
;==============================================================================
;
;                                   ECHO
;
;==============================================================================
;
;   Author:         Jose Fernando Lopez Fernandez
;
;   Date:           7 June, 2019
;
;   Description:
;
;       This program echoes all of its arguments in argv after the 
;       program's name to STDOUT.
;
;   Building:
;
;       To build the program on an x86-64 computer with nasm and ld, use
;       the following commands.
;
;           nasm -f elf -o echo.o ./echo.asm
;           ld -m elf_i386 -o echo-x86 ./echo.o
;
;------------------------------------------------------------------------------

                SECTION .text
                GLOBAL _start

_start:         POP     EBX             ; Store number of program args -> EBX
                POP     EBX             ; Overwrite EBX with &argv[0]

                ; Print every arg by pre-incrementing and checking zero flag,
                ; which will be set if EBX is NULL
                
.PRINT_ARG      POP     EBX             ; Overwrite EBX with *++argv
                
                ; Before proceeding, make sure that EBX is not NULL (NULL = 0)
                ; If this check is not performed, the program will SEGFAULT

                CMP     EBX,0           ; Explicitly check for NULL
                JZ      .DONE           ; If ZF = 1 (NULL = TRUE), exit prog

                ; Compute the length of argv[1] and store in EDI
                
                MOV     AX,DS           ; Initialize AX
                MOV     ES,AX           ; Initialize ES
                MOV     EDI,EBX         ; Set to string argv[1]
                MOV     EBP,EBX         ; Set to string argv[1]

                CLD                     ; Clear direction flag
                MOV     ECX,255         ; Set max size of string
                MOV     AL,0            ; Initialize AL with NUL
                REPNE   SCASB           ; Scan bytes in string until NUL found
                SUB     EDI,EBP         ; end - start = length

                ; Print the first positional argument to STDOUT

                MOV     ECX,EBX         ; Set length arg before clobbering EBX
                MOV     EDX,EDI         ; Length of argv[1] computed above
                MOV     EAX,4           ; Syscall write
                MOV     EBX,1           ; File descriptor: STDOUT
                INT     0x80            ; Execute system call

                ; Print newline char after string

                PUSH    10              ; Push newline char ASCII val to stack
                MOV     EAX,4           ; Syscall write
                MOV     EBX,1           ; File descriptor: STDOUT
                MOV     ECX,ESP         ; Addr of 'string' -> ESP
                MOV     EDX,1           ; Printing single char: length 1
                INT     0x80            ; Execute system call

                ; Get next argument from the stack

                POP     EBX
                JNZ     .PRINT_ARG      ; If *++argv != NULL, goto .PRINT_ARG

                ; Exit the program

.DONE:          MOV     EAX,1           ; Syscall: exit
                XOR     EBX,EBX         ; Return code 0
                INT     0x80            ; Execute system call

