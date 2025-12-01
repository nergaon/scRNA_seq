#!/bin/sh -x

bam_folder="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE109774"

cd $bam_folder
#download fasta and split to the paired reads. one should be barcode and the other the reads
/gpfs0/tals/projects/software/anaconda3/envs/SRA/bin/fastq-dump.3.0.0 --split-files SRR6835851
#mouse index!!!!!!!!!!!!!!!
#--mm - Use memory-mapped I/O to load the index, rather than typical file I/O. 
#Memory-mapping allows many concurrent bowtie processes on the same computer to share the same memory image of the index (i.e. you pay the memory overhead just once).
#hisat2 -x /gpfs0/tals/projects/data/Genomes/mouse/GRCm39/genome --add-chrname --mm -1 SRR6835851_1.fastq -2 SRR6835851_2.fastq -S SRR6835851.sam
#chmod 770 SRR6835851.sam
#samtools view -b SRR6835851.sam -o SRR6835851.bam
#chmod 770 SRR6835851.bam
#rm -f SRR6835851.sam
#samtools sort SRR6835851.bam -o SRR6835851.sort.bam
#chmod 770 SRR6835851.sort.bam
#rm -f SRR6835851.bam
#samtools index SRR6835851.sort.bam
#chmod 550 SRR6835851.sort.bam
#chmod 550 SRR6835851.sort.bam.bai
#samtools flagstat SRR6835851.sort.bam > flagStat.txt
#echo "SRR6835851.sort.bam" >> flagStat.txt"

