#########################################################

# Date:                 10-10-13 
# Last updated:         10-10-13 
# Author:               Ignatius Pang
# Version:              v1.01
# Description: 
# * Analysis of C. neoformans and C. gattii 97/170, antagonism between Voriconazole and EDTA

######### Version description ###########################

# v1.05 
#  10-10-13 Igy created the script

#########################################################

### Source location

# cd '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/RNA_seq/EdgeR'

##################  Parameters ####################################################################

library(edgeR)
# library(pcurve)

###################################################################################################

# Perform TMM normalization on the the HTSeq-counts data, and return the results in DGEList format
get_normalized_factors <- function(input_file, column_name, min_count, num_samples_above_cutoff)
{
	### Read in HTSeq-count data
	samples_counts <- read.csv(input_file)
	rownames(samples_counts) <- samples_counts[, column_name]
	samples_counts <- samples_counts[,2:length(samples_counts[1,])]
	samples_dgelist <- DGEList(counts=samples_counts, genes=rownames(samples_counts) )
	
	### Only keep genes that have at least X (min_count) count per million in Y (num_samples_above_cutoff) samples
	genes_to_keep <- rowSums(cpm(samples_dgelist) >= min_count) >= num_samples_above_cutoff
	
	samples_dgelist <- samples_dgelist[genes_to_keep, ]
	
	samples_dgelist <- calcNormFactors(samples_dgelist)
	
	return ( samples_dgelist )
}


# Perform specified normalization on the the HTSeq-counts data, and return the results in DGEList format
get_normalized_factors_specific_normalization <- function(input_file, column_name, min_count, num_samples_above_cutoff, normalization_method="TMM")
{
	### Read in HTSeq-count data
	samples_counts <- read.csv(input_file)
	rownames(samples_counts) <- samples_counts[, column_name]
	samples_counts <- samples_counts[,2:length(samples_counts[1,])]
	samples_dgelist <- DGEList(counts=samples_counts, genes=rownames(samples_counts) )
	
	### Only keep genes that have at least X (min_count) count per million in Y (num_samples_above_cutoff) samples
	genes_to_keep <- rowSums(cpm(samples_dgelist) >= min_count) >= num_samples_above_cutoff
	
	samples_dgelist <- samples_dgelist[genes_to_keep, ]
	
	samples_dgelist <- calcNormFactors(samples_dgelist, method=normalization_method)
	
	return ( samples_dgelist )
}




# Must run the function get_normalized_factors first
# input the normalized DGEList, and the PDF file name
## Print the 1. MDS plot, 2. Spearman correlation heat map, 3. PCA plot
print_diagnostic_plots <- function( samples_dgelist, results_directory, pdf_file_name)
{
	# Diagnostic plots for samples 
	pdf(paste(results_directory, pdf_file_name, sep=""))
	
	### MDS plot
	plotMDS(samples_dgelist)
	
	## heat map
	heatmap ( 1 - cor (samples_dgelist$counts, method="spearman" ),scale="none" )
	
	## PCA plot
	
	### pcurve package which is used to create the PCA plot is now out of date, needs to be updated
	pca.samples <- pca( t(cpm(samples_dgelist)) )
	pcdat.samples <- data.frame( PC1=pca.samples$pcs[,1] , PC2=pca.samples$pcs[,2])
	plot ( pcdat.samples)
	text( x=pca.samples$pcs[,1] , y=pca.samples$pcs[,2], labels=rownames(t(samples_dgelist$counts)), pos=1   ) 
	
	dev.off()
}


###################################################################################################
num_significant_genes_edgeR <-  function( top_tags, fdr_threshold = 0.05) {
	
	if ( "FDR" %in% colnames( top_tags)) {
		
		num_sig_genes <- top_tags %>% 
			dplyr::filter( FDR < fdr_threshold) %>%
			dplyr::select( one_of( c( "genes"))) %>%
			dplyr::distinct()  %>%
			dplyr::count() %>%
			t()%>% 
			as.vector( )
		
		return ( num_sig_genes[1] ) 
		
	} else if ( "adj.P.Val" %in% colnames( top_tags)) {
		
		num_sig_genes <- top_tags %>% 
			dplyr::filter( adj.P.Val < fdr_threshold) %>%
			dplyr::select( one_of( c( "genes"))) %>%
			dplyr::distinct()  %>%
			dplyr::count() %>%
			t()%>% 
			as.vector( )
		
		return ( num_sig_genes[1] ) 
	}
	
}

num_significant_genes <-  function( top_tags, fdr_threshold = 0.05) {
	
	return( num_significant_genes_edgeR( top_tags, fdr_threshold = fdr_threshold) ) 
}



