module tb_InputCurrentCalculator;

    parameter M = 8;                  // Number of input spikes and weights
    reg clk;
    reg reset;
    reg enable;
    reg [M-1:0] input_spikes;
    reg [M*8-1:0] weights;
    wire [7:0] input_current;

    // Instantiate the module under test
    InputCurrentCalculator #(.M(M)) uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .input_spikes(input_spikes),
        .weights(weights),
        .input_current(input_current)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10 time units period
    end

    // Task to apply test case
    task apply_test_case;
        input [M-1:0] spikes;
        input [M*8-1:0] wts;
        begin
            enable = 1;
            input_spikes = spikes;
            weights = wts;
            #10 enable = 0;
        end
    endtask

    // Declare integer variables at the module level
    integer w1, w2, w3, w4, w5, w6, w7, w8;

    // Test vectors
    initial begin
        // Initialize inputs
        reset = 1;
        enable = 0;
        input_spikes = 0;
        weights = 0;

        // Apply reset
        #10 reset = 0;

        // Test case 1: No spikes
        apply_test_case(8'b0000_0000, {8'd10, 8'd20, 8'd30, 8'd40, 8'd50, 8'd60, 8'd70, 8'd80});

        // Test case 2: All spikes
        apply_test_case(8'b1111_1111, {8'd10, 8'd20, 8'd30, 8'd40, 8'd50, 8'd60, 8'd70, 8'd80});

        // Test case 3: Mixed spikes
        w1 = 8'sd10;
        w2 = -8'sd20;
        w3 = 8'sd30;
        w4 = -8'sd40;
        w5 = 8'sd50;
        w6 = -8'sd60;
        w7 = 8'sd70;
        w8 = -8'sd80;
        apply_test_case(8'b1010_1010, {w1[7:0], w2[7:0], w3[7:0], w4[7:0], w5[7:0], w6[7:0], w7[7:0], w8[7:0]});

        // Test case 4: Random spikes and weights
        w1 = 8'sd100;
        w2 = -8'sd100;
        w3 = 8'sd50;
        w4 = -8'sd50;
        w5 = 8'sd25;
        w6 = -8'sd25;
        w7 = 8'sd12;
        w8 = -8'sd12;
        apply_test_case(8'b1100_1100, {w1[7:0], w2[7:0], w3[7:0], w4[7:0], w5[7:0], w6[7:0], w7[7:0], w8[7:0]});

        // Test case 5: Positive overflow
        apply_test_case(8'b1111_1111, {8'd100, 8'd100, 8'd100, 8'd100, 8'd100, 8'd100, 8'd100, 8'd100});

        // Test case 6: Negative overflow
        w1 = -8'sd100;
        w2 = -8'sd100;
        w3 = -8'sd100;
        w4 = -8'sd100;
        w5 = -8'sd100;
        w6 = -8'sd100;
        w7 = -8'sd100;
        w8 = -8'sd100;
        apply_test_case(8'b1111_1111, {w1[7:0], w2[7:0], w3[7:0], w4[7:0], w5[7:0], w6[7:0], w7[7:0], w8[7:0]});

        // Finish simulation
        #20 $finish;
    end

    // Monitor the output
    initial begin
        $monitor("Time = %d, reset = %b, enable = %b, input_spikes = %b, weights = %h, input_current = %d",
                 $time, reset, enable, input_spikes, weights, input_current);
    end
endmodule
