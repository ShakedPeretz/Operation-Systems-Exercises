#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define SIZE 100
#define HISTORY_SIZE 100
#define PWD_SIZE 1024

void pwd(char **args)
{
    char cwd[PWD_SIZE];
    if (getcwd(cwd, sizeof(cwd)) == NULL)
        perror("getcwd() error");
    else
        printf("%s\n", cwd);
}

void getUserInput(char *input)
{
    printf("$ ");
    fflush(stdout);
    fgets(input, SIZE, stdin);
    input[strcspn(input, "\n")] = '\0'; // Remove the newline character
}

void history(char historyData[HISTORY_SIZE][SIZE], int historyCount)
{
    for (int i = 0; i < historyCount; ++i)
    {
        printf("%d %s\n", i + 1, historyData[i]);
    }
}

void cd(char **args){
    char cwd[SIZE];

    if (args[1] == NULL || strcmp(args[1], "~") == 0) {
        // Change to the home directory
        char *home = getenv("HOME");
        if (home != NULL) {
            if (chdir(home) != 0) {
                perror("chdir failed");
            } else {
                setenv("OLDPWD", getenv("PWD"), 1);
                setenv("PWD", home, 1);
            }
        } else {
            fprintf(stderr, "cd: HOME environment variable not set\n");
        }
    } else if (strcmp(args[1], "-") == 0) {
        // Change to the previous directory
        char *oldpwd = getenv("OLDPWD");
        if (oldpwd != NULL) {
            if (getcwd(cwd, sizeof(cwd)) == NULL) {
                perror("getcwd failed");
                return;
            }

            if (chdir(oldpwd) != 0) {
                perror("chdir failed");
            } else {
                printf("%s\n", oldpwd);
                setenv("OLDPWD", cwd, 1);
                setenv("PWD", oldpwd, 1);
            }
        } else {
            fprintf(stderr, "cd: OLDPWD environment variable not set\n");
        }
    } else if (strcmp(args[1], "..") == 0) {
        // Change to the parent directory
        if (getcwd(cwd, sizeof(cwd)) == NULL) {
            perror("getcwd failed");
            return;
        }

        if (chdir("..") != 0) {
            perror("chdir failed");
        } else {
            setenv("OLDPWD", cwd, 1);
            if (getcwd(cwd, sizeof(cwd)) != NULL) {
                setenv("PWD", cwd, 1);
            } else {
                perror("getcwd failed");
            }
        }
    } else if (strcmp(args[1], ".") == 0) {
        // Stay in the current directory (do nothing)
    } else {
        // Change to the specified directory
        if (getcwd(cwd, sizeof(cwd)) == NULL) {
            perror("getcwd failed");
            return;
        }

        if (chdir(args[1]) != 0) {
            perror("chdir failed");
        } else {
            setenv("OLDPWD", cwd, 1);
            if (getcwd(cwd, sizeof(cwd)) != NULL) {
                setenv("PWD", cwd, 1);
            } else {
                perror("getcwd failed");
            }
        }
    }
}

int main()
{
    char input[SIZE];
    char *command;
    char *arguments[SIZE];
    char historyData[HISTORY_SIZE][SIZE];
    int historyCount = 0;

    while (1)
    {
        getUserInput(input);

        // Store the command in history
        if (historyCount < HISTORY_SIZE)
        {
            strcpy(historyData[historyCount], input);
            historyCount++;
        }
        else
        {
            // Optional: Handle the case where history is full, e.g., by shifting elements
        }

        // Parse the command and arguments
        command = strtok(input, " ");
        int i = 0;
        while (command != NULL && i < SIZE)
        {
            arguments[i++] = command;
            command = strtok(NULL, " ");
        }
        arguments[i] = NULL; // Null-terminate the arguments array
        command = arguments[0];

        // Command handling
        if (strcmp(command, "cd") == 0)
        {
            cd(arguments);
        }
        else if (strcmp(command, "pwd") == 0)
        {
            pwd(arguments);
        }
        else if (strcmp(command, "exit") == 0)
        {
        }
        else if (strcmp(command, "history") == 0)
        {
            history(historyData, historyCount);
        }
        else
        {
            // Handle other commands using fork and exec
        }
    }

    return 0;
}
