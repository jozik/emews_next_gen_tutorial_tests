#!/bin/bash

set -eu

# Check for an optional timeout threshold in seconds. If the duration of the
# model run as executed below, takes longer that this threshhold
# then the run will be aborted. Note that the "timeout" command
# must be supported by executing OS.

# The timeout argument is optional. By default the "run_model" swift
# app fuction sends 3 arguments, and no timeout value is set. If there
# is a 4th (the TIMEOUT_ARG_INDEX) argument, we use that as the timeout value.

# !!! IF YOU CHANGE THE NUMBER OF ARGUMENTS PASSED TO THIS SCRIPT, YOU MUST
# CHANGE THE TIMEOUT_ARG_INDEX !!!
TIMEOUT=""
TIMEOUT_ARG_INDEX=4
if [[ $# ==  $TIMEOUT_ARG_INDEX ]]
then
	TIMEOUT=${!TIMEOUT_ARG_INDEX}
fi

TIMEOUT_CMD=""
if [ -n "$TIMEOUT" ]; then
  TIMEOUT_CMD="timeout $TIMEOUT"
fi

# Set PARAM_LINE from the first argument to this script
# PARAM_LINE is the string containing the model parameters for a run.
PARAM_LINE=$1

# Set EMEWS_ROOT to the root directory of the project (i.e. the directory
# that contains the scripts, swift, etc. directories and files)
EMEWS_ROOT=$2

# Each model run, runs in its own "instance" directory
# Set INSTANCE_DIRECTORY to that and cd into it.
INSTANCE_DIRECTORY=$3
cd $INSTANCE_DIRECTORY
# directory that contains the repast model
MODEL_DIRECTORY=$emews_root"/complete_model/"
# create a symbolic link to the model data directory
# within the instance directory
ln -s $MODEL_DIRECTORY"data" data

cPath=$MODEL_DIRECTORY"lib/*"

pxml=$MODEL_DIRECTORY"scenario.rs/batch_params.xml"

scenario=$MODEL_DIRECTORY"scenario.rs"

# check for java defined as environment variable
if [[ ${JAVA:-0} == 0 ]]
then
  JAVA=java
fi

# Getting the classpath to properly resolve can be tricky
# when running java from a variable so we ignore MODEL_CMD
# and run java explicitly below.
#MODEL_CMD=""


# Turn bash error checking off. This is
# required to properly handle the model execution
# return values and the optional timeout.
set +e
echo "$param_line"
$TIMEOUT_CMD $JAVA -Xmx1536m -XX:-UseLargePages -cp "$cPath" repast.simphony.batch.InstanceRunner \
   -pxml "$pxml" \
   -scenario "$scenario" \
   -id 1 "$param_line"


# $? is the exit status of the most recently executed command (i.e the
# line above)
RES=$?
if [ "$RES" -ne 0 ]; then
	if [ "$RES" == 124 ]; then
    echo "---> Timeout error in model"
  else
	   echo "---> Error while running model"
  fi
fi
