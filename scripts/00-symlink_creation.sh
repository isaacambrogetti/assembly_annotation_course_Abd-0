#!/usr/bin/env bash

#SBATCH --time=00:05:00
#SBATCH --mem=10MB
#SBATCH --cpus-per-task=1
#SBATCH --job-name=symlink
#SBATCH --partition=pibu_el8


cd /data/users/iambrogetti/assembly_annotation_course_Abd-0/data

ln -s /data/courses/assembly-annotation-course/raw_data/Abd-0 ./
ln -s /data/courses/assembly-annotation-course/raw_data/RNAseq_Sha ./
