#!/bin/bash 

#PBS -l nodes=1:ppn=4
#PBS -l vmem=30GB
#PBS -l walltime=12:00:00
#PBS -M i.pang@unsw.edu.au
#PBS -j oe
#PBS -m ae

cd $PBS_O_WORKDIR

module load python/2.7.12
module load hisat2/2.1.0

GENOME_DIR=/srv/scratch/z3371724/Fungal/Data/S_cerevisiae_genome
INDEX_DIR=/srv/scratch/z3371724/Fungal/Data/S_cerevisiae_index
HISAT2_DIR=/share/apps/hisat2/2.1.0

python $HISAT2_DIR/hisat2_extract_splice_sites.py $GENOME_DIR/s.cerevisiae.gtf > $GENOME_DIR/splicesites.txt

python $HISAT2_DIR/hisat2_extract_exons.py $GENOME_DIR/s.cerevisiae.gtf > $GENOME_DIR/exons.txt

cd $INDEX_DIR

$HISAT2_DIR/hisat2-build --ss $GENOME_DIR/splicesites.txt --exon $GENOME_DIR/exons.txt $GENOME_DIR/s.cerevisiae.fa s.cerevisiae > nohup_hisat2-build.log &

