#!/bin/sh
set -eux  # safer: stop on error, print commands

# ====== Activate Conda ======
#source /gpfs0/tals/projects/software/anaconda3/etc/profile.d/conda.sh
#conda activate /gpfs0/tals/projects/software/Anaconda3-2025.06/envs/

# ====== Directories ======
WORKDIR="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE270917"
cd $WORKDIR

#download fasta and split to the paired reads. one should be barcode and the other the reads
#/gpfs0/tals/projects/software/anaconda3/envs/SRA/bin/fastq-dump.3.0.0 --split-files SRR29608249
#SRR29608249_1.fastq
#Cell barcode: 1-16
#UMI: 17-28

# ====== Input FASTQs ======
#R1="SRR29608249_1.fastq"
#R2="SRR29608249_2.fastq"

# ====== Step 1: Extract CB + UMI from Read 1 ======
#umi_tools extract \
#    --bc-pattern=CCCCCCCCCCCCCCCCNNNNNNNNNNNN \
#    --stdin=$R1 \
#    --read2-in=$R2 \
#    --stdout=R1_extracted.fastq \
#    --read2-out=R2_extracted.fastq \
#    --log=extract.log               

# Output:
#   R1_extracted.fastq  (trimmed R1, usually empty)
#   R2_extracted.fastq  (real reads, with CB/UMI encoded in read name)


# ====== Step 2: Align using HISAT2 ======
#HISAT_INDEX="/gpfs0/tals/projects/data/Genomes/hg38/grch38/genome"

#hisat2 -p 8 --mm --add-chrname -x "$HISAT_INDEX" -U R2_extracted.fastq -S SRR29608249.sam   

# Convert + sort
#samtools sort -@ 8 -o SRR29608249.sorted.bam SRR29608249.sam
#rm SRR29608249.sam

# ====== Step 3: Add Cell Barcode + UMI tags to BAM ======
#nergaon@sge1051:/gpfs0/tals/projects/Analysis/scRNA_seq/scripts->qsub -cwd -V -q tals.q runAddTag.sh
#this is not working. the version i have don't include tag
#umi_tools tag \
#    --stdin=SRR29608249.sorted.bam \
#    --stdout=SRR29608249.tagged.bam \
#    --log=tag.log
qsub -cwd -V -q tals.q runAddTag.sh    #i am here

# ====== Step 4: Sorting, indexing, QC ======
samtools index SRR29608249.tagged.bam
samtools flagstat SRR29608249.tagged.bam > flagStat.txt

qsub -cwd -V -q tals.q countBarcode.sh #count how many cells (unique barcodes) there are in the bam file
# ====== Set permissions cleanly ======
chmod 550 SRR29608249.tagged.bam
chmod 550 SRR29608249.tagged.bam.bai
chmod 550 flagStat.txt
chmod 550 R2_extracted.fastq
chmod 550 R1_extracted.fastq

echo "Pipeline completed successfully"

