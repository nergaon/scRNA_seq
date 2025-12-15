#!/bin/sh -x

bam_folder="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE270928"

cd $bam_folder
#download fasta and split to the paired reads
/gpfs0/tals/projects/software/anaconda3/envs/SRA/bin/fastq-dump.3.0.0 --split-files SRR29628122
#human genome!!!!!!!!!!!!!!!
#--mm - Use memory-mapped I/O to load the index, rather than typical file I/O. 
#Memory-mapping allows many concurrent bowtie processes on the same computer to share the same memory image of the index (i.e. you pay the memory overhead just once).
hisat2 -x /gpfs0/tals/projects/data/Genomes/hg38/grch38/genome --add-chrname --mm -1 SRR29628122_1.fastq -2 SRR29628122_2.fastq -S SRR29628122.sam
chmod 770 SRR29628122.sam
samtools view -b SRR29628122.sam -o SRR29628122.bam
chmod 770 SRR29628122.bam
rm -f SRR29628122.sam
samtools sort SRR29628122.bam -o SRR29628122.sort.bam
chmod 770 SRR29628122.sort.bam
rm -f SRR29628122.bam
samtools index SRR29628122.sort.bam
chmod 550 SRR29628122.sort.bam
chmod 550 SRR29628122.sort.bam.bai
samtools flagstat SRR29628122.sort.bam > flagStat.txt
echo "SRR29628122.sort.bam" >> flagStat.txt"

