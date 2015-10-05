#!/bin/bash

# the location of the final report to output
FINAL_REPORT="./report_output/final_report.Rmd"

# check to make sure the output report exists
if [ -f $FINAL_REPORT ];
then
	# if it already exists, delete it, and copy over the new report first page
	rm $FINAL_REPORT && cp ~/pipelines/reporting/report_building_blocks/first_page.Rmd $FINAL_REPORT
else
	# if the report does not already exist, copy over the first page of the report
	cp ~/pipelines/reporting/report_building_blocks/first_page.Rmd $FINAL_REPORT
fi

# look for alignment results
if [ -d ./demo_dirs/chipseq_standard/alignments ]
then
        # if the alignment results are present, then concatenate them to the final report
        cat ./report_building_blocks/chunk_alignment.Rmd >> $FINAL_REPORT
fi

# look for analysis results, such as the pca results
if [ -d ./demo_dirs/chipseq_standard/pca ]
then
	# if the pca results are present, then concatenate the pca report chunk to the final report
	cat ./report_building_blocks/chunk_pca.Rmd >> $FINAL_REPORT
fi

# look for other results, such as the call peaks data (doesn't exist!)
if [ -d ./demo_dirs/chipseq_standard/call_peaks ]
then
	cat ./report_building_blocks/chunk_peak_calling.Rmd >> $FINAL_REPORT
fi
