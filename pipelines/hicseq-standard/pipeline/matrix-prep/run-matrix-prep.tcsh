#!/bin/tcsh
source ./code/code.main/custom-tcshrc      # customize shell environment

##
## USAGE: run-matrix-prep.tcsh [--dry-run]
##

#% This step preprocesses contact matrices using scaling by total number of reads, effective length and imputation for missing values.  
#% TABLES: 
#% FIGURES:

# process command-line inputs
if ($#argv > 1) then
  grep '^##' $0 | scripts-send2err
  exit
endif

set opt = "$1"

# setup
set op = matrix-prep
set inpdirs = "inpdirs/*"
set filter = ".res_[0-9]+kb/"               # This excludes distance-restricted matrices (maxd=...)
set results = results
scripts-create-path $results/
scripts-send2err "=== Operation = $op ============="
set resources = 1
set cmd = "./code/code.main/scripts-qsub-wrapper $resources ./code/hicseq-$op.tcsh"

# generate run script
Rscript ./code/code.main/pipeline-master-explorer.r -v -F "$filter" "$cmd" $results/$op "params/params.*.tcsh" "$inpdirs" "" "sample" 1

# run and wait until done!
if ("$opt" != "--dry-run") scripts-submit-jobs ./$results/.db/run



