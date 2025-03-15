# The Framebuffer tutorial

Lets build a framebuffer. In a modern computer the framebuffer is the videomemory where the color of every pixel on the display is stored. In out case the framebuffer is only 6 bytes large holding the value of every LED-segment. In out case the LED dont have a memory and it will also possible to display a single LED at once. So to make it look like they are actuallt showing at once we will build a refresh-method that copies the values from the frambuffer to the VIA-chips to light-up the leds. If we do this fast enough the eye wont detect that there actually is only one LED at a time showing.

## A note about the 6530 Chip

The LEDS are actually sharing the VIA port A with the keyboard. Therefore it is needed to switch the datadirection of port A between input and output mode. We ignored this in previously tutorials, but now we will reset the port A for input after every screen-refresh to prepere for the upcoming tutorial about the keybord.

## Then some coding
Lets do som coding.


TODO


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

