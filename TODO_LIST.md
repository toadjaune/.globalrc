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
