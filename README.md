# Fungal_Drug_Synergy
Different pathways mediate amphotericin-lactoferrin drug synergy in Cryptococcus and Saccharomyces

## Figures 

### Figure 1.

#### 1a. 
List of selected GO terms: [compare_cneo_scer/Data/Selected_GO_Terms/list_of_selected_GO_terms.txt](compare_cneo_scer/Data/Selected_GO_Terms/list_of_selected_GO_terms.txt)
Plotting Script: [compare_cneo_scer/Source/Compare_Global_Enrichment/compare_go_terms.Rmd](compare_cneo_scer/Source/Compare_Global_Enrichment/compare_go_terms.Rmd)

#### 1b. 
Plotting Script: [compare_cneo_scer/Source/Compare_Orthologs/compare_orthologs.Rmd](compare_cneo_scer/Source/Compare_Orthologs/compare_orthologs.Rmd)


### Figure 2.

#### 2a.

Plotting Script: [cneo_synergy/Source/Compare_Fold_Change/compare_A_AL_fold_change.Rmd](cneo_synergy/Source/Compare_Fold_Change/compare_A_AL_fold_change.Rmd)

#### 2b.

Analyse specific gene sets: [cneo_synergy/Source/Functional_Enrichment/go_enrichment_specific_set.Rmd](cneo_synergy/Source/Functional_Enrichment/go_enrichment_specific_set.Rmd)
Plotting Script: [cneo_synergy/Source/Compare_Fold_Change/plot_selected_GO_terms.Rmd](cneo_synergy/Source/Compare_Fold_Change/plot_selected_GO_terms.Rmd)


### Figure 3.

### 3a and b. 
Script for generating Self-Organising Maps and Gene Ontology Enrichment Analysis of each cluster: [cneo_synergy/Source/Self_Organising_Maps/EdgeR_RUVs_QL_choose_k/soms_analysis_EdgeR_RUVs_QL_choose_k.Rmd](cneo_synergy/Source/Self_Organising_Maps/EdgeR_RUVs_QL_choose_k/soms_analysis_EdgeR_RUVs_QL_choose_k.Rmd)

Plotting Script: [cneo_synergy/Source/Self_Organising_Maps/EdgeR_RUVs_QL_choose_k/draw_soms_using_ggplot.Rmd](cneo_synergy/Source/Self_Organising_Maps/EdgeR_RUVs_QL_choose_k/draw_soms_using_ggplot.Rmd)


## Supplementary Information 

*C. neoformans* and *S. cerevisiae* orthologs information are located in this [link](cneo_synergy/Data/Curated_Data/scer_cneo_orthologs.tab). Those in reliability class 1 were identified using BlastP reciprocal top-hits and are one-to-one orthologs. Those in reliability class 2 were orthologs from OrthoMCL, these are not necessarily one-to-one orthologs but could be. 



