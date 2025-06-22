//--------------------------------------------------------------------------------------
//
// Copyright 2021 Monte J. Dalrymple
// Copyright 2021 Systemyde International Corporation
// Copyright 2022 Yuri Panchul
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the "License"); you may not use
// this file except in compliance with the License, or, at your option, the Apache
// License version 2.0. You may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//
// YRV processor test bench                                          Rev 0.0  02/08/2021
// YRV simple mcu system                                             Rev 0.0  03/29/2021
// YRV board-agnostic tb with cycle-accurate simulation, no #delays  Rev 0.0  10/08/2022
//
//--------------------------------------------------------------------------------------

`timescale 1 ns / 100 ps

`define CLK_FREQUENCY (50 * 1000 * 1000)

`include "yrv_soc.v"

module tb_yrv_mcu;

  logic        clk;          // cpu clock
  logic        ei_req;       // external int request
  logic        nmi_req;      // non-maskable interrupt
  logic        resetb;       // master reset
  logic        ser_rxd;      // receive data input
  logic [15:0] port4_in;     // port 4
  logic [15:0] port5_in;     // port 5

  wire         debug_mode;   // in debug mode
  wire         ser_clk;      // serial clk output (cks mode)
  wire         ser_txd;      // transmit data output
  wire         wfi_state;    // waiting for interrupt
  wire  [15:0] port0_reg;    // port 0
  wire  [15:0] port1_reg;    // port 1
  wire  [15:0] port2_reg;    // port 2
  wire  [15:0] port3_reg;    // port 3


  `ifdef BOOT_FROM_AUX_UART
  logic        aux_uart_rx;  // auxiliary uart receive pin
  `endif

  yrv_soc i_yrv_soc (.*);

  //------------------------------------------------------------------------------------

  // The design is supposed to run with the frequency 50 MHz,
  // i.e. the period is 20 ns

  initial
  begin
    clk = '0;
    forever # 10 clk = ~ clk;
  end

  //------------------------------------------------------------------------------------

  task init;

    ei_req      <= '0;  // external int request
    nmi_req     <= '0;  // non-maskable interrupt
    ser_rxd     <= '0;  // receive data input
    port4_in    <= '0;  // port 4
    port5_in    <= '0;  // port 5

    `ifdef BOOT_FROM_AUX_UART
    aux_uart_rx <= '0;  // auxiliary uart receive pin
    `endif

  endtask

  //------------------------------------------------------------------------------------

  task reset;

    resetb <= 'x;
    repeat (10) @ (posedge clk);
    resetb <= '1;
    repeat (10) @ (posedge clk);
    resetb <= '0;
    repeat (10) @ (posedge clk);
    resetb <= '1;
  endtask

  //------------------------------------------------------------------------------------

  initial
  begin
    `ifdef __ICARUS__
      $dumpvars;
    `endif

    init;
    reset;

    for (int i = 0; i < 10000; i ++)
    begin
      if (0)
      begin
        port4_in <= $urandom ();     // port 4
      	port5_in <= $urandom ();     // port 5
      end

      @ (posedge clk);
    end

    `ifdef MODEL_TECH  // Mentor ModelSim and Questa
      $stop;
    `else
      $finish;
    `endif
  end

endmodule
