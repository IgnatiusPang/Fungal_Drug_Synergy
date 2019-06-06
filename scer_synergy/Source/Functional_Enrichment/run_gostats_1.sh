
RESULTS_DIR=/home/ignatius/PostDoc/2019/scer_synergy/Results
DE_GENES_DIR=$RESULTS_DIR/Differential_Expression/EdgeR_RUVs_QL/scer

rsync -artuvz $DE_GENES_DIR/All_Samples/k_1/* $DE_GENES_DIR/To_Use_k_1

Rscript --vanilla -e "rmarkdown::render('Common/go_enrichment.Rmd', output_file='go_enrichment.html') " --args scer_edger_ruvs_ql_chosen_dir To_Use_k_1

# rsync -artuvz $DE_GENES_DIR/All_Samples/k_0/* $DE_GENES_DIR/To_Use_k_0
# 
# Rscript --vanilla -e "rmarkdown::render('Common/go_enrichment.Rmd', output_file='go_enrichment.html') " --args scer_edger_ruvs_ql_chosen_dir To_Use_k_0

 
 
 

 
 
 
 
 
 
