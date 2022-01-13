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

# Set param_line from the first argument to this script
# param_line is the string containing the model parameters for a run.
param_line=$1

# Set emews_root to the root directory of the project (i.e. the directory
# that contains the scripts, swift, etc. directories and files)
emews_root=$2

# Each model run, runs in its own "instance" directory
# Set instance_directory to that and cd into it.
instance_directory=$3

# directory that contains the repast model
model_directory=$emews_root"/complete_model/"

#
cd $instance_directory

# create a symbolic link to the model data directory
# within the instance directory
ln -s $model_directory"data" data

cPath=$model_directory"lib/*"

pxml=$model_directory"scenario.rs/batch_params.xml"

scenario=$model_directory"scenario.rs"

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
# required to properly handle the model execution return value
# the optional timeout.
set +e


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
	   echo "---> Error in while running model"
  fi
fi
