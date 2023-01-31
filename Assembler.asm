%include "in_out.asm"

section .data
    filename2 db "hex.txt",0
    filename3 db "binary.txt",0
    descriptor dq 0
    descriptor2 dq 0
    descriptor3 dq 0

    space db 0x20

    reg_bit dq 0
    mem_bit dq 0

    registers db "rax:000 rcx:001 rdx:010 rbx:011 rsp:100 rbp:101 rsi:110 rdi:111 \
    eax:000 ecx:001 edx:010 ebx:011 esp:100 ebp:101 esi:110 edi:111 \
    ax:000 cx:001 dx:010 bx:011 sp:100 bp:101 si:110 di:111 \
    al:000 cl:001 dl:010 bl:011 ah:100 ch:101 dh:110 bh:111 \
    r8:000 r9:001 r10:010 r11:011 r12:100 r13:101 r14:110 r15:111 \
    r8d:000 r9d:001 r10d:010 r11d:011 r12d:100 r13d:101 r14d:110 r15d:111 \
    r8w:000 r9w:001 r10w:010 r11w:011 r12w:100 r13w:101 r14w:110 r15w:111 \
    r8b:000 r9b:001 r10b:010 r11b:011 r12b:100 r13b:101 r14b:110 r15b:111",NL

    zeroOperands db "stc:11111001 clc:11111000 std:11111101 cld:11111100 syscall:0000111100000101 ret:11000011",NL
    oneOperands db "inc:1111111 dec:1111111 neg:1111011 not:1111011 idiv:1111011 imul:1111011 pop:01011,10001111 push:01010,11111111,01101010,01101000 ret:11000010 \
    jmp:11101011,11101001,11111111,11111111 call:11101000,11111111,11111111 jrcxz:11100011",NL
    regOne db "inc:000 dec:001 not:010 neg:011 pop:000 push:110 idiv:111 imul:101 jmp:100 call:010",NL


    twoOperands db "mov:1000100,1000101,1000100,1100011,1011,1100011 \
    add:0000000,0000001,0000000,100000,0000010,100000 adc:0001000,0001001,0001000,100000,0001010,100000 \
    sub:0010100,0010101,0010100,100000,0010110,100000 sbb:0001100,0001101,0001100,100000,0001110,100000 \
    and:0010000,0010001,0010000,100000,0010010,100000 or:0000100,0000101,0000100,100000,0000110,100000 \
    xor:0011000,0011001,0011000,100000,0011010,100000 cmp:0011100,0011100,0011101,100000,0011110,100000 \
    test:1000010,1000010,1111011,1010100,1111011 xchg:1000011,10010,1000011 xadd:000011111100000,000011111100000 \
    imul:0000111110101111,0000111110101111 shl:1101000,1101000,1101001,1101001,1100000,1100000 \
    shr:1101000,1101000,1101001,1101001,1100000,1100000 bsf:0000111110111100,0000111110111100 bsr:0000111110111101,0000111110111101",NL
    

    condition db "o:0000 no:0001  b:0010 nae:0010 nb:0011 ae:0011 e:0100 z:0100 ne:0101 nz:0101 be:0110 na:0110 nbe:0111 a:0111 s:1000 ns:10001 \
    p:1010 pe:1010 np:1011 po:1011 l:1100 nge:1100 nl:1101 ge:1101 le:1110 ng:1110 nle:1111 g:1111",NL

    regTwo db "add:000 or:001 adc:010 sbb:011 and:100 sub:101 xor:110 cmp:111 shl:100 shr:101 test:000 mov:000",NL

    one db "0x1",NL
    zero db "0x0",NL

    prefix66 db "01100110",NL
    prefix67 db "01100111",NL

    rexflag dq 0
    rex4 db "0100",NL
    rexw db "0",NL
    r db "0",NL
    x db "0",NL
    b db "0",NL 

    mod1 db "00",NL
    mod2 db "01",NL
    mod3 db "10",NL
    mod4 db "11",NL

    rm1 db "100",NL

    scale1 db "00",NL
    scale2 db "01",NL
    scale3 db "10",NL
    scale4 db "11",NL

    index1 db "100",NL
    base1 db "101",NL

    move db "mov",NL
    i_test db "test",NL
    i_xchg db "xchg",NL
    i_xadd db "xadd",NL
    i_idiv db "idiv",NL
    i_imul db "imul",NL
    shift db "shl shr",NL
    bs db "bsf bsr",NL
    i_ret db "ret",NL
    pp db "push pop",NL
    i_jmp db "jmp",NL
    i_call db "call",NL
    i_jcc db "jcc",NL
    i_jrcxz db "jrcxz",NL
    addfamily db "add adc sub sbb and or xor cmp",NL
    
section .bss
    filename resb 100

    command resb 100            ;command is instruction + operands
    instruction resb 10         ;instruction like mov and add
    operand1 resb 50            ;first operand
    operand2 resb 50            ;second operand
    mem_operand resb 50         ;we store our memory operand in here and we parse this in our memoryHandler function
    register resb 5
    reg_code resb 4
    memory resb 50
    temp resb 20

    prefix resb 17
    rex resb 9
    opcode resb 17
    modrm resb 9
    sib resb 9
    displacement resb 11
    data resb 50

    hex resb 100                ;we store result here
    binary resb 400


    w resb 2
    s resb 2

    mod resb 3
    reg resb 4                  ;reg value which is sometimes a part of opcode
    rm resb 4

    scale resb 3
    index resb 4
    base resb 4




    
section .text
    global _start


%macro init 0
    mov byte [prefix],0xA
    mov byte [rex],0xA
    mov byte [opcode],0xA
    mov byte [modrm],0xA
    mov byte [sib],0xA
    mov byte [displacement],0xA
    mov byte [data],0xA

    mov qword [reg_bit],0
    mov qword [mem_bit],0
    mov qword [rexflag],0
    mov byte [rexw],'0'
    mov byte [r],'0'
    mov byte [x],'0'
    mov byte [b],'0'
    mov byte [w],'0'
    mov byte [s],'0'
%endmacro


%macro dummy 1
    push rax
    mov rax,%1
    call writeNum
    call newLine
    pop rax
