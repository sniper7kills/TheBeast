# TheBeast

Documentation for Personal PC Build

## Objectives

This PC was built to meet the following objectives:

- [ ] Streaming // Media Creation abilities
  - [ ] Editing Videos
  - [ ] Live Streaming on Twitch
  - [ ] Video Capture of other VM's
- [ ] Gaming
- [ ] Cyber Secutiy
  - [ ] Lab Environment
  - [ ] Linux Distro Install
- [X] MacOS

Due to the vast difference in the different objectives, and the need to have multiple running at the same time I decided to go for a fully virtuallized desktop environment.

## Installation

### Hardware

[Hardware Documentation](./hardware.md)

### Software

[Software Documentation](./software.md)

## Tweeks

Dynamic Device Attachment

`sudo virsh attach-device {vm-name} --file data/sda/sniper7kills/TheBeast/devices/{device}.xml`