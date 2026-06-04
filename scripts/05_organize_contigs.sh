#!/bin/bash

# ============================================================
# Script 05: Organize SPAdes contigs for Phyluce
# This is a short script — run it directly on the login node
# (no need to submit to SLURM):
#   bash 05_organize_contigs.sh
# ============================================================

# --- Edit this path to match your project location on the HPC ---
PROJDIR="/home/greta/spider_UCE_project"

SPADESDIR="$PROJDIR/SPAdes_results"
ASSEMBLYDIR="$PROJDIR/Phyluce_project/assemblies"

mkdir -p "$ASSEMBLYDIR"

echo "=== Organizing contigs for Phyluce ==="

for SAMPLE_DIR in "$SPADESDIR"/*_spades; do
    SAMPLE=$(basename "$SAMPLE_DIR" _spades)
    CONTIG="$SAMPLE_DIR/contigs.fasta"

    if [ -f "$CONTIG" ]; then
        cp "$CONTIG" "$ASSEMBLYDIR/${SAMPLE}.fasta"
        echo "Copied: $SAMPLE"
    else
        echo "WARNING: No contigs.fasta found for $SAMPLE"
    fi
done

echo "=== Done. Contigs are in: $ASSEMBLYDIR ==="
