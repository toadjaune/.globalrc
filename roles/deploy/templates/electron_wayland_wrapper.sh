#!/bin/sh

# This script wraps an electron app and starts it with extra arguments for wayland support
# None of the methods implying config files seem to work reliably for now
# (https://wiki.archlinux.org/title/Wayland#Electron)

# Similarly to the firefox wrapper script, this is the only way I found to affect consistently :
# * .desktop file (Various graphical tools, rofi in drun mode, etc...) (https://wiki.archlinux.org/title/Desktop_entries)
# * bare binary (cli, rofi in run mode, etc...)
# * XDG (default program for opening links) (https://wiki.archlinux.org/title/Default_applications, https://wiki.archlinux.org/title/XDG_MIME_Applications)

# Warn in both outputs that we're starting firefox through an very non-standard way
echo "WARNING (stdout) : {{ item }} starting through a custom wrapper at $0"
echo "WARNING (stderr) : {{ item }} starting through a custom wrapper at $0" >&2

# TODO : do not hardcode the path to the real binary
exec /usr/bin/{{ item }} --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"

