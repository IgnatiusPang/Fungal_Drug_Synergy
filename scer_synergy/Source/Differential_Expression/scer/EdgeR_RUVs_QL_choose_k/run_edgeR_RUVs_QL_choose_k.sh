#!/bin/bash


for i in `seq 0 0`;
do
    echo $i
    Rscript --vanilla -e "rmarkdown::render('edgeR_scer_ruvs_ql_choose_k.Rmd', output_file='edgeR_scer_ruvs_ql_choose_k.html') "  --args $i TRUE RUVs scer 
	  Rscript --vanilla -e "rmarkdown::render('edgeR_differential_gene_expression_ruvs_ql_choose_k.Rmd', output_file='edgeR_differential_gene_expression_ruvs_ql_choose_k.html') " --args $i TRUE RUVs scer 
done   


