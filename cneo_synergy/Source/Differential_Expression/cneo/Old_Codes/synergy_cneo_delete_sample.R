#########################################################

# Script:               synergy_cneo_delete_sample.R
# Date:                 10-10-13 
# Last updated:         09-06-15 
# Author:               Ignatius Pang
# Version:              v1.01
# Description: 
# * Analysis of C. neoformans, synergy between Amphotericin B and Lactoferrin 
## Rerun analysis but remove the sample 5A which could be outlier deleted.

######### Version description ###########################

# v1.01 
#  10-10-13 Igy created the script
#  02-4-14 Igy updated the script so that it handles the possible outlier 

#########################################################

### Source location

# cd '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/RNA_seq/EdgeR/cneo'
# DATE=$(date +"%Y%m%d")
# nohup R --vanilla < synergy_cneo_delete_sample.R > Log/run_synergy_cneo_delete_sample_$DATE.log &


##################  DB connection parameters ####################################################################


source('/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/RNA_seq/EdgeR/edgeR_common_functions.R')
source('/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/Common/GO_terms_enrichment/go_term_enrichment.R')
source('/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/Common/common_functions.R')
source('/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/Complexes/membrane_protein_complexes_queries.R')
library(RODBC)
library(pcurve)


input_db    <- "sbi_fungal_pathogen_2013"  # The name of the SQL database for the data to be imported into
user_id     <- "ignatius"
user_passwd <- "Sp33dBo@t"

conn_string <- paste("SERVER=localhost;DRIVER={PostgreSQL};DATABASE=", input_db,
                     ";PORT=5432;UID=", user_id, ";PWD=", user_passwd ,";LowerCaseIdentifier=0", sep="")

channel <- odbcDriverConnect( conn_string)

set_encoding <- sqlQuery(channel,"SET client_encoding='LATIN1'")

results_directory <- "/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/EdgeR/cneo/"
results_directory_de_list <- paste( results_directory, "de_list/", sep="")


sessionInfo()

### Filter genes with low overall gene expression
min_count <- 1 # threshold cpm for a gene
num_samples_above_cutoff <- 6 # At least this many column above minimum count


##################################################################################################################
### Read in data

### Read in C. neoformans data
cneo_dgelist_del <- get_normalized_factors("/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/HTSeq-count/cneo/all_concatenated_delete_outlier_sample.csv", "orf_id", min_count, num_samples_above_cutoff)


##################################################################################################################

#### Perform data quality checks
print_diagnostic_plots( cneo_dgelist_del, results_directory, "mds_plot_cneo_delete_5A_data_synergy.pdf" )

#print_diagnostic_plots( cneo_dgelist, results_directory, "mds_plot_cneo_synergy.pdf" )

##################################################################################################################

### Load design matrix
cneo_del_design_raw <- read.table("/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/RNA_seq/EdgeR/Design_Matrices/cneo_synergy_remove_outlier_sample.tab", header=TRUE)

# assign groups 
cneo_group_del <- cneo_del_design_raw[,2]

cneo_lane_del <- factor(cneo_del_design_raw[,6]) ## Putting the Illumina lanes in does not help the results


## Perform statistical analyses on the S. cerevisae synergy data

############ Work on the design matrix

correct_batch_effect <- TRUE

# The model design formula
cneo_del_design <- model.matrix(~0+cneo_group_del )

colnames(cneo_del_design) <- c(levels(cneo_group_del)) # , "Lane"

# Contrasts
cneo.contrasts_del <- makeContrasts(  
compare_A   = A - CA,
compare_AL   = AL - CAL,
compare_controls = CA - CAL,
compare_synergy = (AL - CAL) - (A - CA),
#compare_lanes = Lane,
levels=cneo_del_design  )

