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
wire cross_compare_result;

reg [2:0] CurrState, Nextstate;
parameter [2:0] InitState = 3'd0, 
                InputState = 3'd1, 
                Sort_odd_start = 3'd2,
                Sort_odd = 3'd3,
                Sort_even_start = 3'd4,
                Sort_even = 3'd5,
                OutputState = 3'd6;

reg [2:0] in_i, out_i, i, sort_outer;
reg outer_enable; // to enable the outer_i counter, being high when inner loop finish
integer j;

// State
always @(posedge clk or posedge reset) begin
  if (reset)
    CurrState <= InitState;
  else
    CurrState <= Nextstate;
end

assign cross_compare_result = (
  ($signed({1'b0,px[i  ]})-$signed({1'b0,px[0]}))*($signed({1'b0,py[i+1]})-$signed({1'b0,py[0]})) - 
  ($signed({1'b0,px[i+1]})-$signed({1'b0,px[0]}))*($signed({1'b0,py[i  ]})-$signed({1'b0,py[0]}))) > 0;

// Counter: in_i
always @(posedge clk or posedge reset) begin
  if (reset)
    in_i <= 3'd0;
  else begin
    case(CurrState)
      InputState:
        in_i <= in_i + 3'd1;
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
        out_i <= out_i + 3'd1;
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
      Sort_odd, Sort_even: begin
        if (outer_enable)
          sort_outer <= (sort_outer == point_num)? sort_outer: sort_outer + 3'd1;
        else
          sort_outer <= sort_outer;
      end
      Sort_even_start, Sort_odd_start:
        sort_outer <= sort_outer;
      default:
        sort_outer <= 3'd0;
    endcase
  end
end

// Counter: i (sort_inner)
always @(posedge clk or posedge reset) begin
  if (reset)
    i <= 3'd0;
  else begin
    case(CurrState)
      Sort_even_start:
        i <= 3'd2;
      Sort_odd_start:
        i <= 3'd1;
      Sort_even, Sort_odd:
        i <= (i == point_num - 3'd1)? i : i + 3'd2;
      default:
       	i <= 3'd0;
    endcase
  end
end

// px py
always @(negedge clk or posedge reset) begin
  if (reset)
    for (j = 0; j < 6; j=j+1) begin
      px[j] <= 10'b0;
      py[j] <= 10'b0;
    end
  else begin
    case(CurrState)
      InitState: 
      begin
      	 for (j = 0; j < 6; j=j+1) begin
          px[j] <= 10'b0;
          py[j] <= 10'b0;
        end
      end

      InputState:
      begin
        px[in_i] <= Xin;
        py[in_i] <= Yin;
      end
      
      Sort_even, Sort_odd:
      begin
        px[i  ] <= (cross_compare_result) ? px[i+1] : px[i  ];
        px[i+1] <= (cross_compare_result) ? px[i  ] : px[i+1];
        py[i  ] <= (cross_compare_result) ? py[i+1] : py[i  ];
        py[i+1] <= (cross_compare_result) ? py[i  ] : py[i+1];
      end

      default:
      begin
        for (j = 0; j < 6; j=j+1) begin
          px[j] <= px[j];
          py[j] <= py[j];
        end
      end
    endcase
  end
end

// Next Logic
always @(point_num or CurrState or in_i or out_i or sort_outer or i) begin
  outer_enable <= 0;
  case(CurrState)
    InitState:
      Nextstate <= InputState;
    
    InputState:
    begin
      if (in_i == point_num - 3'd1)
        Nextstate <= Sort_odd_start;
      else
        Nextstate <= InputState;
    end

    Sort_odd_start:
      Nextstate <= Sort_odd;

    Sort_odd:
    begin
      if (i >= point_num - 3'd3) begin
        if (sort_outer >= point_num - 3'd1 || point_num == 3)
          // early jump when point_num is 3 because there is only one comparison in need
          Nextstate <= OutputState;
        else begin
          outer_enable <= 1;
          Nextstate <= Sort_even_start;
        end
      end
      else
        Nextstate <= Sort_odd;
    end
    Sort_even_start:
      Nextstate <= Sort_even;

    Sort_even:
    begin
      if (i >= point_num - 3'd3) begin
        if (sort_outer >= point_num - 3'd1)
          Nextstate <= OutputState;
        else begin
          outer_enable <= 1;
          Nextstate <= Sort_odd_start;
        end
      end
      else
        Nextstate <= Sort_even;
    end

    OutputState:
    begin
      if (out_i == point_num - 3'd1)
        Nextstate <= InitState;
      else
        Nextstate <= OutputState;
    end
    
    default:
      Nextstate <= InitState;
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