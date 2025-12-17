#!/bin/sh -x
# Usage: /gpfs0/tals/projects/Analysis/scRNA_seq/scripts->qsub -cwd -V -q tals.q filter_bam_by_CB.sh ../GSE270917/SRR29608249.tagged.bam CAGCATATCTGAGTGT CAGCATATCTGAGTGT
# Usage: /gpfs0/tals/projects/Analysis/scRNA_seq/scripts->qsub -cwd -V -q tals.q filter_bam_by_CB.sh ../PacBio_LongReads/mapped.tagged.sorted.bam AAAGGGCACACGTAAA AAAGGGCACACGTAAA
# Usage: /gpfs0/tals/projects/Analysis/scRNA_seq/scripts->qsub -cwd -V -q tals.q filter_bam_by_CB.sh ../PacBio_LongReads/mapped.tagged.sorted.bam ACGACGGCTGAGGTTG ACGACGGCTGAGGTTG
#WORKDIR="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE270917"
WORKDIR="/gpfs0/tals/projects/Analysis/scRNA_seq/PacBio_LongReads"
cd $WORKDIR

INPUT_BAM=$1
CB=$2
OUT_PREFIX=$3

# Filter BAM
echo "Filtering BAM for CB: $CB ..."
samtools view -h $INPUT_BAM \
    | awk 'substr($0,1,1)=="@" || $0 ~ /CB:Z:'$CB'/' \
    | samtools view -b -o ${OUT_PREFIX}.bam

# Index the new BAM
echo "Indexing BAM ..."
samtools index ${OUT_PREFIX}.bam

echo "Done. Filtered BAM and index:"
echo "${OUT_PREFIX}.bam"
echo "${OUT_PREFIX}.bam.bai"
