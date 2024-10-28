# Load necessary libraries
library(lme4)
library(ggplot2)
library(dplyr)
library(readr)

averages_data <- read_csv("PycharmProjects/bs/averages.csv")
# averages_data <- read_csv("averages.csv")

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
  theme_bw() +
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

library(lme4)
library(ggplot2)
library(dplyr)
library(readr)
library(lmtest)

#averages_data <- read_csv("PycharmProjects/bs/averages.csv")
# averages_data <- read_csv("averages.csv")
averages_data <- read_csv("PycharmProjects/bs/averages_with_total.csv")

head(averages_data)

ggplot(averages_data, aes(x = Year_After_Establishment, y = Avg_Survival_Rate, color = Industry)) +
  geom_line() +
  labs(title = "Average Business Survival Rates by Industry Over Time",
       x = "Years After Establishment",
       y = "Average Survival Rate (%)") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(title = "Industry"))

averages_data$log_Avg_Survival_Rate <- log(averages_data$Avg_Survival_Rate)

head(averages_data)

ggplot(averages_data, aes(x = Year_After_Establishment, y = log_Avg_Survival_Rate, color = Industry)) +
  geom_line() +
  labs(title = "Log-Transformed Average Business Survival Rates by Industry Over Time",
       x = "Years After Establishment",
       y = "Log of Average Survival Rate") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(title = "Industry"))

lin_mix_model <- 
  lmer(log_Avg_Survival_Rate ~ Year_After_Establishment + ( 1 | Industry), data = averages_data)

summary(lin_mix_model)

lmm_fixed_only <- lm(log_Avg_Survival_Rate ~ Year_After_Establishment, data = averages_data)

# Perform the likelihood ratio test between the mixed model and the fixed model
lr_test <- lrtest(lin_mix_model, lmm_fixed_only)
print(lr_test)

# Updated model with random slopes for Year_After_Establishment within industries
lin_mix_model_slopes <- lmer(log_Avg_Survival_Rate ~ Year_After_Establishment + (1 + Year_After_Establishment | Industry), 
                             data = averages_data)

# Summary of the new model
summary(lin_mix_model_slopes)

# Likelihood ratio test between the random slopes model and the random intercepts model
lr_test_slopes <- lrtest(lin_mix_model, lin_mix_model_slopes)
print(lr_test_slopes)

# Load the new dataset that includes the Total industry data
averages_data_with_total <- read_csv("PycharmProjects/bs/averages_with_total.csv")

# Apply log transformation
averages_data_with_total$log_Avg_Survival_Rate <- log(averages_data_with_total$Avg_Survival_Rate)

# Define the pairs to compare
industry_pairs <- list(
  c("TOTAL.txt", "utilities_table7.txt"),
  c("TOTAL.txt", "management.txt"),
  c("TOTAL.txt", "information.txt"),
  c("TOTAL.txt", "agriculture.txt")
)

# Initialize a list to store the LME results
lme_results <- list()

# Loop over the industry pairs and run LME models
for (pair in industry_pairs) {
  # Filter data for the current pair
  data_filtered <- averages_data_with_total %>%
    filter(Industry %in% pair & Year_After_Establishment <= 10)
  
  # Ensure there are at least two industries in the filtered data
  if (length(unique(data_filtered$Industry)) < 2) {
    cat("Skipping pair due to insufficient data:", paste(pair, collapse = " vs "), "\n")
    next
  }
  
  # Fit the random intercepts model
  lme_model_intercepts <- lmer(log_Avg_Survival_Rate ~ Year_After_Establishment + 
                                 (1 | Industry), data = data_filtered)
  
  # Fit the random slopes model
  lme_model_slopes <- lmer(log_Avg_Survival_Rate ~ Year_After_Establishment + 
                             (1 + Year_After_Establishment | Industry), data = data_filtered)
  
  # Perform likelihood ratio test
  lr_test <- lrtest(lme_model_intercepts, lme_model_slopes)
  
  # Store the result in the list
  lme_results[[paste(pair, collapse = " vs ")]] <- list(
    intercept_model = summary(lme_model_intercepts),
    slope_model = summary(lme_model_slopes),
    lr_test = lr_test
  )
}

# Print results for each pair
for (pair in names(lme_results)) {
  cat("Results for:", pair, "\n")
  print(lme_results[[pair]]$lr_test)
  cat("\n")
}

# Initialize a list to store the ANCOVA results
ancova_results <- list()

par(mfrow = c(4, 4))

# Loop over the industry pairs and run ANCOVA models
for (pair in industry_pairs) {
  # Filter data for the current pair
  data_filtered <- averages_data_with_total %>%
    filter(Industry %in% pair & Year_After_Establishment <= 10)
  
  # Ensure there are at least two industries in the filtered data
  if (length(unique(data_filtered$Industry)) < 2) {
    cat("Skipping pair due to insufficient data:", paste(pair, collapse = " vs "), "\n")
    next
  }
  
  # Fit the ANCOVA model with interaction
  ancova_model <- lm(log_Avg_Survival_Rate ~ Year_After_Establishment * Industry, 
                     data = data_filtered)
  cat(coef(ancova_model), "\n")
  plot(ancova_model)
  
  # Store the result in the list
  ancova_results[[paste(pair, collapse = " vs ")]] <- summary(ancova_model)
}

# Print results for each pair
for (pair in names(ancova_results)) {
  cat("ANCOVA Results for:", pair, "\n")
  print(ancova_results[[pair]])
  cat("\n")
}

#################
# Load required libraries
library(ggplot2)
library(gridExtra)

# Initialize a list to store the ANCOVA results and plots
ancova_results <- list()
plots <- list()  # Store ggplot objects for later

