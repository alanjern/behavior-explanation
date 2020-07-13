# Analyze data


#  story: food allergy 
# 
#      case: did not eat the appetizer
#          explanations
#              0: knew that the goat cheese contained benzatrate
#              1: knew that the bell pepper contained benzatrate
#              2: knew that the bacon contained benzatrate
#              3: knew that the goat cheese contained benzatrate and that the bell pepper contained benzatrate
#              4: knew that the goat cheese contained benzatrate and that the bacon contained benzatrate
#              5: knew that the bell pepper contained benzatrate and that the bacon contained benzatrate
#              6: knew that the goat cheese contained benzatrate, and that the bell pepper contained benzatrate, and that the bacon contained benzatrate
#              7: didn't know that the goat cheese contained benzatrate, or that the bell pepper contained benzatrate, or that the bacon contained benzatrate
#
#      case: ate the appetizer
#          explanations
#              0: didn't know that the goat cheese contained benzatrate
#              1: didn't know that the bell pepper contained benzatrate
#              2: didn't know that the bacon contained benzatrate
#              3: didn't know that the goat cheese contained benzatrate or that the bell pepper contained benzatrate
#              4: didn't know that the goat cheese contained benzatrate or that the bacon contained benzatrate
#              5: didn't know that the bell pepper contained benzatrate or that the bacon contained benzatrate
#              6: didn't know that the goat cheese contained benzatrate, or that the bell pepper contained benzatrate, or that the bacon contained benzatrate
#              7: knew that the goat cheese contained benzatrate, and that the bell pepper contained benzatrate, and that the bacon contained benzatrate
#
#  story: robbery 
# 
#      case: arrested the culprit
#          explanations
#              0: knew that he had robbed the liquor store
#              1: knew that he had robbed the drug store
#              2: knew that he had robbed the grocery store
#              3: knew that he had robbed the liquor store and the drug store
#              4: knew that he had robbed the liquor store and the grocery store
#              5: knew that he had robbed the drug store and the grocery store
#              6: knew that he had robbed the liquor store, the drug store, and the grocery store
#              7: didn't know that he had robbed the liquor store, or the drug store, or the grocery store
#
#      case: did not arrest the culprit
#          explanations
#              0: didn't know that he had robbed the liquor store
#              1: didn't know that he had robbed the drug store
#              2: didn't know that he had robbed the grocery store
#              3: didn't know that he had robbed the liquor store or the drug store
#              4: didn't know that he had robbed the liquor store or the grocery store
#              5: didn't know that he had robbed the drug store or the grocery store
#              6: didn't know that he had robbed the liquor store, or the drug store, or the grocery store
#              7: knew that he had robbed the liquor store, and the drug store, and the grocery store
#
#  story: locks 
# 
#      case: got the keys before opening
#          explanations
#              0: knew that Lock A was locked
#              1: knew that Lock B was locked
#              2: knew that Lock C was locked
#              3: knew that Lock A was locked and that Lock B was locked
#              4: knew that Lock A was locked and that Lock C was locked
#              5: knew that Lock B was locked and that Lock C was locked
#              6: knew that Lock A was locked, and that Lock B was locked, and that Lock C was locked
#              7: didn't know that Lock A was locked, or that Lock B was locked, or that Lock C was locked
#
#      case: didn't get the keys before opening
#          explanations
#              0: didn't know that Lock A was locked
#              1: didn't know that Lock B was locked
#              2: didn't know that Lock C was locked
#              3: didn't know that Lock A was locked, or that Lock B was locked
#              4: didn't know that Lock A was locked, or that Lock C was locked
#              5: didn't know that Lock B was locked, or that Lock C was locked
#              6: didn't know that Lock A was locked, or that Lock B was locked, or that Lock C was locked
#              7: knew that Lock A was locked, and that Lock B was locked, and that Lock C was locked
#

library(tidyverse)
library(brms)

# Clear workspace
rm(list=ls())

# Read in data
rawdata <- read.csv("../Data/data_all.csv")

# Number of subjects before excluding subjects who failed attention check
N_total <- rawdata %>% 
           select(Subject) %>%
           rapply(function(x) length(unique(x)))
cat(sprintf("Total N: %d", N_total),"\n")

# Filter out subjects who failed the attention check
# Recall that the attention check in this experiment was explanation 7; if a subject
# gave a rating of > 4 (indicating that they thought it was a good explanation) for any
# story, all of their ratings were discarded
filteredSubjects <- rawdata %>%
                    filter(Explanation.7 > 4) %>%
					select(Subject)
