# kof97react

This project is to rebuild the source code for the SNK NeoGeo game "The King of Fighters '97" by M68K assembly.
It is based on the reverse analysing on the original rom file.
Currently, this will only rebuild the P1-rom part of the game (cartridge, MVS system, P1-rom size: 1M bytes). 

## Compiler tools 
Use gcc tools to complie the source code.
For Windows system, you can download the tools here:
https://wiki.neogeodev.org/index.php?title=File:NeoDev001.zip

## Debugger tools
To run it on mame (www.mame.net), first load the original kof97 rom, then you may use "load out.bin, 0, 100000" on mame debugger to replace the P1-rom part by your own file. Howerer, the mame debugger seems not support to load data to some rom section (rather than to some ram section), so you would edit mame's source code and rebuild mame to let it work. Or instead, you can find your own way to write the data block to the mame's program's heap ram (note that the game's rom section is a part of the simulator's process ram section).
