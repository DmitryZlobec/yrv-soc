//
//  General-purpose I/O module for Altera's DE2-115 and 
//  Digilent's (Xilinx) Nexys4-DDR board
//
//  Altera's DE2-115 board:
//  Outputs:
//  18 red LEDs (IO_LEDR), 9 green LEDs (IO_LEDG) 
//  Inputs:
//  18 slide switches (IO_Switch), 4 pushbutton switches (IO_PB[3:0])
//
//  Digilent's (Xilinx) Nexys4-DDR board:
//  Outputs:
//  15 LEDs (IO_LEDR[14:0]) 
//  Inputs:
//  15 slide switches (IO_Switch[14:0]), 
//  5 pushbutton switches (IO_PB)
//

`include "mfp_ahb_lite.vh"
`include "mfp_ahb_lite_matrix_config.vh"

`define PORT0_ADDR     32'hffff0000
`define PORT1_ADDR     32'hffff0002

module mfp_ahb_port_slave
(
    input             HCLK,
    input             HRESETn,
    input      [31:0] HADDR,
    input      [ 2:0] HBURST,
    input             HMASTLOCK,
    input      [ 3:0] HPROT,
    input      [ 2:0] HSIZE,
    input             HSEL,
    input      [ 1:0] HTRANS,
    input      [31:0] HWDATA,
    input             HWRITE,
    output reg [31:0] HRDATA,
    output            HREADY,
    output            HRESP,
    input             SI_Endian,

    output [15:0]  port0_out,
    output [15:0]  port1_out
);

    // Ignored: HMASTLOCK, HPROT
    // TODO: SI_Endian

    assign HREADY = 1'b1;
    assign HRESP  = 1'b0;

    reg [ 1:0] HTRANS_dly;
    reg [31:0] HADDR_dly;
    reg        HWRITE_dly;
    reg        HSEL_dly;

    reg [15:0] port0_reg;
    reg [15:0] port1_reg;

    always @ (posedge HCLK)
    begin
        HTRANS_dly <= HTRANS;
        HADDR_dly  <= HADDR;
        HWRITE_dly <= HWRITE;
        HSEL_dly   <= HSEL;
    end

    wire [3:0] read_ionum   = HADDR     [5:2];
    wire [3:0] write_ionum  = HADDR_dly [5:2];
    wire       write_enable = HTRANS_dly != `HTRANS_IDLE && HSEL_dly && HWRITE_dly;

    always @ (posedge HCLK or negedge HRESETn)
    begin
        if (! HRESETn)
        begin
            port0_reg    <= 16'b0;
            port1_reg    <= 16'b0;
        end
        else if (write_enable)
        begin
            case (HADDR_dly)
            `PORT0_ADDR   : port0_reg   <= HWDATA [15:0];
            `PORT1_ADDR   : port1_reg   <= HWDATA [15:0];
            endcase
        end
    end

    assign port0_out = port0_reg;
    assign port1_out = port1_reg;


endmodule
