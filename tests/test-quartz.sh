#!/bin/bash

echo "test-quartz.sh: START"

if (( ${#} != 1 ))
then
    echo "test-quartz.sh: Provide Python version!"
    exit 1
fi

PY_VERSION=$1

THIS=$( dirname $0 )

if (( ${#JENKINS_URL} > 0 ))
then
    # CELS Jenkins environment
    PATH=$WORKSPACE/../EMEWS-Conda/Miniconda-311_23.11.0-1/bin:$PATH
    # Otherwise, we are on GitHub, and GitHub provides python, conda
fi

ENV_NAME=emews-py${PY_VERSION}

echo "CONDA CREATE ..."
conda create -y -n $ENV_NAME python=${PY_VERSION}
echo "CONDA CREATE: OK"

CONDA_EXE=$(which conda)
# The installation is a bit different on GitHub
# conda    is in $CONDA_HOME/condabin
# activate is in $CONDA_HOME/bin
CONDA_HOME=$(dirname $(dirname $CONDA_EXE))
CONDA_BIN_DIR=$CONDA_HOME/bin

echo "activating: $CONDA_BIN_DIR/activate '$ENV_NAME'"
if ! [[ -f $CONDA_BIN_DIR/activate ]]
then
    echo "File not found: '$CONDA_BIN_DIR/activate'"
    exit 1
fi
if ! source $CONDA_BIN_DIR/activate $ENV_NAME
then
    echo "could not activate: $ENV_NAME"
    exit 1
fi

PYTHON_EXE=$(which python)
ENV_HOME=$(dirname $(dirname $PYTHON_EXE))

echo "python:  " $PYTHON_EXE
echo "version: " $(python -V)
echo "conda:   " $(which conda)
echo "env:     " $ENV_HOME

conda install -y -c conda-forge r-base

set -eu

which Rscript

Rscript $THIS/install_pkgs.R



# Local Variables:
# sh-basic-offset: 4
# End:
