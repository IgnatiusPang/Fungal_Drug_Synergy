
## Move fastq files from UNSW research data store to Katana drives 
screen -S z3371724

./download.sh "/UNSW_RDS/D0234352/cneo_AMB_only_control" "/srv/scratch/z3371724/Fungal/Data/Synergy"
./download.sh "/UNSW_RDS/D0234352/cneo_AMB_only" "/srv/scratch/z3371724/Fungal/Data/Synergy"
./download.sh "/UNSW_RDS/D0234352/cneo_AMB_LF_control" "/srv/scratch/z3371724/Fungal/Data/Synergy"
./download.sh "/UNSW_RDS/D0234352/cneo_AMB_LF" "/srv/scratch/z3371724/Fungal/Data/Synergy"

## Move index over
rsync -artuvz z3371724@Clive.ramaciotti.unsw.edu.au:/share/bioinfo/igy/cneo_flubendazole/Data/C_neoformans_genome /srv/scratch/z3371724/Fungal/Data
rsync -artuvz z3371724@Clive.ramaciotti.unsw.edu.au:/share/bioinfo/igy/cneo_flubendazole/Data/C_neoformans_index /srv/scratch/z3371724/Fungal/Data


cd /srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352/cneo_AMB_only_control

mkdir rep_8G
mkdir rep_2K
mkdir rep_5L

mv *_8G_*.fastq.gz rep_8G
mv *_2K_*.fastq.gz rep_2K
mv *_5L_*.fastq.gz rep_5L


cd /srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352/cneo_AMB_only

mkdir rep_1C
mkdir rep_5F
mkdir rep_4A

mv *_1C_*.fastq.gz rep_1C
mv *_5F_*.fastq.gz rep_5F
mv *_4A_*.fastq.gz rep_4A

cd /srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352/cneo_AMB_LF_control

mkdir rep_7B
mkdir rep_3D
mkdir rep_6F

mv *_7B_*.fastq.gz rep_7B
mv *_3D_*.fastq.gz rep_3D
mv *_6F_*.fastq.gz rep_6F


cd /srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352/cneo_AMB_LF

mkdir rep_8H
mkdir rep_5A
mkdir rep_2G


mv *_8H_*.fastq.gz rep_8H
mv *_5A_*.fastq.gz rep_5A
mv *_2G_*.fastq.gz rep_2G


## Copy Scripts
cd /home/ignatius/PostDoc/2019/cneo_synergy/Source/Read_Mapping_and_Counting
scp submit.sh  kdm:/srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352
scp hisat2.pbs kdm:/srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352
scp  sam_to_bam_sort_index.pbs kdm:/srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352
scp featureCounts.pbs kdm:/srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352
scp tidy_up_files.pbs kdm:/srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352
scp tar_zip_files.sh kdm:/srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352

## get Subreads and featureCount tool
cd /srv/scratch/z3371724/Fungal/Programs
wget https://sourceforge.net/projects/subread/files/subread-1.6.4/subread-1.6.4-Linux-x86_64.tar.gz/download
mv download subread-1.6.4-Linux-x86_64.tar.gz
tar -zxvf subread-1.6.4-Linux-x86_64.tar.gz 
cd subread-1.6.4-Linux-x86_64/


## http://www.ici.upmc.fr/cluego/ClueGOcyRESTExample.R
## /home/ignatius/ClueGOConfiguration/v2.5.3/ClueGOSourceFiles/Organism_Cryptococcus neoformans var. grubii H99

## Compress the files 
qsub tar_zip_files.sh


##  Copy the bam files and the read counts to UNSW RDS data archives 
module add unswdataarchive/2017-02-06
cd /srv/scratch/z3371724/Fungal/Data/Synergy/script

screen -S z3371724
upload.sh "/srv/scratch/z3371724/Fungal/Results/cneo_synergy_hisat2_20190409.tar.gz" "/UNSW_RDS/D0234352/C_neoformans_bam_files_Yu_Wen/hisat2_featureCounts"


## Copy files back to home 
rsync -artuvz   kdm:/srv/scratch/z3371724/Fungal/Results/Synergy/Read_Counts/* /home/ignatius/PostDoc/2019/cneo_synergy/Rresults/Read_Counts/cneo/Original_Files

scp babs:/home/ignatius/PostDoc/2013/Fungal_Shared/Source/v1.01/RNA_seq/EdgeR/Design_Matrices/cneo_synergy.tab \
    /home/ignatius/PostDoc/2019/cneo_synergy/Data/Experimental_Design


    













