
---------------------------------------------------------------------------------- 

-- Script Name:        compile_go_terms_qa_checks.sql
-- Author:             Ignatius Pang
-- Version:            v1.01 
-- Date created dd-mm-yyyy:       7-5-2015
-- Date last updated :            7-5-2015

-- Description: Compile GO terms from different sources for C. neoformans, then do the quality assurance checks
-- -- README: see https://bitbucket.org/IgnatiusPang/fungal_shared/wiki/C_neo_GO_terms_annotation


------------------- Version History ---------------------------------------------- 

-- v1.01
-- 7-5-2015 created script
--  

----------------------- Workspace -------------------------------------------------

-- cd '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/BLAST/GO_terms/cneo/'
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------


--- We have make sure that there are no genes in the GO annotation that is not in the 'universe' of C. neoformans genes
select distinct orf_id from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl
except
select distinct orf_id from genome_annotation_cneo_table;


----------------------------------------------------------------------------------------------------------

--- Find the orf_id for each entry in QuickGO
select distinct  acc.orf_id, go_id, term, go_group
from quickgo_cneo_go_terms  quickgo
        left outer join id_cneo_uniprot_acc  acc
                on quickgo.uniprot_acc = acc.uniprot_acc 
                
--- the ones where the orf_id is null are unreliable, therefore ignored                
where acc.orf_id is not null    ;
                

----------------------------------------------------------------------------------------------------------


-- nohup R --vanilla < synergy_cneo_q_delete_sample.R > Log/run_synergy_cneo_q_delete_sample_20150508.log & 

----------------------------------------------------------------------------------------------------------

--- Check how many genes do we add by adding mushrooms 
--- we added annotations for 296 genes
--- 186 genes if we only look at GO biological processes


select distinct orf_id
from go_cneo_orthomcl_reciprocal_mapping 
where sce is null 
        and spo is null 
        and asf is null
        and agb is not null
        and go_group = 'P'

except

select distinct orf_id 
from go_cneo_orthomcl_reciprocal_mapping 
where not ( sce is null 
        and spo is null 
        and asf is null )
        and agb is  null
        and go_group = 'P';
        

----------------------------------------------------------------------------------------------------------
        
        
--- OrthoMCL added annotation for  677 genes
--- 798 if looking at biological processes only
select distinct orf_id
from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl
where source = 'orthomcl'
        and go_group = 'P'

except

select distinct orf_id 
from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl
where source != 'orthomcl'
        and go_group = 'P';

----------------------------------------------------------------------------------------------------------


---- Blast2Go picked up some Human GO terms!
select * 
from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl
where orf_id in ( 'CNAG_01648', 'CNAG_07807');


----------------------------------------------------------------------------------------------------------

select source, count(*)
from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl
group by source;

--        source       | count 
-- --------------------+-------
--  Uniprot only       |   419
--  Uniprot & Blast2go |  9247
--  Blast2Go only      |  4810
--  QuickGO            |  5712
--  orthomcl           | 36968
-- (5 rows)


delete from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl
where source = 'Blast2Go only'
      and   go_id not in ( select 'GO:' || go_id as go_id
                                from go_scer_gene_ontology )                                
      and go_id not in ( select go_id
                        from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl
                        where source in ( 'QuickGO', 'orthomcl', 'Uniprot only', 'Uniprot & Blast2go' ) 
      )
      and go_id not in (select go_id 
                         from go_sgd_scer_go_terms )  ;


-- go_cneo_gene_ontology
-- go_scer_gene_ontology
-- sgd_scer_goslim

----------------------------------------------------------------------------------------------------------

--- Compare CryptoNet annotation versus compiled annotations (from 1 to 1 orthologous relationships)

drop table blast2go_versus_cryptonet_cneo;
create table blast2go_versus_cryptonet_cneo as 
select high_quality_annot.orf_id  
, high_quality_annot.go_id   
, high_quality_annot.term    
, high_quality_annot.go_group
, high_quality_annot.source  
, high_quality_annot.breath_first_distance
, high_quality_annot.depth_first_distance
, inferred.rank
, inferred.oddsratio
, inferred.bh as bh

