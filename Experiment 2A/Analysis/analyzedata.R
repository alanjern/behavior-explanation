# Analyze data

library(tidyverse)

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
										  Mean.Exp00 = mean(Explanation.00),
										  Mean.Exp01 = mean(Explanation.01),
										  Mean.Exp02 = mean(Explanation.02),
										  Mean.Exp03 = mean(Explanation.03),
										  Mean.Exp04 = mean(Explanation.04),
										  Mean.Exp05 = mean(Explanation.05),
										  Mean.Exp06 = mean(Explanation.06),
										  Mean.Exp07 = mean(Explanation.07),
										  Mean.Exp08 = mean(Explanation.08),
										  Mean.Exp09 = mean(Explanation.09),
										  Mean.Exp10 = mean(Explanation.10),
										  Mean.Exp11 = mean(Explanation.11),
										  Mean.Exp12 = mean(Explanation.12)
										 ) %>%
										 gather(Explanation, Mean.Rating, Mean.Exp00:Mean.Exp12) %>%
										 arrange(Condition, Explanation)

dislikesClowns_means <- dislikesClownsData %>% filter(Condition != 4) %>%
										 group_by(Condition) %>%
										 summarise(
										  Mean.Exp00 = mean(Explanation.00),
										  Mean.Exp01 = mean(Explanation.01),
										  Mean.Exp02 = mean(Explanation.02),
										  Mean.Exp03 = mean(Explanation.03),
										  Mean.Exp04 = mean(Explanation.04),
										  Mean.Exp05 = mean(Explanation.05),
										  Mean.Exp06 = mean(Explanation.06),
										  Mean.Exp07 = mean(Explanation.07),
										  Mean.Exp08 = mean(Explanation.08),
										  Mean.Exp09 = mean(Explanation.09),
										  Mean.Exp10 = mean(Explanation.10),
										  Mean.Exp11 = mean(Explanation.11),
										  Mean.Exp12 = mean(Explanation.12)
										 ) %>%
										 gather(Explanation, Mean.Rating, Mean.Exp00:Mean.Exp12) %>%
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




