#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64GB
#SBATCH --time=02:00:00
#SBATCH --job-name=mummer
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/output_mummer_%j.out
#SBATCH --error=/data/users/iambrogetti/assembly_annotation_course_Abd-0/logs/error_mummer_%j.e
#SBATCH --partition=pshort_el8

WORKDIR="/data/users/iambrogetti/assembly_annotation_course_Abd-0"
INPUTDIR="$WORKDIR/output"
OUTPUTDIR="$WORKDIR/output/mummer"

FLYE=$INPUTDIR/flye/assembly.fasta
HIFIASM=$INPUTDIR/hifiasm/ERR11437323.fa
LJA=$INPUTDIR/lja/ERR11437323.fa/assembly.fasta
REF="/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"

if [ ! -d "$OUTPUTDIR" ]; then
  echo "creating output directory"
  mkdir $OUTPUTDIR
fi

echo "Working directory: $WORKDIR"
echo "Input directory: $INPUTDIR"
echo "Output directory: $OUTPUTDIR"
echo "flye fasta: $FLYE"
echo "hifiasm fasta: $HIFIASM"
echo "lja fasta: $LJA"


run_nucmer_plot () {
    local ref=$1
    local query=$2
    local prefix=$3

    apptainer exec --bind /data /containers/apptainer/mummer4_gnuplot.sif \
    nucmer --prefix=$prefix \
    --breaklen 1000 \
    --mincluster 1000 \
    $ref $query

    apptainer exec --bind /data /containers/apptainer/mummer4_gnuplot.sif \
    mummerplot \
    -R $ref -Q $query \
    --filter \
    -t png \
    --large \
    --layout \
    --fat \
    -p $prefix \
    $prefix.delta
}

# Each assembly vs. reference
echo "starting assembly vs reference comparisons"
run_nucmer_plot $REF $FLYE "$OUTPUTDIR/flye_vs_ref"
run_nucmer_plot $REF $HIFIASM "$OUTPUTDIR/hifiasm_vs_ref"
run_nucmer_plot $REF $LJA "$OUTPUTDIR/LJA_vs_ref"

# Pairwise assembly comparisons
echo "starting assemblies comparisons"
run_nucmer_plot $FLYE $HIFIASM "$OUTPUTDIR/flye_vs_hifiasm"
run_nucmer_plot $FLYE $LJA     "$OUTPUTDIR/flye_vs_LJA"
run_nucmer_plot $HIFIASM $LJA  "$OUTPUTDIR/hifiasm_vs_LJA"

echo "FINISHED"