# HPC Environment Setup

This document describes how to set up the bioinformatics software environment on the HPC for the UCE pipeline. Installation is done on a **per-user basis** — each user installs Miniconda and creates their own conda environments in their home directory.

---

## 1. Install Miniconda

From your home directory:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

Follow the prompts. When asked whether to initialize conda, say **yes**.

Then reload your shell and disable auto-activation of the base environment:

```bash
source ~/.bashrc
conda config --set auto_activate_base false
```

Clean up the installer:

```bash
rm Miniconda3-latest-Linux-x86_64.sh
```

Accept the conda terms of service:

```bash
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
```

---

## 2. Create the Bioinfo Environment

This environment contains FastQC and Trimmomatic.

```bash
conda create -n Bioinfo -y
conda activate Bioinfo
```

Your shell prompt will now be preceded by `(Bioinfo)`.

Install tools:

```bash
conda install -c bioconda trimmomatic spades fastqc -y
```

Verify installations:

```bash
spades.py --version
trimmomatic -version
```

---

## 3. Install SPAdes (newer version)

The version of SPAdes available via Bioconda is outdated, so we install a newer version manually. The binary is installed outside of conda and added to PATH.

```bash
wget https://github.com/ablab/spades/releases/download/v4.2.0/SPAdes-4.2.0-Linux.tar.gz
tar -xzf SPAdes-4.2.0-Linux.tar.gz
echo 'export PATH=~/SPAdes-4.2.0-Linux/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

Clean up:

```bash
rm SPAdes-4.2.0-Linux.tar.gz
```

Deactivate the Bioinfo environment before proceeding:

```bash
conda deactivate
```

---

## 4. Install Phyluce

Download the Phyluce 1.7.3 environment file and create a new conda environment from it. This step can take a while.

```bash
wget https://raw.githubusercontent.com/faircloth-lab/phyluce/v1.7.3/distrib/phyluce-1.7.3-py36-Linux-conda.yml
conda env create -n phyluce-1.7.3 --file phyluce-1.7.3-py36-Linux-conda.yml
```

> **Note:** If you get a `sqlite3.OperationalError: database is locked` error, try:
> ```bash
> rm -f ~/miniconda3/pkgs/cache/*.db
> ```
> Then re-run the `conda env create` command.

Activate the Phyluce environment:

```bash
conda activate phyluce-1.7.3
```

---

## 5. Install FUSe

FUSe must be installed while the `phyluce-1.7.3` environment is active.

From your home directory:

```bash
cd ~
wget -O FUSe.zip https://github.com/rmonjaraz/FUSe/archive/refs/heads/main.zip
unzip FUSe.zip
```

Verify the file is where expected:

```bash
ls ~/FUSe-main/FUSe/FUSe.py
```

Copy FUSe into the Phyluce environment's bin folder and make it executable:

```bash
cp ~/FUSe-main/FUSe/FUSe.py ~/miniconda3/envs/phyluce-1.7.3/bin/
chmod 775 ~/miniconda3/envs/phyluce-1.7.3/bin/FUSe.py
```

---

## Summary

After completing the above steps, you should have:

| Environment | Tools |
|-------------|-------|
| `Bioinfo` | FastQC, Trimmomatic |
| `phyluce-1.7.3` | Phyluce 1.7.3, FUSe |
| PATH | SPAdes 4.2.0 |
