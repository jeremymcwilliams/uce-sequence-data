#!/bin/bash
#SBATCH --job-name=fastqc_trimmed
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=50G
#SBATCH --time=04:00:00
#SBATCH --output=fastqc_trimmed.log

# ============================================================
# Script 03: FastQC on trimmed (paired) reads
# Run after 02_trimmomatic.sh completes.
#   sbatch 03_fastqc_trimmed.sh
# ============================================================

# --- Edit this path to match your project location on the HPC ---
PROJDIR="/home/greta/spider_UCE_project"

TRIMDIR="$PROJDIR/Trimmomatic"
OUTDIR="$PROJDIR/FastQC_trimmed"

mkdir -p "$OUTDIR"

# Activate Bioinfo conda environment (contains FastQC)
source ~/miniconda3/etc/profile.d/conda.sh
conda activate Bioinfo

echo "=== Starting FastQC on trimmed reads ==="
date

fastqc --nogroup -t 10 -o "$OUTDIR" "$TRIMDIR"/*_paired.fq.gz

echo "=== FastQC complete ==="
date
