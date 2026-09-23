#!/usr/bin/env bash
  
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=20GB
#SBATCH --time=00:10:00
#SBATCH --job-name=jelly_hist
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_jellyhist_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_jellyhist_%j.e
#SBATCH --partition=pshort_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/output/jellyfish"
OUTPUTDIR="$WORKDIR/output/jellyfish"

if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "running..."

apptainer exec \
--bind /data \
/containers/apptainer/jellyfish-2.2.6--0.sif \
jellyfish histo -t 10 "$INPUTDIR/ERR11437323.jf" > "$OUTPUTDIR/ERR11437323.histo"

echo "terminating"

