`timescale 1ns/1ps

module IEEE_754_to_32_32_fixed_point( //accepts ieee 754 float and converts to signed Q32.32 fixed point value
                                      //maximum input: (2-2^-23)*2^31 = 4294967040
									  //minimum input: 1*2^-9 = 0.001953125
									  //Maximum latency: 15 clock cycles
  input clk,
  input reset,
  input [31:0] IEEE_float,
  output [64:0] fixed_point,
  output done,
  output nan,
  output pos_inf,
  output neg_inf,
  output overflow,
  output underflow
);


parameter IDLE = 0, NAN = 1, ZERO = 2, INF = 3, OVERFLOW = 4, UNDERFLOW = 5,
          E = 6, E_4_INC = 7, E_INC = 8, E_4_DEC = 9, E_DEC = 10, DONE = 11, RST = 12, NEG_POS = 13;
reg [3:0] state = 0;

wire s = IEEE_float[31];
wire [7:0] biased_exponent = IEEE_float[30:23];
wire [22:0] mantissa = IEEE_float [22:0];
wire or_exp = |biased_exponent;
wire and_exp = &biased_exponent;
wire or_mantissa = |mantissa;
wire signed [8:0] exponent = biased_exponent - 8'd127;
reg signed [8:0] exp_reg;
reg s_reg;
reg mantissa_reg;
reg [64:0] fixed_point_reg;

wire less_than_4 = ~(|exp_reg[5:2]);
wire exp_zero = (exp_reg == 0);
wire greater_than_neg_4 = (exp_reg > -4);

always@(posedge clk, posedge reset) begin
  if(reset) begin
    state <= RST;
  end
  else begin
    case(state)
	RST: state <= IDLE;
	IDLE: begin                     
	  if((~or_exp) & (~or_mantissa))
	    state <= ZERO;
      else if((and_exp)&(or_mantissa))
	    state <= NAN;
	  else if(and_exp & (~or_mantissa))
	    state <= INF;		
      else if(exponent > 31)
	    state <= OVERFLOW;
	  else if(exponent < -9)
	    state <= UNDERFLOW;
	  else if(or_exp & (~and_exp))
	    state <= E;
	end
	ZERO: state <= IDLE;
	NAN: state <= IDLE;
	OVERFLOW: state <= IDLE;
	UNDERFLOW: state <= IDLE;
	INF: state <= IDLE;
	E: begin
	  if(exp_reg[8])
	    state <= E_4_INC;
	  if(~exp_reg[8])
	    state <= E_4_DEC;
	end
    E_4_DEC: if(less_than_4) state <= E_DEC;
	E_DEC : if(exp_zero) state <= NEG_POS;
	E_4_INC: if(greater_than_neg_4) state <= E_INC;
	E_INC: if(exp_zero) state <= NEG_POS;
	NEG_POS: state <= DONE;	
	DONE: state <= IDLE;
	default: state <= RST;
	endcase
  end
end

always@(posedge clk) begin
  if(state == IDLE) s_reg <= s;
  
  case(state) 
    IDLE: begin
	  exp_reg <= exponent;
	  fixed_point_reg <= ((~or_exp) & (~or_mantissa)) ? {33'b0,mantissa,9'b0} : {33'b1,mantissa,9'b0};
	end
	E_4_DEC: begin
	  if(~less_than_4) begin
	    exp_reg <= exp_reg - 4;
		fixed_point_reg <= fixed_point_reg << 4; 
	  end
	end
	E_DEC: begin
	  if(~exp_zero) begin
	    exp_reg <= exp_reg - 1;
		fixed_point_reg <= fixed_point_reg << 1;
	  end
	end
	E_4_INC: begin
	  if(~greater_than_neg_4) begin
	    exp_reg <= exp_reg + 4;
		fixed_point_reg <= fixed_point_reg >> 4; 
	  end
	end
	E_INC: begin
	  if(~exp_zero) begin
	    exp_reg <= exp_reg + 1;
		fixed_point_reg <= fixed_point_reg >> 1;
	  end
	end	
	NEG_POS: begin
	  if(s_reg) fixed_point_reg <= ~fixed_point_reg + 1;
	end
  endcase
  
  
  
end

assign done = (state == ZERO) | (state == NAN) | (state == OVERFLOW) | (state == UNDERFLOW) | (state == DONE) | (state == INF);
assign nan       = (state == NAN);
assign pos_inf   = (state == INF) & (~s_reg);
assign neg_inf   = (state == INF) & s_reg;
assign overflow  = (state == OVERFLOW);
assign underflow = (state == UNDERFLOW);
assign fixed_point = fixed_point_reg;
endmodule