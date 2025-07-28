#!/bin/bash
# Copyright (c) 2025 Lawrence Livermore National Security, LLC and other
# hecbench-omp-builder project developers. See the top-level COPYRIGHT
# file for details.
#
# SPDX-License-Identifier: MIT
  
set -e

if [[ -z "$1" ]]
then
    echo "Usage: $0 <<build|run> outputs_dir>"
    exit 1
fi

wf_type=$(awk '{ printf("%s", $1) }' <<< "$1")
outputs_dir=$(awk '{ printf("%s", $2) }' <<< "$1")

source ${outputs_dir}/projects.txt
num_projects=${#makefile_paths[@]}
source ${outputs_dir}/run-cmds.txt
num_failed=0
num_success=0
msg_failed="Segmentation fault"

echo "--INFO-- Searching benchmarks $wf_type"
for (( i=0; i<num_projects; i++ ));
do
    status="fail"
    project_dir=$(sed -n "s/\/Makefile.aomp//p" <<< "${makefile_paths[$i]}")
    project=$(awk 'BEGIN {FS="/"} {print $NF}' <<< "$project_dir")

    # Check if executable "main" generated
    if [[ $wf_type == "build" ]]
    then
        if [[ -f "$project_dir/main" ]]
        then
            status="success"
        fi
    fi

    # Check if run results generated
    if [[ $wf_type == "run" ]]
    then
        if [[ -f "$project_dir/run_results.txt" ]]
        then
            # Check for segmentation faults
            msg=$(sed -n "/$msg_failed/p" $project_dir/run_results.txt)
            if [[ -z "$msg" ]]
            then
                status="success"
            fi
        fi
    fi

    # Cumulate results
    if [[ $status == "success" ]]
    then
        num_success=$((num_success + 1))
    else
        num_failed=$((num_failed + 1))
        printf "%3d %s\n" "$i" "$project" 
    fi
done
echo "--INFO-- Benchmark $wf_type success=$num_success failed=$num_failed"
