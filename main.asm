INCLUDE Irvine32.inc
.data
;0dh (carriage return) moves cusor to beginning of line
;0ah (line feed) moves cursor donw one line
;title BYTE "*** MAIN MENU *** ", 0dh, 0ah, 0
mytitle BYTE 0dh, 0ah, 0dh, 0ah, "*** MAIN MENU ***", 0dh, 0ah, 0dh, 0ah, 0
menu BYTE "Please select one of the following:", 0dh, 0ah,
			"1: Display my available credits ", 0dh, 0ah,
			"2: Add credits to my account ", 0dh, 0ah,
			"3: Play the guessing game ", 0dh, 0ah,
			"4: Display my statistics ", 0dh, 0ah,
			"5: Exit the program ", 0dh, 0ah, 0
userInput DWORD ? 
inputPrompt BYTE 0dh, 0ah, "Enter a number: ", 0
invalidInputStr BYTE "Invalid input, please enter an integer between 1 - 5 ", 0dh, 0ah, 0dh, 0ah, 0
balance DWORD 0 ;stores available credits
amount DWORD 0 ;amount of credits entered by user, max = 20
MAX_ALLOWED EQU 20 ;constant for maximum allowed credits
availableBalance BYTE "=> Your available balance is : $", 0
enterAmount BYTE 0dh, 0ah, "=> Please enter the amount you would like to add: ", 0
invalidAmount BYTE 0dh, 0ah, "The amount of credits you add cannot exceed 20", 0
updatedBalance BYTE 0dh, 0ah, "=> Your Balance is now: $", 0
correctGuesses DWORD 0 ;number of times user can correctly guess number
missedGuesses  DWORD 0 ;number of times user guessed the number incorrectly
randomNumber DWORD ? ;randomly generated number
userGuess DWORD ? ; number the user guessed
guessPrompt BYTE "Guess a number between 1 - 10!", 0dh, 0ah, 0
guessPrompt2 BYTE 0dh, 0ah, "=> Enter your number: ", 0
incorrectGuess BYTE 0dh, 0ah, "The correct number is: ", 0
incorrectGuess2 BYTE 0dh, 0ah, "You guessed wrong...", 0dh, 0ah, 0
congratsMessage BYTE 0dh, 0ah, "Congratulations! You guessed the number", 0dh, 0ah, 0dh, 0ah,
				"=> You win $2!", 0dh, 0ah, 0
replayPrompt BYTE 0dh, 0ah, "Would you like to play again?", 0dh, 0ah, 0dh, 0ah, "=> Enter 'yes' or 'no': ", 0
yesNo BYTE 4 DUP(?) ;max chars is 3 + null for yes/no user input
yes2 BYTE "yes", 0
no2 BYTE "no", 0
printName BYTE "Player's Name: ", 0
printAvailableCredits BYTE 0dh, 0ah, "Avalible Credits: ", 0
printGamesPlayed BYTE 0dh, 0ah, "Games Played: ", 0
printCorrectGuesses BYTE 0dh, 0ah, "Correct Guesses: ", 0
printWrongGuesses BYTE 0dh, 0ah, "Wrong Guesses: " ,0
printMoneyWon BYTE 0dh, 0ah, "Money You Won: " , 0
printMoneyLost BYTE 0dh, 0ah, "Money You Lost: " , 0
totalGamesPlayed DWORD 0
totalCorrectGuesses DWORD 0
totalWrongGuesses DWORD 0
totalMoneyWon DWORD 0
totalMoneyLost DWORD 0
playerName BYTE 15 DUP(0) ;stores the player's name, max = 15 chars


.code
main proc
mainMenu:
	mov edx, OFFSET mytitle
	call WriteString
	mov edx, OFFSET menu
	call WriteString
	mov edx, OFFSET inputPrompt
	call WriteString
	call ReadInt ;ReadInt sets overflow flag if the input is invalid
	jno validInput ;jump if not overflow, aka input is valid

	validInput:
		call Clrscr ;clear the screen
		mov userInput, eax ;store valid user input
		cmp userInput, 1 ;compares by subtracting destination - source
		jz optionOne ;if values are equal, zero flag (ZF) is set
		cmp userInput, 2
		jz optionTwo
		cmp userInput, 3
		jz optionThree
		cmp userInput, 4
		jz optionFour
		cmp userInput, 5
		jz optionFive
		jmp invalidInput ;default case if no comparisons are equal

	invalidInput:
		;call Clrscr ;clear the screen
		mov edx, OFFSET invalidInputStr
		call WriteString ;print error message
		jmp mainMenu
