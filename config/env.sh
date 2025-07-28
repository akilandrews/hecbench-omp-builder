#!/bin/bash

module load rocm/6.4.1
export HSA_IGNORE_SRAMECC_MISREPORT=1 # Radeon VII gfx906
