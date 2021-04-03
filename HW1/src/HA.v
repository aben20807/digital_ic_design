module HA(s, c, x, y);
input x, y;
output s, c;

xor xor1(s, x, y);
and and1(c, x, y);
  
endmodule