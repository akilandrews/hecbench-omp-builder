#!/bin/bash

module load rocm/6.0.2
export HSA_IGNORE_SRAMECC_MISREPORT=1 # Radeon VII gfx906