;Menu option one -> displays available balance
optionOne:
		mov edx, OFFSET availableBalance
		mov eax, balance
		call WriteString
		call WriteDec
		jmp mainMenu


			
optionThree:
	inc totalGamesPlayed
	inc totalMoneyLost
	call Randomize
	dec balance ;decrement balance by $1
	mov eax, 10
	call RandomRange ;generates number between 0-9
	inc eax ;update range to 1-10 by incrementing
	mov randomNumber, eax ;store randomly generated number

	mov edx, OFFSET guessPrompt ;tell the user to guess
	call WriteString

	mov eax, randomNumber
	call WriteDec

	mov edx, OFFSET guessPrompt2 ;prompt them to enter
	call WriteString
	call ReadInt
	mov userGuess, eax
	mov eax, randomNumber
	cmp eax, userGuess ;compare guess and random num
	jz correctGuess ;if values are equal, zero flag (ZF) is set
	jnz wrongGuess

correctGuess:
		inc totalCorrectGuesses
		mov eax, balance
		add eax, 2
		mov balance, eax
		mov eax, totalMoneyWon
		add eax, 2 
		mov totalMoneyWon, eax
		mov edx, OFFSET congratsMessage ;congratulate user and prompt to play again
		call WriteString
		jmp playAgain

wrongGuess:
		inc totalWrongGuesses
		mov edx, OFFSET incorrectGuess
		call WriteString
		mov eax, randomNumber
		call WriteDec
		mov edx, OFFSET incorrectGuess2
		call WriteString
		jmp playAgain

playAgain:
	mov edx, OFFSET replayPrompt
	call WriteString
		mov edx, OFFSET yesNo
		mov ecx, 3 ;char input for yes/no is max 3 characters
		call ReadString
		mov esi, OFFSET yesNo
		mov edi, OFFSET yes2
		call Clrscr 
		cmpsb
		je optionThree
		mov edi, OFFSET no2
		mov esi, OFFSET yesNo
		cmpsb
		je mainMenu

;Menu option 2 -> add credits to account
optionTwo:
		mov edx, OFFSET enterAmount 
		call WriteString ;prompt user to enter amount
		call ReadInt
		mov amount, eax ;store amount
		cmp amount, MAX_ALLOWED ;verify amount isn't greater than 20
		jbe addCredits ;jump if below or equal, if destination < source, then carry flag (CF) or zero flag (ZF) is set
		ja invalidCredits ;jump if above, carry flag (CF) and zero flag (ZF) = 0
		invalidCredits:
				mov edx, OFFSET invalidAmount
				call WriteString ;tell them not to add more than 20
				jmp optionTwo ;make them try again
		addCredits:
				mov eax, amount
				add balance, eax
				jmp optionOne ;display current balance


optionFour:
	mov edx, OFFSET printName
	call WriteString
	mov edx, OFFSET playerName
	call WriteString
	mov edx, OFFSET printAvailableCredits
	call WriteString
	mov eax, balance
	call WriteDec
	mov edx, OFFSET printGamesPlayed
	call WriteString
	mov eax, totalGamesPlayed
	call WriteDec
	mov edx, OFFSET printCorrectGuesses
	call WriteString
	mov eax, totalCorrectGuesses
	call WriteDec
	mov edx, OFFSET printWrongGuesses
	call WriteString
	mov eax, totalWrongGuesses
	call WriteDec
	mov edx, OFFSET printMoneyWon
	call WriteString
	mov eax, totalMoneyWon
	call WriteDec
	mov edx, OFFSET printMoneyLost
	call WriteString
	mov eax, totalMoneyLost
	call WriteDec
	

optionFive:

		

call ExitProcess
main endp
end main