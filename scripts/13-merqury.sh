#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=02:00:00
#SBATCH --job-name=merq-gen
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=BEGIN,END
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_merqury-genomes_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_merqury-genomes_%j.e
#SBATCH --partition=pshort_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/output"
OUTPUTDIR="$WORKDIR/output/merqury"
REFDIR="/data/courses/assembly-annotation-course/references"

if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir "$OUTPUTDIR"
fi

echo "Working directory: $WORKDIR"
echo "Input directory: $INPUTDIR"
echo "Output directory: $OUTPUTDIR"

# add MERQURY as a path variable in the script
export MERQURY="/usr/local/share/merqury"

if [[ ! -d "$OUTPUTDIR/reads.k19.meryl" ]]; then
  echo "Creating Meryl k=19 database"

  apptainer exec \
  --bind /data \
  /containers/apptainer/merqury_1.3.sif \
  meryl k=19 count \
  "$WORKDIR/data/ERR11437323.fastq.gz" \
  output "$OUTPUTDIR/reads.k19.meryl"
else
  echo "Using existing database: $OUTPUTDIR/reads.k19.meryl"
fi

mkdir -pv "$OUTPUTDIR/flye"
mkdir -pv "$OUTPUTDIR/hifiasm"
mkdir -pv "$OUTPUTDIR/lja"

# Run merqury on each assembly
apptainer exec \
--bind /data \
/containers/apptainer/merqury_1.3.sif \
sh -c '
cd "$1"
export MERQURY=/usr/local/share/merqury
sh "$MERQURY/merqury.sh" \
"$2/reads.k19.meryl" \
"$3" \
flye_merqury
' sh "$OUTPUTDIR/flye" "$OUTPUTDIR" "$INPUTDIR/flye/assembly.fasta"


apptainer exec \
--bind /data \
/containers/apptainer/merqury_1.3.sif \
sh -c '
cd "$1"
export MERQURY=/usr/local/share/merqury
sh "$MERQURY/merqury.sh" \
"$2/reads.k19.meryl" \
"$3" \
hifiasm_merqury
' sh "$OUTPUTDIR/hifiasm" "$OUTPUTDIR" "$INPUTDIR/hifiasm/ERR11437323.fa"


apptainer exec \
--bind /data \
/containers/apptainer/merqury_1.3.sif \
sh -c '
cd "$1"
export MERQURY=/usr/local/share/merqury
sh "$MERQURY/merqury.sh" \
"$2/reads.k19.meryl" \
"$3" \
lja_merqury
' sh "$OUTPUTDIR/lja" "$OUTPUTDIR" "$INPUTDIR/lja/ERR11437323.fa/assembly.fasta"