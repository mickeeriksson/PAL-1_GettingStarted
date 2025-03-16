# The Framebuffer tutorial

Lets build a framebuffer. In a modern computer the framebuffer is the videomemory where the color of every pixel on the display is stored. In out case the framebuffer is only 6 bytes large holding the value of every LED-segment. In out case the LED dont have a memory and it will also possible to display a single LED at once. So to make it look like they are actuallt showing at once we will build a refresh-method that copies the values from the frambuffer to the VIA-chips to light-up the leds. If we do this fast enough the eye wont detect that there actually is only one LED at a time showing.

## A note about the 6530 Chip

The LEDS are actually sharing the RIOT port A with the keyboard. Therefore it is needed to switch the datadirection of port A between input and output mode. We ignored this in previously tutorials, but now we will reset the port A for input after every screen-refresh to prepere for the upcoming tutorial about the keybord.

## Then some coding
Lets do som coding.

First we need an actual framebuffer of 6 bytes to hold the values that the refresher should use when setting the LED'segment. By using a framebuffer we separate the refreshlogic and electronics wiring from the other code whch only need to write a byte into a place in the framebuffer to get it out on the screen. 

Like in the spinner tutorial we also define a ledselector-array that coverts a LED-position into RIOT-port output values.

The last dataarray is the animation. It holds all the "frames" for the warp effect. Altough a single frame is only 6 bytes, by expanding the frame to 8 bytes we can just do a shift-left by 3 operation of the frameindex to get the starting position of the next frame of the animation. 

```
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
```

The next step is to build a helper that clears out the frambuffer to clear the screen. Nothing fancy here, it just iterates over the framebuffers 6 bytes and sets them to 0x00. Remember the STA FB,Y - instruction? It uses an addressing mode where it stores register A to the memory address of (FB+Y).

```
;
;  Clears the Framebuffer
;  Destroys A & Y
;
FB_CLEAR:
                LDY #$00            ; Start with pos 0
@next_pos:
                LDA #$00            ; Clear all segments at current pos
                STA FB,Y            ; in FB with index Y

                INY                 ; Increase Y (Y=Y+1)
                CPY #6              ; Compare result of last instruction with 6 (6 segments)
                BCC @next_pos       ; Jump to clear next pos if Y<6
                RTS
```

Then the actual refresh-subroutine. This is the longest code in the tutorial. Lets go through it.

First and last in the subroutine is the code for pushing/popping the registers to the stack. So that no registers of the caller is destroyed.

Next is the code to set the RIOT ports to Output mode so that we direct it to control the LEDs. We will do this every refresh, since the ports might be used for keyboard- or serial handling between refreshes.

Then is a loop where we iterate the 6 positions of the frambuffer and write the values to the RIOT-port to set the LED. This is no different from previos tutorial, except that we do a short delayloop to let the LED be fully loaded before moving on the the next LED.

Finally before popping the stack, we reset the RIOT port to keyboard mode. 

```
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
                LDA #$7F            ; Set PA0..PA6 as output, (PA7 as input)
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

                LDA #$00            ; Set PA0..PA7 as input
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
```

Now we have everything needed to write the actual control-logic for the animation. Some notes about the new 6502/assembler used.

Remember that the 6502 only has 3 registers A,X,Y? In this case it turns out we also need a 4th register to hold the current animation step. To out rescue is are the 6502 zero-page registers. It is not actual registers, but memory positions i the first 256 bytes of memory. There is a special addressing mode for zero-page which makes it a very powerful memory. In out case we defined 0x40 as a zero-page memory position to hold our WARP_STEP variable.

In the beginning of each NEXT_WARP_STEP iteration A will hold the current WARP_STEP so we save it into ZP (zero page)-memory. We then do 3 shift left to do a multiply by 8 to get the starting position in the ANIM_STEP array and stores it into X to be used as an index-register.

Then we do the actual copying from ANIM_STEP to FB using X & Y as index registers to LDA/STA opcodes.

After every step we need to do a delay before rendering next frame. Notice how we call LED_REFRESH in every delayiteration. This is to not led the LED diminish while doing the waiting. 

What about the @1: ?? Why not a real label? This is what the ca65 assembler calls a [cheap local label](https://cc65.github.io/doc/ca65.html#ss6.5). They are great when we just need a local delay loop and won't bother with defining a global unique label for it. It also does the code a little cleaner and increases readabillity. 


```
START:                              ; No Operation, this does nothing but tell us this is the START :-)

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

```





The complete program is in [framebuffer.s](./framebuffer.s)

type:

    make
to build the program and convert it into papertape format.

## Lets run it!
* Hook everything up (cables and stuff)
* Reset the PAL-1 Again:
* Press RS on PAL-1
* Press Enter in Terminal
* Enter L (Capital L), (Dont press any other key after L)
* Open Sendfile dialog in your TerminalProgram. Select the file [./framebuffer.ptp](./framebuffer.ptp)
  And send the file as raw/binary content.
* You will see a lot of Hexformated output in the terminal.

Run the program
* type 0200+SPACE, to set the address to 0x0200, out start address
* press G (capital G) (to run the program from the current address)

Be amazed by flying in warp 8! (Warp 9 wasn't reached until the Defiant class was invented)

