//Author(s):  Kevin VanHorn
//            Nishant Gurrapadi
//            Thach Ngo
//            Marco Serrano
//Prof:       Nhut Nguyen
//Assignment: Lexathon Project
//Class:      CS3340.501/ Computer Architecture
//Due:        1 December, 2016

/*
Issues/Improvements:
+ Word minimum of 4 (most boards dont have enough words)
-Possible Fixes:
1. Run board through analyzer: regen if too difficult
2. Lexathon has the ability to lock letters ADD THIS (later)
+ No letter can be used twice (no way to check this at the moment)
+ Add Timer so program has the game aspect (update after every word entered by seconds elapsed)
*/

/* Issues/Improvements made on 18th oct by Nishant
 1) Added the letter repeat condition check

*/

#include <iostream>
#include <fstream>
#include <iomanip>
#include <random>
#include <string>

using namespace std;

void printMenu();
void printInstructions();
void randomizeBoard(char gameTable[]);
void shuffleBoard(char gameTable[]);
void printBoard(char gameTable[]);
void startGame(char gameTable[]);
bool checkMiddle(char gameTable[], string answer, int answerLength);
bool checkDictionary(string answer, int answerLength);
bool letterRepeat(char gameTable[], string answer);
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
	cout << endl;
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
		cout << endl;
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
	srand(time(NULL)); // This will be different for MIPS, but in the subroutine: make sure srand has a random seed
	// As of now, every game starts with the same board. -Kevin
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

void shuffleBoard(char gameTable[])
{
    char middle = gameTable[4]; // holds the gameTable's middle value to preserve its postion
    char temp; // to hold the a letter temporarily when shuffling
    int randomNum; // holds the randomly generated number

    srand(time(NULL));

    // shuffles the entire board
    for (int i = ARRAY_SIZE - 1; i > 0; i--){
        randomNum = rand() % i;
        temp = gameTable[i];
        gameTable[i] = gameTable[randomNum];
        gameTable[randomNum] = temp;
    }

    // finds the value originally in the middle and swaps it with the value currently in the middle
    for(int index = 0; index < ARRAY_SIZE; index++){
        if (gameTable[index] == middle){
            gameTable[index] = gameTable[4];
            gameTable[4] = middle;
        }
    }
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
	cout << endl;
}

// Starts game
void startGame(char gameTable[])
{
	bool inputIsValid = false;
	bool letter_repeat = false;
	string playerAnswer = " "; // hold player's answer
	int score = 0; // variable hold player's score

	randomizeBoard(gameTable);

	do
	{

		printBoard(gameTable);
		cout << "Score: " << score << endl;
		cout << "Instructions: [1], Shuffle: [2], Give Up: [3]" << endl // CHANGED: Reduced to one line for readability 11-14-16 :Kevin
			//<< "2) Shuffle" << endl
			//<< "3) Give Up" << endl
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
			shuffleBoard(gameTable);
		}

		// If a word is entered
		else if (playerAnswer[0] != '3'){
			letter_repeat = letterRepeat(gameTable, playerAnswer);
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
					cout << endl << "Middle letter was not used. Try again.\n" << endl << endl;
				}
				// changed
				else if(letter_repeat == true)
				{
					cout << endl << "A letter has been repeated. Try again.\n" << endl;
				}
				// changed
				else if (inputIsValid == true && letter_repeat == false)
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
		}







	} while (playerAnswer[0] != '3');
	cout << endl;
	cout << "Your FINAL SCORE is... " << score << "!\n";
	cout << endl << "Again?\n";
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
				if (tolower(answer[i]) != dictionaryWord[i]) // CHANGED: tolower() may need to be added as a subroutine-Kevin
				{
					break;
				}
				else //if (answer[i] == dictionaryWord[i])
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

bool letterRepeat(char gameTable[], string answer)
{
    bool repeat = false;
    int answerArray[26] = {0}, gameBoardArray[26] = {0};


    for(int letter = 65; letter < 65 + 26; letter++)
    {
        for(int i = 0; i < answer.length(); i++)
        {
            if (letter == answer[i] || letter + 32 == answer[i])
                answerArray[letter - 65]++;
        }

        for(int j = 0; j < ARRAY_SIZE; j++)
        {
            if (letter == gameTable[j])
                gameBoardArray[letter - 65]++;
        }
    }

    for(int k = 0; k < 26; k++)
    {
        if(answerArray[k] > gameBoardArray[k])
            repeat = true;
    }

    return repeat;
}
/*/ Check to see if any letter is repeated
// if letter is repeated, it returns true
// if letter_Repeat == true, word is invalid!
bool letter_Repeat(string answer)
{
	unsigned int i = 0, j = 1, tempj = 1;
	bool repeat = false;
	char temp = answer[i];

	for(i = 0; i < answer.length(); i++)
	{
		temp = answer[i];
		for(; j < answer.length(); j++)
		{
			if(answer[j] == temp)
			{
				repeat = true;
			}
		}
		if(repeat == true)
			return repeat;
		else
			j = ++tempj;
	}
	return repeat;
}*/

int addScore(int length)
{
	int score;
	score = 5 * length;
	return score;
}

