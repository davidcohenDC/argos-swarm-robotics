#!/bin/bash

# Configuration
argos_executable="argos3"  # Path to ARGoS executable if not in PATH
argos_config_template="./test/aggregation_template.argos"
argos_config_file="./test/results/aggregation.argos"
num_simulations=10
output_file="./test/results/simulation_results.txt"
extract_value_string="Distance:"

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
# Function to extract the last Distance value from the simulation output
extract_distance() {
    echo "$1" | grep "$extract_value_string" | tail -n 1 | awk '{print $2}'
}

# Function to run a single simulation
run_simulation() {
    local i=$1
    echo "Running simulation $i/$num_simulations" >&2
    local seed=$(shuf -i 0-100000 -n 1)
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

    output=$($argos_executable -c $unique_config_file --no-visualization | sed 's/\x1B\[[0-9;]*[JKmsu]//g')

    # Extract the distance from the simulation output
    distance_to_light=$(extract_distance "$output")

    if [[ -n "$distance_to_light" ]]; then
        steps_taken=1000  # As per the fixed experiment length
        echo "$i,$steps_taken,$distance_to_light,$seed"
    else
        echo "$i,ERROR,ERROR,$seed"
        echo "Error parsing the distance for simulation $i." >&2
    fi

    rm $unique_config_file
}

export -f run_simulation extract_distance
export argos_executable argos_config_file extract_value_string num_simulations

# Initialize the output file
echo "Simulation,Steps,DistanceToLight,Seed" > "$output_file"

# Run simulations in parallel and append results to the output file
parallel -j $(nproc) run_simulation {} ::: $(seq 1 $num_simulations) >> "$output_file"

# Wait for all the parallel processes to finish
wait

# Run the Python script to analyze the results
python3 test/analyze_results.py
