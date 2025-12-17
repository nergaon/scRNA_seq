#!/bin/sh
set -eux  # safer: stop on error, print commands

# ====== Activate Conda ======
source /gpfs0/tals/projects/software/anaconda3/etc/profile.d/conda.sh
conda activate /gpfs0/tals/projects/software/Anaconda3-2025.06/envs/scRNA_seq

# ====== Directories ======
WORKDIR="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE270917"


#download fasta and split to the paired reads. R1 barcode and UMI. R2 reads
/gpfs0/tals/projects/software/anaconda3/envs/SRA/bin/fastq-dump.3.0.0 --split-files SRR29608249
#SRR29608249_1.fastq
#Cell barcode: 1-16
#UMI: 17-28

# ====== Input FASTQs ======
#R1="SRR29608249_1.fastq"
#R2="SRR29608249_2.fastq"

#Prepare reference (once)
cd /gpfs0/tals/projects/data/Genomes/hg38/grch38/
/gpfs0/tals/projects/software/CellRanger/cellranger-3.0.2/cellranger-cs/3.0.2/bin/cellranger mkref --genome=GRCh38cellranger --fasta=/gpfs0/tals/projects/data/Genomes/hg38/grch38/GRCh38.primary_assembly.genome.fa --genes=/gpfs0/tals/projects/data/Transcriptomes/human_hg38/Homo_sapiens.GRCh38.113_chr_HN1.gtf

cd $WORKDIR
#change the names to be as cellranger like
mv SRR29608249_1.fastq SRR29608249_S1_L001_R1_001.fastq
mv SRR29608249_2.fastq SRR29608249_S1_L001_R2_001.fastq

/gpfs0/tals/projects/software/CellRanger/cellranger-3.0.2/cellranger-cs/3.0.2/bin/cellranger count \
  --id=SRR29608249 \
  --fastqs=/gpfs0/tals/projects/Analysis/scRNA_seq/GSE270917 \
  --sample=SRR29608249 \
  --transcriptome=/gpfs0/tals/projects/data/Genomes/hg38/grch38/GRCh38cellranger \
  --localcores=16 \
  --localmem=64

