#!/usr/bin/env bash
  
#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=06:00:00
#SBATCH --job-name=trinity
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_trinity_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_trinity_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/data"
OUTPUTDIR="$WORKDIR/output/trinity"

if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "loading module"

module add Trinity/2.15.1-foss-2021a

echo "module loaded"

echo "running..."

Trinity --seqType fq \
--max_memory 64G \
--left ${INPUTDIR}/ERR754081_1.fastq.gz \
--right ${INPUTDIR}/ERR754081_2.fastq.gz  \
--CPU ${SLURM_CPUS_PER_TASK} \
--output ${OUTPUTDIR}

echo "terminating"