#processedData <- rawdata %>% anti_join(filteredSubjects, by="Subject") %>%
#                             select(-Reasoning)
processedData <- rawdata %>% select(-Reasoning) 
 
 
# Number of subjects after excluding subjects who failed attention check
N_final <- processedData %>%
           select(Subject) %>%
		   rapply(function(x) length(unique(x)))
cat(sprintf("Final N: %d", N_final),"\n")

# Reformat the data
processedData_long <- gather(processedData, key = expl,
                             value = rating, Explanation.0, Explanation.1,
							 Explanation.2, Explanation.3, Explanation.4,
							 Explanation.5, Explanation.6, Explanation.7)
pd <- processedData_long %>% filter(expl != "Explanation.7")


# Create a data frame that groups the explanations into three categories: Explanations 0-2,
# Explanations 3-5, and Explanation 6
#
# The reasoning here is that these are explanations with the same number of factors in them

# First create separate data frames for the ratings for each explanation
# and apppend a new column that indicates the numbers of factors in that explantion
ex0 <- filter(pd, expl=="Explanation.0") %>% select(-expl) %>% mutate(explFactors = "one")
ex1 <- filter(pd, expl=="Explanation.1") %>% select(-expl) %>% mutate(explFactors = "one")
ex2 <- filter(pd, expl=="Explanation.2") %>% select(-expl) %>% mutate(explFactors = "one")
ex3 <- filter(pd, expl=="Explanation.3") %>% select(-expl) %>% mutate(explFactors = "two")
ex4 <- filter(pd, expl=="Explanation.4") %>% select(-expl) %>% mutate(explFactors = "two")
ex5 <- filter(pd, expl=="Explanation.5") %>% select(-expl) %>% mutate(explFactors = "two")
ex6 <- filter(pd, expl=="Explanation.6") %>% select(-expl) %>% mutate(explFactors = "three")

# Now glue them all back together
grpdData <- ex0 %>% bind_rows(ex1) %>% bind_rows(ex2) %>% bind_rows(ex3) %>% 
              bind_rows(ex4) %>% bind_rows(ex5) %>% bind_rows(ex6)
grpdData$explFactors <- as.factor(grpdData$explFactors)
grpdData$explFactors <- relevel(grpdData$explFactors, "three")

# Separate based on know and didn't know
grpdDataKnow <- grpdData %>% filter(Case == "didn't eat" | Case == "arrested" | Case == "got keys")
grpdDataDidntKnow <- grpdData %>% filter(Case == "ate" | Case == "didn't arrest" | Case == "didn't get keys")

# Run the Bayesian models to test if there is an effect of number of explanation factors           
#m_know <- brm(rating ~ explFactors + (1|Subject), family="cumulative", data=grpdDataKnow, iter=5000)
#m_didntKnow <- brm(rating ~ explFactors + (1|Subject), family="cumulative", data=grpdDataDidntKnow, iter=5000)

# Run the post-hoc tests

cat(sprintf("\n=========================\n"))
cat(sprintf("Know condition comparison tests\n"))
#h1 <- hypothesis(m_know, "explFactorstwo > 0")
cat(sprintf("\n=========================\n"))
cat(sprintf("Test that two-factor explanations is > three-factor\n"))
#print(h1)
#h2 <- hypothesis(m_know, "explFactorsone > explFactorstwo")
cat(sprintf("\n=========================\n"))
cat(sprintf("Test that one-factor explanations is > two-factor\n"))
#print(h2)

cat(sprintf("\n=========================\n"))
cat(sprintf("Didn't know condition comparison tests\n"))
#h1 <- hypothesis(m_didntKnow, "explFactorstwo > 0")
cat(sprintf("\n=========================\n"))
cat(sprintf("Test that two-factor explanations is > three-factor\n"))
#print(h1)
#h2 <- hypothesis(m_didntKnow, "explFactorsone > explFactorstwo")
cat(sprintf("\n=========================\n"))
cat(sprintf("Test that one-factor explanations is > two-factor\n"))
#print(h2)



# Test if ratings varied by case
# I tried running the model on all the data at once but the model wouldn't converge, so I'm
# splitting the data set into chunks (by story) and running three separate models
gd_food <- grpdData %>% filter(Story == "food allergy")
#m_food <- brm(rating ~ Case + (1|Subject), family="cumulative", data=gd_food, iter=10000, control = list(adapt_delta=0.9))
#h_food <- hypothesis(m_food, "Casedidnteat > 0", alpha = 0.05)

cat(sprintf("\n=========================\n"))
cat(sprintf("Test that didn't eat is diff from did eat\n"))
#print(h_food)

