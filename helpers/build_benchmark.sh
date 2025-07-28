#!/bin/bash
# Copyright (c) 2025 Lawrence Livermore National Security, LLC and other
# hecbench-omp-builder project developers. See the top-level COPYRIGHT
# file for details.
#
# SPDX-License-Identifier: MIT
  
set -e

if [[ -z "$1" ]]
then
    echo "Usage: $0 <project_dir project>"
    exit 1
fi

start_time_run=$(date '+%s')

project_dir=$(awk '{ printf("%s", $1) }' <<< "$1")
project=$(awk '{ printf("%s", $2) }' <<< "$1")
printf "%s" "$project"

cd $project_dir
make -f Makefile.aomp clean > /dev/null 2>&1
make -f Makefile.aomp > compile_results.txt 2>&1

end_time_run=$(date '+%s')
total_time_run=$(bc -l <<< "($end_time_run - $start_time_run) / 60")
printf "\t%.2f mins\n" "$total_time_run"
