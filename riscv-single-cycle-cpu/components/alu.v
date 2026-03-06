
// alu.v - ALU module

// Module: alu
// Description: Parameterized-width Arithmetic Logic Unit (ALU).
//              Supports ADD, SUB, AND, OR, and SLT (set less than) operations.
// Parameters:
//   WIDTH - Bit-width of ALU operands and output (default is 32 bits)
// Ports:
//   a, b       - ALU operands
//   alu_ctrl   - Control signal to select operation
//   alu_out    - ALU output
//   zero       - Flag set when alu_out is zero

module alu #(parameter WIDTH = 32) (
    input  [WIDTH-1:0] a, b,       // ALU operands
    input  [3:0]       alu_ctrl,   // ALU operation select
    output reg [WIDTH-1:0] alu_out,// ALU output
    output             zero,        // Zero flag
	 output             ltu_flag 
);
	
	 wire [WIDTH:0] sub_ext;
	 assign ltu_flag = sub_ext[WIDTH];

    assign sub_ext = {1'b0, a} - {1'b0, b};


    // Combinational ALU logic
    // Triggered whenever a, b, or alu_ctrl changes
    always @(a, b, alu_ctrl) begin
        case (alu_ctrl)
            4'b0000:  alu_out <= a + b;        // ADD operation
            4'b0001:  alu_out <= sub_ext[WIDTH-1:0];   // SUB operation (a - b)
            4'b0010:  alu_out <= a & b;        // AND operation
            4'b0011:  alu_out <= a | b;        // OR operation
				4'b0110:  alu_out <= a ^ b;
				4'b0100:  alu_out <= a << b[4:0];
				4'b0111:  alu_out <= a >> b[4:0];
				4'b1001:  alu_out <= $signed(a) >>> b[4:0];
				4'b1000:  alu_out <= (a < b) ? 32'b1 : 32'b0;
            4'b0101:  begin                     // SLT (set less than, signed comparison)
                        if (a[31] != b[31]) 
                            alu_out <= a[31] ? 1'b1 : 1'b0; // if signs differ, negative is less
                        else 
                            alu_out <= (a < b) ? 1'b1 : 1'b0; // if same sign, compare normally
                     end
            default: alu_out = 0;               // Default output
        endcase
    end

    // Zero flag: high when ALU output is zero
    assign zero = (alu_out == 0) ? 1'b1 : 1'b0;

endmodule

