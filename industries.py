import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import re
import os

pd.set_option('display.max_rows', 500)
pd.set_option('display.max_columns', 500)


# Folder containing the files
folder_path = '/Users/ha/PycharmProjects/bs/data'

# Define columns for the data
columns = ['Industry', 'Establishment_Year', 'Year_After_Establishment', 'Surviving_Establishments', 'Total_Employment',
           'Survival_Rate_Since_Birth', 'Survival_Rate_Prev_Year', 'Avg_Employment']


# Function to process a single file and extract data
def process_file(file_path_input, file_name_input):
    data = []
    current_establishment_year = None
    industry_name = None

    with open(file_path_input, 'r') as file:
        for line in file:
            # Detect the industry name (appears after the "Table 7." line)
            industry_match = re.match(r'^\s*(\w.*\w)\s*$', line)
            if industry_match and not industry_name:
                industry_name = file_name_input  # Extract industry name

            # Detect the new establishment year block (e.g., "Year ended: March 1994")
            establishment_year_match = re.match(r'\s*Year\s+ended:\s+March\s+(\d{4})', line)
            if establishment_year_match:
                current_establishment_year = int(establishment_year_match.group(1))  # Set the new establishment year

            # Match lines that start with a month-year pair and capture the survival data
            if current_establishment_year:
                match = re.match(r'\s*March\s+(\d{4})\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)\s+([_\d.]+)?\s+([\d.]+)', line)
                if match:
                    recorded_year = int(match.group(1))  # Year in which survival data is recorded
                    year_after_establishment = recorded_year - current_establishment_year  # Calculate years after establishment
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

                    # Append data with establishment year, years after establishment, and industry name
                    data.append(
                        [industry_name, current_establishment_year, year_after_establishment, surviving_establishments,
                         total_employment, survival_rate_since_birth, survival_rate_prev_year, avg_employment])

    return data


# List to store all data
all_data = []

# Loop through each file in the folder and process it
for file_name in os.listdir(folder_path):
    if file_name.endswith(".txt"):  # Adjust the extension if necessary
        file_path = os.path.join(folder_path, file_name)
        file_data = process_file(file_path, file_name)
        all_data.extend(file_data)  # Add the processed data to the overall list

# Convert the data to a pandas DataFrame
df = pd.DataFrame(all_data, columns=columns)

# This drops the unnecessary columns
df = df.drop(columns=['Surviving_Establishments', 'Total_Employment', 'Avg_Employment'])

# Let's save the df as a CSV for future use
output_csv_path = 'processed_data.csv'  # Update the path as needed
df.to_csv(output_csv_path, index=False)

print(f"Data successfully saved to {output_csv_path}")

data = pd.read_csv("processed_data.csv")

data = data[data['Industry'] != 'TOTAL.txt']

# Group the data by 'Industry' and 'Year_After_Establishment' and calculate the average survival rate
grouped_data = data.groupby(['Industry', 'Year_After_Establishment']).agg(
    Avg_Survival_Rate=('Survival_Rate_Since_Birth', 'mean')
).reset_index()

# Save the grouped data to CSV
grouped_data.to_csv("averages.csv", index=False)

# Now group by industry and years after establishment to calculate the average survival rate for each industry
industry_avg = df.groupby(['Industry', 'Year_After_Establishment'])['Survival_Rate_Since_Birth'].mean().reset_index()

industry_avg = industry_avg[industry_avg['Industry'] != 'TOTAL.txt']

# Plotting the average survival rates over time for each industry
plt.figure(figsize=(10, 6))

colors = cm.get_cmap('tab20')

# Group by industry and plot each group's average survival rate over time
for idx, (industry, group) in enumerate(industry_avg.groupby('Industry')):
    plt.plot(group['Year_After_Establishment'], group['Survival_Rate_Since_Birth'], marker='o', label=industry,
             color=colors(idx % 20))  # Use colors from tab20 colormap


plt.xlabel('Years After Establishment')
plt.ylabel('Average Survival Rate (%)')
plt.title('Average Business Survival Rate Over Time by Industry')

# Move the legend to the bottom
plt.legend(loc='upper center', bbox_to_anchor=(0.5, -0.15), ncol=4)

plt.grid(True)
plt.xticks()
plt.tight_layout()

# Display the plot
plt.show()

# Display a sample of the organized data
print(industry_avg)
