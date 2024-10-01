# Load necessary libraries
library(lme4)
library(ggplot2)
library(dplyr)
library(readr)

# averages_data <- read_csv("PycharmProjects/bs/averages.csv")
averages_data <- read_csv("averages.csv")

# Perform log transformation of the average survival rate
averages_data$log_Avg_Survival_Rate <- log(averages_data$Avg_Survival_Rate)

# Fit a Linear Mixed Model with Year_After_Establishment as the fixed effect and Industry as the random effect
lin_mix_model <- lmer(log_Avg_Survival_Rate ~ Year_After_Establishment + Year_After_Establishment:Industry + (1 | Industry),
                      data = averages_data)

# Show the summary of the Linear Mixed Model
summary(lin_mix_model)

# Plot the average survival rates for each industry over time
ggplot(averages_data, aes(x = Year_After_Establishment, y = Avg_Survival_Rate, color = Industry)) +
  geom_line() +
  labs(title = "Average Business Survival Rates by Industry Over Time",
       x = "Years After Establishment",
       y = "Average Survival Rate (%)") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(title = "Industry"))

# Plot the log-transformed average survival rates
ggplot(averages_data, aes(x = Year_After_Establishment, y = log_Avg_Survival_Rate, color = Industry)) +
  geom_line() +
  labs(title = "Log-Transformed Average Business Survival Rates by Industry Over Time",
       x = "Years After Establishment",
       y = "Log of Average Survival Rate") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(title = "Industry"))

# Likelihood Ratio Test: testing if the random effect is significant
# Fit the simpler model (fixed effects only, without the random effect)
lmm_fixed_only <- lm(log_Avg_Survival_Rate ~ Year_After_Establishment, data = averages_data)

# Perform the likelihood ratio test between the mixed model and the fixed model
library(lmtest)
lr_test <- lrtest(lin_mix_model, lmm_fixed_only)
print(lr_test)

lin_mix_model <- lmer(log_Avg_Survival_Rate ~ Year_After_Establishment + (1 + Year_After_Establishment | Industry),
                      data = averages_data)

# Show the summary of the Linear Mixed Model
summary(lin_mix_model)