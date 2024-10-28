# data_preprocessing.R
# Load necessary libraries
#install.packages(c("lme4", "lmtest", "ggplot2", "dplyr", "readr", "gridExtra"))
library(readr)
library(dplyr)

# Load data
averages_data <- read_csv("PycharmProjects/bs/averages.csv")
averages_data_with_total <- read_csv("PycharmProjects/bs/averages_with_total.csv")

# Remove ".txt" suffix from industry names
averages_data$Industry <- gsub("\\.txt$", "", averages_data$Industry)
averages_data_with_total$Industry <- gsub("\\.txt$", "", averages_data_with_total$Industry)

# Remove "_table7" suffix from industry names
averages_data$Industry <- gsub("\\_table7$", "", averages_data$Industry)
averages_data_with_total$Industry <- gsub("\\_table7$", "", averages_data_with_total$Industry)

# Perform log transformation of the average survival rate
averages_data$log_Avg_Survival_Rate <- log(averages_data$Avg_Survival_Rate)
averages_data_with_total$log_Avg_Survival_Rate <- log(averages_data_with_total$Avg_Survival_Rate)

# Display the first few rows of the datasets
# head(averages_data)
# head(averages_data_with_total)

# Define industry pairs to be compared
industry_pairs <- list(
  c("TOTAL", "utilities"),
  c("TOTAL", "management"),
  c("TOTAL", "information"),
  c("TOTAL", "agriculture")
)

set_reference <- function(data, ref_level = "TOTAL") {
  data$Industry <- factor(data$Industry)
  data$Industry <- relevel(data$Industry, ref = ref_level)
  return(data)
}

averages_data_with_total <- set_reference(averages_data_with_total)