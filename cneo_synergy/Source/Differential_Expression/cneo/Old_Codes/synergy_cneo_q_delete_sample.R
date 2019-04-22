#########################################################

# Script:               synergy_cneo_queries.R
# Date:                 10-10-13 
# Last updated:         10-10-13 
# Author:               Ignatius Pang
# Version:              v1.01
# Description: 
# * Analysis of S.cerevisiae, synergy between Amphotericin B and Lactoferrin 

######### Version description ###########################

# v1.01 
#  10-10-13 Igy created the script

#########################################################

### Source location

# cd '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/RNA_seq/EdgeR/cneo'
# ulimit -s 32768 # Change stack to 32 MB
# DATE=$(date +"%Y%m%d")
# nohup R --vanilla < synergy_cneo_q_delete_sample.R > Log/run_synergy_cneo_q_delete_sample_$DATE.log &


##################  DB connection parameters ####################################################################

source('/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/Common/common_functions.R')
source('/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/Common/GO_terms_enrichment/go_term_enrichment.R')
source('/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/RNA_seq/EdgeR/edgeR_common_functions.R')
source('/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/RNA_seq/EdgeR/SOMS.R')
source('/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/Complexes/membrane_protein_complexes_functions.R')

library(RODBC)
library(edgeR)
library(kohonen)
library(genefilter)

input_db <- "sbi_fungal_pathogen_2013"  # The name of the SQL database for the data to be imported into
user_id <- "ignatius"
user_passwd <- "Sp33dBo@t"

conn_string <- paste("SERVER=localhost;DRIVER={PostgreSQL};DATABASE=", input_db,
                     ";PORT=5432;UID=", user_id, ";PWD=", user_passwd ,";LowerCaseIdentifier=0", sep="")

channel <- odbcDriverConnect( conn_string)


set_encoding <- sqlQuery(channel,"SET client_encoding='LATIN1'")

results_directory <- "/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/EdgeR/cneo/"
results_directory_de_list <- paste ( results_directory, "de_list/", sep="")

sessionInfo()

################################################################################################

###### Perform GO terms encrichment tests

load( paste(results_directory_de_list,  "edgeR_cneo_compare_delete_sample_5A.Rdata", sep="") )


##### obtain the length of the genes

