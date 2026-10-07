 # Genome and Transcriptome Assembly and Evaluation

This repository contains the scripts and results for the genome and transcriptome assembly and evaluation practical from the Assembly Annotation Course. The workflow uses PacBio HiFi reads to assemble the genome with three assemblers, Illumina RNA-seq reads to assemble a transcriptome, and several complementary tools to assess assembly completeness, contiguity, k-mer consistency, and agreement with a reference genome.

The scripts were designed for the course HPC environment using Slurm and Apptainer. They are therefore reproducible on that environment, but are not portable without adapting the paths, container locations, and scheduler directives described below.

## Repository layout

```text
scripts/
	00-symlink_creation.sh  Link the course input data
	01-run_fastqc.sh        Read-quality assessment
	02-jelly.sh             31-mer counting
	03-jelly_hist.sh        K-mer histogram generation
	04-flye.sh              PacBio HiFi genome assembly
	05-hifiasm.sh           PacBio HiFi genome assembly
	06-lja.sh               PacBio HiFi genome assembly
	07-trinity.sh           Illumina RNA-seq transcriptome assembly
	08-11-*.sh              BUSCO evaluation
	12-quast-flye.sh        QUAST comparison of genome assemblies
	13-merqury.sh           Merqury k-mer evaluation
	14-nucmer.sh            MUMmer alignment plots
	kmer-size.md            K-mer size calculation used for Merqury

data/                     Symlinks to the course reads
output/                   Assembly and evaluation results
logs/                     Slurm stdout and stderr files
```

## Data and references

The raw data are supplied by the course and are not redistributed in this repository. The scripts expect the following files after the symlinks are created:

| File | Role |
| --- | --- |
| `ERR11437323.fastq.gz` | PacBio HiFi reads for genome assembly and k-mer analyses |
| `ERR754081_1.fastq.gz` | RNA-seq forward reads |
| `ERR754081_2.fastq.gz` | RNA-seq reverse reads |

The course reference directory is expected at `/data/courses/assembly-annotation-course/references/` and must contain:

* `Arabidopsis_thaliana.TAIR10.dna.toplevel.fa`
* `Arabidopsis_thaliana.TAIR10.57.gff3`

These reference files are used by QUAST and MUMmer. BUSCO downloads or accesses the `brassicales_odb10` lineage through the BUSCO container, depending on the course environment configuration.

## Requirements

The original workflow requires:

* A Slurm cluster with the `pibu_el8` and `pshort_el8` partitions.
* Apptainer/Singularity with access to the course containers under `/containers/apptainer/`.
* The `Trinity/2.15.1-foss-2021a` module.
* Access to `/data/courses/assembly-annotation-course/raw_data/` and the course reference directory.
* Write permission in this repository and sufficient storage for intermediate assembly files.

The container versions used by the scripts are:

| Tool | Container or module |
| --- | --- |
| FastQC | `fastqc-0.12.1.sif` |
| Jellyfish | `jellyfish-2.2.6--0.sif` |
| Flye | `flye_2.9.5.sif` |
| Hifiasm | `hifiasm_0.25.0.sif` |
| LJA | `lja-0.2.sif` |
| BUSCO | `busco_5.7.1.sif` |
| QUAST | `quast_5.2.0.sif` |
| Merqury | `merqury_1.3.sif` |
| MUMmer | `mummer4_gnuplot.sif` |
| Trinity | `Trinity/2.15.1-foss-2021a` module |

## Reproduce the workflow

Run the commands from the repository root on the course cluster. Each script contains its own Slurm resource request and writes job logs to `logs/`.

### 1. Link the input data

```bash
sbatch scripts/00-symlink_creation.sh
```

Wait for the job to finish, then confirm that `data/` contains the three expected FASTQ files. The links point to the course data and do not copy the reads into this repository.

### 2. Inspect the reads and k-mer spectrum

```bash
sbatch scripts/01-run_fastqc.sh
sbatch scripts/02-jelly.sh
sbatch scripts/03-jelly_hist.sh
```

FastQC reports are written to `output/fastqc/`. Jellyfish writes the k-mer database and histogram to `output/jellyfish/`.

The genome size estimate used for selecting the Merqury k-mer size was `130400000` bp. The calculation in [scripts/kmer-size.md](scripts/kmer-size.md) gives approximately `18.46`, rounded to `k=19`.

### 3. Assemble the genome and transcriptome

```bash
sbatch scripts/04-flye.sh
sbatch scripts/05-hifiasm.sh
sbatch scripts/06-lja.sh
sbatch scripts/07-trinity.sh
```

The assembly jobs can run independently after the input links exist. Their main outputs are:

* Flye: `output/flye/assembly.fasta`
* Hifiasm: `output/hifiasm/ERR11437323.fa`
* LJA: `output/lja/ERR11437323.fa/assembly.fasta`
* Trinity: `output/trinity/trinity.Trinity.fasta`

Hifiasm produces a GFA graph and the script converts the primary contigs from `ERR11437323.bp.p_ctg.gfa` into FASTA with `awk`.

### 4. Evaluate completeness with BUSCO

Submit these after the corresponding assembly files exist:

```bash
sbatch scripts/08-busco-flye.sh
sbatch scripts/09-busco-hifiasm.sh
sbatch scripts/10-busco-lja.sh
sbatch scripts/11-busco-trinity.sh
```

Genome assemblies are evaluated with `-m genome`; the Trinity transcriptome is evaluated with `-m transcriptome`. All four jobs use the `brassicales_odb10` lineage and write results under `output/busco/`.

### 5. Compare genome assemblies

QUAST compares Flye, Hifiasm, and LJA both without and with the Arabidopsis reference:

```bash
sbatch scripts/12-quast-flye.sh
```

Results are written to `output/quast/no_ref/` and `output/quast/with_ref/`.

Merqury evaluates k-mer completeness and consensus quality using a k=19 Meryl database made from the PacBio reads:

```bash
sbatch scripts/13-merqury.sh
```

Results are organized into `output/merqury/flye/`, `output/merqury/hifiasm/`, and `output/merqury/lja/`.

Finally, MUMmer/Nucmer produces filtered alignments and PNG dot plots for each assembly against the reference and for each pair of assemblies:

```bash
sbatch scripts/14-nucmer.sh
```

The plots and alignment files are written to `output/mummer/`.

## Reproducibility notes

* Submit dependent jobs only after their input files exist. For a production rerun, Slurm job dependencies such as `sbatch --dependency=afterok:<jobid>` can enforce this order.
* The scripts use absolute paths beginning with `/data/users/iambrogetti/assembly_annotation_course_Abd-0`. If the repository is moved, update `WORKDIR` and the Slurm log paths in the scripts.
* The scripts bind `/data` into each Apptainer container. On another system, replace this with the appropriate bind path and container locations.
* Slurm resource requests, module versions, container versions, reference assemblies, and the exact input files should be recorded when reproducing results on a different cluster.