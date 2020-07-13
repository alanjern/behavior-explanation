# TODO: If I run the ANOVA again, I may need to update the way it's calculated to account
# for within subjects


# Analyze data

library(tidyverse)
library(ggrepel)
library(effsize)
library(brms)

# Clear workspace
rm(list=ls())

# Return the mean and the bounds of a 95% confidence interval for x
mean_95CI <- function(x) {
    return(mean_se(x,1.96))
}

# Read in data
ratings1 <- read_csv('../Data/rawdata_v1.csv')
ratings2 <- read_csv('../Data/rawdata_v2.csv')
ratings <- bind_rows(ratings1, ratings2)

# Rename the conditions to be in a format suitable for tidyverse manipulation
ratings <- ratings %>% rename(NearAFarB.1 = judgment_1_nearAfarB,
                              NearAFarC.1 = judgment_1_nearAfarC,
                              NearBFarC.1 = judgment_1_nearBfarC,
                              FarAFarC.1 = judgment_1_farAC,
                              FarBFarC.1 = judgment_1_farBC,
                              NearANearBFarC.1 = judgment_1_nearABfarC,
                              NearAFarBFarC.1 = judgment_1_nearAfarBC,
                              NearA.2 = judgment_2_nearA,
                              FarA.2 = judgment_2_farA,
                              NearB.2 = judgment_2_nearB,
                              FarB.2 = judgment_2_farB,
                              FarC.2 = judgment_2_farC,
                              NearANearB.2 = judgment_2_nearAB,
                              NearAFarB.2 = judgment_2_nearAfarB,
                              NearAFarC.2 = judgment_2_nearAfarC,
                              NearA.Check = judgment_chk_nearA,	
                              NearBFarC.2 = judgment_2_nearBfarC,
                              FarA.Check = judgment_chk_farA,
                              FarAFarC.2 = judgment_2_farAC,
                              NearB.Check = judgment_chk_nearB,
                              FarBFarC.2 = judgment_2_farBC,
                              FarB.Check = judgment_chk_farB,
                              NearANearBFarC.2 = judgment_2_nearABfarC,
                              FarC.Check = judgment_chk_farC,
                              NearAFarBFarC.2 = judgment_2_nearAfarBC,
                              NearANearB.Check = judgment_chk_nearAB,
                              NearAFarB.Check = judgment_chk_nearAfarB,
                              NearAFarC.Check = judgment_chk_nearAfarC,
                              NearBFarC.Check = judgment_chk_nearBfarC,
                              FarAFarC.Check = judgment_chk_farAC,
                              FarBFarC.Check = judgment_chk_farBC,
                              NearANearBFarC.Check = judgment_chk_nearABfarC,
                              NearAFarBFarC.Check = judgment_chk_nearAfarBC,
                              NearA.3 = judgment_3_nearA,
                              FarA.3 = judgment_3_farA,
                              NearB.3 = judgment_3_nearB,
                              FarB.3 = judgment_3_farB,
                              FarC.3 = judgment_3_farC,
                              NearANearB.3 = judgment_3_nearAB,
                              NearAFarB.3 = judgment_3_nearAfarB,
                              NearAFarC.3 = judgment_3_nearAfarC,
                              NearBFarC.3 = judgment_3_nearBfarC,
                              FarAFarC.3 = judgment_3_farAC,
                              FarBFarC.3 = judgment_3_farBC,
                              NearANearBFarC.3 = judgment_3_nearABfarC,
                              NearAFarBFarC.3 = judgment_3_nearAfarBC,
                              NearA.1 = judgment_1_nearA,
                              FarA.1 = judgment_1_farA,
                              NearB.1 = judgment_1_nearB,
                              FarB.1 = judgment_1_farB,
                              FarC.1 = judgment_1_farC,
                              NearANearB.1 = judgment_1_nearAB)


# Reshape data into tidy format
ratingsTidy <- ratings %>% gather(expl, rating, 3:54)

# Split explanation and condition
ratingsTidy <- ratingsTidy %>% separate(expl, c("explanation", "condition"))

