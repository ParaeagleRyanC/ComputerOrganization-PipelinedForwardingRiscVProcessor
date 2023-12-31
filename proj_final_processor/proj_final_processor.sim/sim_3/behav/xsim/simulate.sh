#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Mon Mar 27 17:08:15 MDT 2023
# SW Build 2708876 on Wed Nov  6 21:39:14 MST 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xsim riscv_final_tb_behav -key {Behavioral:sim_3:Functional:riscv_final_tb} -tclbatch riscv_final_tb.tcl -log simulate.log"
xsim riscv_final_tb_behav -key {Behavioral:sim_3:Functional:riscv_final_tb} -tclbatch riscv_final_tb.tcl -log simulate.log

