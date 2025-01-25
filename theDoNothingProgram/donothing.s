.setcpu "6502"
.segment "CODE"
.org	$0200		; Where program will be loaded

START:          NOP                 ; No Operation, this does nothing
                JMP START           ; Jump to adress START

