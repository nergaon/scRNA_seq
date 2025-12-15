#!/bin/sh -x

bam_folder="/gpfs0/tals/projects/Analysis/scRNA_seq/PacBio_LongReads"
cd $bam_folder
#download files with barcode and umi
#wget -r -np https://downloads.pacbcloud.com/public/dataset/Kinnex-single-cell-RNA/DATA-MAS-Revio-PBMC-1/2-DeduplicatedReads/
#wget -r -np -nH --cut-dirs=5 -R "index.html*" https://downloads.pacbcloud.com/public/dataset/Kinnex-single-cell-RNA/DATA-MAS-Revio-PBMC-1/2-DeduplicatedReads/

#convert fasta to fastq
#awk 'BEGIN{FS=" "} /^>/ {h=$0; getline s; printf "%s\n%s\n+\n%s\n", h, s, gensub(/./, "I", "g", s)}' \
#  scisoseq.5p--3p.tagged.refined.corrected.sorted.dedup.fasta > dedup_reads.fastq
#This creates a FASTQ with quality "I".

#add the tag to the read names
#awk '
#  /^>/ {
#    split($0,a,";");
#    cb=""; xm="";
#    for(i in a){
#      if(a[i] ~ /CB=/){ split(a[i],b,"="); cb=b[2] }
#      if(a[i] ~ /XM=/){ split(a[i],b,"="); xm=b[2] }
#    }
    # extract molecule/0 (remove ">")
#    readname = substr($1,2)
    # build compact QNAME (no spaces)
#    newname = readname "_CB:Z:" cb "_XM:Z:" xm
    # get sequence and build fake quality
#    getline seq
#    qual = gensub(/./,"I","g",seq)
#    print "@" newname "\n" seq "\n+\n" qual
#    next
#  }
#' dedup_reads.fastq > reads_tagged.fastq                 

#Align to human genome                                 
minimap2 -t 70 -ax splice:hq -uf --secondary=no /gpfs0/tals/projects/data/Genomes/hg38/grch38/GRCh38.primary_assembly.genome.fa reads_tagged.fastq | samtools view -bS -o mapped.bam
#Barcodes remain in the read name

#Convert read-name tags into BAM tags
cd /gpfs0/tals/projects/Analysis/scRNA_seq/scripts
python /gpfs0/tals/projects/Analysis/scRNA_seq/scripts/add_tag_long_reads.py

cd $bam_folder
samtools sort -o mapped.tagged.sorted.bam mapped.tagged.bam
samtools index mapped.tagged.sorted.bam
samtools flagstat mapped.tagged.bam > flagStat.txt

#filter bam by CB tag to get one cell bam
qsub -cwd -V -q tals.q filter_bam_by_CB.sh ../PacBio_LongReads/mapped.tagged.sorted.bam AAAGGGCACACGTAAA AAAGGGCACACGTAAA

#wget options
#-r — recursive download
#-np — no parent: don’t ascend to parent directories
#-nH — don’t create host-prefixed directory (i.e. don’t prefix with downloads.pacbcloud.com)
#--cut-dirs=5 — skip first 5 path components when creating local directories (adjust according to URL structure)
#-R "index.html*" — reject index.html files (i.e. don’t download directory listings)

#minimap2
#-ax splice:hq → spliced alignment for HiFi CCS
#-uf → cDNA
#--secondary=no → avoid secondary alignments
#-t 20 CPU threads to use = 20