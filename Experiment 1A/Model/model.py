import sys
import copy
import json
import random
import math

import numpy as np
import pandas as pd

def get_node_for_id(i, nodes):
    """
    Gets the node in the network (list of nodes) with the given id (i)
    """
    for n in nodes:
        if n['id'] == i: # finds the matching id
             return n # returns it

def update_network_for_knowledge(net, decisions, knowledge):
    """
    Updates the network (chance nodes) with the knowledge (edges from chance to
    decision)
    """
    for node in net['nodes']:
        if node['type'] == 'decisions':
            for p_id in node['parents']:
                # get parents that are chance nodes and need to be updated
                parent = get_node_for_id(p_id)
                if parent['type'] == 'chance':
                    # update node probability
                    # only works for simple cases now (chance nodes don't have parents)
                    e = [parent['name']+':'+knowledge[parent['name']]]
                    events = []
                    for event in parent['CPT']:
                        if event['event'] != e: # if this isn't the known event
                            events.append(event) # add it to the list
                            events[-1]['prob'] = 0 # with 0 probability
                    parent['CPT'] = [{'event':e, 'prob':1}] # add the known event with prob 1
                    parent['CPT'] += events # add all the events that won't occur
                                            # used for complexity calculations


def row_is_valid(row, decisions):
    """
    Checks if a given row of the CPT matches the decisions
    """
    for e in row['event']:
        if e.split(':')[0] in decisions and decisions[e.split(':')[0]] != e.split(':')[1]:
            return False
    return True

def get_val(name, event):
    """
    Gets the value for a node involved in an event
    """
    for e in event:
        if e.split(':')[0] == name:
            return e.split(':')[1]
    return 'INVALID'

def evaluate_node(node, decisions):
    """
    Evaluates a node
    """
    if node['type'] == 'decision': # if decision node, give it decision value
        node['val'] = decisions[node['name']]
    elif node['type'] == 'chance': # if chance node, randomly select a value
        p = 0
        for row in node['CPT']:
            if row_is_valid(row, decisions):
                p += np.random.random()
                if row['prob'] > p:
                    node['val'] = get_val(node['name'], row['event'])

def calc_utility(net, decisions, k):
    """
    Calculates the utility for the network
    """
    # find utility node
    utility_node = None
    for node in net['nodes']:
        if node['type'] == 'utility':
            utility_node = node
            break
        else:
            evaluate_node(node, decisions)

    # evaluate utility function
    # This is for the seating experiment, different utility functions can be used here
    utility_node['val'] = utility_seating(net, decisions, k)
    print('Utility =', utility_node['val'])
    return utility_node['val']

def utility_seating(net, decisions, k):
    """
    Calculates the utility for the seating experiment
    k is a free parameter
    """
    near_far = net['props']['near_far'] # stores the "near to" or "far from" information

    # First compute utility for chosen seat
    d = [] # distance list, filled with distance from each person
    r = [] #
    for node in net['nodes']:
        if node['type'] != 'utility' and node['type'] != 'decision':
            val = int(node['val'])
            d.append([np.abs(val - decisions['seat_choice']), node['name']]) # add distance from each person
    # near_far is an array [0,1] for near, [1,-1] for far
    for i in range(len(d)):
        for j in range(len(near_far)):
            if d[i][1] == near_far[j][2]:
                # e^(-kd) utility: Utility function used in main text
                r.append(near_far[j][0] + near_far[j][1]*np.exp(-k*d[i][0]))

                # Alternative utility function used in Appendix (to allow for negative utiliities)
                #r.append(near_far[j][1]*np.exp(-k*d[i][0]))
                break
    #return np.sum(r)
    u_chosen = np.sum(r)

    # Now compute utilities for all the other options (non-chosen seats)
    u_nonchosen = []
    for seat in decisions['other_options']:
        d = []
        r = []
        for node in net['nodes']:
            if node['type'] != 'utility' and node['type'] != 'decision':
                val = int(node['val'])
                d.append([np.abs(val - seat), node['name']])
        for i in range(len(d)):
            for j in range(len(near_far)):
                if d[i][1] == near_far[j][2]:
                    # e^(-kd) utility: Utility function used in main text
                    r.append(near_far[j][0] + near_far[j][1]*np.exp(-k*d[i][0]))

                    # Alternative utility function used in Appendix (to allow for negative utiliities)
                    #r.append(near_far[j][1]*np.exp(-k*d[i][0]))
                    break
        u_nonchosen.append(np.sum(r))


    # softmax decision function (used in main text)
    return u_chosen / np.sum(u_nonchosen)

    # Luce choice rule alternative decison function (used in Appendix)
    #return np.exp(u_chosen) / np.sum(np.exp(u_nonchosen))

def evaluate_network(net, decisions, knowledge, k):
    """
    Evaluates the network for utility calculation
    """
    # update network to include knowledge
    update_network_for_knowledge(net, decisions, knowledge)

    # calc utility (rationality check)
    return calc_utility(net, decisions, k)

