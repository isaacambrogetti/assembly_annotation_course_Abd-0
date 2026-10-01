#!/usr/bin/env bash
  
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=02:00:00
#SBATCH --job-name=hifiasm
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_hifiasm_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_hifiasm_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/data"
OUTPUTDIR="$WORKDIR/output/hifiasm"

if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "running..."

apptainer exec \
--bind /data \
/containers/apptainer/hifiasm_0.25.0.sif \
hifiasm -o $OUTPUTDIR/ERR11437323 \
-t${SLURM_CPUS_PER_TASK} \
$INPUTDIR/ERR11437323.fastq.gz

echo "terminating hifiasm"

awk '/^S/{print ">"$2;print $3}' $OUTPUTDIR/ERR11437323.bp.p_ctg.gfa > $OUTPUTDIR/ERR11437323.fa

echo "terminating awk"
