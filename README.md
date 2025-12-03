# Dotfiles & co

This repo contains my various dotfiles and configurations, meant to be deployed with ansible.

It evolved organically frow various sources, and many elements here are unreasonably complicated, or not considered good practice even by me.

Still, feel free to have a look around !

## git-crypt

This repo contains files encrypted with git-crypt. If you're me, follow [instructions](https://blog.toadjaune.eu/posts/2024/06-11_git_crypt_without_gpg/) to unlock git-crypt and access those files

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

* [Install lix](https://nixos.org/download/) (as a nix implementation)
  * enable flakes during the interactive install process
* Install home-manager as a standalone program : https://nix-community.github.io/home-manager/#sec-install-standalone

Recurrent usage :
* Install/update configuration : `home-manager switch --flake ./#houston`
* Update lockfile : `nix flake update --flake .`
