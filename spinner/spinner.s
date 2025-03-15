.setcpu "6502"
.segment "CODE"

VIA_SAD	    := $1740		        ; A side Data
VIA_PADD	:= $1741		        ; A side Data Direction
VIA_SBD	    := $1742		        ; B side Data
VIA_PBDD	:= $1743		        ; B side Data Direction

.org	$0200		                ; Where program will be loaded


START:                              ; No Operation, this does nothing

INIT_VIA:
                LDA #$7F	        ; Set PA0..PA6 as output, (PA7 as input)
                STA VIA_PADD
                LDA #$1E            ; Set PB0..PB4 as output, (PB5..PB7 as input)
                STA VIA_PBDD

SPIN:
                LDY #$00            ; Start with listentry index=0 (first value)
NEXTSEG:
                LDA LEDLIST,Y       ; load value at address LEDLIST + the value in Y-register into Accumulator-register
                STA VIA_SBD         ; Store it into Port B (to select LED)
                LDA SEGLIST,Y       ; load value at address SEGLIST + the value in Y-register into Accumulator-register
                STA VIA_SAD         ; Store it into Port A (to select Segement)
                JSR DELAY           ; Wait a little bit

                INY                 ; Increase Y (Y=Y+1)
                CPY #16             ; Compare result of last instruction with 16 (6+6+2+2 segments)
                BCC NEXTSEG         ; Jump to NEXTSEG if Y<16

                JMP SPIN            ; Else restart SPIN Sequence

LEDLIST:
	.byte	$08,$0A,$0C,$0E,$10,$12,$12,$12,$12,$10,$0E,$0C,$0A,$08,$08,$08
SEGLIST:
	.byte	$01,$01,$01,$01,$01,$01,$02,$04,$08,$08,$08,$08,$08,$08,$10,$20


DELAY:                              ; A simple delay routine
                                    ; First save current A,X,Y onto Stack
                PHA                 ; Push A to the stack
                TYA                 ; Store Y into A (A=Y)
                PHA                 ; Push A to the stack, which is the value of Y
                TXA                 ; Store X into A (X=A)
                PHA                 ; Push A to the stack, which is the value of X

                LDY #70		        ; Set register Y to 70
	            LDX #255            ; Set register X to 255
DELAYLOOP:
                NOP                 ; Do nothing
                NOP                 ; Do nothing again
                DEX                 ; Decrement X
	            BNE DELAYLOOP       ; Jump to DELAYLOOP if X!=0
	            DEY                 ; Decrement Y
	            BNE DELAYLOOP       ; Jump to DELAYLOOP if Y!=0

                                    ; Restore A,X,Y from stack in reverse order
	            PLA                 ; Pop stack into A
	            TAX                 ; Store A into X (X=A)
	            PLA                 ; Pop stack into A
	            TAY                 ; Store A into Y (Y=A)
	            PLA                 ; Pop stack into A
	            RTS                 ; Return, and continue with next instruction after the JSR that got us here!