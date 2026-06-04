#!/bin/bash
#SBATCH --job-name=trimmomatic
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --time=12:00:00
#SBATCH --output=trimmomatic.log

# ============================================================
# Script 02: Trimmomatic on all 48 samples
# Loops automatically over all *_R1.fastq.gz files.
# Run from your project directory:
#   sbatch 02_trimmomatic.sh
# ============================================================

# --- Edit this path to match your project location on the HPC ---
PROJDIR="/home/greta/spider_UCE_project"

# --- Raw reads may live in a shared folder outside your project directory ---
RAWDIR="/home/labs/binford/data-june2026/raw_reads_combined"
OUTDIR="$PROJDIR/Trimmomatic"
ADAPTERS="$PROJDIR/adapters/adaptersfasta.fa"

# NOTE: Create adaptersfasta.fa in your adapters/ folder before running.
# Contents should be (confirm adapter sequences with RAPiD Genomics):
#   >TruSeq_i7
#   GATCGGAAGAGCACACGTCTGAACTCCAGTCAC
#   >TruSeq_i5
#   AATGATACGGCGACCACCGAGATCTACAC

mkdir -p "$OUTDIR"

# Activate Bioinfo conda environment (contains Trimmomatic)
source ~/miniconda3/etc/profile.d/conda.sh
conda activate Bioinfo

threads=10

# Give Java more heap space to prevent OutOfMemoryError on large samples
export _JAVA_OPTIONS="-Xmx16g"

echo "=== Starting Trimmomatic ==="
date

for R1 in "$RAWDIR"/*_R1.fastq.gz; do
    # Extract sample name (e.g. Hoorlog from Hoorlog_R1.fastq.gz)
    SAMPLE=$(basename "$R1" _R1.fastq.gz)
    R2="${RAWDIR}/${SAMPLE}_R2.fastq.gz"

    echo "--- Processing $SAMPLE ---"

    trimmomatic PE -threads $threads \
        "$R1" "$R2" \
        "$OUTDIR/${SAMPLE}_R1_paired.fq.gz"   "$OUTDIR/${SAMPLE}_R1_unpaired.fq.gz" \
        "$OUTDIR/${SAMPLE}_R2_paired.fq.gz"   "$OUTDIR/${SAMPLE}_R2_unpaired.fq.gz" \
        ILLUMINACLIP:${ADAPTERS}:2:30:10:2:keepBothReads \
        LEADING:5 TRAILING:15 SLIDINGWINDOW:4:15 MINLEN:40

    echo "Done: $SAMPLE"
done

echo "=== Trimmomatic complete ==="
date
