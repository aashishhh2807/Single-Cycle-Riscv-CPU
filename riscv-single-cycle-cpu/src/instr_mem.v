
/*
# Filename:         instr_mem.v
# File Description: Instruction memory module for RISC-V CPU. Stores instructions and provides word-aligned read access.
# Global variables: None
*/

// Module: instr_mem
// Description: Instruction memory for RISC-V CPU.
//              Stores instructions and provides word-aligned read access.
// Parameters:
//   DATA_WIDTH - Width of each instruction (default 32 bits)
//   ADDR_WIDTH - Width of instruction address (default 32 bits)
//   MEM_SIZE   - Number of instructions in memory (default 512)
// Ports:
//   instr_addr - Address of instruction to read
//   instr      - Output instruction

module instr_mem #(
    // Parameter definitions
    parameter DATA_WIDTH = 32,  // Width of each instruction word
    parameter ADDR_WIDTH = 32,  // Width of instruction address
    parameter MEM_SIZE   = 512  // Total number of instructions in memory
)(
    input  [ADDR_WIDTH-1:0] instr_addr,  // Address of instruction to read
    output [DATA_WIDTH-1:0] instr        // Output instruction corresponding to instr_addr
);

    // Memory array to store instructions
    // instr_ram[0] to instr_ram[MEM_SIZE-1], each DATA_WIDTH bits wide
    reg [DATA_WIDTH-1:0] instr_ram [0:MEM_SIZE-1];

    /*
    Purpose:
    ---
    Initialize instruction memory from a hex file.
    This allows the CPU to start execution with predefined instructions.
    */
    initial begin
        //$readmemh("rv32i_book.hex", instr_ram);  // Load instructions from standard hex file
        $readmemh("rv32i_test.hex", instr_ram); // Load instructions from alternative test file
    end

    /*
    Purpose:
    ---
    Provide combinational, word-aligned read access to instruction memory.
    Since instructions are 4 bytes each, the lower 2 bits of the address are ignored.
    */
    assign instr = instr_ram[instr_addr[31:2]];

endmodule



