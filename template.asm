; In order for this program to work as intended, output must be piped to aplay or /dev/dsp. 
section .data
hello:
    db "Optional ascii art or program start message."
helloLen: equ $-hello
; Note values = period in samples (lower = higher pitch)
; Define notes using equ <byte>, for example :
noteC4: equ 120
noteC5: equ 60
noteE4: equ 96
noteG4: equ 80
noteDb4: equ 114
noteEb4: equ 100
noteF4:  equ 90
noteGb4: equ 84
noteAb4: equ 76
noteBb4: equ 68
noteDb5: equ 56
noteEb5: equ 50
rest: equ 0
halfBeat: equ 600
fullBeat: equ 1200
longBeat: equ 1800

song_data:
 ; Then write your MIDI melody here like so :
dw noteAb4, halfBeat
dw noteEb5, fullBeat
dw rest,     longBeat

song_end:

section .bss 
 buffer: resb 1

section .text
 global _start

_start:
 mov rax,1
 mov rdi,2
 mov rsi,hello
 mov rdx,helloLen
 syscall

_play_song:
 mov rbx, song_data 

.next_note: 
 cmp rbx, song_end
 je _exit
 movzx r12, word [rbx]
 movzx r13, word [rbx+2]
 call _connect_speaker
 add rbx, 4 
 jmp .next_note 

_connect_speaker:
    ; r12 = pitch (period in samples), r13 = total samples to output
    test r12, r12
    jz _silence_speaker   ; pitch 0 = rest
    push r13              ; save total sample count

.sample_loop:
    xor r14, r14          ; reset position within cycle
    mov r15, r12
    shr r15, 1            ; half-cycle = pitch / 2

.half_high:
    mov byte [buffer], 0x3F
    call _write_sample
    inc r14
    dec r13
    jz .done
    cmp r14, r15
    jl .half_high

.half_low:
    mov byte [buffer], 0x00
    call _write_sample
    inc r14
    dec r13
    jz .done
    cmp r14, r12
    jl .half_low

    jmp .sample_loop

.done:
    pop r13
    ret

_silence_speaker:
    ; r13 = duration (number of samples to stay silent)
    push r13
.silence_loop:
    mov byte [buffer], 0x00
    call _write_sample
    dec r13
    jnz .silence_loop
    pop r13
    ret

_write_sample:
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, 1
    syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

_exit:
   mov rax, 60
   xor rdi, rdi
   syscall 
