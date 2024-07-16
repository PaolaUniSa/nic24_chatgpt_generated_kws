module tb_programmable_delay;

    // Inputs
    reg clk;
    reg reset;
    reg [2:0] delay;
    reg din;

    // Outputs
    wire dout;

    // Instantiate the Unit Under Test (UUT)
    programmable_delay uut (
        .clk(clk),
        .reset(reset),
        .delay(delay),
        .din(din),
        .dout(dout)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns period clock

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        delay = 3'd5; // Default delay to 5 clock cycles
        din = 0;

        // Apply reset
        apply_reset();

        // Test sequences
        test_delay(3'd5, 50);
        test_delay(3'd3, 30);
        test_delay(3'd7, 70);

        // Finish the simulation
        $stop;
    end

    // Task to apply reset
    task apply_reset;
        begin
            reset = 1;
            #20; // Hold reset for 20ns
            reset = 0;
        end
    endtask

    // Task to test delay
    task test_delay(input [2:0] delay_value, input integer wait_time);
        begin
            delay = delay_value;
            din = 1;
            #20;
            din = 0;
            #(wait_time); // Wait to observe the output
        end
    endtask

    initial begin
        // Monitor signals
        $monitor("At time %t, clk = %b, reset = %b, delay = %d, din = %b, dout = %b", 
                 $time, clk, reset, delay, din, dout);
    end

endmodule
