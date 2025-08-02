# Benchmark Builder
Bash scripts that build OpenMP Offload benchmarks included in the [HeCBench Suite](https://github.com/zjin-lcf/HeCBench) on AMD GPUs hardware.

## Requirements
Bash shell v4.4, OpenMP 4.5, Clang 19.1.7, AMD ROCm 6.0.2, Flux 0.75

## Configuration
First configure the builder to your environment, search files for '#TODO change' and update the variables to reflect your file system and preferences. Edit files and variables:
* builder.sh:
    * 'jobs_dir' to store Flux job outputs
    * 'outputs_dir' to store builder config files
    * 'hecbench_install_dir' location to or clone the repository
* config/amdgcn-amd-amdhsa.cfg for clang++ configuration
* config/env.sh for loading modules and environment variables

## Run builder
**Step 1.** Launch an interactive Flux environment (see Flux documentation for help)  

**Step 2.** (Recommended) Clean repository of any prior outputs:
```console
builder.sh clean
```
**Step 3.** Generate a list of all available benchmarks (removes benchmarks with issues and edits all Makefile.aomp):
```console
builder.sh get
```
**Step 4.** Build benchmarks:
```console
builder.sh build
```
**Step 5.** Execute benchmarks:
```console
builder.sh run
``` 
*Note: progress of steps 3 and 4 can be monitored using `flux top`

## Authors
See the [CODEOWNERS](CODEOWNERS) file for details.

## License
hecbench-omp-builder is distributed under the terms of the MIT license. All new contributions must be made under the MIT license. See [LICENSE](LICENSE), [NOTICE](NOTICE), and [COPYRIGHT](COPYRIGHT) for details.

SPDX-License-Identifier: MIT

## Release
LLNL-CODE-2006347
