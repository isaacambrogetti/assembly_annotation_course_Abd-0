#!/usr/bin/env bash
  
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=1-00:00:00
#SBATCH --job-name=lja
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_lja_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_lja_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/data"
OUTPUTDIR="$WORKDIR/output/lja"

if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "running..."

apptainer exec \
--bind /data \
/containers/apptainer/lja-0.2.sif \
lja -o $OUTPUTDIR/ERR11437323.fa \
-t ${SLURM_CPUS_PER_TASK} \
--reads $INPUTDIR/ERR11437323.fastq.gz \
--diploid

echo "terminating"





