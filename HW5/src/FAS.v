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
input clk, rst;
input data_valid;
input [15:0] data;
output fir_valid;
output [15:0] fir_d;

reg fir_valid;
reg [15:0] fir_d;

reg signed [15:0] xf [31:0];
reg signed [35:0] p [31:0];
reg [5:0] cnt;
integer j;

parameter signed [19:0] FIR_C00 = 20'hFFF9E ;     //The FIR_coefficient value 0: -1.495361e-003
parameter signed [19:0] FIR_C01 = 20'hFFF86 ;     //The FIR_coefficient value 1: -1.861572e-003
parameter signed [19:0] FIR_C02 = 20'hFFFA7 ;     //The FIR_coefficient value 2: -1.358032e-003
parameter signed [19:0] FIR_C03 = 20'h0003B ;    //The FIR_coefficient value 3: 9.002686e-004
parameter signed [19:0] FIR_C04 = 20'h0014B ;    //The FIR_coefficient value 4: 5.050659e-003
parameter signed [19:0] FIR_C05 = 20'h0024A ;    //The FIR_coefficient value 5: 8.941650e-003
parameter signed [19:0] FIR_C06 = 20'h00222 ;    //The FIR_coefficient value 6: 8.331299e-003
parameter signed [19:0] FIR_C07 = 20'hFFFE4 ;     //The FIR_coefficient value 7: -4.272461e-004
parameter signed [19:0] FIR_C08 = 20'hFFBC5 ;     //The FIR_coefficient value 8: -1.652527e-002
parameter signed [19:0] FIR_C09 = 20'hFF7CA ;     //The FIR_coefficient value 9: -3.207397e-002
parameter signed [19:0] FIR_C10 = 20'hFF74E ;     //The FIR_coefficient value 10: -3.396606e-002
parameter signed [19:0] FIR_C11 = 20'hFFD74 ;     //The FIR_coefficient value 11: -9.948730e-003
parameter signed [19:0] FIR_C12 = 20'h00B1A ;    //The FIR_coefficient value 12: 4.336548e-002
parameter signed [19:0] FIR_C13 = 20'h01DAC ;    //The FIR_coefficient value 13: 1.159058e-001
parameter signed [19:0] FIR_C14 = 20'h02F9E ;    //The FIR_coefficient value 14: 1.860046e-001
parameter signed [19:0] FIR_C15 = 20'h03AA9 ;    //The FIR_coefficient value 15: 2.291412e-001
parameter signed [19:0] FIR_C16 = 20'h03AA9 ;    //The FIR_coefficient value 16: 2.291412e-001
parameter signed [19:0] FIR_C17 = 20'h02F9E ;    //The FIR_coefficient value 17: 1.860046e-001
parameter signed [19:0] FIR_C18 = 20'h01DAC ;    //The FIR_coefficient value 18: 1.159058e-001
parameter signed [19:0] FIR_C19 = 20'h00B1A ;    //The FIR_coefficient value 19: 4.336548e-002
parameter signed [19:0] FIR_C20 = 20'hFFD74 ;     //The FIR_coefficient value 20: -9.948730e-003
parameter signed [19:0] FIR_C21 = 20'hFF74E ;     //The FIR_coefficient value 21: -3.396606e-002
parameter signed [19:0] FIR_C22 = 20'hFF7CA ;     //The FIR_coefficient value 22: -3.207397e-002
parameter signed [19:0] FIR_C23 = 20'hFFBC5 ;     //The FIR_coefficient value 23: -1.652527e-002
parameter signed [19:0] FIR_C24 = 20'hFFFE4 ;     //The FIR_coefficient value 24: -4.272461e-004
parameter signed [19:0] FIR_C25 = 20'h00222 ;    //The FIR_coefficient value 25: 8.331299e-003
parameter signed [19:0] FIR_C26 = 20'h0024A ;    //The FIR_coefficient value 26: 8.941650e-003
parameter signed [19:0] FIR_C27 = 20'h0014B ;    //The FIR_coefficient value 27: 5.050659e-003
parameter signed [19:0] FIR_C28 = 20'h0003B ;    //The FIR_coefficient value 28: 9.002686e-004
parameter signed [19:0] FIR_C29 = 20'hFFFA7 ;     //The FIR_coefficient value 29: -1.358032e-003
parameter signed [19:0] FIR_C30 = 20'hFFF86 ;     //The FIR_coefficient value 30: -1.861572e-003
parameter signed [19:0] FIR_C31 = 20'hFFF9E ;     //The FIR_coefficient value 31: -1.495361e-003

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

    always @(posedge clk or posedge rst) begin
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
				cnt <= (cnt == 6'd33) ? cnt : cnt + 6'd1;
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

parameter signed [31:0] W_R0 = 32'h00010000;
parameter signed [31:0] W_R1 = 32'h0000EC83;
parameter signed [31:0] W_R2 = 32'h0000B504;
parameter signed [31:0] W_R3 = 32'h000061F7;
parameter signed [31:0] W_R4 = 32'h00000000;
parameter signed [31:0] W_R5 = 32'hFFFF9E09;
parameter signed [31:0] W_R6 = 32'hFFFF4AFC;
parameter signed [31:0] W_R7 = 32'hFFFF137D;

parameter signed [31:0] W_I0 = 32'h00000000;
parameter signed [31:0] W_I1 = 32'hFFFF9E09;
parameter signed [31:0] W_I2 = 32'hFFFF4AFC;
parameter signed [31:0] W_I3 = 32'hFFFF137D;
parameter signed [31:0] W_I4 = 32'hFFFF0000;
parameter signed [31:0] W_I5 = 32'hFFFF137D;
parameter signed [31:0] W_I6 = 32'hFFFF4AFC;
parameter signed [31:0] W_I7 = 32'hFFFF9E09;

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
reg [15:0] garb_16;
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
				y[15]  <= fir_d + {15'd0, fir_d[15]}; // Magic
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
				fft_s1_valid <= 1;
				// j=0
				fft_s1_R[0  ] <= fft_in[0]+fft_in[8];
				fft_s1_I[0  ] <= 32'b0; // because (b+d) is 0
				{garb_16, fft_s1_R[8], garb_16} <= ((fft_in[0]-fft_in[8])*W_R0); // because (d-b) is 0
				{garb_16, fft_s1_I[8], garb_16} <= ((fft_in[0]-fft_in[8])*W_I0); // because (b-d) is 0
				// j=1
				fft_s1_R[1  ] <= fft_in[1]+fft_in[8+1];
				fft_s1_I[1  ] <= 32'b0; // because (b+d) is 0
				{garb_16, fft_s1_R[8+1], garb_16} <= ((fft_in[1]-fft_in[8+1])*W_R1); // because (d-b) is 0
				{garb_16, fft_s1_I[8+1], garb_16} <= ((fft_in[1]-fft_in[8+1])*W_I1); // because (b-d) is 0
				// j=2
				fft_s1_R[2  ] <= fft_in[2]+fft_in[8+2];
				fft_s1_I[2  ] <= 32'b0; // because (b+d) is 0
				{garb_16, fft_s1_R[8+2], garb_16} <= ((fft_in[2]-fft_in[8+2])*W_R2); // because (d-b) is 0
				{garb_16, fft_s1_I[8+2], garb_16} <= ((fft_in[2]-fft_in[8+2])*W_I2); // because (b-d) is 0
				// j=3
				fft_s1_R[3  ] <= fft_in[3]+fft_in[8+3];
				fft_s1_I[3  ] <= 32'b0; // because (b+d) is 0
				{garb_16, fft_s1_R[8+3], garb_16} <= ((fft_in[3]-fft_in[8+3])*W_R3); // because (d-b) is 0
				{garb_16, fft_s1_I[8+3], garb_16} <= ((fft_in[3]-fft_in[8+3])*W_I3); // because (b-d) is 0
				// j=4
				fft_s1_R[4  ] <= fft_in[4]+fft_in[8+4];
				fft_s1_I[4  ] <= 32'b0; // because (b+d) is 0
				{garb_16, fft_s1_R[8+4], garb_16} <= ((fft_in[4]-fft_in[8+4])*W_R4); // because (d-b) is 0
				{garb_16, fft_s1_I[8+4], garb_16} <= ((fft_in[4]-fft_in[8+4])*W_I4); // because (b-d) is 0
				// j=5
				fft_s1_R[5  ] <= fft_in[5]+fft_in[8+5];
				fft_s1_I[5  ] <= 32'b0; // because (b+d) is 0
				{garb_16, fft_s1_R[8+5], garb_16} <= ((fft_in[5]-fft_in[8+5])*W_R5); // because (d-b) is 0
				{garb_16, fft_s1_I[8+5], garb_16} <= ((fft_in[5]-fft_in[8+5])*W_I5); // because (b-d) is 0
				// j=6
				fft_s1_R[6  ] <= fft_in[6]+fft_in[8+6];
				fft_s1_I[6  ] <= 32'b0; // because (b+d) is 0
				{garb_16, fft_s1_R[8+6], garb_16} <= ((fft_in[6]-fft_in[8+6])*W_R6); // because (d-b) is 0
				{garb_16, fft_s1_I[8+6], garb_16} <= ((fft_in[6]-fft_in[8+6])*W_I6); // because (b-d) is 0
				// j=7
				fft_s1_R[7  ] <= fft_in[7]+fft_in[8+7];
				fft_s1_I[7  ] <= 32'b0; // because (b+d) is 0
				{garb_16, fft_s1_R[8+7], garb_16} <= ((fft_in[7]-fft_in[8+7])*W_R7); // because (d-b) is 0
				{garb_16, fft_s1_I[8+7], garb_16} <= ((fft_in[7]-fft_in[8+7])*W_I7); // because (b-d) is 0
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
					//j=0
					fft_s2_R[i*8+0] <= fft_s1_R[i*8+0] + fft_s1_R[i*8+0+4];
					fft_s2_I[i*8+0] <= fft_s1_I[i*8+0] + fft_s1_I[i*8+0+4];
					{garb_16, fft_s2_R[i*8+0+4], garb_16} <= 
						((fft_s1_R[i*8+0  ] - fft_s1_R[i*8+0+4])*W_R0) + 
						((fft_s1_I[i*8+0+4] - fft_s1_I[i*8+0  ])*W_I0);
					{garb_16, fft_s2_I[i*8+0+4], garb_16} <= 
						((fft_s1_R[i*8+0  ] - fft_s1_R[i*8+0+4])*W_I0) + 
						((fft_s1_I[i*8+0  ] - fft_s1_I[i*8+0+4])*W_R0);
					//j=1
					fft_s2_R[i*8+1] <= fft_s1_R[i*8+1] + fft_s1_R[i*8+1+4];
					fft_s2_I[i*8+1] <= fft_s1_I[i*8+1] + fft_s1_I[i*8+1+4];
					{garb_16, fft_s2_R[i*8+1+4], garb_16} <= 
						((fft_s1_R[i*8+1  ] - fft_s1_R[i*8+1+4])*W_R2) + 
						((fft_s1_I[i*8+1+4] - fft_s1_I[i*8+1  ])*W_I2);
					{garb_16, fft_s2_I[i*8+1+4], garb_16} <= 
						((fft_s1_R[i*8+1  ] - fft_s1_R[i*8+1+4])*W_I2) + 
						((fft_s1_I[i*8+1  ] - fft_s1_I[i*8+1+4])*W_R2);
					//j=2
					fft_s2_R[i*8+2] <= fft_s1_R[i*8+2] + fft_s1_R[i*8+2+4];
					fft_s2_I[i*8+2] <= fft_s1_I[i*8+2] + fft_s1_I[i*8+2+4];
					{garb_16, fft_s2_R[i*8+2+4], garb_16} <= 
						((fft_s1_R[i*8+2  ] - fft_s1_R[i*8+2+4])*W_R4) + 
						((fft_s1_I[i*8+2+4] - fft_s1_I[i*8+2  ])*W_I4);
					{garb_16, fft_s2_I[i*8+2+4], garb_16} <= 
						((fft_s1_R[i*8+2  ] - fft_s1_R[i*8+2+4])*W_I4) + 
						((fft_s1_I[i*8+2  ] - fft_s1_I[i*8+2+4])*W_R4);
					//j=3
					fft_s2_R[i*8+3] <= fft_s1_R[i*8+3] + fft_s1_R[i*8+3+4];
					fft_s2_I[i*8+3] <= fft_s1_I[i*8+3] + fft_s1_I[i*8+3+4];
					{garb_16, fft_s2_R[i*8+3+4], garb_16} <= 
						((fft_s1_R[i*8+3  ] - fft_s1_R[i*8+3+4])*W_R6) + 
						((fft_s1_I[i*8+3+4] - fft_s1_I[i*8+3  ])*W_I6);
					{garb_16, fft_s2_I[i*8+3+4], garb_16} <= 
						((fft_s1_R[i*8+3  ] - fft_s1_R[i*8+3+4])*W_I6) + 
						((fft_s1_I[i*8+3  ] - fft_s1_I[i*8+3+4])*W_R6);
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
					//j=0
					fft_s3_R[i*4+0] <= fft_s2_R[i*4+0] + fft_s2_R[i*4+0+2];
					fft_s3_I[i*4+0] <= fft_s2_I[i*4+0] + fft_s2_I[i*4+0+2];
					{garb_16, fft_s3_R[i*4+0+2], garb_16} <= 
						((fft_s2_R[i*4+0  ] - fft_s2_R[i*4+0+2])*W_R0) + 
						((fft_s2_I[i*4+0+2] - fft_s2_I[i*4+0  ])*W_I0);
					{garb_16, fft_s3_I[i*4+0+2], garb_16} <= 
						((fft_s2_R[i*4+0  ] - fft_s2_R[i*4+0+2])*W_I0) + 
						((fft_s2_I[i*4+0  ] - fft_s2_I[i*4+0+2])*W_R0);
					//j=1
					fft_s3_R[i*4+1] <= fft_s2_R[i*4+1] + fft_s2_R[i*4+1+2];
					fft_s3_I[i*4+1] <= fft_s2_I[i*4+1] + fft_s2_I[i*4+1+2];
					{garb_16, fft_s3_R[i*4+1+2], garb_16} <= 
						((fft_s2_R[i*4+1  ] - fft_s2_R[i*4+1+2])*W_R4) + 
						((fft_s2_I[i*4+1+2] - fft_s2_I[i*4+1  ])*W_I4);
					{garb_16, fft_s3_I[i*4+1+2], garb_16} <= 
						((fft_s2_R[i*4+1  ] - fft_s2_R[i*4+1+2])*W_I4) + 
						((fft_s2_I[i*4+1  ] - fft_s2_I[i*4+1+2])*W_R4);
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
						{garb_16, fft_s4_R[i*2+1], garb_16} <= 
							((fft_s3_R[i*2  ] - fft_s3_R[i*2+1])*W_R0) + 
							((fft_s3_I[i*2+1] - fft_s3_I[i*2  ])*W_I0);
						{garb_16, fft_s4_I[i*2+1], garb_16} <= 
							((fft_s3_R[i*2  ] - fft_s3_R[i*2+1])*W_I0) + 
							((fft_s3_I[i*2  ] - fft_s3_I[i*2+1])*W_R0);
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
				cnt <= (cnt == 6'd16) ? 6'd1 : cnt + 6'd1;
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

reg done;
reg [3:0] freq;

reg signed [31:0] y_dis [15:0];
reg do_cmp1, do_cmp2, do_cmp3, do_output, keep_done_low;
reg signed [31:0] max [15:0];
reg [3:0] max_idx [15:0];
integer j;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			do_cmp1 <= 0;
			for (j = 0; j < 16; j = j + 1) begin
				y_dis[j] <= 0;
			end
		end
		else begin
			if (fft_valid) begin
				do_cmp1 <= 1;
				y_dis[0] <= fft_d0[31:16]*fft_d0[31:16] + fft_d0[15:0]*fft_d0[15:0];
				y_dis[1] <= fft_d1[31:16]*fft_d1[31:16] + fft_d1[15:0]*fft_d1[15:0];
				y_dis[2] <= fft_d2[31:16]*fft_d2[31:16] + fft_d2[15:0]*fft_d2[15:0];
				y_dis[3] <= fft_d3[31:16]*fft_d3[31:16] + fft_d3[15:0]*fft_d3[15:0];
				y_dis[4] <= fft_d4[31:16]*fft_d4[31:16] + fft_d4[15:0]*fft_d4[15:0];
				y_dis[5] <= fft_d5[31:16]*fft_d5[31:16] + fft_d5[15:0]*fft_d5[15:0];
				y_dis[6] <= fft_d6[31:16]*fft_d6[31:16] + fft_d6[15:0]*fft_d6[15:0];
				y_dis[7] <= fft_d7[31:16]*fft_d7[31:16] + fft_d7[15:0]*fft_d7[15:0];
				y_dis[8] <= fft_d8[31:16]*fft_d8[31:16] + fft_d8[15:0]*fft_d8[15:0];
				y_dis[9] <= fft_d9[31:16]*fft_d9[31:16] + fft_d9[15:0]*fft_d9[15:0];
				y_dis[10]<= fft_d10[31:16]*fft_d10[31:16] + fft_d10[15:0]*fft_d10[15:0];
				y_dis[11]<= fft_d11[31:16]*fft_d11[31:16] + fft_d11[15:0]*fft_d11[15:0];
				y_dis[12]<= fft_d12[31:16]*fft_d12[31:16] + fft_d12[15:0]*fft_d12[15:0];
				y_dis[13]<= fft_d13[31:16]*fft_d13[31:16] + fft_d13[15:0]*fft_d13[15:0];
				y_dis[14]<= fft_d14[31:16]*fft_d14[31:16] + fft_d14[15:0]*fft_d14[15:0];
				y_dis[15]<= fft_d15[31:16]*fft_d15[31:16] + fft_d15[15:0]*fft_d15[15:0];
			end
			else begin
				do_cmp1 <= 0;
				for (j = 0; j < 16; j = j + 1) begin
					y_dis[j] <= y_dis[j];
				end
			end
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			do_cmp2 <= 0;
			do_cmp3 <= 0;
			do_output <= 0;
			for (j = 0; j < 16; j = j + 1) begin
				max[j]     <= 0;
				max_idx[j] <= 0;
			end
		end
		else begin
			if (do_cmp1) begin
				do_cmp2 <= 1;
				do_cmp3 <= 0;
				do_output <= 0;
				for (j = 0; j < 16; j = j + 2) begin
					max[j]     <= (y_dis[j] > y_dis[j+1])? y_dis[j]: y_dis[j+1];
					max_idx[j] <= (y_dis[j] > y_dis[j+1])? j[3:0]: j[3:0]+4'd1;
				end
			end
			else if (do_cmp2) begin
				do_cmp2 <= 0;
				do_cmp3 <= 1;
				do_output <= 0;
				for (j = 0; j < 16; j = j + 4) begin
					max[j]     <= (max[j] > max[j+2])? max[j]: max[j+2];
					max_idx[j] <= (max[j] > max[j+2])? max_idx[j]: max_idx[j+2];
				end
			end
			else if (do_cmp3) begin
				do_cmp2 <= 0;
				do_cmp3 <= 0;
				do_output <= 1;
				for (j = 0; j < 16; j = j + 8) begin
					max[j]     <= (max[j] > max[j+4])? max[j]: max[j+4];
					max_idx[j] <= (max[j] > max[j+4])? max_idx[j]: max_idx[j+4];
				end
			end
			else begin
				do_cmp2 <= 0;
				do_cmp3 <= 0;
				do_output <= 0;
				for (j = 0; j < 16; j = j + 1) begin
					max[j]     <= max[j];
					max_idx[j] <= max_idx[j];
				end
			end
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			done <= 0;
			freq <= 0;
			keep_done_low <= 0;
		end
		else begin
			if (do_output && !keep_done_low) begin
				done <= 1;
				freq <= (max[0]>max[8])?max_idx[0]:max_idx[8];
				keep_done_low <= 1;
			end
			else begin
				done <= 0;
				freq <= 0;
				keep_done_low <= keep_done_low;
			end
		end
	end

endmodule