gd_robbery <- grpdData %>% filter(Story == "robbery")
#m_robbery <- brm(rating ~ Case + (1|Subject), family="cumulative", data=gd_robbery, iter=10000, control = list(adapt_delta=0.9))
#h_robbery <- hypothesis(m_robbery, "Casedidntarrest > 0", alpha = 0.05)

cat(sprintf("\n=========================\n"))
cat(sprintf("Test that didn't arrest is diff from did arrest\n"))
#print(h_robbery)

gd_locks <- grpdData %>% filter(Story == "locks")
#m_locks <- brm(rating ~ Case + (1|Subject), family="cumulative", data=gd_locks, iter=15000, control = list(adapt_delta=0.9))
#h_locks <- hypothesis(m_locks, "Casegotkeys > 0", alhpa = 0.05)

cat(sprintf("\n=========================\n"))
cat(sprintf("Test that got keys is diff from didn't get keys\n"))
#print(h_locks)


# Compute the ANOVA
# -------------------
# The prediction is an interaction between the Case and expl variables. Specifically,
# we predict that subjects will treat the two cases of each story differently.

print((summary(aov(rating ~ Case * Story * expl + Error(Subject/(Story*expl)), data=pd))))

# Compute separate ANOVA tests for individual conditions
# --------------------
# The prediction is that within each condition, subjects will give different ratings 
# for the different explanations

# Food allergy
cat(sprintf("\n=========================\n"))
cat(sprintf("Food allergy (didn't eat) ANOVA:\n"))
dfood2 <- processedData_long %>% 
            filter(Story == "food allergy", Case=="didn't eat", expl != "Explanation.7")
print(summary(aov(rating ~ expl + Error(Subject/expl), data=dfood2)))



cat(sprintf("\n=========================\n"))
cat(sprintf("Food allergy (ate) ANOVA:\n"))
dfood1 <- processedData_long %>% 
            filter(Story == "food allergy", Case=="ate", expl != "Explanation.7")
print(summary(aov(rating ~ expl + Error(Subject/expl), data=dfood1)))


# Robbery
cat(sprintf("\n=========================\n"))
cat(sprintf("Robbery (arrested) ANOVA:\n"))
drobbery1 <- processedData_long %>% 
            filter(Story == "robbery", Case=="arrested", expl != "Explanation.7")
print(summary(aov(rating ~ expl + Error(Subject/expl), data=drobbery1)))


cat(sprintf("\n=========================\n"))
cat(sprintf("Robbery (didn't arrest) ANOVA:\n"))
drobbery2 <- processedData_long %>% 
            filter(Story == "robbery", Case=="didn't arrest", expl != "Explanation.7")
print(summary(aov(rating ~ expl + Error(Subject/expl), data=drobbery2)))

# Locks and keys
cat(sprintf("\n=========================\n"))
cat(sprintf("Locks (got keys) ANOVA:\n"))
dlocks1 <- processedData_long %>% 
            filter(Story == "locks", Case=="got keys", expl != "Explanation.7")
print(summary(aov(rating ~ expl + Error(Subject/expl), data=dlocks1)))

cat(sprintf("\n=========================\n"))
cat(sprintf("Locks (didn't get keys) ANOVA:\n"))
dlocks2 <- processedData_long %>% 
            filter(Story == "locks", Case=="didn't get keys", expl != "Explanation.7")
print(summary(aov(rating ~ expl + Error(Subject/expl), data=dlocks2)))

# Compute the t-tests
# We are specifically comparing Explanation 6 across the two cases of each story.
# These explanations provide rational support in both cases, but one explanation is
# simpler. For example, consider the robbery story. 
#
# Case 1: arrested the culprit
#	Explanation 6: knew that he had robbed the liquor store, the drug store, and the grocery store
#
# Case 2: didn't arrest the culprit
# 	Explanation 6: didn't know that he had robbed the liquor store, or the drug store, or the grocery store
#
# In Case 2, it is necessary to know all three facts in order for the action to provide rational support. But in Case 1, it only necessary to know any one of the three facts to provide rational support. As a result, relative to the other available explanations, Case 1 is a less simple explanation and would receive a lower rating according to our model. We therefore predict that people would assign a higher rating to Explanation 6 in Case 2 than in Case 1.

# Food allergy
cat(sprintf("\n=========================\n"))
cat(sprintf("Food allergy t-test result (didn't eat vs. ate):\n"))

pdFood <- processedData %>% filter(Story == "food allergy") %>%
                            select(Subject, Story, Case, Explanation.6)
print(t.test(pdFood %>% filter(Case=="didn't eat") %>% select(Explanation.6), 
      pdFood %>% filter(Case=="ate") %>% select(Explanation.6), 
	  alternative = c("less"), var.equal = TRUE))
	  