%endmacro

%macro write 1
    push rax
    mov rax,%1
    call writeNum
    call newLine
    pop rax
%endmacro

;print strings that end with newline
%macro print 1              
    push rax
    push rsi

    mov rax,0
    mov rsi,%1
%%body_print:
    mov al,[rsi]
    call putc
    cmp al,0xA
    je %%end_print
    inc rsi
    jmp %%body_print
%%end_print:
    pop rsi
    pop rax

%endmacro

%macro search 4
    push rax
    push rbx
    push rcx
    push rsi
    push rdi

    mov rax,0
    mov rcx,%4                  ;rcx holds which opcode to grab
    mov rbx,%3                  ;rbx points to opcode to store it
    mov rsi,%1                  ;instruction
    mov rdi,%2                  ;dictionary
%%body_search:
    cmp byte [rdi],':'
    je %%match_search           ;match has been found
    mov al,[rsi]        
    cmp [rdi],al
    jne %%next_search
    inc rsi
    inc rdi
    jmp %%body_search
%%next_search:
    mov rsi,%1
    inc rdi
    mov al,[rdi-1]
    cmp al,0x20                 ;if equals space
    je %%body_search
    jmp %%next_search
%%match_search:
    inc rdi
    cmp byte [rdi],0x20         ;if we reach space match ends
    je %%end_search
    cmp byte [rdi],','          ;if we reach comma match ends
    je %%comma_search
    cmp byte [rdi],0xA          ;if we reach end of dictionary match ends
    je %%end_search

    mov al,[rdi]
    mov [rbx],al
    inc rbx
    jmp %%match_search

%%comma_search:
    cmp rcx,0
    je %%end_search
    dec rcx
    mov rbx,%3
    jmp %%match_search
%%end_search:
    mov byte [rbx],0xA          ;end it with 0xA to know where it ends so we can use it later or add to it

    pop rdi
    pop rsi
    pop rcx
    pop rbx
    pop rax



%endmacro 

; copies 1 to 2.
%macro copy 2
    push rax
    push rsi
    mov rsi,%1
    mov rdi,%2
%%body_copy:
    mov al,[rsi]
    cmp al,0xA
    je %%end_copy
    mov [rdi],al
    inc rsi
    inc rdi
    jmp %%body_copy

%%end_copy:
    mov byte [rdi],0xA
    pop rsi
    pop rax
%endmacro 


;this adds s and w bit to opcode if they are not -1
%macro addOpcode 1
    push rax
    push rsi
    push rdi

    mov rsi,opcode
    mov rdi,%1
%%loop_addOpcode:
    cmp byte [rsi],0xA
    je %%loop2_addOpcode
    inc rsi
    jmp %%loop_addOpcode
%%loop2_addOpcode:
    mov al,byte [rdi]
    cmp al,0xA
    je %%end_addOpcode
    mov byte [rsi],al
    inc rsi
    inc rdi
    jmp %%loop2_addOpcode

%%end_addOpcode:
    mov byte [rsi],0xA

    pop rdi
    pop rsi
    pop rax
%endmacro

%macro setModrm 0
    push rsi
    push rdi

    mov rdi,modrm
    mov rsi,mod
    copy rsi,rdi
    mov rsi,reg
    copy rsi,rdi
    mov rsi,rm
    copy rsi,rdi

    pop rdi
    pop rsi
%endmacro



%macro setPrefix 0
    push rdi
    mov rdi,prefix
    cmp qword [mem_bit],32
    je %%p67
    jmp %%next_sp
%%p67:
    copy prefix67,rdi
%%next_sp:
    cmp qword [reg_bit],16
    je %%p66
    jmp %%end_sp
%%p66:
    copy prefix66,rdi 
%%end_sp:
    mov byte [rdi],0xA
    pop rdi


%endmacro


%macro setRex 0
    push rdi
    cmp qword [reg_bit],64
    je %%flag_sr
    jmp %%start_sr
%%flag_sr:
    mov qword [rexflag],1
%%start_sr:
    cmp qword [rexflag],0
    je %%end_sr
    mov rdi,rex
    cmp qword [reg_bit],64
    je %%setw_sr
    jmp %%next_sr
%%setw_sr:
    mov byte [rexw],'1'
%%next_sr:
    copy rex4,rdi
    copy rexw,rdi
    copy r,rdi
    copy x,rdi
    copy b,rdi
    mov byte [rdi],0xA
%%end_sr:
    pop rdi

%endmacro


%macro newRegister 2
    push rax
    push rsi
    push rdi 

    mov rsi,%1
    mov rdi,%2
    mov al,[rsi]
    cmp al,'r'
    je %%part1_nR
    jmp %%end_nR
%%part1_nR:
    mov al,[rsi+1]
    cmp al,'1'
    je %%new_nR
    cmp al,'8'
    je %%new_nR
    cmp al,'9'
    je %%new_nR

    jmp %%end_nR
%%new_nR:
    mov qword [rexflag],1
    mov al,'1'
    mov byte [rdi],al
%%end_nR:
    pop rdi 
    pop rsi 
    pop rax 

%endmacro 


;this macro stores operation size(QWORD DWORD etc..) in reg_bit. and stores in between brackets in memory variable.
%macro opSize 1
    push rax
    push rsi

    mov rsi,%1
    mov al,[rsi]
    cmp al,'Q'
    je %%op64
    cmp al,'D'
    je %%op32
    cmp al,'W'
    je %%op16
    cmp al,'B'
    je %%op8
%%op64:
    mov qword [reg_bit],64
    jmp %%next_os
%%op32:
    mov qword [reg_bit],32
    jmp %%next_os
%%op16:
    mov qword [reg_bit],16
    jmp %%next_os
%%op8:
    mov qword [reg_bit],8
%%next_os:
    mov al,[rsi]
    cmp al,'['
    je %%next2_os
    inc rsi
    jmp %%next_os
%%next2_os:
    inc rsi
    mov rdi,memory
    copy rsi,rdi
    mov byte [rdi-1],0xA

    pop rsi
    pop rax
%endmacro


;gets length of memory and stores it in rax
%macro len 1
    push rsi

    mov rax,0
    mov rsi,%1
%%body_len:
    mov bl,byte [rsi]
    cmp bl,0xA
    je %%end_len
    inc rax
    inc rsi
    jmp %%body_len

%%end_len:
    pop rsi
%endmacro


%macro getw 0
    push rsi

    mov rsi,w
    cmp qword [reg_bit],8
    je %%set_getw
    mov byte [rsi],'1'
    jmp %%end_getw
%%set_getw:
    mov byte [rsi],'0'
%%end_getw:
    inc rsi
    mov byte [rsi],0xA
    
    pop rsi
%endmacro

;this macro checks if register is rbp or ebp. rax=1 it is rax=0 its not
%macro checkbp 1
    push rsi
    mov rax,0
    mov rsi,%1
    cmp byte [rsi+1],'b'
    je %%part1_rb
    jmp %%end_rb
%%part1_rb:
    cmp byte [rsi+2],'p'
    je %%part2_rb
    jmp %%end_rb
%%part2_rb:
    mov rax,1
%%end_rb:
    pop rsi

%endmacro

%macro decimalHex 1
    push rax 
    push rbx 
    push rcx 
    push rdx 
    push rsi

    mov rsi,%1
    mov rax,0
    mov rbx,0
    mov rcx,0
    mov rdx,0
%%strnum:
    mov al,[rsi]
    cmp al,0xA
    je %%endstrnum
    sub al,48
    imul rbx,10
    add rbx,rax
    inc rsi
    jmp %%strnum
%%endstrnum:
    mov rax,rbx
    mov rbx,16
    mov rcx,0
    mov rsi,%1
    mov byte [rsi],'0'
    mov byte [rsi+1],'x'
    add rsi,2
%%numhex:
    mov rdx,0
    div rbx
    cmp rdx,10
    jl %%lessdigit
    jmp %%moredigit

%%lessdigit:
    add rdx,48
    push rdx
    inc rcx
    cmp rax,0
    je %%hexdigits
    jmp %%numhex
%%moredigit:
    add rdx,87
    push rdx
    inc rcx 
    cmp rax,0
    je %%hexdigits
    jmp %%numhex

%%hexdigits:
    cmp rcx,0
    je %%end_dh
    pop rdx
    mov [rsi],dl
    inc rsi
    dec rcx
    jmp %%hexdigits
%%end_dh:
    mov byte [rsi],0xA
    print %1
    pop rsi 
    pop rdx
    pop rcx
    pop rbx
    pop rax
    

%endmacro

;return rax as flag. rax=1 its number
%macro checkNumber 1
    push rbx
    push rsi
    mov rax,0
    mov rsi,%1
    mov bl,[rsi]
    cmp bl,48
    jge %%part1_cn
    jmp %%end_cn
%%part1_cn:
    cmp bl,57
    jle %%part2_cn
    jmp %%end_cn
%%part2_cn:
    mov bl,[rsi+1]
    cmp bl,'x'
    je %%hex_cn
    jmp %%decimal_cn

%%decimal_cn:
    decimalHex %1
    mov rax,1
    jmp %%end_cn
%%hex_cn:
    mov rax,1
    jmp %%end_cn
%%end_cn:
    pop rsi
    pop rbx

%endmacro


;this macro gets register as string and stores it size in reg_bit
%macro registerSize 1
    push rax
    push rbx
    push rsi

    mov rsi,%1
    len rsi                 ;this returns length of register in rax
    dec rax
    mov bl,[rsi]            ;first character of register
    cmp bl,'r'
    je %%r_reg
    cmp bl,'e'
    je %%reg32

    mov bl,[rsi+rax]        ;last character
    cmp bl,'l'
    je %%reg8
    cmp bl,'h'
    je %%reg8
    cmp bl,'x'
    je %%reg16
    cmp bl,'p'
    je %%reg16
    cmp bl,'i'
    je %%reg16

%%r_reg:
    mov bl,[rsi+rax]        ;last character of register
    cmp bl,'d'
    je %%reg32
    cmp bl,'w'
    je %%reg16
    cmp bl,'b'
    je %%reg8

    jmp %%reg64               ;else register is 64 bit


%%reg64:
    mov qword [reg_bit],64
    jmp %%end_reg
%%reg32:
    mov qword [reg_bit],32
    jmp %%end_reg
%%reg16:
    mov qword [reg_bit],16
    jmp %%end_reg
%%reg8:
    mov qword [reg_bit],8
    jmp %%end_reg

%%end_reg:
    pop rsi
    pop rbx
    pop rax


%endmacro


%macro checkDisp 1
    push rsi
    mov rsi,%1
    add rsi,2
    len rsi
    cmp rax,2
    je %%equal_cd
    jl %%less_cd
    jg %%greater_cd
%%less_cd:
    mov rax,2
    copy mod2,mod
    jmp %%end_cd
%%equal_cd:
    cmp byte [rsi],'8'
    jge %%greater_cd
    copy mod2,mod
    mov rax,2
    jmp %%end_cd
%%greater_cd:
    mov rax,8
    copy mod3,mod
    jmp %%end_cd
%%end_cd:
    pop rsi

%endmacro

;sets displacement or data in machine code
%macro setDispData 3
    push rax
    push rbx
    push rcx
    push rsi
    push rdi

    mov rsi,%1
    mov rcx,%2
    mov rdi,%3



%%else_sd:
    cmp byte [rsi],0xA
    je %%zero_sd
    cmp byte [rsi+1],'x'
    je %%start_sd

%%start_sd:
    add rsi,2

%%loop_sd:
    cmp byte [rsi],0xA
    je %%next_sd
    inc rsi
    jmp %%loop_sd
%%next_sd:
    dec rsi                 ;rsi now points to last digit
%%loop2_sd:
    cmp rcx,0
    je %%end_sd
    mov al,[rsi]
    mov bl,[rsi-1]
    cmp bl,'x'
    je %%next2_sd
    mov [rdi],bl
    mov [rdi+1],al

    add rdi,2
    sub rsi,2
    sub rcx,2

    cmp byte [rsi],'x'
    je %%zero_sd
    jmp %%loop2_sd

%%next2_sd:
    mov byte [rdi],'0'
    mov [rdi+1],al
    add rdi,2
    sub rsi,2
    sub rcx,2

%%zero_sd:
    cmp rcx,0
    je %%end_sd
    mov byte [rdi],'0'
    mov byte [rdi+1],'0'
    add rdi,2
    sub rcx,2
    jmp %%zero_sd

%%end_sd:
    mov byte [rdi],0xA
    pop rdi
    pop rsi
    pop rcx
    pop rbx 
    pop rax 

%endmacro

%macro setSib 0
    push rdi
    mov rdi,sib
    copy scale,rdi
    copy index,rdi 
    copy base,rdi 
    pop rdi
%endmacro


%macro setScale 1
    push rax
    mov al,%1
    cmp al,'1'
    je %%setscale1
    cmp al,'2'
    je %%setscale2
    cmp al,'4'
    je %%setscale3
    cmp al,'8'
    je %%setscale4
%%setscale1:
    copy scale1,scale
    jmp %%end_ss
%%setscale2:
    copy scale2,scale
    jmp %%end_ss
%%setscale3:
    copy scale3,scale
    jmp %%end_ss
%%setscale4:
    copy scale4,scale
    jmp %%end_ss
%%end_ss:
    pop rax
%endmacro


%macro compare 2
    push rbx
    push rsi
    push rdi
    mov rax,0
    mov rsi,%1
    mov rdi,%2
%%body_compare:
    mov bl,[rsi]
    cmp bl,0xA
    je %%equal_compare
    cmp bl,[rdi]
    jne %%end_compare
    inc rsi
    inc rdi
    jmp %%body_compare
%%equal_compare:
    mov rax,1
%%end_compare:
    pop rdi
    pop rsi
    pop rbx

%endmacro

%macro member 2
    push rbx
    push rsi
    push rdi

    mov rax,0
    mov rsi,%1      ;our instruction
    mov rdi,%2      ;our list
%%start_m:

    mov bl,[rsi]
    cmp bl,0xA
    je %%equal_m
    cmp bl,[rdi]
    jne %%next_m
    inc rsi
    inc rdi
    jmp %%start_m
%%next_m:
    inc rdi
    cmp byte [rdi],0x20
    je %%reset_m
    cmp byte [rdi],0xA
    je %%end_m
    jmp %%next_m
%%reset_m:
    inc rdi
    mov rsi,%1
    jmp %%start_m
%%equal_m:
    mov rax,1
%%end_m:
    pop rdi
    pop rsi 
    pop rbx
%endmacro

%macro dataExtension 0
    push rbx
    push rdx 

    mov rax,[reg_bit]
    mov rbx,4
    mov rdx,0
    div rbx
    cmp rax,8
    jge %%eight_de
    jmp %%end_de
%%eight_de:
    mov rax,8
%%end_de:
    pop rdx 
    pop rbx

%endmacro



%macro gets 1
    push rax
    push rsi

    mov rax,[reg_bit]
    mov rsi,%1
    add rsi,2
    cmp rax,16
    jge %%part1_g
    jmp %%szero
%%part1_g:
    len rsi
    cmp rax,1
    je %%sone
    cmp rax,2
    je %%part2_g
    cmp rax,3
    jge %%szero

%%part2_g:
    cmp byte [rsi],'8'
    jl %%sone
    jmp %%szero
%%szero:
    mov byte [s],'0'
    mov byte [s+1],0xA
    jmp %%end_g
%%sone:
    mov byte [s],'1'
    mov byte [s+1],0xA
    jmp %%end_g
%%end_g:
    pop rsi 
    pop rax

%endmacro

;this macro gets immediate data and has reg_bit and decides how much extension is needed. its value is returned in rax
%macro sdataExtension 1
    push rbx
    push rdx 
    push rsi 

    mov rsi,%1
    add rsi,2
    cmp qword [reg_bit],8
    je %%two_sde
    len rsi
    cmp rax,1
    je %%two_sde
    cmp rax,2
    je %%part1_sde
    cmp rax,2
    jg %%div_sde
%%part1_sde:
    cmp byte [rsi],'8'
    jl %%two_sde
%%div_sde:
    mov rax,[reg_bit]
    mov rbx,4
    mov rdx,0
    div rbx
    cmp rax,8
    jg %%eight_sde
    jmp %%end_sde
%%eight_sde:
    mov rax,8
    jmp %%end_sde
%%two_sde:
    mov rax,2
    jmp %%end_sde
%%end_sde:
    pop rsi 
    pop rdx 
    pop rbx 

%endmacro

;this macro checks if register is accumulator and s=0 then we use imm to al,eax opcode in addfamiy table. return rax=1 if alternate opcode is needed
%macro accums 1
    push rsi 
    mov rsi,%1
    mov rax,0
    cmp byte [rsi],'a'
    je %%part1_a
    cmp byte [rsi+1],'a'
    je %%part1_a
    jmp %%end_a
%%part1_a:
    cmp byte [s],'0'
    je %%itsaccum
    jmp %%end_a
%%itsaccum:
    cmp byte [rsi+1],'h'
    je %%end_a
    mov rax,1
%%end_a:
    pop rsi

%endmacro


%macro accum 1
    push rsi
    mov rax,0
    mov rsi,%1
    cmp byte [rsi],'a'
    je %%isaccum
    cmp byte [rsi+1],'a'
    je %%isaccum
    jmp %%end_accum
%%isaccum:
    cmp byte [rsi+1],'h'
    je %%end_accum
    mov rax,1
%%end_accum:
    pop rsi
%endmacro



%macro binToHex 1
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    push rsi

    mov rsi,%1
%%start_bTH:
    cmp byte [rsi],0xA
    je %%end_bTH
    mov rax,8
    mov rbx,2
    mov rcx,4
    mov r8,0
%%loop_bTH:
    cmp rcx,0
    je %%after_bTH
    mov dl,[rsi]
    cmp dl,'1'
    je %%add_bTH
    jmp %%next_bTH
%%add_bTH:
    add r8,rax
