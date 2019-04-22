
#!/bin/bash 

#PBS -l nodes=1:ppn=1
#PBS -l vmem=11GB
#PBS -l walltime=5:00:00
#PBS -M i.pang@unsw.edu.au
#PBS -j oe
#PBS -m ae

cd /srv/scratch/z3371724/Fungal/Results


tar -czvf  /srv/scratch/z3371724/Fungal/Results/cneo_synergy_hisat2_20190409.tar.gz  /srv/scratch/z3371724/Fungal/Results/Synergy

