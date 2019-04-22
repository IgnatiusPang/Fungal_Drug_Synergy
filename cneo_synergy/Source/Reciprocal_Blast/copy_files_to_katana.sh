

LOCAL_DATA_DIR=/home/ignatius/PostDoc/2019/cneo_synergy/Data
REMOTE_DATA_DIR=/srv/scratch/z3371724/Fungal/Data

scp $LOCAL_DATA_DIR/Uniprot/uniprot-cryptococcus+neoformans+h99.fasta katana:$REMOTE_DATA_DIR/C_neoformans_proteome
scp $LOCAL_DATA_DIR/Uniprot/uniprot-proteome_UP000002311.fasta katana:$REMOTE_DATA_DIR/S_cerevisiae_proteome


scp /home/ignatius/PostDoc/2019/cneo_synergy/Source/Reciprocal_Blast/make_blastdb_2.sh katana:/srv/scratch/z3371724/Fungal/Source/BlastP




scp katana:/srv/scratch/z3371724/Fungal/Results/BlastP/*  /home/ignatius/PostDoc/2019/cneo_synergy/Results/BlastP

