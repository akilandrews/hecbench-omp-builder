#!/bin/bash
# Copyright (c) 2025 Lawrence Livermore National Security, LLC and other
# hecbench-omp-builder project developers. See the top-level COPYRIGHT
# file for details.
#
# SPDX-License-Identifier: MIT
  
set -e

parameters="<clean|get|build|run>"
if [[ -z "$1" ]]
then
  echo "Usage: $0 $parameters"
  exit 1
else
  wf_type=$1
fi

# Directories for build and installation
root_dir="$(pwd)"
config_dir="$root_dir/config"
source $config_dir/env.sh
clang_config="$config_dir/amdgcn-amd-amdhsa.cfg"
export EXTRA_CFLAGS="--config $clang_config"
jobs_dir=$(readlink -f "$root_dir/../jobs") #TODO change
outputs_dir=$(readlink -f "$root_dir/../hob-configs") #TODO change
hecbench_install_dir=$(readlink -f "$root_dir/../") #TODO change

# Create directories and clone HecBench suite
[[ ! -f "$jobs_dir" ]] && mkdir -p ${jobs_dir}
[[ ! -f "$outputs_dir" ]] && mkdir -p ${outputs_dir}
if [[ ! -d ${hecbench_install_dir}/HeCBench ]]
then
    cd $hecbench_install_dir
    git clone https://github.com/zjin-lcf/HeCBench.git
    cd HeCBench
    git checkout 8a7cf3cc504436f11aa2337dedaf07deb17f3acb
    cd $root_dir
fi
hecbench_source=$hecbench_install_dir/HeCBench/src
echo "--INFO-- HeCBench project directory $hecbench_source"

# Begin workflow type
echo "--INFO-- Begin workflow $wf_type"
msg=""
start_time=$(date '+%s')
case $wf_type in

  # Clean available omp benchmark directories
  "clean")
    echo "--INFO-- Remove prior results and any core dump files"
    rm -f *.core ${jobs_dir}/* ${outputs_dir}/*
    omp_projects="$hecbench_source/*-omp"
    find ${omp_projects} -maxdepth 1 -type f -name '*.core'                     \
      | xargs --no-run-if-empty rm
    find ${omp_projects} -maxdepth 1 -type f -name 'compile_results.txt'        \
      | xargs --no-run-if-empty rm
    find ${omp_projects} -maxdepth 1 -type f -name 'run_results.txt'            \
      | xargs --no-run-if-empty rm
    msg="--INFO-- Completed clean"
    ;;
  
  # Get available omp benchmarks
  "get")
    helpers/get_benchmarks.sh "$hecbench_source $outputs_dir"
    msg="--INFO-- Completed get benchmarks"
    ;;
  
  # Build and execute available omp benchmarks using Flux submit 
  "build" | "run")
    source ${outputs_dir}/projects.txt
    num_projects=${#makefile_paths[@]}
    source ${outputs_dir}/run-cmds.txt
    for (( i=0; i<num_projects; i++ ));
    do
      project_dir=$(sed -n "s/\/Makefile.aomp//p" <<< "${makefile_paths[$i]}")
      project=$(awk 'BEGIN {FS="/"} {print $NF}' <<< "$project_dir")
      if [[ $wf_type == "build" ]]
      then
        flux submit -n 1 -c 1 --quiet -o mpibind=off -o cpu-affinity=per-task   \
          --flags=waitable --output=$jobs_dir/build-{{id}}.out                  \
	        helpers/build_benchmark.sh "$project_dir $project"
      else
        flux submit -n 1 -c 1 -g 1 --quiet -o mpibind=off                       \
          -o cpu-affinity=per-task -o gpu-affinity=per-task                     \
          --flags=waitable --output=$jobs_dir/run-{{id}}.out                    \
          helpers/run_benchmark.sh                                              \
          "$project_dir $project ${run_cmds[$i]}"
      fi
      printf "%3d %s\n" "$i" "$project"
    done
    flux job wait --all
    msg="--INFO-- Completed submitting $wf_type jobs"
    ;;

  # Default error
  *)
    echo "--ERROR-- Usage: $0 $parameters"
    ;;
esac

# Display total execution time
end_time=$(date '+%s')
total_time=$(bc -l <<< "($end_time - $start_time) / 60")
printf "%s in %.2f mins\n" "$msg" "$total_time"
