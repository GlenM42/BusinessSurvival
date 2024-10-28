# mixed_models.R
library(lme4)
library(performance)
library(sjPlot)

# Fit random intercepts model
lin_mix_model <- lmer(log_Avg_Survival_Rate ~ Year_After_Establishment + (1 | Industry), 
                      data = averages_data)

# Summary of the model
summary(lin_mix_model)
icc(lin_mix_model)

# Fit model with random slopes
lin_mix_model_slopes <- lmer(log_Avg_Survival_Rate ~ Year_After_Establishment +  (1 + Year_After_Establishment | Industry), 
                             data = averages_data)

# Summary of the random slopes model
summary(lin_mix_model_slopes)
icc(lin_mix_model_slopes)

data_filtered <- averages_data %>%
  filter(Year_After_Establishment <= 10)

# Fit model with random slopes
lin_mix_model_slopes_10_years <- lmer(log_Avg_Survival_Rate ~ Year_After_Establishment +  (1 + Year_After_Establishment | Industry), 
                             data = data_filtered)

# Summary of the random slopes model
summary(lin_mix_model_slopes_10_years)
icc(lin_mix_model_slopes_10_years)

# Plot the random effects
re.effects <- plot_model(lin_mix_model, 
                         type = "re", 
                         show.values = TRUE, 
                         title = "Random Intercepts by Industries over the Whole Period")
re.effects + 
  scale_y_continuous(limits = c(-0.5, 0.5)) +
  theme(
    panel.border = element_rect(color = "black", fill = NA, size = 1),  # Add border around panels
    panel.spacing = unit(1, "lines"),  # Increase space between panels
    strip.background = element_rect(color = "black", size = 0.5),  # Frame facet titles
    strip.text = element_text(size = 12)  # Adjust facet title text size
  )
re.effects <- plot_model(lin_mix_model_slopes, 
                         type = "re", 
                         show.values = TRUE, 
                         title = "Random Intercepts and Slopes by Industries over the Whole Period")
re.effects + 
  scale_y_continuous(limits = c(-0.2, 0.2)) +
  theme(
    panel.border = element_rect(color = "black", fill = NA, size = 1),  # Add border around panels
    panel.spacing = unit(1, "lines"),  # Increase space between panels
    strip.background = element_rect(color = "black", size = 0.5),  # Frame facet titles
    strip.text = element_text(size = 12)  # Adjust facet title text size
  )
re.effects <- plot_model(lin_mix_model_slopes_10_years, 
                         type = "re", 
                         show.values = TRUE, 
                         title = "Random Intercepts and Slopes by Industries in the First Ten Years")
re.effects + 
  scale_y_continuous(limits = c(-0.045, 0.045)) +
  theme(
    panel.border = element_rect(color = "black", fill = NA, size = 1),  # Add border around panels
    panel.spacing = unit(1, "lines"),  # Increase space between panels
    strip.background = element_rect(color = "black", size = 0.5),  # Frame facet titles
    strip.text = element_text(size = 12)  # Adjust facet title text size
  )


####### The second graph has different scales, so we do this


# Load necessary packages
library(broom.mixed)
library(dplyr)
library(ggplot2)
library(stringr)

# Extract and structure the random effects data
re_data <- broom.mixed::tidy(lin_mix_model_slopes, effects = "ran_vals")

# Calculate confidence intervals and assign colors based on sign
re_data <- re_data %>%
  mutate(
    term_type = ifelse(str_detect(term, "Intercept"), "Intercept", "Slope"),
    industry = as.factor(level),  # Use 'level' for industry names
    conf.low = estimate - 1.96 * std.error,  # Lower bound
    conf.high = estimate + 1.96 * std.error,  # Upper bound
    color = ifelse(estimate >= 0, "deepskyblue4", "red")  # Color based on estimate sign
  )

# Plot with industries, color-coded confidence intervals, and estimates
ggplot(re_data, aes(x = estimate, y = industry)) +
  geom_point(aes(color = color), size = 3) +  # Plot the point estimates with color
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high, color = color), height = 0.2) +  # Error bars with color
  geom_text(aes(label = round(estimate, 2), color = color), vjust = -0.5, size = 3) +  # Display values above points
  facet_wrap(~ term_type, ncol = 2, scales = "free_x") +  # Two columns: Intercept and Slope
  scale_color_identity() +  # Use the specified red/blue colors directly
  theme_minimal(base_size = 14) +  # Set minimal theme with larger base size for readability
  theme(
    panel.background = element_rect(fill = "grey90", color = NA),  # Dark panel background
    plot.background = element_rect(fill = "white", color = NA),  # Dark plot background
    panel.grid.major = element_line(color = "white"),  # Darker grid lines
    panel.grid.minor = element_line(color = "white"),  # Minor grid lines
    axis.text.y = element_text(size = 10, color = "black"),  # White industry labels
    axis.text.x = element_text(size = 10, color = "black"),  # White x-axis labels
    panel.border = element_rect(color = "black", fill = NA, size = 1),  # White border around panels
    panel.spacing = unit(1, "lines"),  # Space between panels
    strip.background = element_rect(color = "gray", size = 0.5),  # White frame for facet titles
    strip.text = element_text(size = 12, color = "black") 
  ) +
  labs(
    title = "Random Intercepts and Slopes by Industries over the Whole Period",
    x = "Estimate",
    y = "Industry"
  )

