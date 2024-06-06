#include <stdio.h>
#include <string.h>

#define SIZE 100

void history() {}

void cd(char *arguments) {}

void pwd(char *arguments) {}

void exit(char *arguments) {}

void getUserInput(char *input, char **command, char **arguments)
{
    fgets(input, SIZE, stdin);
    input[strcspn(input, "\n")] = 0; // Remove trailing newline

    *command = strtok(input, " ");

    int i = 0;

    char *token = strtok(NULL, " ");
    while (token != NULL)
    {
        arguments[i] = token;
        i++;
        token = strtok(NULL, " ");
    }

    // Null terminate the arguments array
    arguments[i] = NULL;

    // Print the command and arguments
    printf("Command: %s\n", *command);
    printf("Arguments:\n");
    for (int j = 0; j < i; j++)
    {
        printf("%s\n", arguments[j]);
    }
}

int main()
{
    char input[SIZE];
    char *arguments[SIZE];
    char *command;

    while (1)
    {
        getUserInput(input, &command, arguments);

        if (strcmp(command, "history") == 0)
        {
            history(&arguments);
        }
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
            exit(&arguments);
        }
        else
        {
            // Handle other commands using fork and exec
            printf("Executing command: %s\n", command);
        }
    }

    return 0;
}