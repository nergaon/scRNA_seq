#!/bin/sh -x

# =======================
# Config
# =======================
SAMPLE="SRR6835851_1.fastq"  # or the SRR/FASTQ ID
FASTQ_DIR="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE109774/fastqs"
OUT_DIR="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE109774/cellranger_out"
REF="/gpfs0/tals/projects/data/Genomes/mouse/GRCm39/genome"

# =======================
# Step 1: Run CellRanger count
# =======================
echo "Running CellRanger count for $SAMPLE ..."

/gpfs0/tals/projects/software/CellRanger/cellranger-3.0.2/cellranger count \
    --id=$SAMPLE \
    --fastqs=$FASTQ_DIR \
    --sample=$SAMPLE \
    --transcriptome=$REF \
    --localcores=8 \
    --localmem=64 \
    --expect-cells=5000

# =======================
# Step 2: BAM with CB/UB tags
# =======================
# CellRanger outputs:
# /path/to/cellranger_out/$SAMPLE/outs/possorted_genome_bam.bam
# This BAM already has CB:Z and UB:Z tags.

set BAM = $OUT_DIR/$SAMPLE/outs/possorted_genome_bam.bam

# =======================
# Step 3: Index BAM
# =======================
samtools index $BAM
echo "BAM ready for IGV: $BAM"
echo "Indexed BAM: $BAM.bai"

# =======================
# Optional Step 4: Split BAM per cell
# =======================
# If you want per-cell BAMs:
# Cell barcodes are in barcodes.tsv
set BARCODES = $OUT_DIR/$SAMPLE/outs/filtered_feature_bc_matrix/barcodes.tsv

foreach cb (`cat $BARCODES`)
    samtools view -b -d CB:Z:$cb $BAM > $OUT_DIR/${SAMPLE}_${cb}.bam
end

echo "All done!"

