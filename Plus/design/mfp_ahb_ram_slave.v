`include "mfp_ahb_lite.vh"

`include "mfp_dual_port_ram.v"

module mfp_ahb_ram_slave
# (
    parameter ADDR_WIDTH    = 10,
    parameter INIT_FILENAME = ""
)
(
    input         HCLK,
    input         HRESETn,
    input  [31:0] HADDR,
    input  [ 2:0] HBURST,
    input         HMASTLOCK,
    input  [ 3:0] HPROT,
    input         HSEL,
    input  [ 2:0] HSIZE,
    input  [ 1:0] HTRANS,
    input  [31:0] HWDATA,
    input         HWRITE,
    output [31:0] HRDATA,
    output        HREADY,
    output        HRESP,
    input         SI_Endian
);

    // Ignored: HMASTLOCK, HPROT
    // TODO: SI_Endian

    assign HREADY = 1'b1;
    assign HRESP  = 1'b0;

    reg [ 1:0] HTRANS_dly;
    reg [31:0] HADDR_dly;
    reg        HWRITE_dly;
    reg        HSEL_dly;

    always @ (posedge HCLK)
    begin
        HTRANS_dly <= HTRANS;
        HADDR_dly  <= HADDR;
        HWRITE_dly <= HWRITE;
        HSEL_dly   <= HSEL;
    end

    `ifdef MFP_INITIALIZE_MEMORY_FROM_TXT_FILE

    wire write_enable = HTRANS_dly != `HTRANS_IDLE && HSEL_dly && HWRITE_dly;

    mfp_dual_port_ram
    # (
        .ADDR_WIDTH     ( ADDR_WIDTH    ),
        .DATA_WIDTH     ( 16            ),
        .INIT_FILENAME  ( INIT_FILENAME )
    )
    ram
    (
        .clk          ( HCLK                                ),
        .read_addr    ( HADDR     [ ADDR_WIDTH - 1 : 1]     ),
        .write_addr   ( HADDR_dly [ ADDR_WIDTH - 1 : 1]     ),
        .write_data   ( HWDATA                              ),
        .write_enable ( write_enable                        ),
        .read_data    ( HRDATA                              )
    );

    `else

    reg [3:0] mask;

    always @*
    begin
        if (! (HTRANS_dly != `HTRANS_IDLE && HSEL_dly && HWRITE_dly))
            mask = 4'b0000;
        else if (HBURST == `HBURST_SINGLE && HSIZE == `HSIZE_1)
            mask = 4'b0001 << HADDR [1:0];
        else if (HBURST == `HBURST_SINGLE && HSIZE == `HSIZE_2)
            mask = HADDR [1] ? 4'b1100 : 4'b0011;
        else
            mask = 4'b1111;
    end

    generate
        genvar i;

        for (i = 0; i <= 1; i = i + 1)
        begin : u
            mfp_dual_port_ram
            # (
                .ADDR_WIDTH ( ADDR_WIDTH ),
                .DATA_WIDTH ( 8          )
            )
            ram
            (
                .clk          ( HCLK                                ),
                .read_addr    ( HADDR     [ ADDR_WIDTH - 1 : 1] ),
                .write_addr   ( HADDR_dly [ ADDR_WIDTH - 1 : 1] ),
                .write_data   ( HWDATA    [ i * 8 +: 8 ]            ),
                .write_enable ( mask      [ i ]                     ),
                .read_data    ( HRDATA    [ i * 8 +: 8 ]            )
            );
        end
    endgenerate

    `endif

endmodule
