#!/bin/bash


script_dir=/srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352
# job="${script_dir}/run_fastqc.pbs"
# job="${script_dir}/concatenate_files.pbs"
# job="${script_dir}/run_fastqc_concat.pbs"
job="${script_dir}/hisat2.pbs"
# job="${script_dir}/tophat2.pbs"
# job="${script_dir}/sam_to_bam_sort_index.pbs"
# job="${script_dir}/featureCounts.pbs"
# job="${script_dir}/run_read_counts_FR_option.pbs"
# job="${script_dir}/htseq-count_int_strict.pbs" 
# job="${script_dir}/htseq-count_int_nonempty.pbs" 
# job="${script_dir}/htseq-count_union.pbs" 
# job="${script_dir}/tidy_up_files.pbs"
# job="${script_dir}/tidy_up_files_FR_option.pbs"

# RAW_FILES_DIR=/home/ignatius/PostDoc/2017/cneo_flubendazole/Data/Raw_Sequencing_Data/TRU4105_20170913_Transcriptomics_MT_2017_non_antifungal_C_neoformans-47539497
RAW_FILES_DIR=/srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352


cd $RAW_FILES_DIR

for EXPERIMENT in $(ls)
do
	count_replicate=0  

	if [[  -d "$EXPERIMENT" ]]
	then
		cd $EXPERIMENT

		for BIO_REP in $(ls)
		do 
				count_replicate=$(($count_replicate+1))

				if [[  -d "$BIO_REP" ]]
				then
					cd $BIO_REP
					
					job_name="${EXPERIMENT}_rep${count_replicate}"
					
					echo "${BIO_REP}\t${job_name}"
					
					cp $job $job_name.`basename $job`
					qsub -v job_name=$job_name  $job_name.`basename $job`

					cd ..
				fi
		done 
		
		cd ..
	fi
done


