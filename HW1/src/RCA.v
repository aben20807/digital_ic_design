`include "FA.v"
module RCA(s, c_out, x, y, c_in);
input  [3:0] x, y;
output [3:0] s;
input  c_in;
output c_out;
wire [2:0] c;

FA fa0(s[0], c[0], x[0], y[0], c_in);
FA fa1(s[1], c[1], x[1], y[1], c[0]);
FA fa2(s[2], c[2], x[2], y[2], c[1]);
FA fa3(s[3], c_out, x[3], y[3], c[2]);

endmodule
