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
  * certigo (https://github.com/square/certigo)
  * bpytop https://pypi.org/project/bpytop/
  * vimium (modern vimperator, https://github.com/philc/vimium)
  * Maybe give a try to hyprland as a sway replacement ?


Power management : tlp

* Install required libs solokeys
