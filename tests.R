# tests.R
library(lmtest)

# 1. Fit the fixed-effects model (no random effects)
lmm_fixed_only <- lm(log_Avg_Survival_Rate ~ Year_After_Establishment, 
                     data = averages_data)

# 2. Perform Likelihood Ratio Test between the random intercepts model and the fixed model
lr_test_intercept <- lrtest(lin_mix_model, lmm_fixed_only)
cat("LRT between Fixed-Effects and Random Intercepts Model:\n")
print(lr_test_intercept)

# 3. Perform Likelihood Ratio Test between random intercepts and random slopes models
lr_test_slopes <- lrtest(lin_mix_model, lin_mix_model_slopes)
cat("LRT between Random Intercepts and Random Slopes Model:\n")
print(lr_test_slopes)

# 4. Fit the fixed-effects model for the 10-year restricted data
lmm_fixed_10_years <- lm(log_Avg_Survival_Rate ~ Year_After_Establishment, 
                         data = data_filtered)

# 5. Perform Likelihood Ratio Test between fixed-effects and random slopes models (10 years)
lr_test_10_years <- lrtest(lin_mix_model_slopes_10_years, lmm_fixed_10_years)
cat("LRT for Random Slopes Model (10 Years) vs. Fixed-Effects Model:\n")
print(lr_test_10_years)