# Rename the explanation levels
ratingsTidy$explanation <- fct_recode(ratingsTidy$explanation, 
                                      "Near A, Far B" = "NearAFarB",
                                      "Near A, Far C" = "NearAFarC",
                                      "Near B, Far C" = "NearBFarC",
                                      "Far A, Far C" = "FarAFarC",
                                      "Far B, Far C" = "FarBFarC",
                                      "Near A, Near B, Far C" = "NearANearBFarC",
                                      "Near A, Far B, Far C" = "NearAFarBFarC", 
                                      "Near A" = "NearA",
                                      "Far A" = "FarA",
                                      "Near B" = "NearB",
                                      "Far B" = "FarB",
                                      "Far C" = "FarC",
                                      "Near A, Near B" = "NearANearB")  

# Count the number of total subjects
nSubjects <- ratingsTidy %>% select(subject) %>%
                             rapply(function(x) length(unique(x)))
cat(sprintf("Total N: %d", nSubjects),"\n")

# Exclude subjects who failed the attention check

# Identify the subjects who failed attention check
excludedSubjects <- ratingsTidy %>%
                    filter(condition == "Check" & !is.na(rating)) %>%
                    select(subject) %>%
                    rapply(function(x) unique(x))
                    
# Exclude them
#ratingsTidy <- ratingsTidy %>% filter(!(subject %in% excludedSubjects))

# Count number of remaining (non-excluded) subjects
nSubjectsFinal <- ratingsTidy %>% select(subject) %>%
                                  rapply(function(x) length(unique(x)))
cat(sprintf("Final N (after exclusions): %d", nSubjectsFinal),"\n")

# Exclude the attention check ratings
ratingsTidy <- ratingsTidy %>% filter(condition != "Check")

ratingsTidyDF <- as.data.frame(ratingsTidy)
ratingsTidyDF$condition <- as.factor(ratingsTidyDF$condition)
ratingsTidyDF$explanation <- as.factor(ratingsTidy$explanation)
ratingsTidyDF$condition <- relevel(ratingsTidyDF$condition, 2) # set condition 2 to reference level (useful for post-hoc tests)

# Run the model
# Explanation:
#   - condition * explanation makes sure that it also includes coefficients for every interaction
#     of coefficient x explanation (that is, it will allow me to perform comparisons of individiual conditions)
#   - (1|subject) is because subject is a random effect (i.e. it is not a fixed effect that would remain 
#     the same if the experiment were run again
#   - family=cumulative runs ordinal regression
#   - set iterations to a high number because recommendation is that each coefficient should have an effective
#     gibbs sample estimate > 1000 and lower iteration numbers resulted in not enough eff. samples
m <- brm(formula = rating ~ condition * explanation + (1|subject), data=ratingsTidyDF, family=cumulative, iter=5000)
summary(m)

# Perform the hypothesis tests
# Note: Unlike in a t-test, we are not comparing means here, but the learned coefficients in the 
#       regression model from above. So what we are looking for here is the posterior probability
#       assigned to the H1 that the difference in coefficient values for the interactions for the
#       two conditions of interest is sufficiently greater than H0 that the difference is 0.   
# (These predictions are based on exploratory analysis of the data)
# ------------------------

# Note that for these tests, I am comparing interaction coefficients, not means

# Prediction 2: In Condition 1, test whether "Near A" is significantly greater than
# "Near A, far B, far C"
h2 <- hypothesis(m, "condition1:explanationNearA > condition1:explanationNearAFarBFarC")
print('Testing whether Cond 1: Near A is diff from Cond 1: Near A, Far B, Far C')
print(h2)


# Prediction 3: In Condition 3, test whether "Near B" is significantly greater than
# "far from A and C"
h3 <- hypothesis(m, "condition3:explanationNearB > condition3:explanationFarAFarC")
print('Testing whether Cond 3: Near B is diff from Cond 3: Far A, Far C')
print(h3)


# -----------------------------
# Run the pre-registered analysis
#
# Compute the ANOVA
# ------------------
# Prediction 1: A condition x explanation interaction such that subjects overall will
# rate the explanations differently across conditions. For example, "Near A" will get
# a higher rating when the person sat near A than when the person sat near B.
#print(summary(aov(rating ~ factor(condition) * factor(explanation) + Error(subject/(factor(condition)*factor(explanation))), data=ratingsTidy)))

