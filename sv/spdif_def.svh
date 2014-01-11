///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF GENERATOR BY zied.sassi@gmail.com /////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

`ifndef SPDIF_SVH
`define SPDIF_SVH
`define ADDR_SIZE 16
`define DATA_SIZE 8
`define BOUNDRY_VAL 10
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "spdif_transfer.sv"
`include "spdif_scoreboard.sv"
`include "spdif_driver.sv"
`include "spdif_monitor.sv"
`include "spdif_sequencer.sv"
`include "spdif_env.sv"
`include "spdif_tb.sv"
`include "spdif_test_lib.sv"
