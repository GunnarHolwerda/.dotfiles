#!/bin/bash

#### Status bar for i3
#### Install brightnessctl for intel brightness ctrl (may need xbacklight instead if a different computer?)
sudo apt-get install i3 i3status brightnessctl

# Configuration
## Add user to video group so we can use brightnessctl without needing sudo everytime
sudo usermod -aG video $USER

# Mouse speed on Dell XPS 13
xinput --set-prop 11 'libinput Accel Speed' 0.75

