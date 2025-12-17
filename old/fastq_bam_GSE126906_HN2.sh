#!/bin/sh -x
source /gpfs0/tals/projects/software/Anaconda3-2025.06/etc/profile.d/conda.sh
conda activate /gpfs0/tals/projects/software/Anaconda3-2025.06/envs/spyder_HN1

bam_folder="/gpfs0/tals/projects/Analysis/scRNA_seq/GSE126906_10xGenomics"
cd $bam_folder

# =====================
#  Input FASTQ files
# =====================
R1="SRR8606521_1.fastq"
R2="SRR8606521_2.fastq"
OUT="SRR8606521"

echo "STEP 1: building R2 tagged FASTQ"

#paste -d '\t' SRR8606521_1.fastq SRR8606521_2.fastq | \
#awk -F '\t' '
#{
#    n = NR % 4
#
#    if (n == 1) {
#        r1_h = $1
#        split(r1_h, arr, " ")
#        split(arr[1], arr2, ".")
#        srr = arr2[1]
#    }
#
#    if (n == 2) {
#        r1_seq = $1
#        r2_seq = $2
#    }
#
#    if (n == 3) {
#        r2_plus = $2
#    }
#
#    if (n == 0) {
#        r2_qual = $2
#        bc  = substr(r1_seq, 1, 16)
#        umi = substr(r1_seq, 17, 10)
#
#        # use R1 for base
#        print r1_h " CB:Z:" bc " UMI:Z:" umi
#        print r2_seq
#        print "+"
#        print r2_qual
#    }
#}' > SRR8606521.R2.tagged.fastq

echo "Generated $(wc -l < ${OUT}.R2.tagged.fastq) lines."

# =====================
#  HISAT2
# =====================
echo "STEP 2: HISAT2 aligning"
hisat2 -x /gpfs0/tals/projects/data/Genomes/hg38/grch38/genome --add-chrname -U ${OUT}.R2.tagged.fastq -S ${OUT}.sam

echo "Alignment finished."

# =====================
# Convert + sort
# =====================
echo "STEP 3: BAM convert and sort"

samtools view -b ${OUT}.sam -o ${OUT}.bam
rm -f ${OUT}.sam

samtools sort ${OUT}.bam -o ${OUT}.sorted.bam
rm -f ${OUT}.bam
samtools index ${OUT}.sorted.bam

# =====================
#  Add CB and UB tags
# =====================
echo "STEP 4: Adding CB and UB tags"

# tcsh-compatible heredoc:
python3 << EOF
import pysam, re

inbam = "${OUT}.sorted.bam"
outbam = "${OUT}.sorted.tagged.bam"

pat = re.compile(r".*CB:Z:([^ ]+).*UMI:Z:([^ ]+)$")

with pysam.AlignmentFile(inbam, "rb") as inf, \
     pysam.AlignmentFile(outbam, "wb", template=inf) as outf:

    for read in inf:
        hdr = read.query_name
        m = pat.search(hdr)
        if m:
            read.set_tag("CB", m.group(1), "Z")
            read.set_tag("UB", m.group(2), "Z")
        outf.write(read)

pysam.index(outbam)
EOF

echo "STEP 5: Flagstat"

samtools flagstat ${OUT}.sorted.tagged.bam > flagStat.txt
echo "${OUT}.sorted.tagged.bam" >> flagStat.txt

echo "DONE."


