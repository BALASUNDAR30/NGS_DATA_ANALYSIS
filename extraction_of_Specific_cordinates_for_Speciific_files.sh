#!/bin/bash

# Set directories
VCF_DIR= "FILE CONTAINS SET OF VCF FILES"
OUTPUT_DIR=" OUTPUT DIRECTORIES"

mkdir -p "$OUTPUT_DIR"

# List of specific VCF files to process
declare -a selected_vcfs=("1881.vcf.gz" "1251.vcf.gz" "1163.vcf.gz" "827.vcf.gz")

# List of gene regions (with 2kb upstream included)
readarray -t genes <<< "
SiATG8a	scaffold_6	2735489-2737488
SiATG8b	scaffold_7	30399533-30401532
SiATG8c	scaffold_4	3953704-3955703
SiATG8d	scaffold_2	41652964-41654963
SiATG9a	scaffold_9	13208653-13210652
SiATG9b	scaffold_9	51218553-51220552
SiATG12	scaffold_1	39546933-39548932
SiATG18a	scaffold_9	11652562-11654561
SiATG18b	scaffold_3	6560813-6562812
SiATG18c	scaffold_1	40222647-40224646
SiATG18d	scaffold_5	45689508-45691507
SiATG18e	scaffold_5	9927984-9929983
SiATG18f	scaffold_3	21221476-21223475
SiATG18g	scaffold_5	38888008-38890007

"

# Loop through selected VCFs
for vcf in "${selected_vcfs[@]}"; do
    input_file="$VCF_DIR/$vcf"
    filename=$(basename "$vcf" .vcf.gz)

    # Loop through gene regions
    for line in "${genes[@]}"; do
        read -r gene chr region <<< "$line"
        output_gene_dir="${OUTPUT_DIR}/${gene}"
        mkdir -p "$output_gene_dir"
        bcftools view -r "${chr}:${region}" "$input_file" -Oz -o "${output_gene_dir}/${filename}_${gene}.vcf.gz"
    done
done
