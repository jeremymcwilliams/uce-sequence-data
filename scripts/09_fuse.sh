#!/bin/bash
#SBATCH --job-name=fuse
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=fuse.log

# ============================================================
# Script 09: Align, trim, and filter UCEs with FUSe
# Run after 08_phyluce_get_fastas.sh completes.
#   sbatch 09_fuse.sh
#
# This is the command-line alternative to Mesquite (Practice 6).
# FUSe must be installed in your Phyluce environment first.
# ============================================================

# --- Edit this path to match your project location on the HPC ---
PROJDIR="/home/greta/spider_UCE_project"

PHYLDIR="$PROJDIR/Phyluce_project"

# Path to FUSe.py should be similar to below, but a different home directory
FUSEPY="/home/jeremym/miniconda3/envs/phyluce-1.7.3/bin/FUSe.py"

cd "$PHYLDIR"

# Activate Phyluce environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate phyluce-1.7.3

echo "=== Starting FUSe ==="
date

python "$FUSEPY" \
    -i taxon-sets/all/all-taxa-incomplete.fasta \
    -t 48 \
    -p Greta_spiders \
    -o fasta \
    -c 8 \
    --gblocks \
    --b1 0.5 --b2 0.5 --b3 10 --b4 5 \
    --remove-short -s 0.5 \
    --remove-div -d 0.2 \
    --filter-alignments -l 200 -m 4 \
    --get-completeness -e 0.8 \
    --taxa-count

echo "=== FUSe complete ==="
date
