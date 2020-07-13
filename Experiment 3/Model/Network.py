from Node import *
import math

class Network:

	def __init__(self, name, choiceNodes=None, edges=None):
		self.name = name
		self.decisionNode = DecisionNode(5)
		self.utilityNode = UtilityNode(5)

		self.choices = choiceNodes
		if self.choices is None:
			self.choices = []

		self.edges = edges
		if self.edges is None:
			self.edges = {}
		self.edges['decision'] = ['utility']

	def __str__(self):
		"""How this object is displayed when printed"""
		return self.name + " = " \
			+ "{ clown: " + str(self.getNode('clown').getValue()) \
			+ ", magician: " + str(self.getNode('magician').getValue()) \
			+ ", acrobat: " + str(self.getNode('acrobat').getValue()) + " }"
	def __repr__(self):
		return self.name

	def addChoice(self, choiceNode):
		"""Adds a given choice node to this network"""
		self.choices = self.choices[:] + [choiceNode]

	def addChoices(self, choicesToAdd):
		"""Adds a list of choice nodes to this network."""
		[self.addChoice(choiceNode) for choiceNode in choicesToAdd]

	def addConnection(self, node1, node2):
		"""Adds an edge from node1 to node2 in this Network.

		Returns:
			False if the nodes are equal or either do not exist, else True.
		"""
		if node1 == node2:
			return False
		node1Exists = False
		node2Exists = False
		for node in self.choices:
			if node.name == node1:
				node1Exists = True
			if node.name == node2:
				node2Exists = True
		if node1Exists and node2Exists:
			# add connection to edges
			if self.edges[node1] is None:
				self.edges[node1] = [node2]
			else:
				self.edges[node1] = self.edges[node1][:] + [node2]
			return True

		# these nodes do not exist
		return False

	def getChoiceProbabilities(self):
		"""Finds all possible choices that need to be considered.

		This is a helper procedure for calculating utility by providing all
		the choices required to be taken into consideration. Each value in
		the output comes with a probability indicating how sure we are that
		choice is made. So if person A could be at either positions 1 or 2,
		each has a probability of 0.5 since there are only 2 unknowns.

		TODO: change how probability is calculated. If A can be at positions
		{1, 2, 3} and B can be at positions {3, 4, 5}, the probability can't
		be calculated based on number of positions we know for sure, but the
		number of possible positions B can be given what positions we know.

		Returns:
			Array of objects providing 3 values mapped to keys:
				'likes': if this node is liked,
				'position': position corresponding to this choice,
				'probability': how sure we are this node made this choice.
		"""
		output = []
		takenPositions = []
		for key, edges in self.edges.items():
			if 'decision' in edges:
				node = self.getNode(key)
				if isinstance(node, ChoiceNode):
					position = node.getValue()
					output.append({
						'likes': node.likes,
						'position': position,
						'probability': 1.0
					})
					takenPositions.append(position)

		numTakenPositions = len(takenPositions)
		for choiceNode in self.choices:
			edges = []
			if choiceNode.name in self.edges:
				edges = self.edges[choiceNode.name]

			if 'decision' not in edges:
				possibleValues = choiceNode.possibleValues()
				# save length so it doesn't have to be calculated each iteration
				numPossibleValues = len(possibleValues)
				for position in possibleValues:
					if position not in takenPositions:
						output.append({
							'likes': choiceNode.likes,
							'position': position,
							'probability': 1.0 / (numPossibleValues
								- numTakenPositions)
						})
		return output

	def calculateUtility(self, section, stagePostion, likesStage, free_param):
		"""Computes the utility of a given decision.

		Utility here is defined as the city block distance from one section
		to the stage. If the stage is liked, it is the inverse of the
		city block distance.

		Returns:
			Float valued utility of the given decision.
		"""
		# utility for disliking this stage
		# utilityOutput = math.sqrt(((section - stagePostion) ** 2) + 1.0)
		# print("Difference = {}".format(section - stagePostion))
		utilityOutput = math.exp(-1 * abs(free_param * (section - stagePostion)))
		# print("Utility = {}\n".format(utilityOutput))
		if likesStage == 0:
			# we are indifferent about this stage
			return 0
		if likesStage == 1:
			# we like this stage
			return utilityOutput
		return 1 - utilityOutput

	def getAllUtilities(self, free_param):
		"""Computes the all utilities for all possible decisions.

		First identify what choices the decision knows about. Then for each
		one of these choices, sum together the utilities for each possible
		decision.

		Since utility is additive, we are always summing them together.

		Returns:
			Array of float valued sums of utility where each index represents
			the total sum for the decision at that index.
		"""
		utilities = [0.0] * len(self.decisionNode.possibleValues())
		for choice in self.getChoiceProbabilities():
			if choice['likes'] != 0:
				for value in self.decisionNode.possibleValues():
					utilities[value - 1] += choice['probability'] \
						* self.calculateUtility(value, choice['position'],
							choice['likes'], free_param)
		return utilities

	def probabilityOfDecision(self, decision, free_param):
		"""Computes the probability of a decision given this network.

		P(decision | N) = utility(decision) / sum(utilities for all decisions)

		Returns:
			Float valued probability of this decision being made for this
			network.
		"""
		allUtilities = self.getAllUtilities(free_param)
		utilitySum = float(sum(allUtilities))
		if utilitySum == 0.0:
			return 0.0
		return allUtilities[decision - 1] / float(sum(allUtilities))
		#return allUtilities[decision - 1]


	def complexity(self):
		"""Computes the complexity of this network.

		Complexity for decision networks can be computed by their
		minimum description length (MDL).

		Complexity(N) = sum(x_i * q_i) for all nodes i in network N
		where x_i is the number of values that node i can take on
		and q_i is the number of values that the parents of i can take on.

		Returns:
			Integer values complexity of this network.
		"""
		output = 0
		for node in self.choices[:] + [self.decisionNode, self.utilityNode]:
			parentValues = 0
			for key, edges in self.edges.items():
				if node.name in edges:
					parentNode = self.getNode(key)
					if parentValues < 1:
						parentValues = len(parentNode.possibleValues())
					else:
						parentValues *= len(parentNode.possibleValues())
			output += len(node.possibleValues()) * parentValues
		return output

	def simplicity(self):
		"""Computes the simplicity of this network.
		
		Simplicity can be defined as the inverse of the complexity.

		Returns:
			Float valued simplicity of this network.
		"""
		return 1.0 / self.complexity()

	def getNode(self, name):
		"""Fetches the node object of a given name.

		Returns:
			If this network contains a node with the given name, the node
			object itself, else None.
		"""
		if name == 'utility':
			return self.utilityNode
		if name == 'decision':
			return self.decisionNode
		for choice in self.choices:
			if choice.name == name:
				return choice
		return None

	def probabilityOfThisNetworkGivenDecision(self, decision, free_param):
		"""Computes the probability of this network given a decision.

		P(N | decision) ~ P(decision | N) * P(N)

		The greater probability, the greater chance this network explains
		why a person made the given decision.

		Returns:
			Float valued probability of this network being the network
			used for a given decision.
		"""
		# use this to care about prior probability
		return self.probabilityOfDecision(decision, free_param) * self.simplicity()
		
		# use this to not care about prior probability
		#return self.probabilityOfDecision(decision, free_param)
		
		# use this to only care about prior probability
		#return self.simplicity()