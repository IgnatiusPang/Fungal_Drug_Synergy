#/usr/bin/perl -w


############################################################## 

# Script Name:        go_basic_alt_id_translation_table.pl
# Author:             Ignatius Pang
# Version:            v1.01 
# Date created:       8-5-15
# Date last updated : 8-5-15

# Description: Parse GO basic obo file
## Output file: First column is the main GO ID, 
##              the second column is the alternate GO ID.

################### Version History ########################## 

# v1.01
# -- 8-5-15 created script
# -- 

# cd 'file:///media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Source/v1.01/BLAST/GO_terms/cneo/'

#################### Import Libraries #################################################################### 

use strict;
use warnings;

my $input_file = "/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/go-basic.obo.txt";
my $output_file = "/media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/convert_alternate_go_id.txt";

*INPUT = &my_read_file($input_file);
*OUTPUT = &my_write_file($output_file);

# grep "^\(id:\|alt_id:\)" /media/babs/Systemsbiology/Igy/2013/Fungal_Shared/Results/v1.01/BLAST/GO_terms_annotation/cneo/go-basic.obo.txt

my $id = "";
my $alt_id = "";

### Print the table header
print OUTPUT "main_go_id\talternate_go_id\n";

while (<INPUT>) {

        chomp;

        if ( $_ =~ /^id/ ) {
                
                my @temp = split/\s+/, ;
                $id = $temp[1];

        } elsif ( $_ =~ /^alt_id/ ) {

                my @temp = split/\s+/, ;
                $alt_id = $temp[1];

                print OUTPUT $id, "\t", $alt_id, "\n";
        }

}

close(INPUT);
close(OUTPUT);

####################### Subroutines   #####################################################################

sub my_read_file
{
    my ($file) = @_;

    my $filehandle;

    if ( !open ( $filehandle, "< $file" ))
    {
        print STDERR "$0: Cannot read file $file, $!\n";
        exit 1;
    }

    return $filehandle;
}

sub my_write_file
{
    my ($file) = @_;

    my $filehandle;

    if ( !open ( $filehandle, "> $file" ))
    {
        print STDERR "$0: Cannot write file $file, $!\n";
        exit 1;
    }

    return $filehandle;
}

###########################################################################################################
