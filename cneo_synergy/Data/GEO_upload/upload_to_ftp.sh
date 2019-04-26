


## https://www.ncbi.nlm.nih.gov/geo/info/submissionftp.html
# ncftpput -F -z -u geo -p "33%9uyj_fCh?M16H" ftp-private.ncbi.nlm.nih.gov ./path1 ./path2

# path1: path to a directory you've already created on the ftp server
# path2: path to local file to be transferred to your directory on the ftp server

# -F to use passive (PASV) data connection
# -z is for resuming upload if a file upload gets interrupted
# -R to recursively upload an entire directory/tree

cd /srv/scratch/z3371724/Fungal/Data/Synergy/UNSW_RDS/D0234352

$FILES=`find * | grep .fastq.gz`


for f in $FILES
do
  echo "Processing $f file..."
  # take action on each file. $f store current file name
   ncftpput -F -z -u geo -p "33%9uyj_fCh?M16H" ftp-private.ncbi.nlm.nih.gov $f ./ignatiuspang
done



