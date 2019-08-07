# Analyze data

library(irr)
library(tidyverse)


# Clear workspace
rm(list=ls())

# Condition 1
print("Condition 1")
# Read in data
ratings1 <- read_csv('../Data/condition1.csv')
# Compute Cohen's kappa
print(kappa2(data.frame(ratings1$coder1, ratings1$coder2)))

# Condition 2
print("Condition 2")
# Read in data
ratings2 <- read_csv('../Data/condition2.csv')
# Compute Cohen's kappa
print(kappa2(data.frame(ratings2$coder1, ratings2$coder2)))

# Condition 3
print("Condition 3")
# Read in data
ratings3 <- read_csv('../Data/condition3.csv')
# Compute Cohen's kappa
print(kappa2(data.frame(ratings3$coder1, ratings3$coder2)))

# Compute overall kappa
fullratings <- ratings1 %>% bind_rows(ratings2) %>% bind_rows(ratings3)
print(kappa2(data.frame(fullratings$coder1, fullratings$coder2)))


# Reorganize the predictions for analysis
r1 <- ratings1 %>% select(decision) %>% rename(explanation = decision) %>%
						                mutate(condition = 1)
r2 <- ratings2 %>% select(decision) %>% rename(explanation = decision) %>%
						                mutate(condition = 2)
r3 <- ratings3 %>% select(decision) %>% rename(explanation = decision) %>%
						                mutate(condition = 3)
ratings <- r1 %>% bind_rows(r2) %>% bind_rows(r3)



# Read in model predictions
predictions <- read_csv('bestfitting_modelpredictions.csv')

# Normalize model predictions so that they sum to 1
cond1predictions <- predictions %>% filter(condition == 1)
cond1predictions$fullmodel <- cond1predictions$fullmodel /
                              sum(cond1predictions$fullmodel)
cond1predictions$utility <- cond1predictions$utility
                              
cond2predictions <- predictions %>% filter(condition == 2)
cond2predictions$fullmodel <- cond2predictions$fullmodel /
                              sum(cond2predictions$fullmodel)
cond2predictions$utility <- cond2predictions$utility

cond3predictions <- predictions %>% filter(condition == 3)
cond3predictions$fullmodel <- cond3predictions$fullmodel /
                              sum(cond3predictions$fullmodel)
cond3predictions$utility <- cond3predictions$utility
                              
# Put the predictions back together
#preds <- bind_rows(cond1predictions, cond2predictions, cond3predictions)
#preds <- preds %>% select(-X1) # Leave out the superfluous "X" column that is basically just a row number
                              
# Reshape into tidy format
cond1predictionsTidy <- cond1predictions %>% 
                            gather(model, prediction, c("fullmodel", "utility"))
cond2predictionsTidy <- cond2predictions %>% 
                            gather(model, prediction, c("fullmodel", "utility"))
cond3predictionsTidy <- cond3predictions %>% 
                            gather(model, prediction, c("fullmodel", "utility"))
							
# Perform an analysis to determine the proportion of subject responses
# that are included in the model's top N responses for all values of N

# Sort model predictions from most to least probable
c1predictions <- cond1predictionsTidy %>% filter(model == "fullmodel") %>%
										  select(explanation, prediction) %>%
										  arrange(desc(prediction)) %>%
										  mutate(condition = 1)
c2predictions <- cond2predictionsTidy %>% filter(model == "fullmodel") %>%
										  select(explanation, prediction) %>%
										  arrange(desc(prediction)) %>%
										  mutate(condition = 2)
c3predictions <- cond3predictionsTidy %>% filter(model == "fullmodel") %>%
										  select(explanation, prediction) %>%
										  arrange(desc(prediction)) %>%
										  mutate(condition = 3)
preds <- c1predictions %>% bind_rows(c2predictions) %>% bind_rows(c3predictions)

nmax <- 12
c1proportions <- rep(0,nmax)
c2proportions <- rep(0,nmax)
c3proportions <- rep(0,nmax)
										  
for (n in 1:nmax) {
	# Counters to keep track of how many of the ith explanation in each condition
	# subjects generated
	n1 <- 0
	n2 <- 0
	n3 <- 0
	
	# Iterate over all explanations to get a cumulative total
	for (i in 1:n) {
		# Look for how many of subjects' explanations match the ith explanation
		n1 <- n1 + nrow(r1 %>% filter(explanation == c1predictions[i,]$explanation))
		n2 <- n2 + nrow(r2 %>% filter(explanation == c2predictions[i,]$explanation))
		n3 <- n3 + nrow(r3 %>% filter(explanation == c3predictions[i,]$explanation))
	}
	
	# Divide by total number of explanations to get proportions
	c1proportions[n] <- n1 / nrow(r1)
	c2proportions[n] <- n2 / nrow(r2)
	c3proportions[n] <- n3 / nrow(r3)
}

