#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec 10 11:13:06 2025

@author: nergaon
"""

import pysam
import re

input_bam = "/gpfs0/tals/projects/Analysis/scRNA_seq/PacBio_LongReads/mapped.bam"
output_bam = "/gpfs0/tals/projects/Analysis/scRNA_seq/PacBio_LongReads/mapped.tagged.bam"

bam_in = pysam.AlignmentFile(input_bam, "rb")
bam_out = pysam.AlignmentFile(output_bam, "wb", template=bam_in)

for read in bam_in:
    # extract CB and XM from read.query_name
    m = re.search(r"_CB:Z:([A-Z0-9]+)_XM:Z:([A-Z]+)", read.query_name)
    if m:
        cb = m.group(1)
        xm = m.group(2)
        
        # remove the suffix from read name
        new_name = re.sub(r"_CB:Z:[A-Z0-9]+_XM:Z:[A-Z]+", "", read.query_name)
        read.query_name = new_name
        
        # add BAM tags
        read.set_tag("CB", cb, value_type="Z")
        read.set_tag("XM", xm, value_type="Z")
    
    bam_out.write(read)

bam_in.close()
bam_out.close()
