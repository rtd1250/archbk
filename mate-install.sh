#!/usr/bin/env bash

pacman -S mate mate-extra xorg-server lightdm lightdm-gtk-greeter xf86-input-synaptics networkmanager network-manager-applet alsa-utils mate-power-manager xorg-xmodmap

--noconfirm

f /sys/class/backlight/backlight.12/brightness 0666 - - - 800

echo 'Section "InputClass"
        Identifier "touchpad"
        Driver "synaptics"
        MatchIsTouchpad "on"
        Option "FingerHigh" "5"
        Option "FingerLow" "5"
        Option "TapButton1" "1"
        Option "TapButton2" "3"
        Option "TapButton3" "2"
        Option "HorizTwoFingerScroll" "on"
        Option "VertTwoFingerScroll" "on"
EndSection' > /etc/X11/xorg.conf.d/70-synaptics.conf

echo '#!/usr/bin/env bash

b="/sys/class/backlight/backlight.12/brightness"
mb="/sys/class/backlight/backlight.12/max_brightness"
cur_bri=$(/usr/bin/cat $b)
maxb=$(/usr/bin/cat $mb) 
incr=100

if [ $1 = "u" ] && [ `expr $cur_bri + $incr` -le $maxb ]; then
    echo `expr $cur_bri + $incr` > $b
fi
if [ $1 = "d" ] && [ `expr $cur_bri - $incr` -ge 0 ]; then
    echo `expr $cur_bri - $incr` > $b
fi' >> /usr/local/bin/b

chmod +x /usr/local/bin/b

echo '[Unit]
Description=Disable trackpad waking computer

[Service]
Type=oneshot
ExecStart=/bin/sh -c "echo disabled > /sys/devices/12c70000.i2c/i2c-1/1-0067/power/wakeup"

[Install]
WantedBy=multi-user.target' >>  /etc/systemd/system/tp-wake-disable.service

echo '"xvkbd -xsendevent -text "[Prior]""
    m:0x4 + c:111
    Control + Up

"xvkbd -xsendevent -text "[Next]""
    m:0x4 + c:116
    Control + Down

"xvkbd -xsendevent -text "[Delete]""
    m:0x4 + c:22
    Control + BackSpace

"xvkbd -xsendevent -text "[End]""
    m:0x4 + c:114
    Control + Right

"xvkbd -xsendevent -text "[Home]""
    m:0x4 + c:113
    Control + Left' >> ~/.xbindkeysrc

echo 'xbindkeys &' >> ~/.xprofile

systemctl enable lightdm.service
systemctl enable NetworkManager.service
systemctl enable tp-wake-disable.service
