; AVR Assembly Decade Counter using K-Map Logic
#include <avr/io.h>
.def temp = r16
.def A = r17
.def B = r18
.def C = r19
.def D = r20
.def W = r21
.def X = r22
.def Y = r23
.def Z = r24
.def d_cnt1 = r25
.def d_cnt2 = r26
.def d_cnt3 = r27
.global main
main:
; Setup Stack Pointer to top of RAM
ldi temp, low(RAMEND)
out _SFR_IO_ADDR(SPL), temp
ldi temp, high(RAMEND)
out _SFR_IO_ADDR(SPH), temp
; DDRD: PD2..PD5 as inputs, PD6..PD7 as outputs
in temp, _SFR_IO_ADDR(DDRD)
ori temp, 0xC0 ; Set PD6, PD7 high
andi temp, 0xC3 ; Set PD2..PD5 low out _SFR_IO_ADDR(DDRD), temp
; DDRB: PB0, PB1, PB5 as outputs
in temp, _SFR_IO_ADDR(DDRB)
ori temp, 0x23 ; Set PB0, PB1, PB5 high
out _SFR_IO_ADDR(DDRB), temp
main_loop:
; Read Port D Pin Register
in temp, _SFR_IO_ADDR(PIND)
; Isolate A (PD2)
mov A, temp
lsr A
lsr A
andi A, 0x01
; Isolate B (PD3)
mov B, temp
lsr B
lsr B
lsr B
andi B, 0x01
; Isolate C (PD4)
mov C, temp
swap C ; Swap nibbles: bit 4 moves to bit 0
andi C, 0x01
; Isolate D (PD5)
mov D, temp
swap D
lsr D ; Bit 5 moves to bit 0
andi D, 0x01
; --- K-Map Logic Computation ---
; W = !A
mov W, A
ldi temp, 0x01
eor W, temp ; Bitwise invert A (W = A XOR 1)
; X = (B AND !A) OR (!D AND !B AND A)
mov temp, A
eor temp, 0x01 ; temp = !A
mov X, B
and X, temp ; X = B AND !A mov r0, D
eor r0, 0x01 ; r0 = !D
mov r1, B
eor r1, 0x01 ; r1 = !B
and r0, r1 ; r0 = !D AND !B
and r0, A ; r0 = !D AND !B AND A
or X, r0 ; X = (B AND !A) OR (!D AND !B AND A)
; Y = (C AND !A) OR (C AND !B) OR (!C AND B AND A)
mov temp, A
eor temp, 0x01 ; temp = !A
mov Y, C
and Y, temp ; Y = C AND !A
mov r0, B
eor r0, 0x01 ; r0 = !B
and r0, C ; r0 = C AND !B
or Y, r0
mov r0, C
eor r0, 0x01 ; r0 = !C
and r0, B
and r0, A ; r0 = !C AND B AND A
or Y, r0
; Z = (D AND !A) OR (A AND B AND C)
mov temp, A
eor temp, 0x01 ; temp = !A
mov Z, D
and Z, temp ; Z = D AND !A
mov r0, A
and r0, B
and r0, C ; r0 = A AND B AND C
or Z, r0
; --- Output Mapping ---
; Output W -> PD6, X -> PD7
mov temp, W
lsl temp
lsl temp
lsl temp
lsl temp
lsl temp
lsl temp ; Shift W to Bit 6
mov r0, X
lsl r0 lsl r0
lsl r0
lsl r0
lsl r0
lsl r0
lsl r0 ; Shift X to Bit 7
or temp, r0
in r28, _SFR_IO_ADDR(PORTD)
andi r28, 0x3F ; Mask upper 2 bits
or r28, temp
out _SFR_IO_ADDR(PORTD), r28
; Output Y -> PB0, Z -> PB1
mov temp, Y
mov r0, Z
lsl r0 ; Shift Z to Bit 1
or temp, r0
in r28, _SFR_IO_ADDR(PORTB)
andi r28, 0xFC ; Mask lower 2 bits
or r28, temp
out _SFR_IO_ADDR(PORTB), r28
; Pulse Clock HIGH (PB5)
sbi _SFR_IO_ADDR(PORTB), 5
rcall delay_500ms
; Pulse Clock LOW (PB5)
cbi _SFR_IO_ADDR(PORTB), 5
rcall delay_500ms
rjmp main_loop
; Delay Subroutine (~500ms at 16MHz)
delay_500ms:
ldi d_cnt1, 41
ldi d_cnt2, 150
ldi d_cnt3, 128
d_loop:
dec d_cnt3
brne d_loop
dec d_cnt2
brne d_loop
dec d_cnt1
brne d_loop
ret
