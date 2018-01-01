; Universidade Federal do Espírito Santo
; Centro Universitário Norte do Espírito Santo
; Trabalho prático de Arquitetura de Computadores - 2017/2
; Autores: Elyabe Alves e Thayza Sacconi 


global main
extern scanf, printf, atoi
SECTION .data
	fmtNum db '%s', 0
	ftmNum_saida db '%s', 10, 0
	fmt_int db '%d', 10, 0
	fmt_double db 'num = %.10lf', 10, 0
	fmt_caracter db '%c',0
	msgErroDiv db 'Error :(', 0x0a, 0

	stringSemPonto:  db '0000000000000000000000000000000000000000000',0x0D,0x0a,0

	tam db 0
	pot dq 1.0
	dez dq 10.0
	zero db 0

SECTION .bss
	source resb 255
	operandoA resq 1
	operandoB resq 1

SECTION .TEXT
;imprime double em xmm0
imprimir_double:
	mov rdi, fmt_double
    mov rax, 1
    call printf
    ret

;imprime inteiro em rsi
imprimir_inteiro:
    mov rdi, fmt_int
    mov rax, 0
    call printf
    ret

;imprime string em rsi
imprimir_string:
	mov rdi, ftmNum_saida
    mov rax, 0
    call printf
    ret


;lê entrada como string e salva na string source
le_entrada:
	mov     edx, 255        ;número de caracteres lidos
    mov     ecx, source    
    mov     ebx, 0          ;Entrada padrão
    mov     eax, 3          ; SYS_READ (kernel opcode 3)
    int     80h
    ret

;CONVERTER
;Remove o ponto da string transformando "-45.7" => "-457"
;rdx : endereço da string em rdx
;rcx : endereço da string nova
converter:
    lea rdi, [rel rdx]
	lea rsi, [rel rcx]
	cld

	;cuida das potencias de 10
	mov rax, 1
	cvtsi2sd xmm0, rax

	;Flag que indica se achou o ponto
	mov ah, '0' 			

	Loop:
	cmp ah, '1'
	jne cont
	mulsd xmm0, [dez]

	cont:
	
	lodsb       ;carrega o caracter no endereço rdi 
	stosb       ;Salva o caracter no registrador al

	;Se achar o ponto ignora e passa pro próximo
	cmp  al, '.' 	
	jne  LoopBack
	mov ah, '1'

	lodsb 	; carrega próximo caracter
	stosb 	;salva caracter em al

	sub rdi, 2  
	mov byte [rdi], al   ;grava o caracter na nova string
	inc rdi
	

	LoopBack:
	cmp al, 0x0a	
	jne Loop

	;salva a potência de normalização
	movq [pot], xmm0

	;Chama a função de conversão string => inteiro
	xor rax, rax
	
	;mov rdi, stringSemPonto 
	;call atoi
	
	mov rcx, stringSemPonto
	call myAtoi
	
	cmp rax, 0

	cvtsi2sd xmm0, rax     ;converte inteiro para double 
	divsd xmm0, [pot] 		;normaliza o resultado

	ret


; MYATOY
; Recebe um número em uma string e converte em inteiro considerando que a string é não vazia
; rcx : endereco da string a ser convertida
; rax : inteiro

myAtoi:

	mov rdi, 0
	mov rbx,10      
    xor rax, rax    
    ;mov rcx, ascii 

    LL1:           
    movzx rdx, byte [rcx]   ; carrega em rdx o caracter correpondente

    test rdx, rdx    ;teste se palavra é vazia
    jz final        

    cmp rdx, 0x0a	 ;verifica se caracter é '\n' 
    jz final

    cmp rdx, 0		;verifica se é fim de string
    jz final

    cmp rdx, '-'	;verifica se número digitado é negativo
    jnz continue

    mov rdi, 1		
    inc rcx
    jmp LL1

    continue:
    inc rcx         

    ;Verifica a validade dos caracteres digitados
    cmp rdx, '0'    
    jb done

    cmp rdx, '9'    
    ja done

    ;Conversão usando código ASCII
    sub rdx, '0'  

    add rax, rax
    lea rax, [rax + rax * 4]

    add rax, rdx    

    jmp LL1  ; repeat

    final:
    cmp rdi, 1
    jnz done

    imul rax, -1

    done:
    ret

main:
;config
	push    rbp
	mov     rbp, rsp
	sub     rsp, 32
	
ler_valores:

	call le_entrada

    movzx rcx, byte[source]
    cmp rcx, 0x0a
    je fim

 	sub rsp, 8    
		mov rdx, stringSemPonto 
		mov rcx, source
		call converter
		atrib_opA:
		movq [operandoA], xmm0
    add rsp, 8   


;LENDO SEGUNDO OPERANDO

ler_valor2:

	call le_entrada

    movzx rcx, byte[source]
    cmp rcx, 0x0a
    je fim

 	sub rsp, 8    
		mov rdx, stringSemPonto 
		mov rcx, source
		call converter
		atrib_opB:
		movq [operandoB], xmm0
    add rsp, 8   

show:
	sub rsp, 8
		movq xmm0, [operandoA]
		call imprimir_double
		movq xmm0, [operandoB]
		call imprimir_double
	add rsp, 8

	call le_entrada

    movzx rcx, byte[source]
    cmp rcx, 0x0a
    je fim


sub rsp, 8
def_operador:     

    movq xmm0, [operandoA]
    
    cmp rcx, '+'
    jz adicao

    cmp rcx, '-'
    jz subtracao

    cmp rcx, '*'
    jz multiplicacao

    cmp rcx, '/'
    jz divisao


subtracao:
    subsd xmm0, [operandoB]
    jmp exibir

adicao:
   addsd xmm0, [operandoB]
  jmp exibir

multiplicacao:
  mulsd xmm0, [operandoB]
  jmp exibir

divisao:
	mov rsi, [operandoB]
	cmp rsi, 0
	jz erro_div
	divsd xmm0, [operandoB]


exibir:
		movq  [operandoA], xmm0
		call imprimir_double

	add rsp, 8
jmp ler_valor2   

erro_div:
	mov rsi, msgErroDiv
	call imprimir_string

fim:
	mov     eax, 0
	add     rsp, 32
	pop     rbp
	ret


    ;fim
    mov eax, 0x60
    xor edi, edi
    syscall 
