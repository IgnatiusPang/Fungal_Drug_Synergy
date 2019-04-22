RESULTS_DIR=/home/ignatius/PostDoc/2019/cneo_synergy/Results
DE_GENES_DIR=$RESULTS_DIR/Differential_Expression/EdgeR_RUVs_QL/cneo

# rsync -artuvz $DE_GENES_DIR/Remove_5a/k_5/* $DE_GENES_DIR/To_Use_k_5_Remove_5a
# 
# Rscript --vanilla -e "rmarkdown::render('Common/go_enrichment_camera.Rmd', output_file='go_enrichment_camera.html') " --args cneo_edger_ruvs_ql_chosen_dir To_Use_k_5_Remove_5a

rsync -artuvz $DE_GENES_DIR/Remove_5a/k_0/* $DE_GENES_DIR/To_Use_k_0_Remove_5a

Rscript --vanilla -e "rmarkdown::render('Common/go_enrichment_camera.Rmd', output_file='go_enrichment_camera.html') " --args cneo_edger_ruvs_ql_chosen_dir To_Use_k_0_Remove_5a
