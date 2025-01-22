// 32X32 Multiplier arithmetic unit template
module mult32x32_arith (
    input logic clk,             // Clock
    input logic reset,           // Reset
    input logic [31:0] a,        // Input a
    input logic [31:0] b,        // Input b
    input logic [1:0] a_sel,     // Select one byte from A
    input logic b_sel,           // Select one 2-byte word from B
    input logic [2:0] shift_sel, // Select output from shifters
    input logic upd_prod,        // Update the product register
    input logic clr_prod,        // Clear the product register
    output logic [63:0] product  // Miltiplication product
);

// Put your code here
// ------------------
	logic [7:0] selector_a;
	
	always_comb begin
		if (a_sel == 2'b00) begin
			selector_a = a[7:0];
		end
		else if (a_sel == 2'b01) begin
			selector_a = a[15:8];
		end
		else if (a_sel == 2'b10) begin
			selector_a = a[23:16];
		end
		else begin 
			selector_a = a[31:24];
		end
	end
	
	logic [15:0] selector_b;
	
	always_comb begin
		if (b_sel == 1'b0) begin
			selector_b = b[15:0];
		end
		else begin 
			selector_b = b[31:16];
		end
	end
	
	logic [23:0] mul_ab;
	
	assign mul_ab = selector_b * selector_a;
	
	logic [63:0] result;
	
	always_comb begin
		if (shift_sel == 3'b000) begin
			result = {{40{1'b0}},mul_ab
    };
		end
		else if (shift_sel == 3'b001) begin
			result = {{32{1'b0}}, mul_ab
     ,{8{1'b0}}};
		end
		else if (shift_sel == 3'b010) begin
			result = {{24{1'b0}}, mul_ab
     ,{16{1'b0}}};
		end
		else if (shift_sel == 3'b011) begin
			result = {{16{1'b0}}, mul_ab
     ,{24{1'b0}}};
		end
		else if (shift_sel == 3'b100) begin
			result = {{8{1'b0}}, mul_ab
     ,{32{1'b0}}};
		end
		else if (shift_sel == 3'b101) begin
			result = {mul_ab
     ,{40{1'b0}}};
		end
		else begin
			result = 64'b0;
		end
	end

	always_ff @(posedge clk , posedge reset) begin
		if (reset == 1'b1) begin
			product <= 64'b0;
		end
		else if (clr_prod == 1'b1) begin
			product <= 64'b0;		
		end
		else if (upd_prod == 1'b1) begin
			product <= product + result;		
		end
		else begin
			product <= product;
		end
	end

// End of your code

endmodule