# Robbery
cat(sprintf("\n=========================\n"))
cat(sprintf("Robbery t-test result (didn't arrest vs. did arrest):\n"))

pdRobbery <- processedData %>% filter(Story == "robbery") %>%
                            select(Subject, Story, Case, Explanation.6)
print(t.test(pdRobbery %>% filter(Case=="didn't arrest") %>% select(Explanation.6), 
      pdRobbery %>% filter(Case=="arrested") %>% select(Explanation.6), 
	  alternative = c("less"), var.equal = TRUE))
	  
# Locks
cat(sprintf("\n=========================\n"))
cat(sprintf("Locks t-test result (got keys vs. didn't get keys):\n"))

pdLocks <- processedData %>% filter(Story == "locks") %>%
                            select(Subject, Story, Case, Explanation.6)
print(t.test(pdLocks %>% filter(Case=="got keys") %>% select(Explanation.6), 
      pdLocks %>% filter(Case=="didn't get keys") %>% select(Explanation.6), 
	  alternative = c("less"), var.equal = TRUE))
	  

# Make plots

# Read in model predictions
predictions <- read.csv("../Model/predictions/predictions_tidy.csv")
# Group the three freatures together to make a single column representing condition
predictions <- predictions %>% unite("f", c("Feature.1", "Feature.2", "Feature.3"))

# Plot model predictions
print(ggplot(predictions, 
             aes(x=fct_rev(fct_reorder(f, Probability)), y=Probability, fill=Probability)) +
             geom_col() +
             guides(fill=FALSE) +
             xlab("Explanations") +
             scale_x_discrete(labels=c("1","2","3","4","5","6","7")) +
             ylab("Probability") +
             theme(text=element_text(size=9)) +
             ggtitle("Model predictions"))
#ggsave("expt4_predictions.pdf", width=1.5, height=1.4, units="in")


# Plot data
CImult = 1.96

# Food allergy, didn't eat
pdFoodNoEat <- processedData_long %>%
               filter(Story == "food allergy", Case == "didn't eat",
                      expl != "Explanation.7")
# Compute means and glue a column of predictions
pdFoodNoEatMeans <- pdFoodNoEat %>% group_by(expl) %>%
                                    summarize(m = mean(rating),
                                              std = sd(rating),
                                              n = n(),
                                              CI = CImult*std/sqrt(n)) %>%
                                    mutate(prob = predictions$Probability)

print(ggplot(pdFoodNoEatMeans, 
             aes(x=fct_rev(fct_reorder(expl, prob)), y=m, fill=prob)) +
             geom_col() +
             geom_errorbar(aes(x=fct_rev(fct_reorder(expl, prob)), ymin=m-CI, ymax=m+CI), width=0.2) +
             guides(fill=FALSE) +
             xlab("Explanations") +
             scale_x_discrete(labels=c("1","2","3","4","5","6","7")) +
             ylab("Mean rating") +
             theme(text=element_text(size=9)) +
             ylim(0,7) +
             ggtitle("Food allergy, Didn't eat"))
#ggsave("data_allergy.pdf", width=1.5, height=1.4, units="in")

# Food allergy, did eat
pdFoodAte <- processedData_long %>%
               filter(Story == "food allergy", Case == "ate",
                      expl != "Explanation.7")
# Compute means and glue a column of predictions
pdFoodAteMeans <- pdFoodAte %>% group_by(expl) %>%
                                    summarize(m = mean(rating),
                                              std = sd(rating),
                                              n = n(),
                                              CI = CImult*std/sqrt(n)) %>%
                                    mutate(prob = predictions$Probability)

print(ggplot(pdFoodAteMeans, 
             aes(x=fct_rev(fct_reorder(expl, prob)), y=m, fill=prob)) +
             geom_col() +
             geom_errorbar(aes(x=fct_rev(fct_reorder(expl, prob)), ymin=m-CI, ymax=m+CI), width=0.2) +
             guides(fill=FALSE) +
             xlab("Explanations") +
             scale_x_discrete(labels=c("1","2","3","4","5","6","7")) +
             ylab("Mean rating") +
             theme(text=element_text(size=9)) +
             ylim(0,7) +
             ggtitle("Food allergy, Ate"))
#ggsave("data_allergy_ate.pdf", width=1.5, height=1.4, units="in")
             
# Robbery, Arrested
pdRobberyArrested <- processedData_long %>%
                     filter(Story == "robbery", Case == "arrested",
                            expl != "Explanation.7")
