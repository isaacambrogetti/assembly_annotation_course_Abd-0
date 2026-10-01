#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=02:00:00
#SBATCH --job-name=merq-gen
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_merqury-genomes_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_merqury-genomes_%j.e
#SBATCH --partition=pshort_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/output"
OUTPUTDIR="$WORKDIR/output/merqury"
REFDIR="/data/courses/assembly-annotation-course/references"

  
if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "Working directory: $WORKDIR"
echo "Input directory: $INPUTDIR"
echo "Output directory: $OUTPUTDIR"

# add MERQURY as a path variable in the script
export MERQURY="/usr/local/share/merqury"

echo "running without reference"

apptainer exec \
--bind /data \
/containers/apptainer/merqury_1.3.sif \
meryl k=19 count \
$WORKDIR/data/ERR11437323.fastq.gz \
output $OUTPUTDIR/reads.k19.meryl

# Run merqury on each assembly

apptainer exec \
--bind /data \
/containers/apptainer/merqury_1.3.sif \
merqury.sh $OUTPUTDIR/reads.k19.meryl \
$INPUTDIR/flye/assembly.fasta \
$OUTPUTDIR/flye_merqury

apptainer exec --bind /data /containers/apptainer/merqury_1.3.sif \
merqury.sh $OUTPUTDIR/reads.k19.meryl \
$INPUTDIR/hifiasm/ERR11437323.fa \
$OUTPUTDIR/hifiasm_merqury

apptainer exec --bind /data /containers/apptainer/merqury_1.3.sif \
merqury.sh $OUTPUTDIR/reads.k19.meryl \
$INPUTDIR/lja/ERR11437323.fa/assembly.fasta \
$OUTPUTDIR/lja_merqury


# k-mer size decision
"""
(base) [iambrogetti@binfservas11 assembly_annotation_course_Abd-0]$ apptainer exec \
>   --containall \
>   /containers/apptainer/merqury_1.3.sif \
>   sh /usr/local/share/merqury/best_k.sh 130400000
genome: 130400000
tolerable collision rate: 0.001
18.4614

rounded to 19
"""