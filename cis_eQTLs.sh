#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=4G
#SBATCH --output=out_slurm/slurm-%A_%a.out
#SBATCH --array=1-29%29
#SBATCH --error=out_slurm_err/slurm-%A_%a.e
gvcf=chr.vcf.gz
bed=pheno.sorted.bed.gz
array_ID=${SLURM_ARRAY_TASK_ID}
cov=co-factor.csv
out=permute_gene_chunk_${array_ID}
window_size=1000000
permute_num=1000
QTLtools cis --vcf ${gvcf} --bed ${bed} --cov ${cov} --window $window_size --permute $permute_num --chunk ${array_ID} 29 --out ${out}
