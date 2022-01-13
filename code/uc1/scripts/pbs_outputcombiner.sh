#!/bin/bash

#PBS -N rs_outputcombiner 
#PBS -l nodes=1:ppn=1 
#PBS -l walltime=01:30:00 
#PBS -j oe
#PBS -o ../exp_dirs/exp_$EXPID/outputcombiner_output.txt 
#PBS -V

# Send EXPID as environment variable: qsub -vEXPID="myexpid" pbs_outputcombiner.sh
cd ${PBS_O_WORKDIR}/../exp_dirs/exp_$EXPID
ln -s "../../complete_model/scenario.rs" scenario.rs
cp "../../complete_model/config.props" .
java -Xmx8192m -XX:-UseLargePages -cp "../../complete_model/lib/*" repast.simphony.batch.ClusterOutputCombiner . combined_data_$EXPID

