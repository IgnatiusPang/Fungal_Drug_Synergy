###############################################################################################

# Script Name:        create_GO_hierarchy_graph.R
# Author:             Ignatius Pang
# Version:            v1.01
# Date created:       7-5-2015
# Date last updated :  12-5-2015

# Description: 
## From the Gene Ontology directed acyclic graph (DAG), which is represented as an edge list
## Where the first column is the parent (go_id_parent), the second column is hte child (go_id_child)
## We performed Breath First Search to get the depth of each node (see file create_GO_hierarchy_graph.R
## since it is breath first search, distance is the shortest path to root

## Only 'is_a' relationships are captured in the input file

###############################################################################################

### Source location

# cd '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/BLAST/GO_terms/cneo/'

# nohup R --vanilla < create_GO_hierarchy_graph.R > Log/run_create_GO_hierarchy_graph.log  &


##################  DB connection parameters ####################################################################

library(RODBC)
library(igraph)


### Database connection
input_db <- "sbi_fungal_pathogent_2013"  # The name of the SQL database for the data to be imported into
user_id <- "ignatius"
user_passwd <- "Sp33dBo@t"

conn_string <- paste("SERVER=localhost;DRIVER={PostgreSQL};DATABASE=", input_db,
                     ";PORT=5432;UID=", user_id, ";PWD=", user_passwd ,";LowerCaseIdentifier=0", sep="")

channel <- odbcDriverConnect( conn_string)

sessionInfo()

##################################################################################################################
### Input Parameters

input_dir <- "/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/GO_graph_analysis/"

results_dir <- "/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/GO_graph_analysis/"

process_file   <- paste( input_dir, "go_basic_is_a_relationships_formatted_process.txt", sep="")

function_file  <- paste( input_dir, "go_basic_is_a_relationships_formatted_function.txt", sep="")
 
component_file <- paste( input_dir, "go_basic_is_a_relationships_formatted_component.txt", sep="")

### read the files into a table
process_table <- read.table (process_file)
function_table <- read.table(function_file)
component_table <- read.table(component_file) 

##################################################################################################################


get_distance_from_root <- function ( edge_list_table, input_root ) {

        ### Draw the biological processes network
        go_net <- graph.empty(directed=TRUE)

        ### Add nodes
        go_nodes <- unique( c(  as.vector(edge_list_table[,1]), as.vector(edge_list_table[,2]) ) )

        go_net<- add.vertices(go_net, length(go_nodes),
                                name=go_nodes)
                                
        if( length( V(go_net)) != length( go_nodes) ) {
        
                warning("get_distance_from_root: Something wrong with the number of nodes.")
        }
                                

        ### Add Edges

        go_edges <- t( data.frame( go_id_parent=as.vector(edge_list_table[,1]),
                                        go_id_child=as.vector(edge_list_table[,2])    ) )

        go_net <- add.edges(go_net, go_edges )
        
        if ( (input_root %in% V(go_net)$name) == FALSE ) {
        
                warning(paste( "get_distance_from_root: root node", input_root , "not in network") )
        }

        
        breath_first_search  <- graph.bfs (go_net, input_root, neimode="out", dist=TRUE)
        
        depth_first_search <- graph.dfs (go_net, input_root, neimode="out", dist=TRUE)
        
        
        
        dist_to_root <- data.frame(nodes=as.character(V(go_net)$name), breath_first_search=breath_first_search$dist, depth_first_search=depth_first_search$dist )

        return( dist_to_root)
  
}

##################################################################################################################

# The root node is 
# GO:0008150 ! biological_process

  biological_process_root <- "GO:0008150"
  process_distance_to_root <- get_distance_from_root( process_table, biological_process_root)
  
  
# The root node is 
# is_a: GO:0005575 ! cellular_component
  cellular_component_root <- "GO:0005575"
  component_distance_to_root <- get_distance_from_root( component_table, cellular_component_root) 


# The root node is 
# is_a: GO:0003674 ! molecular_function
  molecular_function_root <- "GO:0003674"
  function_distance_to_root <-  get_distance_from_root( function_table, molecular_function_root) 

  
  # Group the smaller tables into one large table for easy handling in SQL
  
  process_distance_to_root <- cbind( process_distance_to_root, go_group = rep( 'P', length(process_distance_to_root[,1] ) ) )
  component_distance_to_root <- cbind( component_distance_to_root, go_group = rep( 'C', length(component_distance_to_root[,1] ) ) )
  function_distance_to_root <- cbind( function_distance_to_root, go_group = rep( 'F',  length(function_distance_to_root[,1] ) )  ) 
  
  
  distance_to_root <-  rbind( process_distance_to_root , 
         component_distance_to_root , 
         function_distance_to_root )
         
   
  write.table(    distance_to_root, paste(results_dir, "go_distance_to_root.txt", sep=""), row.names=FALSE)
  
  
##################################################################################################################