%%next_bTH:
    dec rcx
    mov rdx,0
    div rbx
    inc rsi
    jmp %%loop_bTH
%%after_bTH:
    cmp r8,10
    jl %%digit_bTH
    add r8,87
    mov byte [rdi],r8b
    inc rdi
    jmp %%start_bTH
%%digit_bTH:
    add r8,48
    mov byte [rdi],r8b
    inc rdi
    jmp %%start_bTH
%%end_bTH:
    pop rsi
    pop r8
    pop rdx 
    pop rcx 
    pop rbx 
    pop rax 
%endmacro


%macro hexToBin 0
    push rax
    push rbx 
    push rcx 
    push rdx 
    push rsi 
    push rdi 


    mov rsi,hex
    mov rdi,binary
    mov rbx,2
    mov rax,0
    mov rcx,4
%%body_htb:
    mov al,[rsi]
    cmp al,0xA
    je %%end_htb
    cmp al,97
    jge %%letter_htb
    jmp %%digit_htb
%%letter_htb:
    sub al,87
    jmp %%next_htb
%%digit_htb:
    sub al,48
    jmp %%next_htb
%%next_htb:
    cmp rcx,0
    je %%next2_htb
    mov rdx,0
    div rbx
    add dl,48
    dec rcx
    mov [rdi+rcx],dl
    jmp %%next_htb
%%next2_htb:
    mov rcx,4
    inc rsi
    add rdi,4
    jmp %%body_htb
%%end_htb:
    mov byte [rdi],0xA

    pop rdi 
    pop rsi 
    pop rdx 
    pop rcx 
    pop rbx 
    pop rax

%endmacro 

readname:
    push rax
    push rsi

    mov rsi,filename
body_rd:
    call getc
    cmp rax,0xA
    je end_rd
    mov [rsi],al
    inc rsi
    jmp body_rd
end_rd:
    mov byte [rsi],0

    pop rsi
    pop rax
    ret


_start:
    call rostin
_exit:
    mov rax,60
    xor rdi,rdi
    syscall

rostin:
    call readname


    mov rax,2
    mov rdi,filename
    mov rsi,O_RDWR
    syscall
    mov [descriptor],rax


    mov rax,85
    mov rdi,filename2
    mov rsi,sys_IRUSR | sys_IWUSR
    syscall
    mov [descriptor2],rax 

    mov rax,85
    mov rdi,filename3
    mov rsi,sys_IRUSR | sys_IWUSR
    syscall
    mov [descriptor3],rax 

    call readInput

    mov rax,3
    mov rdi,[descriptor]    ;close input file
    syscall

    mov rax,3
    mov rdi,[descriptor2]
    syscall

    mov rax,3
    mov rdi,[descriptor3]
    syscall

    ret


readInput:
    mov rbx,command
bodyrI:
    mov rax,0
    mov rdi,[descriptor]
    mov rsi,rbx
    mov rdx,1
    syscall


    cmp rax,rdx
    jl endOfFile


    cmp byte [rbx],0xA             ;if newline then we have read a line. end of our command is the newline character
    je executeCommand

    inc rbx

    jmp bodyrI


executeCommand:
    call parse

    mov rbx,command
    jmp bodyrI

endOfFile:
    mov byte [rbx],0xA          ;add newline to the end of the last command
    mov r15,-10                 ;for our last command so that we dont print newline
    call parse

    ret








parse:
    print command
    init                    ;this intializes our machine code bytes to newline
    push rax
    push rbx
    push rcx
    push rsi
    push rdi
    push r8
    push r9

    mov rax,0
    mov rbx,0               ;flag for comma between operands.rbx=0 then one operand. rbx=1 then two operands
    mov rcx,1               ;holds integer 1
    mov r8,-1               ;r8 is flag for first operand. r8=-1 means it doesnt exist. r8=0 means its register. r8=1 means its memory.
    mov r9,-1               ;r9 is flag for second operand. r9=0 might mean its data
    mov rsi,command         ;rsi points to start of command
    mov rdi,instruction     ;rdi points to start of instruction
;we read instruction and store it
inst_parse:              
    cmp byte [rsi],0xA      ;if we reach newline then there are 0 operands 
    je zeroOperands_parse

    cmp byte [rsi],0x20     ;if we reach space then there are 1 or 2 operands
    je operands_parse

    mov al,[rsi]
    mov [rdi],al
    inc rdi
    inc rsi
    jmp inst_parse

zeroOperands_parse:
    mov al,0xA
    mov [rdi],al            ;end of instruction ends with newline
    call zeroOperand
    jmp end_parse

operands_parse:
    mov al,0xA
    mov [rdi],al            ;end of instruction ends with newline
    inc rsi                 ;rsi now points to start of operands

    mov rdi,operand1
    mov r8,0                ;first operand is register until proven otherwise
operand_parse:
    mov al,[rsi]

    cmp al,0xA
    je newline_parse
    cmp al,0x20             ;if there is space it means that operand is memory
    je space_parse
    cmp al,','
    je comma_parse

    mov [rdi],al
    inc rsi
    inc rdi
    jmp operand_parse

space_parse:
    mov [rdi],al
    inc rsi
    inc rdi

    cmp rbx,0
    je space1_parse
    jmp space2_parse
space1_parse:
    mov r8,1
    jmp operand_parse
space2_parse:
    mov r9,1
    jmp operand_parse
comma_parse:
    mov byte [rdi],0xA
    mov rbx,1
    mov rdi,operand2
    inc rsi
    mov r9,0
    jmp operand_parse
    
newline_parse:
    mov byte [rdi],0xA      ;end operand with newline
    cmp rbx,1
    je twoOperands_parse
    jmp oneOperands_parse

oneOperands_parse:
    member instruction,shift
    cmp rax,1
    je shift_parse
    checkNumber operand1
    cmp rax,1
    je dataone_parse
    jmp tempone_parse
dataone_parse:
    mov r8,2
tempone_parse:
    call oneOperand
    jmp end_parse
shift_parse:
    mov r9,2
    copy one,operand2
    call twoOperand
    jmp end_parse

twoOperands_parse:
    checkNumber operand2
    cmp rax,1
    je data_parse
    jmp temp_parse
data_parse:
    mov r9,2                ;second operand is immediate data
temp_parse:
    call twoOperand
    jmp end_parse



end_parse:
    call hexCode
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rcx
    pop rbx
    pop rax

    ret



;result hex
hexCode:
    mov rdi,hex
    binToHex prefix
    binToHex rex
    binToHex opcode
    binToHex modrm
    binToHex sib
    copy displacement,rdi
    copy data,rdi
    mov byte [rdi],0xA
    len hex

    mov rdi,[descriptor2]
    mov rsi,hex
    mov rdx,rax
    mov rax,1
    syscall

    mov rax,1
    mov rdi,[descriptor2]
    mov rsi,space
    mov rdx,1
    syscall

    len command
    cmp r15,-10
    jne last1
    jmp elselast1
last1:
    inc rax
elselast1:
    mov rdi,[descriptor2]
    mov rsi,command
    mov rdx,rax
    mov rax,1
    syscall

    hexToBin

    len binary
    cmp r15,-10
    jne last2
    jmp elselast2
last2:
    inc rax
elselast2:
    mov rdi,[descriptor3]
    mov rsi,binary
    mov rdx,rax
    mov rax,1
    syscall

    print hex
    ret






;this function handles 0 operand instructions
zeroOperand:
    search instruction,zeroOperands,opcode,0
    ret





;this function handles 1 operand instructions
oneOperand:
    cmp r8,2
    je data_oneOperand                          ;if r8=2 then our operand is data. our instruction is either push,ret,jmp.

    search instruction,oneOperands,opcode,0     ;store opcode of instruction
    search instruction,regOne,reg,0             ;store reg of instruction

    cmp r8,1                                    ;if r8=0 then its regsiter. if r8=1 then its memory
    je mem_oneOperand
    jmp reg_oneOperand

data_oneOperand:
    compare instruction,i_ret
    cmp rax,1
    je retdata
    jmp pushdata
retdata:
    search instruction,oneOperands,opcode,0
    setDispData operand1,4,data
    ret
pushdata:
    checkDisp operand1
    cmp rax,2
    je push8data
    jmp push64data
push8data:
    search instruction,oneOperands,opcode,2
    setDispData operand1,rax,data
    ret
push64data:
    search instruction,oneOperands,opcode,3
    setDispData operand1,rax,data
    ret

reg_oneOperand:
    member instruction,pp
    cmp rax,1
    je ppreg
    compare instruction,i_jmp
    cmp rax,1
    je jmpreg
    compare instruction,i_call
    cmp rax,1
    je callreg


    registerSize operand1                   ;this gets register size and store it in reg_bit

    copy mod4,mod                           ;mod is 11 in this cased so we store 11 in mod
    search operand1,registers,rm,0          ;we get code of register and store it in rm
    setModrm                                ;this macro sets modrm byte

    newRegister operand1,b                  ;this macro checks if register is new or not. if its new we store 1 in b bit. b bit is in rex

    jmp end_oneOperand

jmpreg:
    search instruction,oneOperands,opcode,2
    jmp calljmpreg
callreg:
    search instruction,oneOperands,opcode,1
    jmp calljmpreg
calljmpreg:
    search instruction,regOne,reg,0
    copy mod4,mod
    search operand1,registers,rm,0
    setModrm
    registerSize operand1
    setPrefix
    newRegister operand1,b
    mov qword [reg_bit],0
    setRex
    ret

ppreg:
    search instruction,oneOperands,opcode,0
    search operand1,registers,reg,0
    addOpcode reg
    registerSize operand1
    newRegister operand1,b
    setPrefix
    mov qword [reg_bit],0               ;pop gets rex only when there is new register
    setRex
    ret
mem_oneOperand:
    copy operand1,mem_operand
    call memoryHandler

    member instruction,pp
    cmp rax,1
    je ppmem
    compare instruction,i_jmp
    cmp rax,1
    je jmpmem
    compare instruction,i_call
    cmp rax,1
    je callmem

    jmp end_oneOperand

jmpmem:
    search instruction,oneOperands,opcode,3
    jmp calljmpmem
callmem:
    search instruction,oneOperands,opcode,2
    jmp calljmpmem
calljmpmem:                   ;DWORD is weird in jmp and call. it gets 66 prefix and changes reg for some reason
    setPrefix
    mov qword [reg_bit],0
    setRex
    ret

ppmem:
    search instruction,oneOperands,opcode,1
    setPrefix
    mov qword [reg_bit],0
    setRex
    ret


end_oneOperand:
    getw                                    ;this gets w bit and store it in w
    addOpcode w                             ;add opcode is a macro that adds remaining stuff to opcode such as w,s,reg. in this case its w
    setPrefix
    setRex
    ret


;handles memory operand

twoOperand:
    mov rax,r8
    add rax,r9

    cmp rax,0
    je regreg
    cmp rax,1
    je mem
    cmp rax,2
    je regdata
    cmp rax,3
    je memdata

mem:
    cmp r9,1
    je regmem
    jmp memreg

;register to register
regreg:
    compare instruction,i_xchg
    cmp rax,1
    je xchgregreg
    compare instruction,i_imul
    cmp rax,1
    je imulbsregreg
    member instruction,shift
    cmp rax,1
    je shiftregreg
    member instruction,bs
    cmp rax,1
    je imulbsregreg
    jmp elseregreg


shiftregreg:
    search instruction,twoOperands,opcode,2
    registerSize operand1
    getw
    addOpcode w
    copy mod4,mod
    search instruction,regTwo,reg,0
    search operand1,registers,rm,0
    setModrm
    setPrefix
    newRegister operand1,b
    setRex
    ret

imulbsregreg:
    search instruction,twoOperands,opcode,0
    registerSize operand1
    copy mod4,mod
    search operand2,registers,rm,0
    search operand1,registers,reg,0
    setModrm
    setPrefix
    newRegister operand1,r
    newRegister operand2,b
    setRex
    ret
xchgregreg:
    accum operand1
    cmp rax,1
    je alt1_xchgregreg
    accum operand2
    cmp rax,1
    je alt2_xchgregreg
    jmp elseregreg

;first operand is accum
alt1_xchgregreg:
    search instruction,twoOperands,opcode,1
    search operand2,registers,reg,0
    newRegister operand2,b
    jmp end_xchgregreg
;second operand is accum
alt2_xchgregreg:
    search instruction,twoOperands,opcode,1
    search operand1,registers,reg,0
    newRegister operand1,b
    jmp end_xchgregreg
end_xchgregreg:
    addOpcode reg
    registerSize operand1
    setPrefix
    setRex
    ret
elseregreg:


    search instruction,twoOperands,opcode,0
    registerSize operand1
    getw
    addOpcode w
    copy mod4,mod
    search operand2,registers,reg,0
    search operand1,registers,rm,0
    setModrm
    setPrefix
    newRegister operand1,b
    newRegister operand2,r
    setRex
    ret


;memory to register
regmem:
    compare instruction,i_xchg
    cmp rax,1
    je xchgregmem
    compare instruction,i_imul
    cmp rax,1
    je imulbsregmem
    member instruction,bs
    cmp rax,1
    je imulbsregmem
    jmp elseregmem

imulbsregmem:
    search instruction,twoOperands,opcode,1
    registerSize operand1
    search operand1,registers,reg,0
    newRegister operand1,r
    copy operand2,mem_operand
    call memoryHandler
    setRex
    setPrefix
    ret
xchgregmem:
    search instruction,twoOperands,opcode,2
    jmp endregmem
elseregmem:
    search instruction,twoOperands,opcode,1
    jmp endregmem
endregmem:
    registerSize operand1
    search operand1,registers,reg,0
    getw
    addOpcode w
    newRegister operand1,r
    copy operand2,mem_operand
    call memoryHandler
    setRex
    setPrefix
    ret

;register to memory
memreg:
    compare instruction,i_test
    cmp rax,1
    je testmemreg
    compare instruction,i_xadd
    cmp rax,1
    je xaddmemreg
    member instruction,shift
    cmp rax,1
    je shiftmemreg
    jmp elsememreg

shiftmemreg:
    search instruction,twoOperands,opcode,3
    search instruction,regTwo,reg,0
    copy operand1,mem_operand
    call memoryHandler
    getw
    addOpcode w
    setRex
    setPrefix
    ret

testmemreg:
    search instruction,twoOperands,opcode,1
    jmp endmemreg
xaddmemreg:
    search instruction,twoOperands,opcode,1
    jmp endmemreg
elsememreg:
    search instruction,twoOperands,opcode,2
    jmp endmemreg
endmemreg:
    registerSize operand2
    search operand2,registers,reg,0
    getw
    addOpcode w
    newRegister operand2,r
    copy operand1,mem_operand
    call memoryHandler
    setRex
    setPrefix
    ret



;data to register
regdata:
    registerSize operand1
    search operand1,registers,reg,0
    getw
    newRegister operand1,b
    
    compare instruction,move
    cmp rax,1
    je movregdata
    member instruction,addfamily
    cmp rax,1
    je addregdata
    compare instruction,i_test
    cmp rax,1
    je testregdata
    member instruction,shift
    cmp rax,1
    je shiftregdata
    jmp elseregdata

shiftregdata:
    copy mod4,mod
    search instruction,regTwo,reg,0
    search operand1,registers,rm,0
    compare operand2,one
    cmp rax,1
    je shiftoneregdata
    jmp shiftdataregdata
shiftoneregdata:
    search instruction,twoOperands,opcode,0
    addOpcode w
    setModrm
    jmp elseregdata
shiftdataregdata:
    search instruction,twoOperands,opcode,4
    addOpcode w
    setModrm
    setDispData operand2,2,data
    jmp elseregdata

testregdata:
    accum operand1
    cmp rax,1
    je alt_testregdata
    jmp org_testregdata
alt_testregdata:
    search instruction,twoOperands,opcode,3
    addOpcode w
    jmp end_testregdata
org_testregdata:
    search instruction,twoOperands,opcode,2
    addOpcode w 
    copy mod4,mod
    search instruction,regTwo,reg,0
    search operand1,registers,rm,0 
    setModrm
    jmp end_testregdata

end_testregdata:
    dataExtension
    setDispData operand2,rax,data
    jmp elseregdata

movregdata:
    cmp qword [reg_bit],64
    je movreg64data
    jmp movregelsedata

movreg64data:
    search instruction,twoOperands,opcode,3
    addOpcode w
    copy mod4,mod
    search instruction,regTwo,reg,0
    search operand1,registers,rm,0
    setModrm

    dataExtension                               ;this macro handles how much we need to extend for immediate data. this does not handle addfamily

    setDispData operand2,rax,data               ;this macro handles data as well
    jmp elseregdata

movregelsedata:
    search instruction,twoOperands,opcode,4
    addOpcode w
    addOpcode reg

    dataExtension
    setDispData operand2,rax,data
    jmp elseregdata


addregdata:
    gets operand2
    accums operand1
    cmp rax,1
    je alt_addregdata
    jmp org_addregdata
alt_addregdata:
    search instruction,twoOperands,opcode,4
    addOpcode w
    jmp end_addregdata


org_addregdata:
    search instruction,twoOperands,opcode,3
    copy mod4,mod
    search instruction,regTwo,reg,0
    search operand1,registers,rm,0
    setModrm
    addOpcode s 
    addOpcode w 


end_addregdata:
    sdataExtension operand2
    setDispData operand2,rax,data
    jmp elseregdata

elseregdata:
    setPrefix
    setRex
    ret





;data to memory
memdata:
    search instruction,regTwo,reg,0
    copy operand1,mem_operand
    call memoryHandler
    getw

    compare instruction,move
    cmp rax,1
    je movmemdata
    member instruction,addfamily
    cmp rax,1
    je addmemdata
    compare instruction,i_test
    cmp rax,1
    je testmemdata
    member instruction,shift
    cmp rax,1
    je shiftmemdata
    jmp elsememdata

