#!/bin/bash

# Initialize the board as an associative array
declare -A board

# Array to store board states
declare -a board_states

# Variable to store the initial board state
declare -A init_board

# Global counter for moves
counter=0

# Function to create the board with initial positions
create_board() {
    # Set initial positions for white pieces (lowercase)
    board[0,0]='r'; board[0,1]='n'; board[0,2]='b'; board[0,3]='q'; board[0,4]='k'; board[0,5]='b'; board[0,6]='n'; board[0,7]='r'
    board[1,0]='p'; board[1,1]='p'; board[1,2]='p'; board[1,3]='p'; board[1,4]='p'; board[1,5]='p'; board[1,6]='p'; board[1,7]='p'
    
    # Set initial positions for black pieces (uppercase)
    board[6,0]='P'; board[6,1]='P'; board[6,2]='P'; board[6,3]='P'; board[6,4]='P'; board[6,5]='P'; board[6,6]='P'; board[6,7]='P'
    board[7,0]='R'; board[7,1]='N'; board[7,2]='B'; board[7,3]='Q'; board[7,4]='K'; board[7,5]='B'; board[7,6]='N'; board[7,7]='R'
    
    # Fill the rest of the board with dots (empty spaces)
    for ((i=2; i<6; i++)); do
        for ((j=0; j<8; j++)); do
            board[$i,$j]='.'
        done
    done

    # Save the initial board state
    save_initial_board_state
}

# Function to save the initial board state
save_initial_board_state() {
    for ((i=0; i<8; i++)); do
        for ((j=0; j<8; j++)); do
            init_board[$i,$j]=${board[$i,$j]}
        done
    done
}

# Function to save the current board state
save_board_state() {
    local board_state=""
    for ((i=0; i<8; i++)); do
        for ((j=0; j<8; j++)); do
            board_state+="${board[$i,$j]}"
        done
    done
    board_states[$counter]=$board_state
}

# Function to load the initial board state
load_initial_board_state() {
    for ((i=0; i<8; i++)); do
        for ((j=0; j<8; j++)); do
            board[$i,$j]=${init_board[$i,$j]}
        done
    done
}

# Function to load a board state
load_board_state() {
    local board_state=${board_states[$1]}
    local index=0
    for ((i=0; i<8; i++)); do
        for ((j=0; j<8; j++)); do
            board[$i,$j]=${board_state:$index:1}
            ((index++))
        done
    done
}

# Function to print the chessboard
print_chessboard() {
    echo "  a b c d e f g h"
    for ((i=0; i<8; i++)); do
        echo -n "$((8 - i)) "
        for ((j=0; j<8; j++)); do
            echo -n "${board[$i,$j]}  "
        done
        echo "$((8 - i))"
    done
    echo "  a b c d e f g h"
}

# # Function to move a piece based on UCI move
# move_step_forward() {
#     # Get the move from the UCI moves array
#     echo "Counter: $counter, Total Moves: ${#moves[@]}, Move $counter: ${moves[$counter]}"
#     current_move=${moves[counter-1]}

#     # Get the starting and ending positions from the move
#     start_pos=${current_move:0:2}
#     end_pos=${current_move:2:2}

#     # Get the row and column indices for the starting and ending positions
#     start_row=$((8 - ${start_pos:1:1}))
#     start_col=$(echo ${start_pos:0:1} | tr 'a-h' '0-7')
#     end_row=$((8 - ${end_pos:1:1}))
#     end_col=$(echo ${end_pos:0:1} | tr 'a-h' '0-7')

#     # Get the piece at the starting position
#     piece=${board[$start_row,$start_col]}

#     # Move the piece to the ending position
#     board[$end_row,$end_col]=$piece
#     board[$start_row,$start_col]='.'
#     # Save the new board state
#     save_board_state
# }

# calculate_all_board_states() {
#     # Save the initial board state at index 1
#     save_board_state
    
#     # Start the counter from 1 to calculate board states from move 1
#     for ((counter = 0; counter < ${#moves[@]}; counter++)); do
#         move_step_forward $counter
#     done
# }






calculate_all_board_states() {
    save_board_state
    
    # Start the counter from 0 to calculate board states from move 0
    counter=0
    while (( counter < ${#moves[@]} )); do
        # Get the move from the UCI moves array
        echo "Counter: $counter, Total Moves: ${#moves[@]}, Move $counter: ${moves[$counter]}"
        current_move=${moves[counter]}

        # Get the starting and ending positions from the move
        start_pos=${current_move:0:2}
        end_pos=${current_move:2:2}

        # Get the row and column indices for the starting and ending positions
        start_row=$((8 - ${start_pos:1:1}))
        start_col=$(echo ${start_pos:0:1} | tr 'a-h' '0-7')
        end_row=$((8 - ${end_pos:1:1}))
        end_col=$(echo ${end_pos:0:1} | tr 'a-h' '0-7')

        # Get the piece at the starting position
        piece=${board[$start_row,$start_col]}

        # Move the piece to the ending position
        board[$end_row,$end_col]=$piece
        board[$start_row,$start_col]='.'
        
        ((counter++))

        # Save the new board state
        save_board_state
    done
}








# Function to handle user input for game flow
game_flow() {
    echo "Metadata from PGN file:
    $description_file
    "

    echo "uci :$uci_moves"

    # Calculate all board states based on moves
    calculate_all_board_states
    counter=0 
    load_board_state $counter

    while true; do
        echo "Move $counter/${#moves[@]}"
        print_chessboard
        echo -n "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit: "
        read user_input

        case $user_input in
            d)  # Move forward
                if ((counter < ${#moves[@]})); then
                    ((counter++))
                    load_board_state $counter
                else
                    echo "Already at the last move."
                fi
                ;;
            a)  # Move backward
                if ((counter > 0)); then
                    ((counter--))
                    load_board_state $counter
                else
                    echo "Already at the first move."
                fi
                ;;
            w)  # Go to the start
                counter=0
                load_initial_board_state                
                ;;
            s)  # Go to the end
                counter=$((${#moves[@]}))
                load_board_state $counter
                ;;
            q)  # Quit
                echo "Exiting. End of game."
                break
                ;;
            *)  echo "Invalid input";;
        esac
    done
}



extract_description() {
    description_file=$(grep '^\[' "$pgn_file")
}

# Extract moves from the PGN file
extract_moves() {
    # Save only the moves without the description of the game
    pgn_moves=$(grep -v '^\[' "$1")

    # Parse the moves to UCI format
    uci_moves=$(python3 parse_moves.py "$pgn_moves")

    # Split the UCI moves into an array
    IFS=' ' read -r -a moves <<< "$uci_moves"
}

# Usage: pass the PGN file as an argument to the script
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <pgn_file>"
    exit 1
fi

pgn_file="$1"

# Initialize the board and extract moves
create_board
extract_description
extract_moves "$pgn_file"
# Start the game flow
game_flow
