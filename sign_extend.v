module sign_extend#(parameter W = 16)
	(
	input [W-1:0] in,
	output reg [31:0] out
	);
	
	always @(*)
		begin
			//out[W-1:0] = in;
			//out[31:W-1] = {(32-W){in[W-1]}};
            out[31:0] = { {32-W{in[W-1]}} , { in }};
		end
endmodule