def number_of_vals(net, node):
    """
    Calculates the number of values a node can take
    """
    if node['type'] == 'decision':
        return len(node['values']) # if it is a decision node, length of possible values
    elif node['type'] == 'utility':
        # if it is a utility node, the length of 'near_far' is the number of people cared about
        # and it is doubled because you can be near or farm from each of those people
        # and 6 is added because there are 6 places you can sit
        # (9 total seat - 3 people already there)
        return 6 + 2*len(net['props']['near_far'])
    elif node['type'] == 'chance':
        q = 0
        used = []
        for p in node['CPT']:
            # for each event
            for event in p['event']:
                # check if it has been used before
                if node['name']+':' in event and event not in used:
                    used.append(event)
                    # if not, increase possbile values by 1
                    q += 1
        # constant here to keep network structure files more simple. This is correct becuse
        # there are 9 places for A to sit, 8 for B to sit and 7 for C to sit, 9+8+7 = 24
        # and 8+8+8 = 24
        return 8

def compute_complexity(net):
    """
    Computes the complexity of the network
    """
    # returns a tuple for complexity with and without knowledge edges (knowledge, no_knowledge)
    knowledge = 0 # counting knowledge edges
    no_knowledge = 0 # not counting knowledge edges
    for node in net['nodes']:
        q = 0
        q2 = 0
        for p_id in node['parents']:
            parent = get_node_for_id(p_id, net['nodes'])
            if node['type'] == 'decision' and parent['type'] == 'chance':
                # count knowledge edges separate
                q2 += number_of_vals(net, parent)
                continue
            q += number_of_vals(net, parent)
        knowledge += (number_of_vals(net, node) - 1) * (q+q2) # q+q2 is all edges
        no_knowledge += (number_of_vals(net, node) - 1) * q # q is all but knowledge edges
    print('Complexity:',(knowledge, no_knowledge))
    return (knowledge, no_knowledge)

if __name__ == '__main__':
    total_knowledge = [] # store all the knowledge prediction values for plotting
    total_complexity = [] # store all complexity values for plotting
    total_utility = [] # store all utility values for plotting

    # Arrays of data to make up the final data frame to output
    conditions = [] # list of condition numbers
    explanations = [] # list of explanations
    params = [] # list of k parameter values
    simplicity = [] # simplicity model predictions
    rationalsupport = [] # rational support model un-normalized predictions
    predictions = [] # full model un-normalized predictions

    for ind in [1,2,3]: # for each of the 4 cases, load the seat network
        if ind == 1:
            import seat_networks_x1 as sn
        elif ind == 2:
            import seat_networks_x2 as sn
        elif ind == 3:
            import seat_networks_x3 as sn
        complexity = [] # complexity values
        utility = [] # utility values

        # Go through all 13 explanations

        print('\n======= Condition ' + str(ind) + ' ============\n')

        # possible param values
        k_values = np.linspace(0.05,3,60)

        for k in k_values:

            case1 = sn.seat_near_a()
            print('Near A:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            complexity.append(c[0])
            utility.append(u)
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Near A')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)

            case1 = sn.seat_far_c()
            print('Far C:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            complexity.append(c[0])
            utility.append(u)
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Far C')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)


            case1 = sn.seat_near_a_far_c()
            print('Near A, Far C:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            complexity.append(c[0])
            utility.append(u)
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Near A, Far C')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)

            case1 = sn.seat_near_a_far_b_far_c()
            print('Near A, Far B and C:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            complexity.append(c[0])
            utility.append(u)
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Near A, Far B, Far C')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)


            case1 = sn.seat_near_a_far_b()
            print('Near A, Far B:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            complexity.append(c[0])
            utility.append(u)
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Near A, Far B')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)


            case1 = sn.seat_far_b()
            print('Far B:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            complexity.append(c[0])
            utility.append(u)
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Far B')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)


            case1 = sn.seat_far_b_far_c()
            print('Far B and C:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            complexity.append(c[0])
            utility.append(u)
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Far B, Far C')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)


            case1 = sn.seat_far_a()
            print('Far A:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            complexity.append(c[0])
            utility.append(u)
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Far A')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)


            case1 = sn.seat_near_b_far_c()
            print('Near B, Far C:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            complexity.append(c[0])
            utility.append(u)
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Near B, Far C')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)


            case1 = sn.seat_near_a_near_b_far_c()
            print('Near A and B, Far C:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            complexity.append(c[0])
            utility.append(u)
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Near A, Near B, Far C')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)


            case1 = sn.seat_near_a_near_b()
            print('Near A and B:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            complexity.append(c[0])
            utility.append(u)
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Near A, Near B')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)


            case1 = sn.seat_near_b()
            print('Near B:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            complexity.append(c[0])
            utility.append(u)
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Near B')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)


            case1 = sn.seat_far_a_far_c()
            print('Far A and C:')
            u = evaluate_network(json.loads(case1[0]), json.loads(case1[1]), json.loads(case1[2]), k)
            c = compute_complexity(json.loads(case1[0]))
            prediction = (u*(1.0/c[0]), u*(1.0/c[1]))
            complexity.append(c[0])
            utility.append(u)
            print('Prediction:', prediction[0])

            # Store the predictions in the data frame
            conditions.append(ind)
            explanations.append('Far A, Far C')
            simplicity.append(1/float(c[0]))
            rationalsupport.append(u)
            predictions.append(prediction[0])
            params.append(k)

    # Create the data frame
    predictionsDataFrame = pd.DataFrame({ 'condition': conditions,
                                          'explanation': explanations,
                                          'k': params,
                                          'simplicity': simplicity,
                                          'rationalsupport': rationalsupport,
                                          'fullmodel': predictions})

    # Output predictions into a CSV file
    predictionsDataFrame.to_csv('model_predictions.csv')
