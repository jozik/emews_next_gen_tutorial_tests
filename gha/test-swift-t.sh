#!/bin/bash

# TEST SWIFT-T
# Test Swift/T under GitHub Actions

if (( ${#} != 1 ))
then
    echo "Provide Python version!"
    exit 1
fi

PY_VERSION=$1

ENV_NAME=emews-py${PY_VERSION}

CONDA_EXE=$(which conda)
if [[ ${AUTO_TEST} != "GitHub" ]]
then
    CONDA_BIN_DIR=$(dirname $CONDA_EXE)
else
    # The installation is a bit different on GitHub
    # conda    is in $CONDA_HOME/condabin
    # activate is in $CONDA_HOME/bin
    CONDA_HOME=$(dirname $(dirname $CONDA_EXE))
    CONDA_BIN_DIR=$CONDA_HOME/bin
fi

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
echo "python:  " $(which python)
echo "version: " $(python -V)
echo "conda:   " $(which conda)

# Run tests!

set -eux

which swift-t
swift-t -v
swift-t -E 'trace(42);'


# Local Variables:
# sh-basic-offset: 4
# End:
