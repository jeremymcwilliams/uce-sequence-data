# Understanding the UCE Pipeline

This document explains what each step of the pipeline does and why it is necessary.
It is written for students who are new to bioinformatics and genomic data analysis.

---

## Background: What are UCEs and why do we sequence them?

**Ultraconserved Elements (UCEs)** are regions of DNA that are nearly identical across
a wide range of animal species — including very distantly related ones. Because they are
so similar across species, they are useful landmarks that can be found and compared
across many different organisms.

By sequencing UCEs from many different spider specimens and comparing them, we can
build a **phylogenetic tree** — essentially a family tree that shows how the species are
related to each other and how they evolved over time.

The raw data we start with are **FASTQ files** — these are the direct output from the
sequencing machine. Each file contains millions of short DNA sequences (called **reads**),
along with a quality score for each base that tells us how confident the sequencing
machine was when it read that letter.

---

## Step 1: Quality Check on Raw Reads (FastQC)

**Script:** `01_fastqc_raw.sh`
**Tool:** FastQC

### What it does
FastQC reads through all of the raw FASTQ files and generates a report for each one.
The report includes statistics such as:
- Average quality scores across the length of the reads
- Whether adapter sequences are present
- GC content (the proportion of G and C bases)
- Whether there are any overrepresented sequences

### Why we do it
Before doing anything else with the data, we need to know whether the sequencing
worked well. The FastQC report tells us if there are any obvious problems — for example,
if quality drops off sharply at the ends of reads, or if adapter sequences are contaminating
the data. This helps us decide how aggressively to clean the data in the next step.

### Output
A `.html` report file for each FASTQ file, which can be opened in a web browser.

---

## Step 2: Trimming and Cleaning the Reads (Trimmomatic)

**Script:** `02_trimmomatic.sh`
**Tool:** Trimmomatic

### What it does
Trimmomatic processes each pair of raw read files (R1 and R2) and:
- **Removes adapter sequences** — short synthetic DNA sequences that were added
  during library preparation and are not part of the spider's genome
- **Trims low-quality bases** from the ends of reads
- **Discards reads that are too short** after trimming (less than 40 bases)

For each sample, Trimmomatic produces four output files:
- `_R1_paired.fq.gz` — forward reads that still have a matching reverse read
- `_R2_paired.fq.gz` — reverse reads that still have a matching forward read
- `_R1_unpaired.fq.gz` — forward reads whose reverse partner was discarded
- `_R2_unpaired.fq.gz` — reverse reads whose forward partner was discarded

The **paired** files are what we use going forward.

### Why we do it
Raw sequencing data is never perfect. Adapter sequences can interfere with downstream
analysis, and low-quality bases can introduce errors into the assembled genome. Cleaning
the data at this stage improves the quality of everything that follows.

### Output
Four `.fq.gz` files per sample (96 paired files total across 48 samples).

---

## Step 3: Quality Check on Trimmed Reads (FastQC again)

**Script:** `03_fastqc_trimmed.sh`
**Tool:** FastQC

### What it does
Runs FastQC again, this time on the trimmed (cleaned) paired read files.

### Why we do it
We want to confirm that trimming actually improved the data quality and that the adapter
sequences have been removed. Comparing the before and after FastQC reports is a good
way to verify that the cleaning step worked as expected.

### Output
A new set of `.html` report files for the trimmed reads.

---

## Step 4: De Novo Genome Assembly (SPAdes)

**Script:** `04_spades.sh`
**Tool:** SPAdes

### What it does
SPAdes takes the cleaned paired reads for each sample and assembles them into longer
sequences called **contigs** (short for "contiguous sequences"). It does this by finding
reads that overlap with each other and joining them together, like fitting puzzle pieces
together to reconstruct a larger picture.

This is called **de novo assembly** because it builds the sequences from scratch,
without using a reference genome as a guide. This is necessary for spiders because
most species do not have a published reference genome.

The key output file for each sample is `contigs.fasta` — a FASTA format file containing
all the assembled contigs.

### Why we do it
The reads coming off the sequencing machine are only about 150 bases long. UCE loci
are much longer than that. By assembling overlapping reads into contigs, we reconstruct
longer, more complete sequences that can then be matched to UCE probes in the next step.

### Output
A folder for each sample (e.g. `Hoorlog_spades/`) containing `contigs.fasta` and
other assembly files.

---

## Step 5: Organize Contigs for Phyluce

**Script:** `05_organize_contigs.sh`

### What it does
This is a simple housekeeping step. SPAdes names every output file `contigs.fasta`
regardless of the sample, so after running 48 assemblies we have 48 files all with the
same name in different folders. This script:
- Copies each `contigs.fasta` file into a single `assemblies/` folder
- Renames each file after its sample (e.g. `Hoorlog.fasta`)

### Why we do it
Phyluce (the next tool) expects all contig files to be in one folder with unique names.
This step sets up that structure.

### Output
A folder called `assemblies/` containing 48 uniquely named `.fasta` files.

---

## Step 6: Match Contigs to UCE Probes (Phyluce)

**Script:** `06_phyluce_mapping.sh`
**Tool:** Phyluce

### What it does
This step compares each sample's assembled contigs against a set of **UCE probes** —
short DNA sequences that were specifically designed to match UCE loci in spiders. The
probe file used here (`RTA-v3-probe-combine-spider-color-DUPE-SCREENED.fasta`) was
developed for arachnids and downloaded from Dryad
(https://datadryad.org/dataset/doi:10.5061/dryad.xksn02vkj).

Phyluce uses a sequence alignment tool called LASTZ to find contigs that match the
probes with at least 80% coverage and 80% identity.

### Why we do it
After assembly, each sample has thousands of contigs representing many different parts
of the genome — most of which are not UCEs. This step acts as a filter, identifying only
the contigs that correspond to known UCE loci. It also creates a database that records
which UCEs were found in which samples.

### Output
A folder called `matched_contigs/` containing alignment files (`.lastz`) for each sample,
and a database file (`probe.matches.sqlite`) that records all the matches.

---

## Step 7: Count UCE Loci per Sample (Phyluce)

**Script:** `07_phyluce_get_counts.sh`
**Tool:** Phyluce

### What it does
This step reads the database created in Step 6 and counts which UCE loci were
successfully found in which samples. It uses a configuration file (`taxon-set.conf`)
that lists all the specimen names, and produces a summary file
(`all-taxa-incomplete.conf`) that records the presence or absence of each UCE locus
across all samples.

The `--incomplete-matrix` flag means we include loci even if they weren't found in
every single sample — which is normal and expected in real datasets.

### Why we do it
Not every UCE locus will be recovered from every sample — some may have assembled
poorly or been missed by the probes. This step tallies up what we have so that the
next step knows exactly which sequences to extract for each sample.

### Output
A file called `all-taxa-incomplete.conf` listing the UCE loci present in each sample.

---

## Step 8: Extract UCE Sequences (Phyluce)

**Script:** `08_phyluce_get_fastas.sh`
**Tool:** Phyluce

### What it does
Using the summary from Step 7, Phyluce goes back to the assembled contigs and
extracts the actual DNA sequences for each UCE locus from each sample. It combines
all of these into a single large file called a **monolithic FASTA** file
(`all-taxa-incomplete.fasta`), where each sequence is labelled with both the sample
name and the UCE locus name.

It then **explodes** this monolithic file — splitting it back apart into individual files,
one per sample, each containing all the UCE sequences found for that specimen.

### Why we do it
This step produces the actual sequence data that will be used for phylogenetic analysis.
The exploded per-sample files are the input for alignment in the next step.

### Output
- `all-taxa-incomplete.fasta` — all UCE sequences for all samples in one file
- `exploded-fastas/` — one `.fasta` file per sample

---

## Step 9: Align, Trim, and Filter (FUSe)

**Script:** `09_fuse.sh`
**Tool:** FUSe (running inside the Phyluce environment)

### What it does
FUSe is an automated workflow that takes the extracted UCE sequences and prepares
them for phylogenetic analysis through three stages:

1. **Alignment** — For each UCE locus, the sequences from all samples are aligned
   against each other using a tool called MAFFT. Alignment lines up the sequences so
   that corresponding positions across different species are in the same column —
   this is essential for comparing them.

2. **Trimming** — Poorly aligned regions and excessive gaps are removed using
   Gblocks. These regions are unreliable and can introduce noise into the phylogenetic
   analysis.

3. **Filtering** — Sequences or entire loci that don't meet quality thresholds are
   removed. For example, sequences that are too short or too different from the others
   are discarded. Loci that are present in too few samples are also removed.

### Why we do it
Before we can build a phylogenetic tree, all the sequences need to be aligned — you
can only compare positions that are homologous (i.e., descended from the same
position in a common ancestor). Trimming and filtering ensures that only reliable,
informative data goes into the final analysis.

### Output
A set of cleaned, aligned FASTA files ready for phylogenetic tree building.

---

## What Comes Next?

After Step 9, you have a clean set of aligned UCE sequences. The next step —
not covered in these scripts — is **phylogenetic tree reconstruction**, which uses
tools like RAxML or IQ-TREE to infer the evolutionary relationships among the
spider specimens based on their UCE sequences.

Alternatively, Steps 8 and 9 can be done using a graphical program called **Mesquite**
on your local computer, which allows you to visually inspect and interact with the
alignments. See `docs/pipeline_setup.md` for details on the Mesquite option.
