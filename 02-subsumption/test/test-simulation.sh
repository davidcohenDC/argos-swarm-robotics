#!/bin/bash

# Configuration
argos_executable="argos3"  # Path to ARGoS executable if not in PATH
argos_config_file="test-subs.argos"
num_simulations=10000
output_file="test/simulation_results.txt"
extract_value_string="f_distance"

cd ..

# Check if configuration file exists
if [ ! -f "$argos_config_file" ]; then
    echo "Error: Configuration file '$argos_config_file' not found."
    exit 1
fi

# Function to extract the last f_distance value from the simulation output
extract_distance() {
    echo "$1" | grep "$extract_value_string" | tail -n 1 | awk '{print $2}'
}

# Function to run a single simulation
run_simulation() {
    local i=$1
    echo "Running simulation $i/$num_simulations" >&2
    output=$($argos_executable -c "$argos_config_file" --no-visualization)

    # Extract the distance from the simulation output
    distance_to_light=$(extract_distance "$output")

    if [[ -n "$distance_to_light" ]]; then
        steps_taken=1000  # As per the fixed experiment length
        echo "$i,$steps_taken,$distance_to_light"
    else
        echo "$i,ERROR,ERROR"
        echo "Error parsing the distance." >&2
    fi
}

export -f run_simulation extract_distance
export argos_executable argos_config_file extract_value_string num_simulations

# Initialize the output file
echo "Simulation,Steps,DistanceToLight" > "$output_file"

# Run simulations in parallel and append results to the output file
parallel -j $(nproc) run_simulation {} ::: $(seq 1 $num_simulations) >> "$output_file"
