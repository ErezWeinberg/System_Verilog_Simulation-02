module mult32x32_fast_test;
    logic clk;            
    logic reset;          
    logic start;          
    logic [31:0] a;       
    logic [31:0] b;       
    logic busy;           
    logic [63:0] product;
    
    // DUT instantiation
    mult32x32_fast uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .a(a),
        .b(b),
        .busy(busy),
        .product(product)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize
        reset = 1'b1;
        start = 1'b0;
        a = 32'h0;
        b = 32'h0;

        // Reset for exactly 4 clock cycles
        repeat(4) @(posedge clk);
        reset = 1'b0;
        
        // First test case: Full ID numbers
        @(posedge clk);
        a = 32'h13404874; // 322979956 בהקסה
        b = 32'h11E2F516; // 300086550 בהקסה
        
        @(posedge clk); // Wait one cycle
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        
        // Wait for first multiplication to complete
        wait(!busy);
        repeat(2) @(posedge clk); // Wait 2 cycles after first multiplication
        
        // Second test case: IDs with zeroed MSBs
        a = 32'h00004874; // אותו מספר עם אפסים בבתים העליונים
        b = 32'h0000F516; // אותו מספר עם אפסים בבתים העליונים
        
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        
        // Wait for second multiplication
        wait(!busy);
        
        // Add extra cycles to see final results clearly
        repeat(10) @(posedge clk);
        
        $stop;  
    end

    // Result monitoring
    always @(posedge clk) begin
        if (!busy && product != 0) begin
            $display("Time=%0t a=%h b=%h product=%h", $time, a, b, product);
        end
    end
endmodule