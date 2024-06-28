#!/bin/bash

# Configuration
argos_executable="argos3"  # Path to ARGoS executable if not in PATH
argos_config_template="./test/aggregation_template.argos"
argos_config_file="./test/results/aggregation.argos"
num_simulations=1
output_file="./test/results/simulation_results.txt"
extract_value_string="Average Neighbor Distance:"

cd ..
mkdir -p test/results

# Check if template configuration file exists
if [ ! -f "$argos_config_template" ]; then
    echo "Error: Template configuration file '$argos_config_template' not found."
    exit 1
fi

# Parse command-line arguments for number of simulations and length
while getopts "n:" opt; do
    case $opt in
        n)
            num_simulations=$OPTARG
            ;;
        *)
            echo "Usage: $0 [-n num_simulations] [-l length]"
            exit 1
            ;;
    esac
done


# Function to extract the Average Neighbor Distance from the simulation output
extract_average_neighbor_distance() {
    echo "$1" | grep "$extract_value_string" | awk '{print $4}'
}

# Function to run a single simulation
run_simulation() {
    local i=$1
    local max_velocity=$2
    local alpha=$3
    local beta=$4
    local s=$5
    local w=$6
    local seed=$7
    echo "Running simulation $i with MAX_VELOCITY=$max_velocity, ALPHA=$alpha, BETA=$beta, S=$s, W=$w, SEED=$seed" >&2
    local unique_config_file="./test/results/aggregation_$i.argos"

    # Generate a unique configuration file for each simulation
    sed "s/random_seed=\"PLACEHOLDER\"/random_seed=\"$seed\"/g" "./test/aggregation_template.argos" > $unique_config_file

    # Debugging: Ensure the configuration file is created and has content
    if [ ! -s "$unique_config_file" ]; then
        echo "Error: Configuration file '$unique_config_file' is empty or does not exist."
        exit 1
    fi


#    Set the environment variable for the configuration file
    export ARGOS_CONFIG_FILE="$unique_config_file"
    export ALPHA=$alpha
    export BETA=$beta
    export S=$s
    export W=$w

    output=$($argos_executable -c $unique_config_file --no-visualization | sed 's/\x1B\[[0-9;]*[JKmsu]//g')

    # Collect all average neighbor distances for this simulation
    distances=()
    while read -r line; do
        if [[ "$line" == "$extract_value_string"* ]]; then
            distances+=($(echo "$line" | awk '{print $4}'))
        fi
    done <<< "$output"

    # Calculate the overall average distance for this simulation
    if [ ${#distances[@]} -ne 0 ]; then
        total_distance=0
        for distance in "${distances[@]}"; do
            total_distance=$(echo "$total_distance + $distance" | bc)
        done
        overall_average_distance=$(echo "scale=2; $total_distance / ${#distances[@]}" | bc)
        echo "$i,$overall_average_distance,$seed,$max_velocity,$alpha,$beta,$s,$w" >> "./test/results/simulation_results.txt"
    else
        echo "$i,ERROR,$seed,$max_velocity,$alpha,$beta,$s,$w" >> "$output_file"
        echo "Error parsing the average neighbor distance for simulation $i." >&2
    fi

    # Clean up the unique configuration file
    rm "$unique_config_file"
}

export -f run_simulation extract_average_neighbor_distance
export argos_executable argos_config_file extract_value_string num_simulations

# Initialize the output file
# Initialize the output file
echo "Simulation,AverageNeighborDistance,Seed,MAX_VELOCITY,ALPHA,BETA,S,W"  > "./test/results/simulation_results.txt"

## Run simulations in parallel and append results to the output file
#parallel -j $(nproc) run_simulation {} ::: $(seq 1 $num_simulations) >> "./test/results/simulation_results.txt"

# Define hyperparameter ranges
max_velocity_range=(15)
alpha_range=(0.05 0.1 0.15)
beta_range=(0.03 0.05 0.07)
s_range=(0.01 0.02 0.03)
w_range=(0.05 0.1 0.15)

# Generate a list of all parameter combinations
combinations=()
for max_velocity in "${max_velocity_range[@]}"; do
    for alpha in "${alpha_range[@]}"; do
        for beta in "${beta_range[@]}"; do
            for s in "${s_range[@]}"; do
                for w in "${w_range[@]}"; do
                    combinations+=("$max_velocity,$alpha,$beta,$s,$w")
                done
            done
        done
    done
done

echo "Total number of simulations: $((num_simulations * ${#combinations[@]}))"
# Set the initial simulation index
simulation_index=1

# Run simulations in parallel for each combination
for simulation in $(seq 1 $num_simulations); do
  seed=$(shuf -i 0-100000 -n 1)
  for combination in "${combinations[@]}"; do
        parallel -j $(nproc) run_simulation {#} $(echo $combination | awk -F',' '{print $1,$2,$3,$4,$5}') $seed ::: $(seq 1 $num_simulations)
  done
done


# Wait for all the parallel processes to finish
wait



# Run the Python script to analyze the results
python3 test/analyze_results.py
