#!/bin/bash
source 00.sh

# Setup #############################
SETUP_WITH_OUTPUT_DIR $1
#####################################

INFO "Setting up the pan analysis directory"
mkdir $output_dir/pan_test
cp $files/mock_data_for_pangenomics/*.fa                      $output_dir/pan_test/
cp $files/mock_data_for_pangenomics/functions/*functions*     $output_dir/pan_test/
cp $files/mock_data_for_pangenomics/external-genomes.txt      $output_dir/pan_test/
cp $files/mock_data_for_pangenomics/example-PC-collection.txt $output_dir/pan_test/
cp $files/mock_data_for_pangenomics/default-state.json        $output_dir/pan_test/
cp $files/example_description.md                              $output_dir/pan_test/
cd $output_dir/pan_test

INFO "Generating contigs databases for external genomes"
anvi-script-FASTA-to-contigs-db 01.fa
anvi-script-FASTA-to-contigs-db 02.fa
anvi-script-FASTA-to-contigs-db 03.fa

INFO "Importing functions into the contigs database"
anvi-import-functions -c 01.db -i 01-functions.txt
anvi-import-functions -c 02.db -i 02-functions.txt
anvi-import-functions -c 03.db -i 03-functions.txt

INFO "Generating an anvi'o genomes storage"
anvi-gen-genomes-storage -e external-genomes.txt -o TEST-GENOMES.h5

INFO "Running the pangenome anaysis with default parameters"
anvi-pan-genome -g TEST-GENOMES.h5 -o TEST/ -n TEST --use-ncbi-blast --description example_description.md

INFO "Running the pangenome analysis again utilizing previous search results"
anvi-pan-genome -g TEST-GENOMES.h5 -o TEST/ -n ANOTHER_TEST --use-ncbi-blast --min-occurrence 2 --description example_description.md

INFO "Importing an example collection of protein clusters"
anvi-import-collection -p TEST/TEST-PAN.db -C test_collection example-PC-collection.txt

INFO "Exporting the collection 'test_collection'"
anvi-export-collection -p TEST/TEST-PAN.db -C test_collection -O exported_collection --include-unbinned

INFO "Exporting aligned amino acid sequences for some protein clusters"
anvi-export-pc-alignments -p TEST/TEST-PAN.db -g TEST-GENOMES.h5 -C test_collection -b PCB_1_CORE -o aligned_gene_sequences_in_PCB_1_CORE_AA.fa

INFO "Exporting aligned DNA sequences for some protein clusters"
anvi-export-pc-alignments -p TEST/TEST-PAN.db -g TEST-GENOMES.h5 -C test_collection -b PCB_1_CORE -o aligned_gene_sequences_in_PCB_1_CORE_DNA.fa --report-DNA-sequences

INFO "First five line from the AA output"
head -n 5 aligned_gene_sequences_in_PCB_1_CORE_AA.fa

INFO "First five line from the DNA output"
head -n 5 aligned_gene_sequences_in_PCB_1_CORE_DNA.fa

INFO "Exporting concatenated amino acid sequences for some protein clusters for phylogenomics"
anvi-export-pc-alignments -p TEST/TEST-PAN.db -g TEST-GENOMES.h5 -C test_collection -b PCB_1_CORE -o aligned_gene_sequences_in_PCB_1_CORE_AA.fa --concatenate-pcs

INFO "Summarizing the pan, using the test collection (in quick mode)"
anvi-summarize -p TEST/TEST-PAN.db -g TEST-GENOMES.h5 -C test_collection -o TEST_SUMMARY_QUICK --quick

INFO "Summarizing the pan, using the test collection"
anvi-summarize -p TEST/TEST-PAN.db -g TEST-GENOMES.h5 -C test_collection -o TEST_SUMMARY

INFO "Listing collections available"
anvi-show-collections-and-bins -p TEST/TEST-PAN.db

INFO "Importing the default state for pretty outputs"
anvi-import-state -p TEST/TEST-PAN.db -s default-state.json -n default
anvi-import-state -p TEST/ANOTHER_TEST-PAN.db -s default-state.json -n default

INFO "Displaying the initial pangenome analysis results"
anvi-display-pan -p TEST/TEST-PAN.db -s TEST/TEST-SAMPLES.db -g TEST-GENOMES.h5 --title "A mock pangenome analysis"

INFO "Displaying the second pangenome analysis results"
anvi-display-pan -p TEST/ANOTHER_TEST-PAN.db -s TEST/ANOTHER_TEST-SAMPLES.db -g TEST-GENOMES.h5 --title "A mock pangenome analysis (with --min-occurrence 2)"
