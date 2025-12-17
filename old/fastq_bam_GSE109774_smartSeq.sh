#!/bin/sh -x

bam_folder="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE109774"

cd $bam_folder
#download fasta and split to the paired reads. smart seq 2
/gpfs0/tals/projects/software/anaconda3/envs/SRA/bin/fastq-dump.3.0.0 --split-files SRR6608713
#mouse index!!!!!!!!!!!!!!!
#--mm - Use memory-mapped I/O to load the index, rather than typical file I/O. 
#Memory-mapping allows many concurrent bowtie processes on the same computer to share the same memory image of the index (i.e. you pay the memory overhead just once).
hisat2 -x /gpfs0/tals/projects/data/Genomes/mouse/GRCm39/genome --add-chrname --mm -1 SRR6608713_1.fastq -2 SRR6608713_2.fastq -S SRR6608713.sam
chmod 770 SRR6608713.sam
samtools view -b SRR6608713.sam -o SRR6608713.bam
chmod 770 SRR6608713.bam
rm -f SRR6608713.sam
samtools sort SRR6608713.bam -o SRR6608713.sort.bam
chmod 770 SRR6608713.sort.bam
rm -f SRR6608713.bam
samtools index SRR6608713.sort.bam
chmod 550 SRR6608713.sort.bam
chmod 550 SRR6608713.sort.bam.bai
samtools flagstat SRR6608713.sort.bam > flagStat.txt
echo "SRR6608713.sort.bam" >> flagStat.txt"