# Compute some post-hoc t-tests
# (These predictions are based on exploratory analysis of the data)
# ------------------------
# Prediction 2: In Condition 1, test whether "Near A" is significantly greater than
# "Near A, far B, far C"
r1 <- ratingsTidy %>% filter(explanation == "Near A", condition == 1)
r2 <- ratingsTidy %>% filter(explanation == "Near A, Far B, Far C", condition == 1)
print(t.test(r1$rating,r2$rating,paired=TRUE,alternative = "greater"))
# Calculate effect size
print(cohen.d(r1$rating,r2$rating,paired=TRUE))

# Prediction 3: In Condition 3, test whether "Near B" is significantly greater than
# "far from A and C"
r3 <- ratingsTidy %>% filter(explanation == "Near B", condition == 3)
r4 <- ratingsTidy %>% filter(explanation == "Far A, Far C", condition == 3)
print(t.test(r3$rating,r4$rating,paired=TRUE,alternative = "greater"))
# Calculate effect size
print(cohen.d(r3$rating,r4$rating,paired=TRUE))


# Reorder the factors as they will appear in the figures
#explanationOrder = c("near.A", "far.C", "far.B", "far.A",
#                 "near.B", "near.A.far.C", "near.A.far.B",
#                 "far.B.far.C", "near.B.far.C",
#                 "near.A.near.B", "far.A.far.C", 
#                 "near.A.near.B.far.C", 
#                 "near.A.far.B.far.C")

# Split by condition
cond1ratingsTidy <- ratingsTidy %>% filter(condition == 1)
cond2ratingsTidy <- ratingsTidy %>% filter(condition == 2)
cond3ratingsTidy <- ratingsTidy %>% filter(condition == 3)

# Sort condition ratings by mean rating
# This is the order in which the data will be plotted in all plots
cond1meanRatings <- cond1ratingsTidy %>% group_by(explanation) %>% 
            summarize(m = mean(rating))
cond1meanRatings <- cond1meanRatings %>% arrange(m)

cond2meanRatings <- cond2ratingsTidy %>% group_by(explanation) %>% 
            summarize(m = mean(rating))
cond2meanRatings <- cond2ratingsTidy %>% group_by(explanation) %>% 
            summarize(m = mean(rating)) %>% arrange(m)

cond3meanRatings <- cond3ratingsTidy %>% group_by(explanation) %>%
            summarize(m = mean(rating)) %>% arrange(m)
            
# Compute mean ratings across all conditions and group together
# Squish the condition and explanation columns together into a single column named "datapoint"
meanRatings <- ratingsTidy %>% unite(datapoint, condition, explanation) %>%
# Then compute the mean rating, grouped by datapoint
            group_by(datapoint) %>% summarize(m = mean(rating))
# Then separate out again
meanRatings <- meanRatings %>% separate(datapoint, c("condition", "explanation"), sep="_")

# Read in model predictions
predictions <- read_csv('../Model/model_predictions.csv')
predictions_utility <- read_csv('../Model/nonprobmodel_predictions.csv')

# Find best-fitting model predictions
k_vals <- seq(0.05,3,0.05)
rmax_fullmodel = -Inf
bestk_fullmodel = 0.05
besta_fullmodel = 0.05
rmax_simplicity = -Inf
bestk_simplicity = 0.05
besta_simplicity = 0.05
rmax_rationalsupport = -Inf
bestk_rationalsupport = 0.05
besta_rationalsupport = 0.05
rmax_utility = -Inf
bestk_utility = 0.05
besta_utility = 0.05