if ( correct_batch_effect == TRUE)
{
        # The model design formula
        cneo_del_design <- model.matrix(~0 + cneo_group_del + cneo_lane_del)

        colnames(cneo_del_design) <- c(levels(cneo_group_del), "Lane")  

        # Contrasts
        cneo.contrasts_del <- makeContrasts(  
        compare_A   = A - CA,
        compare_AL   = AL - CAL,
        compare_controls = CA - CAL,
	compare_treatment = AL - A, 
        compare_synergy = (AL - CAL) - (A - CA),
        compare_lanes = Lane,
        levels=cneo_del_design  )
}

############ Estimate the dispersion parameters

cneo_dgelist_del <- estimateGLMCommonDisp(cneo_dgelist_del, cneo_del_design, verbose=TRUE)
# Disp = 0.02284 , BCV = 0.1511 

cneo_dgelist_del <- estimateGLMTrendedDisp(cneo_dgelist_del, cneo_del_design)

cneo_dgelist_del <- estimateGLMTagwiseDisp(cneo_dgelist_del, cneo_del_design)

#### Differential Expression

cneo_del_fit <- glmFit( cneo_dgelist_del, cneo_del_design)

#cneo.lrt_compare_del_lanes <- glmLRT(cneo_fit, contrast=cneo.contrasts_del[,"compare_lanes"])
cneo.lrt_compare_del_A <- glmLRT(cneo_del_fit, contrast=cneo.contrasts_del[,"compare_A"])
cneo.lrt_compare_del_AL <- glmLRT(cneo_del_fit, contrast=cneo.contrasts_del[,"compare_AL"])
cneo.lrt_compare_del_treatment <- glmLRT(cneo_del_fit, contrast=cneo.contrasts_del[,"compare_treatment"])
cneo.lrt_compare_del_controls <- glmLRT(cneo_del_fit, contrast=cneo.contrasts_del[,"compare_controls"])
cneo.lrt_compare_del_synergy <- glmLRT(cneo_del_fit, contrast=cneo.contrasts_del[,"compare_synergy"])

#topTags(cneo.lrt_compare_del_A)
#topTags(cneo.lrt_compare_del_AL)
#topTags(cneo.lrt_compare_del_controls)
#topTags(cneo.lrt_compare_del_synergy)

#cneo.de_compare_del_lanes <- decideTestsDGE(cneo.lrt_compare_del_lanes)
#summary(cneo.de_compare_del_lanes)
# No differentially expressed genes, but enough to change the number of DE genes

cneo.de_compare_del_A <- decideTestsDGE(cneo.lrt_compare_del_A)
summary(cneo.de_compare_del_A)
# After correcting for 'Lanes' batch effect and removing possible outlier 
#   [,1]
#-1 1615
#0  3517
#1  1678


cneo.de_compare_del_AL <- decideTestsDGE(cneo.lrt_compare_del_AL)
summary(cneo.de_compare_del_AL)
# After correcting for 'Lanes' batch effect and removing possible outlier 
#    [,1]
# -1 1474
# 0  3658
# 1  1678

cneo.de_compare_del_treatment <- decideTestsDGE(cneo.lrt_compare_del_treatment)
summary(cneo.de_compare_del_treatment)
# After correcting for 'Lanes' batch effect and removing possible outlier 
#    [,1]
# -1    0
# 0  6810
# 1     0


### The controls 
cneo.de_compare_del_controls <- decideTestsDGE(cneo.lrt_compare_del_controls)
summary(cneo.de_compare_del_controls)
# After correcting for 'Lanes' batch effect and removing possible outlier 
#    [,1]
# -1    2
# 0  6788
# 1    20

cneo.de_compare_del_synergy <- decideTestsDGE(cneo.lrt_compare_del_synergy)
summary(cneo.de_compare_del_synergy)
# After correcting for 'Lanes' batch effect and removing possible outlier 
#    [,1]
# -1    0
# 0  6806
# 1     4



################################################################################################

#### Plot the Biological Variation and the log-fold change versus log-counts per million plot

pdf( paste ( results_directory, "cneo_edgeR_diagnostic_plots_delete_5A_data.pdf", sep=""))

#### plot biological variation
plotBCV(cneo_dgelist_del)

