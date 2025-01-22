// 32X32 Multiplier test template
module mult32x32_test;
    logic clk;            // Clock
    logic reset;          // Reset
    logic start;          // Start signal
    logic [31:0] a;       // Input a
    logic [31:0] b;       // Input b
    logic busy;           // Multiplier busy indication
    logic [63:0] product; // Multiplication product

    // Instance of the multiplier
    mult32x32 uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .a(a),
        .b(b),
        .busy(busy),
        .product(product)
    );

    // Add state probing - updated to use direct reference
    bind mult32x32_fsm mult32x32_test_probe probe (
        .current_state(current),
        .next_state(next)
    );
    
    // Clock generator
    always begin
        #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        clk = 1;
        reset = 1'b1;
        start = 0;
        a = 0;
        b = 0;
    
        // Hold reset for 4 clock cycles
        repeat (4) @(posedge clk);
        reset = 1'b0;
    
        // Set input values
        a = 32'd322979956;
        b = 32'd300086550;
    
        // Wait one clock cycle before asserting start
        @(posedge clk);
        start = 1'b1;
    
        // Hold start for one clock cycle
        @(posedge clk);
        start = 1'b0;
    
        // Wait for busy to go low
        wait(!busy);
    
        // Add a few more cycles to observe the stable output
        repeat(5) @(posedge clk);
    
        // End simulation
        $finish;
    end

    // Monitoring
    initial begin
        $timeformat(-9, 2, " ns", 10);
        $monitor("Time=%t reset=%b start=%b busy=%b a=%d b=%d product=%d",
                 $time, reset, start, busy, a, b, product);
    end
endmodule

// State probe interface module
module mult32x32_test_probe (
    input logic [3:0] current_state,
    input logic [3:0] next_state
);
endmodule