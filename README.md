# Benchmark Builder
Bash scripts that build OpenMP Offload benchmarks included in the [HeCBench Suite](https://github.com/zjin-lcf/HeCBench) on AMD GPUs hardware.

## Requirements
Bash shell v4.4, OpenMP 4.5, Clang 19.1.7, AMD ROCm 6.4.1, Flux 0.75

## Configuration
To configure the builder to your environment, search files for '#TODO change' and update the variables to reflect your file system and preferences. Files and variables include:
* 'builder.sh' at a minimum, the following variables:
    * 'jobs_dir' to store Flux job outputs.
    * 'outputs_dir' to store builder config files.
    * 'hecbench_install_dir' to clone the benchmark repository.
* 'amdgcn-amd-amdhsa.cfg' for clang++ configuration.
* 'env.sh' for loading modules and environment variables.

## Run the builder
Execute each step in a Flux environment in order:
1. `builder.sh clean`
2. `builder.sh get`
3. `builder.sh build`
4. `builder.sh run`  
*Note: progress of steps 3 and 4 can be monitored using `flux top`

## Authors
See the [CODEOWNERS](CODEOWNERS) file for details.

## License
hecbench-omp-builder is distributed under the terms of the MIT license. All new contributions must be made under the MIT license. See [LICENSE](LICENSE), [NOTICE](NOTICE), and [COPYRIGHT](COPYRIGHT) for details.

SPDX-License-Identifier: MIT

## Release
LLNL-CODE-2006347
