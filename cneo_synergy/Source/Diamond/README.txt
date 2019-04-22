README
--------

Ignatius Pang 31st October 2019

This readme describes how I've performed Blast2Go on all Sepsis strains. Briefly, I've used the Diamond tool (Buchfink et al. 2015) to run fast blast searches of each proteome agains the Uniprot SwissProt database. I then imported the XML Blast output files into Blast2GO, where GO terms are mapped to each protein.

1. Downloaded Uniprot SwissProt (reviewed sequences) fasta file from the ftp site: ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz (UniProt Release 2018_09)

2. Formatted the UniProt fasta database using the following Diamond Command:

diamond makedb --in $UNIPROT_DB/uniprot_sprot.fasta -d $UNIPROT_DB/uniprot_sprot

3. For the proteome of each sepsis strain, run BLASTP agains the Uniprot SwissProt sequence database. Searches were performed using the following command:

diamond blastp --db $REF_UNIPROT_DB --tmpdir $TMPDIR --outfmt 5 --salltitles --evalue 1e-3 --max-target-seqs 3 \
 --threads 2 --out $RESULTS_DIR/$strain_name.xml --query $file_name

4. Import all of the legacy XML BlastP output into Blast2Go

5. Run Mapping (GO version 28th Oct 2018)

6. Run Annotation

7. Filter GO annotation by Taxa (bacteria taxa:2,Bacteria)

8. Removed level 1 GO terms

9. Results exported


Reference:
The Diamond tool " B. Buchfink, Xie C., D. Huson, "Fast and sensitive protein alignment using DIAMOND", Nature Methods 12, 59-60 (2015)." will be used to perform fast Blast searches





