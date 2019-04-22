#!/bin/bash

#PBS -N Diamond[]
#PBS -l nodes=1:ppn=2
#PBS -l vmem=8gb
#PBS -l walltime=11:00:00
#PBS -j oe
#PBS -M i.pang@unsw.edu.au
#PBS -m ae


module load diamond/0.9.24

UNIPROT_DB=/srv/scratch/z3371724/Fungal/Data/Uniprot
REF_UNIPROT_DB="$UNIPROT_DB/uniprot_sprot"
RESULTS_DIR=/srv/scratch/z3371724/Fungal/Results/Diamond

data_dir=/srv/scratch/z3371724/Fungal/Data/C_neoformans_proteome

file_name=$data_dir/c_neoformans_all_proteins.fasta
strain_name="C_neoformans_H99"

TMPDIR=/srv/scratch/z3371724/Fungal/Temp/Diamond

#########################################################
echo $file_name
echo $strain_name

diamond blastp --db $REF_UNIPROT_DB --tmpdir $TMPDIR --outfmt 5 --salltitles --evalue 1e-3 --max-target-seqs 3 \
 --threads 2 --out $RESULTS_DIR/$strain_name.xml --query $file_name