num_significant_genes_up_and_down <-  function( top_tags, fdr_threshold = 0.05) {
	
	
	num_gene_significantly_up <-	dplyr::filter( top_tags, adj.P.Val < fdr_threshold & logFC > 0 ) %>% 
		dplyr::select( one_of( c( "genes"))) %>% dplyr::distinct() %>%
		dplyr::count() %>% as.data.frame() %>% unlist() %>% as.vector() 
	
	num_gene_significantly_down <- dplyr::filter( top_tags, adj.P.Val < fdr_threshold & logFC < 0 ) %>% 
		dplyr::select( one_of( c( "genes"))) %>% dplyr::distinct() %>%
		dplyr::count()%>% as.data.frame() %>% unlist() %>% as.vector() 
	
	return ( list( up=num_gene_significantly_up, down=num_gene_significantly_down) ) 
	
}



num_significant_genes_up_and_down_edgeR <-  function( top_tags, fdr_threshold = 0.05) {
	
	
	num_gene_significantly_up <-	dplyr::filter( top_tags, FDR < fdr_threshold & logFC > 0 ) %>% 
		dplyr::select( one_of( c( "genes"))) %>% dplyr::distinct() %>%
		dplyr::count() %>% as.data.frame() %>% unlist() %>% as.vector() 
	
	num_gene_significantly_down <- dplyr::filter( top_tags, FDR < fdr_threshold & logFC < 0 ) %>% 
		dplyr::select( one_of( c( "genes"))) %>% dplyr::distinct() %>%
		dplyr::count()%>% as.data.frame() %>% unlist() %>% as.vector() 
	
	return ( list( up=num_gene_significantly_up, down=num_gene_significantly_down) ) 
	
}


###################################################################################################

plot_RLE_before_and_after_ruv_version_edgeR <- function ( set_before, set_after, title_for_before_ruv, title_for_after_ruv, expt_group_list, treatment_type_list, results_directory, output_file_name ) {
	
	logCPM_set_before <- cpm(set_before@assayData$normalizedCounts, log=TRUE, prior.count = 2)
	logCPM_set_after <- cpm(set_after@assayData$normalizedCounts, log=TRUE, prior.count = 2)
	
	pData(set_after)
	
	group.colours <- c('slateblue','orange')[as.numeric(as.factor(expt_group_list))];
	
	# RLE plots Before and after RUV
	plotRLE(set_before , outline=FALSE, ylim=c(-0.4, 0.4), col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], 
	        main=title_for_before_ruv, las=3)
	plotRLE(set_after, outline=FALSE, ylim=c(-0.4, 0.4), col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], 
	        main=title_for_after_ruv, las=3)
	
	plotPCA(set_before, col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], cex=1.2, main=title_for_before_ruv)
	plotPCA(set_before, col=c("blue", "green")[as.numeric(as.factor(treatment_type_list))], cex=1.2, main=title_for_before_ruv)
	
	plotPCA(set_after, col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], cex=1.2, main=title_for_after_ruv)
	plotPCA(set_after, col=c("blue", "green")[as.numeric(as.factor(treatment_type_list))], cex=1.2, main=title_for_after_ruv)
	
	plotMDS(logCPM_set_before, col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], cex=1.2, main=title_for_before_ruv)
	plotMDS(logCPM_set_before, col=c("blue", "green")[as.numeric(as.factor(treatment_type_list))], cex=1.2, main=title_for_before_ruv)
	
	plotMDS(logCPM_set_after, col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], cex=1.2, main=title_for_after_ruv)
	plotMDS(logCPM_set_after, col=c("blue", "green")[as.numeric(as.factor(treatment_type_list))], cex=1.2, main=title_for_after_ruv)
	
	
	pdf( file=file.path( results_directory, output_file_name) )
	# RLE plots Before and after RUV
	plotRLE(set_before , outline=FALSE, ylim=c(-0.4, 0.4), col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], 
	        main=title_for_before_ruv, las=3)
	plotRLE(set_after, outline=FALSE, ylim=c(-0.4, 0.4), col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], 
	        main=title_for_after_ruv, las=3)
	
	plotPCA(set_before, col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], cex=1.2, main=title_for_before_ruv)
	plotPCA(set_before, col=c("blue", "green")[as.numeric(as.factor(treatment_type_list))], cex=1.2, main=title_for_before_ruv)
	
	plotPCA(set_after, col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], cex=1.2, main=title_for_after_ruv)
	plotPCA(set_after, col=c("blue", "green")[as.numeric(as.factor(treatment_type_list))], cex=1.2, main=title_for_after_ruv)
	
	plotMDS(logCPM_set_before, col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], cex=1.2, main=title_for_before_ruv)
	plotMDS(logCPM_set_before, col=c("blue", "green")[as.numeric(as.factor(treatment_type_list))], cex=1.2, main=title_for_before_ruv)
	
	plotMDS(logCPM_set_after, col=brewer.pal(6, "Set2")[as.numeric(as.factor(expt_group_list))], cex=1.2, main=title_for_after_ruv)
	plotMDS(logCPM_set_after, col=c("blue", "green")[as.numeric(as.factor(treatment_type_list))], cex=1.2, main=title_for_after_ruv)
	dev.off()
	
}

###################################################################################################

