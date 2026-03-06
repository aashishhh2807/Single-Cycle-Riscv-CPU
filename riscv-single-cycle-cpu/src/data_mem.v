
/*
# Filename:         data_mem.v
# File Description: Parameterized data memory module for RISC-V CPU. Supports
#                   synchronous write and combinational read with byte, halfword,
#                   and word access.
# Global variables: None
*/

// Module: data_mem
// Description: Parameterized data memory with synchronous write and combinational read.
//              Supports word-aligned access for 32-bit words.
// Parameters:
//   DATA_WIDTH - Width of each memory word (default 32 bits)
//   ADDR_WIDTH - Width of the address bus (default 32 bits)
//   MEM_SIZE   - Number of memory words (default 64)
// Ports:
//   clk         - Clock signal for synchronous write
//   wr_en       - Write enable
//   funct3      - Determines size of read/write (byte, halfword, word)
//   wr_addr     - Write/read address
//   wr_data     - Data to write
//   rd_data_mem - Data output (read from memory)
module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64) (
    input  clk,                  // Clock signal for synchronous write
    input  wr_en,                // Write enable
    input  [2:0] funct3,         // Function field indicating byte/halfword/word operation
    input  [ADDR_WIDTH-1:0] wr_addr, // Address for read/write
    input  [DATA_WIDTH-1:0] wr_data, // Data to write
    output reg [DATA_WIDTH-1:0] rd_data_mem // Data read from memory
);

    // Memory array declaration
    reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1]; // Array of memory words

    // Word-aligned address calculation
    wire [ADDR_WIDTH-1:0] word_addr = wr_addr[ADDR_WIDTH-1:2] % 64; // Align to word boundary and wrap within MEM_SIZE

    //====================================================
    // Synchronous write block
    // Purpose:
    // --- 
    // Writes data to memory on rising edge of clk if wr_en is high.
    // Supports byte (lb), halfword (lh), and word (lw) writes depending on funct3.
    //====================================================
    always @(posedge clk) begin
        if (wr_en) begin
            case(funct3)
                3'b000: begin // sb - store byte
                    case(wr_addr[1:0])
                        2'b00: data_ram[word_addr][7:0]   = wr_data[7:0];
                        2'b01: data_ram[word_addr][15:8]  = wr_data[7:0];
                        2'b10: data_ram[word_addr][23:16] = wr_data[7:0];
                        2'b11: data_ram[word_addr][31:24] = wr_data[7:0];
                    endcase
                end
                3'b010: data_ram[word_addr] <= wr_data; // sw - store word
                3'b001: begin // sh - store halfword
                    case(wr_addr[1])
                        1'b0: data_ram[word_addr][15:0]  = wr_data[15:0];
                        1'b1: data_ram[word_addr][31:16] = wr_data[15:0];
                    endcase
                end
            endcase
        end
    end

    //====================================================
    // Combinational read block
    // Purpose:
    // ---
    // Reads data from memory based on wr_addr and funct3.
    // Sign-extends or zero-extends for byte/halfword accesses as needed.
    //====================================================
    always @(*) begin
        case(funct3)
            3'b000: begin // lb - load byte (sign-extended)
                case(wr_addr[1:0])
                    2'b00: rd_data_mem = {{24{data_ram[word_addr][7]}},  data_ram[word_addr][7:0]};
                    2'b01: rd_data_mem = {{24{data_ram[word_addr][15]}}, data_ram[word_addr][15:8]};
                    2'b10: rd_data_mem = {{24{data_ram[word_addr][23]}}, data_ram[word_addr][23:16]};
                    2'b11: rd_data_mem = {{24{data_ram[word_addr][31]}}, data_ram[word_addr][31:24]};
                endcase
            end
            3'b100: begin // lbu - load byte unsigned (zero-extended)
                case(wr_addr[1:0])
                    2'b00: rd_data_mem = {24'b0, data_ram[word_addr][7:0]};
                    2'b01: rd_data_mem = {24'b0, data_ram[word_addr][15:8]};
                    2'b10: rd_data_mem = {24'b0, data_ram[word_addr][23:16]};
                    2'b11: rd_data_mem = {24'b0, data_ram[word_addr][31:24]};
                endcase
            end
            3'b010: rd_data_mem = data_ram[word_addr]; // lw - load word
            3'b001: begin // lh - load halfword (sign-extended)
                case(wr_addr[1])
                    1'b0: rd_data_mem = {{16{data_ram[word_addr][15]}}, data_ram[word_addr][15:0]};
                    1'b1: rd_data_mem = {{16{data_ram[word_addr][31]}}, data_ram[word_addr][31:16]};
                endcase
            end
            3'b101: begin // lhu - load halfword unsigned (zero-extended)
                case(wr_addr[1])
                    1'b0: rd_data_mem = {16'b0, data_ram[word_addr][15:0]};
                    1'b1: rd_data_mem = {16'b0, data_ram[word_addr][31:16]};
                endcase
            end
            default: rd_data_mem = 32'b0; // Default value to prevent X
        endcase
    end

endmodule


