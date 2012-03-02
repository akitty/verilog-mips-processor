module adder#(parameter W = 32)
	(
	input [W-1:0] left_in,
	input [W-1:0]	right_in,
	output reg [W:0] sum_out
	);
	
	always @(*)
		begin
			sum_out = left_in + right_in;
		end
endmodule
