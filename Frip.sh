#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=200G        # 5GB
#SBATCH --job-name=test
Sample=${1}
fPeak=${2}
nlines=$( wc -l $Sample |tail -n 1 | awk '{print $1}')
Peak_numbers=$(bedtools sort -i ${fPeak} | bedtools merge -i stdin | wc -l)
fraction_number=$(bedtools sort -i ${fPeak} | bedtools merge -i stdin | bedtools intersect -nonamecheck -u -a $Sample -b stdin | wc -l)
short_Frip=$(printf "%.5f" $(echo "scale=5;$fraction_number/$nlines" | bc))