### plot log-fold change against log-counts per million, with DE genes highlighted
cneo.detags.compare_del_A <- rownames(cneo_dgelist_del)[as.logical(cneo.de_compare_del_A)]
plotSmear(cneo.lrt_compare_del_A, de.tags=cneo.detags.compare_del_A, main="A - CA")
abline(h=c(-1, 1), col="blue")

cneo.detags.compare_del_AL <- rownames(cneo_dgelist_del)[as.logical(cneo.de_compare_del_AL)]
plotSmear(cneo.lrt_compare_del_AL, de.tags=cneo.detags.compare_del_AL, main="AL - CAL")
abline(h=c(-1, 1), col="blue")

cneo.detags.compare_del_treatment <- rownames(cneo_dgelist_del)[as.logical(cneo.de_compare_del_treatment)]
plotSmear(cneo.lrt_compare_del_treatment, de.tags=cneo.detags.compare_del_treatment, main="AL - A")
abline(h=c(-1, 1), col="blue")

cneo.detags.compare_del_controls <- rownames(cneo_dgelist_del)[as.logical(cneo.de_compare_del_controls)]
plotSmear(cneo.lrt_compare_del_controls, de.tags=cneo.detags.compare_del_controls, main="CA - CAL")
abline(h=c(-1, 1), col="blue")

cneo.detags.compare_del_synergy <- rownames(cneo_dgelist_del)[as.logical(cneo.de_compare_del_synergy)]
plotSmear(cneo.lrt_compare_del_synergy, de.tags=cneo.detags.compare_del_synergy, main="(AL - CAL) - (A - CA)")
abline(h=c(-1, 1), col="blue")

dev.off()


################################################################################################

de_list_A_CA_del <- cbind ( experiment=rep("A - CA" , length(cneo.lrt_compare_del_A$table[,1]) ),
cneo.lrt_compare_del_A$table, 
is_significant=cneo.de_compare_del_A,
orf_id=rownames( cneo.lrt_compare_del_A$table) ) 


write.table(data.frame(de_list_A_CA_del), 
                file=paste(results_directory_de_list, "cneo_de_list_A_CA_del.tab", sep="" ), row.names=FALSE, quote=TRUE, col.names=FALSE )


de_list_AL_CAL_del <- cbind ( experiment=rep("AL - CAL" , length(cneo.lrt_compare_del_AL$table[,1]) ),
cneo.lrt_compare_del_AL$table, 
is_significant=cneo.de_compare_del_AL,
orf_id=rownames( cneo.lrt_compare_del_AL$table))

                
write.table(data.frame(de_list_AL_CAL_del), 
                file=paste(results_directory_de_list, "cneo_de_list_AL_CAL_del.tab", sep="" ), row.names=FALSE, quote=TRUE, col.names=FALSE )
                

################################################################################################
### Getting the differentially expressed gene lists 

# cneo Amphotericin B experiment
cneo_delete_sample_A_down_reg <- rownames(cneo_dgelist_del)[cneo.de_compare_del_A == -1]   # down regulated genes  
cneo_delete_sample_A_no_change <- rownames(cneo_dgelist_del)[cneo.de_compare_del_A == 0] # no change
cneo_delete_sample_A_up_reg <- rownames(cneo_dgelist_del)[cneo.de_compare_del_A == 1]    # up regulated genes  

write.table(data.frame(cneo_delete_sample_A_down_reg=cneo_delete_sample_A_down_reg), file=paste(results_directory_de_list, "cneo_delete_sample_A_down_reg.tab", sep="" ) )
write.table(data.frame(cneo_delete_sample_A_up_reg=cneo_delete_sample_A_up_reg), file=paste(results_directory_de_list,  "cneo_delete_sample_A_up_reg.tab", sep="" ))


# cneo Ampotericin B and lactoferrin experiment 
cneo_delete_sample_AL_down_reg  <- rownames(cneo_dgelist_del)[cneo.de_compare_del_AL == -1]  # down regulated genes  
cneo_delete_sample_AL_no_change <- rownames(cneo_dgelist_del)[cneo.de_compare_del_AL == 0]  # no change  
cneo_delete_sample_AL_up_reg    <- rownames(cneo_dgelist_del)[cneo.de_compare_del_AL == 1]   # up regulated genes  

