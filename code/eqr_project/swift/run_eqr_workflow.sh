#! /usr/bin/env bash
set -eu

if [ "$#" -ne 2 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} exp_id cfg_file"
  exit 1
fi

# Uncomment to turn on swift/t logging. Can also set TURBINE_LOG,
# TURBINE_DEBUG, and ADLB_DEBUG to 0 to turn off logging
# export TURBINE_LOG=1 TURBINE_DEBUG=1 ADLB_DEBUG=1
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
# source some utility functions used by EMEWS in this script
source "${EMEWS_PROJECT_ROOT}/etc/emews_utils.sh"

export EXPID=$1
export TURBINE_OUTPUT=$EMEWS_PROJECT_ROOT/experiments/$EXPID
check_directory_exists

CFG_FILE=$2
source $CFG_FILE

echo "--------------------------"
echo "WALLTIME:              $CFG_WALLTIME"
echo "PROCS:                 $CFG_PROCS"
echo "PPN:                   $CFG_PPN"
echo "QUEUE:                 $CFG_QUEUE"
echo "PROJECT:               $CFG_PROJECT"
echo "ME CONFIG FILE:        $CFG_ME_CONFIG_FILE"
echo "--------------------------"

ME_CONFIG=$EMEWS_PROJECT_ROOT/$CFG_ME_CONFIG_FILE

echo "------ME CONFIG-----------"
cat $ME_CONFIG
echo "--------------------------"

export PROCS=$CFG_PROCS
export QUEUE=$CFG_QUEUE
export PROJECT=$CFG_PROJECT
export WALLTIME=$CFG_WALLTIME
export PPN=$CFG_PPN
export TURBINE_JOBNAME="${EXPID}_job"
export TURBINE_MPI_THREAD=1 

mkdir -p $TURBINE_OUTPUT
cp $CFG_FILE $TURBINE_OUTPUT/cfg.cfg

# TODO: If R cannot be found, then these will need to be
# uncommented and set correctly.
# export R_HOME=/path/to/R
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_HOME/lib

# EQ/R location
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

# TODO: If Python cannot be found or there are "Cannot find 
# X package" type errors then these two environment variables
# will need to be uncommented and set correctly.
# export PYTHONHOME=/path/to/python

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# TODO: Set MACHINE to your schedule type (e.g. pbs, slurm, cobalt etc.),
# or empty for an immediate non-queued unscheduled run
MACHINE=""

if [ -n "$MACHINE" ]; then
  MACHINE="-m $MACHINE"
fi

EMEWS_EXT=$EMEWS_PROJECT_ROOT/ext/emews

# Copies ME config file to experiment directory
FNAME=$(basename $ME_CONFIG)
ME_CONFIG_CP=$TURBINE_OUTPUT/$FNAME
cp $ME_CONFIG $ME_CONFIG_CP

CMD_LINE_ARGS="$* --me_config_file=$ME_CONFIG_CP --trials=$CFG_TRIALS"

# CMD_LINE_ARGS can be extended with +=:
# CMD_LINE_ARGS+="-another_arg=$ANOTHER_VAR"

# TODO: Some slurm machines may expect jobs to be run
# with srun, rather than mpiexec (for example). If
# so, uncomment this export.
# export TURBINE_LAUNCHER=srun

# TODO: Add any script variables that you want to log as
# part of the experiment meta data to the USER_VARS array,
# for example, USER_VARS=("VAR_1" "VAR_2")
USER_VARS=()
# log variables and script to to TURBINE_OUTPUT directory
log_script
# echo's anything following this to standard out
set -x
SWIFT_FILE=eqr_workflow.swift
swift-t -n $PROCS $MACHINE -p -I $EQR -r $EQR \
    -I $EMEWS_EXT -r $EMEWS_EXT \
    -e TURBINE_MPI_THREAD \
    -e TURBINE_OUTPUT \
    -e EMEWS_PROJECT_ROOT \
    $EMEWS_PROJECT_ROOT/swift/$SWIFT_FILE \
    $CMD_LINE_ARGS
