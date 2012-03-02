module mux#(parameter W = 32)
	(
	input select_in,
	input [W-1:0] _0_in,
	input [W-1:0] _1_in,
	output reg [W-1:0] out
	);
	
	always @(*)
		begin
			out= 32'h00000000;
			if(select_in)
				begin
					out = _1_in;
				end
			else
				begin
					out = _0_in;
				end
		end
endmodule