write.table(data.frame(cneo_delete_sample_AL_down_reg=cneo_delete_sample_AL_down_reg), file=paste(results_directory_de_list,  "cneo_delete_sample_AL_down_reg.tab", sep="" ))
write.table(data.frame(cneo_delete_sample_AL_up_reg=cneo_delete_sample_AL_up_reg), file=paste(results_directory_de_list,  "cneo_delete_sample_AL_up_reg.tab", sep="" ))


# Compare Control CA and Control CAL
cneo_delete_sample_controls_down_reg  <- rownames(cneo_dgelist_del)[cneo.de_compare_del_controls == -1]  # down regulated genes  
cneo_delete_sample_controls_no_change <- rownames(cneo_dgelist_del)[cneo.de_compare_del_controls == 0]  # no change
cneo_delete_sample_controls_up_reg    <- rownames(cneo_dgelist_del)[cneo.de_compare_del_controls == 1]   # up regulated genes  

write.table(data.frame(cneo_delete_sample_controls_down_reg=cneo_delete_sample_controls_down_reg), file=paste(results_directory_de_list,  "cneo_delete_sample_controls_down_reg.tab", sep="" ))
write.table(data.frame(cneo_delete_sample_controls_up_reg=cneo_delete_sample_controls_up_reg), file=paste(results_directory_de_list,  "cneo_delete_sample_controls_up_reg.tab", sep="" ))


# cneo Amphotericin B and lactoferrin compared to Amphotericin B, adjusted by the controls. 
# (AL - CAL) - (A - CA)
#cneo_delete_sample_synergy_down_reg <- rownames(cneo_dgelist_del)[cneo.de_compare_del_synergy == -1]  # down regulated genes
cneo_delete_sample_synergy_no_change <- rownames(cneo_dgelist_del)[cneo.de_compare_del_synergy == 0] # genes with no change
cneo_delete_sample_synergy_up_reg   <- rownames(cneo_dgelist_del)[cneo.de_compare_del_synergy == 1]   # up regulated genes

#write.table(data.frame(cneo_delete_sample_synergy_down_reg=cneo_delete_sample_synergy_down_reg),
#                file=paste(results_directory_de_list,  "cneo_delete_sample_synergy_down_reg.tab", sep="" ), row.names=FALSE, quote=FALSE, col.names=FALSE)
write.table(data.frame(cneo_delete_sample_synergy_up_reg=cneo_delete_sample_synergy_up_reg), 
                file=paste(results_directory_de_list,  "cneo_delete_sample_synergy_up_reg.tab", sep="" ), row.names=FALSE, quote=FALSE, col.names=FALSE)


################################################################################################
##### obtain the length of the genes

