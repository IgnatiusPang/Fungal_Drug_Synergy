
---------------------------------------------------------------------------------- 

-- Script Name:        compile_go_terms.sql
-- Author:             Ignatius Pang
-- Version:            v1.01 
-- Date created dd-mm-yyyy:       6-5-2015
-- Date last updated :            6-5-2015

-- Description: Compile GO terms from different sources for C. neoformans
-- -- README: see https://bitbucket.org/IgnatiusPang/fungal_shared/wiki/C_neo_GO_terms_annotation


------------------- Version History ---------------------------------------------- 

-- v1.01
-- 6-5-2015 created script
--  

----------------------- Workspace -------------------------------------------------

-- cd '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/BLAST/GO_terms/cneo/'
----------------------------------------------------------------------------------


---- Merge the GO terms for Uniprot and Blast2Go together
drop view blast2go_cneo_go_annotation_union_uniprot;
create view blast2go_cneo_go_annotation_union_uniprot as 
select * 
from 
(
(
select distinct uniprot.orf_id, 'GO:' || go.go_id as go_id, go.go_term as term, go_type as go_group, 'Uniprot & Blast2go' as source
from go_cneo_gene_ontology  go 
        left outer join id_cneo_uniprot_acc  uniprot
                on uniprot.uniprot_acc = go.uniprot_acc 
intersect                 
select distinct orf_id, GO_ID, Term, go_group, 'Uniprot & Blast2go'  as source
from blast2go_cneo_go_annotation
) 

union 

(
select distinct orf_id, GO_ID, Term, go_group, 'Blast2Go only' as source
from blast2go_cneo_go_annotation

except
 
select distinct uniprot.orf_id, 'GO:' || go.go_id as go_id, go.go_term as term, go_type as go_group, 'Blast2Go only' as source
from go_cneo_gene_ontology  go
        left outer join id_cneo_uniprot_acc  uniprot
                on uniprot.uniprot_acc = go.uniprot_acc 
)                

union 
(
select distinct uniprot.orf_id, 'GO:' || go.go_id as go_id, go.go_term as term, go_type as go_group, 'Uniprot only' as source
from go_cneo_gene_ontology  go
        left outer join id_cneo_uniprot_acc  uniprot
                on uniprot.uniprot_acc = go.uniprot_acc 
except
select distinct orf_id, GO_ID, Term, go_group, 'Uniprot only' as source
from blast2go_cneo_go_annotation
) ) temp 
order by orf_id;


\o '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/GO_terms_annotation_Uniprot_and_Blast2Go.txt'
\a
\f '\t'
\pset footer off
select * from blast2go_cneo_go_annotation_union_uniprot;
\pset footer on
\a
\f '|'
\o



----------------------------------------------------------------------------------------------------------

---- Merge the GO terms for Uniprot and Blast2Go and OrthoMCL/1 to 1 reciprocal matches together


drop table blast2go_cneo_go_annotation_union_uniprot_union_orthomcl cascade;
create table blast2go_cneo_go_annotation_union_uniprot_union_orthomcl as 

--- Add OrthoMCL
select orf_id, go_id, term, go_group, 'orthomcl' as source
from ( 

select distinct orf_id, go_id, term, go_group
from go_cneo_orthomcl_reciprocal_mapping

except

select distinct orf_id, go_id, term, go_group
from blast2go_cneo_go_annotation_union_uniprot

except 

select distinct  acc.orf_id, go_id, term, go_group
from quickgo_cneo_go_terms  quickgo
        left outer join id_cneo_uniprot_acc  acc
                on quickgo.uniprot_acc = acc.uniprot_acc                 
--- the ones where the orf_id is null are unreliable, therefore ignored                
where acc.orf_id is not null    

) temp 


union 

----- QuickGO
select distinct orf_id, go_id, term, go_group, 'QuickGO' as source
from 
(
select distinct  acc.orf_id, go_id, term, go_group
from quickgo_cneo_go_terms  quickgo
        left outer join id_cneo_uniprot_acc  acc
                on quickgo.uniprot_acc = acc.uniprot_acc 
                
--- the ones where the orf_id is null are unreliable, therefore ignored                
where acc.orf_id is not null    

except

select distinct orf_id, go_id, term, go_group
from blast2go_cneo_go_annotation_union_uniprot
) temp2

union 

--- Add uniprot
select distinct orf_id, go_id, term, go_group, source
from blast2go_cneo_go_annotation_union_uniprot

;


