/*******************************************************************************************/
/**                                                                                       **/
/** Copyright 2021 Monte J. Dalrymple                                                     **/
/**                                                                                       **/
/** SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1                                      **/
/**                                                                                       **/
/** Licensed under the Solderpad Hardware License v 2.1 (the "License"); you may not use  **/
/** this file except in compliance with the License, or, at your option, the Apache       **/
/** License version 2.0. You may obtain a copy of the License at                          **/
/**                                                                                       **/
/** https://solderpad.org/licenses/SHL-2.1/                                               **/
/**                                                                                       **/
/** Unless required by applicable law or agreed to in writing, any work distributed under **/
/** the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF   **/
/** ANY KIND, either express or implied. See the License for the specific language        **/
/** governing permissions and limitations under the License.                              **/
/**                                                                                       **/
/** YRV simple mcu system                                             Rev 0.0  03/29/2021 **/
/**                                                                                       **/
/*******************************************************************************************/
`define IO_BASE   16'hffff                                 /* msword of i/o address        */
`define IO_PORT10 14'h0000                                 /* lsword of port 1/0 address   */
`define IO_PORT32 14'h0001                                 /* lsword of port 3/2 address   */
`define IO_PORT54 14'h0002                                 /* lsword of port 5/4 address   */
`define IO_PORT76 14'h0003                                 /* lsword of port 7/6 address   */

`define MEM_BASE  16'h0000                                 /* msword of mem address        */
`define VGA_BASE_0  16'hA000                                 /* msword of mem address        */
`define VGA_BASE_1  16'hA001                                 /* msword of mem address        */


`define IO_PORT0 15'h0000                                 /* lsword of port 0 address   */
`define IO_PORT1 15'h0001                                 /* lsword of port 1 address   */
`define IO_PORT2 15'h0002                                 /* lsword of port 2 address   */
`define IO_PORT3 15'h0003                                 /* lsword of port 3 address   */
`define IO_PORT4 15'h0004                                 /* lsword of port 4 address   */
`define IO_PORT5 15'h0005                                 /* lsword of port 5 address   */
`define IO_PORT6 15'h0006                                 /* lsword of port 6 address   */
`define IO_PORT7 15'h0007                                 /* lsword of port 7 address   */




/* processor                                                                               */
`include "yrv_top.v"
`include "mfp_ahb_lite_matrix.v "

`ifdef INSTANCE_MEM
/* instantiated memory                                                                     */
`include "inst_mem.v"
`endif


module yrv_soc  (debug_mode, port0_reg, port1_reg, port2_reg, port3_reg, 
                 wfi_state, clk, ei_req, nmi_req, port4_in, port5_in, resetb);

  input         clk;                                       /* cpu clock                    */
  input         ei_req;                                    /* external int request         */
  input         nmi_req;                                   /* non-maskable interrupt       */
  input         resetb;                                    /* master reset                 */
  input  [15:0] port4_in;                                  /* port 4                       */
  input  [15:0] port5_in;                                  /* port 5                       */

  output        debug_mode;                                /* in debug mode                */
  output        wfi_state;                                 /* waiting for interrupt        */
  output [15:0] port0_reg;                                 /* port 0                       */
  output [15:0] port1_reg;                                 /* port 1                       */
  output [15:0] port2_reg;                                 /* port 2                       */
  output [15:0] port3_reg;                                 /* port 3                       */




  /*****************************************************************************************/
  /* signal declarations                                                                   */
  /*****************************************************************************************/
  wire          bus_32;                                    /* 32-bit bus select            */
  wire          debug_mode;                                /* in debug mode                */

  wire          ser_clk;                                   /* serial clk output (cks mode) */
  wire          wfi_state;                                 /* waiting for interrupt        */
  wire    [7:0] rx_rdata;                                  /* receive data buffer          */
  wire   [15:0] li_req;                                    /* local int requests           */
  wire   [15:0] port7_dat;                                 /* i/o port                     */

  
  

  /*****************************************************************************************/
  /* 32-bit bus, no wait states, internal local interrupts                                 */
  /*****************************************************************************************/
  assign bus_32    = 1'b0;
  assign li_req    = 15'b000000000000000;

  /*****************************************************************************************/
  /* processor                                                                             */
  /*****************************************************************************************/

  wire [31:0] top_mem_addr;
  wire [ 3:0] top_mem_ble;
  wire [ 1:0] top_mem_trans;
  wire [15:0] top_mem_wdata;
  wire        top_mem_write;
  wire        top_resetb;
  wire        top_mem_ready;
  wire [15:0] top_mem_rdata;

  assign top_resetb = resetb;
  
  yrv_top YRV     ( .csr_achk(), .csr_addr(), .csr_read(), .csr_wdata(), .csr_write(),
                    .debug_mode(debug_mode), .ebrk_inst(), .mem_addr(top_mem_addr),
                    .mem_ble(top_mem_ble), .mem_lock(), .mem_trans(top_mem_trans),
                    .mem_wdata(top_mem_wdata), .mem_write(top_mem_write), .timer_en(),
                    .wfi_state(wfi_state), .brk_req(1'b0), .bus_32(bus_32), .clk(clk),
                    .csr_ok_ext(1'b0), .csr_rdata(32'h0), .dbg_req(1'b0),
                    .dresetb(resetb), .ei_req(ei_req), .halt_reg(1'b0), .hw_id(10'h0),
                    .li_req(li_req), .mem_rdata(top_mem_rdata), .mem_ready(top_mem_ready),
                    .nmi_req(nmi_req), .resetb(top_resetb), .sw_req(1'b0),
                    .timer_match(1'b0), .timer_rdata(64'h0) );

    wire [31:0] HADDR;
    wire [ 2:0] HBURST;
    wire        HCLK;
    wire        HMASTLOCK;
    wire [ 3:0] HPROT;
    wire [31:0] HRDATA;
    wire        HREADY;
    wire        HRESETn;
    wire        HRESP;
    wire [ 2:0] HSIZE;
    wire [ 1:0] HTRANS;
    wire [31:0] HWDATA;
    wire        HWRITE;

    wire        SI_Reset;
    wire        SI_Endian;
 


    assign HCLK = clk;
    assign SI_Reset = ~ resetb;
  
  yrv_ahb_bridge ahb_bridge( .mem_addr(top_mem_addr), .mem_ble(top_mem_ble), 
                    .mem_trans(top_mem_trans), .mem_wdata(top_mem_wdata), 
                    .mem_write(top_mem_write), .mem_ready(top_mem_ready), .mem_rdata(top_mem_rdata),
                    .HADDR         (   HADDR         ),
                    .HBURST        (   HBURST        ),
                    .HMASTLOCK     (   HMASTLOCK     ),
                    .HPROT         (   HPROT         ),
                    .HSIZE         (   HSIZE         ),
                    .HTRANS        (   HTRANS        ),
                    .HWDATA        (   HWDATA        ),
                    .HWRITE        (   HWRITE        ),
                    .HRDATA        (   HRDATA        ),
                    .HREADY        (   HREADY        ),
                    .HRESP         (   HRESP         ),
                    .SI_Endian     (   SI_Endian     ));



    mfp_ahb_lite_matrix ahb_lite_matrix
    (
        .HCLK          (   HCLK          ),
        .HRESETn       ( ~ SI_Reset      ),  // Not HRESETn - this is necessary for serial loader
        .HADDR         (   HADDR         ),
        .HBURST        (   HBURST        ),
        .HMASTLOCK     (   HMASTLOCK     ),
        .HPROT         (   HPROT         ),
        .HSIZE         (   HSIZE         ),
        .HTRANS        (   HTRANS        ),
        .HWDATA        (   HWDATA        ),
        .HWRITE        (   HWRITE        ),
        .HRDATA        (   HRDATA        ),
        .HREADY        (   HREADY        ),
        .HRESP         (   HRESP         ),
        .SI_Endian     (   SI_Endian     ),
                                           
        .port0_reg   (   port0_reg   ),
        .port1_reg   (   port1_reg    )
    );
  

  endmodule

`define HTRANS_IDLE    2'b00
`define HTRANS_NONSEQ  2'b10
`define HTRANS_SEQ     2'b11

