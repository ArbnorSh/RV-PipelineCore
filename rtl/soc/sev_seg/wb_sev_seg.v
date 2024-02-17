// For 50 MHz clock, default count value
// achieves 2 ms refresh rate for a digit
module wb_sevenseg
  #(parameter CNT_VALUE=32'h186A0)
  (
   input wire 	      i_wb_clk,
   input wire 	      i_wb_rst,
   input wire [31:0]  i_wb_dat,
   input wire [3:0]   i_wb_sel,
   input wire 	      i_wb_we,
   input wire 	      i_wb_cyc,
   input wire 	      i_wb_stb,
   output wire [31:0] o_wb_rdt,
   output reg 	      o_wb_ack,
   output reg [6:0]   o_ca,
   output reg [7:0]   o_an);

   reg [31:0] 	    cnt;
   
   reg [7:0] 	    an;
   reg [7:0] 	    an_r;

   reg [3:0] 	    cur_nibble;
   reg [32:0] 	    word;

   assign o_wb_rdt = word;

   always @(posedge i_wb_clk) begin
      an_r <= an;
      o_an <= ~an_r;
      o_wb_ack <= i_wb_cyc & i_wb_stb & !o_wb_ack;
      if (i_wb_cyc & i_wb_stb & i_wb_we) begin
         if (i_wb_sel[0]) word[7:0]   <= i_wb_dat[7:0];
         if (i_wb_sel[1]) word[15:8]  <= i_wb_dat[15:8];
         if (i_wb_sel[2]) word[23:16] <= i_wb_dat[23:16];
         if (i_wb_sel[3]) word[31:24] <= i_wb_dat[31:24];
      end
      if (cnt == 32'd0) begin
         an <= {an[0],an[7:1]};
         cnt <= CNT_VALUE;
      end else begin
         cnt <= cnt - 1;
      end
      cur_nibble <= (word[3:0]   & {4{an[0]}}) |
		    (word[7:4]   & {4{an[1]}}) |
		    (word[11:8]  & {4{an[2]}}) |
		    (word[15:12] & {4{an[3]}}) |
		    (word[19:16] & {4{an[4]}}) |
		    (word[23:20] & {4{an[5]}}) |
		    (word[27:24] & {4{an[6]}}) |
		    (word[31:28] & {4{an[7]}});
      case (cur_nibble)
	4'h0: o_ca <= 7'b1000000;
	4'h1: o_ca <= 7'b1111001;
	4'h2: o_ca <= 7'b0100100;
	4'h3: o_ca <= 7'b0110000;
	4'h4: o_ca <= 7'b0011001;
	4'h5: o_ca <= 7'b0010010;
	4'h6: o_ca <= 7'b0000010;
	4'h7: o_ca <= 7'b1111000;
	4'h8: o_ca <= 7'b0000000;
	4'h9: o_ca <= 7'b0011000;
	4'hA: o_ca <= 7'b0001000;
	4'hB: o_ca <= 7'b0000011;
	4'hC: o_ca <= 7'b1000110;
	4'hD: o_ca <= 7'b0100001;
	4'hE: o_ca <= 7'b0000110;
	4'hF: o_ca <= 7'b0001110;
	default: o_ca <= 7'b1001001;
      endcase
      if (i_wb_rst) begin
         an <= 8'b10000000;
         cnt <= CNT_VALUE;
         o_wb_ack <= 1'b0;
      end
   end

endmodule