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
data = data[data['AverageNeighborDistance'] != 'ERROR']
data['AverageNeighborDistance'] = data['AverageNeighborDistance'].astype(float)

# Calculate statistics
mean_distance = data['AverageNeighborDistance'].mean()
median_distance = data['AverageNeighborDistance'].median()
std_distance = data['AverageNeighborDistance'].std()
min_distance = data['AverageNeighborDistance'].min()
max_distance = data['AverageNeighborDistance'].max()

# Define a threshold for success
success_threshold = 60.0  # Example threshold value (adjust as needed)
success_rate = (data['AverageNeighborDistance'] <= success_threshold).mean() * 100

# Plot the average neighbor distances
plt.figure(figsize=(10, 6))
plt.plot(data['Simulation'], data['AverageNeighborDistance'], marker='o', linestyle='-', color='b', label='Average Neighbor Distance')
plt.title('Average Neighbor Distance Over Simulations')
plt.xlabel('Simulation')
plt.ylabel('Average Neighbor Distance')
plt.grid(True)
plt.axhline(mean_distance, color='r', linestyle='--', label=f'Mean: {mean_distance:.2f}')
plt.axhline(median_distance, color='g', linestyle='--', label=f'Median: {median_distance:.2f}')
plt.axhline(success_threshold, color='y', linestyle='--', label=f'Success Threshold: {success_threshold:.2f}')
plt.legend()
plt.tight_layout()

# Save the plot
plt.savefig('results/average_neighbor_distance_plot.png')

# Show the plot
plt.show()

# Histogram of average neighbor distances
plt.figure(figsize=(10, 6))
plt.hist(data['AverageNeighborDistance'], bins=20, color='c', edgecolor='k', alpha=0.7)
plt.title('Histogram of Average Neighbor Distances')
plt.xlabel('Average Neighbor Distance')
plt.ylabel('Frequency')
plt.axvline(mean_distance, color='r', linestyle='--', label=f'Mean: {mean_distance:.2f}')
plt.axvline(median_distance, color='g', linestyle='--', label=f'Median: {median_distance:.2f}')
plt.legend()
plt.tight_layout()

# Save the histogram
plt.savefig('results/average_neighbor_distance_histogram.png')

# Show the histogram
plt.show()

# Group data by hyperparameter sets and compute mean performance
grouped_data = data.groupby(['MAX_VELOCITY', 'ALPHA', 'BETA', 'S', 'W']).agg(
    MeanAverageNeighborDistance=('AverageNeighborDistance', 'mean')).reset_index()

# Identify the best performing set
best_performance = grouped_data.loc[grouped_data['MeanAverageNeighborDistance'].idxmin()]

# Print the best performing set
print("Best performing hyperparameters:")
print(best_performance)

# Prepare y_labels with multi-line formatting
y_labels = grouped_data.apply(lambda row: f'V:{row.MAX_VELOCITY}, A:{row.ALPHA}, B:{row.BETA}, S:{row.S}, W:{row.W}', axis=1)

# Plot the performance of each hyperparameter set
plt.figure(figsize=(20, 14))  # Increase the width and height for better readability
grouped_data_sorted = grouped_data.sort_values(by='MeanAverageNeighborDistance', ascending=True)

# Create a barh plot with labels and highlight the best performance
bars = plt.barh(grouped_data_sorted.index, grouped_data_sorted['MeanAverageNeighborDistance'], color='b', alpha=0.7)
plt.axvline(best_performance['MeanAverageNeighborDistance'], color='r', linestyle='--', label=f'Best Performance: {best_performance["MeanAverageNeighborDistance"]:.2f}')
plt.yticks(grouped_data_sorted.index, y_labels)
plt.xticks(rotation=45)
plt.title('Performance of Hyperparameter Sets')
plt.xlabel('Mean Average Neighbor Distance')
plt.ylabel('Hyperparameter Sets')
plt.legend()
plt.grid(axis='x', linestyle='--', alpha=0.7)

# Make the first bar label bold
bars[0].set_color('red')
bars[0].set_label('Best Hyperparameter Set')
for label in plt.gca().get_yticklabels():
    if label.get_text() == y_labels.iloc[0]:
        label.set_fontweight('bold')

plt.tight_layout()

# Save the bar plot
plt.savefig('results/hyperparameter_performance.png')

# Show the bar plot
plt.show()

# Save the grouped data to a CSV file for further analysis
grouped_data.to_csv('results/grouped_performance.csv', index=False)
print('Grouped performance data saved to results/grouped_performance.csv')

# Perform the Mann-Whitney U Test
group1 = data[data['Seed'] % 2 == 0]['AverageNeighborDistance']
group2 = data[data['Seed'] % 2 != 0]['AverageNeighborDistance']

# Check if the sample size is sufficient for the Mann-Whitney U test
if len(group1) < 20 or len(group2) < 20:
    print("Sample size is too small for Mann-Whitney U test. Skipping the test.")
else:
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
        'Mean AverageNeighborDistance': [group1.mean(), group2.mean()],
        'Median AverageNeighborDistance': [group1.median(), group2.median()],
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
    plt.boxplot([group1, group2], tick_labels=['Even Seeds', 'Odd Seeds'])
    plt.title('Boxplot of Average Neighbor Distance by Seed Group')
    plt.xlabel('Group')
    plt.ylabel('Average Neighbor Distance')
    plt.tight_layout()

    # Save the boxplot
    plt.savefig('results/average_neighbor_distance_boxplot.png')

    # Show the boxplot
    plt.show()
