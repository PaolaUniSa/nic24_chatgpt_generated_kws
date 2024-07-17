`include "../Verilog/SNNwithDelays_top.v"
`include "../Verilog/TwoLayerNetwork_debug.v"
`include "../Verilog/NeuronLayerWithDelays_debug.v"
`include "../Verilog/NeuronWithDelays_debug.v"
`include "../Verilog/LIF_Neuron_debug.v"
`include "../Verilog/LeakyIntegrateFireNeuron_debug.v"
`include "../Verilog/neuron_delay.v"
`include "../Verilog/InputCurrentCalculator.v"
`include "../Verilog/programmable_delay.v"
module tb_SNNwithDelays_top();

    // Parameters
    parameter CLK_PERIOD = 10;
    parameter DELAY_CLK_PERIOD = 20;
    parameter Nbits = 4; // Nbits precision

    // Inputs
    reg clk;
    reg reset;
    reg enable;
    reg delay_clk;
    reg [23:0] input_spikes;
    reg [(24*8+8*2)*Nbits-1:0] weights;
    reg [Nbits-1:0] threshold;
    reg [Nbits-1:0] decay;
    reg [Nbits-1:0] refractory_period;
    reg [(8*24+8*2)*4-1:0] delays;

    // Outputs
    wire [(8+2)*Nbits-1:0] membrane_potential_out;
    wire [7:0] output_spikes_layer1;
    wire [1:0] output_spikes;

    // Instantiate the Unit Under Test (UUT)
    SNNwithDelays_top #(
    	.Nbits(Nbits)
    ) uut (
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
    input [Nbits-1:0] th,
    input [Nbits-1:0] de,
    input [Nbits-1:0] ref_per,
    input [(8*24+8*2)*4-1:0] del
    );
    	integer i;
        begin
	    input_spikes = spikes;
            threshold = th;
            decay = de;
            refractory_period = ref_per;
            delays = del;
            // Set all weights to 8'h7F
            for (i = 0; i < (24*8 + 8*2); i = i + 1) begin
                weights[i*Nbits +: Nbits] = 4'h7;
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
        $dumpfile("SNNout.vcd");
        $dumpvars(0, tb_SNNwithDelays_top);
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
        configure_inputs(24'hABCDEF, 4'h1, 4'h2, 4'h0, {128{1'b1}});
        
        #1000;
        configure_inputs(24'hABCDEF, 4'h1, 4'h2, 4'h3, {128{1'b0}});
        
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
