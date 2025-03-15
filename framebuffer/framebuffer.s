.setcpu "6502"
.segment "CODE"

.org	$0200		                ; Where program will be loaded


VIA_SAD	    := $1740		        ; A side Data
VIA_PADD	:= $1741		        ; A side Data Direction
VIA_SBD	    := $1742		        ; B side Data
VIA_PBDD	:= $1743		        ; B side Data Direction

;ANIM_STEP_DATA_PTR	:= $FB              ; Pointer to current Warp Step Buffer
WARP_STEP	    := $40	            ; Zero page variable to hold current warp step
                                    ; rom uses ZP 0xEF-0xFF


START:                              ; No Operation, this does nothing

INIT:
                CLD

WARP:                               ; Do "Warp" animation
                LDA #$0

NEXT_WARP_STEP:
                STA WARP_STEP       ; Store 0 to current warp step
                ASL                 ; Multiply by 8 by doing Shift left 3 times
                ASL
                ASL
                CLC
                TAX                 ; Z is now index to animation data

                LDY #$0
COPY_FB_STEP:
                LDA ANIM_STEP,X
                STA FB,Y
                INY
                INX
                CPY #6              ; Compare result of last instruction with 6 (6 segments)
                BCC COPY_FB_STEP    ; Jump to NEXTSEG if Y<6

                LDX #$8F            ; Delay loop before next animation step
@1:             JSR LED_REFRESH
                DEX
                BNE @1

                INC WARP_STEP
                LDA WARP_STEP
                CMP #$7             ; We have 7 warp steps
                BNE NEXT_WARP_STEP

                JMP WARP            ; Repeat animation



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

;
;  Clears the Framebuffer
;  Destroys A & Y
;
FB_CLEAR:
                LDY #$00            ; Start with pos 0
@next_pos:
                LDA #$00            ; Clear all segments at curret pos
                STA FB,Y            ; in FB with index Y

                INY                 ; Increase Y (Y=Y+1)
                CPY #6              ; Compare result of last instruction with 6 (6 segments)
                BCC @next_pos       ; Jump to clear next pos if Y<6
                RTS

FB:
	.byte	$00,$00,$00,$00,$00,$00
LEDSEL:
	.byte	$08,$0A,$0C,$0E,$10,$12

ANIM_STEP:
	.byte	$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$06,$30,$00,$00,$00,$00
	.byte	$00,$00,$36,$36,$00,$00,$00,$00
	.byte	$00,$06,$36,$36,$30,$00,$00,$00
	.byte	$00,$36,$36,$36,$36,$00,$00,$00
	.byte	$06,$36,$36,$36,$36,$30,$00,$00
	.byte	$36,$36,$36,$36,$36,$36,$00,$00

