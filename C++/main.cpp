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
bool checkMiddle(char gameTable[], string answer, int answerLength);
bool checkDictionary(string answer, int answerLength);
int addScore(int length);

const int ARRAY_SIZE = 9;

int main()
{
   printMenu();
   return 0;
}

// Display menu
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

   // Input player's choice
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
   srand(time(NULL));
   char vowel[] = { 'A', 'E', 'I', 'O', 'U' };
   
   for (int index = 0; index < ARRAY_SIZE; ++index)
   {
      
      gameTable[index] = 65 + rand() % 26;
      
      if (index + 1 % 3 == 0)
      {
         cout << endl;
      }
   }
   gameTable[4] = vowel[rand() % 5];

}

// Print board
void printBoard(char gameTable[])
{
   // CHANGED 10.4.16 removed 'line' variable, so only i is needed -Kevin
   for (int i = 0; i < ARRAY_SIZE; ++i)
   {
      cout << "| " << gameTable[i] << " | ";
      if ((i + 1) % 3 == 0)
      {
         cout << "\n";
      }
   }
}

// Starts game
void startGame(char gameTable[])
{
   bool inputIsValid = false; 
   string playerAnswer = " "; // hold player's answer
   int score = 0; // variable hold player's score

   randomizeBoard(gameTable);

   do // CHANGE: rewrite w/o do for easier MIPS implementation
   {
      
      printBoard(gameTable);
      
      cout << "Score: " << score << endl;
      cout << "1) Instructions" << endl
         << "2) Shuffle" << endl
         << "3) Give Up" << endl
         << "Enter word: ";
      
      // Get player's answer
      cin >> playerAnswer;

      // If 1 is entered, print instructions
      if (playerAnswer[0] == '1')
      {
         printInstructions();
      }
      // If 2 entered, shuffle the board
      else if (playerAnswer[0] == '2')
      {
         randomizeBoard(gameTable);
      }

      int answerLength = playerAnswer.size();
      cout << "Answer length: " << answerLength << endl;
      cout << "Player's answer: " << playerAnswer << endl;
      
      // Check if middle letter was used
      inputIsValid = checkMiddle(gameTable, playerAnswer, answerLength);
      if (playerAnswer != "1" && playerAnswer != "2" && playerAnswer != "3")
      {
         //FIX: this is showing up on shuffle
         //10.14.16 This has been fixed
         if (inputIsValid == false)
         {
            cout << endl << "Middle letter was not used. Try again." << endl << endl;
         }
         else if (inputIsValid == true)
         {
            inputIsValid = checkDictionary(playerAnswer, answerLength);
            if (inputIsValid == true)
            {
               score = score + addScore(answerLength);
               cout << endl << "+" << addScore(answerLength) << endl << endl;
            }
            else
            {
               cout << "Not a valid word" << endl << endl;
            }
         }
      }
      
      





   } while (playerAnswer[0] != '3');
}

// Checks if the Middle Tile was used
// Returns TRUE if the middle letter was used
// Returns false otherwise
bool checkMiddle(char gameTable[], string answer, int answerLength)
{
   // Table Positions
   //  0   1   2
   //  3   4   5
   //  6   7   8
   // check if middle letter is in the player's answer
   
   int tablePosition = 4;
   int index = 0;
   
   while (index < answerLength)
   {
      if (gameTable[tablePosition] != toupper(answer[index]))
      {
         ++index;
      }
      else if (gameTable[tablePosition] == toupper(answer[index]))
      {
         return true;
      }
   }
   return false;
}

// Check the dictionary for the player's answer
bool checkDictionary(string answer, int answerLength)
{
   const string FILE_NAME = "Dictionary.txt";
   
   // create input stream object
   ifstream inputFile;
   // string to hold words in the dictionary
   string dictionaryWord;
   
   // Open Dictionary.txt for reading
   if (!inputFile.fail())
   {
      inputFile.open(FILE_NAME);
      //cout << "Dictionary opened..." << endl;
      
      while (inputFile >> dictionaryWord)
      {
         
         int correctLetters = 0;
         
         /*cout << dictionaryWord << endl;
         cout << dictionaryWord.length() << endl;
         cin >> dictionaryWord; */
         
         for (int i = 0; i < answerLength; ++i)
         {
            if (answer[i] != dictionaryWord[i])
            {
               break;
            }
            else if (answer[i] == dictionaryWord[i])
            {
               correctLetters += 1;
            }
         }
         if (correctLetters == dictionaryWord.length() && correctLetters == answerLength)
         {
            return true;
         }
      }


   }
   else
   {
      cout << "Error file not detected.";
   }
   
   return false;
}

int addScore(int length)
{
   int score;
   score = 5 * length;
   return score;
}