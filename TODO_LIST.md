# Mac-specific stuff

General issues that need solving :
* find a tiling window manager
* copy-paste keyboard shortcuts
* screenshots with equivalent funtionality
* maybe move rofi to cmd + space (this shortcut is cool)
* automatic focus of windows when hovering with mouse
* ssh-agent
* Ctrl-backspace to delete word

Fixed manually, to automate :
* install brew
* install with brew :
  * qwerty-lafayette
  * md5sum (for old prompt)
  * prettyping
  * exa


Nice stuff :
* Dead keys representation in text fields
* Permission management across the system (popup to allow terminal to access downloads directory...)
* Per-app notification permissions






# List of things that need to be done

* Add a minimal vimrc to sshrc
* Find WTF is happening when using arrow keys in insert mode in vim
* Manage font fallback if compatible fonts are not detected
* See if git completion glitches are due to zsh-completions
* Find why zsh history is lost
* color of tmux bar
* replace tests like [ -x /some/path ] by only builtins (like command -v ?) see https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script#677212
* Perf evaluation (and change ?) between :
  * Testing if a program exists at source-time, and then define an alias
  * Always define a function that tests at runtime
  (after moving to a builtin check, should not be a significative difference)


Links for zsh profiling :
* https://blog.jonlu.ca/posts/speeding-up-zsh
* https://kev.inburke.com/kevin/profiling-zsh-startup-time/
* https://stackoverflow.com/questions/4351244/can-i-profile-my-zshrc-zshenv

Nice terminal emulator, see about implementing some of the things it supports : https://sw.kovidgoyal.net/kitty/
such as : https://cirw.in/blog/bracketed-paste

Nice tools :
  * https://remysharp.com/2018/08/23/cli-improved
  * lnav (log navigator)
  * https://github.com/nitefood/asn -> ASN, BGP, réputations IP, etc…
  * gping (https://github.com/orf/gping)


Power management : tlp

* Install required libs solokeys
