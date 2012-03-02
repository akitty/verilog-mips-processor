module reg_file#(parameter W = 32)
	(
	input 				clock,
	input 				reset,
	input [4:0] 	read_reg1_in,
	input [4:0] 	read_reg2_in,
	input [4:0] 	write_reg_in,
	input 					write_en_in,
	input [W-1:0] 	write_data_in,
	output reg [W-1:0] 	read_data1_out,
	output reg [W-1:0]	read_data2_out	
	);

	reg [W-1:0] reg_file [W-1:0];
	
	// asynchronous reads
	always @(*)
		begin
			read_data1_out = reg_file[read_reg1_in];
			read_data2_out = reg_file[read_reg2_in];
		end
	
	// synchronous writes; handles $zero register
	always @(posedge clock)
		begin
			if(reset)
				begin
					reg_file[0] <= 0;
					reg_file[1] <= 0;
					reg_file[2] <= 0;
					reg_file[3] <= 0;
					reg_file[4] <= 0;
					reg_file[5] <= 0;
					reg_file[6] <= 0;
					reg_file[7] <= 0;
					reg_file[8] <= 0;
					reg_file[9] <= 0;
					reg_file[10] <= 0;
					reg_file[11] <= 0;
					reg_file[12] <= 0;
					reg_file[13] <= 0;
					reg_file[14] <= 0;
					reg_file[15] <= 0;
					reg_file[16] <= 0;
					reg_file[17] <= 0;
					reg_file[18] <= 0;
					reg_file[19] <= 0;
					reg_file[20] <= 0;
					reg_file[21] <= 0;
					reg_file[22] <= 0;
					reg_file[23] <= 0;
					reg_file[24] <= 0;
					reg_file[25] <= 0;
					reg_file[26] <= 0;
					reg_file[27] <= 0;
					reg_file[28] <= 0;
					reg_file[29] <= 0;
					reg_file[30] <= 0;
					reg_file[31] <= 0;
				end
			else if(write_en_in)
				begin
					if(write_reg_in != 0)
						begin
							reg_file[write_reg_in] <= write_data_in;
						end
				end
		end
endmodule
