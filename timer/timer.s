.setcpu "6502"
.segment "CODE"

.org	$0200		                ; Where program will be loaded

C1024E      := $174F           ; Div by 1024 counter, enable intr
SCANS       := $1F1F           ; SCANS ROM Routine
INCPT       := $1F63           ; INCPT ROM Routine

TMR_CNT	    := $40	           ; Zero page variable to hold timer counter

START:                              ; No Operation, this does nothing

                LDA #<INTSVC
                STA $17FE
                LDA #>INTSVC
                STA $17FF

                LDA #$60
                STA TMR_CNT


                LDA #$08
                STA C1024E

                CLI


DISP:
                JMP DISP

INTSVC:
                DEC TMR_CNT
                BNE EXITINTSVC
                LDA #$60        ; if timer is 20 hz
                STA TMR_CNT     ; reset counter to 0x14
                JSR INCPT

EXITINTSVC:
                JSR SCANS
                LDA #$08
                STA C1024E
                RTI