# Plot the results
topN <- seq(1,12)
c1props.df <- data.frame(topN, c1proportions) %>% rename(proportion = c1proportions) %>%
                                                  mutate(condition = "1")
c2props.df <- data.frame(topN, c2proportions) %>% rename(proportion = c2proportions) %>%
                                                  mutate(condition = "2")
c3props.df <- data.frame(topN, c3proportions) %>% rename(proportion = c3proportions) %>%
                                                  mutate(condition = "3")
proportions <- c1props.df %>% bind_rows(c2props.df) %>% bind_rows(c3props.df) %>%
               rename(Condition = condition)
               
print(ggplot(data=proportions, 
             aes(x=topN, y=proportion, group=Condition, shape=Condition, linetype=Condition)) +
             geom_line(aes(color=Condition)) +
			 geom_point(aes(color=Condition)) +
			 ylim(0,1) +
             scale_x_continuous(breaks=seq(1,12,2)) +
             xlab("Model's top N predicted explanations") +
             ylab("Proportion of subjects' explanations") +
             ggtitle("Decision net model") +
             theme(axis.title.y = element_text(angle=90, vjust=0.5), legend.position="bottom",
                   text=element_text(size=9)) +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
ggsave("expt1bresults_fullmodel.pdf", width=2.75, height=4, units="in")
             
             
# Repeat for non-probabilistic model

# Sort model predictions from most to least probable
c1predictions <- cond1predictionsTidy %>% filter(model == "utility") %>%
										  select(explanation, prediction) %>%
										  arrange(desc(prediction)) %>%
										  mutate(condition = 1)
c2predictions <- cond2predictionsTidy %>% filter(model == "utility") %>%
										  select(explanation, prediction) %>%
										  arrange(desc(prediction)) %>%
										  mutate(condition = 2)
c3predictions <- cond3predictionsTidy %>% filter(model == "utility") %>%
										  select(explanation, prediction) %>%
										  arrange(desc(prediction)) %>%
										  mutate(condition = 3)
preds <- c1predictions %>% bind_rows(c2predictions) %>% bind_rows(c3predictions)

nmax <- 12
c1proportions <- rep(0,nmax)
c2proportions <- rep(0,nmax)
c3proportions <- rep(0,nmax)
										  
for (n in 1:nmax) {
	# Counters to keep track of how many of the ith explanation in each condition
	# subjects generated
	n1 <- 0
	n2 <- 0
	n3 <- 0
	
	# Iterate over all explanations to get a cumulative total
	for (i in 1:n) {
		# Look for how many of subjects' explanations match the ith explanation
		n1 <- n1 + nrow(r1 %>% filter(explanation == c1predictions[i,]$explanation))
		n2 <- n2 + nrow(r2 %>% filter(explanation == c2predictions[i,]$explanation))
		n3 <- n3 + nrow(r3 %>% filter(explanation == c3predictions[i,]$explanation))
	}
	
	# Divide by total number of explanations to get proportions
	c1proportions[n] <- n1 / nrow(r1)
	c2proportions[n] <- n2 / nrow(r2)
	c3proportions[n] <- n3 / nrow(r3)
}

# Plot the results
topN <- seq(1,12)
c1props.df <- data.frame(topN, c1proportions) %>% rename(proportion = c1proportions) %>%
                                                  mutate(condition = "1")
c2props.df <- data.frame(topN, c2proportions) %>% rename(proportion = c2proportions) %>%
                                                  mutate(condition = "2")
c3props.df <- data.frame(topN, c3proportions) %>% rename(proportion = c3proportions) %>%
                                                  mutate(condition = "3")
proportions <- c1props.df %>% bind_rows(c2props.df) %>% bind_rows(c3props.df) %>%
               rename(Condition = condition)

print(ggplot(data=proportions, 
             aes(x=topN, y=proportion, group=Condition, shape=Condition, linetype=Condition)) +
             geom_line(aes(color=Condition)) +
			 geom_point(aes(color=Condition)) +
			 ylim(0,1) +
             scale_x_continuous(breaks=seq(1,12,2)) +
             xlab("Model's top N predicted explanations") +
             ylab("Proportion of subjects' explanations") +
             ggtitle("Non-probabilistic model") +
             theme(axis.title.y = element_text(angle=90, vjust=0.5), legend.position="bottom",
                   text=element_text(size=9)) +
             scale_color_manual(values=c("#1b9e77", "#d95f02", "#7570b3")))
ggsave("expt1bresults_nonprobmodel.pdf", width=2.75, height=4, units="in")

