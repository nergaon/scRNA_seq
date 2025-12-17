#!/bin/sh -x

bam_folder="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE126906_10xGenomics"

cd $bam_folder
#download fasta and split to the paired reads
#/gpfs0/tals/projects/software/anaconda3/envs/SRA/bin/fastq-dump.3.0.0 --split-files SRR8606521
#add barcode and umi to the header of read_2
paste -d '\t' SRR8606521_1.fastq SRR8606521_2.fastq | \
awk -F '\t' '
{
    n = NR % 4

    if (n == 1) {
        r1_h = $1    # full R1 header, e.g. @SRR8606521.1 ...
        r2_h = $2    # full R2 header (may or may not include SRR)
    }
    if (n == 2) {
        r1_seq = $1
        r2_seq = $2
    }
    if (n == 3) {
        r2_plus = $2
    }
    if (n == 0) {
        r2_qual = $2

        bc  = substr(r1_seq, 1, 16)
        umi = substr(r1_seq, 17, 10)

        # Use R1 header (which contains @SRR...) so we retain the SRR id.
        header = r1_h

        # Print valid FASTQ 4-line block for R2 but with tags appended to header
        print header " CB:Z:" bc " UMI:Z:" umi
        print r2_seq
        print r2_plus
        print r2_qual
    }
}' > R2.tagged.fastq

#human index!!!!!!!!!!!!!!!
#--mm - Use memory-mapped I/O to load the index, rather than typical file I/O. 
#Memory-mapping allows many concurrent bowtie processes on the same computer to share the same memory image of the index (i.e. you pay the memory overhead just once).
hisat2 -x /gpfs0/tals/projects/data/Genomes/hg38/grch38/genome --add-chrname --mm -U R2.tagged.fastq -S SRR8606521.sam
chmod 770 SRR8606521.sam
samtools view -b SRR8606521.sam -o SRR8606521.bam
chmod 770 SRR8606521.bam
rm -f SRR8606521.sam
samtools sort SRR8606521.bam -o SRR8606521.sort.bam
chmod 770 SRR8606521.sort.bam
rm -f SRR8606521.bam
samtools index SRR8606521.sort.bam
chmod 550 SRR8606521.sort.bam
chmod 550 SRR8606521.sort.bam.bai
samtools flagstat SRR8606521.sort.bam > flagStat.txt
echo "SRR8606521.sort.bam" >> flagStat.txt"