from  blast2go_cneo_go_compiled_annotation_distances high_quality_annot
        left outer join cryptonet_cneo_infer_function_from_neighbiours inferred
                on high_quality_annot.orf_id    = inferred.gene_name
                        and high_quality_annot.go_id = inferred.go_id  
where rank is not null   
order by high_quality_annot.orf_id
, inferred.rank;



     
\o '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/blast2go_versus_cryptonet_cneo.txt'
\a
\f '\t'
\pset footer off
select * from blast2go_versus_cryptonet_cneo;
\pset footer on
\a
\f '|'
\o


alter table cryptonet_cneo_infer_function_from_neighbiours add column breath_first_distance integer;
alter table cryptonet_cneo_infer_function_from_neighbiours add column depth_first_distance integer;


update cryptonet_cneo_infer_function_from_neighbiours annotation set breath_first_distance = distances.breath_first_distance
from   go_distance_to_root   distances
where annotation.go_id = distances.go_id;

update cryptonet_cneo_infer_function_from_neighbiours annotation set depth_first_distance = distances.depth_first_distance
from   go_distance_to_root   distances
where annotation.go_id = distances.go_id;

----------------------------------------------------------------------------------------------------------         
                   
                  
--- Investigate terms that are incorrect
select * 
from blast2go_versus_cryptonet_cneo
where orf_id in ( 
        -- ORFs that do not have a correct prediction
        -- 3941 ORFs without prediction of any kind
        select distinct orf_id 
        from blast2go_cneo_go_compiled_annotation_distances
        except
        -- 1098 ORFs with prediction
        select distinct orf_id
        from blast2go_versus_cryptonet_cneo
);


----------------------------------------------------------------------------------------------------------
--  56733 of terms predicted for 5039 proteins 
select count(*)
from ( select distinct orf_id, go_id 
        from  blast2go_cneo_go_compiled_annotation_distances
) temp ;


select count(*)
from ( select distinct orf_id
        from  blast2go_cneo_go_compiled_annotation_distances
) temp ;
                    
                   
----------------------------------------------------------------------------------------------------------

--- A
select count(*) 
from ( 
        select distinct orf_id, go_id 
        from blast2go_versus_cryptonet_cneo
        where rank <=10
                and bh < 0.01 ) temp;

--- B
select count(*) 
from ( 
        select distinct orf_id, go_id 
        from blast2go_versus_cryptonet_cneo
        where rank > 10
        and bh < 0.01 ) temp;


--- C
select count(*) 
from ( 
        select distinct gene_name as orf_id , go_id 
        from cryptonet_cneo_infer_function_from_neighbiours
        where rank <= 10
                and bh < 0.01

        except 

        select distinct orf_id, go_id 
        from blast2go_versus_cryptonet_cneo
        where bh < 0.01 ) temp;


--- D
select count(*) 
from ( 
        select distinct gene_name as orf_id , go_id 
        from cryptonet_cneo_infer_function_from_neighbiours
        where rank > 10
                and bh < 0.01
        except 

        select distinct orf_id, go_id 
        from blast2go_versus_cryptonet_cneo
        where bh < 0.01 ) temp;


-------- Condition on child term = FALSE        
--- bh < 0.01
--  fisher.test( matrix ( c(A, B, C, D), 2, 2, byRow=TRUE) )
-- fisher.test( matrix ( c(1494, 1417, 17341, 73748), 2, 2, byRow=TRUE) )

-- bh < 0.001
--  fisher.test ( matrix( c(1295, 820, 10055, 24908), 2, 2, byrow=TRUE)  )

-------- Condition on child term = TRUE

--- bh < 0.01
-- fisher.test ( matrix( c(3519, 4757, 34393, 193024), 2, 2, byrow=TRUE)  )


--- Only look at GO terms annotation that is sufficiently deep enough?


----------------------------------------------------------------------------------------------------------


select * 
from cryptonet_cneo_infer_function_from_neighbiours inferred
where exists ( 
        select * 
        from ( 
                select distinct gene_name as orf_id , go_id 
                from cryptonet_cneo_infer_function_from_neighbiours
                where rank <= 10
                        and bh < 0.001

                except 

                select distinct orf_id, go_id 
                from blast2go_versus_cryptonet_cneo
                where bh < 0.001 ) temp
        where inferred.gene_name = temp.orf_id
                and inferred.go_id = temp.go_id

        );

