
/*
# Filename:         reset_ff.v
# File Description: Parameterized width D flip-flop with synchronous data input and asynchronous reset
# Global variables: None
*/

module reset_ff #(parameter WIDTH = 8) (
    input                   clk,  // Clock signal, rising edge triggered
    input                   rst,  // Asynchronous reset signal (active high)
    input  [WIDTH-1:0]      d,    // Data input of WIDTH bits
    output reg [WIDTH-1:0]  q     // Output register storing current value of the flip-flop
);

    /*
    Purpose:
    ---
    Implements a parameterized WIDTH D flip-flop with synchronous data capture and asynchronous reset.
    The output q is updated with input d on the rising edge of clk unless rst is high, in which case q resets to 0.
    */
    always @(posedge clk or posedge rst) begin
        if (rst) 
            q <= 0;       // Asynchronous reset: set output q to 0 when reset is high
        else     
            q <= d;       // On rising clock edge, capture the input data d into output q
    end

endmodule



