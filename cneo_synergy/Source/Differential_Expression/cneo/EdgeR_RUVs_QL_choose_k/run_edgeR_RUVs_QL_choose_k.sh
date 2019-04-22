#!/bin/bash


for i in `seq 1 6`;
do
    echo $i
    Rscript --vanilla -e "rmarkdown::render('edgeR_cneo_ruvs_ql_choose_k.Rmd', output_file='edgeR_cneo_ruvs_ql_choose_k.html') "  --args $i TRUE RUVs cneo 
	  Rscript --vanilla -e "rmarkdown::render('edgeR_differential_gene_expression_ruvs_ql_choose_k.Rmd', output_file='edgeR_differential_gene_expression_ruvs_ql_choose_k.html') " --args $i TRUE RUVs cneo 
done   


