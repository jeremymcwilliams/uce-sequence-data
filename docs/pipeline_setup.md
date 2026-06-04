# Pipeline Setup

These scripts run the full UCE phylogenomics pipeline on your HPC, adapted from the
"Introduction to the analysis of UCEs V1" guide (originally written for PBS/Torque) to SLURM.

48 samples, named by specimen code (e.g. Hoorlog, Lrusselli, etc.)

---

## Before You Start

**1. Edit `PROJDIR`** in each script to match your actual home/scratch directory on the HPC:

```bash
PROJDIR="/home/binford/spider_UCE_project"
```

**2. Set up the project directory structure:**

```
spider_UCE_project/
├── Combined_Fastqs/        ← transfer your 96 .fastq.gz files here
├── adapters/
│   └── adaptersfasta.fa    ← create this (see below)
├── Phyluce_project/
│   ├── probes/
│   │   └── RTA-v3-probe-combine-spider-color-DUPE-SCREENED.fasta
│   └── taxon-set.conf      ← create this (see below)
```

**3. Create the adapter file.** Confirm adapter sequences with RAPiD Genomics, then create `adapters/adaptersfasta.fa`:

```
>TruSeq_i7
GATCGGAAGAGCACACGTCTGAACTCCAGTCAC
>TruSeq_i5
AATGATACGGCGACCACCGAGATCTACAC
```

**4. Copy the spider UCE probe file** into `Phyluce_project/probes/`. The probe file is included in this repository under `probes/`:

```
RTA-v3-probe-combine-spider-color-DUPE-SCREENED.fasta
```

> This probe file was downloaded from Dryad: https://datadryad.org/dataset/doi:10.5061/dryad.xksn02vkj

**5. Create `taxon-set.conf`** in `Phyluce_project/`. This file lists all 48 specimen names:

```
[all]
Hoorlog
HGob
Hruac
HDanVil2
HWund
HMunst
HUisib
HBrand
SYura
SOlmos
SManc
SArroy
Stoto
SOcotal
SPV
Lmunst
Lgroot
LUisib
Lhooen
LruAsni
LfSequeya
LfKoumb
LGbako
Lhehuanc
LAtiqHol
LStaMaria
LJuliaca
LMuyo
LPalca
LQuito
LPucara
Lhuacarp
LTingoM2
LAcamay
LcaribCC
LtainoVV
LspCAK2
LpanBCI
LrufPV
LLBcave
LJinotec
LazTuc
Lrusselli
Ldeserta
Lpalma
Lsabina
Lblanda2
Lkaiba
```

---

## Running the Pipeline

Run scripts in order — each depends on the previous completing successfully.

| Order | Command | Notes |
|-------|---------|-------|
| 1 | `sbatch 01_fastqc_raw.sh` | |
| 2 | `sbatch 02_trimmomatic.sh` | |
| 3 | `sbatch 03_fastqc_trimmed.sh` | after 02 completes |
| 4 | `sbatch 04_spades.sh` | after 02 completes — slow (~hours) |
| 5 | `bash 05_organize_contigs.sh` | after 04 completes — run directly, no SLURM needed |
| 6 | `sbatch 06_phyluce_mapping.sh` | after 05 completes |
| 7 | `sbatch 07_phyluce_get_counts.sh` | after 06 completes |
| 8 | `sbatch 08_phyluce_get_fastas.sh` | after 07 completes |
| 9 | `sbatch 09_fuse.sh` | after 08 completes — slow |

Monitor jobs:

```bash
squeue -u your_username
```

View logs in real time:

```bash
tail -f jobname.log
```

---

## After Script 08 — Mesquite Option

If you prefer to use Mesquite instead of FUSe (script 09):

1. Transfer the `exploded-fastas/` folder from the HPC to your local machine
2. Follow Practices 5.1–5.6 in the PDF guide using Mesquite
