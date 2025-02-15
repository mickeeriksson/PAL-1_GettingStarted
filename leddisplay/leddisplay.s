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

SHOWCHAR:
                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD

                LDA #$49            ; Show three bars, upper, middle, lower
                STA VIA_SAD


HOLD:
                JMP HOLD            ; Jump to adress HOLD
