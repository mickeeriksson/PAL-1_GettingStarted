# The LED Display tutorial

The purpose of this tutorial is to understand the electronics of the LED Display. How it is connected to the VIA-circuit and how to use the VIA in 6502-assembly code.

## Lets start with the schematics
When we look at the [schematics](../datasheets/PAL1_schematic.pdf) we can identify the LED1-LED6. each led is driven by a transistor Q1-Q6 which in turn is selected by the output Q4-Q9 from U1 (and [74LS145](../datasheets/sn74ls145.pdf)).
The 74ls145 is a BCD-to-decimal decoder. By setting a binary value to the inputs a single output will be selected (active low). The inputs of the 74ls145 are in turn connected to PB1-PB4 of U7. U7 is a RIOT circuit from MOS technologies and was frequently used in all early Commodore designs. RIOT stands for (RAM I/O and Timer) and is a multipurpose circuit. We will only use the two 8bit I/O ports when controlling the LEDS.
The datasheet for the 6532 is here [6532 datasheet](../datasheets/mos_6532_riot_preliminary_feb_1977.pdf). From the PAL-1 user manual appendix A memory Map, we see that the 6532 is hooked up at the base address 0x1740. This means that the four controlregisters to control I/O port A and B is at:

* 0x1740: Port A data register, write here to set and read pins PA0-PA7 of the 6532
* 0x1741: Port A data direction register. Write here to control if pin PA0-PA7 should be treated as an output or an input. a bit value of 1 means the pin is treated as an output.
* 0x1742: Port B data register, operates exactly as for Port A
* 0x1743: Port B data direction register, operates exactly as for Port A

The PAL-1 is using PA0-PA6 as output (and PA7 as input). This means we should write 0x7F to address 0x1741 to set bit 0-6 of the Port A data direction register.
PAL-1 is also using PB0-PB4 as output (and PB5..PB7 as input). This means we should write 0x1E to address 0x1743 to set bit 0-4 of the Port B data direction register.

When this is done we should have done the needed initialization to start showing stuff on the LEDS. 

To light up a single LED we need to write to both Port B to select which LED we want to light up, and to Port A to set which segments of the LED that should be set.

Lets start with the LED-selection.
To activate LED1 by setting Q4 to 0, we can look at the function table (truth table) in the datasheet. From that we see that wee should set an input value of b0100 to input A-D this should be 0x04 hexadecimal. But beware! Since the 74ls145 is hookup up to PB1-4 instead of PB0-3, we need to shift the value the corresponding one step. So instead of 0x04 we need to write 0x08 (b1000) to the Port B data register in the 6532.
This gives us the following cheat-sheet for setting LED1-LED6
* LED1=0x08
* LED2=0x0A
* LED3=0x0C
* LED4=0x0E
* LED5=0x10
* LED6=0x12

Now to the segments of each LED.
First look at the datasheet of the [HDSP-511A](../datasheets/hdsp511x.pdf) to locate segment a-g. which give us the following layout:

    ---a---
    |     |
    f     b
    |     |
    ---g---
    |     |
    e     c
    |     |
    ---d---

from the schematics we see that segment a-g is in turn hooked up to dataport A pin PA0-PA6 correspondingly. This gives that to set a single segment in led we need to enable the following bits in Port A data register.

* segment a = PA0, bit 0 (0x01)
* segment b = PA1, bit 1 (0x02)
* segment c = PA2, bit 2 (0x04)
* segment d = PA3, bit 3 (0x08)
* segment e = PA4, bit 4 (0x10)
* segment f = PA5, bit 5 (0x20)
* segment g = PA6, bit 6 (0x40)
 
For our tutorial lets set the three bars segment a+g+d. ie bit (0+3+6). this means a binary value of b1001001 (hexvalue of 0x49).

Now we have all the theoretical background to start coding.  

## Lets start coding!

First define the needed registers of the 6532.

    VIA_SAD	    := $1740		; A side Data
    VIA_PADD    := $1741		; A side Data Direction
    VIA_SBD	    := $1742		; B side Data
    VIA_PBDD    := $1743		; B side Data Direction

Next set the start address of the program

    .org	$0200		; Where program will be loaded

Lets also declare a START label even if we dont put any code here.

    START:                           ; No Operation, this does nothing

Next set up the 6532 registers as input and output according to the schematics, explained above.

The LDA-instruction loads a value into the A-register of the 6502-cpu. the #-sign is used for an immediate address, ie load the value directly follwing the #-sign. in this case the hexadecimal value of 0x7F. our assembler takes this format as $7F.

The STA-instruction writes the value of the A-register into memory. In this case we supply the memory address in absolut form $1741. But to give the code a little bit more readabillity we use the label VIA_PADD instead of writing \$1741. The 6502 dont differentiate between memorymapped registers of a circuit like the 6532 from the actual RAM-memory.

    INIT_VIA:
               LDA #$7F                ; Set PA0..PA6 as output, (PA7 as input)
               STA VIA_PADD
               LDA #$1E                ; Set PB0..PB4 as output, (PB5..PB7 as input)
               STA VIA_PBDD

Now we are ready for some business, lets output a character. First select a LED to output, by writing to the dataport B 

    SHOWCHAR:
               LDA #$08                ; Set active display to LED1 leftmost display
               STA VIA_SBD

Then set the actual segments of LED1, by writing to dataport A.

               LDA #$49                ; Show three bars, upper, middle, lower
               STA VIA_SAD     

We are finished now so just hold the cpu looping to the HOLD-label.

    HOLD:
               JMP HOLD                ; Jump to adress HOLD

The whole program is also supplied as a finished sourcefile [leddisplay.s](./leddisplay.s). The simplify compilation I have supplied a [Makefile](./Makefile) for this purpose. to compile the leddisplayprogram just type

    make

in the sourcecode folder, which should produce an output like this:

    micke@MBP16 leddisplay % make
    ca65 -g -l leddisplay.lst leddisplay.s
    ld65 -t none -vm -m leddisplay.map -o leddisplay.bin leddisplay.o
    srec_cat leddisplay.bin -binary -offset 0x0200 -address-length=2 -execution-start-address=0x0200 -o leddisplay.ptp -MOS_Technologies
    micke@MBP16 leddisplay %


## Lets run it!
* Hook everything up (cables and stuff)
* Reset the PAL-1 Again:
* Press RS on PAL-1
* Press Enter in Terminal
* Enter L (Capital L), (Dont press any other key after L)
* Open Sendfile dialog in your TerminalProgram. Select the file [./leddisplay.ptp](./leddisplay.ptp)
  And send the file as raw/binary content.
* You will see a lot of Hexformated output in the terminal.

Run the program
* type 0200+SPACE, to set the address to 0x0200, our start address.
* press G (capital G) (to run the program from the current address)

The PAL-1 will not show anything in the serial-terminal. But you should se three bars of the first LED-display if everything worked out?

