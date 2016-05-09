# pimp - The Raspberry Pi Media Player.

aka So you want to turn your Raspberry Pi into a Wireless Portable BlueTooth Audio System using Mopidy and you thought it was going to be easy...

## Introduction

The goal here was to setup a jukebox for the office.

The Raspberry Pi 3 lends itself very nicely to this project as it has built in Wifi and BlueTooth.
 
We'll be using the Wifi connection for streaming media from the Internet and
the BlueTooth to connect to an existing stereo system or speaker.

### Do we really need another music box project?

I'm glad you asked.

This project is really designed for those of you that like to tinker.
 
No need to reimage your Raspberry Pi SD card.

It's designed not to take over the entire system.

It only does what it needs in order to play music.

## Prerequisites

### Hardware

* [Raspberry Pi 3](http://amzn.to/1SVYyuY)
* [Samsung Memory 32GB Evo MicroSDHC UHS-I Grade 1 Class 10 Memory Card](http://amzn.to/1CPrL5c)
* [Raspberry Pi Official Universal Power Supply Unit](http://amzn.to/1efVJmU)

Note: You may need a keyboard and mouse to begin with, I recommend the [Logitech K400](http://amzn.to/1SVYWcS).

### Operating System

* Download [NOOBS_v*.zip](http://downloads.raspberrypi.org/NOOBS_latest), extract zip contents onto the SD card.
* Power up the Pi, from the [NOOBS menu choose to Install Raspbian](https://www.raspberrypi.org/documentation/installation/noobs.md).
* Keep the [Command Line Boot Behaviour](http://elinux.org/RPi_raspi-config#boot_behaviour_-_Start_desktop_on_boot.3F).

### Connectivity

* Use the LAN port until Wireless is setup
* Connect to your Pi from Windows [over SSH](https://technet.microsoft.com/en-us/library/hh225041(v=sc.12).aspx) using [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) (ie: `putty -ssh pi@raspberrypi.local`)

## Setup

We'll be setting up 4 things:

* Wifi
* VNC
* BlueTooth Audio
* Mopidy (Music Player)

The scripts in this repository will set this up for you.

## See also

* [Pi Media Server](https://github.com/jpswade/pims)
* [Potteries Hackspace](http://potterieshackspace.org/)
* [/r/raspberry_pi](https://www.reddit.com/r/raspberry_pi/)
* [James Wade](http://wade.be/)