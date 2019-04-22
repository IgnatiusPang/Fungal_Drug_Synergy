#!/usr/bin/python 


###############################################################################################


# Script Name:        clean_go_is_arelationshiop.py
# Author:             Ignatius Pang
# Version:            v1.01
# Date created:       7-5-2015
# Date last updated :  7-5-2015

# Description: 
## Convert the Gene Ontology directed acyclic graph (DAG) into an edge list
## Where the first column is the parent (go_id_parent), the second column is hte child (go_id_child)
## Only is_a relationships are captured in the input file
## Next we need to perform Breath First Search to get the depth of each node (see file create_GO_hierarchy_graph.R


# cd '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/BLAST/GO_terms/cneo/'

###############################################################################################
## Import Libraries

import sys
import fileinput, re


### Global Parameters

input_dir  = '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/GO_graph_analysis/'

input_file = input_dir + 'go-basic.obo_GO_to_GO.txt'


### Separate the directed acyclic graph (DAG) 
output_file_process    = input_dir + 'go_basic_is_a_relationships_formatted_process.txt'
output_file_function   = input_dir + 'go_basic_is_a_relationships_formatted_function.txt'
output_file_component  = input_dir + 'go_basic_is_a_relationships_formatted_component.txt'

PROCESS_OUTPUT   = open(output_file_process, 'w')
FUNCTION_OUTPUT  = open(output_file_function, 'w')
COMPONENT_OUTPUT = open(output_file_component, 'w')

go_id_parent  = ''
go_group = ''


###############################################################################################

### Function
for line in fileinput.input(input_file):
        
        # equivalent to chomp in perl 
        line = line.rstrip('\n')

        #print line
        if   re.match('^>', line):                
                line =  re.sub(r'^>', '', line)
                splitted_line = line.split('|')
                go_id_child = [splitted_line[0]]
                go_group = splitted_line[2]
                print go_id_child
                
        elif not re.match( r'^\s*$', line) :
                # print the rest of the line
                line = line.split(' ')  
                go_id_parent = [line[1]]
                to_print =   go_id_parent + go_id_child
                
                if go_group == 'P':                        
                        PROCESS_OUTPUT.write ('\t'.join(map(str,to_print)) + '\n')
                elif go_group == 'F':
                        FUNCTION_OUTPUT.write ('\t'.join(map(str,to_print)) + '\n')
                elif go_group == 'C':
                        COMPONENT_OUTPUT.write ('\t'.join(map(str,to_print)) + '\n')
                                                
                        

### File close
PROCESS_OUTPUT.close()
FUNCTION_OUTPUT.close()
COMPONENT_OUTPUT.close()


###############################################################################################
