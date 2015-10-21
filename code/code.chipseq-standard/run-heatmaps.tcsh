#!/bin/tcsh

##
## USAGE: run
##

if ($#argv != 0) then
  grep '^##' $0
  exit
endif

# set path
set path = (./code/code $path)

scripts-send2err "=== Generating heatmaps ============="

set row_filter = results/row_filter.txt
set nbins = 50
set inpdir = matrices/results

set jid = ()
set D = `cd $inpdir; ls -1d matrices.*nbins=$nbins`
foreach d ($D)
  set outdir = results/$d
  scripts-send2err "Generating $outdir..."
  if (! -e $outdir) then
    scripts-create-path $outdir/logs/    
    ls -1d $inpdir/$d/matrix.*.tsv | cols -t 0 0 | sed 's/[^\t]*\///' | sed 's/^matrix.//' | sed 's/\.tsv\t/\t/' | sed 's/\([^-]*-[^-]*-[^-]*\)-/\1:/' >! $outdir/dataset.tsv
    set jid = ($jid `scripts-qsub-run $outdir/logs/job.heatmap 1 scripts-heatclustering.r -v -o $outdir/heatmap --log2=false --normalize=none --row-filter=$row_filter --max-cutoff=0 --sd-cutoff=0 --palette=palette.txt --nclust=1 $outdir/dataset.tsv`)
  endif
end

scripts-send2err "Waiting for all jobs to finish..."
scripts-qsub-run "$jid"
scripts-send2err "Done."


