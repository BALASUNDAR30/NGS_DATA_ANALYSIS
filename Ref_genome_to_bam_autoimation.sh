#!/bin/bash

# === CONFIGURE THESE VARIABLES ===
REFERENCE_INDEX=" ref index directory"     # HISAT2 index prefix (already built)
READ_DIR="trimmed reads directory"              # Directory containing your .fastq.gz files
OUT_DIR="output directory"                 # Output directory for BAM files
THREADS=20

# === MAKE OUTPUT DIRECTORY IF NOT EXISTS ===
mkdir -p "$OUT_DIR"

# === LOOP OVER ALL _1_ READ FILES ===
for R1 in "$READ_DIR"/*_1_trimmed.fastq.gz; do
    SAMPLE=$(basename "$R1" | sed 's/_1_trimmed.fastq.gz//')
    R2="$READ_DIR/${SAMPLE}_2_trimmed.fastq.gz"

    # Check if R2 exists
    if [[ ! -f "$R2" ]]; then
        echo "Missing R2 for $SAMPLE. Skipping..."
        continue
    fi

    echo "Processing sample: $SAMPLE"

    # Output filenames
    SAM="$OUT_DIR/${SAMPLE}.sam"
    BAM="$OUT_DIR/${SAMPLE}.bam"
    SORTED_BAM="$OUT_DIR/${SAMPLE}.sorted.bam"

    # HISAT2 alignment
    hisat2 -p "$THREADS" -x "$REFERENCE_INDEX" -1 "$R1" -2 "$R2" -S "$SAM" --phred33

    # Convert SAM to BAM
    samtools view -@ "$THREADS" -bS "$SAM" > "$BAM"

    # Sort BAM
    samtools sort -@ "$THREADS" -o "$SORTED_BAM" "$BAM"

    # Index BAM (optional)
    samtools index "$SORTED_BAM"

    # Clean up
    rm "$SAM" "$BAM"

    echo "Finished $SAMPLE"
done

echo "All samples processed!"
