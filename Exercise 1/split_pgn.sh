#!/bin/bash

# Check if the number of arguments is exactly 2
check_valid_input() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 <source_pgn_file> <destination_directory>"
        exit 1
    fi
}

# Check if the source file exists
check_file_exist() {
    if [ ! -e "$input_file" ]; then
        echo "Error: File '$input_file' does not exist."
        exit 1
    fi
}

# Check if the destination directory exists, and create it if it doesn't
create_dest_dir() {
    if [ ! -d "$dest_dir" ]; then
        echo "Created directory '$dest_dir'."
        mkdir -p "$dest_dir"
    fi
}

# Split the source file into multiple files
split_pgn_file() {
    local game_count=0
    local game_file=""
    local in_game=0
    local game_content=""
    local base_filename=$(basename "$input_file" .pgn) # Get the base filename without extension

    # Read the source PGN file line by line
    while IFS= read -r line; do
        # If the line starts with [Event ", start a new game file
        if [[ $line =~ ^\[Event\ \" ]]; then
            if [[ $in_game -eq 1 ]]; then
                game_file="${dest_dir}/${base_filename}_${game_count}.pgn" # Construct the filename
                echo -e "$game_content" > "$game_file"
                echo "Saved game to $game_file"
                game_content=""
            fi
            in_game=1
            game_count=$((game_count + 1))
        fi
        
        # Accumulate the content of the current game
        if [[ $in_game -eq 1 ]]; then
            game_content+="$line"$'\n'
        fi
    done < "$input_file"
    
    # Save the last game
    if [[ $in_game -eq 1 ]]; then
        game_file="${dest_dir}/${base_filename}_${game_count}.pgn" # Construct the filename
        echo -e "$game_content" > "$game_file"
        echo "Saved game to $game_file"
    fi
    
    echo "All games have been split and saved to '$dest_dir'."
}

# Check if the number of arguments is exactly 2
check_valid_input "$@"

# Assign the arguments to variables
input_file=$1
dest_dir=$2

# Check if the source file exists
check_file_exist

# Create the destination directory if it does not exist
create_dest_dir

# Split the PGN file into individual game files
split_pgn_file
