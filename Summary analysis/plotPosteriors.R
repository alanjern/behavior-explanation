# Make density plots of posterior probability samples from
# Bayesian regression analyses of Experiments 1A, 1B, and 3

library(tidyverse)
library(viridis)
library(ggrepel)

# Clear workspace
rm(list=ls())


# Read in posterior samples
samples_expt1a <- read_csv('../Experiment 1A/Analysis/posterior_samples_expt1A.csv')
samples_expt1b <- read_csv('../Experiment 1B/Analysis/posterior_samples_expt1B.csv')
samples_expt3 <- read_csv('../Experiment 3/Analysis/posterior_samples_expt3.csv')

# Reorganize data frames
samples_expt1a <- samples_expt1a %>% gather("variable","sample",2:3) %>% mutate(experiment = "Experiment 1A")
samples_expt1b <- samples_expt1b %>% gather("variable","sample",2:3) %>% mutate(experiment = "Experiment 1B")
samples_expt3 <- samples_expt3 %>% gather("variable","sample",2:3) %>% mutate(experiment = "Experiment 3")

# Glue data frames together
samples_all <- samples_expt1a %>% bind_rows(samples_expt1b) %>% bind_rows(samples_expt3)

# Plot rational support
samples_rationalsupport <- samples_all %>% filter(variable == "b_rationalsupport")
labels_rationalsupport <- samples_rationalsupport %>% group_by(experiment) %>%
          summarize(xPos = max(sample)-0.4*(max(sample)-min(sample)),
                    yPos = max((density(sample))$y))
print(ggplot(samples_rationalsupport, aes(sample)) +
  geom_density(alpha=0.2, aes(color=experiment, fill=experiment)) +
  geom_label_repel(data=labels_rationalsupport, size=2.5, aes(x=xPos, y=yPos, label=experiment)) +
  scale_color_viridis(discrete = TRUE, guide=FALSE) +
  scale_fill_viridis(discrete = TRUE, guide=FALSE) +
  theme(text=element_text(size=9)) +
  xlab("Coefficient sample") +
  ylab(NULL) +
  labs(title = "Rational support posterior density"))
ggsave("posterior_density_rationalsupport.pdf", width=3, height=2, units="in")


# Plot simplicity
samples_simplicity <- samples_all %>% filter(variable == "b_simplicity")
labels_simplicity <- samples_simplicity %>% group_by(experiment) %>%
          summarize(xPos = max(sample)-0.4*(max(sample)-min(sample)),
                    yPos = max((density(sample))$y))
print(ggplot(samples_simplicity, aes(sample)) +
  geom_density(alpha=0.2, aes(color=experiment, fill=experiment)) +
  geom_label_repel(data=labels_simplicity, size=2.5, aes(x=xPos, y=yPos, label=experiment)) +
  scale_color_viridis(discrete = TRUE, guide=FALSE) +
  scale_fill_viridis(discrete = TRUE, guide=FALSE) +
  theme(text=element_text(size=9)) +
  xlab("Coefficient sample") +
  ylab(NULL) +
  labs(title = "Simplicity posterior density"))
ggsave("posterior_density_simplicity.pdf", width=3, height=2, units="in")
