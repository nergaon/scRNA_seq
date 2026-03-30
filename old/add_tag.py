#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov 30 16:13:54 2025

@author: nergaon
"""

import pysam
import re
import sys

input_bam = sys.argv[1]
output_bam = sys.argv[2]

# Example read name format:
# @SRR29608249.1_CNCCAGTTTCAGAGAC_ACTCAGGTAGAG ...

pattern = re.compile(r"^[^_]+_([ACGTN]+)_([ACGTN]+)")

bam_in = pysam.AlignmentFile(input_bam, "rb")
bam_out = pysam.AlignmentFile(output_bam, "wb", template=bam_in)

for read in bam_in.fetch(until_eof=True):
    m = pattern.match(read.query_name)
    if m:
        CB = m.group(1)
        UMI = m.group(2)

        read.set_tag("CB", CB, value_type='Z')
        read.set_tag("UB", UMI, value_type='Z')

    bam_out.write(read)

bam_in.close()
bam_out.close()
