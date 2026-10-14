;Final Project for CMPR-154 Computer Architecure and Organization for Spring 2025
;Note: The Irvine32 library for assembly is required to run this program!
INCLUDE Irvine32.inc
.data
;0dh (carriage return) moves cusor to beginning of line
;0ah (line feed) moves cursor down one line
;9 (tab space)
printNamePrompt BYTE "=> Enter your name (max 15 chars): ", 0
MAX_NAME EQU 16
playerName BYTE MAX_NAME+1 DUP(0) ;Stores the player's name, max = 15 chars

menu BYTE 0dh, 0ah, "*** MAIN MENU ***", 0dh, 0ah, 0dh, 0ah,
			"Please select one of the following:", 0dh, 0ah, 9h,
			"1: Display my available credits ", 0dh, 0ah, 9h,
			"2: Add credits to my account ", 0dh, 0ah, 9h,
			"3: Play the guessing game ", 0dh, 0ah,9h,
			"4: Display my statistics ", 0dh, 0ah, 9h,
			"5: Exit the program ", 0dh, 0ah,0
inputPrompt BYTE 0dh, 0ah, 0dh, 0ah,"=> Enter a number: ", 0

userInput DWORD ?
invalidInputStr BYTE "=> Invalid input, please enter an integer between 1 - 5!", 0dh, 0ah, 0

balance DWORD 3 ;Stores available credits, user starts with $10
amount SDWORD 0 ;Amount of credits entered by user, max = 20
MAX_ALLOWED EQU 20 ;Constant for maximum allowed credits

availableBalance BYTE "=> Your available balance is: $", 0
enterAmount BYTE 0dh, 0ah, "=> Please enter the amount you would like to add: ", 0
invalidMaxAmount BYTE 0dh, 0ah, "The amount of credits you add cannot exceed $20", 0
invalidMinAmount BYTE 0dh, 0ah, "The amount of credits you add cannot be less than $1", 0
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

replayPrompt BYTE 0dh, 0ah, "Would you like to play again?", 0dh, 0ah, 0
replayInputPrompt BYTE 0dh, 0ah, "=> Enter 'yes' or 'no': ", 0
userYesNo BYTE 4 DUP(?) ;Max chars is 3 + null for yes/no user input
yes2 BYTE "yes", 0
no2 BYTE "no", 0
printInvalidYesNo BYTE 0dh, 0ah, "Please enter only yes or no." , 0dh, 0ah, 0

printInsufficientBalance BYTE 0dh, 0ah, "You don't have enough money to play. Please add credits to your account." ,0dh, 0ah, 0dh, 0ah, 0

totalGamesPlayed DWORD 0
totalCorrectGuesses DWORD 0
totalWrongGuesses DWORD 0
totalMoneyWon DWORD 0
totalMoneyLost DWORD 0

printName BYTE "Player's Name: ", 0
printAvailableCredits BYTE 0dh, 0ah, 9h, "-Available Credits: $", 0
printGamesPlayed BYTE 0dh, 0ah, 9h, "-Games Played: ", 0
printCorrectGuesses BYTE 0dh, 0ah, 9h, "-Correct Guesses: ", 0
printWrongGuesses BYTE 0dh, 0ah, 9h, "-Wrong Guesses: " ,0
printMoneyWon BYTE 0dh, 0ah, 9h, "-Money You Won: $" , 0
printMoneyLost BYTE 0dh, 0ah, 9h, "-Money You Lost: $" , 0
printContinue BYTE 0dh, 0ah, 0dh, 0ah, "=> Press enter to continue..." , 0

printGameEnd BYTE 0dh, 0ah, "Exiting program..." , 0

.code
main proc
;Change prompt color to magenta 
mov eax, lightMagenta 
call SetTextColor

;Ask for the user's name
mov edx, OFFSET printNamePrompt
call WriteString

;Change user's input to white
mov eax, white
call SetTextColor

;Store name
mov edx, OFFSET playerName
mov ecx, MAX_NAME ;Max length 15 = chars
call ReadString
call Clrscr ;Clear the screen

mainMenu:
	;Print menu options
	mov eax, lightCyan
	call SetTextColor
	mov edx, OFFSET menu 
	call WriteString 

	;Ask for user input
	mov eax, lightMagenta
	call SetTextColor
	mov edx, OFFSET inputPrompt
	call WriteString
	mov eax, white
	call SetTextColor
	call ReadInt ;ReadInt sets overflow flag if the input is invalid
	jno validInput ;Jump if not overflow, (AKA input is valid)

	validInput:
		call Clrscr
		;Compare inputs
		mov userInput, eax ;Store valid user input
		cmp userInput, 1 ;Compares by subtracting destination - source
		jz optionOne ;If values are equal, zero flag (ZF) is set
		cmp userInput, 2
		jz optionTwo
		cmp userInput, 3
		jz optionThree
		cmp userInput, 4
		jz optionFour
		cmp userInput, 5
		jz optionFive
		jmp invalidInput ;Default case if no comparisons are equal

	invalidInput:
	;Print error message
		mov edx, OFFSET invalidInputStr
		call WriteString
		jmp mainMenu

;Menu option one -> display available balance
optionOne:
	mov edx, OFFSET availableBalance
	mov eax, balance
	call WriteString
	call WriteDec
	jmp mainMenu

