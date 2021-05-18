#!/bin/bash

ct_dir='.'
>all.htseq.counts.txt

i=0
for fn in ${ct_dir}/P*.Aligned.htseq.counts.txt 
do
  ((i+=1))
  basefn=$(basename $fn)
  sample=$(echo $basefn | awk -F. '{ print $1 }')
  echo "Processing sample $sample"
  if [[ $i -eq 1 ]]; then sed "1i Gene\t$sample" $fn | cut -f1 >all.htseq.counts.txt; fi;
  sed "1i Gene\t$sample" $fn | cut -f2 | paste all.htseq.counts.txt - >tmp.htseq.counts.txt
  mv tmp.htseq.counts.txt all.htseq.counts.txt
done

  
