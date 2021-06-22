
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
  
  reg [2:0] CurrState, Nextstate;
  parameter [2:0]
  InitState = 3'd0,
  InputCenterState = 3'd1,
  InputPixel = 3'd2,
  InputNextPixel = 3'd3,
  WriteState = 3'd4,
  Sort_even = 3'd5,
  EndState = 3'd6;

  reg [3:0] win_cnt;
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
        Nextstate <= InputPixel;
      end
      
      InputPixel://2
      begin
        Nextstate <= InputNextPixel;
      end
      
      InputNextPixel://3
      begin
        if (win_cnt == 8) begin
          Nextstate <= WriteState;
        end
        else begin
          Nextstate <= InputPixel;
        end
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
      
      InputPixel, WriteState, EndState:
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
      win_cnt <= 0;
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
        data_wr <= tmp[8];
        
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




