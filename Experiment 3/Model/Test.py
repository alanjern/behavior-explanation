from Network import Network
from Node import *

def testAll():
	allCorrect = True

	# test complexity
	complexityIncorrect = testComplexity()
	allCorrect &= printResults(complexityIncorrect, "testComplexity()")

	# finish tests
	if allCorrect:
		print("All Test Cases Passed!")

def printResults(incorrect, name):
	if len(incorrect) == 0:
		return True
	print("------------------------")
	print(name, "incorrect results:")
	for case in incorrect:
		print(case['name'], "failed! Expected =", case['expected'],
			"Actual =", case['actual'])


def testComplexity():
	networks = [
		Network('n1', [
			ChoiceNode('clown', -1),
			ChoiceNode('magician', 0),
			ChoiceNode('acrobat', 0)
		], {
			'clown': ['utility']
		}),
		Network('n2', [
			ChoiceNode('clown', -1, 1),
			ChoiceNode('magician', 0),
			ChoiceNode('acrobat', 0)
		], {
			'clown': ['utility', 'decision']
		}),
		Network('n3', [
			ChoiceNode('clown', -1, 1),
			ChoiceNode('magician', 0, 2),
			ChoiceNode('acrobat', 0)
		], {
			'clown': ['utility', 'decision'],
			'magician': ['decision']
		}),
		Network('n4', [
			ChoiceNode('clown', -1, 1),
			ChoiceNode('magician', 0, 2),
			ChoiceNode('acrobat', 0, 3)
		], {
			'clown': ['utility', 'decision'],
			'magician': ['decision'],
			'acrobat': ['decision']
		}),
		# networks not in experiment
		Network('n5', [
			ChoiceNode('clown', -1),
			ChoiceNode('magician', 0),
			ChoiceNode('acrobat', 0)
		], {
			'clown': ['utility'],
			'magician': ['utility']
		}),
		Network('n6', [
			ChoiceNode('clown', -1, 1),
			ChoiceNode('magician', 0),
			ChoiceNode('acrobat', 0)
		], {
			'clown': ['utility', 'decision'],
			'magician': ['utility']
		}),
		Network('n7', [
			ChoiceNode('clown', -1, 1),
			ChoiceNode('magician', 0, 2),
			ChoiceNode('acrobat', 0)
		], {
			'clown': ['utility', 'decision'],
			'magician': ['utility', 'decision']
		}),
		Network('n8', [
			ChoiceNode('clown', -1, 1),
			ChoiceNode('magician', 0, 2),
			ChoiceNode('acrobat', 0, 3)
		], {
			'clown': ['utility', 'decision'],
			'magician': ['utility', 'decision'],
			'acrobat': ['decision']
		}),
		Network('n9', [
			ChoiceNode('clown', -1),
			ChoiceNode('magician', 0),
			ChoiceNode('acrobat', 0)
		], {
			'clown': ['utility'],
			'magician': ['utility'],
			'acrobat': ['utility']
		}),
		Network('n10', [
			ChoiceNode('clown', -1, 1),
			ChoiceNode('magician', 0),
			ChoiceNode('acrobat', 0)
		], {
			'clown': ['utility', 'decision'],
			'magician': ['utility'],
			'acrobat': ['utility']
		}),
		Network('n11', [
			ChoiceNode('clown', -1, 1),
			ChoiceNode('magician', 0, 2),
			ChoiceNode('acrobat', 0)
		], {
			'clown': ['utility', 'decision'],
			'magician': ['utility', 'decision'],
			'acrobat': ['utility']
		}),
		Network('n12', [
			ChoiceNode('clown', -1, 1),
			ChoiceNode('magician', 0, 2),
			ChoiceNode('acrobat', 0, 3)
		], {
			'clown': ['utility', 'decision'],
			'magician': ['utility', 'decision'],
			'acrobat': ['utility', 'decision']
		})
	]
	complexities = [
	#known: 0		1		2		3
			75, 	90, 	120, 	210,	# care about one choice
			225,	240, 	270, 	360,	# care about two choices
			675, 	690, 	720, 	810		# care about three choices
	]

	incorrect = []
	for i in range(len(networks)):
		complexity = networks[i].complexity()
		expected = complexities[i]
		if complexity != expected:
			# test case failed
			incorrect.append({
				'name': networks[i].name,
				'expected': expected,
				'actual': complexity
			})
	return incorrect

if __name__ == '__main__':
	testAll()