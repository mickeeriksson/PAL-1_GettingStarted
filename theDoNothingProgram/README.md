# The do Nothing Program

The purpose of the Do Nothing Program is to get our fingers dirty and to test that the toolchain is able to take us from sourcecode in assembler to a running program on the PAL-1.

## Lets write some Code

* Create a folder somewhere and call it doNothingProject. This will be our projectfolder.
* Start out favorite code-editor and create a file called donothing.s in the projectfolder
* Type in the following assembler program


    .setcpu "6502"
    .segment "CODE"
    .org	$0200		; Where program will be loaded

    START:          NOP                 ; No Operation, this does nothing
                    JMP START           ; Jump to adress START

The first three lines are control commands to the assembler to let it know how to handle our program.
.setcpu specifies for which CPU the assembler should be assembled into macinecode.
.segment specifes that the following should be linked into the CODE-segment. CODE is default but we specifies it anyway.
.org specifies where the program will be loaded into memory.

Then our small program
We will explain what the program does later on. For now we will just compile the program and test it.

## Lets do some compilation
start a terminal and goto our projectfolder doNothingProject
run the assembler

    ca65 --cpu 6502 -o donothing.o -l donothing.lst donothing.s

This will produce the object-file donothing.o which will be using by the linker later on. It will also produce a list-file donothing.lst which show how the assembler code was assembled into machinecode.

The run the linker

    ld65 -v -t none -o donothing.bin donothing.o

This will take the all the object-files (we only have one) and link them together into the finished program donothing.bin

The program should be exactly 4 bytes long. Let's take a look of what was produced.

     hexdump -C donothing.bin

Gives this output

    00000000  ea 4c 00 02                                       |.L..|
    00000004

Somehow the assembler (ca65), translated our program into the bytes 0xEA, 0x4C, 0x00 and 0x02. To understand why we will open the file donothing.lst that was also produced by the assembler

    ca65 V2.19 - Git 700c01fa8
    Main file   : donothing.s
    Current file: donothing.s

    000000r 1               .setcpu "6502"
    000000r 1               .segment "CODE"
    000000r 1               .org	$0200		; Where program will be loaded
    000200  1               
    000200  1  EA           START:          NOP
    000201  1  4C 00 02                     JMP START
    000204  1               
    000204  1

From this we can see that the assembler mnemonics (instruction) NOP was translated into the machine code opcode 0xEA, and that JMP START was translated into the opcode 0x4C with the address 0x00,0x02 (given from the label START). Why 0x00,0x02 and not 0x02,0x00??
This is because the 6502 is a little endian CPU, and stores 16-bit adresses in memory with the LSB (Least Significant Byte) first followed by the MSB (Most Significant Byte).

Before we can load the program into PAL-1 it needs to be translated into a hexfile in papertape-format described in [KIM-1 users manual](http://retro.hansotten.nl/uploads/files/MOS_KIM-1_User_Manual.pdf) appendix F.

We will do this by using a program called srec_cat. for MacOs this can be installed with brew https://formulae.brew.sh/formula/srecord

    srec_cat donothing.bin -binary -offset 0x0200 -address-length=2 -execution-start-address=0x0200 -o donothing.ptp  -MOS_Technologies

TODO: Implement and show this with MIC-Tools instead of srec_cat

---------------




(also called Motorola S28 Hex format). We will do this by using a program called srec_cat. for MacOs this can be installed with brew https://formulae.brew.sh/formula/srecord

convert the .bin into ptp by running

    srec_cat donothing.bin -binary -offset 0x0200 -address-length=2 -execution-start-address=0x0200 -o donothing.ptp


## Lets run it!
* Hook everything up (cables and stuff)
* Reset the PAL-1 Again:
* Press RS on PAL-1
* Press Enter in Terminal
* Enter L (Capital L), (Dont press any other key after L)
* Open Sendfile dialog in your TerminalProgram. Select the file [./donothing.ptp](./donothing.ptp)
  And send the file as raw/binary content.
* You will see a lot of Hexformated output in the terminal.

Run the program
* type 0200+SPACE, to set the address to 0x0200, out start address, The PAL-1 shows


    0200 EA
* press G (capital G) (to run the program from the current address)

The PAL-1 will not respond with anything, since the PAL-1 is busy with doing nothing.

The PAL-1 will not only do nothing, It will do it forever!


## What is happening inside the CPU when this program is running?

Let's go through the opcodes in the program/listing and explain what is happening inside the CPU, when this is run.

    000200  1  EA           START:          NOP
    000201  1  4C 00 02                     JMP START
START: Is just a LABEL that will be given the value of 0x0200. This meens we can use the label START instead of 0x0200 in the future when refering to the start of the program

When this program starts the PC_Register  (Program Counter Register) is loaded with 0x0200, which specifies where in memory to load the first instruction from.

at 0x0200 the CPU will load the instruction 0xEA into the instruction register, and decode that instruction. In this case the decoding will result in nothing but that the PC is incremented to the next instruction at 0x0201, our JUMP instruction.

If we check for example http://www.6502.org/tutorials/6502opcodes.html#JMP we see that 0x4C is one of two avaliable adressing modes for JMP, we are using the Absolute addressing mode where the address is explicitly specified.

When the CPU loads and decode the 0x4C opcode (JMP), the result will be that PC will be set to following address 0x0200 and load the next instruction from there. This means that the CPU will now jump back to the first instruction at START (0x0200). 

This is a typical forever loop in assembler.

This 4-byte long program is not doing much, but we have tested all the fundamental tools to write, assemble, load and run a program on the PAL-1.





