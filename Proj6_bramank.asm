; Project 6    (Proj6_bramank.asm)

; Author: Kevin Braman
; Last Modified: 03/18/2023
; OSU email address: bramankD@oregonstate.edu
; Course number/section: CS 271 Section 402
; Project Number: 6		Due Date: 03/19/2023
; Description: This program prompts the user to enter 10 integers in string form, converts the string primitives into SDWORD integers, 
;			   computes the sum and average of the integers entered, and then converts the SDWORD integers back into strings. The 
;			   integers entered, their sum and their truncated average is displayed. 

INCLUDE Irvine32.inc

;-----------------------------------------------------------------------------------------------------------------------------------------------
; Name:	mGetString
;
; Calls the Irvine Library procedure "ReadString" to record user input and store it in a memory location. 
;
; Preconditions:	Uses ECX, EDX | PROC WriteString, ReadString 
; Receives:			
;					prompt					= string containing prompt message, in memory as input_1
;					memoryLocation			= memory location to store read string, in memory as array stringInput
;					memoryLocationLength	= length of memory location, in memory as lenStringInpt 
;
; Returns:			None, stores read string in variable memoryLocation
;-----------------------------------------------------------------------------------------------------------------------------------------------

mGetString MACRO prompt, memoryLocation, memoryLocationLength

	PUSH	ECX
	PUSH	EDX
	MOV		ECX, memoryLocationLength
	MOV		EDX, prompt
	CALL	WriteString
	MOV		EDX, memoryLocation
	CALL	ReadString
	MOV		memoryLocation, EDX
	POP		EDX
	POP		ECX

ENDM

;-----------------------------------------------------------------------------------------------------------------------------------------------
; Name:	mDisplayString
;
; Calls the Irvine Library procedure "WriteString" to output a passed string. 
;
; Preconditions:	Uses EDX | PROC WriteString
; Receives:			
;					memoryLocation			= memory location that stores a string array
;
; Returns:			Outputs the passed string to the user
;-----------------------------------------------------------------------------------------------------------------------------------------------

mDisplayString MACRO memoryLocation

	PUSH	EDX
	MOV		EDX, memoryLocation
	CALL	WriteString
	POP		EDX

ENDM

.data
intro_1			BYTE	"					Program 06 by Kevin Braman", 13, 10, 0
intro_2			BYTE	"Please provide 10 signed decimal integers.", 13, 10, 0
intro_3			BYTE	"Please note that each number must be small enough to fit inside a 32 bit register.", 13, 10, 0
intro_4			BYTE	"After you are finished this program will display a list of numbers entered, their sum, and their average.", 13, 10, 0
input_1			BYTE	"Please enter a signed integer: ", 0
error_1			BYTE	"ERROR: Input not a signed integer or input too large!", 13, 10, 0
output_1		BYTE	"You entered the following numbers:", 13, 10, 0
output_2		BYTE	"The sum of these numbers is: ", 0
output_3		BYTE	"The truncated average is: ", 0
outro_1			BYTE	"Thank you for using this program! Goodbye!", 13, 10, 0
stringInput		BYTE	20 DUP(?)
writeValOutput	BYTE	20 DUP(?)
lenStringInpt	DWORD	LENGTHOF stringInput
lenSavedInt     DWORD	LENGTHOF savedIntegers
lenWriteVal		DWORD	LENGTHOF writeValOutput
savedIntCount	DWORD	0
sumCount		DWORD	0
avgCount		DWORD	0
readValOutput	SDWORD	?
savedIntegers	SDWORD	10 DUP(?)
savedIntOutput	SDWORD	0
outputSum		SDWORD	0
outputAvg		SDWORD  0

.code

main PROC

	; Introduction

	PUSH	OFFSET intro_1
	PUSH	OFFSET intro_2
	PUSH	OFFSET intro_3
	PUSH	OFFSET intro_4
	CALL	introduction

	; Get 10 integers from the user, convert them to SDWORDs 

_PrepareValLoop:
	PUSH	ECX
	PUSH	EDI
	MOV		ECX, 10
	MOV		EDI, OFFSET savedIntegers 

	_ReadValLoop:
		PUSH	lenStringInpt
		PUSH	OFFSET readValOutput
		PUSH	OFFSET error_1
		PUSH	OFFSET stringInput
		PUSH	OFFSET input_1
		CALL	ReadVal
		MOV		EAX, readValOutput
		STOSD
		LOOP	_ReadValLoop
		POP		EDI
		POP		ECX
	_ReadValLoopEnd:
	
	; Calculate Sum & Average

	PUSH	OFFSET savedIntegers 
	PUSH	OFFSET outputAvg
	PUSH	OFFSET outputSum
	PUSH	lenSavedInt 
	CALL	Calculation

	; Calculate Sum & Average digit counts

	PUSH	OFFSET sumCount
	PUSH	outputSum	
	CALL	InputCount
	PUSH	OFFSET avgCount
	PUSH	outputAvg	
	CALL	InputCount

	; Output array

	PUSH	EDX
	CALL	CrLf
	MOV		EDX, OFFSET output_1
	CALL	WriteString
	POP		EDX

