//Author(s):  Kevin van Horn
//            Nishant Gurrapadi
//            Thach Ngo
//Prof:       Nhut Nguyen
//Assignment: Lexathon Project
//Class:      CS3340.501/ Computer Architecture
//Due:        1 December, 2016

#include <iostream>
#include <fstream>
#include <iomanip>
#include <random>
using namespace std;
// Lexathon is a word game where you must find as many word
// of four or more letters in the alloted time
// Each word must contain the central letter exactly once,
// and other tiles can be used once
// You start each game with 60 seconds
// Finding a new word increases time by 20 seconds
// The game ends when:
// -Time runs out, or
// -You give up
// Scores are determined by both the percentage of words found
// and how quickly words are found
// so find as many words as quickly as possible.

void printInstructions();
void populateBoard(char arr[]);
void printBoard(char arr[]);
void startGame(char arr[]);
bool checkInput(char arr[], char input[]);
const int ARRAY_SIZE = 9;

int main()
{
   // Variable holds user input
   int choice;
   // Array holds random letters for board
   char letterArray[ARRAY_SIZE];
   
   // Menu
   cout << "Welcome to Lexathon!\n\n";

   cout << "1) Start the game\n";
   cout << "2) Instructions\n";
   cout << "3) Exit\n";
      
   cin >> choice;
   while(choice != 3)
   {
     if (choice == 1)
     {
         startGame(letterArray);
     }
     else if (choice == 2) 
     {
         printInstructions();
     }
     else if (choice == 3)
     {
         break;
     }

      cout << "1) Start the game\n";
      cout << "2) Instructions\n";
      cout << "3) Exit\n";
      cin >> choice;
    }

   system("pause");
   return 0;
}

//  prints out instructions
void printInstructions()
{

   cout << "Lexathon is a word game where you must find as many word\n"
      << "of four or more letters in the alloted time\n\n";
   cout << "Each word must contain the central letter exactly once,\n"
      << "and other tiles can be used once\n\n";
   cout << "You start each game with 60 seconds\n"
      << "Finding a new word increases time by 20 seconds\n\n";
   cout << "The game ends when:\n"
      << "-Time runs out, or\n"
      << "-You give up\n\n";
   cout << "Scores are determined by both the percentage of words found\n"
      << "and how quickly words are found.\n"
      << "so find as many words as quickly as possible.\n\n";
   return;
}


// Generate random letters for table
void populateBoard(char arr[])
{
   for (int index = 0; index < ARRAY_SIZE; ++index)
   {
      arr[index] = 65 + rand() % 26;
      //cout << arr[index] << " "; IGNORE this is test code
      if (index + 1 % 3 == 0) 
      {
         cout << endl;
      }
   }
}

// Print board
void printBoard(char arr[]) 
{
   int line = 1;
   for (int i = 0; i < ARRAY_SIZE; ++i)
   {
      //cout << i + 1; IGNORE
      cout << "| " << arr[i] << " | ";
      if ( line % 3 == 0)
      {
         cout << "\n";
      }
      ++line;
   }
}

// Starts the game
void startGame(char arr[])
{
   char input[9];

   
   do
   {
      // initialize array with character zero
      for (int i = 0; i < sizeof(input); i++)
      {
         input[i] = '0';
      }
      // print board
      populateBoard(arr);
      printBoard(arr);
      cout << "1) Instructions" << endl
         << "2) Give Up" << endl;
      cout << "Enter word:" << endl;
      
      cin >> input;
      if (input[0] == '1')
      {
         printInstructions();
      }
      
      int index = 0;
      int inputLength = 0;
      while (input[index] != '0')
      {
         ++inputLength;
         ++index;
         cout << inputLength - 1;
      }
      cout << " Input length is " << inputLength - 1 << endl;
      cout << endl;

      bool inputIsValid = checkInput(arr, input);
      if (inputIsValid == true)
      {
         continue;
      }
      else if(inputIsValid == false)
      {
         cout << endl << "INVALID ANSWER" << endl;
         input[0] = '2';
      }

   } while (input[0] != '2');
}

// check input to see if each tile is used only once
// or if the correct tiles were used at all
bool checkInput(char arr[], char input[])
{
   char letterArrayCopy[9];
   cout << "copying array...";
   for (int i = 0; i < 9; ++i)
   {
      letterArrayCopy[i] = arr[i];
      
      cout << letterArrayCopy[i];
   }
   cout << endl;
   
   // set beginning to middle letter
   int boardIndex = 5;
   for (int i = 0; i < 9; )
   {
      boardIndex = boardIndex % 9;
      
      // If input's first letter does not match with 
      // middle letter continue to next position 
      // in input array until the character if found
      // If central letter is found return true
      // If central letter is not found the function
      // returns false
      if (arr[boardIndex] != input[i])
      {
         ++i;
      }
      else if (arr[boardIndex] == input[i] )
      {
         arr[boardIndex] = 0;
         return true;
      }
   }
   return false;
}