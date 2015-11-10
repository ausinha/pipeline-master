#!/bin/bash

##
## USAGE: create-matrix.sh OUTPUT-DIR PARAMETER-SCRIPT PEAKS-BRANCH SAMPLE-NAMES
##

# shell settings (must be included in all scripts)
source ./code/code.main/custom-bashrc

# process command-line inputs
if (($# != 4)); then
  grep '^##' $0
  exit
fi

outdir=$1
params=$2
peaks_branch=$3
samples=($4)

# create record of input branch(es) [TODO: need to figure out a way to do a relative symlink]
echo $peaks_branch > $outdir/obj.branch

# parameters
scripts-send2err "Processing parameter file $params..."
source $params
scripts-send2err "- window = $win"
scripts-send2err "- flank = $flank"
scripts-send2err "- nbins = $nbins"

# determine input files
sheet=inputs/sample-sheet.tsv
aln_branch=$(cat $peaks_branch/*/obj.branch | head -1)
alignments=( $(echo $samples | tr ' ' '\n' | awk -v d=$aln_branch '{print d"/"$0"/alignments.bam"}') )
ref_regions=( $(ls -1 $peaks_branch/*/peaks.bed) )

# create ref.bed
scripts-create-path $outdir/
ref=$outdir/ref.bed
if (($win > 0)); then
  p=$(scripts-create-temp $outdir)
  cat ${ref_regions[*]} | genomic_regions bed > $p
  cat inputs/release/genome.bed | genomic_regions win -s $win -d `echo $win/4 | bc` | awk '{print $1"\t"$2"\t"$3"\t"$1":"$2"-"$3}' | genomic_overlaps subset -i $p > $ref
  rm -f $p
else
  cat ${ref_regions[*]} | genomic_regions bed | scripts-sortbed | genomic_regions link | genomic_regions center | genomic_regions pos -op 1 | genomic_regions shiftp -5p -$flank -3p +$flank | genomic_regions shiftp -5p 0 -3p -1 | awk '{print $1"\t"$2"\t"$3"\t"$1":"$2"-"$3}' > $ref
fi

# check reference labels  
if (( $(genomic_regions reg $ref | cut -f1 | sort | uniq -d | wc -l) > 0)); then
  scripts-send2err "Error: unique labels required in the $ref file."
  exit
fi

# create matrix
threads=${#alignments[@]}
alignments=$(echo ${alignments[*]} | tr ' ' ',')
gtools_threaded matrix -v -i -p $threads --overlap-op hits -nbins $nbins -rpkm $alignments $ref > $outdir/matrix.tsv

# cleanup
rm -f $ref