gene_length <- sqlQuery ( channel, "select orf_id, abs(start-stop+1)  as gene_length
from genome_annotation_cneo_table
where orf_id is not null
        and start is not null
        and stop is not null;" )


## sort the gene length according to the way cpm table is sorted)

rownames(gene_length) <- as.vector( gene_length[,'orf_id'] )

gene_length <- gene_length[rownames(cpm( cneo_dgelist_del )), c('orf_id','gene_length')]



### Get the C. neoformans gene universe and GO terms mapping

universe <- get_cneo_universe(channel)
go_dictionary <- get_cneo_go_dictionary(channel)

################################################################################################

# source('/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/Common/GO_terms_enrichment/go_term_enrichment.R')

### Determine list of parameters to loop over
de_query_list_id <- c("edgeR_delete_sample_A_down_reg",        "edgeR_delete_sample_A_up_reg", 
                      "edgeR_delete_sample_AL_down_reg",       "edgeR_delete_sample_AL_up_reg", 
                      #"edgeR_delete_sample_synergy_down_reg",  
                      "edgeR_delete_sample_synergy_up_reg" )


de_list_of_queries <- list ( cneo_delete_sample_A_down_reg, cneo_delete_sample_A_up_reg, 
                              cneo_delete_sample_AL_down_reg, cneo_delete_sample_AL_up_reg, 
                              #cneo_delete_sample_synergy_down_reg, 
                              cneo_delete_sample_synergy_up_reg)


## Performs GO terms enrichment test
de_go_terms_temp_results_dir <- paste(results_directory,"go_terms/",sep="")

loop_over_all_go_term_enrichment_tests_crypto(channel, de_go_terms_temp_results_dir, "cneo", de_query_list_id, de_list_of_queries, universe, go_dictionary)


## Calculate enrichment of membrane protein complexes
#de_membrane_temp_results_dir <- paste( results_directory, "membrane_protein_complexes/", sep="")

#loop_membrane_protein_complex_enrichment_cneo (channel, de_membrane_temp_results_dir, de_query_list_id, de_list_of_queries )


################################################################################################
### Calculate RPKM_values

rpkm_values <- cpm(cneo_dgelist_del, log=TRUE)[,  c("X2K", "X5L", "X8G", # CA
"X1C", "X4A", "X5F", # A
"X3D", "X6F", "X7B", # CAL
"X2G", "X8H" # AL
) ] 

rpkm_values <- rpkm_values - log2(gene_length[,'gene_length'])


################################################################################################

#### Compare A Experiment
cneo_delete_sample_A_list_of_de_genes <- unique( c( cneo_delete_sample_A_down_reg, cneo_delete_sample_A_up_reg) )

expt_label <- "delete_sample_A"
expt_label_edger <- paste( "edgeR_",  expt_label, sep="") 

cneo_delete_sample_A_data_matrix <- rpkm_values[cneo_delete_sample_A_list_of_de_genes,]

cneo_delete_sample_compare_A_som <- run_soms_analysis( cneo_delete_sample_A_data_matrix, "cneo", expt_label, 5, 5, results_directory ) 

compare_A_codebook_vector <- cneo_delete_sample_compare_A_som$som$codes


draw_soms_xyplot( cneo_delete_sample_compare_A_som$pivot, "cneo", expt_label, 5, 5, results_directory ) 
dev.off() 


cell_for_each_mic_id_compare_A <- unique(cneo_delete_sample_compare_A_som$pivot[,c("id_a", "id_b", "cell")])


run_soms_enrichment_tests_crypto( channel, cell_for_each_mic_id_compare_A, expt_label_edger, results_directory, universe, go_dictionary, "cneo")

### Mark which gene in which cell is 'up' or 'down' regulated
compare_A_up_or_down <- rep(NA, length( cell_for_each_mic_id_compare_A[,1] ) )
compare_A_up_or_down[which ( cell_for_each_mic_id_compare_A[,1] %in% cneo_delete_sample_A_down_reg ) ] <- "down"
compare_A_up_or_down[which ( cell_for_each_mic_id_compare_A[,1] %in% cneo_delete_sample_A_up_reg ) ] <- "up"

compare_A_soms_de <- data.frame( expt_label_edger, "cneo", cell_for_each_mic_id_compare_A[,c(1,3)], compare_A_up_or_down )

cleanup_som_cells_A <- sqlQuery(channel, paste("delete from som_cells where query_list_id = '", expt_label_edger, "' and organism = 'cneo'", sep=""))

insert_into_sql_table_using_file( channel, compare_A_soms_de, "som_cells", FALSE, results_directory, "soms/som_cells_delete_sample_A_cneo.txt")


################################################################################################

#### Compare AL Experiment
cneo_delete_sample_AL_list_of_de_genes <- unique( c( cneo_delete_sample_AL_down_reg, cneo_delete_sample_AL_up_reg ) )

expt_label <- "delete_sample_AL"
expt_label_edger <- paste( "edgeR_",  expt_label, sep="") 

cneo_delete_sample_AL_data_matrix <- rpkm_values[cneo_delete_sample_AL_list_of_de_genes, ]

cneo_delete_sample_compare_AL_som <- run_soms_analysis( cneo_delete_sample_AL_data_matrix, "cneo", expt_label, 5, 5, results_directory ) 

compare_AL_codebook_vector <- cneo_delete_sample_compare_AL_som$som$codes

draw_soms_xyplot( cneo_delete_sample_compare_AL_som$pivot, "cneo", expt_label, 5, 5, results_directory ) 
dev.off() 

cell_for_each_mic_id_compare_AL <- unique(cneo_delete_sample_compare_AL_som$pivot[,c("id_a", "id_b", "cell")])

run_soms_enrichment_tests_crypto( channel, cell_for_each_mic_id_compare_AL, expt_label_edger, results_directory, universe, go_dictionary, "cneo")

### Mark which gene in which cell is 'up' or 'down' regulated
compare_AL_up_or_down <- rep(NA, length( cell_for_each_mic_id_compare_AL[,1] ) )
compare_AL_up_or_down[which ( cell_for_each_mic_id_compare_AL[,1] %in% cneo_delete_sample_AL_down_reg ) ] <- "down"
compare_AL_up_or_down[which ( cell_for_each_mic_id_compare_AL[,1] %in% cneo_delete_sample_AL_up_reg ) ] <- "up"

compare_AL_soms_de <- data.frame( expt_label_edger, "cneo", cell_for_each_mic_id_compare_AL[,c(1,3)], compare_AL_up_or_down )

cleanup_som_cells_AL <- sqlQuery(channel, paste("delete from som_cells where query_list_id = '", expt_label_edger, "' and organism = 'cneo'", sep=""))

insert_into_sql_table_using_file( channel, compare_AL_soms_de, "som_cells", FALSE, results_directory, "soms/som_cells_delete_sample_AL_cneo.txt")

################################################################################################

### Save the relevant code book vector

save( compare_A_codebook_vector, 
      compare_AL_codebook_vector, 
      file=paste(results_directory,  "soms/edgeR_cneo_delete_sample_codebook_vector.Rdata", sep="") )

################################################################################################        