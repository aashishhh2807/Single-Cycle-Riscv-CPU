
// adder.v - logic for adder

// Module: adder
// Description: Parameterized width adder module. Adds two inputs 'a' and 'b' and produces 'sum'.
// Parameters:
//   WIDTH - Bit-width of inputs and output (default is 32 bits)
// Ports:
//   a    - First input operand
//   b    - Second input operand
//   sum  - Output of the addition

module adder #(parameter WIDTH = 32) (
    input  [WIDTH-1:0] a,  // First input operand of WIDTH bits
    input  [WIDTH-1:0] b,  // Second input operand of WIDTH bits
    output [WIDTH-1:0] sum // Output of WIDTH bits
);

    // Continuous assignment to perform addition
    // This is a combinational operation, no clock is needed
    assign sum = a + b;

endmodule

