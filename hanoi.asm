section .data                         
    output:
                          db        "Mova o disco "   
        disco:            db        " "
                          db        " da torre "                      
        torre_saida:      db        " "  
                          db        " para a torre "     
        torre_origem:     db        " ", 0xa  ;
        
        lenght            equ       $-output
        
    msg_prompt db 'Digite a quantidade de discos: ', 0xa
    len_prompt equ $-msg_prompt
    
    msg_complete db 'Programa encerrado! ', 0xa
    len_complete equ $-msg_complete

section .bss
    buffer_discos resb 128

section .text                      

    global _start

    _start:        
        ; Exibir mensagem de prompt
        mov edx, len_prompt        ; comprimento da mensagem
        mov ecx, msg_prompt        ; endereço da mensagem
        mov ebx, 1                 ; saída padrão (stdout - terminal)
        mov eax, 4                 ; código para sys_write
        int 0x80
        
        ; Ler input
        mov edx, 128               ; tamanho máximo do input em bytes
        mov ecx, buffer_discos     ; endereço do buffer para armazenar
        mov ebx, 0                 ; entrada padrão (stdin - terminal input)
        mov eax, 3                 ; código para sys_read
        int 0x80
        
        ; Converter o input para número
        mov edx, buffer_discos     ; endereço do buffer
        call atoi                  ; chama a função atoi para converter a string em número
        
        ; Configurar os parâmetros iniciais para a função hanoi
        push dword 2               ; Torre Auxiliar
        push dword 3               ; Torre Destino
        push dword 1               ; Torre Origem
        push eax                   ; número de discos (obtido do input)

        call hanoi                 ; chama a função hanoi

        ; Finalizar o programa
        jmp exit

    hanoi: 
        push ebp                   ; salva o valor atual de ebp
        mov ebp, esp               ; atualiza ebp para o valor atual de esp

        mov eax, [ebp+8]           ; carrega o número de discos da Torre de origem em eax
        
        cmp eax, 0                 ; verifica se há discos restantes na Torre de origem
        je desemp                  ; se não houver, pula para desemp

        ; Primeira chamada recursiva    
        push dword [ebp+16]        ; empilha a Torre Auxiliar
        push dword [ebp+20]        ; empilha a Torre Destino
        push dword [ebp+12]        ; empilha a Torre Origem
        dec eax                    ; decrementa o número de discos
        push dword eax             ; empilha o número de discos restantes
        call hanoi                 ; chama a função hanoi recursivamente

        ; Imprimir movimento
        push dword [ebp+16]        ; empilha a Torre de Destino
        push dword [ebp+12]        ; empilha a Torre de Origem
        push dword [ebp+8]         ; empilha o número do disco
        call imprime               ; chama a função imprime

        ; Segunda chamada recursiva
        push dword [ebp+12]        ; empilha a Torre Origem
        push dword [ebp+16]        ; empilha a Torre Auxiliar
        push dword [ebp+20]        ; empilha a Torre Destino
        mov eax, [ebp+8]           ; carrega o número de discos restantes
        dec eax                    ; decrementa o número de discos
        push dword eax             ; empilha o número de discos restantes
        call hanoi                 ; chama a função hanoi recursivamente

    desemp: 
        mov esp, ebp               ; restaura o valor original de esp
        pop ebp                    ; restaura o valor original de ebp
        ret                        ; retorna da função

    imprime:
        push ebp                   ; salva o valor atual de ebp
        mov ebp, esp               ; atualiza ebp para o valor atual de esp
        
        mov eax, [ebp + 8]         ; carrega o número do disco
        add al, 48                 ; converte para ASCII
        mov [disco], al            ; armazena no campo disco

        mov eax, [ebp + 12]        ; carrega a Torre de origem
        add al, 64                 ; converte para ASCII
        mov [torre_saida], al      ; armazena no campo torre_saida

        mov eax, [ebp + 16]        ; carrega a Torre de destino
        add al, 64                 ; converte para ASCII
        mov [torre_origem], al        ; armazena no campo torre_ida

        mov edx, lenght            ; comprimento da mensagem
        mov ecx, output            ; endereço da mensagem
        mov ebx, 1                 ; saída padrão (stdout)
        mov eax, 4                 ; código para sys_write
        int 128                    ; interrupção para escrever

        mov esp, ebp               ; restaura o valor original de esp
        pop ebp                    ; restaura o valor original de ebp
        ret                        ; retorna da função
    
    atoi:
        xor eax, eax               ; limpa o registrador eax
        mov ebx, 10                ; define a base decimal (10)
        
        .loop:
            movzx ecx, byte [edx]  ; carrega um byte da string para ecx
            inc edx                ; avança para o próximo caractere
            cmp ecx, '0'           ; compara com '0'
            jb .done               ; se menor, pula para .done
            cmp ecx, '9'           ; compara com '9'
            ja .done               ; se maior, pula para .done
            
            sub ecx, '0'           ; converte de ASCII para valor numérico
            imul eax, ebx          ; multiplica eax por 10
            add eax, ecx           ; adiciona o dígito convertido
            jmp .loop              ; repete o loop
        
        .done:
            ret                    ; retorna da função

    exit:
        ; Exibir mensagem de conclusão
        mov edx, len_complete      ; comprimento da mensagem
        mov ecx, msg_complete      ; endereço da mensagem
        mov ebx, 1                 ; saída padrão (stdout - terminal)
        mov eax, 4                 ; código para sys_write
        int 0x80
    
        ; Sair do programa
        mov eax, 1                 ; código para sys_exit
        mov ebx, 0                 ; código de saída
        int 128                    ; interrupção para sair do programa
