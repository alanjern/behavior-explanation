Experiment 2 analysis code
===========================

* `analyzedata.R`: This file analyzes the data for Experiment 1B. It computes the Cohen's kappa values reported in the paper. It then generates the plots comparing the top N predicted explanations to the proportion of times subjects generated them.
* `bestfitting_modelpredictions.csv`: This file contains the best-fitting model predictions, computed and generated using the Experiment 1A `analyzedata.R` script. This file is used by the Experiment 2 `analyzedata.R` script in the current directory to determine the top N predicted explanations for each model.
