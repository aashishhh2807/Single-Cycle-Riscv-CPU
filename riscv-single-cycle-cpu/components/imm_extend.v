
// imm_extend.v - logic for sign extension
// Module: imm_extend
// Description: Sign-extends immediate values from RISC-V instructions to 32-bit width.
//              Supports I-type, S-type, B-type, and J-type instructions.
// Ports:
//   instr   - Bits [31:7] of the instruction (RISC-V instruction is 32-bit)
//   immsrc  - Selects the type of immediate to extract:
//               00 -> I-type
//               01 -> S-type
//               10 -> B-type
//               11 -> J-type
//   immext  - 32-bit sign-extended immediate output

module imm_extend (
    input  [31:7]     instr,   // Instruction bits [31:7] (exclude opcode bits [6:0])
    input  [ 1:0]     immsrc,  // Immediate type selector
    output reg [31:0] immext   // Sign-extended immediate
);

    // Combinational logic to extract and sign-extend immediate
    always @(*) begin
        case(immsrc)
            // I-type: immediate is instr[31:20], sign-extended
            2'b00: immext = {{20{instr[31]}}, instr[31:20]};

            // S-type (store): immediate is instr[31:25] concatenated with instr[11:7], sign-extended
            2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type (branch): immediate is formed as {instr[31], instr[7], instr[30:25], instr[11:8], 0}, sign-extended
            2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

            // J-type (jal): immediate is {instr[31], instr[19:12], instr[20], instr[30:21], 0}, sign-extended
            2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

            // Default: undefined (for safety)
            default: immext = 32'bx;
        endcase
		  
    end

endmodule