shiftmemdata:
    copy mod4,mod
    search instruction,regTwo,reg,0
    copy operand1,mem_operand
    call memoryHandler
    getw

    compare operand2,one
    cmp rax,1
    je shiftonememdata
    jmp shiftdatamemdata
shiftonememdata:
    search instruction,twoOperands,opcode,1
    addOpcode w
    jmp elsememdata
shiftdatamemdata:
    search instruction,twoOperands,opcode,5
    addOpcode w
    setDispData operand2,2,data
    jmp elsememdata

testmemdata:
    search instruction,twoOperands,opcode,4
    addOpcode w 
    dataExtension
    setDispData operand2,rax,data
    jmp elsememdata
    

movmemdata:
    search instruction,twoOperands,opcode,5
    addOpcode w
    dataExtension
    setDispData operand2,rax,data
    jmp elsememdata
addmemdata:
    search instruction,twoOperands,opcode,5
    gets operand2
    addOpcode s 
    addOpcode w 
    sdataExtension operand2
    setDispData operand2,rax,data

    jmp elsememdata
elsememdata:
    setPrefix
    setRex
    ret








;this piece of shi..code handles our memory
memoryHandler:
    opSize mem_operand
    mov rsi,memory
    mov rdi,temp
part1_mh:
    mov al,[rsi]
    cmp al,0xA      ;it means that its only base or displacement
    je size1_mh
    cmp al,'+'      ;its base and ...
    je next1_mh
    cmp al,'*'      ;its index and scale and ...
    je next2_mh

    mov [rdi],al
    inc rsi
    inc rdi
    jmp part1_mh

;only base or displacement
size1_mh:
    mov byte [rdi],0xA
    checkNumber temp
    cmp rax,1
    je disp_mh
    call regbase_mh
    copy reg_code,rm
    setModrm
    ret


;only displacement. direct addressing
disp_mh:
    setDispData temp,8,displacement
    copy mod1,mod
    copy rm1,rm
    setModrm
    copy scale1,scale
    copy index1,index 
    copy base1,base 
    setSib
    ret

;we store base register code in reg_code and set mod and displacement if needed
regbase_mh:
    push rsi
    checkbp temp
    cmp rax,1
    je bpbase_mh
    jmp elsebase_mh
bpbase_mh:                          ;rbp or ebp base has 00 displacement with mod 01
    copy mod2,mod

    copy mod1,displacement

    jmp endbase_mh
elsebase_mh:
    copy mod1,mod                   ;mod is 00

endbase_mh:
    search temp,registers,reg_code,0            ;register code in rm

    push qword [reg_bit]
    registerSize temp
    mov rax,[reg_bit]
    mov [mem_bit],rax
    pop qword [reg_bit]

    newRegister temp,b
    pop rsi
    ret
    
;we store index register code in index
regindex_mh:
    push rsi
    search temp,registers,index,0

    push qword [reg_bit]
    registerSize temp
    mov rax,[reg_bit]
    mov [mem_bit],rax
    pop qword [reg_bit]

    newRegister temp,x
    pop rsi
    ret

;starts with base and continues
next1_mh:
    mov byte [rdi],0xA
    call regbase_mh
    mov rdi,temp
    inc rsi
part2_mh:
    mov al,[rsi]
    cmp al,0xA          ;base index or base displacement
    je basesize2_mh
    cmp al,'+'          ;then its base index displacement
    je next3_mh
    cmp al,'*'          ;then its base index scale and ...
    je next4_mh
    mov [rdi],al
    inc rdi
    inc rsi
    jmp part2_mh

;base index or base displacement
basesize2_mh:
    mov byte [rdi],0xA
    checkNumber temp
    cmp rax,1
    je basedisp_mh
    jmp baseindex_mh



;base and displacement
basedisp_mh:
    copy reg_code,rm
    print base
    compare base,base1
    cmp rax,1
    je notbase_mh
    compare temp,zero
    cmp rax,1
    je onlybase_mh
notbase_mh:
    checkDisp temp
    setDispData temp,rax,displacement
    setModrm
    ret
onlybase_mh:
    copy mod1,mod
    setModrm
    ret

;base and index
baseindex_mh:
    copy reg_code,base
    call regindex_mh
    copy mod1,mod
    copy rm1,rm
    copy scale1,scale
    setModrm
    setSib
    print base
    ret


;starts with index and scale and continues
next2_mh:
    mov byte [rdi],0xA
    call regindex_mh
    inc rsi
    mov al,[rsi]
    setScale al
    copy mod1,mod
    copy rm1,rm
    setModrm
    copy base1,base
    setSib
    inc rsi
    cmp byte [rsi],0xA
    je indexscale_mh
    jmp indexscaledisp_mh

;index scale
indexscale_mh:
    setDispData rsi,8,displacement
    ret
;index scale disp
indexscaledisp_mh:
    inc rsi
    setDispData rsi,8,displacement
    ret



;base index displacement
next3_mh:
    copy reg_code,base
    call regindex_mh
    inc rsi
    copy rsi,temp
    checkDisp temp
    copy rm1,rm
    copy scale1,scale
    setSib
    print base
    compare base,base1
    cmp rax,1
    je notbaseindex_mh
    compare temp,zero
    cmp rax,1
    je onlybaseindex_mh
notbaseindex_mh:
    checkDisp temp
    setDispData temp,rax,displacement
    setModrm
    ret
onlybaseindex_mh:
    copy mod1,mod
    setModrm
    ret
;base index scale and...
next4_mh:
    copy reg_code,base
    call regindex_mh
    inc rsi
    mov al,[rsi]
    setScale al
    copy rm1,rm
    inc rsi
    cmp byte [rsi],0xA
    je baseindexscale_mh
    jmp baseindexscaledisp_mh
baseindexscale_mh:
    setModrm
    setSib
    ret

baseindexscaledisp_mh:
    setSib
    inc rsi
    compare base,base1
    cmp rax,1
    je notbaseindexscale_mh
    compare rsi,zero
    cmp rax,1
    je onlybaseindexscale_mh
notbaseindexscale_mh:
    checkDisp rsi
    setDispData rsi,rax,displacement
    setModrm
    ret

onlybaseindexscale_mh:
    copy mod1,mod
    setModrm
    ret