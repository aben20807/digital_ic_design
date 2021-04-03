module booth(out, in1, in2);

parameter width = 6;

input  	[width-1:0] in1;   //multiplicand
input  	[width-1:0] in2;   //multiplier
output  [2*width-1:0] out; //product

reg [2*width-1:0] out;
reg [2*width:0] P;
integer i;

always@(*) begin
  P = {{width{1'b0}}, in2, 1'b0};

  for (i = 0; i < width; i=i+1) begin
    case(P[1:0])
      2'b01: P = P + {in1, {width{1'b0}}, 1'b0};
      2'b10: P = P - {in1, {width{1'b0}}, 1'b0};
      default: P = P;
    endcase
    P = $signed(P) >>> 1;
  end

  out = P[2*width:1];
end
endmodule