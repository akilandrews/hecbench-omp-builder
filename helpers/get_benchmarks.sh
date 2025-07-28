#!/bin/bash
# Copyright (c) 2025 Lawrence Livermore National Security, LLC and other
# hecbench-omp-builder project developers. See the top-level COPYRIGHT
# file for details.
#
# SPDX-License-Identifier: MIT
  
set -e

if [[ -z "$1" ]]
then
    echo "Usage: $0 <hecbench_source outputs_dir>"
    exit 1
fi

hecbench_source=$(awk '{ printf("%s", $1) }' <<< "$1")
outputs_dir=$(awk '{ printf("%s", $2) }' <<< "$1")

# Get benchmarks Makefiles.aomp
hec_projects=$(find ${hecbench_source} -type f -name "Makefile.aomp"            \
  -printf '%p\n' | sort -g)
num_hec_projects=$(grep -o "Makefile.aomp" <<< "$hec_projects" | wc -l)
echo "--INFO-- Total benchmarks available: $num_hec_projects"

desired_projects=("accuracy-omp" "ace-omp" "adam-omp" "aidw-omp"                \
  "aligned-types-omp" "amgmk-omp" "aobench-omp" "atan2-omp"                     \
  "background-subtract-omp" "backprop-omp" "bitonic-sort-omp"                   \
  "black-scholes-omp" "cbsfil-omp" "chemv-omp" "clenergy-omp" "cobahh-omp"      \
  "complex-omp" "concat-omp" "convolution3D-omp" "cooling-omp" "crc64-omp"      \
  "cross-omp" "damage-omp" "dct8x8-omp" "ddbp-omp" "distort-omp" "dslash-omp"   \
  "dxtc2-omp" "easyWave-omp" "ecdh-omp" "eigenvalue-omp" "extrema-omp"          \
  "filter-omp" "fluidSim-omp" "fsm-omp" "fwt-omp" "ga-omp" "gabor-omp"          \
  "gaussian-omp" "heat-omp" "hellinger-omp" "hmm-omp" "interleave-omp"          \
  "ising-omp" "iso2dfd-omp" "jenkins-hash-omp" "keccaktreehash-omp"             \
  "laplace3d-omp" "lavaMD-omp" "layout-omp" "lda-omp" "libor-omp" "lif-omp"     \
  "log2-omp" "lombscargle-omp" "mandelbrot-omp" "mask-omp" "matrix-rotate-omp"  \
  "maxpool3d-omp" "md5hash-omp" "medianfilter-omp" "minisweep-omp"              \
  "minkowski-omp" "mr-omp" "mrc-omp" "murmurhash3-omp" "nbody-omp" "ne-omp"     \
  "nms-omp" "ntt-omp" "particle-diffusion-omp" "particlefilter-omp"             \
  "pathfinder-omp" "perplexity-omp" "popcount-omp" "projectile-omp" "pso-omp"   \
  "rainflow-omp" "randomAccess-omp" "recursiveGaussian-omp" "resize-omp"        \
  "rodrigues-omp" "romberg-omp" "rsc-omp" "s3d-omp" "secp256k1-omp"             \
  "simplemoc-omp" "sobol-omp" "softmax-omp" "sosfil-omp" "sph-omp" "su3-omp"    \
  "swish-omp" "tensorT-omp" "threadfence-omp" "tsa-omp" "vanGenuchten-omp"      \
  "winograd-omp" "wlcpow-omp" "wyllie-omp" "xsbench-omp")

# Add benchmarks
echo "--INFO-- Add benchmarks"
declare -a makefile_paths=()
# count=0
num_projects=${#desired_projects[@]}
for (( i=0; i<num_projects; i++ ));
do
  project=${desired_projects[$i]}
  makefile_paths+=("$hecbench_source/$project/Makefile.aomp")
  # count=$((count + 1))
  # if [[ count -eq 100 ]]; then break; fi 
done
num_projects=${#makefile_paths[@]}
message="$num_projects"
echo "--INFO-- Total benchmarks available: $message"

# Modify variables in each Makefile.aomp
echo "--INFO-- Modify variables in each Makefile.aomp"
declare -a options=(
  [0]="CC"
  [1]="OPTIMIZE"
  [2]="DEBUG"
  [3]="DEVICE"
  [4]="ARCH"
  [5]="LAUNCHER"
  [6]="VERIFY"
  [7]="DUMP"
  [8]="program"
)
for (( i=0; i<num_projects; i++ ));
do
  project_makefile=${makefile_paths[$i]}
  sed -i -e "s/${options[0]}.*=.*/${options[0]} = clang++/"                     \
    -e "s/${options[1]}.*=.*/${options[1]} = /"                                 \
    -e "s/${options[2]}.*=.*/${options[2]} = /"                                 \
    -e "s/${options[3]}.*=.*/${options[3]} = /"                                 \
    -e "s/${options[4]}.*=.*/${options[4]} = /"                                 \
    -e "s/${options[5]}.*=.*/${options[5]} = /"                                 \
    -e "s/${options[6]}.*=.*/${options[6]} = /"                                 \
    -e "s/${options[7]}.*=.*/${options[7]} = /"                                 \
    -e "s/${options[8]}.*=.*/${options[8]} = main/"                             \
    -e "/CFLAGS.*+=.*-qopenmp/d"                                                \
    -e "/CFLAGS.*+=.*-fopenmp/d" ${project_makefile}
done

# Create files 'projects.txt' and 'run-cmds.txt'
echo "--INFO-- Create files 'projects.txt' and 'run-cmds.txt'"
declare -a run_cmds
for (( i=0; i<num_projects; i++ ));
do
  option="0,/\$(LAUNCHER) *\.\/\$(program)/{s/\$(LAUNCHER) *\.\/\$(program)//p}"
  has_option=$(sed -n "$option" ${makefile_paths[$i]})
  
  # Replace "../" since running executable in run# folders not project path
  replace_str=$(sed 's;/;\\/;g' <<< "$hecbench_source")
  option="s/ \.\.\// $replace_str\//g"
  has_option=$(sed "$option" <<< "$has_option")
  
  # Replace "./"
  project_dir=$(awk 'BEGIN {FS="/"} {for(i=1;i<=NF;i++) printf("%s%s",$i,FS);}' \
    <<< "${makefile_paths[$i]}")
  replace_str=$(sed 's;/;\\/;g' <<< "$project_dir")
  option="s/ \.\// $replace_str\//g"
  has_option=$(sed "$option" <<< "$has_option")
  
  # Store benchmark run command with parameters
  exec_full_path=$(sed -n "s/Makefile.aomp/main/p" <<< "${makefile_paths[$i]}")
  run_cmds+=("$exec_full_path $has_option")
  project=$(awk 'BEGIN {FS="/"} {print $(NF - 1)}' <<< "$exec_full_path")
  printf "%d %s\n" "$i" "$project"
done

# Verify array sizes and output to file
if [ "${#makefile_paths[@]}" -ne "${#run_cmds[@]}" ]
then
    printf "%s%d" "--ERROR-- num projects " "${#makefile_paths[@]}"
    printf "%s%d\n" " != num cmds " "${#run_cmds[@]}"
    echo "--ERROR-- Exiting!"
    exit 1
fi
declare -p run_cmds > ${outputs_dir}/run-cmds.txt
declare -p makefile_paths > ${outputs_dir}/projects.txt
