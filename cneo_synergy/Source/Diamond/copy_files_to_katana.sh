

wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz


scp /home/ignatius/PostDoc/2019/cneo_synergy/Source/Diamond/diamond_make_uniprot_db.sh katana:/srv/scratch/z3371724/Fungal/Source/Diamond

## Copy the C. neoformans H99 proteome sequences over to katana
cd /srv/scratch/z3371724/Fungal/Data/C_neoformans_proteome

scp /home/ignatius/PostDoc/2013/Fungal_Shared/Data/Broad_C_neoformans_Mar_2014/*proteins.fasta  katana:/srv/scratch/z3371724/Fungal/Data/C_neoformans_proteome

scp /home/ignatius/PostDoc/2019/cneo_synergy/Source/Diamond/run_diamon_on_all_strains.sh katana:/srv/scratch/z3371724/Fungal/Source/Diamond


scp kdm:/srv/scratch/z3371724/Fungal/Results/Diamond/*.xml /home/ignatius/PostDoc/2019/cneo_synergy/Results/Diamond