----------------------------------------------------------------------------------------------------------

--- 5039 orf_id with GO terms
select count(*)                                  
from (
 select distinct orf_id 
 from  blast2go_cneo_go_compiled_annotation_distances ) temp; 



select go_group, count(*) 
from (
 select distinct orf_id,  go_group
 from  blast2go_cneo_go_compiled_annotation_distances ) temp
group by go_group; 



--  go_group | count 
-- ----------+-------
--  F        |  4394
--  C        |  3842
--  P        |  4610
-- (3 rows)
-- 


----------------------------------------------------------------------------------------------------------

--- Why is more annotation for C. neoformans important?
--- We want to use number to shows the importance.
--- 

--- how many genes are there (nuclear and mitochondria)?
--- 6975
select distinct orf_id
from genome_annotation_cneo_table;


--- How many hypothetical proteins do we have gene ontology terms for?

--- List of uncharacterized proteins in the C. neoformans genome
--- 3152 orf_ids        
create temporary table cneo_uncharacterized_genes as
select distinct genome.orf_id 
from genome_annotation_cneo_table               genome
        left outer join id_cneo_gene_name       uniprot  
                on  genome.orf_id = uniprot.orf_id 
where lower(genome.name) ~ 'hypothetical' 
        and (  lower(uniprot.description) ~'uncharacterized' 
                or uniprot.description is null ) ;
          
--  Uncharacterized proteins with GO terms          
--  934 orf_id for P only
--  1317 for all GO terms (P, M, C)
--  1360 including all terms, even with depth of 1
create temporary table cneo_uncharacterized_genes_with_go_terms as 
select orf_id, max(depth_first_distance)
from blast2go_cneo_go_compiled_annotation_distances          
where orf_id in (
        select distinct genome.orf_id 
        from genome_annotation_cneo_table               genome
                left outer join id_cneo_gene_name       uniprot  
                        on  genome.orf_id = uniprot.orf_id 
        where lower(genome.name) ~ 'hypothetical' 
                and (  lower(uniprot.description) ~'uncharacterized' 
                        or uniprot.description is null ) )
       -- and go_group = 'P'
group by orf_id ;
--having max(depth_first_distance) > 1;


-- select 3152-1360
-- 1792 genes, uncharacterized and without GO terms.

--- Genes that are characterized    
-- 3824 orf_ids
create temporary table cneo_characterized_genes as 
select distinct genome.orf_id  -- , genome.name, uniprot.description  
from genome_annotation_cneo_table               genome
        left outer join id_cneo_gene_name       uniprot  
                on  genome.orf_id = uniprot.orf_id 
where lower(genome.name) !~ 'hypothetical' 
        or (  lower(uniprot.description) !~'uncharacterized' 
                and uniprot.description is not null ) ;
                                


--- How many DE genes do we NOT have annotation for ? 
--- 919 orf_id

--- List of all differentially expressed genes 
select distinct orf_id from cneo_edger_synergy_pivot_table_delete_sample_5A

intersect 

--- Uncharacterized genes without GO terms
(
select distinct orf_id from cneo_uncharacterized_genes

except 
select distinct orf_id from cneo_uncharacterized_genes_with_go_terms );



---- Number of previously uncharacterized protein which we have now added annotation for 

select status, count(*) 
from (
select distinct orf_id
  , case when description_semi_curated = 'Uncharacterized protein' then 'Uncharacterized'
        else 'Characterized' end as status
from id_cneo_merged_gene_descriptions
where broad_description ~ 'hypothetical protein' 
            and fungidb_description ~ 'hypothetical protein' 
            and uniprot_description ~ 'Uncharacterized' ) temp
group by status;


select orf_id, description_semi_curated from id_cneo_merged_gene_descriptions;


select * 
from id_cneo_merged_gene_descriptions
where is_new_annotation = TRUE;


----------------------------------------------------------------------------------------------------------









