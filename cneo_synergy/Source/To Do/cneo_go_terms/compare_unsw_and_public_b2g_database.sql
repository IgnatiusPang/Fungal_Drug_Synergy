
select distinct coalesce( public_db.orf_id, unsw_db.orf_id) as orf_id
        , substr( coalesce( public_db.Hit_Desc, unsw_db.Hit_Desc), 1, 40) as Hit_Desc
        , public_db.go_id
        , public_db.go_group
        , substr(public_db.term, 1, 40)
        , unsw_db.go_id
        , unsw_db.go_group
        , substr(unsw_db.term, 1, 40)
from blast2go_cneo_go_annotation   public_db
        full outer join zzz_blast2go_cneo_go_annotation_old unsw_db
                
                        on  public_db.orf_id = unsw_db.orf_id
                            and public_db.GO_Group = unsw_db.GO_Group
                            and public_db.GO_ID = unsw_db.GO_ID
where   public_db.orf_id is null or    unsw_db.orf_id is null                        
order by coalesce( public_db.orf_id, unsw_db.orf_id)  
         , public_db.go_group
         , public_db.go_id;
                            
                            
                            

-- not in public, 2894 rows
select coalesce( public_db.orf_id, unsw_db.orf_id) as orf_id
        , substr( coalesce( public_db.Hit_Desc, unsw_db.Hit_Desc), 1, 40) as Hit_Desc
        , public_db.go_id
        , public_db.go_group
        , substr(public_db.term, 1, 40)
        , unsw_db.go_id
        , unsw_db.go_group
        , substr(unsw_db.term, 1, 40)
from blast2go_cneo_go_annotation   public_db
        full outer join zzz_blast2go_cneo_go_annotation_old unsw_db
                
                        on  public_db.orf_id = unsw_db.orf_id
                            and public_db.GO_Group = unsw_db.GO_Group
                            and public_db.GO_ID = unsw_db.GO_ID
where   public_db.orf_id is null      ;
                            
                            
-- not in unsw, 1392 rows
select coalesce( public_db.orf_id, unsw_db.orf_id) as orf_id
        , substr( coalesce( public_db.Hit_Desc, unsw_db.Hit_Desc), 1, 40) as Hit_Desc
        , public_db.go_id
        , public_db.go_group
        , substr(public_db.term, 1, 40)
        , unsw_db.go_id
        , unsw_db.go_group
        , substr(unsw_db.term, 1, 40)
from blast2go_cneo_go_annotation   public_db
        full outer join zzz_blast2go_cneo_go_annotation_old unsw_db
                
                        on  public_db.orf_id = unsw_db.orf_id
                            and public_db.GO_Group = unsw_db.GO_Group
                            and public_db.GO_ID = unsw_db.GO_ID
where   unsw_db.orf_id is null      ;
                            
                            
----------------------------------------------------------------------------------------------------------
--- Union 
---663 rows
select coalesce( public_db.orf_id, unsw_db.orf_id) as orf_id
      
from blast2go_cneo_go_annotation   public_db
        full outer join zzz_blast2go_cneo_go_annotation_old unsw_db
                
                        on  public_db.orf_id = unsw_db.orf_id
                            and public_db.GO_Group = unsw_db.GO_Group
                            and public_db.GO_ID = unsw_db.GO_ID
where   public_db.orf_id is null      

intersect 
select coalesce( public_db.orf_id, unsw_db.orf_id) as orf_id
from blast2go_cneo_go_annotation   public_db
        full outer join zzz_blast2go_cneo_go_annotation_old unsw_db
                
                        on  public_db.orf_id = unsw_db.orf_id
                            and public_db.GO_Group = unsw_db.GO_Group
                            and public_db.GO_ID = unsw_db.GO_ID
where   unsw_db.orf_id is null      ;
                            
                
-- Not in public db only                 
--     806 rows             
select coalesce( public_db.orf_id, unsw_db.orf_id) as orf_id
      
from blast2go_cneo_go_annotation   public_db
        full outer join zzz_blast2go_cneo_go_annotation_old unsw_db
                
                        on  public_db.orf_id = unsw_db.orf_id
                            and public_db.GO_Group = unsw_db.GO_Group
                            and public_db.GO_ID = unsw_db.GO_ID
where   public_db.orf_id is null      

except 
select coalesce( public_db.orf_id, unsw_db.orf_id) as orf_id
from blast2go_cneo_go_annotation   public_db
        full outer join zzz_blast2go_cneo_go_annotation_old unsw_db
                
                        on  public_db.orf_id = unsw_db.orf_id
                            and public_db.GO_Group = unsw_db.GO_Group
                            and public_db.GO_ID = unsw_db.GO_ID
where   unsw_db.orf_id is null      ;


--- Not in UNSW only 
--- 200 rows
select coalesce( public_db.orf_id, unsw_db.orf_id) as orf_id
from blast2go_cneo_go_annotation   public_db
        full outer join zzz_blast2go_cneo_go_annotation_old unsw_db
                
                        on  public_db.orf_id = unsw_db.orf_id
                            and public_db.GO_Group = unsw_db.GO_Group
                            and public_db.GO_ID = unsw_db.GO_ID
where   unsw_db.orf_id is null      
except 
select coalesce( public_db.orf_id, unsw_db.orf_id) as orf_id
      
from blast2go_cneo_go_annotation   public_db
        full outer join zzz_blast2go_cneo_go_annotation_old unsw_db
                
                        on  public_db.orf_id = unsw_db.orf_id
                            and public_db.GO_Group = unsw_db.GO_Group
                            and public_db.GO_ID = unsw_db.GO_ID
where   public_db.orf_id is null    ;  



----------------------------------------------------------------------------------------------------------


