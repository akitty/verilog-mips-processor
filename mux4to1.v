module mux4to1#(parameter W = 32)
	(
		input [1:0] select_in,
		input [W-1:0] data0_in,
		input [W-1:0] data1_in,
		input [W-1:0] data2_in,
		input [W-1:0] data3_in,
		output reg [W-1:0] data_out
	);
	
	always @(*)
		begin
			data_out = 32'h00000000;
			case (select_in)
				2'b00:
					data_out = data0_in;
				2'b01:
					data_out = data1_in;
				2'b10:
					data_out = data2_in;
				2'b11:
					data_out = data3_in;
			endcase
		end
endmodule