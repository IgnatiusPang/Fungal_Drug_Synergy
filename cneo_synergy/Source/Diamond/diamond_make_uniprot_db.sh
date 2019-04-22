#!/bin/bash

#PBS -N MakeDiamDB
#PBS -l nodes=1:ppn=1
#PBS -l vmem=8gb
#PBS -l walltime=11:00:00
#PBS -j oe
#PBS -M i.pang@unsw.edu.au
#PBS -m ae

module load diamond/0.9.24

UNIPROT_DB=/srv/scratch/z3371724/Fungal/Data/Uniprot

gunzip $UNIPROT_DB/uniprot_sprot.fasta.gz

diamond makedb --in $UNIPROT_DB/uniprot_sprot.fasta -d $UNIPROT_DB/uniprot_sprot
