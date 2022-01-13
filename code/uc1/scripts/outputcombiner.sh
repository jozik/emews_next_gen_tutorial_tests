#!/bin/bash

set -eu

tproot="$PWD/.."
exp_dirs="../exp_dirs"
EXPID="1"
scenario_dir="scenario.rs"
config_props="config.props"

while getopts ":t:e:i:s:c:" opt; do
  case $opt in
    t)  tproot="$OPTARG"
    ;;
    e)  exp_dirs="$OPTARG"
    ;;
    i)  EXPID="$OPTARG"
    ;;
    s)  scenario_dir="$OPTARG"
    ;;
    c)  config_props="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

exp_dir_path="$exp_dirs/exp_$EXPID"
if [ ! -e $exp_dir_path ]; then
    echo "Error: $exp_dir_path doesn't exist" >&2
    exit 1
fi

cd $exp_dir_path
# echo $PWD

# needs to be named scenario.rs in the exp directory since ClusterOutputCombiner
# expects it
if [ ! -e scenario.rs ]; then
    ln -s "$tproot/complete_model/$scenario_dir" scenario.rs
fi

if [ ! -e config.props ]; then
    cp "$tproot/complete_model/$config_props" config.props
fi

java -Xmx1024m -XX:-UseLargePages -cp "$tproot/complete_model/lib/*" repast.simphony.batch.ClusterOutputCombiner . combined_data_$EXPID

