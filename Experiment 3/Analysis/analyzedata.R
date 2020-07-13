# Analyze data

library(tidyverse)
library(brms)

# Clear workspace
rm(list=ls())


findBestFreeParam <- function(d, p) {
# Finds the best free parameter. The best free parameter is the one that
# produces the greatest correlation between model predictions and data
#
# Arguments:
#   d: Data frame with mean data
#   p: Data frame with model predictions
#
# Returns a list containing the best-fitting parameter and the corresponding
# correlation coefficient
  
	freeParams <- seq(0.05, 3.0, 0.05)
	best.f <- 0.05
	best.r <- 0

	for (f in freeParams) {
		# Get model predictions
		preds <- p %>% filter(FreeParam == f)

		# Compute correlation between model prediction with this parameter value and data
		r <- cor(d$Mean.Rating, preds$Probability)
		if (r > best.r) {
			best.f <- f
			best.r <- r
		}
	}
	
	return(list(best.f,best.r))
}

# Read in the data files
likesClownsData <- read.csv("../Data/likesClowns_data_tidy.csv")
dislikesClownsData <- read.csv("../Data/dislikesClowns_data_tidy.csv")

# Remove X and Reasoning columns (unrelated to data analysis)
likesClownsData <- likesClownsData %>% select(-X, -Reasoning)
dislikesClownsData <- dislikesClownsData %>% select(-X, -Reasoning)

# Number of total subjects (including subjects who failed attention check)
N_likesClowns <- likesClownsData %>% 
                 select(Subject) %>%
                 rapply(function(x) length(unique(x)))
cat(sprintf("Total N (likes clowns): %d", N_likesClowns),"\n")
N_dislikesClowns <- dislikesClownsData %>% 
                 select(Subject) %>%
                 rapply(function(x) length(unique(x)))
cat(sprintf("Total N (dislikes clowns): %d", N_dislikesClowns),"\n")

# Eliminate subjects who failed the attention check

# Creates a unique list of indices of subjects who failed
excludedSubjects_likesClowns <- likesClownsData %>% 
                                filter(Condition == 4) %>%
                                gather(Exp, Rating, Explanation.00:Explanation.12) %>%
						        filter(Rating != -1) %>%
								select(Subject) %>% 
								rapply(function(x) unique(x))
excludedSubjects_dislikesClowns <- dislikesClownsData %>% 
                                   filter(Condition == 4) %>%
                                   gather(Exp, Rating, Explanation.00:Explanation.12) %>%
								   filter(Rating != -1) %>%
								   select(Subject) %>% 
								   rapply(function(x) unique(x))

# Exclude subjects
likesClownsData <- likesClownsData %>% filter(!(Subject %in% excludedSubjects_likesClowns))
dislikesClownsData <- dislikesClownsData %>% filter(!(Subject %in% excludedSubjects_dislikesClowns))

# Now compute number of remaining (non-excluded) subjects
N_likesClowns <- likesClownsData %>% 
                 select(Subject) %>%
                 rapply(function(x) length(unique(x)))
cat(sprintf("Final N after exclusions (likes clowns): %d", N_likesClowns),"\n")
N_dislikesClowns <- dislikesClownsData %>% 
                 select(Subject) %>%
                 rapply(function(x) length(unique(x)))
cat(sprintf("Final N after exclusions (dislikes clowns): %d", N_dislikesClowns),"\n")


# Read in the predictions
likesClownsPredictions <- read.csv("../Model/predictions/likesClowns_predictions_tidy.csv")
likesClownsPredictions_rationalsupport <- read.csv("../Model/predictions/likesClowns_rationalsupportonly_predictions_tidy.csv")
likesClownsPredictions_simplicity <- read.csv("../Model/predictions/likesClowns_simplicityonly_predictions_tidy.csv")
likesClownsPredictions_nonprob <- read.csv("../Model/predictions/likesClowns_nonprob_predictions_tidy.csv")
dislikesClownsPredictions <- read.csv("../Model/predictions/dislikesClowns_predictions_tidy.csv")
dislikesClownsPredictions_rationalsupport <- read.csv("../Model/predictions/dislikesClowns_rationalsupportonly_predictions_tidy.csv")
dislikesClownsPredictions_simplicity <- read.csv("../Model/predictions/dislikesClowns_simplicityonly_predictions_tidy.csv")
dislikesClownsPredictions_nonprob <- read.csv("../Model/predictions/dislikesClowns_nonprob_predictions_tidy.csv")

# Rearrange the data
likesClowns_means <- likesClownsData %>% filter(Condition != 4) %>%
										 group_by(Condition) %>%
										 summarise(
										  Explanation.00 = mean(Explanation.00),
										  Explanation.01 = mean(Explanation.01),
										  Explanation.02 = mean(Explanation.02),
										  Explanation.03 = mean(Explanation.03),
										  Explanation.04 = mean(Explanation.04),
										  Explanation.05 = mean(Explanation.05),
										  Explanation.06 = mean(Explanation.06),
										  Explanation.07 = mean(Explanation.07),
										  Explanation.08 = mean(Explanation.08),
										  Explanation.09 = mean(Explanation.09),
										  Explanation.10 = mean(Explanation.10),
										  Explanation.11 = mean(Explanation.11),
										  Explanation.12 = mean(Explanation.12)
										 ) %>%
										 gather(Explanation, Mean.Rating, Explanation.00:Explanation.12) %>%
										 arrange(Condition, Explanation)

dislikesClowns_means <- dislikesClownsData %>% filter(Condition != 4) %>%
										 group_by(Condition) %>%
										 summarise(
										  Explanation.00 = mean(Explanation.00),
										  Explanation.01 = mean(Explanation.01),
										  Explanation.02 = mean(Explanation.02),
										  Explanation.03 = mean(Explanation.03),
										  Explanation.04 = mean(Explanation.04),
										  Explanation.05 = mean(Explanation.05),
										  Explanation.06 = mean(Explanation.06),
										  Explanation.07 = mean(Explanation.07),
										  Explanation.08 = mean(Explanation.08),
										  Explanation.09 = mean(Explanation.09),
										  Explanation.10 = mean(Explanation.10),
										  Explanation.11 = mean(Explanation.11),
										  Explanation.12 = mean(Explanation.12)
										 ) %>%
										 gather(Explanation, Mean.Rating, Explanation.00:Explanation.12) %>%
										 arrange(Condition, Explanation)



# Get the best-fitting parameters for each model
best_likesClowns <- findBestFreeParam(likesClowns_means, likesClownsPredictions)
best_likesClowns_rationalsupport <- findBestFreeParam(likesClowns_means, likesClownsPredictions_rationalsupport)
best_likesClowns_simplicity <- findBestFreeParam(likesClowns_means, likesClownsPredictions_simplicity)
best_likesClowns_nonprob <- findBestFreeParam(likesClowns_means, likesClownsPredictions_nonprob)
best_dislikesClowns <- findBestFreeParam(dislikesClowns_means, dislikesClownsPredictions)
best_dislikesClowns_rationalsupport <- findBestFreeParam(dislikesClowns_means, dislikesClownsPredictions_rationalsupport)
best_dislikesClowns_simplicity <- findBestFreeParam(dislikesClowns_means, dislikesClownsPredictions_simplicity)
best_dislikesClowns_nonprob <- findBestFreeParam(dislikesClowns_means, dislikesClownsPredictions_nonprob)

bestFittingModel_likesClowns <- likesClownsPredictions %>% filter(FreeParam == best_likesClowns[1])
bestFittingModel_likesClowns_rationalsupport <- likesClownsPredictions_rationalsupport %>% filter(FreeParam == best_likesClowns_rationalsupport[1])
bestFittingModel_likesClowns_simplicity <- likesClownsPredictions_simplicity %>% filter(FreeParam == best_likesClowns_simplicity[1])
bestFittingModel_likesClowns_nonprob <- likesClownsPredictions_nonprob %>% filter(FreeParam == best_likesClowns_nonprob[1])
bestFittingModel_dislikesClowns <- dislikesClownsPredictions %>% filter(FreeParam == best_dislikesClowns[1])
bestFittingModel_dislikesClowns_rationalsupport <- dislikesClownsPredictions_rationalsupport %>% filter(FreeParam == best_dislikesClowns_rationalsupport[1])
bestFittingModel_dislikesClowns_simplicity <- dislikesClownsPredictions_simplicity %>% filter(FreeParam == best_dislikesClowns_simplicity[1])
bestFittingModel_dislikesClowns_nonprob <- dislikesClownsPredictions_nonprob %>% filter(FreeParam == best_dislikesClowns_nonprob[1])

likesClowns_means <- likesClowns_means %>% 
                     mutate(fullmodel = bestFittingModel_likesClowns$Probability,
					        rationalsupport = bestFittingModel_likesClowns_rationalsupport$Probability,
							simplicity = bestFittingModel_likesClowns_simplicity$Probability,
							nonprob = bestFittingModel_likesClowns_nonprob$Probability) 
dislikesClowns_means <- dislikesClowns_means %>% 
                        mutate(fullmodel = bestFittingModel_dislikesClowns$Probability,
						       rationalsupport = bestFittingModel_dislikesClowns_rationalsupport$Probability,
							   simplicity = bestFittingModel_dislikesClowns_simplicity$Probability,
							   nonprob = bestFittingModel_dislikesClowns_nonprob$Probability)
likesClowns_means$Condition <- as.character(likesClowns_means$Condition)
dislikesClowns_means$Condition <- as.character(dislikesClowns_means$Condition)

# Print results
cat("====== Full model ======\n")
cat(sprintf("Best-fitting parameter (likes clowns): %f (r = %f)", best_likesClowns[1], best_likesClowns[2]),"\n")
cat(sprintf("Best-fitting parameter (dislikes clowns): %f (r = %f)", best_dislikesClowns[1], best_dislikesClowns[2]),"\n")

cat("====== Rational support-only model ======\n")
cat(sprintf("Best-fitting parameter (likes clowns): %f (r = %f)", best_likesClowns_rationalsupport[1], best_likesClowns_rationalsupport[2]),"\n")
cat(sprintf("Best-fitting parameter (dislikes clowns): %f (r = %f)", best_dislikesClowns_rationalsupport[1], best_dislikesClowns_rationalsupport[2]),"\n")

cat("====== Simplicity-only model ======\n")
cat(sprintf("Best-fitting parameter (likes clowns): %f (r = %f)", best_likesClowns_simplicity[1], best_likesClowns_simplicity[2]),"\n")
cat(sprintf("Best-fitting parameter (dislikes clowns): %f (r = %f)", best_dislikesClowns_simplicity[1], best_dislikesClowns_simplicity[2]),"\n")

cat("====== Non-probabilistic model ======\n")
cat(sprintf("Best-fitting parameter (likes clowns): %f (r = %f)", best_likesClowns_nonprob[1], best_likesClowns_nonprob[2]),"\n")
cat(sprintf("Best-fitting parameter (dislikes clowns): %f (r = %f)", best_dislikesClowns_nonprob[1], best_dislikesClowns_nonprob[2]),"\n")



# Make the plots

