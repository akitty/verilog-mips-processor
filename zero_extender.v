module zero_extender#(parameter W=16)
(
	input [W-1:0] in,
	output reg [31:0] out
)

always@(*)
	begin
		out = 0;
		out [W-1:0]= in;
	end
endmodule
