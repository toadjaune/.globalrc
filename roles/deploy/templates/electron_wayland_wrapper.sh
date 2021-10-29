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

# Find the "real" binary path, to execute it with extra arguments / envvars
# NB : We don't want to persistently change the PATH variable, so that the final program is exec'd with the normal PATH (less intrusive)
# TODO : Maybe autodetect the directory to be excluded in the script (suprisingly hard) or set it with the jinja template ?
# TODO : Maybe replace item templating by sh logic ? Not sure waht behavior we want for symlinks
actual_binary=$( PATH=$(echo $PATH | sed 's@/usr/local/bin:@@') which {{ item }} )

exec $actual_binary --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"

