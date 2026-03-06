
// mux4.v - logic for 4-to-1 multiplexer

// Module: mux4
// Description: Parameterized 4-to-1 multiplexer.
//              Selects one of four WIDTH-bit inputs based on 2-bit select signal.
// Parameters:
//   WIDTH - Bit-width of inputs and output (default is 8 bits)
// Ports:
//   d0, d1, d2, d3 - Inputs to select from
//   sel             - 2-bit select signal
//   y               - Output, reflects the selected input

module mux4 #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] d0,  // Input 0
    input  [WIDTH-1:0] d1,  // Input 1
    input  [WIDTH-1:0] d2,  // Input 2
    input  [WIDTH-1:0] d3,  // Input 3
    input  [1:0]       sel, // 2-bit select signal
    output [WIDTH-1:0] y    // Output
);

    // Continuous assignment using nested ternary operators
    // Priority based on sel[1] and sel[0]:
    // sel = 00 → y = d0
    // sel = 01 → y = d1
    // sel = 10 → y = d2
    // sel = 11 → y = d3
    assign y = sel[1] ? (sel[0] ? d3 : d2) : (sel[0] ? d1 : d0);

endmodule

