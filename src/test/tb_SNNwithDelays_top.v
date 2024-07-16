//module tb_SNNwithDelays_top();

//    // Parameters
//    parameter CLK_PERIOD = 10;
//    parameter DELAY_CLK_PERIOD = 20;

//    // Inputs
//    reg clk;
//    reg reset;
//    reg enable;
//    reg delay_clk;
//    reg [23:0] input_spikes;
//    reg [(24*8+8*2)*8-1:0] weights;
//    reg [7:0] threshold;
//    reg [7:0] decay;
//    reg [7:0] refractory_period;
//    reg [(8*24+8*2)*4-1:0] delays;

//    // Outputs
//    wire [79:0] membrane_potential_out;
//    wire [7:0] output_spikes_layer1;
//    wire [1:0] output_spikes;

//    // Instantiate the Unit Under Test (UUT)
//    SNNwithDelays_top uut (
//        .clk(clk), 
//        .reset(reset), 
//        .enable(enable), 
//        .delay_clk(delay_clk), 
//        .input_spikes(input_spikes), 
//        .weights(weights), 
//        .threshold(threshold), 
//        .decay(decay), 
//        .refractory_period(refractory_period), 
//        .delays(delays), 
//        .membrane_potential_out(membrane_potential_out), 
//        .output_spikes_layer1(output_spikes_layer1), 
//        .output_spikes(output_spikes)
//    );

//    // Clock Generation
//    initial begin
//        clk = 0;
//        forever #(CLK_PERIOD/2) clk = ~clk;
//    end
    
//    initial begin
//        delay_clk = 0;
//        forever #(DELAY_CLK_PERIOD/2) delay_clk = ~delay_clk;
//    end

//    // Testbench Tasks
//    task reset_dut();
//        begin
//            reset = 1;
//            #20;
//            reset = 0;
//        end
//    endtask

//    task configure_inputs();
//        input [23:0] spikes;
//        input [7:0] th;
//        input [7:0] de;
//        input [7:0] ref_per;
//        input [(8*24+8*2)*4-1:0] del;
//        integer i;
//        begin
        
        
//            input_spikes = spikes;
//            threshold = th;
//            decay = de;
//            refractory_period = ref_per;
//            delays = del;

//            // Set all weights to 8'h7F
//            for (i = 0; i < (24*8 + 8*2); i = i + 1) begin
//                weights[i*8 +: 8] = 8'h7F;
//            end
//        end
//    endtask

//    task enable_network();
//        begin
//            enable = 1;
//        end
//    endtask

//    task disable_network();
//        begin
//            enable = 0;
//        end
//    endtask

//    // Main Test Sequence
//    initial begin
//        // Initialize Inputs
//        reset = 0;
//        enable = 0;
//        input_spikes = 0;
//        weights = 0;
//        threshold = 0;
//        decay = 0;
//        refractory_period = 0;
//        delays = 0;

//        // Reset the DUT
//        reset_dut();

//        // Configure Inputs
//        configure_inputs(24'hABCDEF, 8'h1A, 8'h2B, 8'h00, {128{1'b0}});
//        configure_inputs(24'hABCDEF, 8'h1A, 8'h2B, 8'h3C, {128{1'b0}});
        
//        // Enable the network
//        enable_network();
        
//        // Run for some time
//        #10000;
        
//        // Disable the network
//        disable_network();

//        // Finish simulation
//        #100;
//        $finish;
//    end

//endmodule




module tb_SNNwithDelays_top();

    // Parameters
    parameter CLK_PERIOD = 10;
    parameter DELAY_CLK_PERIOD = 20;

    // Inputs
    reg clk;
    reg reset;
    reg enable;
    reg delay_clk;
    reg [23:0] input_spikes;
    reg [1919:0] weights; // (24*8+8*2)*8-1:0 becomes 1920 bits
    reg [7:0] threshold;
    reg [7:0] decay;
    reg [7:0] refractory_period;
    reg [2815:0] delays; // (8*24+8*2)*4-1:0 becomes 2816 bits

    // Outputs
    wire [79:0] membrane_potential_out;
    wire [7:0] output_spikes_layer1;
    wire [1:0] output_spikes;

    // Instantiate the Unit Under Test (UUT)
    SNNwithDelays_top uut (
        .clk(clk), 
        .reset(reset), 
        .enable(enable), 
        .delay_clk(delay_clk), 
        .input_spikes(input_spikes), 
        .weights(weights), 
        .threshold(threshold), 
        .decay(decay), 
        .refractory_period(refractory_period), 
        .delays(delays), 
        .membrane_potential_out(membrane_potential_out), 
        .output_spikes_layer1(output_spikes_layer1), 
        .output_spikes(output_spikes)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    initial begin
        delay_clk = 0;
        forever #(DELAY_CLK_PERIOD/2) delay_clk = ~delay_clk;
    end

    // Testbench Tasks
    task reset_dut();
        begin
            reset = 1;
            #20;
            reset = 0;
        end
    endtask

    task configure_inputs(
        input [23:0] spikes,
        input [7:0] th,
        input [7:0] de,
        input [7:0] ref_per,
        input [2815:0] del // 2816 bits
    );
        integer i;
        begin
            input_spikes = spikes;
            threshold = th;
            decay = de;
            refractory_period = ref_per;
            delays = del;

            // Set all weights to 8'h7F
            for (i = 0; i < 1920; i = i + 8) begin
                weights[i +: 8] = 8'h7F;
            end
        end
    endtask

    task enable_network();
        begin
            enable = 1;
        end
    endtask

    task disable_network();
        begin
            enable = 0;
        end
    endtask

    // Main Test Sequence
    initial begin
        // Initialize Inputs
        reset = 0;
        enable = 0;
        input_spikes = 0;
        weights = 0;
        threshold = 0;
        decay = 0;
        refractory_period = 0;
        delays = 0;

        // Reset the DUT
        reset_dut();

        // Configure Inputs
        configure_inputs(24'hABCDEF, 8'h1A, 8'h2B, 8'h00, {128{1'b0}});
        configure_inputs(24'hABCDEF, 8'h1A, 8'h2B, 8'h3C, {128{1'b0}});
        
        // Enable the network
        enable_network();
        
        // Run for some time
        #10000;
        
        // Disable the network
        disable_network();

        // Finish simulation
        #100;
        $finish;
    end

endmodule


