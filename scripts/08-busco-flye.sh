#!/usr/bin/env bash
  
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=01:59:00
#SBATCH --job-name=busco-flye
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_busco-flye_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_busco-flye_%j.e
#SBATCH --partition=pshort_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/output/flye"
OUTPUTDIR="$WORKDIR/output/busco"

if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "Working directory: $WORKDIR"
echo "Input directory: $INPUTDIR"
echo "Output directory: $OUTPUTDIR"

echo "running..."

apptainer exec \
--bind /data \
/containers/apptainer/busco_5.7.1.sif busco \
-i $INPUTDIR/assembly.fasta \
-m "genome" \
-l "brassicales_odb10" \
-c ${SLURM_CPUS_PER_TASK} \
-o flye \
--out_path $OUTPUTDIR

echo "terminating"