_PrepareWriteValLoop:
	PUSH	EAX
	PUSH	ECX
	PUSH	ESI
	MOV		ECX, 10
	MOV		ESI, OFFSET savedIntegers

	_WriteValLoop:
		LODSD
		PUSH	savedIntCount
		MOV		savedIntOutput, EAX
		PUSH	OFFSET savedIntCount
		PUSH	savedIntOutput	
		CALL	InputCount
		PUSH	OFFSET writeValOutput
		PUSH	savedIntCount
		PUSH	savedIntOutput
		CALL	WriteVal
		CMP		ECX, 1
		JE		_SkipLastComma
		MOV		AL, ","
		CALL	WriteChar
		MOV		AL, " "
		CALL	WriteChar
		_SkipLastComma:
		PUSH	OFFSET writeValOutput
		PUSH	lenWriteVal
		CALL	ClearArray
		POP		savedIntCount
		LOOP	_WriteValLoop
	_WriteValLoopEnd:
	CALL	CrLf
	POP		ESI
	POP		ECX
	POP		EAX

	; Output Sum

	PUSH	EDX
	MOV		EDX, OFFSET output_2
	CALL	WriteString
	POP		EDX
	PUSH	OFFSET writeValOutput
	PUSH	sumCount
	PUSH	outputSum
	CALL	WriteVal
	CALL	CrLf
	
	; Output Avg

	PUSH	EDX
	MOV		EDX, OFFSET output_3
	CALL	WriteString
	POP		EDX
	PUSH	OFFSET writeValOutput
	PUSH	lenWriteVal
	CALL	ClearArray
	PUSH	OFFSET writeValOutput
	PUSH	avgCount
	PUSH	outputAvg
	CALL	WriteVal
	
	; Outro

	CALL	CrLf
	PUSH	OFFSET outro_1
	CALL	Goodbye

		Invoke ExitProcess,0	; exit to operating system
main ENDP

;-----------------------------------------------------------------------------------------------------------------------------------------------
; Name:	introduction
;
; The 'introduction' procedure displays the title and program instructions before returning. 
;
; Preconditions:	PROC: WriteString, CrLf
; Postconditions:	All registers remain unmodified.
; Receives:			REGISTERS: EBP, EDX  
;					VARIABLES: OFFSET intro_1 [EBP+20], OFFSET intro_2 [EBP+16], OFFSET intro_3 [EBP+12], OFFSET intro_4 [EBP+8]
;					
; Returns:			Outputs intro_1, intro_2, intro_3, intro_4
;-----------------------------------------------------------------------------------------------------------------------------------------------


introduction PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX
	MOV		EDX, [EBP+20]
	CALL	WriteString
	CALL	Crlf
	MOV		EDX, [EBP+16]
	CALL	WriteString
	MOV		EDX, [EBP+12]
	CALL	WriteString
	MOV		EDX, [EBP+8]
	CALL	WriteString
	CALL	Crlf
	POP		EDX
	POP		EBP
	RET		16

introduction ENDP

;-----------------------------------------------------------------------------------------------------------------------------------------------
; Name:	ReadVal
;
; The 'ReadVal' procedure uses the 'mGetString' macro to receive 10 integer intputs as strings and convert them into SDWORDS. If the user enters
; a number that has an invalid character or the number entered is too large for a 32-bit register, an error message is shown and the user is 
; reprompted for input.
;
; Preconditions:	MACRO: mGetString PROC: WriteString, CrLf
; Postconditions:	All registers remain unmodified. VARIABLE readValOutput [EBP+20] modified
; Receives:			REGISTERS: EBP, EAX, EBX, ECX, EDX, ESI  
;					VARIABLES: OFFSET input_1 [EBP+8], OFFSET stringInput [EBP+12], OFFSET error_1 [EBP+16], OFFSET readValOutput [EBP+20],
;							   lenStringInpt [EBP+24]
;					
; Returns:			readValOutput [EBP+20] 
;-----------------------------------------------------------------------------------------------------------------------------------------------

ReadVal	PROC

	; Preserve registers

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI

_PrepareLoop:
	MOV		ESI, [EBP+12]
	MOV		ECX, 0
	JMP		_Prompt

	; Use the macro mGetString to get string input from the user. 
	; Validate the user input. If the user input is invalid, an error message is called and the user is reprompted for input.
	; If initial input was negative, negate the converted SDWORD.
	; Write to memory and return.

