#!/bin/bash
###Sequencing Reads Mapping & extract unmapped reads

main_directory="/usr/tmp"
data_directory=${main_directory}/fastq
result_directory=${main_directory}/result

cd ${main_directory}

for x in `cat ${main_directory}/data.txt`
do
y=${x%.fastq}

########Mapping
STAR --runThreadN 6 --genomeDir Genome --readFilesIn $Input.fastq --outSAMunmapped Within --chimSegmentMin 12 --chimJunctionOverhangMin 12 --alignSJDBoverhangMin 10 --alignMatesGapMax 100000 --alignIntronMax 100000 --chimSegmentReadGapMax 3 --alignSJstitchMismatchNmax 5 -1 5 5  --outSAMtype BAM SortedByCoordinate

########unmapped reads whose mate are mapped
samtools view -u -f 4 -F 264 ${result_directory}/${y}_alignments.bam -o ${y}_temp1.bam
samtools view ${y}_temp1.bam | cut -f1,10,11 | sed 's/^/@/' | sed 's/\t/\n/' | sed 's/\t/\n+\n/' > ${y}_temp1.fastq


########mapped read who's mate is unmapped
samtools view -u -f 8 -F 260 ${result_directory}/${y}_alignments.bam -o ${y}_temp2.bam
samtools view ${y}_temp2.bam | cut -f1,10,11 | sed 's/^/@/' | sed 's/\t/\n/' | sed 's/\t/\n+\n/' > ${y}_temp2.fastq


########both reads of the pair are unmapped
samtools view -u -f 12 -F 256 ${result_directory}/${y}_alignments.bam -o ${y}_temp3.bam
samtools view ${y}_temp3.bam | cut -f1,10,11 | sed 's/^/@/' | sed 's/\t/\n/' | sed 's/\t/\n+\n/' > ${y}_temp3.fastq


########merge the unmapped reads
cat ${y}_temp1.fastq ${y}_temp2.fastq ${y}_temp3.fastq > ${y}_unmapped.fastq


cd ${main_directory}

done
