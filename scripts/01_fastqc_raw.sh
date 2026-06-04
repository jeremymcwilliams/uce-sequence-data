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
PROJDIR="/home/jeremym/gb-test-0626"

# --- the raw reads data may live in a shared folder, and not in your project directory ----#
RAWDIR="/home/labs/binford/data-june2026/raw_reads_combined"
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
