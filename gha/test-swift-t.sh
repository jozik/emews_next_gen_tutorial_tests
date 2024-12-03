#!/bin/bash

# TEST SWIFT-T
# Test Swift/T under GitHub Actions

if (( ${#} != 1 ))
then
    echo "Provide Python version!"
    exit 1
fi

PY_VERSION=$1

THIS=$( dirname $0 )

ENV_NAME=emews-py${PY_VERSION}

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

# Run tests!

export TURBINE_RESIDENT_WORK_WORKERS=1
FLAGS=( -n 4 -I $ENV_HOME -r $ENV_HOME )

set -eux

which swift-t
swift-t -v
swift-t -E 'trace(42);'
swift-t ${FLAGS[@]} -E 'import EQR;'
swift-t ${FLAGS[@]} $THIS/test-eqr-1.swift

# Local Variables:
# sh-basic-offset: 4
# End:
