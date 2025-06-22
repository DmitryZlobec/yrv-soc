`include "mfp_ahb_lite.vh"
`include "mfp_ahb_lite_matrix_config.vh"

`include "mfp_ahb_ram_slave.v"
`include "mfp_ahb_port_slave.v"

module mfp_ahb_lite_matrix
(
    input         HCLK,
    input         HRESETn,
    input  [31:0] HADDR,
    input  [ 2:0] HBURST,
    input         HMASTLOCK,
    input  [ 3:0] HPROT,
    input  [ 2:0] HSIZE,
    input  [ 1:0] HTRANS,
    input  [31:0] HWDATA,
    input         HWRITE,
    output [31:0] HRDATA,
    output        HREADY,
    output        HRESP,
    input         SI_Endian,


    output [15:0] port0_reg,
    output [15:0] port1_reg

);

    wire [ 3:0] HSEL;

    mfp_ahb_lite_decoder decoder (HADDR, HSEL);

    reg  [ 3:0] HSEL_dly;

    always @ (posedge HCLK)
        HSEL_dly <= HSEL;

    wire        HREADY_0 , HREADY_1 , HREADY_2, HREADY_3 ;
    wire [31:0] HRDATA_0 , HRDATA_1 , HRDATA_2, HRDATA_3 ;
    wire        HRESP_0  , HRESP_1  , HRESP_2,  HRESP_3  ;

    mfp_ahb_ram_slave
    # (
        .ADDR_WIDTH    ( `MFP_RAM_RESET_ADDR_WIDTH    ),
        .INIT_FILENAME ( `MFP_RAM_RESET_INIT_FILENAME )
    )
    stack_ram
    (
        .HCLK       ( HCLK       ),
        .HRESETn    ( HRESETn    ),
        .HADDR      ( HADDR      ),
        .HBURST     ( HBURST     ),
        .HMASTLOCK  ( HMASTLOCK  ),
        .HPROT      ( HPROT      ),
        .HSEL       ( HSEL [0]   ),
        .HSIZE      ( HSIZE      ),
        .HTRANS     ( HTRANS     ),
        .HWDATA     ( HWDATA     ),
        .HWRITE     ( HWRITE     ),
        .HRDATA     ( HRDATA_0   ),
        .HREADY     ( HREADY_0   ),
        .HRESP      ( HRESP_0    ),
        .SI_Endian  ( SI_Endian  )
    );

    mfp_ahb_ram_slave
    # (
        .ADDR_WIDTH    ( `MFP_RAM_ADDR_WIDTH    )
    )
    ram
    (
        .HCLK       ( HCLK       ),
        .HRESETn    ( HRESETn    ),
        .HADDR      ( HADDR      ),
        .HBURST     ( HBURST     ),
        .HMASTLOCK  ( HMASTLOCK  ),
        .HPROT      ( HPROT      ),
        .HSEL       ( HSEL [1]   ),
        .HSIZE      ( HSIZE      ),
        .HTRANS     ( HTRANS     ),
        .HWDATA     ( HWDATA     ),
        .HWRITE     ( HWRITE     ),
        .HRDATA     ( HRDATA_1   ),
        .HREADY     ( HREADY_1   ),
        .HRESP      ( HRESP_1    ),
        .SI_Endian  ( SI_Endian  )
    );

    mfp_ahb_port_slave port01
    (
        .HCLK         ( HCLK         ),
        .HRESETn      ( HRESETn      ),
        .HADDR        ( HADDR        ),
        .HBURST       ( HBURST       ),
        .HMASTLOCK    ( HMASTLOCK    ),
        .HPROT        ( HPROT        ),
        .HSEL         ( HSEL [3]     ),
        .HSIZE        ( HSIZE        ),
        .HTRANS       ( HTRANS       ),
        .HWDATA       ( HWDATA       ),
        .HWRITE       ( HWRITE       ),
        .HRDATA       ( HRDATA_3     ),
        .HREADY       ( HREADY_3     ),
        .HRESP        ( HRESP_3      ),
        .SI_Endian    ( SI_Endian    )
    );



    assign HREADY = HREADY_0 | HREADY_1 | HREADY_2;

    mfp_ahb_lite_response_mux response_mux
    (
        .HSEL     ( HSEL_dly ),

        .HRDATA_0 ( HRDATA_0 ),
        .HRDATA_1 ( HRDATA_1 ),
        .HRDATA_2 ( HRDATA_2 ),

        .HRESP_0  ( HRESP_0  ),
        .HRESP_1  ( HRESP_1  ),
        .HRESP_2  ( HRESP_2  ),

        .HRDATA   ( HRDATA   ),
        .HRESP    ( HRESP    )
    );

endmodule

//--------------------------------------------------------------------

module mfp_ahb_lite_decoder
(
    input  [31:0] HADDR,
    output [ 3:0] HSEL
);

    assign HSEL [0] = ( HADDR [31:16] == `STACK_BASE );

    assign HSEL [1] = ( HADDR [31:16] == `MEM_BASE);

    assign HSEL [2] = ( HADDR [31:16] == `VGA_BASE);

    assign HSEL [3] = ( HADDR [31:16] == `IO_BASE    );

endmodule

//--------------------------------------------------------------------

module mfp_ahb_lite_response_mux
(
    input      [ 3:0] HSEL,
               
    input      [31:0] HRDATA_0,
    input      [31:0] HRDATA_1,
    input      [31:0] HRDATA_2,
               
    input             HRESP_0,
    input             HRESP_1,
    input             HRESP_2,

    output reg [31:0] HRDATA,
    output reg        HRESP
);

    always @*
        casez (HSEL)
	        4'b???1:   begin HRDATA = HRDATA_0; HRESP = HRESP_0; end
	        4'b??10:   begin HRDATA = HRDATA_1; HRESP = HRESP_1; end
	        4'b?100:   begin HRDATA = HRDATA_2; HRESP = HRESP_2; end
	        default:   begin HRDATA = HRDATA_1; HRESP = HRESP_1; end
        endcase

endmodule
