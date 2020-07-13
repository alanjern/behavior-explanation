Experiment 1A analysis code
===========================

* `analyzedata.R`: This file analyzes the data and generates the plots for Experiment 1A.
   Specifically, it does the following:
    * Performs the statistical tests reported in the paper.
    * Finds the best-fitting parameter values for each model.
    * Computes correlation coefficients between each model's predictions and subjects' mean ratings.
    * Creates a file named `bestfitting_modelpredictions.csv` that contains all 
      (unnormalized) model predictions for all conditions.
    * Generates all the plots presented in the paper.
