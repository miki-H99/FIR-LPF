`timescale 1ns / 1ps

module FIRlow24_tb; 
    parameter N = 1000; // nr of input samples
    parameter i_WIDTH = 8;
    parameter c_WIDTH = 16;
    parameter TAPS = 24;

    reg clk; 
    reg rst_n;
    reg sample_in; 

    reg signed [i_WIDTH-1:0]  sample [0:N-1]; 
    reg signed [i_WIDTH-1:0] x_in; 
    integer i,file; 

    wire signed [(i_WIDTH+c_WIDTH)+1:0] y_out; 

    FIRlow24 #(
        // module is parameterized:
                .i_WIDTH(i_WIDTH), .c_WIDTH(c_WIDTH), .TAPS(TAPS)
    ) dut(
            //named port connections
        .clk(clk),
        .rst_n(rst_n),
        .sample_in(sample_in),

        .x_in(x_in),
        .y_out(y_out)

    );

    initial clk = 0;
    always #500 clk = ~clk; // for the 1Mhz input sample rate
    

    always@(negedge clk) begin
        if(rst_n) begin
            $fdisplay(file,"%0d,%0d,%0d",$time,x_in,y_out); 
        end
    end

    initial begin
        $dumpfile("firLPF24.vcd");
        $dumpvars(0, FIRlow24_tb);   // record every signal in the testbench

        file = $fopen("y_out_LPF24.csv","w");
        $fdisplay(file,"t_ns,x_in,y_out"); // CSV header row

        $readmemh("sin_210kHz.hex", sample); // 8-bit sine test vector

        rst_n = 0; // starting reset
        sample_in = 0;
        x_in = 0;
        #20; // intial state settling-time buffer
        rst_n = 1; // ending reset

        for (i=0; i < N; i= i + 1) begin
            @(negedge clk) begin
                sample_in = 1;
                x_in <= sample[i];
            end
        end

        repeat (30) @(negedge clk); // let the last sample pass through the taps window

        $fclose(file);
        $finish;
    end
endmodule
