#!/bin/bash
###Kraken taxonomy classification

main_directory="/usr/tmp"
data_directory=${main_directory}/Data
result_directory=${main_directory}/result

cd ${main_directory}

for x in `cat ${main_directory}/data.txt`
do
y=${x%.fastq}

kraken2 --threads 2 --db $kraken2_DB --confidence 0.05 ${data_directory}/$Input.fastq --report ${result_directory}/${y}.txt 

cd ${main_directory}

done

