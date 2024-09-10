import pandas as pd
import matplotlib.pyplot as plt
import re

pd.set_option('display.max_rows', 500)
pd.set_option('display.max_columns', 500)

# Load the data from the text file
file_path = '/Users/ha/PycharmProjects/bs/data/TOTAL.txt'

# Read the data into a dataframe, skipping header rows, adjust based on file structure
# Using fixed-width format as the data in your file appears to be in columns
columns = ['Year', 'Surviving_Establishments', 'Total_Employment', 'Survival_Rate_Since_Birth',
           'Survival_Rate_Prev_Year', 'Avg_Employment']

# Custom parsing logic for the structure of your file
data = []
current_establishment_year = None
with open(file_path, 'r') as file:
    for line in file:
        # Detect the new establishment year block (e.g., "Year ended: March 1994")
        establishment_year_match = re.match(r'\s*Year\s+ended:\s+March\s+(\d{4})', line)
        if establishment_year_match:
            current_establishment_year = int(establishment_year_match.group(1))  # Set the new establishment year

            # Insert the first point (year 0, 100% survival rate) for this establishment year
            # data.append([current_establishment_year, 0, None, None, 100.0, None, None])

        # Match lines that start with a month-year pair and capture the survival data
        if current_establishment_year:
            match = re.match(r'\s*March\s+(\d{4})\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)\s+([_\d.]+)?\s+([\d.]+)', line)
            if match:
                recorded_year = int(match.group(1))  # Year in which survival data is recorded
                year_after_establishment = recorded_year - current_establishment_year # Calculate years after establishment
                surviving_establishments = int(match.group(2).replace(',', ''))  # Surviving Establishments
                total_employment = int(match.group(3).replace(',', ''))  # Total Employment
                survival_rate_since_birth = float(match.group(4))  # Survival Rate Since Birth

                # Handle previous year survival, where some data might be missing (e.g., '_')
                try:
                    survival_rate_prev_year = float(match.group(5)) if match.group(5) and match.group(
                        5) != '_' else None
                except ValueError:
                    survival_rate_prev_year = None

                avg_employment = float(match.group(6))  # Average Employment

                # Append data with establishment year and years after establishment
                data.append(
                    [current_establishment_year, year_after_establishment, surviving_establishments, total_employment,
                     survival_rate_since_birth, survival_rate_prev_year, avg_employment])

# Convert the data to a pandas DataFrame
df = pd.DataFrame(data, columns=['Establishment_Year', 'Year_After_Establishment', 'Surviving_Establishments',
                                 'Total_Employment', 'Survival_Rate_Since_Birth', 'Survival_Rate_Prev_Year',
                                 'Avg_Employment'])

# Plotting the trends in survival rate since birth over time for each establishment year
plt.figure(figsize=(10, 6))

# Group by establishment year and plot each group's survival rate over time
for establishment_year, group in df.groupby('Establishment_Year'):
    plt.plot(group['Year_After_Establishment'], group['Survival_Rate_Since_Birth'], marker='o',
             label=f'Established in {establishment_year}')

plt.xlabel('Years After Establishment')
plt.ylabel('Survival Rate (%)')
plt.title('Business Survival Rate Over Time by Establishment Year')
# Move the legend to the bottom
plt.legend(loc='upper center', bbox_to_anchor=(0.5, -0.15), ncol=3)  # Adjust ncol for the number of columns in the legend

plt.grid(True)
plt.xticks()
plt.tight_layout()

# Display the plot
plt.show()

# Display a sample of the organized data
print(df)
