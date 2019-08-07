
class Node:

	def __init__(self, name, possibleValues, value):
		self.name = name
		self._possibleValues = possibleValues
		self._valueIndex = value

	def possibleValues(self):
		return self._possibleValues

	def getValue(self):
		if self._valueIndex is None:
			return None
		return self._possibleValues[self._valueIndex-1]

class ChoiceNode(Node):

	def __init__(self, name, likes, position=None):
		Node.__init__(self, name, [1, 3, 5], position)
		self.likes = likes

class DecisionNode(Node):

	def __init__(self, numDecisions):
		Node.__init__(self, 'decision', list(range(1, numDecisions + 1)), None)

	def makeDecision(self, decision):
		self._valueIndex = decision

class UtilityNode(Node):

	def __init__(self, numDecisions):
		Node.__init__(self, 'utility', list(range(1, numDecisions + 1)), None)
