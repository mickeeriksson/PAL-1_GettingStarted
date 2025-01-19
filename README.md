# PAL-1 Getting started guide
This is a getting started guide to PAL-1

## Setup the development environment
This is the steps to get everything up and working

### RS-232
The PAL-1 has a RS-232 connector, that can be used to communicate to your computer.
Hook it up with a straight serialcable. The PAL-1 connector is a male DSUB-9, that normally indicates that a nullmodem cable where pin2 & 3 should be crossed. However this is not needed just use a femele<->female gender changer.

Modern computer doesnt have a RS-232 comport any more, so you will probably need an USB->RS-232 cable, to get a comport. There are several alternatives out there and some of them can be a little tricky to get the drivers working on. Especially on Mac.

download or use out favorite Terminal program. Here are some alternatives

MAC:
* Serial-2, https://www.decisivetactics.com/products/serial/ , cost some bucks, but has built in drivers.
* Minicom, https://formulae.brew.sh/formula/minicom

PC:
* TeraTerm, https://teratermproject.github.io/index-en.html

Set the Terminal program line settings to 24008N2
2400 baud, 8bit, no parity, 2 stop bits

The direct the PAL-1 output to RS-232 the IO-Selector jumper should be closed.

### Connect
Connect the power to the PAL-1 board.

Press Reset (RS).
Press Enter int the Terminal.

The following should then be displayed in the Terminal:

    KIM
    0000 00

Congratulations, ýou now have contact with your PAL-1!

### Upload a simple program

To upload programs to PAL-1 we first need to set some transmission pacing. 
I use 5ms/characters and a 100ms/line, suggested in the manual to give the PAL-1 some slack to handle the received data. The settings for this depends on the Terminal program used.

We will first try to upload and run a memory test program, From the first book of KIM, provided by Jeff Tranter in this archive http://retro.hansotten.nl/uploads/files/First%20book%20of%20KIM%20sources.zip

* Reset the PAL-1 Again:
* Press RS on PAL-1
* Press Enter in Terminal
* Enter L (Capital L), (Dont press any other key after L)
* Open Sendfile dialog in your TerminalProgram. Select the file [./memorytest/memorytest.ptp](./memorytest/memorytest.ptp) 
And send the file as raw/binary content.
* You will see a lot of Hexformated output in the terminal. This is a Motorola S-Record format. After a while the upload stops and the PAL-1 is showing the adress/value promt again, showing that the upload is finished. 

Lets test page 01 to page 02 (adress 0x100-0x2FF), following the instructions in memorytest.txt
* type 0000+SPACE
* type 01.   (first program parameter)
* type 02.   (second program parameter)
* type 0002+SPACE    (program start address)
* press G (capital G) (to run the program from the current address)

The following should then be displayed in the Terminal:

    KIM
    0300 00

This means that the Memtest is finished and all addresses up to 0x300 was correctly tested.











    