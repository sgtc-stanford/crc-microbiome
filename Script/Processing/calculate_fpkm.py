#!/usr/bin/env python

import glob, re

gene_len = {}
with open("/mnt/ix1/Resources/GenomeRef/Homo_sapiens/NCBI/GRCh38/Annotation/Genes/gene_coding_lengths.txt") as f:
    next(f)
    for lines in f:
        line = lines.rstrip().split("\t")
        gene_len[line[0]]=int(line[1])

for files in glob.glob("HT_seq_counts/*.Aligned.htseq.counts.txt"):
    sample = files.split("/")[-1].split(".")[0]

    print sample
    total_counts = 0

    with open(files) as f:
        for lines in f:
            if not re.match("_",lines):
                line = lines.rstrip().split("\t")
                if line[0] in gene_len:
                    total_counts += int(line[1])

    fout = open("HT_seq_counts/" + sample + '.fpkm.txt',"w")
    with open(files) as f:
        for lines in f:
            if not re.match("_",lines):
                line = lines.rstrip().split("\t")
                if line[0] in gene_len:
                    fpkm = (float(line[1])*10**9)/(float(total_counts * gene_len[line[0]]))
                    fout.write(line[0] + "\t" + str(fpkm) + "\n")
    fout.close()
