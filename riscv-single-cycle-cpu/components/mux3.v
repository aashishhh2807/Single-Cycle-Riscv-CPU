
// mux3.v - logic for 3-to-1 multiplexer

// Module: mux3
// Description: Parameterized 3-to-1 multiplexer.
//              Selects one of three WIDTH-bit inputs based on 2-bit select signal.
// Parameters:
//   WIDTH - Bit-width of inputs and output (default is 8 bits)
// Ports:
//   d0, d1, d2 - Inputs to select from
//   sel         - 2-bit select signal
//   y           - Output, reflects the selected input

module mux3 #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] d0,  // Input 0
    input  [WIDTH-1:0] d1,  // Input 1
    input  [WIDTH-1:0] d2,  // Input 2
    input  [1:0]       sel, // 2-bit select signal
    output [WIDTH-1:0] y    // Output
);

    // Continuous assignment for 3-to-1 multiplexer
    // Priority: sel[1] has highest priority
    // If sel[1] = 1, output = d2
    // Else if sel[0] = 1, output = d1
    // Else output = d0
    assign y = sel[1] ? d2 : (sel[0] ? d1 : d0);

endmodule

