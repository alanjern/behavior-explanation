Experiment 1B analysis code
===========================

* `analyzedata.R`: This script analyzes the data and generates the plots for Experiment 1B.
   Specifically, it does the following:
    * Filters out subjects who failed the attention check.
    * Performs the statistical tests reported in the paper.
    * Finds the best-fitting parameter values for each model.
    * Computes correlation coefficients between each model's predictions and subjects' mean ratings.
    * Creates a file named `bestfitting_modelpredictions.csv` that contains all 
      (unnormalized) model predictions for all conditions.
    * Generates all the plots presented in the paper.
* `analyzedata_noexclusions.R`: This script is identical to the first but does not exclude any subjects.
