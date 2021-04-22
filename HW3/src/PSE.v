module PSE (clk,reset,Xin,Yin,point_num,valid,Xout,Yout);
input clk;
input reset;
input [9:0] Xin;
input [9:0] Yin;
input [2:0] point_num;
output valid;
output [9:0] Xout;
output [9:0] Yout;

reg valid;
reg [9:0] Xout;
reg [9:0] Yout;

reg [9:0] px [5:0];
reg [9:0] py [5:0];
reg signed [10:0] vx [5:0];
reg signed [10:0] vy [5:0];
//reg signed [21:0] v1;
//reg signed [21:0] v2, v3;
reg [3:0] CurrState, Nextstate;
parameter [3:0] InitState = 4'd0, 
                InputState = 4'd1, 
                CrossSort_even = 4'd2, 
                CrossSort_odd = 4'd3,
                OutputState = 4'd4,
                //CrossSort_even_nxt = 4'd7,
                CrossSort_even_start = 4'd8,
                //CrossSort_odd_nxt = 4'd9,
                CrossSort_odd_start = 4'd10;
                
reg [2:0] in_i, out_i, sort_outer, i;
integer j;

// State
always @(posedge clk or posedge reset) begin
  if (reset)
    CurrState <= InitState;
  else
    CurrState <= Nextstate;
end

// Counter: in_i
always @(posedge clk or posedge reset) begin
  if (reset)
    in_i <= 3'd0;
  else begin
    case(CurrState)
      InputState:
      begin
        in_i <= in_i + 3'd1;
      end
      default:
        in_i <= 3'd0;
    endcase
  end
end

// Counter: out_i
always @(posedge clk or posedge reset) begin
  if (reset)
    out_i <= 3'd0;
  else begin
    case(CurrState)
      OutputState:
      begin
        out_i <= out_i + 3'd1;
      end
      default:
        out_i <= 3'd0;
    endcase
  end
end

// Counter: sort_outer
always @(posedge clk or posedge reset) begin
  if (reset)
    sort_outer <= 3'd0;
  else begin
    case(CurrState)
      CrossSort_odd:
      begin
        sort_outer <= sort_outer + 3'd1;
      end
      CrossSort_even_start, CrossSort_even, CrossSort_odd_start:
      begin
        sort_outer <= sort_outer;
      end
      default:
        sort_outer <= 3'd0;
    endcase
  end
end

// Counter: i
always @(posedge clk or posedge reset) begin
  if (reset)
    i <= 3'd0;
  else begin
    case(CurrState)
      CrossSort_even_start: i <= 3'd2;
      CrossSort_odd_start: i <= 3'd1;
      CrossSort_even, CrossSort_odd: i <= i + 3'd2;
      default: i <= 3'd0;
    endcase
  end
end

