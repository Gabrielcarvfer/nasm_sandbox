%include "io.inc"
;%define BIOS_MODE
;%define DOS_MODE
%define CALL_C

;Dont do silly things: if you want to use DOS or BIOS mode code blocks,
;you need to do additional steps. In case of DOS, run it in DOSBOX, that
;implements the interruption system. In case of BIOS, run the script
;that will assemble it to an object and strip everything else than the raw code.

section .data
    ;string declaration
    HELLOSTRING db "Hello, world!", 13, 10, 0 ; string
    TABLE times 10 dw 0
    
    ;you need to checkout BIOS syscall tables to understand what those codes mean
    EBIOSVIDEOINT equ 10h
    EBIOSTTYOUTPUTFN equ 0eh

section .text

global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    ;beginning of your code
    pusha ; is a pretty good idea pushing all registers to restore them later on
    
    
    ;making some math
        ;using just freaking registers
        mov ebx, 0x01234567
        mov ecx, 0x01
        mov eax, ecx 
        add eax, ebx
        
        ;the same shit using stack
        push ebx 
        push ecx
        pop eax
        pop ebx ;lolwut? why did you do that? to preserve registers before calling nonsafe functions
        add eax, ebx
            
    ;using logic operators
        ;initializing math stuff
        mov eax, 0
        mov ebx, 1
        
        ;lets do a Xor
        xor eax, ebx ; you should have 1 at eax
        
        ;and then an And
        and eax, ebx ; you should have 1 at eax
        
        ;and now a Not
        not eax ; you should have 0 at eax
    
    ;making loops
       ;first start loop stuff
       mov ecx, 0 ; that's a counter, got a problem?
       mov edx, 9 ; that's the end of loop
       
LOOP_LABEL:
       ;you're at the loop now, do something beautiful
       
       
       ;check if its the end of loop
       inc ecx
       cmp ecx, edx
       jne LOOP_LABEL
       
       ;if program counter is here, congrats, your loop works
         
    ;interruptions
       ;interruptions are nice and dangerous, use them wisely
       ;TODO
    
    ;iterating over string
        ;pointer manipulation and a loop, pretty simple
        mov eax, HELLOSTRING
LOOP_ITER:
        mov bl, byte[eax]	
	inc eax
        or bl, 0
        jnz LOOP_ITER
        
    ;printing a string
        ;thats a pretty cool thing to do
%ifdef BIOS_MODE
        ;using BIOS interruptions
	mov bx, HELLOSTRING
	mov ah, EBIOSTTYOUTPUTFN
put_10: 	
	mov al, byte[bx]   ;loading byte from string pointer
	or al, al
	jz put_20          ;reached the end of string 

	push bx            ;pushing pointer address to stack
	mov bx, 7          ;configuring page and color of TTY
	int EBIOSVIDEOINT  ;call for print

	pop bx             ;popping pointer address from stack 
	inc bx             ;increasing the pointer
	jmp put_10         ;loop
put_20:   
%else
        ;print using io.inc
        mov eax, HELLOSTRING
LOOP_PRINT:
        mov bl, byte[eax]
        PRINT_CHAR bl
  	inc eax
        or bl, 0
        jnz LOOP_PRINT
        
%endif
 
    ;now something about macros
        ;you can do awesome things with macros, like:
        ;-->loops
            %assign i 0
            %rep 10
                inc word [TABLE+2*i]
            %assign i i+1
            %endrep
            ;now our table is initialized, ranging from 1 to 10
            
%ifdef DOS_MODE
        ;-->multiline, multiparameter and greedy macros
            %macro writefile 2+
                jmp %%endofstring
                %%string: db %2
                %%endofstring: 
                    mov dx, %%string
                    mov cx, %%endofstring-%%string
                    mov bx, %1
                    mov ah, 0x40
                    int 0x21
%endif

%ifdef CALL_C
    call PS
%endif
    
    ;PRINT_CHAR 'M'
    popa ;is a pretty good idea poping all saved registers to restore context
    ;end of your code
    xor eax, eax
    ret
    
    
%ifdef CALL_C
 PS:
    ;so, you thought that i've forgotten about jumps and external C calls? try again
    
    ;how about calling a C program? seems nice, right?
    mov eax, 0
    mov ebx, 1
    mov ecx, HELLOSTRING
    
    ;first put parameters on the stack (on inverse order), and then call the desired label 
    push ecx
    push ebx
    push eax
    
extern _c_callee ;yup, you need to inform the assembler that this function is not in this file
    ; the callee is a function named c_callee, that receives (int, int, char*)
    ; that function returns -1 on eax
    ; how do you know that? you don't, at least looking into it's call
    ; that's why people don't use assembly to do everything
    call _c_callee 

    ;add esp, 8 ; if you don't know why we need to put that here, check calling conventions
    pop ebx
    pop ebx
    pop ebx
    
    cmp eax, -1
    je PS_RET
   
    ;oh, no, something went pretty darn wrong
    
PS_RET:
    ; we need to return to main function, even if callee test went wrong
    ; the main function know that something bad happened, because it can check eax too
    ret
    
segment .data
    variable dw 0
    
segment .text
global _asm_called
_asm_called:
    enter 0, 0
    pusha
    
    mov eax, [ebp+8]
    mov ebx, [ebp+12]
    
    sub eax, ebx
    
    mov [variable], eax
    
    popa
    leave
    mov eax, [variable]
    ret
%endif