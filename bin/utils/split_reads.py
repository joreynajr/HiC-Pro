#! /usr/bin/env python

import argparse
import os
import subprocess
import sys
from glob import glob
import shutil
import re

parser = argparse.ArgumentParser()
parser.add_argument("filename")
parser.add_argument("--results_folder", "-r", default="./")
parser.add_argument("--nreads", "-n", default=20000000)
args = parser.parse_args()

filename = args.filename
nlines = int(args.nreads)*4
out = args.results_folder
try:
    os.makedirs(out)
except OSError:
    pass


if filename.endswith('.gz'):
    prefix = re.sub('((.fastq)|(.fq)).gz','_part', os.path.join(out, os.path.basename(filename)))
    cmd = "zcat {} | split -l {} -d - {}".format(
        filename, nlines, prefix)
else:
    prefix = re.sub('(.fastq)|(.fq)','_part', os.path.join(out, os.path.basename(filename)))
    cmd = "split -l {} -d {} {}".format(
        nlines, filename, prefix)

retcode = subprocess.call(cmd, shell=True)
if retcode != 0:
    print("split file failed with return code {}".format(retcode))
    sys.exit(1)

files = glob(os.path.join(prefix + "*"))
files.sort()

for ifile in files:

    # splitting on _part to get the main section of the
    # name and the split
    main, split = os.path.basename(ifile).split('_part')

    # constructing the file name
    new_base = '{}_{}.fastq'.format(split, main)
    new_file = os.path.join(os.path.dirname(ifile), new_base)

    # update the ifile name
    shutil.move(ifile, new_file)
