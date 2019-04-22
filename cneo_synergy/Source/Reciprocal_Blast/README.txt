README
-------

This is a draft of the orthologs between all pairs of strains. This is a preliminary draft only, meant for exploratory data analysis and for the November 2018 Sepsis workshop. Not to be used for final publications, please use at your own risk. 

Ignatius Pang and William Klare 

Identification of Orthologs Using Reciprocal Top Hits from Blastp
-----------------------------------------------------------------

1. For each strain, all protein sequences from chromosome and plasmids (.faa files) were concatenated into one .faa file. 
2. A blast database were created using makeblastdb function (blast+/2.6.0)

makeblastdb -in $file_name -input_type fasta -dbtype prot -title $strain_name -hash_index 

3. Perform pairwise blastp search to compare each strain with another. Only get the top hit for each query sequence. No comparisons were made between a strain against itself. The BLASTP (blast+/2.6.0) command:

blastp -query $query_file_name -db $db_file_name -outfmt 7 -max_target_seqs 1 -num_threads 4 -out $OUTPUT_DIR/$query_stain_name\_$db_strain_name.tab

4. Concatenate all the result files together. Only keep hits with e-value < 1 x 10&-6.

5. Find reciprocal top hits for all proteins between every pair of strains.

Output Files:

reciprocal_best_hits_evalue_10e-6.txt - List of reciprocal best hits, including the gene IDs for each pair of orthologs. Include basic output statistics from blastp. Please refer to the Blastp manual for details on the statistics.

cytoscape_reciprocal_blastp_cleaned_evalue_10e-6.txt - List of reciprocal best hits, keeping only the gene IDs of the two orthologous proteins. This list of pairs are uploaded into Cytoscape for visualisation of orthologous clusters.

cleaned_master_annotation_table.tsv - annotations of all genes from all strains

all_genes_without_orthologs.txt - list of all the genes without any orthologs 



Identification of Orthologous Clustes using the ClusterOne App from Cytoscape
------------------------------------------------------------------------------

1. Cytoscape and the ClusterOne app was installed.
2. File -> Import Network from File: 'cytoscape_reciprocal_blastp_cleaned_evalue_10e-6.txt'. Assign the columns gene_id.a and gene_id.b as source and target nodes respectively.
3. The resulting network represents how the proteins are othologous to each other. A line connecting two proteins means the two proteins are othologs of each other. You can also see many different connected sub-groups of proteins, which represents disting orthologous groups.
4. Run ClusterOne using default parameters. ClusterOne will identify clusters of genes that are densely connected together in the network.
5. Save all results files using the Save button in the ClusterOne Results Panel. 
6. Analyse the file 'ClusterOne_GenePro_format.tab' to find genes that are shared by two or more orthologous clusters. 

Result files files:

orthologs_network.cys - Cytoscape file. Each node represent a protein (from one specie) and a edge connecting two nodes represent that the two proteins are orthologs (reciprocal top hits from blastp). Nodes are colored according to each species.

ClusterOne_Cluster_List.txt - Each line represents the results for each cluster. The proteins in each cluster are shown in the same row, separated by tabs.
ClusterOne_Detailed_cluster_list.csv - Detailed clustering statistics for each cluster identified by ClusterOne. Each line represents one cluster
ClusterOne_GenePro_format.tab - Show the cluster ID to protein/gene ID pairs.

gene_ids_shared_between_clusters.txt - List of genes that are shared by two or more clusters. It also contain two additional columns: 1)  the number of clusters the protein are shared among, and 2) the list of cluster IDs in which the protein are part of

















