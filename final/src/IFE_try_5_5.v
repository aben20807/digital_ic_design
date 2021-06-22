
`timescale 1ns/10ps

module IFE(clk,reset,busy,ready,iaddr,idata,data_rd,data_wr,addr,wen,sel);
	input				clk;
	input				reset;
	output				busy;	
	input				ready;	
	output	[13:0]		iaddr;
	input	[7:0]		idata;	
	input	[7:0]		data_rd;
	output	[7:0]		data_wr;
	output	[13:0]		addr;
	output				wen;
	input 	[1:0]		sel;
	
	
  reg busy;
  reg [13:0] iaddr;
  reg [7:0] data_wr;
  reg [13:0] addr;
  reg wen;
  
  reg [7:0] buf_idata;
  reg [7:0] tmp [8:0];
  reg reset_tmp;
  reg tmp_enable;
  
  reg [3:0] CurrState, Nextstate;
  parameter [3:0]
  InitState = 4'd0,
  InputCenterState = 4'd1,
  InputPixel = 4'd2,
  InputNextPixel = 4'd3,
  InputPixel5 = 4'd8,
  InputNextPixel5 = 4'd9,
  WriteState = 4'd4,
  Sort_even = 4'd5,
  EndState = 4'd6,
  PreWriteState = 4'd7;

  reg [4:0] win_cnt;
  reg [13:0] pix_cnt;

  wire [7:0] pix_cnt_modulo;
  integer i, j;
  assign pix_cnt_modulo = (pix_cnt % 8'd128);
  wire [8:0] buf_idata_sub_tmp [8:0];

  wire buf_idata_ge_tmp [8:0];
  
  assign buf_idata_ge_tmp[0] = buf_idata >= tmp[0];
  assign buf_idata_ge_tmp[1] = buf_idata >= tmp[1];
  assign buf_idata_ge_tmp[2] = buf_idata >= tmp[2];
  assign buf_idata_ge_tmp[3] = buf_idata >= tmp[3];
  assign buf_idata_ge_tmp[4] = buf_idata >= tmp[4];
  assign buf_idata_ge_tmp[5] = buf_idata >= tmp[5];
  assign buf_idata_ge_tmp[6] = buf_idata >= tmp[6];
  assign buf_idata_ge_tmp[7] = buf_idata >= tmp[7];
  assign buf_idata_ge_tmp[8] = buf_idata >= tmp[8];

  wire [7:0] mean3_3;
  assign mean3_3 = (tmp[0]+tmp[1]+tmp[2]+tmp[3]+tmp[4]+tmp[5]+tmp[6]+tmp[7]+tmp[8])/9;

  wire [7:0] mean5_5;
  reg [7:0] tmp5 [24:0];
  assign mean5_5 = (tmp5[0]+tmp5[1]+tmp5[2]+tmp5[3]+tmp5[4]+
  					tmp5[5]+tmp5[6]+tmp5[7]+tmp5[8]+tmp5[9]+
					tmp5[10]+tmp5[11]+tmp5[12]+tmp5[13]+tmp5[14]+
  					tmp5[15]+tmp5[16]+tmp5[17]+tmp5[18]+tmp5[19]+
					tmp5[20]+tmp5[21]+tmp5[22]+tmp5[23]+tmp5[24])/25;

  reg [7:0] center;

  always @(posedge clk or posedge reset_tmp) begin
    if (reset_tmp)
      tmp[0] <= 8'b0;
	else begin
		if(win_cnt == 4)
			center <= idata;
		else
			center <= center;
	end
  end

  always @(posedge clk or posedge reset_tmp) begin
    if (reset_tmp)
      tmp[0] <= 8'b0;
    else if (!tmp_enable)
      tmp[0] <= tmp[0];
    else begin
      if (!buf_idata_ge_tmp[0])
        tmp[0] <= tmp[0];
      else
        tmp[0] <= buf_idata;
    end
  end

  always @(posedge clk or posedge reset_tmp) begin
    for (i = 1; i < 9; i = i + 1) begin
      if (reset_tmp)
        tmp[i] <= 8'b0;
      else if (!tmp_enable)
        tmp[i] <= tmp[i];
      else begin
        if (!buf_idata_ge_tmp[i])
          tmp[i] <= tmp[i];
        else if ((buf_idata_ge_tmp[i]) && (buf_idata_ge_tmp[i-1]))
          tmp[i] <= tmp[i-1];
        else if ((buf_idata_ge_tmp[i]) && (!buf_idata_ge_tmp[i-1]))
          tmp[i] <= buf_idata;
      end
    end
  end
  
  always @(posedge clk) begin
    if (CurrState != InputPixel)
      buf_idata <= buf_idata;
    else begin
      if (pix_cnt == 0) begin
        case(win_cnt)
          0,1,2,3,6:
            buf_idata <= 8'b0;
          default:
            buf_idata <= idata;
        endcase
      end
      else if (pix_cnt == 127) begin
        case(win_cnt)
          0,1,2,5,8:
            buf_idata <= 8'b0;
          default:
            buf_idata <= idata;
        endcase
      end
      else if (pix_cnt == 16256) begin
        case(win_cnt)
          0,3,6,7,8:
            buf_idata <= 8'b0;
          default:
            buf_idata <= idata;
        endcase
      end
      else if (pix_cnt == 16383) begin
        case(win_cnt)
          2,5,6,7,8:
            buf_idata <= 8'b0;
          default:
            buf_idata <= idata;
        endcase
      end
      else if (pix_cnt >= 1 && pix_cnt <= 126) begin
        case(win_cnt)
          0,1,2:
            buf_idata <= 8'b0;
          default:
            buf_idata <= idata;
        endcase
      end
      else if (pix_cnt >= 16257 && pix_cnt <= 16382) begin
        case(win_cnt)
          6,7,8:
            buf_idata <= 8'b0;
          default:
            buf_idata <= idata;
        endcase
      end
      else if (pix_cnt_modulo == 0) begin
        case(win_cnt)
          0,3,6:
            buf_idata <= 8'b0;
          default:
            buf_idata <= idata;
        endcase
      end
      else if (pix_cnt_modulo == 127) begin
        case(win_cnt)
          2,5,8:
            buf_idata <= 8'b0;
          default:
            buf_idata <= idata;
        endcase
      end
      else
      begin
        buf_idata <= idata;
      end
    end
  end
  
  // State
  always @(posedge clk or posedge reset) begin
    if (reset)
      CurrState <= InitState;
    else
      CurrState <= Nextstate;
  end
  
  // Next Logic 
  always @(ready or CurrState or win_cnt or pix_cnt) begin
    case(CurrState)
      
      InitState://0
      begin
        if (ready) begin
          Nextstate <= InputCenterState;
        end
        else
        Nextstate <= InitState;
      end
      
      InputCenterState://1
      begin
		  if (sel == 1)
		  	Nextstate <= InputPixel5;
		  else
        	Nextstate <= InputPixel;
      end
      
      InputPixel://2
      begin
        Nextstate <= InputNextPixel;
      end
      
      InputNextPixel://3
      begin
        if (win_cnt == 8) begin
          Nextstate <= PreWriteState;
        end
        else begin
          Nextstate <= InputPixel;
        end
      end

	  InputPixel5://2
      begin
        Nextstate <= InputNextPixel5;
      end
      
      InputNextPixel5://3
      begin
        if (win_cnt == 24) begin
          Nextstate <= PreWriteState;
        end
        else begin
          Nextstate <= InputPixel5;
        end
      end

	  PreWriteState:
	  begin
		  Nextstate <= WriteState;
	  end
      
      WriteState://4
      begin
        
        if (pix_cnt == 16383) begin
          Nextstate <= EndState;
        end
        else begin
          Nextstate <= InputCenterState;
        end
      end

      EndState://5
        Nextstate <= InitState;
      
      default:
      Nextstate <= InitState;
    endcase
  end
  
  always @(posedge clk) begin
    case(win_cnt[3:0])
      0:
      iaddr <= pix_cnt-14'd129;
      1:
      iaddr <= pix_cnt-14'd128;
      2:
      iaddr <= pix_cnt-14'd127;
      3:
      iaddr <= pix_cnt-14'd1;
      4:
      iaddr <= pix_cnt;
      5:
      iaddr <= pix_cnt+14'd1;
      6:
      iaddr <= pix_cnt+14'd127;
      7:
      iaddr <= pix_cnt+14'd128;
      8:
      iaddr <= pix_cnt+14'd129;
      
      default:
      iaddr <= pix_cnt;
    endcase
  end
  
  // Output logic
  always @(ready or CurrState) begin
    reset_tmp <= 0;
    tmp_enable <= 0;
    case(CurrState)
      InitState:
      begin
        busy <= 1'b0;
        reset_tmp <= 1;
      end
      
      InputCenterState:
      begin
        busy <= 1'b1;
        reset_tmp <= 1;
      end
      
      InputPixel, PreWriteState, WriteState, EndState:
      begin
        busy <= 1'b1;
      end
      
      InputNextPixel:
      begin
        tmp_enable <= 1;
        busy <= 1'b1;
      end
      
      default: begin
        busy <= 1'b0;
      end
    endcase
  end

  always @(negedge clk or posedge reset) begin
    if (reset)
	  if (sel == 1)
	  	win_cnt <= 24;
	  else
        win_cnt <= 8;
    else
    begin
      case (CurrState)
      InputNextPixel:
      begin
        if (win_cnt == 8) begin
          win_cnt <= 0;
        end
        else begin
          win_cnt <= win_cnt + 4'd1;
        end
      end
	  InputNextPixel5:
      begin
        if (win_cnt == 24) begin
          win_cnt <= 0;
        end
        else begin
          win_cnt <= win_cnt + 4'd1;
        end
      end
      default:
        win_cnt <= win_cnt;
      endcase
    end
  end

  always @(negedge clk or posedge reset) begin
    if (reset)
      pix_cnt <= 16383;
    else
    begin
      case (CurrState)
      InputCenterState:
      begin
        if (pix_cnt == 16383) begin
          pix_cnt <= 14'd0;
        end
        else begin
          pix_cnt <= pix_cnt + 14'd1;
        end
      end

      default: begin
        pix_cnt <= pix_cnt;
      end
      endcase
    end
  end

  always @(posedge clk or posedge reset) begin
    if (reset)
      wen <= 0;
    else
    begin
      case (CurrState)
      WriteState:
      begin
        wen <= 1;
        addr <= pix_cnt;
		case (sel)
		0:
			data_wr <= mean3_3;
		1:
			data_wr <= 8'b0;
		2:
			data_wr <= tmp[8];
		3:
			data_wr <= (center < 8'd127)? 8'd0 : center;
		endcase
      end

      default: begin
        wen <= 0;
        addr <= pix_cnt;
        data_wr <= 8'b0;
      end
      endcase
    end
  end
	
endmodule




