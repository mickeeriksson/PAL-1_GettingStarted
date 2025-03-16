.setcpu "6502"
.segment "CODE"

.org	$0200		                ; Where program will be loaded


VIA_SAD	    := $1740		        ; A side Data
VIA_PADD	:= $1741		        ; A side Data Direction
VIA_SBD	    := $1742		        ; B side Data
VIA_PBDD	:= $1743		        ; B side Data Direction

; and the GETKEY routine to poll the keyboard
GETKEY      := $1F6A

START:                              ; No Operation, this does nothing

INIT:
                CLD

LOOP:
                JSR LED_REFRESH

                JSR GETKEY

                CMP #$5
                BEQ KEY_5
                CMP #$1             ; DOWN
                BEQ KEY_1
                CMP #$9             ; UP
                BEQ KEY_9
                CMP #$4             ; LEFT
                BEQ KEY_4
                CMP #$6             ; RIGHT
                BEQ KEY_6

                JMP LOOP

KEY_5:                              ; CENTER
                LDA #$40
                LDY #$02
                STA FB,Y
                JMP LOOP

KEY_1:                              ; UP
                LDA #$08
                LDY #$02
                STA FB,Y
                JMP LOOP

KEY_9:                              ; DOWN
                LDA #$01
                LDY #$02
                STA FB,Y
                JMP LOOP

KEY_4:                              ; LEFT
                LDA #$30
                LDY #$02
                STA FB,Y
                JMP LOOP

KEY_6:                              ; RIGHT
                LDA #$06
                LDY #$02
                STA FB,Y
                JMP LOOP



;
;   Refresh the LED segments from the Framebuffer FB
;   Destroys nothing
;
LED_REFRESH:
                                    ; First save current A,X,Y onto Stack
                PHA                 ; Push A to the stack
                TYA                 ; Store Y into A (A=Y)
                PHA                 ; Push A to the stack, which is the value of Y
                TXA                 ; Store X into A (X=A)
                PHA                 ; Push A to the stack, which is the value of X

VIA_LCD_OUT:                        ; Set port A to output Mode (for LED)
                LDA #$7F	        ; Set PA0..PA6 as output, (PA7 as input)
                STA VIA_PADD
                LDA #$1E            ; Set PB0..PB4 as output, (PB5..PB7 as input)
                STA VIA_PBDD

                LDY #$00            ; Start with listentry index=0 (first value)
NEXTSEG:
                LDA #$00            ; Disable output
                STA VIA_SAD         ; Store it into Port A (to select Segement)

                LDA LEDSEL,Y        ; load led-selector value at address LEDSEL + the value in Y-register into Accumulator-register
                STA VIA_SBD         ; Store it into Port B (to select LED)
                LDA FB,Y            ; load the frambuffer value at address FB + the value in Y-register into Accumulator-register
                STA VIA_SAD         ; Store it into Port A (to select Segement)

                LDX #$F             ; A short Delay to let fully load the LED
@delay:         DEX
                BNE @delay

                INY                 ; Increase Y (Y=Y+1)
                CPY #6              ; Compare result of last instruction with 6 (6 segments)
                BCC NEXTSEG         ; Jump to NEXTSEG if Y<6
                ;RTS

VIA_KEYB_IN:                        ; Restore port A to input Mode (for keyboard)
                LDA #$00
                STA VIA_SBD         ; No LED Selected

                LDA #$00	        ; Set PA0..PA7 as input
                STA VIA_PADD
                LDA #$1E            ; Set PB0..PB4 as output, (PB5..PB7 as input)
                STA VIA_PBDD

                                    ; Restore A,X,Y from stack in reverse order
	            PLA                 ; Pop stack into A
	            TAX                 ; Store A into X (X=A)
	            PLA                 ; Pop stack into A
	            TAY                 ; Store A into Y (Y=A)
	            PLA                 ; Pop stack into A
	            RTS                 ; Return, and continue with next instruction after the JSR that got us here!


FB:
	.byte	$00,$00,$00,$00,$00,$00
LEDSEL:
	.byte	$08,$0A,$0C,$0E,$10,$12


