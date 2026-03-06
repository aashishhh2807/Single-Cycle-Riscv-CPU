/*
# Filename:         main_decoder.v
# File Description: Main control logic for RISC-V CPU; generates control signals based on opcode and funct3
# Global variables: None
*/

// main_decoder.v - logic for main decoder
//=========================================================
// Module: main_decoder
// Description: Generates control signals for RISC-V instructions based on opcode and other inputs
// Inputs:
//   op      - 7-bit opcode of the instruction
//   funct3  - 3-bit funct3 field (used for branch decisions)
//   Zero    - Zero flag from ALU
//   ALUR31  - Most significant bit from ALU result (for signed comparisons)
//   ltu_flag - Flag for unsigned comparison (BLTU/BGEU)
// Outputs:
//   ResultSrc - Selects data to write back to register file
//   MemWrite  - Memory write enable
//   Branch    - Branch signal
//   ALUSrc    - ALU input select: 0=register, 1=immediate
//   RegWrite  - Register file write enable
//   Jump      - Jump signal
//   Jalr      - JALR signal
//   ImmSrc    - Immediate type (I, S, B, J, U)
//   ALUOp     - Coarse ALU operation (00=ADD, 01=SUB, 10=R-type)
//=========================================================

module main_decoder (
    input  [6:0] op,             // Opcode field of instruction
    input  [2:0] funct3,         // funct3 field for instruction
    input        Zero,           // Zero flag from ALU
    input        ALUR31,         // Most significant bit of ALU result (for signed comparisons)
    input        ltu_flag,       // Flag for unsigned comparison (BLTU/BGEU)
    output [1:0] ResultSrc,      // Select what goes to register file (ALU, Mem, PC+4, etc.)
    output       MemWrite,       // Memory write enable
    output       Branch,         // Branch signal
    output       ALUSrc,         // ALU input select: 0=register, 1=immediate
    output       RegWrite,       // Register file write enable
    output       Jump,           // Jump signal
    output       Jalr,           // JALR signal
    output [1:0] ImmSrc,         // Immediate type (I, S, B, J, U)
    output [1:0] ALUOp           // Coarse ALU operation type
);

    // Single register holding all control bits (RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUOp, Jump, Jalr)
    reg [10:0] controls;

    // Temporary signal to decide whether to take a branch
    reg TakeBranch;

    // ===================================
    // Main Control Logic
    // Purpose:
    // ---
    // Generate the 11-bit control signals based on opcode and funct3
    // ===================================
    always @(*) begin
        TakeBranch = 0;  // Default branch is not taken

        case (op)
            // LW (Load Word)
            7'b0000011: controls = 11'b1_00_1_0_01_00_0_0;

            // SW (Store Word)
            7'b0100011: controls = 11'b0_01_1_1_00_00_0_0;

            // R-type ALU instructions (ADD, SUB, AND, OR, etc.)
            7'b0110011: controls = 11'b1_xx_0_0_00_10_0_0;

            // BEQ/BNE/BLT/BGE/BLTU/BGEU
            7'b1100011: begin
                controls = 11'b0_10_0_0_00_01_0_0;

                /*
                Purpose:
                ---
                Determine if the branch should be taken based on funct3 and ALU flags
                */
                case(funct3)
                    3'b000: TakeBranch = Zero;         // BEQ
                    3'b001: TakeBranch = !Zero;        // BNE
                    3'b101: TakeBranch = !ALUR31;      // BGE
                    3'b100: TakeBranch = ALUR31;       // BLT
                    3'b110: TakeBranch = (ltu_flag) ? 1'b1 : 1'b0; // BLTU
                    3'b111: TakeBranch = (!ltu_flag) ? 1'b1 : 1'b0; // BGEU
                endcase
            end

            // I-type ALU (ADDI, ANDI, ORI, etc.)
            7'b0010011: controls = 11'b1_00_1_0_00_10_0_0;

            // JAL (Jump and Link)
            7'b1101111: controls = 11'b1_11_0_0_10_00_1_0;

            // LUI (Load Upper Immediate)
            7'b0110111: controls = 11'b1_xx_x_0_11_xx_0_0;

            // AUIPC (Add Upper Immediate to PC)
            7'b0010111: controls = 11'b1_xx_x_0_11_xx_0_0;

            // JALR
            7'b1100111: controls = 11'b1_00_1_0_10_00_0_1;

            // Default: invalid opcode
            default: controls = 11'bx_xx_x_x_xx_xx_x_x;
        endcase
    end

    // ===================================
    // Assign unpacked control signals
    // Purpose:
    // ---
    // Break the 11-bit "controls" register into individual output signals
    // ===================================
    assign Branch = TakeBranch;

    assign {RegWrite,   // Bit[10]
            ImmSrc,     // Bits[9:8]
            ALUSrc,     // Bit[7]
            MemWrite,   // Bit[6]
            ResultSrc,  // Bits[5:4]     
            ALUOp,      // Bits[3:2]
            Jump,       // Bit[1]
            Jalr}       // Bit[0]
          = controls;

endmodule



