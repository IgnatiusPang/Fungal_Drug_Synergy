#!/usr/bin/python 
import sys
import fileinput, re

# Nandan has given me a file consisting of '>' fasta file header for a gene, 
# followed by the list of GO terms associated with the gene, one GO term per line
# Convert this FASTA file format to Tab separated format

# convert_go_terms_to_table.py
# cd '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/BLAST/GO_terms/cneo/'


input_dir  = '/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/'

input_file = input_dir + 'GO_enrichments.txt'

output_file  = input_dir + 'GO_enrichments_formatted.txt'


OUTPUT= open(output_file, 'w')

fasta_header = ''

for line in fileinput.input(input_file):
        
        # equivalent to chomp in perl 
        line = line.rstrip('\n')

        #print line
        if   re.match('^>', line):                
                line =  re.sub(r'^>', '', line)
                fasta_header = line.split('|')
                print line
                
        elif not re.match( r'^\s*$', line) :
                # print the rest of the line
                line = line.split('\t')    
                line =  ['\t'.join( (line[0], line[1], line[2], line[3], line[4], line[6], line[7]) )]
                to_print =   fasta_header+line
                OUTPUT.write ('\t'.join(map(str,to_print)) + '\n')

OUTPUT.close()













