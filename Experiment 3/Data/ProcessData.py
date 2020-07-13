import csv
import re
import pandas as pd
import numpy as np

def processExperiment(experimentNumber, version):
	"""Parses through the csv file Psiturk creates and makes a new, more readable design"""
	fakeWorkers = getFakeWorkers()
	data = []
	allExplanations = []
	allSections = []
	workerIds = []
	numTrials = 4
	numExplanations = 13
	with open('./experiment-'+str(experimentNumber)+'/questiondata.csv', 'rt') as csvFile:
		reader = csv.reader(csvFile, delimiter=',', quotechar='|')
		currentUser = ''
		userData = [[-1 for i in range(numExplanations)] for j in range(numTrials)]
		userExplanations = ["" for i in range(numTrials)]
		userSections = [-1 for i in range(numTrials)]
		isFirst = True
		for row in reader:
			worker = row[0].split(':')[0]
			if worker[:5] == "debug" or worker in fakeWorkers:
				# ignore data from debugging sessions
				continue
			if worker != currentUser:
				if not isFirst:
					data.append(userData)
					allExplanations.append(userExplanations)
					allSections.append(userSections)
					workerIds.append(currentUser)
					userData = [[-1 for i in range(numExplanations)] for j in range(numTrials)]
					userExplanations = ["" for i in range(numTrials)]
					userSections = [-1 for i in range(numTrials)]
				currentUser = worker
				isFirst = False

			if (len(row) < 3):
				print("This row in file is less than 3 columns:\n" + str(row))
			indices = [int(s) for s in re.findall(r'\d+', row[1])]
			if len(indices) == 1:
				# [0]: trial number
				# this contains the value of their explanation of responses
				userExplanations[indices[0]-1] = row[2]
			elif len(indices) == 4 and version == 2:
				# if int(row[1][6]) != indices[0]:
				# 	print("row[1][6] = {} : {} {} {} {}".format(row[1][6], indices[0], indices[1], indices[2], indices[3]))
				# if row[1][13] == ' ':
				# 	if int(row[1][12]) != indices[1]:
				# 		print("row[1][12] = {} : {} {} {} {}".format(row[1][12], indices[0], indices[1], indices[2], indices[3]))
				# else:
				# 	if int(row[1][12] + row[1][13]) != indices[1]:
				# 		print("row[1][12:13] = {} : {} {} {} {}".format(row[1][12] + row[1][13], indices[0], indices[1], indices[2], indices[3]))
				
				# [0]: trial number
				# [1]: explanation number
				# [2]: order explanation appeared to worker
				# [3]: section the person was shown as sitting in
				userSections[indices[0]-1] = int(indices[3]) + 1
				userData[indices[0]-1][indices[1]] = int(row[2])
			elif len(indices) == 2 and version == 1:
				# [0]: trial number
				# [1]: explanation number
				userData[indices[0]-1][indices[1]] = int(row[2])
		data.append(userData)
		allExplanations.append(userExplanations)
		allSections.append(userSections)
		workerIds.append(currentUser)


	# remove users who didn't finish and sum data
	data_sums = [[0 for i in range(numExplanations)] for j in range(numTrials)]
	data_final = []
	explanation_final = []
	sections_final = []
	workerIds_final = []
	numCheaters = 0
	for user, exp, workerId, sections in zip(data, allExplanations, workerIds, allSections):
		# user contains all responses from entire HIT
		# exp contains a list of their explanations for each trial
		trialNumber = 0
		include = True
		userCheated = False
		for trialData in user:
			# trialData contains all responses for this trial
			trialNumber += 1
			if trialNumber == 4:
				if sum(trialData) != -13:
					# one of the responses were selected in attention check
					numCheaters += 1
					userCheated = True
				break
			if -1 in trialData:
				# they didn't finish the HIT
				include = False
				break
		if include:
			data_final.append(user)
			explanation_final.append(exp)
			sections_final.append(sections)
			workerIds_final.append(workerId)
			if not userCheated:
				for trial in range(len(user)-1):
					for i in range(len(user[trial])):
						data_sums[trial][i] += user[trial][i]


	with open('./data/experiment-'+str(experimentNumber)+'-data.csv', 'w', newline='') as f:
		writer = csv.writer(f, delimiter=',')
		writer.writerow(["WorkerId", "Trial", "Section", "Explanation 0", "Explanation 1",
			"Explanation 2", "Explanation 3", "Explanation 4", "Explanation 5",
			"Explanation 6", "Explanation 7", "Explanation 8", "Explanation 9",
			"Explanation 10", "Explanation 11", "Explanation 12", "Reasoning"])

		# write the mean over all HITS
		trialNumber = 0
		numHITS = float(len(data_final) - numCheaters)
		if numHITS == 0:
			print("There are no HITs for this experiment version!")
			return
		print("len(data_final) = {}, numCheaters = {}".format(len(data_final), numCheaters))
		for trialRow in data_sums:
			trialNumber += 1
			if trialNumber == 4:
				break
			writer.writerow(["--"] + [str(trialNumber)] + [str(trialNumber)] + reorderDataRow([float(x) / numHITS for x in trialRow]) + ["MEAN"])

		# add empty row for spacing
		writer.writerow([])

		# calculate standard deviation of data
		# data_std = [[(float(x) - (float(x) / numHITS)) ** 2 for x in trialRow] for trialRow in data_sums]
		# data_std = [[(x / numHITS) ** 0.5 for x in data] for data in data_std]

		# write standard deviation to csv
		# trialNumber = 0
		# for trialRow in data_std:
		# 	trialNumber += 1
		# 	if trialNumber == 4:
		# 		break
		# 	writer.writerow([str(trialNumber)] + trialRow + ["STANDARD DEVIATION"])

		# add empty row for spacing
		# writer.writerow([])

		# write user's data from HIT
		# print("{")
		for row1, row2, workerId, sections in zip(data_final, explanation_final, workerIds_final, sections_final):
			trialNumber = 1
			# print("\"%s\"," % workerId)
			for trialRow, explanation, section in zip(row1, row2, sections):
				writer.writerow([workerId] + [str(trialNumber)] + [str(section)] + reorderDataRow(trialRow) + [explanation])
				# writer.writerow([workerId] + [str(trialNumber)] + [str(section)] + trialRow + [explanation])
				trialNumber += 1
			# add empty row for spacing
			writer.writerow([])
		# print("}")
	# finish
	print("Finished data processing")
	print("Number of cheaters:    {}".format(numCheaters))
	print("Number of usable HITS: {}".format(numHITS))

