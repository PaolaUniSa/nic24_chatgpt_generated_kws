module tb_spi_interface;
    // Parameters
    parameter M = 320;
    parameter N = 8;
    parameter CLOCK_PERIOD = 10;  // Clock period in time units

    // Testbench signals
    reg SCLK, MOSI, SS, RESET;
    wire MISO;
    wire clk_div_ready_reg_out;
    wire input_spike_ready_reg_out;
    wire debug_config_ready_reg_out;
    wire [M*N-1:0] all_data_out;

    // Instantiate the DUT (Device Under Test)
    spi_interface #(M, N) dut (
        .SCLK(SCLK),
        .MOSI(MOSI),
        .SS(SS),
        .RESET(RESET),
        .MISO(MISO),
        .clk_div_ready_reg_out(clk_div_ready_reg_out),
        .input_spike_ready_reg_out(input_spike_ready_reg_out),
        .debug_config_ready_reg_out(debug_config_ready_reg_out),
        .all_data_out(all_data_out)
    );

    // Clock generation
    initial begin
        SCLK = 0;
        forever #(CLOCK_PERIOD/2) SCLK = ~SCLK;
    end

    // Tasks and functions
    task spi_write(input [7:0] data);
        integer i;
        begin
            SS = 0;  // Assert Slave Select
            for (i = 0; i < 8; i = i + 1) begin
                MOSI = data[7-i];
                #(CLOCK_PERIOD);  // Wait for one clock period
            end
            SS = 1;  // Deassert Slave Select
        end
    endtask

    task spi_read(output [7:0] data);
        integer i;
        begin
            SS = 0;  // Assert Slave Select
            data = 0;
            for (i = 0; i < 8; i = i + 1) begin
                #(CLOCK_PERIOD);  // Wait for one clock period
                data = {data[6:0], MISO};
            end
            SS = 1;  // Deassert Slave Select
        end
    endtask

    function integer get_multiple_of_period(input integer multiple);
        begin
            get_multiple_of_period = multiple * CLOCK_PERIOD;
        end
    endfunction

    // Test sequence
    initial begin
        // Initialize signals
        MOSI = 0;
        SS = 1;
        RESET = 1;
        #(get_multiple_of_period(5));
        RESET = 0;

        // Write and read sequence
        spi_write(8'hA5);  // Write 0xA5
        #(get_multiple_of_period(2));  // Wait for 2 clock periods

        spi_write(8'h5A);  // Write 0x5A
        #(get_multiple_of_period(2));  // Wait for 2 clock periods

        // More write/read operations can be added as needed
        // End of test
        #(get_multiple_of_period(10));
        $finish;
    end
endmodule
