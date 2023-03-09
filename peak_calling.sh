#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G        # 5GB

##input treatment
fin=${1}
gDNA=${2}
Esize=${3}
Tsize=${4}
Ssize=${5}
DIR_MAC_narrow=${6}
DIR_BASE=$(pwd)
###method 1
macs2 callpeak \
--treatment ${fin}.bed \
--control ${gDNA}.bed \
--format BED \
--name ${Sfin}_atac \
--outdir $DIR_MAC_narrow \
--bdg \
--gsize hs \
--tsize $Tsize \
--nomodel \
--qvalue 0.05 \
--SPMR \
--keep-dup all \
--call-summits \
--shift -$sszie \
--extsize $Eszie \
--tempdir ${DIR_BASE}
###method 2
macs2 callpeak \
--treatment ${fin}.bam \
--control ${gDNA}.bam \
--format BAMPE \
--name ${fin}_chip \
--outdir $DIR_MAC_narrow \
--bdg \
--gsize hs \
--tsize $Tsize \
--qvalue 0.05 \
--SPMR \
--keep-dup all \
--call-summits \
--tempdir ${DIR_BASE}
