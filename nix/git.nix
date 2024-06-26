{ config, pkgs, lib, ... }:

let
  # TODO : This is a very ugly way to make variable configuration across hosts
  # I also haven't understood yet how to share values between modules
  hostname = lib.strings.removeSuffix "\n" (builtins.readFile /etc/hostname);
  git_user_email = (
    if hostname == "launchpad"  then "arnaud.venturi@vroomly.com" else
    if hostname == "houston"    then "arnaud.venturi@vroomly.com" else
    if hostname == "spacerig"   then "git@toadjaune.eu" else
    if hostname == "valoo"      then "git@toadjaune.eu" else
    abort "invalid_hostname"
  );
in
{
  programs.git = {
    enable = true;
    userName = "Arnaud Venturi";
    userEmail = git_user_email;
    aliases = {
      # This pretty format is equivalent to --oneline --decorate, with the addition of commiter name and date
      # See https://stackoverflow.com/questions/5889878/color-in-git-log#16844346
      # and https://git-scm.com/docs/pretty-formats
      fullog = "log --graph --all --date-order --pretty=tformat:'%C(auto)%h%d %s %Cgreen(%cr) %Cblue<%an>'";
    };
    extraConfig = {
      # Global git config file

      # Good reference for "classic" options :
      # https://jvns.ca/blog/2024/02/16/popular-git-config-options/

      # Only push the current branch
      push.default = "upstream";

      # Don't need to specify --set-upstream when pushing a new branch
      push.autoSetupRemote = true;

      # Abort pulling if local and remote have diverged
      pull.ff = "only";

      # Repair files with Windows-endline-formatting-style (CRLF) on commit :
      core.autocrlf = "input";

      merge.tool = "vimdiff";

      # https://ductile.systems/zdiff3/
      merge.conflictstyle = "zdiff3";

      rerere.enabled = true;

      # https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
      # NB : This is likely useless when using difftastic
      diff.algorithm = "histogram";

      # Git, please, just stop dropping files in my working directory whenever I run `git mergetool`
      mergetool.keepbackup = false;
      # Thank you

      # Use https://github.com/dandavison/delta as pager
      # I'm not sure whether this is redundant with difftastic or not
      # TODO : switch to native home-manager delta setup ?
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.navigate = true;    # use n and N to move between diff sections
      diff.colorMoved = "default";

      commit.verbose = true;

      # https://andrewlock.net/working-with-stacked-branches-in-git-is-easier-with-update-refs/
      # For now, I'll experiment with explicit --update-refs on the cli, to decide whether I want it to be enabled by default or not
      # rebase.updateRefs = true;

      # Detect corruption eagerly, this should not be needed but if it ever is, we'll be very happy to have enabled it
      transfer.fsckobjects = true;
      fetch.fsckobjects = true;
      receive.fsckObjects = true;

      # More sensible submodule-related behavior
      status.submoduleSummary = true;
      diff.submodule = "log";
      submodule.recurse = true;

      # Sort branches and tags by latest activity instead of alphabetically
      branch.sort = "-committerdate";
      tag.sort = "taggerdate";

      # automatically clean up obsolete remote-tracking branches and tags
      fetch.prune = true;
      fetch.prunetags = true;

      # Format dates in git log as iso
      log.date = "iso";
    };

    # cf https://difftastic.wilfred.me.uk/git.html
    difftastic = {
      enable = true;
      background = "dark";
    };
  };

}
