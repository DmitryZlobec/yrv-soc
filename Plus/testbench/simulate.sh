#!/usr/bin/env bash

iverilog -g2005-sv    \
    -D INTEL_VERSION  \
    -I ../design      \
    tb_yrv_mcu.sv           \
    2>&1 | tee "log.txt"

vvp a.out 2>&1 | tee "log.txt"


