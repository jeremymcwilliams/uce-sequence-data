#!/bin/bash
#SBATCH --job-name=phyluce_fastas
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=phyluce_fastas.log

# ============================================================
# Script 08: Extract UCE sequences (Phyluce)
# Run after 07_phyluce_get_counts.sh completes.
#   sbatch 08_phyluce_get_fastas.sh
# ============================================================

# --- Edit this path to match your project location on the HPC ---
PROJDIR="/home/greta/spider_UCE_project"

PHYLDIR="$PROJDIR/Phyluce_project"

# Must run from taxon-sets/all as the guide specifies
cd "$PHYLDIR/taxon-sets/all"

# Activate Phyluce environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate phyluce-1.7.3

mkdir -p log

echo "=== Extracting UCE sequences ==="
date

phyluce_assembly_get_fastas_from_match_counts \
    --contigs ../../assemblies \
    --locus-db ../../matched_contigs/probe.matches.sqlite \
    --match-count-output all-taxa-incomplete.conf \
    --output all-taxa-incomplete.fasta \
    --incomplete-matrix all-taxa-incomplete.incomplete \
    --log-path log

echo "=== Exploding monolithic FASTA by taxon ==="

phyluce_assembly_explode_get_fastas_file \
    --input all-taxa-incomplete.fasta \
    --output exploded-fastas \
    --by-taxon

echo "=== UCE extraction complete ==="
date
