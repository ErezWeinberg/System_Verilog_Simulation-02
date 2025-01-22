// 32X32 Iterative Multiplier template
module mult32x32 (
    input logic clk,            // Clock
    input logic reset,          // Reset
    input logic start,          // Start signal
    input logic [31:0] a,       // Input a
    input logic [31:0] b,       // Input b
    output logic busy,          // Multiplier busy indication
    output logic [63:0] product // Multiplication product
);

    // Internal signals
    logic [1:0] a_sel;
    logic b_sel;
    logic [2:0] shift_sel;
    logic upd_prod;
    logic clr_prod;
    logic a_msb_is_0;
    logic b_msw_is_0;
    wire [1:0] current_state;  // Changed back to 2-bit
    wire [1:0] next_state;     // Changed back to 2-bit
    
    mult32x32_arith arith1 (
        .clk(clk),
        .reset(reset), 
        .a(a), 
        .b(b), 
        .a_sel(a_sel), 
        .b_sel(b_sel),
        .a_msb_is_0(a_msb_is_0),
        .b_msw_is_0(b_msw_is_0),
        .shift_sel(shift_sel),
        .upd_prod(upd_prod),
        .clr_prod(clr_prod),
        .product(product)
    );
    
    mult32x32_fsm fsm1 (
        .clk(clk),
        .reset(reset),
        .start(start),
        .busy(busy),
        .a_sel(a_sel),
        .b_sel(b_sel), 
        .shift_sel(shift_sel),
        .upd_prod(upd_prod),
        .clr_prod(clr_prod),
        .current_state(current_state),
        .next_state(next_state)
    );

endmodule