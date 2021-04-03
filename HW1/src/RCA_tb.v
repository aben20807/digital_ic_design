`timescale 10ns / 1ps
`define CYCLE 10

module RCA_tb;
reg  [3:0] x, y;
wire [3:0] s;
reg  c_in;
wire c_out;

reg [3:0] result;
reg c;
integer num = 0;
integer i, j;
integer err = 0;
integer ans;

RCA RCA(.s(s), .c_out(c_out), .x(x), .y(y), .c_in(c_in));

initial begin
  for(i=0;i<32;i=i+1)
    for(j=0;j<16;j=j+1)
    begin
      #`CYCLE x = i[3:0]; y = j; c_in = i[4];
      
      #`CYCLE {c, result} = i[3:0] + j + i[4];
      
      if((c == c_out) && (result == s))
        $display("%d data is correct", num);
      else begin
        $display("%d data is error !! your data is %b, correct data is %b", num, {c_out, s}, {c, result});
        err = err + 1;
      end
      num = num + 1;
    end
  
  
  if(err == 0) begin
    $display("-------------------PASS-------------------");
    $display("All data have been generated successfully!");    
  end else begin
    $display("-------------------ERROR-------------------");
    $display("There are %d errors!", err);
  end
    
  #10 $finish;
  
end
endmodule
