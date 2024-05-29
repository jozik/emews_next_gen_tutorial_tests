#!/bin/bash 

# INSTALL EMEWS SH
# See README.adoc

function start_step {
    if [[ ${JENKINS_URL:-UNSET} == "UNSET" ]]
    then
        # Normal shell run
        echo -en "[ ] $1 "
    else
        # Jenkins run
        echo -e  "[ ] $1 "
    fi
}

function end_step {
    if [[ ${JENKINS_URL:-UNSET} == "UNSET" ]]
    then
      # Normal shell run - overwrite last line and show check mark
      echo -e "\r[\xE2\x9C\x94] $1 "
    else
      # Jenkins run
      echo -e "[X] $1 "
    fi
}

function on_error {
    msg="$1"
    log="$2"

    echo -e "\n\nError: $msg"
    echo "See $log for details"

    exit 1
}

VALID_VERSIONS=("3.8" "3.9" "3.10" "3.11")
V_PREFIX=(${VALID_VERSIONS[@]::${#VALID_VERSIONS[@]}-1})
V_SUFFIX="${VALID_VERSIONS[@]: -1}"
printf -v joined '%s, ' "${V_PREFIX[@]}"
V_STRING="${joined% } or $V_SUFFIX"

help() {
   echo "Usage: install_emews.sh <python-version> <database-directory>"
   echo "       install_emews.sh -h"
   echo
   echo "Arguments:"
   echo "  python-version         python version to use ($V_STRING)"
   echo "  database-directory     EQ/SQL Database installation directory" 
   echo "  h                      display this help and exit"
   echo
   echo "Example:"
   echo "  install_emews.sh 3.11 ~/Documents/db/eqsql_db"
}

while getopts ":h" option; do
   case $option in
      h) # display Help
         help
         exit;;
      \?) # incorrect option
         help
         exit;;
   esac
done

if [ "$#" -ne 2 ]; then
    help
    exit
fi

PY_VERSION=''
for V in "${VALID_VERSIONS[@]}"; do
    if [ $V = $1 ]; then
        PY_VERSION=$V
    fi
done

if [ -z "$PY_VERSION" ]; then
    echo "Error: python version must be one of $V_STRING."
    exit
fi

if [ -d $2 ]; then
    echo "Error: Database directory already exists: $2"
    echo "       This script will not overwrite an existing database."
    echo "       Remove it or specify a different directory."
    exit 1
fi


if [ ! $(command -v conda) ]; then
    echo "Error: conda executable not found. Conda must be activated."
    echo "Try \"source ~/anaconda3/bin/activate\""
    exit 1
fi

CONDA_BIN=$(which conda)
CONDA_BIN_DIR=$(dirname $CONDA_BIN)

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
EMEWS_INSTALL_LOG="$THIS/emews_install.log"

echo "Starting EMEWS stack installation"
echo "See ${THIS}/emews_install.log for detailed output."
echo

echo "Using conda: $CONDA_BIN_DIR"

ENV_NAME=emews-py${PY_VERSION}
TEXT="Creating conda environment '${ENV_NAME}' using Python ${PY_VERSION}"
start_step "$TEXT"
# echo "Creating conda environment '${ENV_NAME}' using ${PY_VERSION}"
conda create -y -n $ENV_NAME python=${PY_VERSION} > "$EMEWS_INSTALL_LOG" 2>&1 || on_error "$TEXT" "$EMEWS_INSTALL_LOG"
end_step $TEXT


# !! conda activate $ENV_NAME doesn't work within the script
TEXT="Installing swift-t conda package"
start_step "$TEXT"
source $CONDA_BIN_DIR/activate $ENV_NAME
conda install -y -c conda-forge -c swift-t swift-t-r >> "$EMEWS_INSTALL_LOG" 2>&1 || on_error "$TEXT" "$EMEWS_INSTALL_LOG"
conda deactivate
source $CONDA_BIN_DIR/activate $ENV_NAME
end_step "$TEXT"

# TEXT="Upgrading conda gcc"
# start_step "$TEXT"
# conda upgrade -y -c conda-forge gcc >> "$EMEWS_INSTALL_LOG" 2>&1 || on_error "$TEXT" "$EMEWS_INSTALL_LOG"
# end_step "$TEXT"

TEXT="Installing PostgreSQL"
start_step "$TEXT"
conda install -y -c conda-forge postgresql >> "$EMEWS_INSTALL_LOG" 2>&1 || on_error "$TEXT" "$EMEWS_INSTALL_LOG"
end_step "$TEXT"

TEXT="Installing EMEWS Creator"
start_step "$TEXT"
pip install emewscreator >> "$EMEWS_INSTALL_LOG" 2>&1 || on_error "$TEXT" "$EMEWS_INSTALL_LOG"
end_step "$TEXT"

TEXT="Initializing EMEWS Database"
emewscreator init_db -d $2 >> "$EMEWS_INSTALL_LOG" 2>&1 || on_error "$TEXT" "$EMEWS_INSTALL_LOG"
end_step "$TEXT"

# TEXT="Upgrading conda gcc"
# start_step "$TEXT"
# conda upgrade -y -c conda-forge gcc >> "$EMEWS_INSTALL_LOG" 2>&1 || on_error "$TEXT" "$EMEWS_INSTALL_LOG"
# end_step "$TEXT"

set -x
THIS=$( cd $( dirname $0 ) ; /bin/pwd )


TEXT="Initializing Required R Packages"
Rscript $THIS/install_R_pkgs.sh  >> "$EMEWS_INSTALL_LOG" 2>&1 || on_error "$TEXT" "$EMEWS_INSTALL_LOG"
Rscript -e "remotes::install_github('emews/EQ-SQL/R/EQ.SQL')"  >> "$EMEWS_INSTALL_LOG" 2>&1 || on_error "$TEXT" "$EMEWS_INSTALL_LOG"
end_step "$TEXT"

echo
echo "# To activate this EMEWS environment, use"
echo "#"
echo "#     $ conda activate $ENV_NAME"
echo "#"
echo "# To deactivate an active environment, use"
echo "#"
echo "#     $ conda deactivate"

# Local Variables:
# sh-basic-offset: 4
# End:
