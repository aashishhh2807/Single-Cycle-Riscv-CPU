/*
# Filename:         datapath.v
# File Description: Datapath module for single-cycle RISC-V CPU
#                   Implements PC update, register file, ALU operations, 
#                   immediate generation, and memory interface
# Global variables: None
*/

// datapath.v
//====================================================
// Datapath for RISC-V CPU
// - Implements instruction execution flow
// - Includes PC update, register file, ALU, and mux logic
//====================================================
module datapath (
    input         clk, reset,           // Clock and Reset
    input [1:0]   ResultSrc,            // Selects final result (ALU, Memory, or PC+4)
    input         PCSrc,                // Selects next PC (PC+4 or branch target)
    input         ALUSrc,               // Selects ALU operand source (register or immediate)
    input         RegWrite,             // Enables writing back to register file
    input [1:0]   ImmSrc,               // Selects type of immediate extension (I, S, B, J)
    input [3:0]   ALUControl,           // Operation control for ALU
    input         Jalr,                 // JALR instruction flag
    output        Zero,                 // Zero flag from ALU (for branch decisions)
    output        ALUR31,               // ALU result MSB (for comparisons)
    output        ltu_flag,             // Unsigned less-than flag from ALU
    output [31:0] PC,                   // Program Counter (current instruction address)
    input  [31:0] Instr,                // Current instruction from instruction memory
    output [31:0] Mem_WrAddr,           // Address to write in Data Memory
    output [31:0] Mem_WrData,           // Data to write in Data Memory
    input  [31:0] ReadData,             // Data read from Data Memory
    output [31:0] Result                // Final result (to be written back to register file)
);

//====================================================
// Internal signals
//====================================================
wire [31:0] PCNext, PCPlus4, PCTarget, AuiPC, LAuiPC_res, PCnew; // PC-related wires
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult;           // ALU and register file wires

//====================================================
// Program Counter (PC) Update Logic
//====================================================

// Next PC selection
// If PCSrc=0 → PC+4 (sequential)
// If PCSrc=1 → branch target
mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc, PCNext);

/*
Purpose:
---
Selects between normal PC increment and branch target for next PC.
*/
mux2 #(32) jalrmux(PCNext, ALUResult, Jalr, PCnew);

/*
Purpose:
---
Handles JALR instruction by updating PC with ALU result when Jalr=1.
*/

// PC register: holds current PC, updated on rising edge of clk
reset_ff #(32) pcreg(clk, reset, PCnew, PC);

/*
Purpose:
---
Stores current PC and updates on clock edge or reset.
*/

// PC + 4 (for sequential execution)
adder pcadd4(PC, 32'd4, PCPlus4);

/*
Purpose:
---
Calculates next sequential instruction address.
*/

// PC + Immediate (branch target address)
adder pcaddbranch(PC, ImmExt, PCTarget);

/*
Purpose:
---
Calculates branch target address by adding immediate to current PC.
*/

//====================================================
// Register File and Immediate Generation
//====================================================

// Register File: 32x32 registers
// Reads rs1 (Instr[19:15]) and rs2 (Instr[24:20])
// Writes to rd (Instr[11:7]) if RegWrite=1
reg_file rf (
    clk, RegWrite,
    Instr[19:15],    // rs1
    Instr[24:20],    // rs2
    Instr[11:7],     // rd
    Result,          // data to write back
    SrcA,            // output: register rs1 value
    WriteData        // output: register rs2 value
);

/*
Purpose:
---
Handles reading and writing of register file. SrcA and WriteData are used
as ALU operands or memory store data.
*/

// Immediate Extension Unit
// Extends instruction immediate field to 32-bit based on type (I, S, B, J)
imm_extend ext (Instr[31:7], ImmSrc, ImmExt);

/*
Purpose:
---
Generates 32-bit immediate value for ALU operations or branch calculations.
*/

//====================================================
// ALU and Operand Selection
//====================================================

// Select second ALU input:
// If ALUSrc=0 → register (WriteData)
// If ALUSrc=1 → immediate (ImmExt)
mux2 #(32) srcbmux(WriteData, ImmExt, ALUSrc, SrcB);

/*
Purpose:
---
Selects second ALU operand between register value and immediate.
*/

// Arithmetic Logic Unit (ALU)
// Performs operation based on ALUControl
// Sets Zero=1 if result == 0 (used for branch decision)
alu alu (SrcA, SrcB, ALUControl, ALUResult, Zero, ltu_flag);

/*
Purpose:
---
Executes arithmetic/logic operation on SrcA and SrcB.
*/

// Select final result to write back to register file:
// 00 → ALUResult
// 01 → ReadData (from memory)
// 10 → PC+4 (for jal, jalr)
mux4 #(32) resultmux(ALUResult, ReadData, PCPlus4, LAuiPC_res, ResultSrc, Result);

/*
Purpose:
---
Selects the correct value to write back into the register file based on instruction type.
*/

//====================================================
// Data Memory Interface
//====================================================

// Address to write/read from data memory = ALUResult
assign Mem_WrAddr = ALUResult;

/*
Purpose:
---
Memory address comes from ALU result.
*/

// Data to write to memory = register value (rs2)
assign Mem_WrData = WriteData;

/*
Purpose:
---
Stores the value of rs2 to memory for store instructions.
*/

// For LUI and AUIPC instructions
adder #(32) AuiPCadder({Instr[31:12],12'b0}, PC, AuiPC);
mux2 #(32) LAuiPCmux(AuiPC, {Instr[31:12],12'b0}, Instr[5], LAuiPC_res);

/*
Purpose:
---
Computes LUI/AUIPC results for writing back to register file.
*/

assign ALUR31 = ALUResult[31]; // MSB of ALU result

endmodule


