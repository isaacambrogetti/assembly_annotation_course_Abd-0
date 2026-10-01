#!/usr/bin/env bash
  
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=1-00:00:00
#SBATCH --job-name=flye
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_flye_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_flye_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/data"
OUTPUTDIR="$WORKDIR/output/flye"

if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "running..."

apptainer exec \
--bind /data \
/containers/apptainer/flye_2.9.5.sif \
flye --pacbio-hifi $INPUTDIR/ERR11437323.fastq.gz \
--out-dir $OUTPUTDIR \
--threads ${SLURM_CPUS_PER_TASK} 

echo "terminating"

