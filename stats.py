import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import pandas as pd
from scipy.stats import chi2

averages_data = pd.read_csv("averages.csv")

# Perform a log transformation on the new survival rates to account for the 1/x nature
averages_data['log_Avg_Survival_Rate'] = np.log(averages_data['Avg_Survival_Rate'])

# Fit a Linear Mixed Model with Year_After_Establishment as the fixed effect and Industry as the random effect
lin_mix_model = smf.mixedlm(formula="log_Avg_Survival_Rate ~ Year_After_Establishment + Year_After_Establishment * "
                                    "Industry",
                            data=averages_data,
                            groups=averages_data["Industry"]).fit()

# Create a plot for the average survival rates for each industry over time
plt.figure(figsize=(10, 6))
sns.lineplot(x='Year_After_Establishment', y='Avg_Survival_Rate', hue='Industry', data=averages_data, legend=True)
plt.title('Average Business Survival Rates by Industry Over Time')
plt.xlabel('Years After Establishment')
plt.ylabel('Average Survival Rate (%)')
plt.grid(True)
plt.legend(title='Industry', bbox_to_anchor=(1.05, 1), loc='upper left')

plt.tight_layout()

# Show the plot
plt.show()

# Display the summary of the new LMM result
print(lin_mix_model.summary())

print("Fixed effect:")
print(lin_mix_model.params)

print("Random effect:")
print(lin_mix_model.random_effects)

# Create a plot for the log-transformed average survival rates for each industry over time
plt.figure(figsize=(10, 6))
sns.lineplot(x='Year_After_Establishment', y='log_Avg_Survival_Rate', hue='Industry', data=averages_data, legend=True)
plt.title('Log-Transformed Average Business Survival Rates by Industry Over Time')
plt.xlabel('Years After Establishment')
plt.ylabel('Log of Average Survival Rate')
plt.grid(True)
plt.legend(title='Industry', bbox_to_anchor=(1.05, 1), loc='upper left')

plt.tight_layout()

# Show the plot
plt.show()

# Likelihood Ratio Test to test if the random effect is significant

# Fit a simpler model without the random effect (only fixed effects)
lmm_fixed_only = smf.ols("log_Avg_Survival_Rate ~ Year_After_Establishment", data=averages_data).fit()

# Calculate the likelihood ratio statistic
lr_stat = 2 * (lin_mix_model.llf - lmm_fixed_only.llf)

# Calculate the degrees of freedom (difference in the number of parameters)
df_diff = lin_mix_model.df_modelwc - lmm_fixed_only.df_model

# Perform the likelihood ratio test
p_value = chi2.sf(lr_stat, df_diff)

# Return the test statistic and p-value
print(lr_stat, p_value)
