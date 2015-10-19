#!/bin/tcsh

##
## USAGE: run.peaks
##

if ($#argv != 0) then
  grep '^##' $0
  exit
endif

# set path
set path = (./code/code $path)

scripts-send2err "=== Generating peaks ============="
scripts-create-path results/
set jid = ()

foreach params (params/params.*)
  set out = results/peaks.`echo $params | sed 's/.*\///' | sed 's/^params\.//'`
  scripts-send2err "- out = $out"

  # call peaks
  scripts-create-path $out/
  foreach aln (alignments/results/align.*)
    set sample = `echo $aln | sed 's/.*\/align\.//'`
    set control = `cat inputs/sample-sheet.tsv | grep -v '^#' | cut -f2,3 | grep "^$sample	" | cut -f2`
    set bam = $aln/alignments.bam
    if ($control == 'n/a') then
      set bam_control = 
    else
      set bam_control = alignments/results/align.$control/alignments.bam
    endif
    set out_peaks = $out/peaks.$sample
    if (! -e $out_peaks) then
      scripts-send2err "Processing $sample..." 
      scripts-create-path $out_peaks/
      set jid = ($jid `scripts-qsub-run $out_peaks/job.peaks.$sample 1 ./code/peaks-call $out_peaks $params "$bam" "$bam_control"`)  # TODO: allow multiple bams per treatment/control
    else 
      scripts-send2err "Warning: $out_peaks already exists, skipping..."
    endif
  end
end

scripts-send2err "Waiting for all jobs to finish..."
scripts-qsub-wait "$jid"
scripts-send2err "Done."