# Compute means and glue a column of predictions
pdRobberyArrestedMeans <- pdRobberyArrested %>% group_by(expl) %>%
                                                summarize(m = mean(rating),
                                                std = sd(rating),
                                                n = n(),
                                                CI = CImult*std/sqrt(n)) %>%
                                                mutate(prob = predictions$Probability)

print(ggplot(pdRobberyArrestedMeans, 
             aes(x=fct_rev(fct_reorder(expl, prob)), y=m, fill=prob)) +
             geom_col() +
             geom_errorbar(aes(x=fct_rev(fct_reorder(expl, prob)), ymin=m-CI, ymax=m+CI), width=0.2) +
             guides(fill=FALSE) +
             xlab("Explanations") +
             scale_x_discrete(labels=c("1","2","3","4","5","6","7")) +
             ylab("Mean rating") +
             theme(text=element_text(size=9)) +
             ylim(0,7) +
             ggtitle("Robbery, Arrested"))
#ggsave("data_robbery.pdf", width=1.5, height=1.4, units="in")

# Robbery, No arrest
pdRobberyNoArrest <- processedData_long %>%
                     filter(Story == "robbery", Case == "didn't arrest",
                            expl != "Explanation.7")
# Compute means and glue a column of predictions
pdRobberyNoArrestMeans <- pdRobberyNoArrest %>% group_by(expl) %>%
                                                summarize(m = mean(rating),
                                                std = sd(rating),
                                                n = n(),
                                                CI = CImult*std/sqrt(n)) %>%
                                                mutate(prob = predictions$Probability)

print(ggplot(pdRobberyNoArrestMeans, 
             aes(x=fct_rev(fct_reorder(expl, prob)), y=m, fill=prob)) +
             geom_col() +
             geom_errorbar(aes(x=fct_rev(fct_reorder(expl, prob)), ymin=m-CI, ymax=m+CI), width=0.2) +
             guides(fill=FALSE) +
             xlab("Explanations") +
             scale_x_discrete(labels=c("1","2","3","4","5","6","7")) +
             ylab("Mean rating") +
             theme(text=element_text(size=9)) +
             ylim(0,7) +
             ggtitle("Robbery, Didn't arrest"))
#ggsave("data_robbery_noarrest.pdf", width=1.5, height=1.4, units="in")

             
# Locks, Got keys
pdLocksGotKeys <- processedData_long %>%
                  filter(Story == "locks", Case == "got keys",
                         expl != "Explanation.7")
# Compute means and glue a column of predictions
pdLocksGotKeysMeans <- pdLocksGotKeys %>% group_by(expl) %>%
                                          summarize(m = mean(rating),
                                          std = sd(rating),
                                          n = n(),
                                          CI = CImult*std/sqrt(n)) %>%
                                          mutate(prob = predictions$Probability)

print(ggplot(pdLocksGotKeysMeans, 
             aes(x=fct_rev(fct_reorder(expl, prob)), y=m, fill=prob)) +
             geom_col() +
             geom_errorbar(aes(x=fct_rev(fct_reorder(expl, prob)), ymin=m-CI, ymax=m+CI), width=0.2) +
             guides(fill=FALSE) +
             xlab("Explanations") +
             scale_x_discrete(labels=c("1","2","3","4","5","6","7")) +
             ylab("Mean rating") +
             theme(text=element_text(size=9)) +
             ylim(0,7) +
             ggtitle("Locks, Got keys"))
#ggsave("data_locks.pdf", width=1.5, height=1.4, units="in")

# Locks, Didn't get keys
pdLocksNoKeys <- processedData_long %>%
                  filter(Story == "locks", Case == "didn't get keys",
                         expl != "Explanation.7")
# Compute means and glue a column of predictions
pdLocksNoKeysMeans <- pdLocksNoKeys %>% group_by(expl) %>%
                                          summarize(m = mean(rating),
                                          std = sd(rating),
                                          n = n(),
                                          CI = CImult*std/sqrt(n)) %>%
                                          mutate(prob = predictions$Probability)

print(ggplot(pdLocksNoKeysMeans, 
             aes(x=fct_rev(fct_reorder(expl, prob)), y=m, fill=prob)) +
             geom_col() +
             geom_errorbar(aes(x=fct_rev(fct_reorder(expl, prob)), ymin=m-CI, ymax=m+CI), width=0.2) +
             guides(fill=FALSE) +
             xlab("Explanations") +
             scale_x_discrete(labels=c("1","2","3","4","5","6","7")) +
             ylab("Mean rating") +
             theme(text=element_text(size=9)) +
             ylim(0,7) +
             ggtitle("Locks, Didn't get keys"))
#ggsave("data_locks_nokeys.pdf", width=1.5, height=1.4, units="in")
