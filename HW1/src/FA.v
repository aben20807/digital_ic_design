`include "HA.v"
module FA(s, c_out, x, y, c_in);
input x, y, c_in;
output s, c_out;
wire s1, c1, c2;

HA ha0(s1, c1, x, y);
HA ha1(s, c2, s1, c_in);
or or1(c_out, c1, c2);
  
endmodule