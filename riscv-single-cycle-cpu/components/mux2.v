
// mux2.v - logic for 2-to-1 multiplexer

// Module: mux2
// Description: Parameterized 2-to-1 multiplexer.
//              Selects between two WIDTH-bit inputs based on the select signal 'sel'.
// Parameters:
//   WIDTH - Bit-width of inputs and output (default is 8 bits)
// Ports:
//   d0   - First input
//   d1   - Second input
//   sel  - Select signal (0 selects d0, 1 selects d1)
//   y    - Output, reflects either d0 or d1 based on sel

module mux2 #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] d0,  // Input 0
    input  [WIDTH-1:0] d1,  // Input 1
    input              sel,  // Select signal
    output [WIDTH-1:0] y     // Output
);

    // Continuous assignment for multiplexer
    // If sel = 0, y = d0; if sel = 1, y = d1
    assign y = sel ? d1 : d0;

endmodule