gene_length <- sqlQuery ( channel, "select orf_id, abs(start-stop+1)  as gene_length
from genome_annotation_cneo_table
where orf_id is not null
        and start is not null
        and stop is not null;" )

## sort the gene length according to the way cpm table is sorted)

rownames(gene_length) <- as.vector( gene_length[,'orf_id'] )

gene_length <- gene_length[rownames(cpm( cneo_dgelist_del )), c('orf_id','gene_length')]

predFC_rpkm <- cpm(cneo_dgelist_del, log=TRUE)[, c(    "X1C", "X2G", "X2K",
                                            "X3D", "X4A", 
                                            "X5F", "X5L", "X6F",
                                            "X7B", "X8G", "X8H")] - log2(gene_length[,'gene_length'])

grouped_log_rpkm <- predFC(cneo_dgelist_del,cneo_del_design)

de_list_part_1  <- data.frame( experiment="Amphotericine B versus Matched Control 1", model="A - CA", expression="down", orf_id = cneo_delete_sample_A_down_reg, 
                               logFC=grouped_log_rpkm[cneo_delete_sample_A_down_reg,'A'] - grouped_log_rpkm[cneo_delete_sample_A_down_reg,'CA'])
de_list_part_2  <- data.frame( experiment="Amphotericine B versus Matched Control 1", model="A - CA", expression="up", orf_id = cneo_delete_sample_A_up_reg, 
                               logFC=grouped_log_rpkm[cneo_delete_sample_A_up_reg,'A'] - grouped_log_rpkm[cneo_delete_sample_A_up_reg,'CA'])

de_list_part_3  <- data.frame( experiment="Amphotericine B & lactoferrin versus Matched Control 2", model="AL - CAL", expression="down", orf_id = cneo_delete_sample_AL_down_reg, 
                               logFC=grouped_log_rpkm[cneo_delete_sample_AL_down_reg,'AL'] - grouped_log_rpkm[cneo_delete_sample_AL_down_reg,'CAL'])
de_list_part_4  <- data.frame( experiment="Amphotericine B & lactoferrin versus Matched Control 2", model="AL - CAL", expression="up", orf_id = cneo_delete_sample_AL_up_reg, 
                               logFC=grouped_log_rpkm[cneo_delete_sample_AL_up_reg,'AL'] - grouped_log_rpkm[cneo_delete_sample_AL_up_reg,'CAL'])


de_list_part_7  <- data.frame( experiment="Compare the two matched controls", model="CA - CAL", expression="down", orf_id = cneo_delete_sample_controls_down_reg,
                               logFC=grouped_log_rpkm[cneo_delete_sample_controls_down_reg,'CA'] - grouped_log_rpkm[cneo_delete_sample_controls_down_reg,'CAL'])
de_list_part_8  <- data.frame ( experiment="Compare the two matched controls", model="CA - CAL", expression="up", orf_id = cneo_delete_sample_controls_up_reg,
                                logFC=grouped_log_rpkm[cneo_delete_sample_controls_up_reg,'CA'] - grouped_log_rpkm[cneo_delete_sample_controls_up_reg,'CAL'])

#de_list_part_9  <- data.frame( experiment="Normalized effect of adding lactoferrin", model="(AL - CAL) - (A - CA)", expression="down", orf_id = cneo_compare_synergy_down_reg,
#                               logFC=   (grouped_log_rpkm[cneo_delete_sample_synergy_down_reg,'AL'] - grouped_log_rpkm[cneo_delete_sample_synergy_down_reg,'CAL'])
#                                     - (grouped_log_rpkm[cneo_delete_sample_synergy_down_reg,'A'] - grouped_log_rpkm[cneo_delete_sample_synergy_down_reg,'CA'])    )
de_list_part_10 <- data.frame( experiment="Normalized effect of adding lactoferrin", model="(AL - CAL) - (A - CA)", expression="up", 
orf_id = cneo_delete_sample_synergy_up_reg,
logFC=  (grouped_log_rpkm[cneo_delete_sample_synergy_up_reg,'AL'] - grouped_log_rpkm[cneo_delete_sample_synergy_up_reg,'CAL'])
                                     - (grouped_log_rpkm[cneo_delete_sample_synergy_up_reg,'A'] 
                                        - grouped_log_rpkm[cneo_delete_sample_synergy_up_reg,'CA'])   )


#intermediate_down_regulated <- merge( de_list_part_9[, c('orf_id', 'logFC')], de_list_part_7[, c('orf_id', 'logFC')], by.x='orf_id', by.y='orf_id', all.x=TRUE, all.y=FALSE)
intermediate_up_regulated <- merge( de_list_part_10[, c('orf_id', 'logFC')], de_list_part_8[, c('orf_id', 'logFC')], by.x='orf_id', by.y='orf_id', all.x=TRUE, all.y=FALSE)

#to_include_intermediate_down_regulated  <- intermediate_down_regulated[,'logFC.x'] < intermediate_down_regulated[,'logFC.y'] | is.na(intermediate_down_regulated[,'logFC.y'] )
to_include_intermediate_up_regulated  <- intermediate_up_regulated[,'logFC.x'] > intermediate_up_regulated[,'logFC.y'] | is.na(intermediate_up_regulated[,'logFC.y'] )


### Fold-change and DE gene list
all_de_list <- rbind(de_list_part_1 
,de_list_part_2 
,de_list_part_3 
,de_list_part_4 
#,de_list_part_5
#,de_list_part_6
,de_list_part_7
,de_list_part_8
#,de_list_part_9
,de_list_part_10 )

# write.table(all_de_list, file=paste(results_directory_de_list,  "cneo_delete_sample_all_de_genes.tab", sep=""), row.names=FALSE, sep="\t" )


### Save the DE gene list into an SQL table
save_table_into_sql_using_file( channel, all_de_list, "edger_de_genes_cneo_compare_delete_sample_5A", FALSE, results_directory_de_list, "cneo_delete_sample_all_de_genes.tab", 
	    " create table edger_de_genes_cneo_compare_delete_sample_5A (
	    experiment varchar(255)
	    ,model varchar(255)
	    ,expression varchar(64)  CHECK ( expression IN  ( 'up', 'down'))
	    ,orf_id varchar(255)
	    ,logFC numeric
	    );", 
	    with_string=" with  delimiter as E' ' null as ''  csv header ") 		    