# Loop over the industry pairs and run ANCOVA models
for (pair in industry_pairs) {
  # Filter data for the current pair
  data_filtered <- averages_data_with_total %>%
    filter(Industry %in% pair & Year_After_Establishment <= 10)
  
  # Ensure there are at least two industries in the filtered data
  if (length(unique(data_filtered$Industry)) < 2) {
    cat("Skipping pair due to insufficient data:", paste(pair, collapse = " vs "), "\n")
    next
  }
  
  # Fit the ANCOVA model with interaction
  ancova_model <- lm(log_Avg_Survival_Rate ~ Year_After_Establishment * Industry, data = data_filtered)
  
  # Extract the coefficients for plotting equations
  coefficients <- coef(ancova_model)
  industry1_eq <- paste0(pair[1], ": y = ", round(coefficients[1], 2), 
                         " + ", round(coefficients[2], 2), "x")
  industry2_eq <- paste0(pair[2], ": y = ", round(coefficients[1] + coefficients[3], 2), 
                         " + ", round(coefficients[2] + coefficients[4], 2), "x")
  
  # Create the ggplot object
  p <- ggplot(data_filtered, 
              aes(x = Year_After_Establishment, 
                  y = log_Avg_Survival_Rate, color = Industry)) +
    geom_point(size = 2) +
    geom_smooth(method = "lm", se = TRUE, aes(linetype = Industry), size = 1) +
    xlab("Years After Establishment") +
    ylab("Log of Average Survival Rate") +
    scale_color_manual(values = c("blue", "red", "green", "purple")) +
    theme_classic() +
    annotate("text", x = 0.25, y = 5.2, label = industry1_eq, color = "red", hjust = 0, size=4) +
    annotate("text", x = 0.25, y = 5, label = industry2_eq, color = "blue", hjust = 0, size=4)
  
  # Store the plot
  plots[[paste(pair, collapse = " vs ")]] <- p
  
  # Store the ANCOVA result
  ancova_results[[paste(pair, collapse = " vs ")]] <- summary(ancova_model)
}

# Display the plots in a 2x2 grid using gridExtra
do.call(grid.arrange, c(plots, ncol = 2, nrow = 2))

# Print ANCOVA results for each pair
for (pair in names(ancova_results)) {
  cat("ANCOVA Results for:", pair, "\n")
  print(ancova_results[[pair]])
  cat("\n")
}

##################33##
# Define a consistent color palette for industries
industry_colors <- c(
  "TOTAL.txt" = "red", 
  "utilities_table7.txt" = "blue", 
  "management.txt" = "blue", 
  "information.txt" = "blue", 
  "agriculture.txt" = "blue"
)

# Initialize results and plots lists
ancova_results <- list()
plots <- list()

# Loop over the industry pairs
for (pair in industry_pairs) {
  data_filtered <- averages_data_with_total %>%
    filter(Industry %in% pair & Year_After_Establishment <= 10)
  
  if (length(unique(data_filtered$Industry)) < 2) {
    cat("Skipping pair due to insufficient data:", paste(pair, collapse = " vs "), "\n")
    next
  }
  
  # Fit the model for the pair
  ancova_model <- lm(log_Avg_Survival_Rate ~ Year_After_Establishment * Industry, 
                     data = data_filtered)
  
  # Extract the coefficients for the two industries in the pair
  coefficients <- coef(ancova_model)
  cat("\nHere are the coefficients for ", pair, ":\n")
  cat(coefficients)
  
  # Determine the intercept and slope for each industry
  industry1 <- pair[1]
  industry2 <- pair[2]
  
  intercept1 <- coefficients["(Intercept)"]
  slope1 <- coefficients["Year_After_Establishment"]
  
  # Check which industry is TOTAL.txt to extract the right coefficients
  if (industry2 != "TOTAL.txt") {
    intercept2 <- intercept1 + coefficients[paste0("Industry", industry2)]
    slope2 <- slope1 + coefficients[paste0("Year_After_Establishment:Industry", industry2)]
  } else {
    intercept2 <- intercept1
    slope2 <- slope1
    intercept1 <- intercept1 + coefficients[paste0("Industry", industry1)]
    slope1 <- slope1 + coefficients[paste0("Year_After_Establishment:Industry", industry1)]
  }
  
  # Create the equation strings
  industry1_eq <- paste0(industry1, ": y = ", round(intercept1, 2), " + ", round(slope1, 2), "x")
  industry2_eq <- paste0(industry2, ": y = ", round(intercept2, 2), " + ", round(slope2, 2), "x")
  
  # Create the plot with consistent colors
  p <- ggplot(data_filtered, 
              aes(x = Year_After_Establishment, 
                  y = log_Avg_Survival_Rate, color = Industry)) +
    geom_point(size = 2) +
    geom_smooth(method = "lm", se = TRUE, aes(linetype = Industry), size = 1) +
    xlab("Years After Establishment") +
    ylab("Log of Average Survival Rate") +
    scale_color_manual(values = industry_colors) +  # Use consistent color mapping
    theme_classic() +
    annotate("text", x = 5, y = 5.2, label = industry1_eq, color = "blue", hjust = 0, size = 3) +
    annotate("text", x = 5, y = 5, label = industry2_eq, color = "red", hjust = 0, size = 3)
  
  plots[[paste(pair, collapse = " vs ")]] <- p
  ancova_results[[paste(pair, collapse = " vs ")]] <- summary(ancova_model)
}

# Display the plots in a 2x2 grid
do.call(grid.arrange, c(plots, ncol = 2, nrow = 2))

# Print the ANCOVA results
for (pair in names(ancova_results)) {
  cat("ANCOVA Results for:", pair, "\n")
  print(ancova_results[[pair]])
  cat("\n")
}


