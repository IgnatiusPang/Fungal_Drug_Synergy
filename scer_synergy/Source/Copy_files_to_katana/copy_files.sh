
## Move fastq files from UNSW research data store to Katana drives 
module add unswdataarchive/2017-02-06
cd /srv/scratch/z3371724/Fungal/Data/scer_synergy/script
mkdir /srv/scratch/z3371724/Fungal/Data/scer_synergy

screen -S z3371724

./download.sh "/UNSW_RDS/D0234352/scer_AMB_only_control" "/srv/scratch/z3371724/Fungal/Data/scer_synergy"
./download.sh "/UNSW_RDS/D0234352/scer_AMB_only" "/srv/scratch/z3371724/Fungal/Data/scer_synergy"
./download.sh "/UNSW_RDS/D0234352/scer_AMB_LF_control" "/srv/scratch/z3371724/Fungal/Data/scer_synergy"
./download.sh "/UNSW_RDS/D0234352/scer_AMB_LF" "/srv/scratch/z3371724/Fungal/Data/scer_synergy"

## Move index over
# https://www.biostars.org/p/45791/
cd /home/ignatius/PostDoc/2019/scer_synergy/Programs/gffread-0.11.2.Linux_x86_64
./gffread -E  /home/ignatius/PostDoc/2019/scer_synergy/Data/S_cerevisiae_genome/s.cerevisiae.gff -T -o /home/ignatius/PostDoc/2019/scer_synergy/Data/S_cerevisiae_genome/s.cerevisiae.gtf


cd /home/ignatius/PostDoc/2019/scer_synergy/Data/S_cerevisiae_genome/
scp s.cerevisiae.gtf kdm:/srv/scratch/z3371724/Fungal/Data/S_cerevisiae_genome
scp s.cerevisiae.fa kdm:/srv/scratch/z3371724/Fungal/Data/S_cerevisiae_genome


scp /home/ignatius/PostDoc/2019/scer_synergy/Source/Read_Mapping_and_Counting/building_genome_index.sh kdm:/srv/scratch/z3371724/Fungal/Data/scer_synergy/


## Collate the folders 

cd /srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352/scer_AMB_only_control

mkdir rep_3F
mkdir rep_5G
mkdir rep_8A

mv *_3F_*.fastq.gz rep_3F
mv *_5G_*.fastq.gz rep_5G
mv *_8A_*.fastq.gz rep_8A


cd /srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352/scer_AMB_only

mkdir rep_2I
mkdir rep_4E
mkdir rep_9E

mv *_2I_*.fastq.gz rep_2I
mv *_4E_*.fastq.gz rep_4E
mv *_9E_*.fastq.gz rep_9E

cd /srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352/scer_AMB_LF_control

mkdir rep_1B
mkdir rep_3G
mkdir rep_4I

mv *_1B_*.fastq.gz rep_1B
mv *_3G_*.fastq.gz rep_3G
mv *_4I_*.fastq.gz rep_4I


cd /srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352/scer_AMB_LF

mkdir rep_2F
mkdir rep_5C
mkdir rep_9D


mv *_2F_*.fastq.gz rep_2F
mv *_5C_*.fastq.gz rep_5C
mv *_9D_*.fastq.gz rep_9D


## Copy Scripts
cd /home/ignatius/PostDoc/2019/scer_synergy/Source/Read_Mapping_and_Counting
scp submit.sh  kdm:/srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352
scp hisat2.pbs kdm:/srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352
scp  sam_to_bam_sort_index.pbs kdm:/srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352
scp featureCounts.pbs kdm:/srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352
scp tidy_up_files.pbs kdm:/srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352
scp tar_zip_files.sh kdm:/srv/scratch/z3371724/Fungal/Data/scer_synergy/UNSW_RDS/D0234352

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
cd /srv/scratch/z3371724/Fungal/Data/scer_synergy/script

screen -S z3371724
upload.sh "/srv/scratch/z3371724/Fungal/Results/scer_synergy_hisat2_20190410.tar.gz" "/UNSW_RDS/D0234352/C_neoformans_bam_files_Yu_Wen/hisat2_featureCounts"


## Copy files back to home 
rsync -artuvz   kdm:/srv/scratch/z3371724/Fungal/Results/scer_synergy/Read_Counts/* /home/ignatius/PostDoc/2019/scer_synergy/Results/Read_Counts/scer/Original_Files

scp babs:/home/ignatius/PostDoc/2013/Fungal_Shared/Source/v1.01/RNA_seq/EdgeR/Design_Matrices/scer_synergy.tab \
    /home/ignatius/PostDoc/2019/scer_synergy/Data/Experimental_Design


    













