# Dotfiles & co

This repo contains my various dotfiles and configurations, meant to be deployed with ansible.

It evolved organically frow various sources, and many elements here are unreasonably complicated, or not considered good practice even by me.

Still, feel free to have a look around !

## Supported operating systems

Currently supported :

* Fedora

Previously supported, should likely still mostly work with minor tweaks (especially installed packages) :

* Ubuntu
* Manjaro (Arch)

Previously partially supported :

* MacOS (cf roles/deploy/tasks/desktop_mac.yml for details)

## Deployment instructions

There's currently a mix of ansible-managed stuff, and home-manager-managed stuff

### Ansible

* If you're not me, you're gonna have to at least change the inventory.yml file, and probably quite a bit in host_vars/group_vars
* Install ansible, likely the latest version with your OS package manager should be fine
* `ansible-playbook deploy.yml`

### home-manager

* [Install nix](https://nixos.org/manual/nix/stable/installation/installing-binary.html)
  * NB : As of 2024-05-01, it's not possible to install nix as multi-user on SELinux-enabled distros, so, we settle with a single-user install for now
* Install home-manager as a standalone program : https://nix-community.github.io/home-manager/#sec-install-standalone
* Symlink the home-manager configuration file : `ln -s $PWD/home.nix $HOME/.config/home-manager/home.nix`
