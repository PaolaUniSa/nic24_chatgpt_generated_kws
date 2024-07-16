module tb_neuron_delay;

    // Inputs
    reg sys_clk;
    reg reset;
    reg delay_clk;
    reg [2:0] delay_value;
    reg delay;
    reg din;

    // Outputs
    wire dout;

    // Instantiate the Unit Under Test (UUT)
    neuron_delay uut (
        .sys_clk(sys_clk),
        .reset(reset),
        .delay_clk(delay_clk),
        .delay_value(delay_value),
        .delay(delay),
        .din(din),
        .dout(dout)
    );

    // System clock generation
    always #5 sys_clk = ~sys_clk; // 10ns period system clock

    // Delay clock generation
    always #7 delay_clk = ~delay_clk; // 14ns period delay clock

    initial begin
        // Initialize Inputs
        sys_clk = 0;
        delay_clk = 0;
        reset = 0;
        delay_value = 3'd0; // Default delay to 4 clock cycles
        delay = 1;
        din = 1;

        // Apply reset
        apply_reset();

        // Test sequences
        delay = 1;
        #30; // Delay for 30ns
        din = 1;
        #20;
        din = 0;
        #20;

        delay = 1;
        delay_value = 3'd4;
        din = 1;
        #20;
        din = 0;
        #100; // Wait to observe the delayed output

        delay_value = 3'd2;
        din = 1;
        #20;
        din = 0;
        #60; // Wait to observe the delayed output

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

    initial begin
        // Monitor signals
        $monitor("At time %t, sys_clk = %b, delay_clk = %b, reset = %b, delay_value = %d, delay = %b, din = %b, dout = %b", 
                 $time, sys_clk, delay_clk, reset, delay_value, delay, din, dout);
    end

endmodule
