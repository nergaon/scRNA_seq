#!/bin/sh -x
source /gpfs0/tals/projects/software/anaconda3/etc/profile.d/conda.sh
conda activate /gpfs0/tals/projects/software/Anaconda3-2025.06/envs/
bam_folder="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE270917"

cd $bam_folder
#download fasta and split to the paired reads. one should be barcode and the other the reads
#/gpfs0/tals/projects/software/anaconda3/envs/SRA/bin/fastq-dump.3.0.0 --split-files SRR29608249
#SRR29608249_1.fastq
#Cell barcode: 1-16
#UMI: 17-28
umi_tools extract \
    --bc-pattern=CCCCCCCCCCCCCCCCNNNNNNNNNNNN \
    --stdin=SRR29608249_1.fastq \
    --read2-in=SRR29608249_2.fastq \
    --stdout=R1_extracted.fastq \
    --read2-out=R2_extracted.fastq \
    --log=extract.log

#human index!!!!!!!!!!!!!!!
#--mm - Use memory-mapped I/O to load the index, rather than typical file I/O. 
#Memory-mapping allows many concurrent bowtie processes on the same computer to share the same memory image of the index (i.e. you pay the memory overhead just once).
hisat2 -p 8 -x /gpfs0/tals/projects/data/Genomes/hg38/grch38/genome --add-chrname --mm -U R2_extracted.fastq -S SRR29608249.sam
chmod 770 SRR29608249.sam
samtools view -bS SRR29608249.sam | samtools sort -o SRR29608249.sort.bam
chmod 770 SRR29608249.bam
rm -f SRR29608249.sam
chmod 770 SRR29608249.sort.bam
rm -f SRR29608249.bam
chmod 550 SRR29608249.sort.bam
umi_tools tag \
    --stdin=SRR29608249d.sorted.bam \
    --stdout=SRR29608249.tagged.bam \
    --log=tag.log
samtools index SRR29608249.tagged.bam
chmod 550 SRR29608249.tagged.bam
chmod 550 SRR29608249.tagged.bam.bai
samtools flagstat SRR29608249.tagged.bam > flagStat.txt
echo "SRR29608249.tagged.bam" >> flagStat.txt"

