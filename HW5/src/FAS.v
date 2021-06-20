module  FAS (data_valid, data, clk, rst, fir_d, fir_valid, fft_valid, done, freq,
 fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
 fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);
input clk, rst;
input data_valid;
input [15:0] data; 

output fir_valid, fft_valid;
output [15:0] fir_d;
output [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
output [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
output done;
output [3:0] freq;

FIR_Filter fir(.clk(clk), .rst(rst), .data_valid(data_valid), .data(data), .fir_d(fir_d), .fir_valid(fir_valid));

FFT fft(.clk(clk), .rst(rst), .fir_d(fir_d), .fir_valid(fir_valid), .fft_valid(fft_valid), 
    .fft_d1(fft_d1),   .fft_d2(fft_d2),   .fft_d3(fft_d3),   .fft_d4(fft_d4),
    .fft_d5(fft_d5),   .fft_d6(fft_d6),   .fft_d7(fft_d7),   .fft_d8(fft_d8),
    .fft_d9(fft_d9),   .fft_d10(fft_d10), .fft_d11(fft_d11), .fft_d12(fft_d12), 
    .fft_d13(fft_d13), .fft_d14(fft_d14), .fft_d15(fft_d15), .fft_d0(fft_d0));

Analysis ana(.clk(clk), .rst(rst), .fft_valid(fft_valid), 
    .fft_d1(fft_d1),   .fft_d2(fft_d2),   .fft_d3(fft_d3),   .fft_d4(fft_d4),
    .fft_d5(fft_d5),   .fft_d6(fft_d6),   .fft_d7(fft_d7),   .fft_d8(fft_d8),
    .fft_d9(fft_d9),   .fft_d10(fft_d10), .fft_d11(fft_d11), .fft_d12(fft_d12), 
    .fft_d13(fft_d13), .fft_d14(fft_d14), .fft_d15(fft_d15), .fft_d0(fft_d0), 
    .done(done), .freq(freq));

endmodule

module FIR_Filter (clk, rst, data_valid, data, fir_d, fir_valid);
`include "dat/FIR_coefficient.dat"
input clk, rst;
input data_valid;
input [15:0] data;
output fir_valid;
output [15:0] fir_d;

reg fir_valid;
reg [15:0] fir_d;

reg signed [15:0] xf [31:0];
reg signed [35:0] p [31:0];
wire signed [19:0] FIR_CCC [31:0];
reg [5:0] cnt;
integer j;

wire signed [35:0] accu;
assign accu = 
			((p[0]  + p[1] ) + (p[2]  + p[3] ) + (p[4]  + p[5] ) + (p[6]  + p[7] ))+ 
			((p[8]  + p[9] ) + (p[10] + p[11]) + (p[12] + p[13]) + (p[14] + p[15])) + 
			((p[16] + p[17]) + (p[18] + p[19]) + (p[20] + p[21]) + (p[22] + p[23])) +
			((p[24] + p[25]) + (p[26] + p[27]) + (p[28] + p[29]) + (p[30] + p[31]));

    always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (j = 0; j < 32; j = j + 1) begin
				xf[j] <= 0;
				p[j] <= 0;
			end
		end
		else begin
			if (!data_valid) begin
				for (j = 0; j < 32; j = j + 1) begin
					xf[j] <= 0;
					p[j] <= 0;
				end
			end
			else begin
				xf[31]  <= $signed(data);
				for (j = 31; j > 0; j = j - 1) begin
					xf[j-1] <= xf[j];
				end
				p[0] <= FIR_C00 * xf[31];
				p[1] <= FIR_C01 * xf[30];
				p[2] <= FIR_C02 * xf[29];
				p[3] <= FIR_C03 * xf[28];
				p[4] <= FIR_C04 * xf[27];
				p[5] <= FIR_C05 * xf[26];
				p[6] <= FIR_C06 * xf[25];
				p[7] <= FIR_C07 * xf[24];
				p[8] <= FIR_C08 * xf[23];
				p[9] <= FIR_C09 * xf[22];
				p[10]<= FIR_C10 * xf[21];
				p[11]<= FIR_C11 * xf[20];
				p[12]<= FIR_C12 * xf[19];
				p[13]<= FIR_C13 * xf[18];
				p[14]<= FIR_C14 * xf[17];
				p[15]<= FIR_C15 * xf[16];
				p[16]<= FIR_C16 * xf[15];
				p[17]<= FIR_C17 * xf[14];
				p[18]<= FIR_C18 * xf[13];
				p[19]<= FIR_C19 * xf[12];
				p[20]<= FIR_C20 * xf[11];
				p[21]<= FIR_C21 * xf[10];
				p[22]<= FIR_C22 * xf[9];
				p[23]<= FIR_C23 * xf[8];
				p[24]<= FIR_C24 * xf[7];
				p[25]<= FIR_C25 * xf[6];
				p[26]<= FIR_C26 * xf[5];
				p[27]<= FIR_C27 * xf[4];
				p[28]<= FIR_C28 * xf[3];
				p[29]<= FIR_C29 * xf[2];
				p[30]<= FIR_C30 * xf[1];
				p[31]<= FIR_C31 * xf[0];
			end
		end
	end

    always @(negedge clk or posedge rst) begin
		if (rst) begin
            fir_valid <= 0;
			fir_d <= 0;
		end
		else begin
			if (!data_valid || cnt < 6'd33) begin
				fir_valid <= 0;
				fir_d <= 0;
			end
			else begin
				fir_valid <= 1;
				fir_d <= accu[31:16];
			end
		end
	end

    always @(posedge clk or posedge rst) begin
		if (rst) begin
            cnt <= 0;
		end
		else begin
			if (!data_valid)
            	cnt <= 0;
			else
				cnt <= (cnt == 6'd33) ? cnt : cnt + 1;
		end
	end


endmodule

module FFT (clk, rst, fir_d, fir_valid, fft_valid, fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
 fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);
input clk, rst;
input fir_valid;
input [15:0] fir_d;
output fft_valid;
output [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
output [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;

reg fft_valid;
reg [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
reg [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;

wire signed [31:0] W_R [7:0];
assign W_R[0] = 32'h00010000;
assign W_R[1] = 32'h0000EC83;
assign W_R[2] = 32'h0000B504;
assign W_R[3] = 32'h000061F7;
assign W_R[4] = 32'h00000000;
assign W_R[5] = 32'hFFFF9E09;
assign W_R[6] = 32'hFFFF4AFC;
assign W_R[7] = 32'hFFFF137D;

wire signed [31:0] W_I [7:0];
assign W_I[0] = 32'h00000000;
assign W_I[1] = 32'hFFFF9E09;
assign W_I[2] = 32'hFFFF4AFC;
assign W_I[3] = 32'hFFFF137D;
assign W_I[4] = 32'hFFFF0000;
assign W_I[5] = 32'hFFFF137D;
assign W_I[6] = 32'hFFFF4AFC;
assign W_I[7] = 32'hFFFF9E09;

reg [5:0] cnt;
reg signed [15:0] y [15:0];
reg signed [31:0] fft_in [15:0];
reg signed [31:0] fft_s1_R [15:0];
reg signed [31:0] fft_s1_I [15:0];
reg signed [31:0] fft_s2_R [15:0];
reg signed [31:0] fft_s2_I [15:0];
reg signed [31:0] fft_s3_R [15:0];
reg signed [31:0] fft_s3_I [15:0];
reg signed [31:0] fft_s4_R [15:0];
reg signed [31:0] fft_s4_I [15:0];
reg fft_in_valid, fft_s1_valid, fft_s2_valid, fft_s3_valid, fft_s4_valid;
reg [7:0] grab_8;
reg [15:0] grab_16;
integer i, j;
	// serial input
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (j = 0; j < 16; j = j + 1) begin
				y[j] <= 0;
			end
		end
		else begin
			if (!fir_valid) begin
				for (j = 0; j < 16; j = j + 1) begin
					y[j] <= 0;
				end
			end
			else begin
				y[15]  <= fir_d;
				for (j = 15; j > 0; j = j - 1) begin
					y[j-1] <= y[j];
				end
			end
		end
	end
	// parallel output and signed extend
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (j = 0; j < 16; j = j + 1) begin
				fft_in[j] <= 0;
				fft_in_valid <= 0;
			end
		end
		else begin
			if (cnt == 16) begin
				fft_in_valid <= 1;
				for (j = 0; j < 16; j = j + 1) begin
					fft_in[j] <= { {8{y[j][15]}}, y[j], 8'b0};
				end
			end
			else begin
				fft_in_valid <= 0;
				for (j = 0; j < 16; j = j + 1) begin
					fft_in[j] <= fft_in[j];
				end
			end
		end
	end
	// s1
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (j = 0; j < 16; j = j + 1) begin
				fft_s1_R[j] <= 0;
				fft_s1_I[j] <= 0;
				fft_s1_valid <= 0;
			end
		end
		else begin
			if (fft_in_valid) begin
				for (j = 0; j < 8; j = j + 1) begin
					fft_s1_R[j  ] <= fft_in[j]+fft_in[j+8];
					fft_s1_I[j  ] <= 32'b0; // because (b+d) is 0
					{grab_16, fft_s1_R[j+8], grab_16} <= ((fft_in[j]-fft_in[j+8])*W_R[j]); // because (d-b) is 0
					{grab_16, fft_s1_I[j+8], grab_16} <= ((fft_in[j]-fft_in[j+8])*W_I[j]); // because (b-d) is 0
					fft_s1_valid <= 1;
				end
			end
			else begin
				for (j = 0; j < 16; j = j + 1) begin
					fft_s1_R[j] <= fft_s1_R[j];
					fft_s1_I[j] <= fft_s1_I[j];
					fft_s1_valid <= 0;
				end
			end
		end
	end

	// s2
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (j = 0; j < 16; j = j + 1) begin
				fft_s2_R[j] <= 0;
				fft_s2_I[j] <= 0;
				fft_s2_valid <= 0;
			end
		end
		else begin
			if (fft_s1_valid) begin
				fft_s2_valid <= 1;
				for (i = 0; i < 2; i = i + 1) begin
					for (j = 0; j < 4; j = j + 1) begin
						fft_s2_R[i*8+j] <= fft_s1_R[i*8+j] + fft_s1_R[i*8+j+4];
						fft_s2_I[i*8+j] <= fft_s1_I[i*8+j] + fft_s1_I[i*8+j+4];
						{grab_16, fft_s2_R[i*8+j+4], grab_16} <= 
							((fft_s1_R[i*8+j  ] - fft_s1_R[i*8+j+4])*W_R[j*2]) + 
							((fft_s1_I[i*8+j+4] - fft_s1_I[i*8+j  ])*W_I[j*2]);
						{grab_16, fft_s2_I[i*8+j+4], grab_16} <= 
							((fft_s1_R[i*8+j  ] - fft_s1_R[i*8+j+4])*W_I[j*2]) + 
							((fft_s1_I[i*8+j  ] - fft_s1_I[i*8+j+4])*W_R[j*2]);
					end
				end
			end
			else begin
				for (j = 0; j < 16; j = j + 1) begin
					fft_s2_R[j] <= fft_s2_R[j];
					fft_s2_I[j] <= fft_s2_I[j];
					fft_s2_valid <= 0;
				end
			end
		end
	end

	// s3
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (j = 0; j < 16; j = j + 1) begin
				fft_s3_R[j] <= 0;
				fft_s3_I[j] <= 0;
				fft_s3_valid <= 0;
			end
		end
		else begin
			if (fft_s2_valid) begin
				fft_s3_valid <= 1;
				for (i = 0; i < 4; i = i + 1) begin
					for (j = 0; j < 2; j = j + 1) begin
						fft_s3_R[i*4+j] <= fft_s2_R[i*4+j] + fft_s2_R[i*4+j+2];
						fft_s3_I[i*4+j] <= fft_s2_I[i*4+j] + fft_s2_I[i*4+j+2];
						{grab_16, fft_s3_R[i*4+j+2], grab_16} <= 
							((fft_s2_R[i*4+j  ] - fft_s2_R[i*4+j+2])*W_R[j*4]) + 
							((fft_s2_I[i*4+j+2] - fft_s2_I[i*4+j  ])*W_I[j*4]);
						{grab_16, fft_s3_I[i*4+j+2], grab_16} <= 
							((fft_s2_R[i*4+j  ] - fft_s2_R[i*4+j+2])*W_I[j*4]) + 
							((fft_s2_I[i*4+j  ] - fft_s2_I[i*4+j+2])*W_R[j*4]);
					end
				end
			end
			else begin
				for (j = 0; j < 16; j = j + 1) begin
					fft_s3_R[j] <= fft_s3_R[j];
					fft_s3_I[j] <= fft_s3_I[j];
					fft_s3_valid <= 0;
				end
			end
		end
	end

	// s4
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (j = 0; j < 16; j = j + 1) begin
				fft_s4_R[j] <= 0;
				fft_s4_I[j] <= 0;
				fft_s4_valid <= 0;
			end
		end
		else begin
			if (fft_s3_valid) begin
				fft_s4_valid <= 1;
				for (i = 0; i < 8; i = i + 1) begin
						fft_s4_R[i*2] <= fft_s3_R[i*2] + fft_s3_R[i*2+1];
						fft_s4_I[i*2] <= fft_s3_I[i*2] + fft_s3_I[i*2+1];
						{grab_16, fft_s4_R[i*2+1], grab_16} <= 
							((fft_s3_R[i*2  ] - fft_s3_R[i*2+1])*W_R[0]) + 
							((fft_s3_I[i*2+1] - fft_s3_I[i*2  ])*W_I[0]);
						{grab_16, fft_s4_I[i*2+1], grab_16} <= 
							((fft_s3_R[i*2  ] - fft_s3_R[i*2+1])*W_I[0]) + 
							((fft_s3_I[i*2  ] - fft_s3_I[i*2+1])*W_R[0]);
				end
			end
			else begin
				for (j = 0; j < 16; j = j + 1) begin
					fft_s4_R[j] <= fft_s4_R[j];
					fft_s4_I[j] <= fft_s4_I[j];
					fft_s4_valid <= 0;
				end
			end
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
            cnt <= 0;
		end
		else begin
			if (!fir_valid)
            	cnt <= 0;
			else
				cnt <= (cnt == 6'd16) ? 1 : cnt + 1;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			fft_valid <= 0;
            fft_d1  <= 0; fft_d2  <= 0; fft_d3  <= 0; fft_d4  <= 0; 
			fft_d5  <= 0; fft_d6  <= 0; fft_d7  <= 0; fft_d8  <= 0;
 			fft_d9  <= 0; fft_d10 <= 0; fft_d11 <= 0; fft_d12 <= 0; 
			fft_d13 <= 0; fft_d14 <= 0; fft_d15 <= 0; fft_d0  <= 0;
		end
		else begin
			if (!fft_s4_valid) begin
				fft_valid <= 0;
            	fft_d1  <= 0; fft_d2  <= 0; fft_d3  <= 0; fft_d4  <= 0; 
				fft_d5  <= 0; fft_d6  <= 0; fft_d7  <= 0; fft_d8  <= 0;
				fft_d9  <= 0; fft_d10 <= 0; fft_d11 <= 0; fft_d12 <= 0; 
				fft_d13 <= 0; fft_d14 <= 0; fft_d15 <= 0; fft_d0  <= 0;
			end
			else begin
				fft_valid <= 1;
				fft_d1  <= {fft_s4_R[8 ][23:8], fft_s4_I[8 ][23:8]}; fft_d2  <= {fft_s4_R[4][23:8], fft_s4_I[4][23:8]}; 
				fft_d3  <= {fft_s4_R[12][23:8], fft_s4_I[12][23:8]}; fft_d4  <= {fft_s4_R[2][23:8], fft_s4_I[2][23:8]}; 
				fft_d5  <= {fft_s4_R[10][23:8], fft_s4_I[10][23:8]}; fft_d6  <= {fft_s4_R[6][23:8], fft_s4_I[6][23:8]}; 
				fft_d7  <= {fft_s4_R[14][23:8], fft_s4_I[14][23:8]}; fft_d8  <= {fft_s4_R[1][23:8], fft_s4_I[1][23:8]};
				fft_d9  <= {fft_s4_R[9 ][23:8], fft_s4_I[9 ][23:8]}; fft_d10 <= {fft_s4_R[5][23:8], fft_s4_I[5][23:8]}; 
				fft_d11 <= {fft_s4_R[13][23:8], fft_s4_I[13][23:8]}; fft_d12 <= {fft_s4_R[3][23:8], fft_s4_I[3][23:8]}; 
				fft_d13 <= {fft_s4_R[11][23:8], fft_s4_I[11][23:8]}; fft_d14 <= {fft_s4_R[7][23:8], fft_s4_I[7][23:8]}; 
				fft_d15 <= {fft_s4_R[15][23:8], fft_s4_I[15][23:8]}; fft_d0  <= {fft_s4_R[0][23:8], fft_s4_I[0][23:8]};
			end
		end
	end

endmodule

module Analysis (clk, rst, fft_valid, fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
 fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0, done, freq);
input clk, rst;
input fft_valid;
input [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
input [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
output done;
output [3:0] freq;
endmodule