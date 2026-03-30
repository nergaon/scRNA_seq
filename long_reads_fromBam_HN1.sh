#!/bin/sh -x

bam_folder="/gpfs0/tals/projects/Analysis/scRNA_seq/PacBio_LongReads"
cd $bam_folder
#download files with barcode and umi
#wget -r -np https://downloads.pacbcloud.com/public/dataset/Kinnex-single-cell-RNA/DATA-MAS-Revio-PBMC-1/2-DeduplicatedReads/
wget -r -np -nH --cut-dirs=5 -R "index.html*" https://downloads.pacbcloud.com/public/dataset/Kinnex-single-cell-RNA/DATA-MAS-Revio-PBMC-1/2-DeduplicatedReads/

#Prepare the reference genome - only once
/gpfs0/tals/projects/data/Genomes/hg38/pbmm2-1.17.0-h9ee0642_0/bin/pbmm2 index /gpfs0/tals/projects/data/Genomes/hg38/grch38/GRCh38.primary_assembly.genome.fa /gpfs0/tals/projects/data/Genomes/hg38/GRCh38.mmi

/gpfs0/tals/projects/data/Genomes/hg38/pbmm2-1.17.0-h9ee0642_0/bin/pbmm2 align \
  /gpfs0/tals/projects/data/Genomes/hg38/GRCh38.mmi \
  scisoseq.5p--3p.tagged.refined.corrected.sorted.dedup.bam \
  aligned.GRCh38.bam \
  --preset ISOSEQ \
  --sort

#--preset ISOSEQ tells pbmm2 / minimap2 to use a predefined alignment parameter set optimized for PacBio Iso-Seq full-length transcript reads.

#bam file: /gpfs0/tals/projects/Analysis/scRNA_seq/PacBio_LongReads/mapped.tagged.sorted.bam 