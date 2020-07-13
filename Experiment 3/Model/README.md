Experiment 3 model code
========================

This code runs on Python 3.

* `Main.py`: This file generates predictions for the full decision net model, the simplicity-only model, and the rational support-only model for the two conditions (likes clowns and dislikes clowns). By default, the files generate predictions for the full model. To generate predictions for the simplicity-only model or the rational support-only model, uncomment out the line at the bottom of `Network.py` that returns the result in the `probabilityOfThisNetworkGivenDecision` function.
* `MainNonProbabilistic.py`: This file generates predictions for the non-probabilistic model.

There are files in the `predictions` folder for each of the two conditions:
* `*_predictions.csv`: A human-readable version of the full decision net model predictions
* `*_rationalsupportonly_predictions.csv`: A human-readable version of the rational support-only model predictions
* `*_simplicityonly_predictions.csv`: A human-readable version of the simplicity-only model predictions
* `*_nonprob_predictions.csv`: A human-readable version of the non-probabilistic model predictions
* `*_predictions_tidy.csv`: A tidy version of the full decision net model predictions suitable for data analysis
* `*_rationalsupportonly_predictions_tidy.csv`: A tidy version of the rational support-only model predictions suitable for data analysis
* `*_simplicityonly_predictions_tidy.csv`: A tidy version of the simplicity-only model predictions suitable for data analysis
* `*_nonprob_predictions_tidy.csv`: A tidy version of the non-probabilistic model predictions suitable for data analysis

This code was originally written by [Austin Derrow-Pinion](https://github.com/derrowap) and modified by Alan Jern. 