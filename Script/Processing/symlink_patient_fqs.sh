#!/bin/bash
CODE_DIR='/mnt/IPGcrc/00_Code'
RUN_DIR='/mnt/IPGcrc/Seq_Runs'
PROJECT_DIR='/mnt/IPGcrc/IPG03_exome_crc'
SAMPLE_DIR="${PROJECT_DIR}/00_Samples"

# Function to print help
print_usage()
{
	   echo "Usage: $(basename "$0") -p {patient#} -r {run#}"; 
	   echo "Where -p is the LIMS patient#";
	   echo "      -r is the LIMS integer run#";
	   return
}

# Parse command line options
while getopts "p:r:h" OPT
do
  case "$OPT" in
    p) patient="$OPTARG";;
    r) run_nr="$OPTARG";;
    h) print_usage; exit 1;;
   \?) print_usage; exit 1;;
    :) echo "Option -$OPTARG requires an argument."; print_usage; exit 1;;
  esac
done

if [ "$run_nr" == "" ]; then
  print_usage; exit 1;
fi

if [ "$patient" == "" ]; then
  print_usage; exit 1;
fi

# Zero fill run#, and patient# to match LIMS format
zrun=`printf %04d $run_nr`
zpatient=`printf %05d $patient`

# List of libraries/patients/samples for each run should already be in $PROJECT_DIR/00_Samples 
# If not, create by running: ruby /mnt/IPGcrc/00_Code/scripts/utility/get_libs_list.rb <run#>
# Output file will be R{run_nr}_libs_samples.tsv
#ruby ${CODE_DIR}/scripts/utility/get_libs_list.rb $run_nr

# Get list of fastqs from sequencing run directory
run_dir=$(ls -d ${RUN_DIR}/*_${zrun})
fq_dir=${run_dir}/Fastq
echo "Retrieving fastqs from $fq_dir"
ls ${fq_dir}/L*.fastq.gz >R${run_nr}_fastq_list.txt
  
# Now create symlink commands to link and rename fastqs based on patient/sample
python ${CODE_DIR}/scripts/utility/symlink_fastqs.py ${SAMPLE_DIR}/R${run_nr}_libs_samples.tsv R${run_nr}_fastq_list.txt >R${run_nr}_ln_cmds.sh

# Extract only specified patient from R${run_nr}_ln_cmds.sh
awk -v patient="P$zpatient" '$4 ~ patient {print}' R${run_nr}_ln_cmds.sh >P${patient}_ln_cmds.sh

# Run symlink commands
source P${patient}_ln_cmds.sh

# Remove intermediate files
rm R${run_nr}_fastq_list.txt
rm R${run_nr}_ln_cmds.sh