for (k_i in k_vals) {

    # Normalize model predictions so that they sum to 1
    cond1predictions <- predictions %>% filter(condition == 1, k == k_i)
    cond1predictions$fullmodel <- cond1predictions$fullmodel /
                                  sum(cond1predictions$fullmodel)
    cond1predictions$simplicity <- cond1predictions$simplicity /
                                  sum(cond1predictions$simplicity)
    cond1predictions$rationalsupport <- cond1predictions$rationalsupport /
                                  sum(cond1predictions$rationalsupport)

                              
    cond2predictions <- predictions %>% filter(condition == 2, k == k_i)
    cond2predictions$fullmodel <- cond2predictions$fullmodel /
                                  sum(cond2predictions$fullmodel)
    cond2predictions$simplicity <- cond2predictions$simplicity /
                                  sum(cond2predictions$simplicity)
    cond2predictions$rationalsupport <- cond2predictions$rationalsupport /
                                  sum(cond2predictions$rationalsupport)

    cond3predictions <- predictions %>% filter(condition == 3, k == k_i)
    cond3predictions$fullmodel <- cond3predictions$fullmodel /
                                  sum(cond3predictions$fullmodel)
    cond3predictions$simplicity <- cond3predictions$simplicity /
                                  sum(cond3predictions$simplicity)
    cond3predictions$rationalsupport <- cond3predictions$rationalsupport /
                                  sum(cond3predictions$rationalsupport)
                              
    # Put the predictions back together
    predictions2 <- bind_rows(cond1predictions, cond2predictions, cond3predictions)
    predictions2 <- predictions2 %>% select(-X1) # Leave out the superfluous "X" column that is basically just a row number
                              
    # Reshape into tidy format
    cond1predictionsTidy <- cond1predictions %>% 
                                gather(model, prediction, c("fullmodel", "simplicity", "rationalsupport"))
    cond2predictionsTidy <- cond2predictions %>% 
                                gather(model, prediction, c("fullmodel", "simplicity", "rationalsupport"))
    cond3predictionsTidy <- cond3predictions %>% 
                                gather(model, prediction, c("fullmodel", "simplicity", "rationalsupport"))

    # Group all conditions' predictions together
    predictionsTidy <- predictions2 %>% gather(model, prediction, c("fullmodel","simplicity","rationalsupport"))
    predictionsTidy$condition <- as.character(predictionsTidy$condition)

    # Put data and predictions together in the same data frame
    dataAndPredictions <- left_join(meanRatings, predictionsTidy, 
            by=c("condition"="condition", "explanation"="explanation"))
    dataAndPredictions_fullmodel <- dataAndPredictions %>% filter(model=="fullmodel")
    dataAndPredictions_simplicity <- dataAndPredictions %>% filter(model=="simplicity")
    dataAndPredictions_rationalsupport <- dataAndPredictions %>% filter(model=="rationalsupport")

    predictions_utility$condition <- as.character(predictions_utility$condition)
    predictions_utility2 <- predictions_utility %>% select(-X1) %>% filter(k == k_i)
    dataAndPredictions_utility <- left_join(predictions_utility2, meanRatings, 
                                           by=c("condition"="condition", "explanation"="explanation"))

    # Compute correlations
    r_fullmodel <- cor(dataAndPredictions_fullmodel$m, dataAndPredictions_fullmodel$prediction)
    if (r_fullmodel > rmax_fullmodel) {
        rmax_fullmodel <- r_fullmodel
        bestk_fullmodel <- k_i
    }

    r_simplicity <- cor(dataAndPredictions_simplicity$m, dataAndPredictions_simplicity$prediction)
    if (r_simplicity > rmax_simplicity) {
        rmax_simplicity <- r_simplicity
        bestk_simplicity <- k_i
    }

    r_rationalsupport <- cor(dataAndPredictions_rationalsupport$m, dataAndPredictions_rationalsupport$prediction)
    if (r_rationalsupport > rmax_rationalsupport) {
        rmax_rationalsupport <- r_rationalsupport
        bestk_rationalsupport <- k_i
    }

    r_utility <- cor(dataAndPredictions_utility$m, dataAndPredictions_utility$prediction)
    if (r_utility > rmax_utility) {
        rmax_utility <- r_utility
        bestk_utility <- k_i
    }
}

print("Full model max r: ")
print(rmax_fullmodel)
print("Full model best-fitting k: ")
print(bestk_fullmodel)

print("Simplicity model max r: ")
print(rmax_simplicity)
print("Simplicity model best-fitting k: ")
print(bestk_simplicity)

print("Rational support model max r: ")
print(rmax_rationalsupport)
print("Rational support best-fitting k: ")
print(bestk_rationalsupport)

print("Non-probabilistic model max r: ")
print(rmax_utility)
print("Non-probabilistic best-fitting k: ")
print(bestk_utility)

# Extract the best-fitting predictions and normalize them so they sum to 1
bestpredictions_fullmodel <- predictions %>% select(-X1, -simplicity, -rationalsupport) %>%
                                             filter(k == bestk_fullmodel)
fullmodel_c1 <- bestpredictions_fullmodel %>% filter(condition == 1)
fullmodel_c1$fullmodel <- fullmodel_c1$fullmodel / sum(fullmodel_c1$fullmodel)
fullmodel_c2 <- bestpredictions_fullmodel %>% filter(condition == 2)
fullmodel_c2$fullmodel <- fullmodel_c2$fullmodel / sum(fullmodel_c2$fullmodel)
fullmodel_c3 <- bestpredictions_fullmodel %>% filter(condition == 3)
fullmodel_c3$fullmodel <- fullmodel_c3$fullmodel / sum(fullmodel_c3$fullmodel)

