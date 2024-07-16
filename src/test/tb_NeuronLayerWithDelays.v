module TwoLayerNetwork_tb;

    // Parameters
    parameter M1 = 20;
    parameter N1 = 8;
    parameter M2 = 8;
    parameter N2 = 2;

    // Testbench signals
    reg clk;
    reg reset;
    reg enable;
    reg delay_clk;
    reg [M1-1:0] input_spikes;
    reg [N1*M1*8-1:0] weights1;
    reg [N2*M2*8-1:0] weights2;
    reg [7:0] threshold;
    reg [7:0] decay;
    reg [7:0] refractory_period;
    reg [N1*M1*3-1:0] delay_values1;
    reg [N1*M1-1:0] delays1;
    reg [N2*M2*3-1:0] delay_values2;
    reg [N2*M2-1:0] delays2;
    wire [N2-1:0] output_spikes;

    // Instantiate the DUT (Device Under Test)
    TwoLayerNetwork dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .delay_clk(delay_clk),
        .input_spikes(input_spikes),
        .weights1(weights1),
        .weights2(weights2),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .delay_values1(delay_values1),
        .delays1(delays1),
        .delay_values2(delay_values2),
        .delays2(delays2),
        .output_spikes(output_spikes)
    );

    // Clock generation
    always #5 clk = ~clk;
    always #10 delay_clk = ~delay_clk;

    // Task to initialize inputs
    task initialize_inputs;
        begin
            clk = 0;
            delay_clk = 0;
            reset = 1;
            enable = 0;
            input_spikes = 0;
            weights1 = {N1*M1*8{1'b0}};
            weights2 = {N2*M2*8{1'b0}};
            threshold = 8'hFF;
            decay = 8'h00;
            refractory_period = 8'h10;
            delay_values1 = {N1*M1*3{1'b0}};
            delays1 = {N1*M1{1'b0}};
            delay_values2 = {N2*M2*3{1'b0}};
            delays2 = {N2*M2{1'b0}};
        end
    endtask

    // Task to apply a reset
    task apply_reset;
        begin
            reset = 1;
            #20;
            reset = 0;
        end
    endtask

    // Task to enable the DUT
    task enable_dut;
        begin
            enable = 1;
        end
    endtask

    // Task to load weights
    task load_weights;
        input [N1*M1*8-1:0] w1;
        input [N2*M2*8-1:0] w2;
        begin
            weights1 = w1;
            weights2 = w2;
        end
    endtask

    // Task to apply input spikes
    task apply_input_spikes;
        input [M1-1:0] spikes;
        begin
            input_spikes = spikes;
        end
    endtask

    // Function to check output
    function check_output;
        input [N2-1:0] expected_spikes;
        begin
            if (output_spikes !== expected_spikes) begin
                $display("Test failed: Expected %b, got %b", expected_spikes, output_spikes);
                check_output = 0;
            end else begin
                $display("Test passed: Got %b", output_spikes);
                check_output = 1;
            end
        end
    endfunction

    // Test sequence
    initial begin
        // Initialize inputs
        initialize_inputs;
        
        // Apply reset
        apply_reset;

        // Load weights
        load_weights({N1*M1*8{1'b1}}, {N2*M2*8{1'b1}});

        // Enable the DUT
        enable_dut;

        // Apply input spikes and check output
        apply_input_spikes(20'b00000000000000000001);
        #20;
        if (!check_output(2'b00)) $stop;

        apply_input_spikes(20'b11111111111111111111);
        #20;
        //if (!check_output(2'b11)) $stop;

        // New Test Case
        // Weights = 4, Threshold = 16, Delays = 1, Delay_values = 0, Input_spikes = 1, Wait 50 clock cycles
        $display("Running new test case with specified parameters...");
        load_weights({N1*M1*8{8'd4}}, {N2*M2*8{8'd4}});
        threshold = 8'd16;
        decay = 8'h00;
        refractory_period = 8'h10;
        delays1 = {N1*M1{1'b0}};
        delay_values1 = {N1*M1*3{1'b0}};
        delays2 = {N2*M2{1'b1}};
        delay_values2 = {N2*M2*3{1'b0}};
        apply_input_spikes(20'b11111111111111111111);
        #300;
        if (!check_output(2'b00)) $stop;

        $display("All tests passed.");
        $stop;
    end

endmodule
