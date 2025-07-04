#!/bin/bash

# === Configuration ===
REFERENCE=" Reference genome File contains folder "
MAIN_VCF_DIR=" VCF_file directory"  # Contains gene folders
GENE_REGION_FILE= "gene_regions.txt"  # TSV file with gene name and scaffold:region

# Output parent directory
OUTPUT_PARENT="./output folder name"
mkdir -p "$OUTPUT_PARENT"

# Prepare reference index if not already done
if [ ! -f "${REFERENCE}.fai" ]; then
    echo "Indexing reference with samtools..."
    samtools faidx "$REFERENCE"
fi

DICT="${REFERENCE%.*}.dict"
if [ ! -f "$DICT" ]; then
    echo "Creating reference dictionary..."
    gatk CreateSequenceDictionary -R "$REFERENCE"
fi

# Loop through each gene and region
while IFS=$'\t' read -r GENE REGION; do
    echo "🔄 Processing gene: $GENE | Region: $REGION"

    VCF_DIR="$MAIN_VCF_DIR/$GENE"
    OUTPUT_DIR="$OUTPUT_PARENT/${GENE}_fastas"
    MERGED_FASTA="$OUTPUT_PARENT/${GENE}_merged.fasta"
    mkdir -p "$OUTPUT_DIR"
    > "$MERGED_FASTA"

    # Index VCFs
    for VCF_GZ in "$VCF_DIR"/*.vcf.gz; do
        if [[ -f "$VCF_GZ" ]]; then
            echo "Indexing $VCF_GZ..."
            gatk IndexFeatureFile -I "$VCF_GZ"
        fi
    done

    # Generate consensus
    for VCF in "$VCF_DIR"/*.vcf.gz; do
        BASENAME=$(basename "$VCF" .vcf.gz)
        OUTPUT_FASTA="$OUTPUT_DIR/${BASENAME}.fasta"

        echo "Generating consensus for $BASENAME in region $REGION..."

        gatk FastaAlternateReferenceMaker \
            -R "$REFERENCE" \
            -V "$VCF" \
            -L "$REGION" \
            -O "$OUTPUT_FASTA"

        sed -i "1s/.*/>${BASENAME}/" "$OUTPUT_FASTA"
        cat "$OUTPUT_FASTA" >> "$MERGED_FASTA"
    done

    echo "✅ Done with $GENE. Merged FASTA at: $MERGED_FASTA"
done < "$GENE_REGION_FILE"

echo "🎉 All gene consensus FASTAs created!"