// px py vx vy
always @(negedge clk or posedge reset) begin
  if (reset)
    for (j = 0; j < 6; j=j+1) begin
      px[j] <= 10'b0;
      py[j] <= 10'b0;
      vx[j] <= 10'b0;
      vy[j] <= 10'b0;
    end
  else begin
    case(CurrState)
      InitState: 
      begin
      	 for (j = 0; j < 6; j=j+1) begin
          px[j] <= 10'b0;
          py[j] <= 10'b0;
          vx[j] <= 10'b0;
          vy[j] <= 10'b0;
        end
      end
      InputState:
      begin
        px[in_i] <= Xin;
        py[in_i] <= Yin;
       	vx[in_i] <= Xin - px[0];
        vy[in_i] <= Yin - py[0];
      end
      CrossSort_even, CrossSort_odd:
      begin
        /*if (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) begin
          vx[i  ] <= vx[i+1];
          vx[i+1] <= vx[i  ];
          vy[i  ] <= vy[i+1];
          vy[i+1] <= vy[i  ];
          px[i  ] <= px[i+1];
          px[i+1] <= px[i  ];
          py[i  ] <= py[i+1];
          py[i+1] <= py[i  ];
        end
        else begin
   	      vx[i  ] <= vx[i  ];
          vx[i+1] <= vx[i+1];
          vy[i  ] <= vy[i  ];
          vy[i+1] <= vy[i+1];
          px[i  ] <= px[i  ];
         	px[i+1] <= px[i+1];
          py[i  ] <= py[i  ];
          py[i+1] <= py[i+1];
        end*/
        vx[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vx[i+1] : vx[i  ];
        vx[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vx[i  ] : vx[i+1];
        vy[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vy[i+1] : vy[i  ];
        vy[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vy[i  ] : vy[i+1];
        px[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? px[i+1] : px[i  ];
        px[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? px[i  ] : px[i+1];
        py[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? py[i+1] : py[i  ];
        py[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? py[i  ] : py[i+1];
      end
      default:
      begin
        for (j = 0; j < 6; j=j+1) begin
          px[j] <= px[j];
          py[j] <= py[j];
       	  vx[j] <= vx[j];
          vy[j] <= vy[j];
        end
      end
    endcase
  end
end

// Next Logic
always @(point_num or CurrState or in_i or out_i or sort_outer or i) begin
  case(CurrState)
    InitState: 
    begin
      /*for (j = 0; j < 6; j=j+1) begin
        px[j] <= 10'b0;
        py[j] <= 10'b0;
        vx[j] <= 10'b0;
        vy[j] <= 10'b0;
      end*/
      Nextstate <= InputState;
    end
    
    InputState:
    begin
      /*px[in_i] <= Xin;
      py[in_i] <= Yin;
      vx[in_i] <= Xin - px[0];
      vy[in_i] <= Yin - py[0];*/
      if (in_i == point_num - 3'd1)
        Nextstate <= CrossSort_even_start;
      else
        Nextstate <= InputState;
    end
    
    CrossSort_even_start:
    begin
      Nextstate <= CrossSort_even;
    end
    CrossSort_even:
    begin
      if (i >= point_num - 3'd3) begin
        if (sort_outer == point_num - 3'd2)
          Nextstate <= OutputState;
        else
          Nextstate <= CrossSort_odd_start;
      end
      else begin
      //for (i = 2; i < point_num-1; i = i+2) begin
        /*vx[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vx[i+1] : vx[i  ];
        vx[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vx[i  ] : vx[i+1];
        vy[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vy[i+1] : vy[i  ];
        vy[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vy[i  ] : vy[i+1];
        px[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? px[i+1] : px[i  ];
        px[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? px[i  ] : px[i+1];
        py[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? py[i+1] : py[i  ];
        py[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? py[i  ] : py[i+1];*/
      //end
        Nextstate <= CrossSort_even;
      end
    end
    
    
    CrossSort_odd_start:
    begin
      Nextstate <= CrossSort_odd;
    end
    CrossSort_odd:
    begin
      if (i >= point_num - 3'd3) begin
        if (sort_outer == point_num - 3'd2)
          Nextstate <= OutputState;
        else
          Nextstate <= CrossSort_even_start;
      end
      else begin
      //for (i = 1; i < point_num-1; i = i+2) begin
        /*vx[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vx[i+1] : vx[i  ];
        vx[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vx[i  ] : vx[i+1];
        vy[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vy[i+1] : vy[i  ];
        vy[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? vy[i  ] : vy[i+1];
        px[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? px[i+1] : px[i  ];
        px[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? px[i  ] : px[i+1];
        py[i  ] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? py[i+1] : py[i  ];
        py[i+1] <= (vx[i]*vy[i+1] - vx[i+1]*vy[i] > 0) ? py[i  ] : py[i+1];*/
      //end
        Nextstate <= CrossSort_odd;
      end
    end

    OutputState:
    begin
      if (out_i == point_num - 3'd1)
        Nextstate <= InitState;
      else
        Nextstate <= OutputState;
    end
    
    default:
    begin
      /*for (j = 0; j < 6; j=j+1) begin
        px[j] <= 10'b0;
        py[j] <= 10'b0;
        vx[j] <= 10'b0;
        vy[j] <= 10'b0;
      end*/
      Nextstate <= InitState;
    end
  endcase
end


// Output
always @(CurrState, out_i) begin
  case(CurrState)
    OutputState:
    begin
      valid <= 1'b1;
      Xout <= px[out_i];
      Yout <= py[out_i];
    end
    default:
    begin
      valid <= 1'b0;
      Xout <= 10'b0;
      Yout <= 10'b0;
    end
  endcase
end

endmodule