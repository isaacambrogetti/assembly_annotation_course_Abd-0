#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=1G
#SBATCH --time=02:00:00
#SBATCH --job-name=fastqc
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_fastqc_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_fastqc_%j.e
#SBATCH --partition=pshort_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/data"
OUTPUTDIR="$WORKDIR/output/fastqc"

if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "running..."

apptainer exec \
--bind /data \
/containers/apptainer/fastqc-0.12.1.sif \
fastqc -o $OUTPUTDIR $INPUTDIR/ERR11437323.fastq.gz $INPUTDIR/ERR754081_1.fastq.gz $INPUTDIR/ERR754081_2.fastq.gz

echo "terminating"
