	vlib work
	vmap work work
	
		puts "This is ModelSim (Full Version)"
		vlog -work work IEEE_754_to_32_32_fixed_point.v
		vlog -work work IEEE_754_to_32_32_fixed_point_tb.sv
		
		vsim work.IEEE_754_to_32_32_fixed_point_tb


		source ./wave.do
		
		run 950ns