#!/bin/sh -x

bam_folder="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE279316_smartSeq"

cd $bam_folder
#download fasta and split to the paired reads
/gpfs0/tals/projects/software/anaconda3/envs/SRA/bin/fastq-dump.3.0.0 --split-files SRR30870631
#human index!!!!!!!!!!!!!!!
#--mm - Use memory-mapped I/O to load the index, rather than typical file I/O. 
#Memory-mapping allows many concurrent bowtie processes on the same computer to share the same memory image of the index (i.e. you pay the memory overhead just once).
hisat2 -x /gpfs0/tals/projects/data/Genomes/hg38/grch38/genome --add-chrname --mm -1 SRR30870631_1.fastq -2 SRR30870631_2.fastq -S SRR30870631.sam
chmod 770 SRR30870631.sam
samtools view -b SRR30870631.sam -o SRR30870631.bam
chmod 770 SRR30870631.bam
rm -f SRR30870631.sam
samtools sort SRR30870631.bam -o SRR30870631.sort.bam
chmod 770 SRR30870631.sort.bam
rm -f SRR30870631.bam
samtools index SRR30870631.sort.bam
chmod 550 SRR30870631.sort.bam
chmod 550 SRR30870631.sort.bam.bai
samtools flagstat SRR30870631.sort.bam > flagStat.txt
echo "SRR30870631.sort.bam" >> flagStat.txt"

