#/usr/bin/perl -w

use strict;
use warnings;

# java jvm-args -jar picard.jar PicardCommandName OPTION1=value1 OPTION2=value2...

my $base_directory = "/home/ignatius/PostDoc/2019/Fungal_Drug_Synergy/cneo_synergy"
my $input_directory= "$base_directory/Data/Sorted_SAM_Files/";
my $output_directory = "$base_directory/Results/InsertSize/";
my $picard_tools_directory = "/home/ignatius/Programs/2015/Picard_Tools/picard-tools-1.127/";
my @files_to_process = glob "$input_directory\*.bam" ;

chdir $picard_tools_directory;


foreach my $file ( @files_to_process ) {


    $file =~ /(.*\/)?(.*?)\./;
    
    my $file_prefix = $2;
    
    # print $file_prefix, "\n";
  
        my $command = "java  -jar picard.jar CollectInsertSizeMetrics INPUT=$file HISTOGRAM_FILE=$output_directory$file_prefix\_histogram.pdf OUTPUT=$output_directory$file_prefix\.txt";
        
        print $command, "\n";
        
        system($command);

        
} 

