// 32X32 Multiplier FSM
module mult32x32_fsm (
    input logic clk,              // Clock
    input logic reset,            // Reset
    input logic start,            // Start signal
    output logic busy,            // Multiplier busy indication
    output logic [1:0] a_sel,     // Select one byte from A
    output logic b_sel,           // Select one 2-byte word from B
    output logic [2:0] shift_sel, // Select output from shifters
    output logic upd_prod,        // Update the product register
    output logic clr_prod,        // Clear the product register
    output logic [1:0] current_state,
    output logic [1:0] next_state
);

// State definitions
localparam [3:0] IDLE  = 4'd0,
                 A0_B0 = 4'd1,
                 A1_B0 = 4'd2,
                 A2_B0 = 4'd3,
                 A3_B0 = 4'd4,
                 A0_B1 = 4'd5,
                 A1_B1 = 4'd6,
                 A2_B1 = 4'd7,
                 A3_B1 = 4'd8;

logic [3:0] current, next;

// Next state sampling
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        current <= IDLE;
    end
    else begin
        current <= next;
    end
end
    
// State transitions
always_comb begin
    clr_prod = 1'b0; 
    busy = 1'b1;
    upd_prod = 1'b1; 
    a_sel = 2'b00;
    b_sel = 1'b0;
    shift_sel = 3'b000;
    next = current;
    
    case (current)
        IDLE: begin 
            if (start == 1'b1) begin
                busy = 1'b0;
                clr_prod = 1'b1;    
                upd_prod = 1'b0;
                next = A0_B0;
            end
            else begin
                busy = 1'b0;
                upd_prod = 1'b0; 
            end
        end
        
        A0_B0: begin
            next = A1_B0;
            a_sel = 2'b00;
            b_sel = 1'b0;
            shift_sel = 3'b000;
        end
            
        A1_B0: begin
            next = A2_B0;
            a_sel = 2'b01;
            b_sel = 1'b0;
            shift_sel = 3'b001;
        end
        
        A2_B0: begin
            next = A3_B0;
            a_sel = 2'b10;
            b_sel = 1'b0;
            shift_sel = 3'b010;
        end    
        
        A3_B0: begin
            next = A0_B1;
            a_sel = 2'b11;
            b_sel = 1'b0;
            shift_sel = 3'b011;
        end    
        
        A0_B1: begin
            next = A1_B1;
            a_sel = 2'b00;
            b_sel = 1'b1;
            shift_sel = 3'b010;
        end    
        
        A1_B1: begin
            next = A2_B1;
            a_sel = 2'b01;
            b_sel = 1'b1;
            shift_sel = 3'b011;
        end        
        
        A2_B1: begin
            next = A3_B1;
            a_sel = 2'b10;
            b_sel = 1'b1;
            shift_sel = 3'b100;
        end        
        
        A3_B1: begin
            next = IDLE;
            a_sel = 2'b11;
            b_sel = 1'b1;
            shift_sel = 3'b101;
        end            
    endcase
end

// Convert state to output
assign current_state = current[1:0];
assign next_state = next[1:0];

endmodule