
## List of directories
base_directory    <- "/home/ignatius/PostDoc/2019/Fungal_Drug_Synergy/scer_synergy"
data_directory    <- file.path ( base_directory, "Data" ) 
source_directory  <- file.path( base_directory, "Source")
common_directory  <- file.path( source_directory, "Common")  # Commonly used codes (e.g. parameters file)
results_directory <- file.path( base_directory, "Results")

## Gene Ontology annotations
gene_ontology_directory <- file.path( data_directory, "Gene_Ontology_Annotation")

## Read Counts Data
read_counts_directory <- file.path (results_directory, "Read_Counts")
scer_original_read_counts_dir <-  file.path (read_counts_directory, "scer/Original_Files" )
scer_read_counts_file <- file.path( read_counts_directory, "scer", "all_concatenated.txt" )

## Design Matrix
scer_design_matrix_file <- file.path ( data_directory, "Experimental_Design", "scer_synergy.tab")

## EdgeR results directory 
edger_results_dir <-  file.path ( results_directory, "Differential_Expression/EdgeR" ) 

## EdgeR and RUVs results directory 
edger_ruvs_ql_results_dir <-  file.path ( results_directory, "Differential_Expression/EdgeR_RUVs_QL" ) 
scer_edger_ruvs_ql_results_dir <-  file.path ( edger_ruvs_ql_results_dir, "scer" ) 
scer_edger_ruvs_ql_chosen_dir <- file.path( results_directory, "Differential_Expression/EdgeR_RUVs_QL/scer/To_Use_k_1" ) 


## false discover rate cut-off for significantly differentially expressed genes
de_genes_fdr_cutoff <- 0.05

## Samples to remove
samples_to_remove <- c()  # 






