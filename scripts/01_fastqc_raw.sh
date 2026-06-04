#!/bin/bash
#SBATCH --job-name=fastqc_raw
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=50G
#SBATCH --time=04:00:00
#SBATCH --output=fastqc_raw.log

# ============================================================
# Script 01: FastQC on raw combined FASTQ files
# Run from your project directory, e.g.:
#   sbatch 01_fastqc_raw.sh
# ============================================================

# --- Edit this path to match your project location on the HPC ---
PROJDIR="/home/greta/spider_UCE_project"

RAWDIR="$PROJDIR/Combined_Fastqs"
OUTDIR="$PROJDIR/FastQC_raw"

mkdir -p "$OUTDIR"

# Activate Bioinfo conda environment (contains FastQC)
source ~/miniconda3/etc/profile.d/conda.sh
conda activate Bioinfo

cd "$RAWDIR"

echo "=== Starting FastQC on raw reads ==="
date

fastqc --nogroup -t 10 -o "$OUTDIR" *.fastq.gz

echo "=== FastQC complete ==="
date
