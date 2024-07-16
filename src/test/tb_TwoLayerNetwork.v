module tb_TwoLayerNetwork;

    // Parameters
    parameter M1 = 24;
    parameter N1 = 8;
    parameter N2 = 8;

    // Clock parameters
    parameter CLK_PERIOD = 10;       // Clock period for clk (100MHz)
    parameter DELAY_CLK_PERIOD = 30; // Clock period for delay_clk (33.33MHz)

    // Inputs
    reg clk;
    reg reset;
    reg enable;
    reg delay_clk;
    reg [M1-1:0] input_spikes;
    reg [N1*M1*8-1:0] weights1;
    reg [N2*N1*8-1:0] weights2;
    reg [7:0] threshold1;
    reg [7:0] decay1;
    reg [7:0] refractory_period1;
    reg [7:0] threshold2;
    reg [7:0] decay2;
    reg [7:0] refractory_period2;
    reg [N1*M1*3-1:0] delay_values1;
    reg [N1*M1-1:0] delays1;
    reg [N2*N1*3-1:0] delay_values2;
    reg [N2*N1-1:0] delays2;

    // Outputs
    wire [N2-1:0] output_spikes;

    // Instantiate the Unit Under Test (UUT)
    TwoLayerNetwork #(
        .M1(M1),
        .N1(N1),
        .N2(N2)
    ) uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .delay_clk(delay_clk),
        .input_spikes(input_spikes),
        .weights1(weights1),
        .weights2(weights2),
        .threshold1(threshold1),
        .decay1(decay1),
        .refractory_period1(refractory_period1),
        .threshold2(threshold2),
        .decay2(decay2),
        .refractory_period2(refractory_period2),
        .delay_values1(delay_values1),
        .delays1(delays1),
        .delay_values2(delay_values2),
        .delays2(delays2),
        .output_spikes(output_spikes)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Delay clock generation
    initial begin
        delay_clk = 0;
        forever #(DELAY_CLK_PERIOD / 2) delay_clk = ~delay_clk;
    end

    // Task to apply reset
    task apply_reset;
        begin
            reset = 1;
            #(CLK_PERIOD * 2);
            reset = 0;
        end
    endtask

    // Task to initialize inputs
    task initialize_inputs;
        begin
            enable = 0;
            input_spikes = 0;
            weights1 = 0;
            weights2 = 0;
            threshold1 = 8'h0F;
            decay1 = 8'h01;
            refractory_period1 = 8'h10;
            threshold2 = 8'h0F;
            decay2 = 8'h01;
            refractory_period2 = 8'h10;
            delay_values1 = 0;
            delays1 = 0;
            delay_values2 = 0;
            delays2 = 0;
        end
    endtask

    // Task to apply stimulus
    task apply_stimulus;
        input [M1-1:0] i_spikes;
        input [N1*M1*8-1:0] w1;
        input [N2*N1*8-1:0] w2;
        input [N1*M1*3-1:0] d_values1;
        input [N1*M1-1:0] d1;
        input [N2*N1*3-1:0] d_values2;
        input [N2*N1-1:0] d2;
        begin
            enable = 1;
            input_spikes = i_spikes;
            weights1 = w1;
            weights2 = w2;
            delay_values1 = d_values1;
            delays1 = d1;
            delay_values2 = d_values2;
            delays2 = d2;
        end
    endtask

    // Initial setup
    initial begin
        // Initialize inputs and apply reset
        initialize_inputs();
        apply_reset();

        // Apply first stimulus set
        #(CLK_PERIOD * 2);
        apply_stimulus(24'hFFFFFF, {N1*M1{8'h01}}, {N2*N1{8'h01}}, {N1*M1{3'b001}}, {N1*M1{1'b1}}, {N2*N1{3'b001}}, {N2*N1{1'b1}});
        #(CLK_PERIOD * 20);

        // Apply second stimulus set
        apply_stimulus(24'hAAAAAA, {N1*M1{8'h02}}, {N2*N1{8'h02}}, {N1*M1{3'b010}}, {N1*M1{1'b0}}, {N2*N1{3'b010}}, {N2*N1{1'b0}});
        #(CLK_PERIOD * 20);

        // Apply third stimulus set
        apply_stimulus(24'h555555, {N1*M1{8'h03}}, {N2*N1{8'h03}}, {N1*M1{3'b011}}, {N1*M1{1'b1}}, {N2*N1{3'b011}}, {N2*N1{1'b1}});
        #(CLK_PERIOD * 20);

        // Apply fourth stimulus set
        apply_stimulus(24'h0F0F0F, {N1*M1{8'h04}}, {N2*N1{8'h04}}, {N1*M1{3'b100}}, {N1*M1{1'b0}}, {N2*N1{3'b100}}, {N2*N1{1'b0}});
        #(CLK_PERIOD * 20);

        // Apply fifth stimulus set
        apply_stimulus(24'hF0F0F0, {N1*M1{8'h05}}, {N2*N1{8'h05}}, {N1*M1{3'b101}}, {N1*M1{1'b1}}, {N2*N1{3'b101}}, {N2*N1{1'b1}});
        #(CLK_PERIOD * 20);

        // Finish simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | Output Spikes: %b", $time, output_spikes);
    end

endmodule
