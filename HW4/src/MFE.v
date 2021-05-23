`timescale 1ns/10ps

module MFE(clk,
           reset,
           busy,
           ready,
           iaddr,
           idata,
           data_rd,
           data_wr,
           addr,
           wen);
  input clk;
  input reset;
  output busy;
  input ready;
  output [13:0] iaddr;
  input	[7:0] idata;
  input	[7:0] data_rd;
  output [7:0] data_wr;
  output [13:0] addr;
  output wen;
  
  reg busy;
  reg [13:0] iaddr;
  reg [7:0] data_wr;
  reg [13:0] addr;
  reg wen;
  
  reg [7:0] window [8:0];
  reg [7:0] buf_idata;
  reg [7:0] median;
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
  
  integer win_cnt, pix_cnt, i;

  always @(negedge clk or posedge reset_tmp) begin
    if (reset_tmp)
      tmp[0] <= 8'b0;
    else if (!tmp_enable)
      tmp[0] <= tmp[0];
    else begin
      if (tmp[0] > buf_idata)
        tmp[0] <= tmp[0];
      else
        tmp[0] <= buf_idata;
    end
  end

  always @(negedge clk or posedge reset_tmp) begin
    for (i = 1; i < 9; i = i + 1) begin
      if (reset_tmp)
        tmp[i] <= 8'b0;
      else if (!tmp_enable)
        tmp[i] <= tmp[i];
      else begin
        if (tmp[i] > buf_idata)
          tmp[i] <= tmp[i];
        else if ((tmp[i] <= buf_idata)&&(tmp[i-1] <= buf_idata))
          tmp[i] <= tmp[i-1];
        else if ((tmp[i] <= buf_idata)&&(tmp[i-1] > buf_idata))
          tmp[i] <= buf_idata;
      end
    end
  end
  
  always @(CurrState) begin
    if (CurrState != InputCenterState)
      buf_idata = buf_idata;
    else begin
      if (pix_cnt == 0) begin
        case(win_cnt)
          0,1,2,3,6:
            buf_idata = 8'b0;
          default:
            buf_idata = idata;
        endcase
      end
      else if (pix_cnt == 127) begin
        case(win_cnt)
          0,1,2,5,8:
            buf_idata = 8'b0;
          default:
            buf_idata = idata;
        endcase
      end
      else if (pix_cnt == 16256) begin
        case(win_cnt)
          0,3,6,7,8:
            buf_idata = 8'b0;
          default:
            buf_idata = idata;
        endcase
      end
      else if (pix_cnt == 16383) begin
        case(win_cnt)
          2,5,6,7,8:
            buf_idata = 8'b0;
          default:
            buf_idata = idata;
        endcase
      end
      else if (pix_cnt >= 1 && pix_cnt <= 126) begin
        case(win_cnt)
          0,1,2:
            buf_idata = 8'b0;
          default:
            buf_idata = idata;
        endcase
      end
      else if (pix_cnt >= 16257 && pix_cnt <= 16382) begin
        case(win_cnt)
          6,7,8:
            buf_idata = 8'b0;
          default:
            buf_idata = idata;
        endcase
      end
      else if (pix_cnt == 128 || pix_cnt == 256 || pix_cnt == 384 || pix_cnt == 512 || pix_cnt == 640 || 
              pix_cnt == 768 || pix_cnt == 896 || pix_cnt == 1024 || pix_cnt == 1152 || pix_cnt == 1280 || 
              pix_cnt == 1408 || pix_cnt == 1536 || pix_cnt == 1664 || pix_cnt == 1792 || pix_cnt == 1920 || 
              pix_cnt == 2048 || pix_cnt == 2176 || pix_cnt == 2304 || pix_cnt == 2432 || pix_cnt == 2560 || 
              pix_cnt == 2688 || pix_cnt == 2816 || pix_cnt == 2944 || pix_cnt == 3072 || pix_cnt == 3200 || 
              pix_cnt == 3328 || pix_cnt == 3456 || pix_cnt == 3584 || pix_cnt == 3712 || pix_cnt == 3840 || 
              pix_cnt == 3968 || pix_cnt == 4096 || pix_cnt == 4224 || pix_cnt == 4352 || pix_cnt == 4480 || 
              pix_cnt == 4608 || pix_cnt == 4736 || pix_cnt == 4864 || pix_cnt == 4992 || pix_cnt == 5120 || 
              pix_cnt == 5248 || pix_cnt == 5376 || pix_cnt == 5504 || pix_cnt == 5632 || pix_cnt == 5760 || 
              pix_cnt == 5888 || pix_cnt == 6016 || pix_cnt == 6144 || pix_cnt == 6272 || pix_cnt == 6400 || 
              pix_cnt == 6528 || pix_cnt == 6656 || pix_cnt == 6784 || pix_cnt == 6912 || pix_cnt == 7040 || 
              pix_cnt == 7168 || pix_cnt == 7296 || pix_cnt == 7424 || pix_cnt == 7552 || pix_cnt == 7680 || 
              pix_cnt == 7808 || pix_cnt == 7936 || pix_cnt == 8064 || pix_cnt == 8192 || pix_cnt == 8320 || 
              pix_cnt == 8448 || pix_cnt == 8576 || pix_cnt == 8704 || pix_cnt == 8832 || pix_cnt == 8960 || 
              pix_cnt == 9088 || pix_cnt == 9216 || pix_cnt == 9344 || pix_cnt == 9472 || pix_cnt == 9600 || 
              pix_cnt == 9728 || pix_cnt == 9856 || pix_cnt == 9984 || pix_cnt == 10112 || pix_cnt == 10240 || 
              pix_cnt == 10368 || pix_cnt == 10496 || pix_cnt == 10624 || pix_cnt == 10752 || pix_cnt == 10880 || 
              pix_cnt == 11008 || pix_cnt == 11136 || pix_cnt == 11264 || pix_cnt == 11392 || pix_cnt == 11520 || 
              pix_cnt == 11648 || pix_cnt == 11776 || pix_cnt == 11904 || pix_cnt == 12032 || pix_cnt == 12160 || 
              pix_cnt == 12288 || pix_cnt == 12416 || pix_cnt == 12544 || pix_cnt == 12672 || pix_cnt == 12800 || 
              pix_cnt == 12928 || pix_cnt == 13056 || pix_cnt == 13184 || pix_cnt == 13312 || pix_cnt == 13440 || 
              pix_cnt == 13568 || pix_cnt == 13696 || pix_cnt == 13824 || pix_cnt == 13952 || pix_cnt == 14080 || 
              pix_cnt == 14208 || pix_cnt == 14336 || pix_cnt == 14464 || pix_cnt == 14592 || pix_cnt == 14720 || 
              pix_cnt == 14848 || pix_cnt == 14976 || pix_cnt == 15104 || pix_cnt == 15232 || pix_cnt == 15360 || 
              pix_cnt == 15488 || pix_cnt == 15616 || pix_cnt == 15744 || pix_cnt == 15872 || pix_cnt == 16000 || 
              pix_cnt == 16128) begin
        case(win_cnt)
          0,3,6:
            buf_idata = 8'b0;
          default:
            buf_idata = idata;
        endcase
      end
      else if (pix_cnt == 255 || pix_cnt == 383 || pix_cnt == 511 || pix_cnt == 639 || pix_cnt == 767 || 
              pix_cnt == 895 || pix_cnt == 1023 || pix_cnt == 1151 || pix_cnt == 1279 || pix_cnt == 1407 || 
              pix_cnt == 1535 || pix_cnt == 1663 || pix_cnt == 1791 || pix_cnt == 1919 || pix_cnt == 2047 || 
              pix_cnt == 2175 || pix_cnt == 2303 || pix_cnt == 2431 || pix_cnt == 2559 || pix_cnt == 2687 || 
              pix_cnt == 2815 || pix_cnt == 2943 || pix_cnt == 3071 || pix_cnt == 3199 || pix_cnt == 3327 || 
              pix_cnt == 3455 || pix_cnt == 3583 || pix_cnt == 3711 || pix_cnt == 3839 || pix_cnt == 3967 || 
              pix_cnt == 4095 || pix_cnt == 4223 || pix_cnt == 4351 || pix_cnt == 4479 || pix_cnt == 4607 || 
              pix_cnt == 4735 || pix_cnt == 4863 || pix_cnt == 4991 || pix_cnt == 5119 || pix_cnt == 5247 || 
              pix_cnt == 5375 || pix_cnt == 5503 || pix_cnt == 5631 || pix_cnt == 5759 || pix_cnt == 5887 || 
              pix_cnt == 6015 || pix_cnt == 6143 || pix_cnt == 6271 || pix_cnt == 6399 || pix_cnt == 6527 || 
              pix_cnt == 6655 || pix_cnt == 6783 || pix_cnt == 6911 || pix_cnt == 7039 || pix_cnt == 7167 || 
              pix_cnt == 7295 || pix_cnt == 7423 || pix_cnt == 7551 || pix_cnt == 7679 || pix_cnt == 7807 || 
              pix_cnt == 7935 || pix_cnt == 8063 || pix_cnt == 8191 || pix_cnt == 8319 || pix_cnt == 8447 || 
              pix_cnt == 8575 || pix_cnt == 8703 || pix_cnt == 8831 || pix_cnt == 8959 || pix_cnt == 9087 || 
              pix_cnt == 9215 || pix_cnt == 9343 || pix_cnt == 9471 || pix_cnt == 9599 || pix_cnt == 9727 || 
              pix_cnt == 9855 || pix_cnt == 9983 || pix_cnt == 10111 || pix_cnt == 10239 || pix_cnt == 10367 || 
              pix_cnt == 10495 || pix_cnt == 10623 || pix_cnt == 10751 || pix_cnt == 10879 || pix_cnt == 11007 || 
              pix_cnt == 11135 || pix_cnt == 11263 || pix_cnt == 11391 || pix_cnt == 11519 || pix_cnt == 11647 || 
              pix_cnt == 11775 || pix_cnt == 11903 || pix_cnt == 12031 || pix_cnt == 12159 || pix_cnt == 12287 || 
              pix_cnt == 12415 || pix_cnt == 12543 || pix_cnt == 12671 || pix_cnt == 12799 || pix_cnt == 12927 || 
              pix_cnt == 13055 || pix_cnt == 13183 || pix_cnt == 13311 || pix_cnt == 13439 || pix_cnt == 13567 || 
              pix_cnt == 13695 || pix_cnt == 13823 || pix_cnt == 13951 || pix_cnt == 14079 || pix_cnt == 14207 || 
              pix_cnt == 14335 || pix_cnt == 14463 || pix_cnt == 14591 || pix_cnt == 14719 || pix_cnt == 14847 || 
              pix_cnt == 14975 || pix_cnt == 15103 || pix_cnt == 15231 || pix_cnt == 15359 || pix_cnt == 15487 || 
              pix_cnt == 15615 || pix_cnt == 15743 || pix_cnt == 15871 || pix_cnt == 15999 || pix_cnt == 16127 || 
              pix_cnt == 16255) begin
        case(win_cnt)
          2,5,8:
            buf_idata = 8'b0;
          default:
            buf_idata = idata;
        endcase
      end
      else
      begin
        buf_idata = idata;
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
  always @(ready, CurrState) begin
    case(CurrState)
      
      InitState:
      begin
        if (ready) begin
          Nextstate <= InputCenterState;
          win_cnt <= 0;
          pix_cnt <= 0;
          reset_tmp <= 1;
        end
        else
        Nextstate <= InitState;
      end
      
      InputCenterState:
      begin
        Nextstate <= InputPixel;
        reset_tmp <= 0;
        tmp_enable <= 1;
      end
      
      InputPixel:
      begin
        tmp_enable <= 0;
        Nextstate <= InputNextPixel;
      end
      
      InputNextPixel:
      begin
        if (win_cnt == 8) begin
          win_cnt <= 0;
          wen <= 1;
          Nextstate <= WriteState;
        end
        else begin
          win_cnt <= win_cnt + 1;
          Nextstate <= InputCenterState;
        end
      end
      
      WriteState:
      begin
        if (pix_cnt == 16383) begin
          addr <= pix_cnt;
          data_wr <= tmp[4];
          pix_cnt <= 0;
          Nextstate <= EndState;
        end
        else begin
          addr <= pix_cnt;
          data_wr <= tmp[4];
          pix_cnt <= pix_cnt + 1;
          reset_tmp <= 1;
          Nextstate <= InputCenterState;
        end
      end
      
      default:
      Nextstate <= InitState;
    endcase
  end
  
  always @(win_cnt, pix_cnt) begin
    case(win_cnt)
      0:
      iaddr <= pix_cnt[13:0]-129;
      1:
      iaddr <= pix_cnt[13:0]-128;
      2:
      iaddr <= pix_cnt[13:0]-127;
      3:
      iaddr <= pix_cnt[13:0]-1;
      4:
      iaddr <= pix_cnt[13:0];
      5:
      iaddr <= pix_cnt[13:0]+1;
      6:
      iaddr <= pix_cnt[13:0]+127;
      7:
      iaddr <= pix_cnt[13:0]+128;
      8:
      iaddr <= pix_cnt[13:0]+129;
      
      default:
      busy <= pix_cnt[13:0];
    endcase
  end
  
  // Output busy
  always @(CurrState) begin
    case(CurrState)
      InitState, EndState:
      busy <= 1'b0;
      
      default:
      busy <= 1'b1;
    endcase
  end
  
endmodule