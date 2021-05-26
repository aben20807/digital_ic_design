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
  
  // reg [7:0] window [8:0];
  reg [7:0] buf_idata;
  // reg [7:0] median;
  reg [7:0] tmp [8:0];
  reg reset_tmp;
  // reg reset_win;
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
  // wire [13:0] pix_cnt_wire;
  integer i, j;
  // assign win_cnt_wire = win_cnt;
  assign pix_cnt_modulo = (pix_cnt % 8'd128);
  wire [8:0] buf_idata_sub_tmp [8:0];

  wire buf_idata_ge_tmp [8:0];
  // always @(buf_idata or tmp[0] or tmp[1] or tmp[2] or tmp[3] or tmp[4] or tmp[5] or tmp[6] or tmp[7] or tmp[8]) begin
  //   for (j = 0; j < 9; j = j + 1)
  //     CLA_9bit(buf_idata_sub_tmp[j], $signed({1'b0,buf_idata}), $signed({1'b0,tmp[j]}), 0);
  // end

  // assign buf_idata_sub_tmp[0] = ($signed({1'b0,buf_idata}) - $signed({1'b0,tmp[0]}));
  // assign buf_idata_sub_tmp[1] = ($signed({1'b0,buf_idata}) - $signed({1'b0,tmp[1]}));
  // assign buf_idata_sub_tmp[2] = ($signed({1'b0,buf_idata}) - $signed({1'b0,tmp[2]}));
  // assign buf_idata_sub_tmp[3] = ($signed({1'b0,buf_idata}) - $signed({1'b0,tmp[3]}));
  // assign buf_idata_sub_tmp[4] = ($signed({1'b0,buf_idata}) - $signed({1'b0,tmp[4]}));
  // assign buf_idata_sub_tmp[5] = ($signed({1'b0,buf_idata}) - $signed({1'b0,tmp[5]}));
  // assign buf_idata_sub_tmp[6] = ($signed({1'b0,buf_idata}) - $signed({1'b0,tmp[6]}));
  // assign buf_idata_sub_tmp[7] = ($signed({1'b0,buf_idata}) - $signed({1'b0,tmp[7]}));
  // assign buf_idata_sub_tmp[8] = ($signed({1'b0,buf_idata}) - $signed({1'b0,tmp[8]}));

  // CLA_9bit c0(buf_idata_sub_tmp[0], $signed({1'b0,buf_idata}), $signed({1'b0,tmp[0]}));
  // CLA_9bit c1(buf_idata_sub_tmp[1], $signed({1'b0,buf_idata}), $signed({1'b0,tmp[1]}));
  // CLA_9bit c2(buf_idata_sub_tmp[2], $signed({1'b0,buf_idata}), $signed({1'b0,tmp[2]}));
  // CLA_9bit c3(buf_idata_sub_tmp[3], $signed({1'b0,buf_idata}), $signed({1'b0,tmp[3]}));
  // CLA_9bit c4(buf_idata_sub_tmp[4], $signed({1'b0,buf_idata}), $signed({1'b0,tmp[4]}));
  // CLA_9bit c5(buf_idata_sub_tmp[5], $signed({1'b0,buf_idata}), $signed({1'b0,tmp[5]}));
  // CLA_9bit c6(buf_idata_sub_tmp[6], $signed({1'b0,buf_idata}), $signed({1'b0,tmp[6]}));
  // CLA_9bit c7(buf_idata_sub_tmp[7], $signed({1'b0,buf_idata}), $signed({1'b0,tmp[7]}));
  // CLA_9bit c8(buf_idata_sub_tmp[8], $signed({1'b0,buf_idata}), $signed({1'b0,tmp[8]}));

  // assign buf_idata_ge_tmp[0] = !buf_idata_sub_tmp[0][8];
  // assign buf_idata_ge_tmp[1] = !buf_idata_sub_tmp[1][8];
  // assign buf_idata_ge_tmp[2] = !buf_idata_sub_tmp[2][8];
  // assign buf_idata_ge_tmp[3] = !buf_idata_sub_tmp[3][8];
  // assign buf_idata_ge_tmp[4] = !buf_idata_sub_tmp[4][8];
  // assign buf_idata_ge_tmp[5] = !buf_idata_sub_tmp[5][8];
  // assign buf_idata_ge_tmp[6] = !buf_idata_sub_tmp[6][8];
  // assign buf_idata_ge_tmp[7] = !buf_idata_sub_tmp[7][8];
  // assign buf_idata_ge_tmp[8] = !buf_idata_sub_tmp[8][8];

  // wire buf_idata_ge_tmpi_1 [8:0];
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
        // else if ((tmp[i] <= buf_idata)&&(tmp[i-1] <= buf_idata))
        else if ((buf_idata_ge_tmp[i])&&(buf_idata_ge_tmp[i-1]))
          tmp[i] <= tmp[i-1];
        else if ((buf_idata_ge_tmp[i])&&(!buf_idata_ge_tmp[i-1]))
          tmp[i] <= buf_idata;
      end
    end
  end
  // CurrState or pix_cnt or buf_idata or win_cnt or idata
  // CurrState or pix_cnt or win_cnt or idata or pix_cnt_modulo
  always @(posedge clk) begin
    if (CurrState != InputPixel)
      buf_idata <= buf_idata;
    else begin
      // case(pix_cnt)
      //   0:
      //   begin
      //     case(win_cnt)
      //       0,1,2,3,6:
      //         buf_idata <= 8'b0;
      //       default:
      //         buf_idata <= idata;
      //     endcase
      //   end
      //   127:
      //   begin
      //     case(win_cnt)
      //       0,1,2,5,8:
      //         buf_idata <= 8'b0;
      //       default:
      //         buf_idata <= idata;
      //     endcase
      //   end
      //   16256:
      //   begin
      //     case(win_cnt)
      //       0,3,6,7,8:
      //         buf_idata <= 8'b0;
      //       default:
      //         buf_idata <= idata;
      //     endcase
      //   end
      //   16383:
      //   begin
      //     case(win_cnt)
      //       2,5,6,7,8:
      //         buf_idata <= 8'b0;
      //       default:
      //         buf_idata <= idata;
      //     endcase
      //   end
      //   1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126:
      //   begin
      //     case(win_cnt)
      //       0,1,2:
      //         buf_idata <= 8'b0;
      //       default:
      //         buf_idata <= idata;
      //     endcase
      //   end
      //   16257,16258,16259,16260,16261,16262,16263,16264,16265,16266,16267,16268,16269,16270,16271,16272,16273,16274,16275,16276,16277,16278,16279,16280,16281,16282,16283,16284,16285,16286,16287,16288,16289,16290,16291,16292,16293,16294,16295,16296,16297,16298,16299,16300,16301,16302,16303,16304,16305,16306,16307,16308,16309,16310,16311,16312,16313,16314,16315,16316,16317,16318,16319,16320,16321,16322,16323,16324,16325,16326,16327,16328,16329,16330,16331,16332,16333,16334,16335,16336,16337,16338,16339,16340,16341,16342,16343,16344,16345,16346,16347,16348,16349,16350,16351,16352,16353,16354,16355,16356,16357,16358,16359,16360,16361,16362,16363,16364,16365,16366,16367,16368,16369,16370,16371,16372,16373,16374,16375,16376,16377,16378,16379,16380,16381,16382:
      //   begin
      //     case(win_cnt)
      //       6,7,8:
      //         buf_idata <= 8'b0;
      //       default:
      //         buf_idata <= idata;
      //     endcase
      //   end

      //   default:
      //   begin
      //     if (pix_cnt_modulo == 0) begin
      //       case(win_cnt)
      //         0,3,6:
      //           buf_idata <= 8'b0;
      //         default:
      //           buf_idata <= idata;
      //       endcase
      //     end
      //     else if (pix_cnt_modulo == 127) begin
      //       case(win_cnt)
      //         2,5,8:
      //           buf_idata <= 8'b0;
      //         default:
      //           buf_idata <= idata;
      //       endcase
      //     end
      //     else
      //     begin
      //       buf_idata <= idata;
      //     end
      //   end
      // endcase
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
      else if (pix_cnt_modulo == 0/*pix_cnt == 128 || pix_cnt == 256 || pix_cnt == 384 || pix_cnt == 512 || pix_cnt == 640 || 
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
              pix_cnt == 16128*/) begin
        case(win_cnt)
          0,3,6:
            buf_idata <= 8'b0;
          default:
            buf_idata <= idata;
        endcase
      end
      else if (pix_cnt_modulo == 127/*pix_cnt == 255 || pix_cnt == 383 || pix_cnt == 511 || pix_cnt == 639 || pix_cnt == 767 || 
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
              pix_cnt == 16255*/) begin
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
          Nextstate <= InputPixel; //XXX
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
  //win_cnt or pix_cnt
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
    // wen <= 1;
    reset_tmp <= 0;
    tmp_enable <= 0;
    // reset_win <= 0;
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
      
      InputPixel:
      begin
        busy <= 1'b1;
      end
      
      InputNextPixel:
      begin
        tmp_enable <= 1;
        busy <= 1'b1;
      end
      
      WriteState:
      begin
        busy <= 1'b1;
        // reset_win <= 1;
        // addr <= pix_cnt[13:0];
        // data_wr <= tmp[4];
        // reset_tmp <= 1;
      end

      EndState:
      begin
        busy <= 1'b1;
      end
      
      default: begin
        busy <= 1'b0;
      end
    endcase
  end

  // write to mem
  // always @(CurrState) begin
  //   case(CurrState)
  //     WriteState:
  //     begin
  //       wen <= 1;
  //       addr <= pix_cnt_wire;
  //       data_wr <= tmp[4];
  //     end

  //     default: begin
  //       wen <= 0;
  //       addr <= pix_cnt_wire;
  //       data_wr <= 8'b0;
  //     end
  //   endcase
  // end

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

  // always @(negedge clk or posedge reset) begin
  //   if (reset)
  //     reset_tmp <= 1;
  //   else
  //   begin
  //     case (CurrState)
  //     InputCenterState:
  //     begin
  //       reset_tmp <= 1;
  //     end

  //     default: begin
  //       reset_tmp <= 0;
  //     end
  //     endcase
  //   end
  // end

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
        data_wr <= tmp[4];
        
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


module CLA_3bit(S, Cout, PG, GG, A, B, Cin);
    output [2:0] S;
    output Cout,PG,GG;
    input [2:0] A;
    input [2:0] B;
    input Cin;
    wire [2:0] G,P,C;
 
    assign G = A & B; //Generate
    assign P = A ^ B; //Propagate
    assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign Cout = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    assign S = P ^ C;
    
    assign PG = P[2] & P[1] & P[0];
    assign GG = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]);
endmodule

module CLA_9bit(Sum, A, B);
  output [8:0] Sum;
  input [8:0] A;
  input [8:0] B;
  wire Cout;
  wire c2,p2,g2,c5,p5,g5,p8,g8;
  wire [8:0] iB = ~B;
  CLA_3bit CLA1(Sum[2:0], c2,   p2, g2, A[2:0], iB[2:0], 1'b0);
  CLA_3bit CLA2(Sum[5:3], c5,   p5, g5, A[5:3], iB[5:3], c2);
  CLA_3bit CLA3(Sum[8:6], Cout, p8, g8, A[8:6], iB[8:6], c5);
endmodule