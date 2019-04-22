#!/bin/bash

#PBS -N BLASTP
#PBS -l nodes=1:ppn=4
#PBS -l vmem=31gb
#PBS -l walltime=12:00:00
#PBS -j oe
#PBS -M i.pang@unsw.edu.au
#PBS -m ae

module load blast+/2.8.1

cneo_proteome=/srv/scratch/z3371724/Fungal/Data/C_neoformans_proteome/uniprot-cryptococcus+neoformans+h99.fasta
scer_proteome=/srv/scratch/z3371724/Fungal/Data/S_cerevisiae_proteome/uniprot-proteome_UP000002311.fasta

OUTPUT_DIR=/srv/scratch/z3371724/Fungal/Results/BlastP

makeblastdb -in $cneo_proteome -input_type fasta -dbtype prot \
  -title C_neoformans -hash_index 

makeblastdb -in $scer_proteome -input_type fasta -dbtype prot \
  -title S_cerevisiae -hash_index 


blastp -query $cneo_proteome -db $scer_proteome -outfmt 7 -max_target_seqs 1 -num_threads 4 \
  		-out $OUTPUT_DIR/query_cneo_db_scer.tab

blastp -query $scer_proteome -db $cneo_proteome -outfmt 7 -max_target_seqs 1 -num_threads 4 \
  		-out $OUTPUT_DIR/query_scer_db_cneo.tab

