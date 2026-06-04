#!/bin/bash
#SBATCH --job-name=phyluce_counts
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=phyluce_counts.log

# ============================================================
# Script 07: Get UCE match counts (Phyluce)
# Run after 06_phyluce_mapping.sh completes.
#   sbatch 07_phyluce_get_counts.sh
#
# BEFORE RUNNING: Create taxon-set.conf listing your samples.
# See the README for the required format.
# ============================================================

# --- Edit this path to match your project location on the HPC ---
PROJDIR="/home/greta/spider_UCE_project"

PHYLDIR="$PROJDIR/Phyluce_project"

cd "$PHYLDIR"

# Activate Phyluce environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate phyluce-1.7.3

mkdir -p taxon-sets/all
mkdir -p logs

echo "=== Getting UCE match counts ==="
date

phyluce_assembly_get_match_counts \
    --locus-db matched_contigs/probe.matches.sqlite \
    --taxon-list-config taxon-set.conf \
    --taxon-group 'all' \
    --incomplete-matrix \
    --output taxon-sets/all/all-taxa-incomplete.conf

echo "=== Match counts complete ==="
date
