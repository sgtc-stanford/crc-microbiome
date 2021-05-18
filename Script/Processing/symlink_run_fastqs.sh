#!/bin/bash

# Function to print help
print_usage()
{
	   echo "Usage: $(basename "$0") -r {run#} -f {fastq dir} -l {lane #s}"; 
	   echo "Where -r is the LIMS integer run#";
	   echo "      -f is the fastq source directory";
           echo "      -l is comma-separated list of lanes to include";
	   return
}

# Parse command line options
while getopts "r:f:l:h" OPT
do
  case "$OPT" in
    r) run_nr="$OPTARG";;
	f) fq_dir="$OPTARG";;
    l) lane_nrs="$OPTARG";;
    h) print_usage; exit 1;;
   \?) print_usage; exit 1;;
    :) echo "Option -$OPTARG requires an argument."; print_usage; exit 1;;
  esac
done

# First get list of libraries with patient/sample info, from LIMS, for given run#
# Output file: R{run_nr}_libs_samples.tsv
ruby ${CODE_DIR}/scripts/utility/get_libs_list.rb $run_nr $lane_nrs

# Next get list of fastq files from sequencing run output
# Remove trailing '/' if included in supplied directory name 
if [[ "$fq_dir" =~ '/'$ ]]; then 
  fq_dir=${fq_dir:0:-1}
fi
ls ${fq_dir}/L*.fastq.gz >R${run_nr}_fastq_list.txt 

# Now create symlink commands to link and rename fastqs based on patient/sample
python ${CODE_DIR}/scripts/utility/symlink_fastqs.py R${run_nr}_libs_samples.tsv R${run_nr}_fastq_list.txt >R${run_nr}_ln_cmds.sh

# Run symlink commands
source R${run_nr}_ln_cmds.sh

# Remove intermediate files
#rm R${run_nr}_fastq_list.txt
#rm R${run_nr}_libs_samples.tsv