def getFakeWorkers():
	# These were Turkers that had somehow managed to submit the HIT without submitting any data
	return ["A319HGTKM0UY0V", "A145AXBDTCIW6Z", "A1KUJU24MMU3XQ",
					"A2D4E1C1UD7ZK6", "A1PKDJYDESDP3F", "A1B3XMTSAYWBT6",
					"A2K0ZIL8MS0N3E", "A4FSLIWM1NCKF"]

def reorderDataRow(dataRow):
	"""Reorders the questions to match the order they appear in decision-net predictions"""
	output = []
	indices = [12, 0, 3, 1, 4, 2, 5, 6, 7, 8, 10, 9, 11]
	for i in indices:
		output = output[:] + [dataRow[i]]
	return output


def getExplanations():
	"""Returns a list of all explanation wording used in experiment"""
	explanations = ['<strong>clown</strong> would be on <strong>Stage A</strong>', '<strong>magician</strong> would be on <strong>Stage A</strong>', '<strong>acrobat</strong> would be on <strong>Stage A</strong>', '<strong>clown</strong> would be on <strong>Stage B</strong>', '<strong>magician</strong> would be on <strong>Stage B</strong>', '<strong>acrobat</strong> would be on <strong>Stage B</strong>', '<strong>clown</strong> would be on <strong>Stage C</strong>', '<strong>magician</strong> would be on <strong>Stage C</strong>', '<strong>acrobat</strong> would be on <strong>Stage C</strong>']
	names = ["Steve"]

	output = []
	for i in range(0, len(explanations), 3):
		output = output[:] + [names[0] + ' believed that the ' + explanations[i]]

	for i in range(1, len(explanations), 3):
		output = output[:] + [names[0] + ' believed that the ' + explanations[i]]

	for i in range(3):
		for j in range(3, 6):
			if (j % 3 != i):
				for k in range(6, len(explanations)):
					if (k % 3 != j % 3 and k % 3 != i):
						output = output[:] + [names[0] + ' believed that the ' + explanations[i] + ', the ' + explanations[j] + ', and the ' + explanations[k]]
  
	output = output[:] + [names[0] + ' didn\'t know where any of the performers would be']
	return output


def saveTidyExpData(inputFile, outputFile):
	workerid = []
	trial = []
	# section = []
	exp0 = []
	exp1 = []
	exp2 = []
	exp3 = []
	exp4 = []
	exp5 = []
	exp6 = []
	exp7 = []
	exp8 = []
	exp9 = []
	exp10 = []
	exp11 = []
	exp12 = []
	explanations = []

	with open(inputFile, 'r') as f:
		print("Columns -> {}".format(next(f)))
		next(f)
		next(f)
		next(f)
		next(f)
		i = 0
		currentWorker = 0
		for line in f:
			line = line.split(',')
			# skip over blank lines in file
			if len(line) != 17 or line[0] == "":
				continue
			if currentWorker != line[0]:
				i += 1
				currentWorker = line[0]
			workerid.append(i)
			trial.append(int(line[1]))
			# section.append(int(line[2]))
			exp0.append(int(line[3]))
			exp1.append(int(line[4]))
			exp2.append(int(line[5]))
			exp3.append(int(line[6]))
			exp4.append(int(line[7]))
			exp5.append(int(line[8]))
			exp6.append(int(line[9]))
			exp7.append(int(line[10]))
			exp8.append(int(line[11]))
			exp9.append(int(line[12]))
			exp10.append(int(line[13]))
			exp11.append(int(line[14]))
			exp12.append(int(line[15]))
			explanations.append(line[16])

	df = pd.DataFrame({
		'Subject': workerid,
		'Condition': trial,
		# 'Section': section,
		'Explanation 00': exp0,
		'Explanation 01': exp1,
		'Explanation 02': exp2,
		'Explanation 03': exp3,
		'Explanation 04': exp4,
		'Explanation 05': exp5,
		'Explanation 06': exp6,
		'Explanation 07': exp7,
		'Explanation 08': exp8,
		'Explanation 09': exp9,
		'Explanation 10': exp10,
		'Explanation 11': exp11,
		'Explanation 12': exp12,
		'Reasoning': explanations
	})

	df.to_csv(outputFile)

def saveTidyFiles():

	saveTidyExpData('likesClowns_rawdata.csv', 'likesClowns_data_tidy.csv')
	saveTidyExpData('dislikesClowns_rawdata.csv', 'dislikesClowns_data_tidy.csv')

def main():
	print("--- Experiment v2.1 ---")
	processExperiment(1, 2)

	print("\n--- Experiment v2.2 ---")
	processExperiment(2, 2)
	# exportDatabase(1)

if __name__ == '__main__':
	# main()
	saveTidyFiles()
	# loadTestNpz()
	# for exp, i in zip(reorderDataRow(getExplanations()), range(20)):
	# 	print(str(i) + " : " + exp)