fullmodel_predictions <- bind_rows(fullmodel_c1, fullmodel_c2, fullmodel_c3)
fullmodel_tidy <- fullmodel_predictions %>% gather(model, prediction, c("fullmodel"))
fullmodel_tidy$condition <- as.character(fullmodel_tidy$condition)

dataAndPredictions_fullmodel <- left_join(meanRatings, fullmodel_tidy, 
        by=c("condition"="condition", "explanation"="explanation"))

        
bestpredictions_simplicity <- predictions %>% select(-X1, -fullmodel, -rationalsupport) %>%
                                             filter(k == bestk_simplicity)
simplicity_c1 <- bestpredictions_simplicity %>% filter(condition == 1)
simplicity_c1$simplicity <- simplicity_c1$simplicity / sum(simplicity_c1$simplicity)
simplicity_c2 <- bestpredictions_simplicity %>% filter(condition == 2)
simplicity_c2$simplicity <- simplicity_c2$simplicity / sum(simplicity_c2$simplicity)
simplicity_c3 <- bestpredictions_simplicity %>% filter(condition == 3)
simplicity_c3$simplicity <- simplicity_c3$simplicity / sum(simplicity_c3$simplicity)

simplicity_predictions <- bind_rows(simplicity_c1, simplicity_c2, simplicity_c3)
simplicity_tidy <- simplicity_predictions %>% gather(model, prediction, c("simplicity"))
simplicity_tidy$condition <- as.character(simplicity_tidy$condition)

dataAndPredictions_simplicity <- left_join(meanRatings, simplicity_tidy, 
        by=c("condition"="condition", "explanation"="explanation"))
        
        
bestpredictions_rationalsupport <- predictions %>% select(-X1, -simplicity, -fullmodel) %>%
                                             filter(k == bestk_rationalsupport)
rationalsupport_c1 <- bestpredictions_rationalsupport %>% filter(condition == 1)
rationalsupport_c1$rationalsupport <- rationalsupport_c1$rationalsupport / sum(rationalsupport_c1$rationalsupport)
rationalsupport_c2 <- bestpredictions_rationalsupport %>% filter(condition == 2)
rationalsupport_c2$rationalsupport <- rationalsupport_c2$rationalsupport / sum(rationalsupport_c2$rationalsupport)
rationalsupport_c3 <- bestpredictions_rationalsupport %>% filter(condition == 3)
rationalsupport_c3$rationalsupport <- rationalsupport_c3$rationalsupport / sum(rationalsupport_c3$rationalsupport)

rationalsupport_predictions <- bind_rows(rationalsupport_c1, rationalsupport_c2, rationalsupport_c3)
rationalsupport_tidy <- rationalsupport_predictions %>% gather(model, prediction, c("rationalsupport"))
rationalsupport_tidy$condition <- as.character(rationalsupport_tidy$condition)

dataAndPredictions_rationalsupport <- left_join(meanRatings, rationalsupport_tidy, 
        by=c("condition"="condition", "explanation"="explanation"))


bestpredictions_utility <- predictions_utility %>% select(-X1) %>%
                                            filter(k == bestk_utility)
utility_c1 <- bestpredictions_utility %>% filter(condition == 1)
utility_c2 <- bestpredictions_utility %>% filter(condition == 2)
utility_c3 <- bestpredictions_utility %>% filter(condition == 3)

utility_predictions_best <- bind_rows(utility_c1, utility_c2, utility_c3)
utility_tidy <- utility_predictions_best %>% gather(model, prediction, c("prediction"))
utility_tidy$condition <- as.character(utility_tidy$condition)

dataAndPredictions_utility <- left_join(meanRatings, utility_tidy, 
       by=c("condition"="condition", "explanation"="explanation"))