### Predicted RPKM values
write.table(predFC_rpkm, file=paste(results_directory_de_list, "cneo_delete_sample_log_rpkm_predFC_all_genes.tab", sep="" ),  sep="\t" ) 


################################################################################################

#### Get average CPM values per sample group (A, AL, CA, CAL)

# https://stat.ethz.ch/pipermail/bioconductor/2013-April/052129.html

# You could get average cpm for each group in several ways.  You could 
# subset the DGEList by group and compute aveLogCPM() on each subset.  Or 
# you could fit a linear model with a coefficient for each group, then the 
# fit$coefficients hold the aveLogCPM for each group.

#### The method with the subsetting works

## CA
aveLogCPM_CA <- aveLogCPM(cneo_dgelist_del$counts[,c("X2K", "X5L", "X8G")], normalized.lib.sizes=TRUE, prior.count=2, dispersion=cneo_dgelist_del$tagwise.dispersion)
     
## A     
aveLogCPM_A <- aveLogCPM(cneo_dgelist_del$counts[,c("X1C", "X4A", "X5F")], normalized.lib.sizes=TRUE, prior.count=2, dispersion=cneo_dgelist_del$tagwise.dispersion)                                       
                                        
## CAL                                        
aveLogCPM_CAL <- aveLogCPM(cneo_dgelist_del$counts[,c("X3D", "X6F", "X7B")], normalized.lib.sizes=TRUE, prior.count=2, dispersion=cneo_dgelist_del$tagwise.dispersion)
                                        
## AL                                        
aveLogCPM_AL <- aveLogCPM(cneo_dgelist_del$counts[,c("X2G", "X8H")], normalized.lib.sizes=TRUE, prior.count=2, dispersion=cneo_dgelist_del$tagwise.dispersion)     

### Combind columns together
aveLogCPM_results <-  cbind( CA=aveLogCPM_CA, A=aveLogCPM_A, CAL=aveLogCPM_CAL, AL=aveLogCPM_AL )

### Assign row names, take care that $gene requires a [,1] subsetting
rownames(aveLogCPM_results) <- cneo_dgelist_del$gene[,1]

