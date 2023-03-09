#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=60G        # 5GB
#SBATCH --job-name=test

############
ChromInfo=${1}
Sample_merge=${2}
FINAL_BAM_FILE=${3}
FINAL_TA_FILE=${4}
name=${5}
Date=$(date  '+%Y')
DIR_BASE=`pwd`

bedtools bamtobed -i ${FINAL_BAM_FILE} | awk 'BEGIN {OFS = "\t"} ; {if ($6 == "+") { $2 = $2 + 4} else if ($6 == "-") { $3 = $3 - 5} print $0 }' | awk '$2 > 0 && $3 >0 { print $0 }' | awk 'BEGIN{OFS="\t"}{$4="N";$5="1000";print $0}' | bedtools intersect -nonamecheck -a stdin -b $ChromInfo | gzip -nc > ${FINAL_TA_FILE}


PR_PREFIX=${6}
PR1_TA_FILE="${PR_PREFIX}.SE.pr1.tagAlign.gz"
#echo $PR1_TA_FILE
PR2_TA_FILE="${PR_PREFIX}.SE.pr2.tagAlign.gz"
#echo $PR1_TA_FILE
# Get total number of read pairs
nlines=$(zcat ${FINAL_TA_FILE} | wc -l)
#echo -e "nlines\t1\t$nlines"
nlines=$(( (nlines + 1) / 2 ))
#echo -e "nlines\t$nlines"
Scriptname=$(basename $0)
Scriptname=${Scriptname%.sh}

DIR_BASE2=${Date}_${Scriptname}_${name}_temp
mkdir -p $DIR_BASE2

##############
zcat ${FINAL_TA_FILE} | shuf --random-source=<(openssl enc -aes-256-ctr -pass pass:$(zcat -f ${FINAL_TA_FILE} | wc -c) -nosalt </dev/zero 2>/dev/null) | split -d -l ${nlines} - ${PR_PREFIX}

gzip -nc "${PR_PREFIX}00" > ${DIR_BASE_TA}/${PR1_TA_FILE}
rm "${PR_PREFIX}00"
gzip -nc "${PR_PREFIX}01" > ${DIR_BASE_TA}/${PR2_TA_FILE}
rm "${PR_PREFIX}01"
####################
gDNA=${7}
shiftsize=-19
smooth_window=38
DIR_MAC_narrow="${DIR_BASE}/${Date}_10_MACS2_narrow_SPMR"
mkdir -p $DIR_MAC_narrow

###################
macs2 callpeak \
-t ${DIR_BASE_TA}/${PR1_TA_FILE} -f BED -n "${name}pr1" -g hs --qvalue 0.05 --call-summits --tsize 38 --nomodel -B --SPMR --keep-dup all \
	--shift $shiftsize \
	--extsize $smooth_window \
	--outdir $DIR_MAC_narrow \
	--tempdir ${DIR_BASE2} \
	--control ${gDNA}


macs2 callpeak \
-t ${DIR_BASE_TA}/${PR2_TA_FILE} -f BED -n "${name}pr2" -g hs --qvalue 0.05 --call-summits --tsize 38 --nomodel -B --SPMR --keep-dup all \
	--shift $shiftsize \
	--extsize $smooth_window \
	--outdir $DIR_MAC_narrow \
	--tempdir ${DIR_BASE2} \
	--control ${gDNA}

############
REP1_PEAK_FILE=$DIR_MAC_narrow/"${name}pr1"_peaks.narrowPeak
REP2_PEAK_FILE=$DIR_MAC_narrow/"${name}pr2"_peaks.narrowPeak
REP1_sort_PEAK_FILE=$DIR_MAC_narrow/"${name}pr1"_sort_peaks.narrowPeak.gz
REP2_sort_PEAK_FILE=$DIR_MAC_narrow/"${name}pr2"_sort_peaks.narrowPeak.gz
Pooled_narrowPeak=${8}
Pooled_sort_narrowPeak=${9}
###########


rm -rf $DIR_BASE2

sort -k 8gr,8gr $REP1_PEAK_FILE | awk 'BEGIN{OFS="\t"}{$4="Peak_"NR ; print $0}' | gzip -nc > $REP1_sort_PEAK_FILE

sort -k 8gr,8gr $REP2_PEAK_FILE | awk 'BEGIN{OFS="\t"}{$4="Peak_"NR ; print $0}' | gzip -nc > $REP2_sort_PEAK_FILE
sort -k 8gr,8gr ${DIR_BASE_POOL}/${Pooled_narrowPeak} | awk 'BEGIN{OFS="\t"}{$4="Peak_"NR ; print $0}' | gzip -nc > ${DIR_BASE_POOL}/${Pooled_sort_narrowPeak}

intersectBed -wo -a ${DIR_BASE_POOL}/${Pooled_sort_narrowPeak} -b $REP1_sort_PEAK_FILE | awk 'BEGIN{FS="\t";OFS="\t"}{s1=$3-$2; s2=$13-$12; if (($21/s1 >= 0.5) || ($21/s2 >= 0.5)) {print $0}}' | cut -f 1-10 | sort | uniq | intersectBed -wo -a stdin -b $REP2_sort_PEAK_FILE | awk 'BEGIN{FS="\t";OFS="\t"}{s1=$3-$2; s2=$13-$12; if (($21/s1 >= 0.5) || ($21/s2 >= 0.5)) {print $0}}' | cut -f 1-10 | sort | uniq | gzip -nc > ${name}PooledInRep1AndRep2.narrowPeak.gz

IDR_THRESH=0.05 # FOR ENCODE3
IDR_OUTPUT=${name}self_pseudoreplicates_idr

idr --samples ${REP1_sort_PEAK_FILE} ${REP2_sort_PEAK_FILE} --peak-list ${name}PooledInRep1AndRep2.narrowPeak.gz --input-file-type narrowPeak --output-file ${IDR_OUTPUT} --rank p.value --soft-idr-threshold ${IDR_THRESH} --plot --use-best-multisummit-IDR 2>&1
IDR_THRESH_TRANSFORMED=$(awk -v p=${IDR_THRESH} 'BEGIN{print -log(p)/log(10)}')
awk 'BEGIN{OFS="\t"} $12>='"${IDR_THRESH_TRANSFORMED}"' {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' ${IDR_OUTPUT} | sort | uniq | sort -k7n,7n | gzip -nc > ${name}IDR0.05.narrowPeak.gz