;Menu option 2 -> add credits to account
optionTwo:
		mov eax, lightMagenta
		call SetTextColor
		;Prompt user to enter amount
		mov edx, OFFSET enterAmount 
		call WriteString

		mov eax, white
		call SetTextColor

		;Store amount
		call ReadInt
		mov amount, eax 
		cmp amount, 0 ;Verify amount isn't less than 20
		jl invalidMinCredits
		cmp amount, MAX_ALLOWED
		jle addCredits ;Jump if less or equal, if destination < source, then carry flag (CF) or zero flag (ZF) is set
		jg invalidMaxCredits ;Jump if greater, sign flag (CF) = overflow flag (OF) And zero flag (ZF) = 0

			invalidMinCredits:
				call Clrscr ;Clear the screen
				mov eax, lightCyan
				call SetTextColor
				mov edx, OFFSET invalidMinAmount
				call WriteString ;Tell them not to add more than 20
				jmp optionTwo ;Make them try again

			invalidMaxCredits:
				call Clrscr ;Clear the screen
				mov eax, lightCyan
				call SetTextColor
				mov edx, OFFSET invalidMaxAmount
				call WriteString ;Tell them not to add more than 20
				jmp optionTwo ;Make them try again

			addCredits:
				mov eax, amount
				add balance, eax
				jmp optionOne ;Display current balance

;Menu option 3 -> play guessing game
optionThree:
	call Clrscr
	mov eax, lightCyan
	call SetTextColor

	;Check if user has enough money to play game
	mov eax, balance
	cmp eax, 1
	jl insufficientBalance

	;New game starts
	inc totalGamesPlayed
	dec balance ;User pays $1 to play

	;Generate a number between 0-9
	call Randomize
	mov eax, 10 
	call RandomRange
	inc eax ;Update range to 1-10 by incrementing
	mov randomNumber, eax ;Store randomly generated number
	
	;Tell the user to guess a number
	mov edx, OFFSET guessPrompt
	call WriteString

	mov eax, lightMagenta
	call SetTextColor
	;Prompt them to guess a number
	mov edx, OFFSET guessPrompt2
	call WriteString

	;Store user's guess
	mov eax, white
	call SetTextColor
	call ReadInt
	mov userGuess, eax
	
	
	mov eax, lightCyan
	call SetTextColor

	;Compare guess and random num
	mov eax, randomNumber
	cmp eax, userGuess
	jz correctGuess ;if values are equal, zero flag (ZF) is set
	jnz wrongGuess

	correctGuess:
		;User earns $2 for winning
		inc totalCorrectGuesses
		mov eax, balance
		add eax, 2
		mov balance, eax
		mov eax, totalMoneyWon
		add eax, 2 
		mov totalMoneyWon, eax

		;Congratulate user and prompt to play again
		mov edx, OFFSET congratsMessage
		call WriteString
		jmp playAgain

	wrongGuess:
		inc totalWrongGuesses
		inc totalMoneyLost ;Count the $1 the user paid to play as money lost

		;Tell them the correct number
		mov edx, OFFSET incorrectGuess
		call WriteString
		mov eax, randomNumber 
		call WriteDec

		;Tell them they were wrong
		mov edx, OFFSET incorrectGuess2
		call WriteString
		jmp playAgain

playAgain:
	;Ask if they want to play again
	mov edx, OFFSET replayPrompt
	call WriteString
	
	mov eax, lightMagenta
	call SetTextColor
	mov edx, OFFSET replayInputPrompt
	call WriteString
		
	mov eax, white
	call SetTextColor
	;Get user input
	mov edx, OFFSET userYesNo
	mov ecx, LENGTHOF userYesNo ;Compare for the length of user's input
	call ReadString

	;Check if yes
	call Clrscr
	mov esi, OFFSET yes2
	mov edi, OFFSET userYesNo
	repe cmpsb ;Compare strings, byte by byte
	je optionThree

	;Check if no
	mov esi, OFFSET no2
	mov edi, OFFSET userYesNo
	repe cmpsb ;Compare strings, byte by byte
	je mainMenu

	jmp invalidYesNo

	invalidYesNo:
		;Retry if input isn't yes or no
		mov edx, OFFSET printInvalidYesNo ;Tell them their input is wrong
		call WriteString
		jmp playAgain

	insufficientBalance:
		;Tell user to add credits if 1 > balance 
		mov edx, OFFSET printInsufficientBalance
		call WriteString 
		jmp optionTwo

;Menu option 4 -> Print statistics
optionFour:
	mov eax, lightCyan
	call SetTextColor

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

	mov eax, lightMagenta
	call SetTextColor
	mov edx, OFFSET printContinue;Prompt user to hit enter to continue
	call WriteString

	WaitForInput:
		mov eax, 50 ;Sleep
		call Delay ;Pause for 50ms

		call ReadKey ;get input
		jz WaitForInput ;go back if no input yet

		CMP ah,1Ch ;Stores input in AH, 1C is hexadecimal for enter key
		jne WaitForInput ;Else keep waiting
		je ReturnToMenu;Go to main menu if equal to enter

	ReturnToMenu:
		call Clrscr ;Clear the screen
		jmp mainMenu

;Menu option 5 -> Quit game
optionFive:
	mov edx, OFFSET printGameEnd
	call WriteString

call ExitProcess
main endp
end main