### Get the gene length
gene_length <- sqlQuery ( channel, "select orf_id, abs(start-stop+1)  as gene_length
from genome_annotation_cneo_table
where orf_id is not null
        and start is not null
        and stop is not null;" )

## sort the gene length according to the way cpm table is sorted)
rownames(gene_length) <- as.vector( gene_length[,'orf_id'] )

### Need to order the gene name according to the table at hand
gene_length <- gene_length[rownames(aveLogCPM_results), c('orf_id','gene_length')]

aveLogRPKM_results <- aveLogCPM_results - log2(gene_length[,'gene_length'])

### Write the table
write.table(aveLogRPKM_results , file=paste(results_directory_de_list, "cneo_delete_sample_average_log_rpkm_all_genes.tab", sep="" ),  sep="\t" ) 

#####################################################################################################

#### Removing genes that are in the Synergy set, in which the fold change is less extreme than when we compare the two set of controls

#intermediate_down_regulated <- merge( de_list_part_9[, c('orf_id', 'logFC')], de_list_part_7[, c('orf_id', 'logFC')], by.x='orf_id', by.y='orf_id', all.x=TRUE, all.y=FALSE)

#to_include_intermediate_down_regulated  <- intermediate_down_regulated[,'logFC.x'] < 0 & ( intermediate_down_regulated[,'logFC.x'] < intermediate_down_regulated[,'logFC.y'] | is.na(intermediate_down_regulated[,'logFC.y'] ) )

#cneo_delete_sample_synergy_inter_down_reg <-  as.character( intermediate_down_regulated[to_include_intermediate_down_regulated ,'orf_id'] )

intermediate_up_regulated <- merge( de_list_part_10[, c('orf_id', 'logFC')], de_list_part_8[, c('orf_id', 'logFC')], by.x='orf_id', by.y='orf_id', all.x=TRUE, all.y=FALSE)

to_include_intermediate_up_regulated  <- intermediate_up_regulated[,'logFC.x'] > 0 & (intermediate_up_regulated[,'logFC.x'] > intermediate_up_regulated[,'logFC.y'] | is.na(intermediate_up_regulated[,'logFC.y'] ) )

cneo_delete_sample_synergy_inter_up_reg<-  as.character( intermediate_up_regulated[to_include_intermediate_up_regulated ,'orf_id'] )

# Save the objects into an R file for data analysis
save( cneo_delete_sample_A_down_reg, cneo_delete_sample_A_no_change, cneo_delete_sample_A_up_reg, 
      cneo_delete_sample_AL_down_reg, cneo_delete_sample_AL_no_change, cneo_delete_sample_AL_up_reg, 
      #cneo_delete_sample_treatment_down_reg, cneo_delete_sample_treatment_up_reg,
      cneo_delete_sample_controls_down_reg, cneo_delete_sample_controls_no_change, cneo_delete_sample_controls_up_reg,
      #cneo_delete_sample_synergy_down_reg,
      cneo_delete_sample_synergy_no_change,
      cneo_delete_sample_synergy_up_reg,
      #cneo_delete_sample_synergy_inter_down_reg,
      cneo_delete_sample_synergy_inter_up_reg,
      cneo_dgelist_del, 
      cneo.lrt_compare_del_A, 
      cneo.lrt_compare_del_AL,
      cneo.lrt_compare_del_treatment,
      cneo.lrt_compare_del_controls,
      cneo.lrt_compare_del_synergy,    
      cneo.de_compare_del_A,
      cneo.de_compare_del_AL,
      cneo.de_compare_del_treatment,
      cneo.de_compare_del_controls,
      cneo.de_compare_del_synergy,      
      file=paste(results_directory_de_list,  "edgeR_cneo_compare_delete_sample_5A.Rdata", sep="") )

#####################################################################################################


## Save the log2 fold-change and p-values of the results
compare_del_A_fc_p_values  <- topTags( cneo.lrt_compare_del_A, p.value = 0.05, n=8000)
compare_del_AL_fc_p_values <- topTags( cneo.lrt_compare_del_AL, p.value = 0.05, n=8000)

write.table(compare_del_A_fc_p_values,  file=paste(results_directory, "de_list/cneo_delete_sample_compare_A_fc_p_values.tab", sep="" ),   sep="\t", row.names = FALSE, quote=FALSE ) 
write.table(compare_del_AL_fc_p_values, file=paste(results_directory, "de_list/cneo_delete_sample_compare_AL_fc_p_values.tab", sep="" ),  sep="\t", row.names = FALSE, quote=FALSE ) 
   
#####################################################################################################   


#####################################################################################################

