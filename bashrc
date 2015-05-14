# Se place dans le dossier .globalrc (ou qu'il soit)
pushd "$(dirname "$BASH_SOURCE")" > /dev/null

# Chargement des définitions
if [ -f definitions ]; then
  . definitions
fi

# # on affiche le logo
# if shopt -q login_shell; then
#   echo ".globalrc version" $(cat $GLOBALRC/version)
#   cat "$GLOBALRC/logo"
# fi

# Chargement des aliases
if [ -f aliases ]; then
  . aliases
fi

# Chargement des functions
if [ -f functions ]; then
  . functions
fi

# Chargement du prompt
if [ -f prompt ]; then
  . prompt
fi

# Ajoute les scripts aux programmes par défaut
if [ -d "$(pwd)/scripts" ]; then
  PATH="$PATH:$GLOBALRC/scripts"
fi

# Se replace dans le dossier précédent
popd > /dev/null
