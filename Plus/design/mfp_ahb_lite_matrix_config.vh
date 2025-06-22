//
//  Configuration parameters
//

// `define MFP_INITIALIZE_MEMORY_FROM_TXT_FILE_FOR_SIMULATION
`define MFP_INITIALIZE_MEMORY_FROM_TXT_FILE_FOR_SYNTHESIS

`ifdef      MFP_INITIALIZE_MEMORY_FROM_TXT_FILE_FOR_SIMULATION
    `define MFP_INITIALIZE_MEMORY_FROM_TXT_FILE
    `undef  MFP_INITIALIZE_MEMORY_FROM_TXT_FILE_FOR_SYNTHESIS
`elsif      MFP_INITIALIZE_MEMORY_FROM_TXT_FILE_FOR_SYNTHESIS
    `define MFP_INITIALIZE_MEMORY_FROM_TXT_FILE
`endif

`define MFP_RAM_RESET_INIT_FILENAME   "nmon.txt"
`define MFP_RAM_INIT_FILENAME         "ram_program_init.txt"

`define MFP_USE_UART_PROGRAM_LOADER

//
//  Memory-mapped I/O addresses
//

`define MFP_RED_LEDS_ADDR     32'h1f800000
`define MFP_GREEN_LEDS_ADDR   32'h1f800004
`define MFP_SWITCHES_ADDR     32'h1f800008
`define MFP_BUTTONS_ADDR      32'h1f80000C

`define MFP_RED_LEDS_IONUM    4'h0
`define MFP_GREEN_LEDS_IONUM  4'h1
`define MFP_SWITCHES_IONUM    4'h2
`define MFP_BUTTONS_IONUM     4'h3

//
// RAM addresses
//

`define MFP_RAM_RESET_ADDR          32'h00000000
`define MFP_RAM_ADDR                32'hA0??????

`define MFP_RAM_RESET_ADDR_WIDTH    16
`define MFP_RAM_ADDR_WIDTH          16

`define MFP_RAM_RESET_ADDR_MATCH    7'h7f
`define MFP_RAM_ADDR_MATCH          1'b0
`define MFP_GPIO_ADDR_MATCH         7'h7e


/*******************************************************************************************/
`define IO_BASE   16'hffff                                 /* msword of i/o address        */
`define IO_PORT10 14'h0000                                 /* lsword of port 1/0 address   */
`define IO_PORT32 14'h0001                                 /* lsword of port 3/2 address   */
`define IO_PORT54 14'h0002                                 /* lsword of port 5/4 address   */
`define IO_PORT76 14'h0003                                 /* lsword of port 7/6 address   */

`define MEM_BASE    16'h0100                                 /* msword of mem address        */
`define STACK_BASE  16'h0000                                 /* msword of mem address        */
`define VGA_BASE    16'hA000                                 /* msword of mem address        */


`define IO_PORT0 15'h0000                                 /* lsword of port 0 address   */
`define IO_PORT1 15'h0001                                 /* lsword of port 1 address   */
`define IO_PORT2 15'h0002                                 /* lsword of port 2 address   */
`define IO_PORT3 15'h0003                                 /* lsword of port 3 address   */
`define IO_PORT4 15'h0004                                 /* lsword of port 4 address   */
`define IO_PORT5 15'h0005                                 /* lsword of port 5 address   */
`define IO_PORT6 15'h0006                                 /* lsword of port 6 address   */
`define IO_PORT7 15'h0007                                 /* lsword of port 7 address   */
