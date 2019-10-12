// mfp_ahb_gpio.v
//
// General-purpose I/O module for Altera's DE2-115 and 
// Digilent's (Xilinx) Nexys4-DDR board


`include "mfp_ahb_const.vh"

module mfp_ahb_7seg(
    input                        HCLK,
    input                        HRESETn,
    input                        HADDR,
    input      [  1          :0] HTRANS,
    input      [ 31          :0] HWDATA,
    input                        HWRITE,
    input                        HSEL,
    //output reg [ 31          :0] HRDATA,

// memory-mapped I/O
    //input      [`MFP_N_SW-1  :0] IO_Switch,
    //input      [`MFP_N_PB-1  :0] IO_PB,
    //output reg [`MFP_N_LED-1 :0] IO_LED,
    output reg [`MFP_N_SEG-1 :0] IO_SEG
);

  reg         HADDR_d;
  reg         HWRITE_d;
  reg         HSEL_d;
  //reg  [1:0]  HTRANS_d;
  reg       [7:0] DE, DP;
  reg       [31:0] DVL, DVU;
  wire        we;            // write enable

  // delay HADDR, HWRITE, HSEL, and HTRANS to align with HWDATA for writing
  always @ (posedge HCLK) 
  begin
    HADDR_d  <= HADDR;
	HWRITE_d <= HWRITE;
	HSEL_d   <= HSEL;
	//HTRANS_d <= HTRANS;
  end
  
  // overall write enable signal
  assign we = HSEL_d & HWRITE_d;

    always @(posedge HCLK or negedge HRESETn)
       if (~HRESETn) begin
         IO_SEG <= `MFP_N_SEG'b0;  
       end else if (we)
         case (HADDR_d)
           `H_SEG_ADDR_en:       DE <= HWDATA[7:0];
           `H_SEG_ADDR_digit3_0: DVL <= HWDATA;
           `H_SEG_ADDR_digit7_4: DVU <= HWDATA;
           `H_SEG_ADDR_dp:       DP <= HWDATA[7:0];
         endcase

    mfp_ahb_sevensegtimer mfp_seven_seg(.clk(HCLK), .resetn(HRESETn), .EN(DE), .DIGITS({DVU,DVL}), .dp(DP), .DISPOUT(IO_SEG[15:8]), .DISPENOUT(IO_SEG[7:0]));
//	always @(posedge HCLK or negedge HRESETn)
//       if (~HRESETn)
//         HRDATA <= 32'h0;
//       else
//	     case (HADDR)
//           `H_SW_IONUM: HRDATA <= { {32 - `MFP_N_SW {1'b0}}, IO_Switch };
//           `H_PB_IONUM: HRDATA <= { {32 - `MFP_N_PB {1'b0}}, IO_PB };
//            default:    HRDATA <= 32'h00000000;
//         endcase
		 
endmodule