_Prompt:
	mGetString [EBP+8], [EBP+12], [EBP+24]
	MOV		EBX, EAX
	LODSB
	MOV		ESI, [EBP+12]
	CMP		AL, 45
	JE		_NegativeNumber
	JMP		_NonNegative
	
	; If the number entered is negative.

_NegativeNumber:
	CMP		EBX, 11
	JG		_InvalidInput
	CMP		AL, 0
	JE		_InvalidInput
	JMP		_Validate

	; If the number entered is positive.

_NonNegative:
	CMP		EBX, 10
	JG		_InvalidInput
	CMP		AL, 0
	JE		_InvalidInput
	JMP		_Validate

	; Validate ASCII characters are numbers.

_Validate:
	LODSB
	CMP		ECX, 2147483647
	JO		_InvalidInput
	CMP		AL, 0
	JE		_ValidInput
	CMP		AL, 43
	JE		_Validate
	CMP		AL, 45
	JE		_Validate
	CMP		AL, 48
	JL		_InvalidInput
	CMP		AL, 57
	JG		_InvalidInput
	JMP		_MainLoop
	
	; Convert ASCII into integer.

_MainLoop:
	MOV		EBX, 10
	MOVSX	EAX, AL
	SUB		EAX, 48
	XCHG	ECX, EAX
	MUL		EBX
	ADD		EAX, ECX
	MOV		ECX, EAX
	JMP		_Validate

	; If the user enters an invalid character or the number is too large, they are reprompted for input.

_InvalidInput:
	MOV		EDX, [EBP+16]
	CALL	WriteString
	XOR		ECX, ECX
	MOV		ESI, [EBP+12]
	JMP		_Prompt

	; SDWORD is negated if negative was entered. 

_ValidInput:
	MOV		ESI, [EBP+12]
	CMP		BYTE PTR [ESI], 45
	JNE		_WriteMemory
	NEG		ECX
	JMP		_WriteMemory

	; Write to memory

_WriteMemory:
	MOV		EBX, [EBP+20]
	MOV		[EBX], ECX
	JMP		_ReadValEnd

	; POP preserved registers.

_ReadValEnd:
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		24

ReadVal ENDP

;-----------------------------------------------------------------------------------------------------------------------------------------------
; Name:	WriteVal
;
; The 'WriteVal' procedure converts a SDWORD into a string containing its ASCII repesentation, then uses the macro 'mDisplayString' to display it.
;
; Preconditions:	MACRO: mDisplayString 
; Postconditions:	All registers remain unmodified. VARIABLE writeValOutput [EBP+16] modified
; Receives:			REGISTERS: EBP, EAX, EBX, ECX, EDX, EDI  
;					VARIABLES: savedIntOutput [EBP+8] | outputSum [EBP+8] | outputAvg [EBP+8], 
;						       savedIntCount [EBP+12] | sumCount [EBP+12] | avgCount [EBP+12],
;							   OFFSET writeValOutput [EBP+16]
;					
; Returns:			The output of the string writeValOutput [EBP+16]
;-----------------------------------------------------------------------------------------------------------------------------------------------

WriteVal PROC
	
	; Preserve registers.

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	
	; If the SDWORD passed is negative, account for it by appending the negative sign to the beginning of the array. 

_PrepareLoop:
	MOV		EAX, [EBP+8]
	MOV		EDI, [EBP+16]
	CMP		EAX, 0
	JL		_IsNegative
	JMP		_NonNegative

_IsNegative:
	NEG		EAX
	MOV		EBX, [EBP+12]
	MOV		BYTE PTR [EDI], '-'
	ADD		EDI, EBX
	JMP		_WriteValLoop

_NonNegative:
	MOV		EBX, [EBP+12]
	DEC		EBX
	ADD		EDI, EBX		
	JMP		_WriteValLoop

	; Calculate the ASCII equivalent of the integer.

_WriteValLoop:
	STD
	MOV		EBX, 10
	CDQ
	IDIV	EBX
	MOV		ECX, EAX
	MOV		EAX, EDX
	ADD		EAX, 48
	STOSB
	MOV		EAX, ECX
	CMP		EAX, 0
	JNE		_WriteValLoop
	JMP		_DisplayString

	; Call the macro mDisplayString to output to the user the converted string. 

_DisplayString:
	mDisplayString [EBP+16]
	JMP		_WriteValEnd

	; Pop preserved registers. 

_WriteValEnd:
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		12

WriteVal ENDP

;-----------------------------------------------------------------------------------------------------------------------------------------------
; Name:	Calculation
;
; The 'Calculation' procedure receives an array of SDWORDs and calculates the sum and truncated average.
;
; Preconditions:	None 
; Postconditions:	All registers remain unmodified. VARIABLE outputSum [EBP+12], outputAvg [EBP+16] modified
; Receives:			REGISTERS: EBP, EAX, EBX, ECX, EDX, ESI  
;					VARIABLES: lenSavedInt [EBP+8], OFFSET outputSum [EBP+12], OFFSET outputAvg [EBP+16], OFFSET savedIntegers [EBP+20]
;					
; Returns:			VARIABLE outputSum [EBP+12], outputAvg [EBP+16]
;-----------------------------------------------------------------------------------------------------------------------------------------------

