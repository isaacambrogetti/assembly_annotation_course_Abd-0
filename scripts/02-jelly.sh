#!/usr/bin/env bash
  
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=21GB
#SBATCH --time=02:00:00
#SBATCH --job-name=jellyfish
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_jellyfish_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_jellyfish_%j.e
#SBATCH --partition=pshort_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/data"
OUTPUTDIR="$WORKDIR/output/jellyfish"

if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "running..."

apptainer exec \
--bind /data \
/containers/apptainer/jellyfish-2.2.6--0.sif \
jellyfish count -C -m 31 -s 5G -t 4 -o $OUTPUTDIR/ERR11437323.jf <(zcat $INPUTDIR/ERR11437323.fastq.gz)

echo "terminating"
