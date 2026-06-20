#!/bin/bash

CURRENT=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "$CURRENT" == "'prefer-dark'" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'default'
    sed -i 's/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=0/' ~/.config/gtk-3.0/settings.ini
    sed -i 's/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=0/' ~/.config/gtk-4.0/settings.ini
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    sed -i 's/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=1/' ~/.config/gtk-3.0/settings.ini
    sed -i 's/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=1/' ~/.config/gtk-4.0/settings.ini
fi

pkill -HUP xsettingsd
