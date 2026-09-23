autoload -Uz compinit
if [[ ${UID} -eq 0 ]] && [[ -n ${SUDO_USER} ]]; then
  # We are root, do not check for insecure directories, since this check was
  # done for your regular user, and since some files in fpath do not belong to
  # root but to your regular user
  compinit -u
else
  compinit
fi
