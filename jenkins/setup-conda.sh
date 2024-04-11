#!/bin/zsh
set -eu

# JENKINS SETUP CONDA SH

# Defaults:
PYTHON_VERSION=${PYTHON_VERSION:-311}
CONDA_LABEL=${CONDA_LABEL:-23.11.0-1}

DATE_FMT_NICE="%D{%Y-%m-%d} %D{%H:%M:%S}"
log()
# General-purpose log line
{
  print ${(%)DATE_FMT_NICE} "anaconda.sh:" ${*}
}

log "SETUP CONDA"

# Clean up prior runs
uninstall()
{
  log "UNINSTALL ..."
  rm -fv $WORKSPACE/$MINICONDA
  log "DELETE: $WORKSPACE/sfw/Miniconda-$CONDA_LABEL ..."
  rm -fr $WORKSPACE/Miniconda-$CONDA_LABEL
  log "UNINSTALL OK."
}

downloads()
# Download and install Miniconda
{
  log "DOWNLOADS ..."
  (
    mkdir -pv $WORKSPACE
    cd $WORKSPACE
    if [[ ! -f $MINICONDA ]] \
         wget --no-verbose https://repo.anaconda.com/miniconda/$MINICONDA
  )
  log "DOWNLOADS OK."
}

help()
{
  cat <<EOF
-p PYTHON_VERSION  default "$PYTHON_VERSION"
-c CONDA_LABEL     default "$CONDA_LABEL"
-u                 delete prior artifacts, default does not
EOF
}

# Run plain help as needed before possibly affecting settings:
zparseopts h=HELP
if (( ${#HELP} )) help

# Main argument processing
zparseopts -D -E -F c:=CL p:=PV u=UNINSTALL
if (( ${#PV} )) PYTHON_VERSION=${PV[2]}
if (( ${#CL} )) CONDA_LABEL=${CL[2]}

renice --priority 19 --pid $$ >& /dev/null

MINICONDA=Miniconda3-py${PYTHON_VERSION}_${CONDA_LABEL}-Linux-x86_64.sh
log "MINICONDA: $MINICONDA"
TARGET=$WORKSPACE/Miniconda-${PYTHON_VERSION}_${CONDA_LABEL}
log "TARGET: $TARGET"

if (( ${#UNINSTALL} )) uninstall
downloads

log "INSTALL ..."
if [[ ! -d $WORKSPACE/sfw/Miniconda-$CONDA_LABEL ]] \
         bash $MINICONDA -b -p $WORKSPACE/Miniconda-${PYTHON_VERSION}_${CONDA_LABEL}
log "INSTALL OK: $TARGET"
