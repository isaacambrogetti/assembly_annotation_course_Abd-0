#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=02:00:00
#SBATCH --job-name=quast-gen
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_quast-genomes_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_quast-genomes_%j.e
#SBATCH --partition=pshort_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/output"
OUTPUTDIR="$WORKDIR/output/quast"
REFDIR="/data/courses/assembly-annotation-course/references"

  
if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "Working directory: $WORKDIR"
echo "Input directory: $INPUTDIR"
echo "Output directory: $OUTPUTDIR"
echo "Reference file directory: $REFDIR"

echo "running without reference"

apptainer exec \
--bind /data \
/containers/apptainer/quast_5.2.0.sif quast.py \
$INPUTDIR/flye/assembly.fasta \
$INPUTDIR/hifiasm/ERR11437323.fa \
$INPUTDIR/lja/ERR11437323.fa/assembly.fasta \
--labels "flye,hifiasm,LJA" \
--eukaryote \
--est-ref-size 129300000 \
--threads 16 \
-o $OUTPUTDIR/no_ref


echo "without reference finished"
echo "starting with reference"

apptainer exec \
--bind /data \
/containers/apptainer/quast_5.2.0.sif quast.py \
$INPUTDIR/flye/assembly.fasta  \
$INPUTDIR/hifiasm/ERR11437323.fa  \
$INPUTDIR/lja/ERR11437323.fa/assembly.fasta  \
--labels flye,hifiasm,LJA \
-r $REFDIR/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa \
--features $REFDIR/Arabidopsis_thaliana.TAIR10.57.gff3 \
--eukaryote \
--threads 16 \
-o $OUTPUTDIR/with_ref

echo "finished"