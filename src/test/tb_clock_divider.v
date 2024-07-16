module tb_clock_divider;

    // Testbench signals
    reg clk;                    // Clock signal
    reg reset;                  // Reset signal
    reg enable;                 // Enable signal
    reg [7:0] div_value;        // 8-bit Divider value
    wire clk_out;               // Output clock signal

    // Instantiate the clock divider module
    clock_divider uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .div_value(div_value),
        .clk_out(clk_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end

    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1;
        enable = 0;
        div_value = 8'd0;
        #20;
        
        // Release reset
        reset = 0;
        enable = 1;
        #20;
        
        // Test with div_value = 2
        div_value = 8'd1;       // Divide by 4
        #100;
        
        // Disable clock divider
        enable = 0;
        #50;
        
        // Enable clock divider again
        enable = 1;
        #100;
        
        // Test with div_value = 4
        div_value = 8'd3;       // Divide by 8
        #100;
        
        // Test with div_value = 8
        div_value = 8'd7;       // Divide by 16
        #100;
        
        // Test with div_value = 16
        div_value = 8'd15;      // Divide by 32
        #100;

        // Finish simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time: %0t | clk: %b | reset: %b | enable: %b | div_value: %d | clk_out: %b", 
                  $time, clk, reset, enable, div_value, clk_out);
    end

endmodule
