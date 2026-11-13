//24-tap FIR lowpass-filter, direct form and fully parallel
// fs : 1MHz input sample rate
// fpass: 100kHz
// fstop: 200kHz
// -----------------------------------------------

`timescale 1ns / 1ps

module FIRlow24 #(
    parameter i_WIDTH = 8, // input sample bit-width
    parameter c_WIDTH = 16, // coefficient bit-width
    parameter TAPS = 24     // nr-taps

)
(
    input wire clk,
    input wire rst_n,      // async active-low reset
    input wire sample_in, // clock enable

    input wire signed [i_WIDTH-1:0] x_in,
    output reg signed [(i_WIDTH + c_WIDTH)+1:0] y_out // extended WIDTH to avoid overflow

);

reg signed [i_WIDTH-1:0] x_spl [0:TAPS-1];
reg signed [c_WIDTH-1:0] coff [0:TAPS-1];

wire signed [(i_WIDTH + c_WIDTH)+1:0] sum; 
integer k;

//reading coefficients in: 
initial begin 
    $readmemh("./taps.hex",coff);

end

assign sum = coff[0]* x_spl[0] + // combinational (parallel) evaluation
            coff[1]* x_spl[1] + // maybe update to generate-block so nr-taps can be varied
            coff[2]* x_spl[2] +  
            coff[3]* x_spl[3] +
            coff[4]* x_spl[4] +
            coff[5]* x_spl[5] +
            coff[6]* x_spl[6] +
            coff[7]* x_spl[7] +
            coff[8]* x_spl[8] +
            coff[9]* x_spl[9] +
            coff[10]* x_spl[10] +
            coff[11]* x_spl[11] +
            coff[12]* x_spl[12] +
            coff[13]* x_spl[13] +
            coff[14]* x_spl[14] +
            coff[15]* x_spl[15] +
            coff[16]* x_spl[16] +
            coff[17]* x_spl[17] +
            coff[18]* x_spl[18] +
            coff[19]* x_spl[19] +
            coff[20]* x_spl[20] +
            coff[21]* x_spl[21] +
            coff[22]* x_spl[22] +
            coff[23]* x_spl[23] ; 
            
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin // async reset, disregarding clk to settle during pwr-up
        for(k=0; k < TAPS; k = k + 1) begin 
            x_spl[k] <= 0; 
        end 
        y_out <= 0; 

    end

    else if(sample_in) begin 
        x_spl[0] <= x_in;

        for(k=1; k < TAPS; k = k + 1) begin 
            x_spl[k] <= x_spl[k-1];  
        end 
        
        y_out <= sum; 
    end 

end 
endmodule
