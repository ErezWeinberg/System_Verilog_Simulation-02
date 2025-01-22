module mult32x32_fast_fsm (
    input logic clk,              // Clock
    input logic reset,            // Reset
    input logic start,            // Start signal
    input logic a_msb_is_0,       // Indicates MSB of operand A is 0
    input logic b_msw_is_0,       // Indicates MSW of operand B is 0
    output logic busy,            // Multiplier busy indication
    output logic [1:0] a_sel,     // Select one byte from A
    output logic b_sel,           // Select one 2-byte word from B
    output logic [2:0] shift_sel, // Select output from shifters
    output logic upd_prod,        // Update the product register
    output logic clr_prod         // Clear the product register
);

    typedef enum {idle, a0_b0, a1_b0, a2_b0, a3_b0, a0_b1, a1_b1, a2_b1, a3_b1} sm_type;
    sm_type current, next;
    
    // Next state sampling
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            current <= idle;
        end
        else begin
            current <= next;
        end
    end
    
    // State transitions
    always_comb begin
        // Default values
        busy = 1'b1;          // Busy by default except in idle
        clr_prod = 1'b0;      // Don't clear by default
        upd_prod = 1'b1;      // Update product by default
        a_sel = 2'b00;        // Default byte selection
        b_sel = 1'b0;         // Default word selection
        shift_sel = 3'b000;   // Default shift selection
        next = current;       // Stay in current state by default
        
        case (current)
            idle: begin 
                busy = 1'b0;      // Not busy in idle
                upd_prod = 1'b0;  // Don't update in idle
                if (start) begin
                    next = a0_b0;
                    clr_prod = 1'b1;  // Clear when starting
                    busy = 1'b1;      // Become busy when starting
                end
            end
            
            a0_b0: begin
                a_sel = 2'b00;
                b_sel = 1'b0;
                shift_sel = 3'b000;
                next = a1_b0;
            end
            
            a1_b0: begin
                a_sel = 2'b01;
                b_sel = 1'b0;
                shift_sel = 3'b001;
                next = a2_b0;
            end
            
            a2_b0: begin
                a_sel = 2'b10;
                b_sel = 1'b0;
                shift_sel = 3'b010;
                next = a3_b0;
            end
            
            a3_b0: begin
                a_sel = 2'b11;
                b_sel = 1'b0;
                shift_sel = 3'b011;
                if (b_msw_is_0) begin
                    next = idle;
                end
                else begin
                    next = a0_b1;
                end
            end
            
            a0_b1: begin
                a_sel = 2'b00;
                b_sel = 1'b1;
                shift_sel = 3'b010;
                next = a1_b1;
            end
            
            a1_b1: begin
                a_sel = 2'b01;
                b_sel = 1'b1;
                shift_sel = 3'b011;
                next = a2_b1;
            end
            
            a2_b1: begin
                a_sel = 2'b10;
                b_sel = 1'b1;
                shift_sel = 3'b100;
                next = a3_b1;
            end
            
            a3_b1: begin
                a_sel = 2'b11;
                b_sel = 1'b1;
                shift_sel = 3'b101;
                next = idle;
            end
            
            default: next = idle;
        endcase
    end

endmodule