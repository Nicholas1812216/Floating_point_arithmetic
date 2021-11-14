`timescale 1ns/1ps

module IEEE_754_to_32_32_fixed_point_tb();



  reg reset = 0;
  reg [31:0] IEEE_float = 0;
  wire [64:0] fixed_point;
  wire done;
  wire nan;
  wire pos_inf;
  wire neg_inf;
  wire overflow;
  wire underflow;
  IEEE_754_to_32_32_fixed_point DUT(.*);

  // typedef union
  // {
    // shortreal float;
	// int int_field;
  // } test_input;
  
  // test_input input_vector;
  
  reg [31:0] test [13:0];
  
  initial begin
    $readmemh("C:/Users/19259/Documents/float_to_fixed_conversion/float_test_data.txt", test, 0, 13);  
  end

reg clk = 0;

always begin
  #5 clk = 0;
  #5 clk = 1;
end


initial begin
  reset = 1;
  #20 reset = 0;
  for(int i = 0;i<14;i++) begin
    @(posedge clk)IEEE_float = test[i];
	@(posedge clk);
    wait(done == 1);
  end

  
end




endmodule