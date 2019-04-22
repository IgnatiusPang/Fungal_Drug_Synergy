
--  Compare differences between old Blast2Go and new Blast2Go annotations
-- 
-- /media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/C_neoformans_blastp_vs_nr/Blast2Go/Output_Annotations/annot_Seqs_20150203_1231.txt 
-- 
-- /media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/Blast2Go/20131110/annot_Seqs_20140402_1115.txt
-- 


/*
zzz_blast2go_cneo_go_annotation_old

  orf_id        varchar(256) 
, Hit_Desc      text
, GO_Group      varchar(64)  
, GO_ID         text
, Term          text
*/

--- In Old file but not in new file Zero 
--- 2911 rows
select distinct orf_id, GO_ID, Term from zzz_blast2go_cneo_go_annotation_old 
except 
select distinct orf_id, GO_ID, Term from blast2go_cneo_go_annotation ;


--- In New file but not in Old file
--- 5335 rows
select distinct orf_id, GO_ID, Term from blast2go_cneo_go_annotation
except
select distinct orf_id, GO_ID, Term from zzz_blast2go_cneo_go_annotation_old ;


----------------------------------------------------------------------------------------------------------

--        Table "public.go_cneo_gene_ontology"
--     Column    |          Type          | Modifiers 
-- --------------+------------------------+-----------
--  uniprot_acc  | character varying(25)  | 
--  go_id        | text                   | 
--  go_id_number | integer                | 
--  go_type      | character varying(3)   | 
--  go_term      | text                   | 
--  evidence     | character varying(255) | 
-- 
--  public | id_cneo_gene_name                                             | table | ignatius
--  public | id_cneo_uniprot_acc                                           | table | ignatius
--  
 
--- GO terms annotation from uniprot
select distinct uniprot.orf_id, 'GO:' || go.go_id as go_id, go.go_term
from go_cneo_gene_ontology  go
        left outer join id_cneo_uniprot_acc  uniprot
                on uniprot.uniprot_acc = go.uniprot_acc ;

-- GO terms annotation in Uniprot but not in Blast2Go                
-- (419 rows)
select distinct uniprot.orf_id, 'GO:' || go.go_id as go_id, go.go_term
from go_cneo_gene_ontology  go
        left outer join id_cneo_uniprot_acc  uniprot
                on uniprot.uniprot_acc = go.uniprot_acc 
except                
select distinct orf_id, GO_ID, Term from blast2go_cneo_go_annotation;



-- GO terms annotation in Blast2Go but not in Uniprot
-- 4810 rows
select distinct orf_id, GO_ID, Term from blast2go_cneo_go_annotation

except
 
select distinct uniprot.orf_id, 'GO:' || go.go_id, go.go_term
from go_cneo_gene_ontology  go
        left outer join id_cneo_uniprot_acc  uniprot
                on uniprot.uniprot_acc = go.uniprot_acc ;

----------------------------------------------------------------------------------------------------------

select distinct orf_id, GO_ID, Term 
from blast2go_cneo_go_annotation
where orf_id in ('CNAG_06242' 
,'CNAG_02959' 
,'CNAG_03694' );

----------------------------------------------------------------------------------------------------------

select * 
from (

select distinct uniprot.orf_id, 'GO:' || go.go_id as go_id, go.go_term
from go_cneo_gene_ontology  go
        left outer join id_cneo_uniprot_acc  uniprot
                on uniprot.uniprot_acc = go.uniprot_acc 
except                
select distinct orf_id, GO_ID, Term from blast2go_cneo_go_annotation
) temp 
where go_term ~* 'iron ion';


----------------------------------------------------------------------------------------------------------

select distinct orf_id, GO_ID, Term 
from blast2go_cneo_go_annotation_union_uniprot
where Term ~* 'iron ion';

-- blast2go_cneo_go_annotation_union_uniprot


----------------------------------------------------------------------------------------------------------

















