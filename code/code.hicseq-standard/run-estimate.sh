#!/bin/bash

##
## USAGE: run-estimate.sh
##

# shell settings
source ./code/code.main/custom-bashrc

# process command-line inputs
if [ $# != 0 ]
then
  grep '^##' $0
  exit
fi

# create results directory
scripts-create-path results/

# matrix
scripts-send2err "=== Estimating matrix using fused lasso ============="
threads=1
op=estimate
scripts-master-loop.sh $threads by-object ./code/hicseq-$op.tcsh results/matrix_estimated "params/params.*.tcsh" "matrix.*/results"

