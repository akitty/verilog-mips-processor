`define RESET_VAL 32'h003ffffc
module program_counter#(parameter W = 32)
	(
	input 				 		 clock,
	input 				 		 reset,
	input [W-1:0] 		 in,
	output reg [W-1:0] out
	);
		
	always @(posedge clock)
		begin
			if(reset)
				begin
					out <= `RESET_VAL;
				end
			else
				begin
					out <= in;
				end
		end
endmodule