print(ggplot(data=likesClowns_means, 
             aes(x=fullmodel, y=Mean.Rating, color=Condition, shape=Condition)) +
             geom_point() +
             ylim(0,7) +
             xlim(0,0.35) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             theme(axis.title.y = element_text(angle=90, vjust=0.5), legend.position="right",
                   text=element_text(size=9)) +
			 ggtitle("Decision net model") +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
ggsave("decisionnetmodel_likesclowns.pdf", width=2.8, height=1.8, units="in")

print(ggplot(data=dislikesClowns_means, 
             aes(x=fullmodel, y=Mean.Rating, color=Condition, shape=Condition)) +
             geom_point() +
             ylim(0,7) +
             xlim(0,0.35) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             theme(axis.title.y = element_text(angle=90, vjust=0.5), legend.position="right",
                   text=element_text(size=9)) +
			 ggtitle("Decision net model") +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
ggsave("decisionnetmodel_dislikesclowns.pdf", width=2.8, height=1.8, units="in")

print(ggplot(data=likesClowns_means, 
             aes(x=rationalsupport, y=Mean.Rating, color=Condition, shape=Condition)) +
             geom_point() +
             ylim(0,7) +
             xlim(0,0.35) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             theme(axis.title.y = element_text(angle=90, vjust=0.5), legend.position="right",
                   text=element_text(size=9)) +
			 ggtitle("Rational support-only model") +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
ggsave("rationalsupportmodel_likesclowns.pdf", width=2.8, height=1.8, units="in")

print(ggplot(data=dislikesClowns_means, 
             aes(x=rationalsupport, y=Mean.Rating, color=Condition, shape=Condition)) +
             geom_point() +
             ylim(0,7) +
             xlim(0,0.35) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             theme(axis.title.y = element_text(angle=90, vjust=0.5), legend.position="right",
                   text=element_text(size=9)) +
			 ggtitle("Rational support-only model") +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
ggsave("rationalsupportmodel_dislikesclowns.pdf", width=2.8, height=1.8, units="in")

print(ggplot(data=likesClowns_means, 
             aes(x=simplicity, y=Mean.Rating, color=Condition, shape=Condition)) +
             geom_point() +
             ylim(0,7) +
             xlim(0,0.35) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             theme(axis.title.y = element_text(angle=90, vjust=0.5), legend.position="right",
                   text=element_text(size=9)) +
			 ggtitle("Simplicity-only model") +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
ggsave("simplicitymodel_likesclowns.pdf", width=2.8, height=1.8, units="in")

print(ggplot(data=dislikesClowns_means, 
             aes(x=simplicity, y=Mean.Rating, color=Condition, shape=Condition)) +
             geom_point() +
             ylim(0,7) +
             xlim(0,0.35) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             theme(axis.title.y = element_text(angle=90, vjust=0.5), legend.position="right",
                   text=element_text(size=9)) +
			 ggtitle("Simplicity-only model") +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
ggsave("simplicitymodel_dislikesclowns.pdf", width=2.8, height=1.8, units="in")

print(ggplot(data=likesClowns_means, 
             aes(x=nonprob, y=Mean.Rating, color=Condition, shape=Condition)) +
             geom_point() +
             ylim(0,7) +
             xlim(0,0.008) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             theme(axis.title.y = element_text(angle=90, vjust=0.5), legend.position="right",
                   text=element_text(size=9)) +
			 ggtitle("Non-probabilistic model") +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
ggsave("nonprobmodel_likesclowns.pdf", width=2.8, height=1.8, units="in")

print(ggplot(data=dislikesClowns_means, 
             aes(x=nonprob, y=Mean.Rating, color=Condition, shape=Condition)) +
             geom_point() +
             ylim(0,7) +
             xlim(0,0.008) +
             xlab("Model prediction") +
             ylab("Mean human ratings") +
             theme(axis.title.y = element_text(angle=90, vjust=0.5), legend.position="bottom",
                   text=element_text(size=9)) +
			 ggtitle("Non-probabilistic model") +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
ggsave("nonprobmodel_dislikesclowns.pdf", width=2.8, height=1.8, units="in")


# Combine the data into a single data frame

# First increment subject numbers of dislikes clowns data by max subject number from likes condition
likesClownsMaxSubject <- max(likesClownsData$Subject)
dislikesClownsData$Subject <- dislikesClownsData$Subject + likesClownsMaxSubject

# Add a new column to each data fram indicating the condition
likesClownsData <- likesClownsData %>% mutate(clownsPref = "likes")
dislikesClownsData <- dislikesClownsData %>% mutate(clownsPref = "dislikes")

# Merge the two data frames
clownDataFull <- likesClownsData %>% full_join(dislikesClownsData)

# Turn into tidy format and ignore Condition 4
clownDataTidy <- clownDataFull %>% gather(Explanation, Rating, 3:15) %>% 
                                   filter(Condition != 4)


# Convert to data frame
clownDataDF <- as.data.frame(clownDataTidy)
clownDataDF$Condition <- as.factor(clownDataDF$Condition)
clownDataDF$Explanation <- as.factor(clownDataDF$Explanation)
clownDataDF$clownsPref <- as.factor(clownDataDF$clownsPref)

# Run the pre-registered ANOVA analysis
print(summary(aov(Rating ~ Condition * Explanation + Error(Subject/Explanation), data=clownDataDF)))


# Run the Bayesian logistic regression model

m <- brm(formula = Rating ~ clownsPref * Condition * Explanation + (1|Subject), data=clownDataDF, family=cumulative, iter=5000)
summary(m)

# Test for a main effect of clown preference
# I do this by running the model without including clown preference as an effect
m_reduced <- brm(formula = Rating ~ Condition * Explanation + (1|Subject), data=clownDataDF, family=cumulative, iter=5000)
# We can then compare the two model fits using leave-one-out (LOO) IC
# This should show that model m (which includes clown preference) has a better model fit (lower LOOIC)
# than model m2
loo(m,m_reduced)

# Test for interaction

# Re-level with condition 2 as reference level and run model again in order to 
# do some of the tests
clownDataDF$Condition <- relevel(clownDataDF$Condition, 2)
m2 <- brm(formula = Rating ~ clownsPref * Condition * Explanation + (1|Subject), data=clownDataDF, family=cumulative, iter=5000)
summary(m2)

# Re-level with likes as reference level and run model again in order to do some of
# the tests
clownDataDF$clownsPref <- relevel(clownDataDF$clownsPref, "likes")
m3 <- brm(formula = Rating ~ clownsPref * Condition * Explanation + (1|Subject), data=clownDataDF, family=cumulative, iter=5000)
summary(m3)

# We will also run a few specific tests for interactions

# Tests 1-2. Test for effect of liking/disliking

# Check whether there was a significant effect on ratings in Condition 1
# for Explanation 1 (believed clown at stage A) when the person liked clowns relative to
# when the person disliked clowns
h1 <- hypothesis(m2, "clownsPreflikes:Condition1:ExplanationExplanation.01 > 0")
print(h1)

# Check whether there was a significant effect on ratings in Condition 3
# for Explanation 5 (believed clown at stage B) when the person liked clowns relative to
# when the person disliked clowns
h2 <- hypothesis(m, "clownsPreflikes:Condition3:ExplanationExplanation.03 > 0")
print(h2)

# Tests 3-8. Test for effects of simplicity

# Check if, in Condition 1, "Clown at A" has a bigger coefficient (better explanation) than
# "Clown at A, Magician at B, and Acrobat at C." when person likes clowns
h3 <- hypothesis(m2, "clownsPreflikes:Condition1:ExplanationExplanation.01 > clownsPreflikes:Condition1:ExplanationExplanation.07")
print(h3)

# Check if, in Condition 1, "Clown at A" has a bigger coefficient (better explanation) than
# "Clown at A, Acrobat at B, and Magician at C." when person likes clowns
h4 <- hypothesis(m2, "clownsPreflikes:Condition1:ExplanationExplanation.01 > clownsPreflikes:Condition1:ExplanationExplanation.08")
print(h4)

# Check if, in Condition 1, "Clown at C" has a bigger coefficient (better explanation) than
# "Magician at A, Acrobat at B, and Clown at C." when person disliked clowns
h5 <- hypothesis(m3, "clownsPrefdislikes:Condition1:ExplanationExplanation.05 > clownsPrefdislikes:Condition1:ExplanationExplanation.11")
print(h5)

# Check if, in Condition 1, "Clown at C" has a bigger coefficient (better explanation) than
# "Acrobat at A, Magician at B, and Clown at C." when person disliked clowns
h6 <- hypothesis(m3, "clownsPrefdislikes:Condition1:ExplanationExplanation.05 > clownsPrefdislikes:Condition1:ExplanationExplanation.12")
print(h6)

# Check if, in Condition 3, "Clown at B" has a bigger coefficient (better explanation) than
# "Magician at A, Clown at B, and Acrobat at C".
h7 <- hypothesis(m, "clownsPreflikes:Condition3:ExplanationExplanation.03 > clownsPreflikes:Condition3:ExplanationExplanation.09")
print(h7)

# Check if, in Condition 3, "Clown at B" has a bigger coefficient (better explanation) than
# "Acrobat at A, Clown at B, and Magician at C".
h8 <- hypothesis(m, "clownsPreflikes:Condition3:ExplanationExplanation.03 > clownsPreflikes:Condition3:ExplanationExplanation.10")
print(h8)


# Combine the data frames with predictions into a single data frame
allPredictions <- likesClowns_means %>% mutate(clownsPref = "likes") %>%
                  bind_rows(dislikesClowns_means %>% mutate(clownsPref = "dislikes"))
allPredictions$Condition <- as.factor(allPredictions$Condition)
clownDataTidy$Condition <- as.factor(clownDataTidy$Condition)
# Combine again with data
ratingsAndScores <- clownDataTidy %>% left_join(allPredictions, by=c("Condition", "Explanation", "clownsPref")) 

# Run model to test for effects of rational support and simplicity
m4 <- brm(formula = Rating ~ rationalsupport * simplicity + (1|Subject), data=ratingsAndScores, family=cumulative, iter=5000)
summary(m4)

h9 <- hypothesis(m4, "rationalsupport > 0")
print(h9)
h10 <- hypothesis(m4, "simplicity > 0")
print(h10)

