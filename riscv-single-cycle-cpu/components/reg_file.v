
/*
# Filename:         reg_file.v
# File Description: 32-entry register file for single-cycle RISC-V CPU with synchronous write and combinational read.
# Global variables: None
*/

//=========================================================
// Module: reg_file
// Description: 32-entry register file with parameterized data width.
//              Supports synchronous write and combinational read.
//              Register 0 (x0) is hardwired to 0 as per RISC-V spec.
// Parameters:
//   DATA_WIDTH - Bit-width of each register (default is 32 bits)
// Ports:
//   clk      - Clock signal
//   wr_en    - Write enable (1 to write data to a register)
//   rd_addr1 - Read address for first output
//   rd_addr2 - Read address for second output
//   wr_addr  - Write address
//   wr_data  - Data to write into the register file
//   rd_data1 - First read data output
//   rd_data2 - Second read data output
//=========================================================

module reg_file #(parameter DATA_WIDTH = 32) (  // DATA_WIDTH: width of each register
    input                       clk,         // Clock input
    input                       wr_en,       // Write enable signal
    input      [4:0]            rd_addr1,    // Read address 1 (5 bits for 32 registers)
    input      [4:0]            rd_addr2,    // Read address 2
    input      [4:0]            wr_addr,     // Write address
    input      [DATA_WIDTH-1:0] wr_data,     // Data to write into the register file
    output     [DATA_WIDTH-1:0] rd_data1,    // Read data 1
    output     [DATA_WIDTH-1:0] rd_data2     // Read data 2
);

    // reg_file_arr: 32-register array, each register is DATA_WIDTH bits
    // Registers x0-x31, with x0 hardwired to 0
    reg [DATA_WIDTH-1:0] reg_file_arr [0:31];

    // i: integer used for loop in initial block
    integer i;

    //=====================================================
    // Initial block
    // Purpose:
    // ---
    // Initialize all registers to 0 at simulation start.
    //=====================================================
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            reg_file_arr[i] = 0;  // Initialize each register to zero
        end
    end

    //=====================================================
    // Synchronous write block
    // Purpose:
    // ---
    // Write data to the register specified by wr_addr
    // on the rising edge of clk if write enable is high.
    //=====================================================
    always @(posedge clk) begin
        /*
        Purpose:
        ---
        Perform synchronous write to the register file. If wr_en is high, 
        store wr_data into the register specified by wr_addr.
        */
        if (wr_en)
            reg_file_arr[wr_addr] <= wr_data; // Note: writing to x0 (wr_addr = 0) has no effect
    end

    //=====================================================
    // Combinational read logic
    // Purpose:
    // ---
    // Output the value of the register at rd_addr1 and rd_addr2.
    // Register x0 always returns 0.
    //=====================================================
    assign rd_data1 = (rd_addr1 != 0) ? reg_file_arr[rd_addr1] : 0;
    assign rd_data2 = (rd_addr2 != 0) ? reg_file_arr[rd_addr2] : 0;

endmodule

