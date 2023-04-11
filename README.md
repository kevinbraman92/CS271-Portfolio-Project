# Program Overview

This program was originally created for CS271 "Computer Architecture & Assembly Language". The purpose of this program is designing, implementing, and 
calling low-level I/O procedures, as well as using macros. Two macros are used that call Irvine Library read and write procedures. The user is prompted to 
enter 10 integers in the form of strings. These strings containing the integers are converted to SDWORDS and stored in an array. After user input is complete, 
the integers entered, their sum, and their truncated average is displayed. 

# Program Requirements
CS271 Portfolio Project

Implement and test two macros for string processing. These macros should use Irvine’s ReadString to get input from the user, and WriteString procedures to display output.

Implement and test two procedures for signed integers which use string primitive instructions

Write a test program (in main) which uses the ReadVal and WriteVal procedures above to:
1. Get 10 valid integers from the user. Your ReadVal will be called within the loop in main. Do not put your counted loop within ReadVal.
2. Stores these numeric values in an array.
3. Display the integers, their sum, and their truncated average.

User input must be validated the hard way:
1. Read the user's input as a string and convert the string to numeric form.
2. If the user enters non-digits other than something which will indicate sign (e.g. ‘+’ or ‘-‘), or the number is too large for 32-bit registers, an error message should be displayed and the number should be discarded.
3. If the user enters nothing (empty input), display an error and re-prompt.

ReadInt, ReadDec, WriteInt, and WriteDec are not allowed in this program.

Conversion routines must appropriately use the LODSB and/or STOSB operators for dealing with strings.

All procedure parameters must be passed on the runtime stack using the STDCall calling convention.

Prompts, identifying strings, and other memory locations must be passed by address to the macros.

Used registers must be saved and restored by the called procedures and macros.

The stack frame must be cleaned up by the called procedure.

The program must use Register Indirect addressing or string primitives (e.g. STOSD) for integer (SDWORD) array elements, and Base+Offset addressing for accessing parameters on the runtime stack.

Procedures may use local variables when appropriate.

For this assignment you are allowed to assume that the total sum of the valid numbers will fit inside a 32 bit register.
