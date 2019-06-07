
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
;==============================================================================
;
;                           PREPROCESSOR DEFINITIONS
;
;==============================================================================

    %define     NULL            0

    %define     STDIN           0
    %define     STDOUT          1
    %define     STDERR          2

    %define     SYSCALL_EXIT    1
    %define     SYSCALL_READ    3
    %define     SYSCALL_WRITE   4

;==============================================================================
;
;                               DATA SECTION
;
;==============================================================================

ERRMSG_WRITE_FAIL:  db "[Error] Failed while attempting to print output", 10
ERRLEN_WRITE_FAIL:  equ $-ERRMSG_WRITE_FAIL

;==============================================================================
;
;                               TEXT SECTION
;
;==============================================================================

                SECTION .text
                GLOBAL _start

;==============================================================================
;
;                                   MAIN
;
;==============================================================================

_start:         POP     EBX             ; Store number of program args -> EBX
                POP     EBX             ; Overwrite EBX with &argv[0]

                ; Print every arg by pre-incrementing and checking zero flag,
                ; which will be set if EBX is NULL
                
.PRINT_ARG      POP     EBX             ; Overwrite EBX with *++argv
                
                ; Before proceeding, make sure that EBX is not NULL (NULL = 0)
                ; If this check is not performed, the program will SEGFAULT

                CMP     EBX,NULL        ; Explicitly check for NULL
                JZ      .EXIT_SUCCESS   ; If ZF = 1 (NULL = TRUE), exit prog

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
                MOV     EAX,SYSCALL_WRITE
                MOV     EBX,STDOUT      ; File descriptor: STDOUT
                INT     0x80            ; Execute system call

                ; Check return value of SYSCALL_WRITE

                CMP     EAX,0
                JG      .PRINT_NEWLINE  ; If bytes written > 0, all OK

                ; Something went wrong. Print message to STDERR and exit

.WRITE_ERROR:   MOV     EAX,SYSCALL_WRITE
                MOV     EBX,STDERR      ; File descriptor STDERR
                MOV     ECX,ERRMSG_WRITE_FAIL
                MOV     EDX,ERRLEN_WRITE_FAIL
                INT     0x80            ; Execute system call. Write errmsg

                MOV     EBX,1           ; Set error code 1 (EXIT_FAILURE)
                JMP     .EXIT

                ; Print newline char after string

.PRINT_NEWLINE: PUSH    10              ; Push newline char ASCII val to stack
                MOV     EAX,SYSCALL_WRITE
                MOV     EBX,STDOUT      ; File descriptor: STDOUT
                MOV     ECX,ESP         ; Addr of 'string' -> ESP
                MOV     EDX,1           ; Printing single char: length 1
                INT     0x80            ; Execute system call

                ; Check return value of SYSCALL_WRITE

                CMP     EAX,0
                JG      .CONTINUE       ; if bytes written > 0, all ok
                JMP     .WRITE_ERROR    ; if bytes written = 0, handle error

                ; Get next argument from the stack

.CONTINUE:      POP     EBX             ; Reset stack (clear newline char)
                JMP     .PRINT_ARG      ; Return for next argument until NULL

                ; Exit the program

.EXIT_SUCCESS:  XOR     EBX,EBX         ; Return code 0 (EXIT_SUCCESS)
.EXIT:          MOV     EAX,SYSCALL_EXIT; Allow jumping to exit with error code
                INT     0x80            ; Execute system call

