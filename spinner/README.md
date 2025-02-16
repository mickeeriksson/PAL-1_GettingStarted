# The LED Display tutorial

The purpose of this tutorial is to get some deeper understanding of the 6502 assembly language. To use additional addressing modes and to use subroutines.

## First some theory

Now is a good time to do some reading. A good recommendation is either [How to program the Apple II using 6502 Assembly language](http://retro.hansotten.nl/uploads/books/A2_Hyde_6502_Asm_Lang.pdf) despite the title it is pretty 6502 generic, and also works for our PAL-1 programming. This book is easy to read, so read it up and including chapter 5 to get some knowledge about looping/branching and conditional execution. 
Another good book is [Programming_the_6502](http://retro.hansotten.nl/uploads/books/Zaks_Programming_the_6502.pdf) This book is good because it is a little more thorough on how the CPU work internally. Please read everything up and including chapter 3 (to page 98).

## Then some coding
Now with a better theoretical understanding, lets do som coding.

What if we would like to do a spinner in the first LED, that spins sequentially through all the outer segments of the the LED. The simplest way would probably be to do something like this:

```
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
                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$01            ; Show 1st segment of the spinner
                STA VIA_SAD

                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$02            ; Show 2nd segment of the spinner
                STA VIA_SAD

                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$04            ; Show 3rd segment of the spinner
                STA VIA_SAD

                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$08            ; Show fourth segment of the spinner
                STA VIA_SAD

                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$10            ; Show fifth segment of the spinner
                STA VIA_SAD

                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$20            ; Show sixth segment of the spinner
                STA VIA_SAD

                JMP SPIN            ; Jump to adress SPIN, to repeat everything again

```

But if you build and run this code (you should know how by now), you will notice that the PAL-1 is just showing us a Zero (0) at the first LED. WHY?

The explanation is that it is actually spinning but are doing so with so many laps/second, that the eye wont notice the spins, so everything is felt like it is lightened constantly. We need some sort of delay between every segment light-up.

A delay is a good example of how to use a subroutine. Lets start with the call. To call a subroutine we do a JSR (Jump to subroutine) instruction instead of a JMP. DELAY is the address (label) of where the subroutine starts in memory.

    JSR DELAY

When the 6502 encounters this instruction it first saves the current location (Program Counter) to the stack, to be able to get back and continue to execute the next instruction after the JSR when the subroutine is finished.

Lets continue with the declaration of the subroutine.

```
DELAY:                              ; A simple delay routine
                LDY #100            ; Set register Y to 100 (0x64)
                LDX #255            ; Set register X to 255 (0xFF)
DELAYLOOP:
                NOP                 ; Do nothing
                NOP                 ; Do nothing again
                DEX                 ; Decrement X
                BNE DELAYLOOP       ; Jump to DELAYLOOP if X!=0
                DEY                 ; Decrement Y
                BNE DELAYLOOP       ; Jump to DELAYLOOP if Y!=0
                RTS                 ; Return, and continue with next instruction after the JSR that got us here!
```

The Delay subroutine uses two loops. An outer loops that counts from 100->0 and an inner loop that counts from 255->0. This construction is due to the fact that the 6502 is only able to handle 8bit (max 255) numbers in a single register. So in this case when we want the delay to loop more then 255 times, we need another outer loop  which gives us a total of 25500 loop in our simple delay. If we want to know exactly what this means in seconds, we can lookup the number of cpu-cycles every instruction takes. This is a good resource for this [6502_cycle_times](https://www.nesdev.org/wiki/6502_cycle_times). We also know that the PAL-1 operates with a frequency of 1Mhz, so the rest is just math :-)

Whats new instruction-wise here is the LDY & LDX instructions. They work just like the LDA instruction we used earlier, except that the operate on the X & Y register instrad of the Accumulator-register.

The DEX & DEY instruction decrements X & Y register by 1. (X=X-1)

BNE will do a jump if the previous instruction resulted in a value other then zero. It does that by checking the Z-status flag (explained in the books you read above, you did read them?).

The last instruction RTS, will get us back to the origin code, which called the subroutine. It does that by popping the stored address back from the stack into the PC (Program Counter) 

The complete program after adding the subroutine and a JSR-call between the LED-segment lightup would now look like:

```
.setcpu "6502"
.segment "CODE"

VIA_SAD	    := $1740                ; A side Data
VIA_PADD    := $1741                ; A side Data Direction
VIA_SBD	    := $1742                ; B side Data
VIA_PBDD    := $1743                ; B side Data Direction

.org	$0200                       ; Where program will be loaded


START:                              ; No Operation, this does nothing

INIT_VIA:
                LDA #$7F            ; Set PA0..PA6 as output, (PA7 as input)
                STA VIA_PADD
                LDA #$1E            ; Set PB0..PB4 as output, (PB5..PB7 as input)
                STA VIA_PBDD

SPIN:
                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$01            ; Show 1st segment of the spinner
                STA VIA_SAD
                JSR DELAY

                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$02            ; Show 2nd segment of the spinner
                STA VIA_SAD
                JSR DELAY

                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$04            ; Show 3rd segment of the spinner
                STA VIA_SAD
                JSR DELAY

                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$08            ; Show fourth segment of the spinner
                STA VIA_SAD
                JSR DELAY

                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$10            ; Show fifth segment of the spinner
                STA VIA_SAD
                JSR DELAY

                LDA #$08            ; Set active display to LED1 leftmost display
                STA VIA_SBD
                LDA #$20            ; Show sixth segment of the spinner
                STA VIA_SAD
                JSR DELAY

                JMP SPIN            ; Jump to adress SPIN, to repeat everything again


DELAY:                              ; A simple delay routine
                LDY #100            ; Set register Y to 100 (0x64)
                LDX #255            ; Set register X to 255 (0xFF)
DELAYLOOP:
                NOP                 ; Do nothing
                NOP                 ; Do nothing again
                DEX                 ; Decrement X
                BNE DELAYLOOP       ; Jump to DELAYLOOP if X!=0
                DEY                 ; Decrement Y
                BNE DELAYLOOP       ; Jump to DELAYLOOP if Y!=0
                RTS                 ; Return, and continue with next instruction after the JSR that got us here!
```

If we build and run this code we will get the spinner we expected. 

## A bigger spinner

What if we would like to build a bigger spinner that spins through all 6 LED displays? Just put some extra lines setting the LEDs? Sure! But maybe there is a better way? 

Maybe we can declare a list of all the segment values that should be set, load them in order from the list and set the corresponding led?

The list then needs to be 6+6+2+2 entries long to hold all the segments that should be set. We will defines two such lists. One for declaring which LED should be set, and another list for declaring which segment in that LED that should be set.

The declare a list of bytes in assembler we can simple write the values into RAW memory.

```
LEDLIST:
	.byte	$08,$0A,$0C,$0E,$10,$12,$12,$12,$12,$10,$0E,$0C,$0A,$08,$08,$08
SEGLIST:
	.byte	$01,$01,$01,$01,$01,$01,$02,$04,$08,$08,$08,$08,$08,$08,$10,$08
```
The LEDLIST contains all values to set which LED we will use in each step starting with the leftmost.
The SEGLIST contains all values to set which segment in the LED we will use in each step starting with the top segment in the first LED.

To iterate over the list lets do a simple loop.

```
SPIN:
                LDY #$00            ; Start with listentry index=0 (first value)
NEXTSEG:
                LDA LEDLIST,Y       ; load value at address LEDLIST + the value in Y-register into Accumulator-register
                STA VIA_SBD         ; Store it into Port B (to select LED)
                LDA SEGLIST,Y       ; load value at address SEGLIST + the value in Y-register into Accumulator-register
                STA VIA_SAD         ; Store it into Port A (to select Segement)
                JSR DELAY           ; Wait a little bit

                INY                 ; Increase Y (Y=Y+1)
                CMP #16             ; Compare result of last instruction with 16 (6+6+2+2 segments)
                BCC NEXTSEG         ; Jump to NEXTSEG if Y<16

                JMP SPIN            ; Else restart SPIN Sequence
```

We now have a problem. Out iterator is using the Y register, which is same register used in our delay-subroutine, so lets enhance the delay-subroutine so that it doesnt destroy the contents of Y. To do that we will use the stack as a temporary safe place for the previous value of Y. And while fixing it so that Y will be saved, lets also do it for A and X.

```
DELAY:                              ; A simple delay routine
                                    ; First save current A,X,Y onto Stack
                PHA                 ; Push A to the stack
                TYA                 ; Store Y into A (A=Y)
                PHA                 ; Push A to the stack, which is the value of Y
                TXA                 ; Store X into A (X=A)
                PHA                 ; Push A to the stack, which is the value of X

                LDY #70             ; Set register Y to 70
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
```

In the original 6502 there existed no Push and Pop for X and Y register, therefore we have to use A for pushing and popping X and Y.

The complete program is in [spinner.s](./spinner.s)

type:

    make
to build the program and convert it into papertape format.

## Lets run it!
* Hook everything up (cables and stuff)
* Reset the PAL-1 Again:
* Press RS on PAL-1
* Press Enter in Terminal
* Enter L (Capital L), (Dont press any other key after L)
* Open Sendfile dialog in your TerminalProgram. Select the file [./spinner.ptp](./spinner.ptp)
  And send the file as raw/binary content.
* You will see a lot of Hexformated output in the terminal.

Run the program
* type 0200+SPACE, to set the address to 0x0200, out start address
* press G (capital G) (to run the program from the current address)

The spinner will now use all 6 LED-displays and spin around the PAL-1 LED display!