`define HBURST_SINGLE  3'b000
`define HBURST_WRAP4   3'b010

`define HSIZE_1        3'b000
`define HSIZE_2        3'b001
`define HSIZE_4        3'b002

module yrv_ahb_bridge (
  input             clk,
  input             resetb,

//YRV
  input  [31:0] mem_addr,
  input  [ 3:0] mem_ble,
  input  [ 1:0] mem_trans,
  input  [15:0] mem_wdata,
  input         mem_write,
  input         mem_lock,
  output        mem_ready,
  output [15:0] mem_rdata, 

// AHB-lite  
  output  [31:0] HADDR,       // mem_addr [31:0] Out Memory Address HADDR
  output  logic [ 2:0] HBURST,      // HBURST_SINGLE AHB-Lite supports burst transfers and transfers wider than 32 bits, which we do not need
  output  logic        HMASTLOCK,   // mem_lock Out Memory Locked Transfer HMASTLOCK
  output  [ 3:0] HPROT,       // mem_trans [1:0] Out Memory Transfer Type (see text)  mem_trans[1] is equivalent to the HPROT[0]
  output logic  [ 2:0] HSIZE,       // mem_ble [3:0] Out Memory Byte Lane Enables (see text)
  output  [ 1:0] HTRANS,      // mem_trans [1:0] Out Memory Transfer Type (see text) mem_trans[0] is equivalent to the HTRANS[1] signal
  output  [31:0] HWDATA,      // mem_wdata [31:0] Out Memory Write Data HWDATA
  output         HWRITE,      // mem_write Out Memory Write HWRITE
  input   [31:0] HRDATA,      // mem_rdata [31:0] In Memory Read Data HRDATA
  input          HREADY,      // mem_ready  https://roalogic.github.io/ahb3lite_interconnect/ahb3lite_interconnect_datasheet.html  
  input          HRESP,       //     assign  HRESP  = 1'b0;   https://github.com/MIPSfpga/mipsfpga-plus/blob/master/system_rtl/mfp_ahb_ram_sdram.v
  output         SI_Endian   // ignored
);

  // AHB-lite transfer using `HSIZE_1

assign HADDR = mem_ble == 4'b0010 ? mem_addr + 1'b1 : mem_addr; 
  
assign HADDR     = mem_addr;
  
assign HBURST    = 3'b000;
assign HMASTLOCK = mem_lock;
assign HPROT     = {3'b0, mem_trans[1]}  ;

always_comb
  case(mem_ble)
    4'b0001:  HSIZE = 3'b000; //BYTE
    4'b0010:  HSIZE = 3'b000; //BYTE
    4'b0011:  HSIZE = 3'b001; //HALFWORD
    default:  HSIZE = 3'b000; //HALFWORD
  endcase
  
assign HTRANS = {mem_trans[0], 1'b0};
assign HWDATA = mem_wdata;
assign HWRITE = mem_write;
assign mem_rdata = HRDATA;
assign mem_ready = HREADY;

endmodule