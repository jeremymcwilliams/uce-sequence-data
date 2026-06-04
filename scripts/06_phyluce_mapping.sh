#!/bin/bash
#SBATCH --job-name=phyluce_mapping
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=phyluce_mapping.log

# ============================================================
# Script 06: Match contigs to UCE probes (Phyluce)
# Run after 05_organize_contigs.sh completes.
#   sbatch 06_phyluce_mapping.sh
#
# BEFORE RUNNING: Make sure the spider probe file is in place:
#   Phyluce_project/probes/RTA-v3-probe-combine-spider-color-DUPE-SCREENED.fasta
# ============================================================

# --- Edit this path to match your project location on the HPC ---
PROJDIR="/home/greta/spider_UCE_project"

PHYLDIR="$PROJDIR/Phyluce_project"

cd "$PHYLDIR"

# Activate Phyluce environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate phyluce-1.7.3

mkdir -p logs

echo "=== Starting Phyluce contig-to-probe mapping ==="
date

phyluce_assembly_match_contigs_to_probes \
    --contigs assemblies/ \
    --probes probes/RTA-v3-probe-combine-spider-color-DUPE-SCREENED.fasta \
    --output matched_contigs/ \
    --log-path logs/ \
    --min-coverage 80 \
    --min-identity 80 \
    --regex "^(uce-\d+)_p\d+"

echo "=== Phyluce mapping complete ==="
date