Calculation	PROC
	
	; Preserve registers.

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI

	MOV		ECX, [EBP+8]
	MOV		ESI, [EBP+20]
	XOR		EBX, EBX

	; Calculate sum.

_SumLoop:
	LODSD
	ADD		EBX, EAX
	LOOP	_SumLoop
	MOV		EAX, [EBP+12]
	MOV		[EAX], EBX
	JMP		_CalculateAvg

	; Calculate average.

_CalculateAvg:
	MOV		EAX, EBX
	MOV		EBX, [EBP+8]
	CDQ		
	IDIV	EBX
	MOV		EBX, [EBP+16]
	MOV		[EBX], EAX
	JMP		_CalculationEnd

	; Pop preserved registers.

_CalculationEnd:
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		16

Calculation	ENDP

;-----------------------------------------------------------------------------------------------------------------------------------------------
; Name:	InputCount
;
; The 'InputCount' procedure receives an SDWORD and calculates the number of digits, returning the count of digits.
;
; Preconditions:	None 
; Postconditions:	All registers remain unmodified. VARIABLE OFFSET sumCount [EBP+12] | OFFSET avgCount [EBP+12] | 
;					OFFSET savedIntCount [EBP+12] modified 
;
; Receives:			REGISTERS: EBP, EAX, EBX, ECX, EDX
;					VARIABLES: outputSum [EBP+8] | outputAvg [EBP+8] | savedIntOutput [EBP+8],  OFFSET sumCount [EBP+12] | 
;							   OFFSET avgCount [EBP+12] | OFFSET savedIntCount [EBP+12]
;					
; Returns:			VARIABLE sumCount [EBP+12] | avgCount [EBP+12] | savedIntCount [EBP+12]
;-----------------------------------------------------------------------------------------------------------------------------------------------

InputCount PROC
	
	; Preserve registers.

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX

	; Check if number is negative, if so negate it. 

_PrepareInputCalLoop:
	MOV		EAX, [EBP+8]
	MOV		EBX, 10
	MOV		ECX, [EBP+12]
	CMP		EAX, 0
	JG		_InputCal
	NEG		EAX
	JMP		_InputCal

	; Calculate the number of digits.

_InputCal:
	CMP		EAX, 10
	JL		_SingleDigitWrite
	CMP		EAX, 1
	JE		_InputCountEnd
	CDQ
	DIV		EBX
	ADD		DWORD PTR [ECX], 1
	JMP		_InputCal

_SingleDigitWrite:
	ADD		DWORD PTR [ECX], 1
	JMP		_InputCountEnd

	; POP preserved registers.

_InputCountEnd:
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		8

InputCount ENDP

;-----------------------------------------------------------------------------------------------------------------------------------------------
; Name:	ClearArray
;
; The 'ClearArray' procedure receives an array and its length and clears it.
;
; Preconditions:	None 
; Postconditions:	All registers remain unmodified. VARIABLE OFFSET writeValOutput [EBP+12] modified 
; Receives:			REGISTERS: EBP, EAX, ECX, EDI
;					VARIABLES: lenWriteVal [EBP+8], OFFSET writeValOutput [EBP+12] 
;					
; Returns:			VARIABLE OFFSET writeValOutput [EBP+12] 
;-----------------------------------------------------------------------------------------------------------------------------------------------

ClearArray PROC
	
	; Preserve registers.

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	ECX
	PUSH	EDI

	; Fill passed array with 0s. 

	MOV		EAX, 0
	MOV		ECX, [EBP+8]
	MOV		EDI, [EBP+12]
	CLD
	REP		STOSB

	; Pop preserved registers. 

	POP		EDI
	POP		ECX
	POP		EAX
	POP		EBP
	RET		8

ClearArray ENDP

;-----------------------------------------------------------------------------------------------------------------------------------------------
; Name:	Goodbye
;
; The 'Goodbye' procedure outputs a closing message to the user.
;
; Preconditions:	PROC WriteString, CrLf
; Postconditions:	All registers remain unmodified.
; Receives:			REGISTERS: EBP, EDX
;					VARIABLES: OFFSET outro_1 [EBP+8] 
;					
; Returns:			None 
;-----------------------------------------------------------------------------------------------------------------------------------------------

Goodbye PROC
	
	; Preserve used registers.

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX

	; Output parting message. 

	MOV		EDX, [EBP+8]
	CALL	Crlf
	CALL	WriteString
	
	; Pop used registers.

	POP		EDX
	POP		EBP
	RET		4

Goodbye ENDP


END main