# Group all the (unnormalized) best predictions together and save
bestpredictions_utility$condition <- as.numeric(bestpredictions_utility$condition)
bestpredictions_utility <- bestpredictions_utility %>% rename(utility = prediction)
bestpredictions <- bestpredictions_fullmodel %>% 
                   left_join(bestpredictions_rationalsupport, by=c("condition","explanation")) %>%
                   left_join(bestpredictions_simplicity, by=c("condition","explanation")) %>% 
                   left_join(bestpredictions_utility, by=c("condition","explanation")) %>%
                   select(condition, explanation, fullmodel, rationalsupport, simplicity, utility)
write_csv(bestpredictions, 'bestfitting_modelpredictions.csv')


# Run additional model to test for effects of simplicity and rational support on ratings
rt <- ratingsTidy
rt$explanation <- as.factor(rt$explanation)
rt$condition <- as.factor(rt$condition)
bp <- bestpredictions
bp$explanation <- as.factor(bp$explanation)
bp$condition <- as.factor(bp$condition)
ratingsAndScores <- rt %>% left_join(bp, by=c("condition","explanation"))

m2 <- brm(formula = rating ~ rationalsupport * simplicity + (1|subject), data=ratingsAndScores, family=cumulative, iter=5000)
summary(m2)

h4 <- hypothesis(m2, "rationalsupport > 0")
print(h4)

h5 <- hypothesis(m2, "simplicity > 0")
print(h5)

# Create plots


# Data

# Condition 1
print(ggplot(data=cond1ratingsTidy, aes(x=fct_relevel(explanation,as.character(cond1meanRatings$explanation)), y=rating)) +
             geom_jitter(alpha=0.1, height=0.1, width=0, size=0.8) +
             stat_summary(fun.data="mean_95CI", alpha=0.9, fill="#1b9e77", color="#1b9e77", size=0.5, shape=22) +
             coord_flip() +
             theme_grey(base_size=9) +
             xlab(element_blank()) +
             ylab("Rating"))
             #labs(title = "Condition 1 explanation ratings"))
#ggsave("ratings_condition1.pdf", width=5, height=2, units="in")
             

# Condition 2
print(ggplot(data=cond2ratingsTidy, aes(x=fct_relevel(explanation,as.character(cond2meanRatings$explanation)), y=rating)) +
             geom_jitter(alpha=0.1, height=0.1, width=0, size=0.8) +
             stat_summary(fun.data="mean_95CI", alpha=0.9, fill="#1b9e77", color="#1b9e77", size=0.5, shape=22) +
             coord_flip() +
             theme_grey(base_size=9) +
             xlab(element_blank()) +
             ylab("Rating"))
             #labs(title = "Condition 2 explanation ratings"))
#ggsave("ratings_condition2.pdf", width=5, height=2, units="in")

# Condition 3
print(ggplot(data=cond3ratingsTidy, aes(x=fct_relevel(explanation,as.character(cond3meanRatings$explanation)), y=rating)) +
             geom_jitter(alpha=0.1, height=0.1, width=0, size=0.8) +
             stat_summary(fun.data="mean_95CI", alpha=0.9, fill="#1b9e77", color="#1b9e77", size=0.5, shape=22) +
             coord_flip() +
             theme_grey(base_size=9) +
             xlab(element_blank()) +
             ylab("Rating"))
             #labs(title = "Condition 3 explanation ratings"))
#ggsave("ratings_condition3.pdf", width=5, height=2, units="in")
             
         
         


# Data and predictions

print(ggplot(data=dataAndPredictions_fullmodel, 
             aes(x=prediction, y=m, color=condition, shape=condition, label=explanation)) +
             geom_point(size=0.9) +
             ylim(0,7) +
             #xlim(0,0.2) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             labs(color="Condition", title=sprintf("Decision net model, r = %.3f",rmax_fullmodel)) +
             theme_grey(base_size=9) +
             theme(axis.title.y = element_text(angle=90, vjust=0.5)) +
             scale_color_manual(name="Condition",
                                breaks=c("1","2","3"),
                                labels=c("1","2","3"),
                                values=c("#1b9e77", "#d95f02", "#7570b3")) +
             scale_shape_discrete(name="Condition",
                                  breaks=c("1","2","3"),
                                  labels=c("1","2","3")))
#ggsave("decisionnet_results.pdf", width=6, height=4, units="in")

