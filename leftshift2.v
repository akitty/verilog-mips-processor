module leftshift2#(parameter W = 32)
	(
		input [W-1:0] in,
		output reg [31:0] out
	);

	always@(*)
		begin
			out = 32'h00000000;
			out = in<<2;
		end

endmodule
