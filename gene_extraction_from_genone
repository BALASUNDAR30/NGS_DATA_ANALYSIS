## gene extraction form the same species but in diffferent cultivars ##
#######################################################################

makeblastdb -in genome.fa -dbtype nucl -out C1_db
blastn -query ref_gene_seq.fasta -db C1_db -out result.txt -evalue 1e-5 -outfmt 6 -num_threads 8
bedtools getfasta   -fi genome.fa   -bed gene_cord_bed_file.bed   -s   -name > extracted_gene.fa
