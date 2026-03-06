
/*
# Filename:         alu_decoder.v
# File Description: ALU decoder logic for RISC-V CPU
#                   Converts ALUOp + instruction fields (funct3, funct7b5) into ALUControl signals
# Global variables: None
*/

module alu_decoder (
    input            opb5,       // Bit 5 of opcode: used to distinguish R-type vs I-type instructions
    input [2:0]      funct3,     // funct3 field of instruction (specifies operation)
    input            funct7b5,   // Bit 5 of funct7 field: used to differentiate add/sub and shift types
    input [1:0]      ALUOp,      // High-level ALU operation type from main_decoder
    output reg [3:0] ALUControl  // Output: exact ALU control signal for datapath ALU
);

    //=====================================================
    // Combinational ALU decoding logic
    //=====================================================
    /*
    Purpose:
    ---
    Generates the 4-bit ALUControl signal based on ALUOp from main decoder
    and instruction-specific fields (funct3, funct7b5, opb5).
    Handles Load/Store, Branch, R-type, I-type, and shift instructions.
    */
    always @(*) begin
        case (ALUOp)
            //====================================================
            // ALUOp = 00 → Load / Store instructions
            // Always perform ADD to calculate memory addresses
            //====================================================
            2'b00: ALUControl = 4'b0000;  // ADD

            //====================================================
            // ALUOp = 01 → Branch instructions (e.g., BEQ)
            // Always perform SUB to compare equality
            //====================================================
            2'b01: ALUControl = 4'b0001;  // SUB

            //====================================================
            // ALUOp = 10 → R-type / I-type instructions
            // Decoding based on funct3 and funct7b5 fields
            //====================================================
            default: begin
                case (funct3)
                    //------------------------------------------------
                    // funct3 = 000 → ADD / SUB / ADDI
                    // - If funct7b5=1 & opb5=1 → SUB (R-type sub)
                    // - Else → ADD (R-type add or I-type addi)
                    //------------------------------------------------
                    3'b000: begin
                        if (funct7b5 & opb5)
                            ALUControl = 4'b0001; // SUB
                        else
                            ALUControl = 4'b0000; // ADD / ADDI
                    end

                    //------------------------------------------------
                    // funct3 = 010 → SLT / SLTI (set less than)
                    //------------------------------------------------
                    3'b010: ALUControl = 4'b0101;

                    //------------------------------------------------
                    // funct3 = 011 → SLTU / SLTUI (set less than unsigned)
                    //------------------------------------------------
                    3'b011: ALUControl = 4'b1000;

                    //------------------------------------------------
                    // funct3 = 100 → XOR / XORI
                    //------------------------------------------------
                    3'b100: ALUControl = 4'b0110;

                    //------------------------------------------------
                    // funct3 = 110 → OR / ORI
                    //------------------------------------------------
                    3'b110: ALUControl = 4'b0011;

                    //------------------------------------------------
                    // funct3 = 111 → AND / ANDI
                    //------------------------------------------------
                    3'b111: ALUControl = 4'b0010;

                    //------------------------------------------------
                    // funct3 = 001 → SLL / SLLI (shift left logical)
                    //------------------------------------------------
                    3'b001: ALUControl = 4'b0100;

                    //------------------------------------------------
                    // funct3 = 101 → SRL / SRLI / SRA / SRAI (shift right)
                    // - If funct7b5 = 0 → logical shift (SRL / SRLI)
                    // - Else → arithmetic shift (SRA / SRAI)
                    //------------------------------------------------
                    3'b101: begin
                        if (!funct7b5)
                            ALUControl = 4'b0111; // SRL / SRLI
                        else
                            ALUControl = 4'b1001; // SRA / SRAI
                    end

                    //------------------------------------------------
                    // Default case → invalid / unsupported instruction
                    //------------------------------------------------
                    default: ALUControl = 4'bxxxx; // Unknown / illegal instruction
                endcase
            end
        endcase
    end

endmodule
