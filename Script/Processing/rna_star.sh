#!/bin/bash

# Function to print help
print_usage()
{
	   echo "Usage: $(basename "$0") [ -t {target_intervals} -f {file set} ]"; 
	   echo "Where -f override file(s) to be run in pipeline, default = '*.fastq.gz'";
	   return
}

# set default parameters
fset=""; 
default_fset='*.fastq.gz'

# Parse command line options
OPTIND=1
while getopts "f:h" OPT
do
  case "$OPT" in
    f) fset="$OPTARG";;
    h) print_usage; exit 1;;
   \?) print_usage; exit 1;;
    :) echo "Option -$OPTARG requires an argument."; print_usage; exit 1;;
  esac
done

if [ "$fset" == "" ]; then
  fset=$default_fset
fi

# Turn on extended globbing (allowing regex in file matching patterns)
shopt -s extglob

# STAR-Fusion requires STAR (v2.6.0+) and samtools to be in PATH
export PATH=$PATH:/mnt/ix1/Resources/tools/STAR/v2.6.0a/bin/Linux_x86_64:/mnt/ix1/Resources/tools/samtools-1.6

# Alignment and transcript counting
MAX_JAVA_MEM=2g ${BPIPE_EXE} run -n $MAX_THREADS -l mem=$GB_MEM -rf "${LOG_REPORT}.html" \
                                 ${PIPES_DIR}/rnabulk_starJ.pipe ${fset}
