`timescale 1ns / 10ps
`define CYCLE 100
module booth_tb;
  parameter width = 6;
  
  wire [2*width-1:0] out;
  reg [width-1:0] in1;
  reg [width-1:0] in2;
  
  integer num = 1;
  integer i;
  integer j;
  integer ans;
  integer err = 0;
  
  booth booth(.out(out), .in1(in1), .in2(in2));
  
  initial begin
    for(i = (-(1<<width-1)+1); i < (1<<width-1); i = i+1) begin
      for(j = (-(1<<width-1)); j < (1<<width-1); j = j+1) begin
        in1 = i[width-1:0];
        in2 = j[width-1:0];
        #`CYCLE;
        ans = i * j;
        if(out == ans[2*width-1:0])
          $display("%d data is correct", num);
        else begin
          $display("%d data is error %b, correct is %b", num, out, ans[2*width-1:0]);
          err = err + 1;
        end
        num = num + 1;
      end
    end
    
    if(err == 0) begin
      $display("-------------------PASS-------------------");
      $display("All data have been generated successfully!");    
    end else begin
      $display("-------------------ERROR-------------------");
      $display("There are %d errors!", err);
    end
    
    #10 $stop;
  end 
endmodule