print(ggplot(data=dataAndPredictions_fullmodel, 
             aes(x=prediction, y=m, color=condition, shape=condition, label=explanation)) +
             geom_point(size=0.9) +
             ylim(0,7) +
             #xlim(0,0.2) +
             geom_text_repel(size=2, segment.size=0.2, show.legend=FALSE) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             labs(color="Condition", title=sprintf("Decision net model, r = %.3f",rmax_fullmodel)) +
             theme_grey(base_size=9) +
             theme(axis.title.y = element_text(angle=90, vjust=0.5)) +
             scale_color_manual(name="Condition",
                                breaks=c("1","2","3"),
                                labels=c("1","2","3"),
                                values=c("#1b9e77", "#d95f02", "#7570b3")) +
             scale_shape_discrete(name="Condition",
                                  breaks=c("1","2","3"),
                                  labels=c("1","2","3")))
#ggsave("decisionnet_results_withlabels.pdf", width=6, height=4, units="in")

print(ggplot(data=dataAndPredictions_simplicity, 
             aes(x=prediction, y=m, color=condition, shape=condition, label=explanation)) +
             geom_point(size=0.8) +
             ylim(0,7) +
             #xlim(0,0.2) +
             xlab(element_blank()) +
             ylab(element_blank()) +
             labs(color="Condition", title=sprintf("Simplicity-only model, r = %.3f",rmax_simplicity)) +
             theme_grey(base_size=8) +
             #theme(axis.title.y = element_text(angle=90, vjust=0.5)) +
             #geom_text_repel() +
             scale_color_manual(name="Condition",
                                breaks=c("1","2","3"),
                                labels=c("1","2","3"),
                                values=c("#1b9e77", "#d95f02", "#7570b3")) +
             scale_shape_discrete(name="Condition",
                                  breaks=c("1","2","3"),
                                  labels=c("1","2","3")) +
             guides(color=FALSE, shape=FALSE))
#ggsave("simplicity_results.pdf", width=3, height=2.5, units="in")
             
print(ggplot(data=dataAndPredictions_rationalsupport, 
             aes(x=prediction, y=m, color=condition, label=explanation)) +
             geom_point(size=0.8) +
             ylim(0,7) +
             #xlim(0,0.2) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             labs(color="Condition", title=sprintf("Rational support-only model, r = %.3f",rmax_rationalsupport)) +
             theme(axis.title.y = element_text(angle=90, vjust=0.5)) +
             #geom_text_repel() +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
#ggsave("rationalsupport_results.pdf", width=4, height=3, units="in")

print(ggplot(data=dataAndPredictions_rationalsupport, 
             aes(x=prediction, y=m, color=condition, shape=condition, label=explanation)) +
             geom_point(size=0.8) +
             ylim(0,7) +
             #xlim(0,0.2) +
             xlab(element_blank()) +
             ylab(element_blank()) +
             labs(title=sprintf("Rational support-only model, r = %.3f",rmax_rationalsupport)) +
             theme_grey(base_size=8) +
             geom_text_repel(data=subset(dataAndPredictions_rationalsupport, condition=="1"),
                             size=2, segment.size=0.2, show.legend=FALSE) +
             scale_color_manual(name="Condition",
                                breaks=c("1","2","3"),
                                labels=c("1","2","3"),
                                values=c("#1b9e77", "#d95f02", "#7570b3")) +
             scale_shape_discrete(name="Condition",
                                  breaks=c("1","2","3"),
                                  labels=c("1","2","3")) +
             guides(shape=FALSE, color=FALSE))
#ggsave("rationalsupport_results_withlabels.pdf", width=3, height=2.5, units="in")

print(ggplot(data=dataAndPredictions_utility, 
            aes(x=prediction, y=m, color=condition, shape=condition, label=explanation)) +
            geom_point(size=0.9) +
            ylim(0,7) +
            #xlim(0,0.2) +
            geom_text_repel(size=2, segment.size=0.2, show.legend=FALSE) +
            xlab("Model prediction") +
            ylab("Mean human ratings") +
            labs(color="Condition", title=sprintf("Non-probabilistic model, r = %.3f",rmax_utility)) +
            theme_grey(base_size=9) +
            scale_color_manual(name="Condition",
                               breaks=c("1","2","3"),
                               labels=c("1","2","3"),
                               values=c("#1b9e77", "#d95f02", "#7570b3")) +
            scale_shape_discrete(name="Condition",
                                 breaks=c("1","2","3"),
                                 labels=c("1","2","3")))
#ggsave("nonprob_results_withlabels.pdf", width=6, height=4, units="in")