---- Delete GO terms that are potentially not of Fungal Origin
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

                         
--- These are GO terms that are likely to be obsolete, delete these (14th May 2015)
delete from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl
where not exists ( select * from go_distance_to_root 
        where blast2go_cneo_go_annotation_union_uniprot_union_orthomcl.go_id = go_distance_to_root.go_id);



\o '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/GO_terms_annotation_Uniprot_and_Blast2Go_and_manual.txt'
\a
\f '\t'
\pset footer off
select * 
from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl
order by orf_id, go_group, source
;
\pset footer on
\a
\f '|'
\o



--- I want to merge the fully compiled list of GO terms with the distance of each GO term to the root term

drop view blast2go_cneo_go_compiled_annotation_distances;
create view blast2go_cneo_go_compiled_annotation_distances as
select 
annotation.orf_id  
,annotation.go_id   
,annotation.term    
,annotation.go_group
,annotation.source  
,distances.breath_first_distance
,distances.depth_first_distance
from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl  annotation
        left outer join go_distance_to_root   distances
                on annotation.go_id = distances.go_id                
order by orf_id
, go_group
, distances.breath_first_distance desc ;

comment on view blast2go_cneo_go_compiled_annotation_distances is 'I want to merge the fully compiled list of GO terms with the distance of each GO term to the root term';


\o '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/GO_graph_analysis/GO_terms_annotation_check_distances.txt'
\a
\f '\t'
\pset footer off
select 
 orf_id  
,go_id   
,term    
,go_group
,source  
,breath_first_distance
,depth_first_distance
from blast2go_cneo_go_compiled_annotation_distances            
order by orf_id, go_group, breath_first_distance desc ;
\pset footer on
\a
\f '|'
\o

----------------------------------------------------------------------------------------------------------

--- All GO terms from all sources, without compilation

drop view go_cneo_all_go_terms_for_comparisons cascade;
create view go_cneo_all_go_terms_for_comparisons as
select * from ( 
select distinct uniprot.orf_id, 'GO:' || go.go_id as go_id, go.go_term as term, go_type as go_group, 'Uniprot' as source
from go_cneo_gene_ontology  go 
        left outer join id_cneo_uniprot_acc  uniprot
                on uniprot.uniprot_acc = go.uniprot_acc 


union 

select distinct orf_id, GO_ID, Term, go_group, 'Blast2go'  as source
from blast2go_cneo_go_annotation


union 

select distinct orf_id, go_id, term, go_group, 'OrthoMCL' as source
from go_cneo_orthomcl_reciprocal_mapping


union 

select distinct  acc.orf_id, go_id, term, go_group, 'QuickGO' as source
from quickgo_cneo_go_terms  quickgo
        left outer join id_cneo_uniprot_acc  acc
                on quickgo.uniprot_acc = acc.uniprot_acc                 
--- the ones where the orf_id is null are unreliable, therefore ignored                
where acc.orf_id is not null


union 

select orf_id, go_id, term, go_group, 'Compiled' as source
from blast2go_cneo_go_annotation_union_uniprot_union_orthomcl
order by orf_id, go_group, source ) temp

--- Delete entries where the GO terms are likely to be obsolete
where  not exists ( select * from go_distance_to_root 
                    where temp.go_id = go_distance_to_root.go_id)
;


comment on view go_cneo_all_go_terms_for_comparisons is 'All go terms from each sources, without compilation';


--- Get the compiled GO terms and the distance of each term to the root node.
drop view go_cneo_all_go_terms_for_comparisons_distances;
create view go_cneo_all_go_terms_for_comparisons_distances as
select 
annotation.orf_id  
,annotation.go_id   
,annotation.term    
,annotation.go_group
,annotation.source  
,distances.breath_first_distance
,distances.depth_first_distance
from go_cneo_all_go_terms_for_comparisons  annotation
        left outer join go_distance_to_root   distances
                on annotation.go_id = distances.go_id                
order by orf_id, go_group, distances.breath_first_distance  desc ;


comment on view go_cneo_all_go_terms_for_comparisons_distances is 'Get the compiled GO terms and the distance of each term to the root node.';

\o '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/GO_graph_analysis/GO_terms_annotation_check_distances_all_sourcess.txt'
\a
\f '\t'
\pset footer off
select 
 orf_id  
, go_id   
, term    
, go_group
, source  
,breath_first_distance
,depth_first_distance
from go_cneo_all_go_terms_for_comparisons_distances;
\pset footer on
\a
\f '|'
\o


----------------------------------------------------------------------------------------------------------


