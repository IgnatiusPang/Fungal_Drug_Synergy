
module load python/2.7.12

GENOME_DIR=/share/bioinfo/igy/cneo_flubendazole/Data/C_neoformans_genome
INDEX_DIR=/share/bioinfo/igy/cneo_flubendazole/Data/C_neoformans_index

hisat2_extract_splice_sites.py $GENOME_DIR/c.neoformans.gtf > $GENOME_DIR/splicesites.txt

hisat2_extract_exons.py $GENOME_DIR/c.neoformans.gtf > $GENOME_DIR/exons.txt

cd $INDEX_DIR

nohup hisat2-build --ss $GENOME_DIR/splicesites.txt --exon $GENOME_DIR/exons.txt $GENOME_DIR/c.neoformans.fa c.neoformans > nohup_hisat2-build.log &

