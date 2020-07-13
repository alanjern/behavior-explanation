from Network import Network
from Node import *
import csv
import numpy as np

def generateNetworks(likesClowns, likesMagicians, likesAcrobats):
	"""Constructs all decision networks with given preferences."""
	possibleStages = [1, 2, 3]
	performers = ['clown', 'magician', 'acrobat']
	likes = [likesClowns, likesMagicians, likesAcrobats]

	# don't know anything
	networks = [getNetwork(likes, [-1, -1, -1])]

	# all networks where we only know one position
	for stage in possibleStages:
		networks.append(getNetwork(likes, [stage, -1, -1]))
		networks.append(getNetwork(likes, [-1, stage, -1]))

	# all networks where we know all stages
	for stages in permutations(possibleStages):
		networks.append(getNetwork(likes, stages))

	return networks

def getNetwork(likes, stages, name='net'):
	"""Constructs a decision network according to the inputs."""
	choiceNodes = []
	edges = {}
	performers = ['clown', 'magician', 'acrobat']
	for i in range(len(likes)):
		if stages[i] != -1:
			choiceNodes.append(ChoiceNode(performers[i], likes[i], stages[i]))
			edges[performers[i]] = ['decision']
		else:
			choiceNodes.append(ChoiceNode(performers[i], likes[i]))
		if likes[i] != 0:
			if performers[i] in edges:
				edges[performers[i]] = edges[performers[i]][:] + ['utility']
			else:
				edges[performers[i]] = ['utility']
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
	decisions = [1, 2, 3]
	with open('./predictions/' + fileName + '.csv', 'w', newline='') as f:
		writer = csv.writer(f, delimiter=',')

		columns = ['Decision', 'Clown Position', 'Magician Position',
			'Acrobat Position']
		for i in np.linspace(0.05, 3.0, num=60):
			columns = columns[:] + ['Probability-' + str(i)]

		# write header of each column
		writer.writerow(columns)
		
		nets = False
		probability_columns = [[0 for y in range(60)] for x in range(len(decisions) * 13)]
		processed_free_parameters = 0
		for i in np.linspace(0.05, 3.0, num=60):
			p, nets = probabilitiesForDecisions(decisions, likes, i)
			index = 0
			for p_set in p:
				for probability in p_set:
					probability_columns[index][processed_free_parameters] = probability
					index += 1
			processed_free_parameters += 1

		processed_rows = 0
		for d in decisions:
			for net in nets:
				row_data = [
					d,
					net.getNode('clown').getValue(),
					net.getNode('magician').getValue(),
					net.getNode('acrobat').getValue()
				]
				for probability in probability_columns[processed_rows]:
					row_data = row_data[:] + [probability]
				processed_rows += 1
				writer.writerow(row_data)
			writer.writerow([])
					

		# p, nets = probabilitiesForDecisions(decisions, likes)
		# for p_set, d in zip(p, decisions):
		# 	for probability, net in zip(p_set, nets):
		# 		writer.writerow([
		# 			d,
		# 			net.getNode('clown').getValue(),
		# 			net.getNode('magician').getValue(),
		# 			net.getNode('acrobat').getValue(),
		# 			probability
		# 		])
		# 	writer.writerow([])
	print("Saved report: " + fileName)
	
	with open('./predictions/' + fileName + '_tidy.csv', 'w', newline='') as f:
		writer = csv.writer(f, delimiter=',')

		columns = ['Acrobat Position', 'Clown Position', 'Magician Position',
			'Decision', 'FreeParam', 'Probability']

		# write header of each column
		writer.writerow(columns)
		
		probability_columns = [[[0 for x in range(13)] for y in range(len(decisions))] for z in range(60)]
		f_index = 0
		for f in np.linspace(0.05, 3.0, num=60):
			p_set, nets = probabilitiesForDecisions(decisions, likes, f)
			probability_columns[f_index] = p_set
			f_index += 1
		
		d_index = 0
		for d in decisions:
			nets = generateNetworks(likes[0], likes[1], likes[2])
			net_index = 0
			for net in nets:
				f_index = 0
				for f in np.linspace(0.05, 3.0, num=60):		
					row_data = [
						convertStagePosition(net.getNode('acrobat').getValue()),
						convertStagePosition(net.getNode('clown').getValue()),
						convertStagePosition(net.getNode('magician').getValue()),
						d,
						f,
						probability_columns[f_index][d_index][net_index]
					]
					writer.writerow(row_data)
					f_index += 1
				net_index += 1
			d_index += 1
		
	
	print("Saved report: " + fileName + ' (tidy version)')


def generateAllReports():
	"""Saves reports for each experiment."""
	generateReport('dislikesClowns_predictions', [-1, 0, 0])
	generateReport('likesClowns_predictions', [1, 0, 0])
	#generateReport('dislikesClowns_rationalsupportonly_predictions', [-1, 0, 0])
	#generateReport('likesClowns_rationalsupportonly_predictions', [1, 0, 0])
	#generateReport('dislikesClowns_simplicityonly_predictions', [-1, 0, 0])
	#generateReport('likesClowns_simplicityonly_predictions', [1, 0, 0])
	print("All reports saved")

def main():
	# comment line below if you don't want to overwrite predicted data files
	generateAllReports()

if __name__ == '__main__':
	main()