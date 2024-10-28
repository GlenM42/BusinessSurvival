# ancova_models_and_plots.R
library(ggplot2)
library(gridExtra)

# Store ANCOVA results and plots
ancova_results <- list()
plots <- list()

industry_colors <- c(
  "TOTAL" = "blue",   # TOTAL is always blue
  "utilities" = "brown", 
  "management" = "red", 
  "information" = "purple", 
  "agriculture" = "orange"
)

industry_linetypes <- c(
  "TOTAL" = "dashed",       # TOTAL always uses a solid line
  "utilities" = "solid", 
  "management" = "solid", 
  "information" = "solid", 
  "agriculture" = "solid"
)

# Loop over industry pairs and run ANCOVA models
for (pair in industry_pairs) {
  # Filter data for the current pair
  data_filtered <- averages_data_with_total %>%
    filter(Industry %in% pair & Year_After_Establishment <= 10)
  
  data_filtered$Industry <- factor(data_filtered$Industry)
  data_filtered$Industry <- relevel(data_filtered$Industry, ref = "TOTAL")
  
  contrasts(data_filtered$Industry) <- contr.treatment(levels(data_filtered$Industry), 
                                                       base = which(levels(data_filtered$Industry) == pair[2]))
  
  print(data_filtered, n=15)
  
  # Fit ANCOVA model with interaction
  ancova_model <- lm(log_Avg_Survival_Rate ~ Year_After_Establishment * Industry, 
                     data = data_filtered)
  
  # Extract coefficients
  coefficients <- coef(ancova_model)
  cat("\nCoefficients for the pair ", pair, ": \n", coefficients, "\n")
  industry_eq <- paste0(pair[2], ": y = ", round(coefficients[1],3), " + ", 
                                            round(coefficients[2],3), "X")
  cat("This is industry equation: ", industry_eq, "\n")
  total_eq <- paste0(pair[1], ": y = ", round(coefficients[1],3), " + ", 
                                            round(coefficients[3],3), " + (", 
                                            round(coefficients[2],3), " + ",  
                                            round(coefficients[4],3), ")X")
  total_eq_simpl <- paste0(pair[1], ": y = ", 
                    round(coefficients[1],3) + round(coefficients[3],3), " + ", 
                    round(coefficients[2],3) + round(coefficients[4],3), "X")
  cat("This is total equation: ", total_eq, "\n")
  cat("This is simplified total equation: ", total_eq_simpl, "\n")
  
  # Create plot
  p <- ggplot(data_filtered, aes(x = Year_After_Establishment, 
                                 y = log_Avg_Survival_Rate, color = Industry)) +
    geom_point(size = 2) +
    geom_smooth(method = "lm", se = TRUE, aes(linetype = Industry), size = 1) +
    xlab("Years After Establishment") +
    ylab("Log of Average Survival Rate") +
    scale_color_manual(values = industry_colors) + 
    scale_linetype_manual(values = industry_linetypes) +
    theme_bw() +
    annotate("text", x = 1, y = 5.2, label = industry_eq, color = industry_colors[pair[2]], hjust = 0, size = 3) +
    annotate("text", x = 1, y = 5, label = total_eq, color = industry_colors[pair[1]], hjust = 0, size = 3) + 
    annotate("text", x = 1, y = 4.8, label = total_eq_simpl, color = industry_colors[pair[1]], hjust = 0, size = 3)
  
  # Store plot and results
  plots[[paste(pair, collapse = " vs ")]] <- p
  ancova_results[[paste(pair, collapse = " vs ")]] <- summary(ancova_model)
  
  #cat("\nThe model terms: ")
  #print(terms(ancova_model))
}

# Display all plots in a 2x2 grid
do.call(grid.arrange, c(plots, ncol = 2, nrow = 2))

# Print ANCOVA results
for (pair in names(ancova_results)) {
  cat("ANCOVA Results for:", pair, "\n")
  print(ancova_results[[pair]])
  cat("\n")
}



