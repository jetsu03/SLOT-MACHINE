section .data
    ; Game messages
    welcome_msg db '🎰 SLOT MACHINE SIMULATOR 🎰', 0xA, 0xA, 0
    welcome_len equ $ - welcome_msg
    
    credits_msg db 'Credits: ', 0
    credits_msg_len equ $ - credits_msg
    
    spin_msg db 0xA, 'Press ENTER to spin (or q to quit): ', 0
    spin_msg_len equ $ - spin_msg
    
    spinning_msg db 0xA, 'Spinning... ', 0
    spinning_msg_len equ $ - spinning_msg
    
    result_msg db 0xA, 'Result: [ ', 0
    result_msg_len equ $ - result_msg
    
    result_end db ' ]', 0xA, 0
    result_end_len equ $ - result_end
    
    win_msg db '🎉 JACKPOT! You won 5 credits! 🎉', 0xA, 0
    win_msg_len equ $ - win_msg
    
    lose_msg db 'No match. Try again!', 0xA, 0
    lose_msg_len equ $ - lose_msg
    
    game_over_msg db 0xA, 'Game Over! No more credits!', 0xA, 0
    game_over_msg_len equ $ - game_over_msg
    
    quit_msg db 0xA, '👋 Thanks for playing!', 0xA, 0
    quit_msg_len equ $ - quit_msg
    
    newline db 0xA, 0
    newline_len equ $ - newline
    
    space db ' ', 0
    space_len equ $ - space
    
    ; Slot symbols
    symbols db 'A', 'B', 'C', 'X', '7'
    symbols_count equ 5
    
    ; Random seed file
    urandom_path db '/dev/urandom', 0

section .bss
    credits resb 4          ; Player credits (as integer)
    input_buffer resb 2     ; Buffer for user input
    random_buffer resb 4    ; Buffer for random data
    slot_results resb 3     ; Three slot results
    credits_str resb 12     ; String representation of credits
    urandom_fd resb 4       ; File descriptor for /dev/urandom

section .text
    global _start

_start:
    ; Initialize credits to 5
    mov dword [credits], 5
    
    ; Open /dev/urandom for randomness
    call open_urandom
    
    ; Display welcome message
    call print_welcome
    
game_loop:
    ; Check if credits > 0
    mov eax, [credits]
    cmp eax, 0
    jle game_over
    
    ; Display current credits
    call display_credits
    
    ; Prompt for spin
    call prompt_spin
    
    ; Get user input
    call get_input
    
    ; Check if user wants to quit
    mov al, [input_buffer]
    cmp al, 'q'
    je quit_game
    cmp al, 'Q'
    je quit_game
    
    ; Deduct 1 credit for spin
    dec dword [credits]
    
    ; Show spinning message
    call show_spinning
    
    ; Generate 3 random symbols
    call generate_symbols
    
    ; Display results
    call display_results
    
    ; Check for win
    call check_win
    
    jmp game_loop

game_over:
    ; Display game over message
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, game_over_msg
    mov rdx, game_over_msg_len
    syscall
    jmp exit_program

quit_game:
    ; Display quit message
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, quit_msg
    mov rdx, quit_msg_len
    syscall

exit_program:
    ; Close urandom file
    mov rax, 3              ; sys_close
    mov rdi, [urandom_fd]
    syscall
    
    ; Exit program
    mov rax, 60             ; sys_exit
    mov rdi, 0
    syscall

; Function to open /dev/urandom
open_urandom:
    mov rax, 2              ; sys_open
    mov rdi, urandom_path
    mov rsi, 0              ; O_RDONLY
    syscall
    mov [urandom_fd], eax
    ret

; Function to print welcome message
print_welcome:
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, welcome_msg
    mov rdx, welcome_len
    syscall
    ret

; Function to display current credits
display_credits:
    ; Print "Credits: " message
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, credits_msg
    mov rdx, credits_msg_len
    syscall
    
    ; Convert credits to string and print
    mov eax, [credits]
    call int_to_string
    
    ; Print newline
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, newline
    mov rdx, newline_len
    syscall
    ret

; Function to prompt for spin
prompt_spin:
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, spin_msg
    mov rdx, spin_msg_len
    syscall
    ret

; Function to get user input
get_input:
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, input_buffer
    mov rdx, 2
    syscall
    ret

; Function to show spinning message
show_spinning:
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, spinning_msg
    mov rdx, spinning_msg_len
    syscall
    ret

; Function to generate 3 random symbols
generate_symbols:
    ; Generate first symbol
    call get_random_byte
    mov bl, al
    mov al, 0
    mov al, bl
    xor rdx, rdx
    mov rcx, symbols_count
    div rcx
    mov al, [symbols + rdx]
    mov [slot_results], al
    
    ; Generate second symbol
    call get_random_byte
    mov bl, al
    mov al, 0
    mov al, bl
    xor rdx, rdx
    mov rcx, symbols_count
    div rcx
    mov al, [symbols + rdx]
    mov [slot_results + 1], al
    
    ; Generate third symbol
    call get_random_byte
    mov bl, al
    mov al, 0
    mov al, bl
    xor rdx, rdx
    mov rcx, symbols_count
    div rcx
    mov al, [symbols + rdx]
    mov [slot_results + 2], al
    ret

; Function to get a random byte
get_random_byte:
    mov rax, 0              ; sys_read
    mov rdi, [urandom_fd]
    mov rsi, random_buffer
    mov rdx, 1
    syscall
    mov al, [random_buffer]
    ret

; Function to display slot results
display_results:
    ; Print "Result: [ "
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, result_msg
    mov rdx, result_msg_len
    syscall
    
    ; Print first symbol
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, slot_results
    mov rdx, 1
    syscall
    
    ; Print space
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, space
    mov rdx, space_len
    syscall
    
    ; Print second symbol
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, slot_results + 1
    mov rdx, 1
    syscall
    
    ; Print space
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, space
    mov rdx, space_len
    syscall
    
    ; Print third symbol
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, slot_results + 2
    mov rdx, 1
    syscall
    
    ; Print " ]"
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, result_end
    mov rdx, result_end_len
    syscall
    ret

; Function to check for win
check_win:
    ; Compare all three symbols
    mov al, [slot_results]
    mov bl, [slot_results + 1]
    mov cl, [slot_results + 2]
    
    cmp al, bl
    jne no_win
    cmp bl, cl
    jne no_win
    
    ; All match - player wins!
    add dword [credits], 5
    
    ; Display win message
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, win_msg
    mov rdx, win_msg_len
    syscall
    ret

no_win:
    ; Display lose message
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, lose_msg
    mov rdx, lose_msg_len
    syscall
    ret

; Function to convert integer to string and print
int_to_string:
    ; Simple implementation for small numbers (0-99)
    ; Input: eax = number to convert
    push rbx
    push rcx
    push rdi
    push rsi
    
    mov rbx, 10
    xor rcx, rcx            ; digit counter
    mov rdi, credits_str + 11 ; point to end of buffer
    mov byte [rdi], 0       ; null terminator
    
convert_loop:
    xor rdx, rdx
    div rbx                 ; divide by 10
    add dl, '0'             ; convert remainder to ASCII
    dec rdi
    mov [rdi], dl
    inc rcx                 ; increment digit count
    test eax, eax
    jnz convert_loop
    
    ; Print the string
    mov rax, 1              ; sys_write
    push rdi                ; save string start
    mov rdi, 1              ; stdout
    pop rsi                 ; string start
    mov rdx, rcx            ; length
    syscall
    
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret