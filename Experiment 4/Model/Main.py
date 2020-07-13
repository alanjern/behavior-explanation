from Network import Network
from Node import *
import csv
import numpy as np

def generateNetworks(likesF1, likesF2, likesF3):
	"""Constructs all decision networks with given preferences."""
	
	likes = [likesF1, likesF2, likesF3]
	
	networks = [getNetwork(likes, [1, -1, -1])]
	networks.append(getNetwork(likes, [-1, 1, -1]))
	networks.append(getNetwork(likes, [-1, -1, 1]))
	networks.append(getNetwork(likes, [1, 1, -1]))
	networks.append(getNetwork(likes, [1, -1, 1]))
	networks.append(getNetwork(likes, [-1, 1, 1]))
	networks.append(getNetwork(likes, [1, 1, 1]))

	return networks

def getNetwork(likes, features, name='net'):
	"""Constructs a decision network according to the inputs."""
	choiceNodes = []
	edges = {}
	
	featureNames = ['f1', 'f2', 'f3']
	for i in range(len(likes)):
		if features[i] != -1:
			choiceNodes.append(ChoiceNode(featureNames[i], likes[i], features[i]))
			edges[featureNames[i]] = ['decision']
		else:
			choiceNodes.append(ChoiceNode(featureNames[i], likes[i]))
		if likes[i] != 0:
			if featureNames[i] in edges:
				edges[featureNames[i]] = edges[featureNames[i]][:] + ['utility']
			else:
				edges[featureNames[i]] = ['utility']
	return Network(name, choiceNodes, edges)

def permutations(numbers):
	"""Computes all permutations of the given array of numbers."""
	output = []
	for i in numbers:
		for j in numbers:
			if i != j:
				for k in numbers:
					if k != j and k != i:
						output.append([i, j, k])
	return output

def probabilitiesForDecisions(decisions, likes, free_param):
	"""Computes the probabilities for each network to reason the most
	accurately for why someone made each decision with the corresponding
	preferences in likes.

	Parameters:
		decisions: array of what decisions to compute
			Ex: [1, 2, 3, 4, 5]
		likes: array indicating what this person does or does not like
			of the form [likesClowns, likesMagicians, likesAcrobats]

	Returns:
		2D array of probabilities of each decision network for all
		specified decisions. Also the networks themselves.
	"""

	nets = generateNetworks(likes[0], likes[1], likes[2])
	
	# print('printing nets')
	# for net in nets:
		# print(net)
	
	scores = []

	for decision in decisions:
		decision_scores = []
		for net in nets:
			score = net.probabilityOfThisNetworkGivenDecision(decision, free_param)
			decision_scores.append(score)
		scores.append(decision_scores)

	output = []
	for i in range(len(scores)):
		probabilities = []
		total_sum = sum(scores[i])
		for score in scores[i]:
			probabilities.append(score / total_sum)
		output.append(probabilities)
	
	return output, nets

def convertStagePosition(pos):
	"""Converts the value of the node in a network from stage position
	to -1 if it has no position. This allows for easier analysis later.
	"""
	
	if pos is None:
		return -1
	else:
		return pos
	
def generateReport(fileName, likes):
	"""Saves predicted probabilities for each network for each decision.

	Generates the probability each network would represent the best reasoning
	for each decision.

	Parameter:
		fileName: name of csv file to save report to.
		likes: array of the form [likesClowns, likesMagicians, likesAcrobats].
	"""
	decisions = [0]
	with open('./predictions/' + fileName + '.csv', 'w', newline='') as f:
		writer = csv.writer(f, delimiter=',')

		columns = ['Decision', 'Feature 1', 'Feature 2',
			'Feature 3']

		# write header of each column
		writer.writerow(columns)
		
		nets = False
		probability_columns = [0 for x in range(len(decisions) * 7)]

		# We pass a dummy value for the free parameter even though it won't be used
		p, nets = probabilitiesForDecisions(decisions, likes, 0.05)
		index = 0
		for p_set in p:
			for probability in p_set:
				probability_columns[index] = probability
				index += 1

		processed_rows = 0
		for d in decisions:
			for net in nets:
				row_data = [
					d,
					net.getNode('f1').getValue(),
					net.getNode('f2').getValue(),
					net.getNode('f3').getValue()
				]
				#for probability in probability_columns[processed_rows]:
				row_data = row_data[:] + [probability_columns[processed_rows]]
				processed_rows += 1
				writer.writerow(row_data)
			writer.writerow([])
					
	print("Saved report: " + fileName)
	
	with open('./predictions/' + fileName + '_tidy.csv', 'w', newline='') as f:
		writer = csv.writer(f, delimiter=',')

		columns = ['Decision', 'Feature 1', 'Feature 2', 'Feature 3', 'Probability']

		# write header of each column
		writer.writerow(columns)
		
		probability_columns = [[0 for x in range(7)] for y in range(len(decisions))]
		p_set, nets = probabilitiesForDecisions(decisions, likes, 0.05)
		probability_columns = p_set
		
		d_index = 0
		for d in decisions:
			nets = generateNetworks(likes[0], likes[1], likes[2])
			net_index = 0
			for net in nets:	
				row_data = [
					d,
					convertStagePosition(net.getNode('f1').getValue()),
					convertStagePosition(net.getNode('f2').getValue()),
					convertStagePosition(net.getNode('f3').getValue()),
					probability_columns[d_index][net_index]
				]
				writer.writerow(row_data)
				net_index += 1
			d_index += 1
		
	
	print("Saved report: " + fileName + ' (tidy version)')


def generateAllReports():
	"""Saves reports for each experiment."""
	generateReport('predictions', [-1, -1, -1])
	print("All reports saved")

def main():
	# comment line below if you don't want to overwrite predicted data files
	generateAllReports()

if __name__ == '__main__':
	main()