#!/bin/bash
#SBATCH --job-name=spades
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=100G
#SBATCH --time=24:00:00
#SBATCH --output=spades.log

# ============================================================
# Script 04: SPAdes de novo assembly for all 48 samples
# Run after 02_trimmomatic.sh completes.
#   sbatch 04_spades.sh
#
# NOTE: SPAdes is memory-intensive. Each sample may use up to
# 100GB RAM. This script runs samples sequentially; if your
# HPC allows multiple jobs, consider splitting into batches.
# ============================================================

# --- Edit this path to match your project location on the HPC ---
PROJDIR="/home/greta/spider_UCE_project"

TRIMDIR="$PROJDIR/Trimmomatic"
OUTDIR="$PROJDIR/SPAdes_results"

mkdir -p "$OUTDIR"

# Load SPAdes from PATH (installed manually in home directory)
export PATH=~/SPAdes-4.2.0-Linux/bin:$PATH

echo "=== Starting SPAdes assemblies ==="
date

for R1 in "$TRIMDIR"/*_R1_paired.fq.gz; do
    SAMPLE=$(basename "$R1" _R1_paired.fq.gz)
    R2="${TRIMDIR}/${SAMPLE}_R2_paired.fq.gz"
    SAMPLE_OUT="$OUTDIR/${SAMPLE}_spades"

    echo "==============================="
    echo "Assembling $SAMPLE ..."
    echo "==============================="

    mkdir -p "$SAMPLE_OUT"

    spades.py \
        -1 "$R1" \
        -2 "$R2" \
        -o "$SAMPLE_OUT" \
        --isolate \
        -t 16 \
        -m 100

    echo "Assembly complete: $SAMPLE"
    echo ""
done

echo "=== All SPAdes assemblies complete ==="
date
