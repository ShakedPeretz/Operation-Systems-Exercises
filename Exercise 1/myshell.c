#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define SIZE 100
#define HISTORY_SIZE 100

void getUserInput(char *input) {
    printf("$ ");
    fflush(stdout);
    fgets(input, SIZE, stdin);
    input[strcspn(input, "\n")] = '\0';  // Remove the newline character
}

void history(char historyData[HISTORY_SIZE][SIZE], int historyCount) {
    for (int i = 0; i < historyCount; ++i) {
        printf("%d %s\n", i + 1, historyData[i]);
    }
}

void cd(char **path){
    




}




int main() {
    char input[SIZE];
    char *command;
    char *arguments[SIZE];
    char historyData[HISTORY_SIZE][SIZE];
    int historyCount = 0;

    while (1) {
        getUserInput(input);

        // Store the command in history
        if (historyCount < HISTORY_SIZE) {
            strcpy(historyData[historyCount], input);
            historyCount++;
        } else {
            // Optional: Handle the case where history is full, e.g., by shifting elements
        }

        // Parse the command and arguments
        command = strtok(input, " ");
        int i = 0;
        while (command != NULL && i < SIZE) {
            arguments[i++] = command;
            command = strtok(NULL, " ");
        }
        arguments[i] = NULL;  // Null-terminate the arguments array
        command = arguments[0];

        // Command handling
        if (strcmp(command, "cd") == 0) {
            cd(arguments);
        } else if (strcmp(command, "pwd") == 0) {
            // Implement and call pwd() function
            printf("pwd command executed\n");
        } else if (strcmp(command, "exit") == 0) {


        } else if (strcmp(command, "history") == 0) {
            history(historyData, historyCount);
        } else {
            // Handle other commands using fork and exec
        }
    }

    return 0;
}

