import os
import matplotlib.pyplot as plt
import pandas as pd
from scipy.stats import mannwhitneyu

# Read the simulation results
results_file = 'results/simulation_results.txt'

# Change directory to be in the test folder if not already
if os.getcwd().split('/')[-1].lower().count('test') == 0:
    os.chdir('test')

data = pd.read_csv(results_file)

# Filter out rows with errors
data = data[data['DistanceToLight'] != 'ERROR']
data['DistanceToLight'] = data['DistanceToLight'].astype(float)

# Calculate statistics
mean_distance = data['DistanceToLight'].mean()
median_distance = data['DistanceToLight'].median()
std_distance = data['DistanceToLight'].std()
min_distance = data['DistanceToLight'].min()
max_distance = data['DistanceToLight'].max()

# Define a threshold for success
success_threshold = 1.0  # Example threshold value
success_rate = (data['DistanceToLight'] <= success_threshold).mean() * 100

# Plot the distances
plt.figure(figsize=(10, 6))
plt.plot(data['Simulation'], data['DistanceToLight'], marker='o', linestyle='-', color='b', label='Distance')
plt.title('Distance to Light Over Simulations')
plt.xlabel('Simulation')
plt.ylabel('Distance to Light')
plt.grid(True)
plt.axhline(mean_distance, color='r', linestyle='--', label=f'Mean: {mean_distance:.2f}')
plt.axhline(median_distance, color='g', linestyle='--', label=f'Median: {median_distance:.2f}')
plt.axhline(success_threshold, color='y', linestyle='--', label=f'Success Threshold: {success_threshold:.2f}')
plt.legend()
plt.tight_layout()

# Save the plot
plt.savefig('results/distance_plot.png')

# Show the plot
plt.show()

# Histogram of distances
plt.figure(figsize=(10, 6))
plt.hist(data['DistanceToLight'], bins=20, color='c', edgecolor='k', alpha=0.7)
plt.title('Histogram of Distances to Light')
plt.xlabel('Distance to Light')
plt.ylabel('Frequency')
plt.axvline(mean_distance, color='r', linestyle='--', label=f'Mean: {mean_distance:.2f}')
plt.axvline(median_distance, color='g', linestyle='--', label=f'Median: {median_distance:.2f}')
plt.legend()
plt.tight_layout()

# Save the histogram
plt.savefig('results/distance_histogram.png')

# Show the histogram
plt.show()

# Perform the Mann-Whitney U Test
group1 = data[data['Seed'] % 2 == 0]['DistanceToLight']
group2 = data[data['Seed'] % 2 != 0]['DistanceToLight']

stat, p_value = mannwhitneyu(group1, group2)

# Print the results
print(f'Mann-Whitney U Test Statistic: {stat}')
print(f'P-value: {p_value}')

# Interpret the result
alpha = 0.05
if p_value < alpha:
    result = 'Reject the null hypothesis - there is a significant difference between the groups.'
else:
    result = 'Fail to reject the null hypothesis - there is no significant difference between the groups.'
print(result)

# Create a DataFrame for the results
results_df = pd.DataFrame({
    'Group': ['Even Seeds', 'Odd Seeds'],
    'Count': [len(group1), len(group2)],
    'Mean DistanceToLight': [group1.mean(), group2.mean()],
    'Median DistanceToLight': [group1.median(), group2.median()],
    'Mann-Whitney U Test Statistic': [stat, ''],
    'P-value': [p_value, ''],
    'Result': [result, '']
})

# Save the results table
results_table_file = 'results/statistical_analysis_results.csv'
results_df.to_csv(results_table_file, index=False)
print(f'Statistical analysis results saved to {results_table_file}')

# Plot the results of the Mann-Whitney U Test
plt.figure(figsize=(10, 6))
plt.boxplot([group1, group2], labels=['Even Seeds', 'Odd Seeds'])
plt.title('Boxplot of Distance to Light by Seed Group')
plt.xlabel('Group')
plt.ylabel('Distance to Light')
plt.tight_layout()

# Save the boxplot
plt.savefig('results/distance_to_light_boxplot.png')

# Show the boxplot
plt.show()
