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
#include <string>

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

void printMenu();
void printInstructions();
void randomizeBoard(char gameTable[]);
void printBoard(char gameTable[]);
void startGame(char gameTable[]);
bool checkMiddle(char gameTable[], char input[], int inputLength);
int checkDictionary(char input[], int inputLength);

const int ARRAY_SIZE = 9;

int main()
{

   printMenu();
   system("pause");
   return 0;
}

void printMenu()
{
   // Variable holds user input
   int choice;
   // Array holds random letters for board
   char gameTable[ARRAY_SIZE];

   // Menu
   cout << "Welcome to Lexathon!\n\n";

   cout << "1) Start the game\n";
   cout << "2) Instructions\n";
   cout << "3) Exit\n";
   
   // Input choice
   cin >> choice;
   while (choice != 3)
   {
      if (choice == 1)
      {
         startGame(gameTable);
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
}

// Print out instructions
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
void randomizeBoard(char gameTable[])
{
   for (int index = 0; index < ARRAY_SIZE; ++index)
   {
      gameTable[index] = 65 + rand() % 26;
      
      if (index + 1 % 3 == 0) 
      {
         cout << endl;
      }
   }
}

// Print board
void printBoard(char gameTable[]) 
{
   int line = 1;
   for (int i = 0; i < ARRAY_SIZE; ++i)
   {
      cout << "| " << gameTable[i] << " | ";
      if ( line % 3 == 0)
      {
         cout << "\n";
      }
      ++line;
   }
}

// Starts the game
void startGame(char gameTable[])
{
   char playerAnswer[9]; // array holds player input
   int score = 0;
   
   randomizeBoard(gameTable);
   
   do
   {
      // initialize array
      for (int i = 0; i < sizeof(playerAnswer); i++)
      {
         playerAnswer[i] = '0';
      }
      // print board
      printBoard(gameTable);
      cout << "Score: " << score << endl;
      cout << "1) Instructions" << endl
         << "2) Shuffle" << endl
         << "3) Give Up" << endl
         << "Enter word:" << endl;
      // get player's answer
      cin >> playerAnswer;
      if (playerAnswer[0] == '1')
      {
         printInstructions();
      }
      else if (playerAnswer[0] == '2')
      {
         randomizeBoard(gameTable);
      }
      // find answer's length
      int index = 0;
      int inputLength = 0;
      while (playerAnswer[index] != '0')
      {
         ++inputLength;
         ++index;
         cout << inputLength - 1;
      }
      inputLength = inputLength - 1;
      cout << "Input length is " << inputLength << endl;
      cout << "Player anwser is: " << playerAnswer[0] << playerAnswer[1] << endl;
      cout << endl;
      
      // Check if answer is valid
      bool inputIsValid = checkMiddle(gameTable, playerAnswer, inputLength);
      
      // If input valid add score, else try again
      if (inputIsValid == true)
      {
         score = score + checkDictionary(playerAnswer, inputLength);
      }
      else if(inputIsValid == false)
      {
         cout << endl << "Invalid Answer. Try again." << endl << endl;
         
      }

   } while (playerAnswer[0] != '3');
}

// check if middle tile was used
bool checkMiddle(char gameTable[], char playerAnswer[], int inputLength)
{
   // Table Positions
   //  0   1   2
   //  3   4   5
   //  6   7   8
   // check if middle letter is in the player's answer
   int tablePosition = 4;
   int index = 0;
   while(index < inputLength)
   {

      if (gameTable[tablePosition] != playerAnswer[index])
      {
         ++index;
      }
      else if (gameTable[tablePosition] == playerAnswer[index])
      {
         return true;
      }
   }
   return false;
}

int checkDictionary(char input[], int inputLength)
{
   const string FILE_NAME = "Dictionary.txt";
   ifstream inputFile;
   string word;
   cout << "Answer is" << endl;
   for (int i = 0; i < inputLength; i++)
   {
      cout << input[i] << " ";
   }
   cout << endl;
   system("pause");
   if (!inputFile.fail())
   {
      inputFile.open(FILE_NAME);
      cout << "Dictionary opened" << endl;
      cout << "Player Answer Length: " << inputLength << endl << endl;
      while (inputFile >> word)
      {
         int i = 0;
         cout << word << endl;
         while (i < inputLength)
         {
            if (tolower(input[i]) == word[i])
            {
               cout << word[i] << endl;
               ++i;
            }
            else
            {
               cout << "Invalid word detected" << endl;
               break;
            }
         }
         if (i == inputLength - 1)
         {
            cout << "Congrats, you know some random word...here, have some points" << endl
               << "+500"
               << endl
               << endl;
            return 500;
         }
      }

   }
   else
   {
      cout << "Error file not detected.";
   }
   return 0;
}