`timescale 1ns / 1ps

/*
**  UCSD CSE 141L Lab2/3 Provided Module
** -------------------------------------------------------------------
**  Serial Module for Single-Cycle MIPS Processor for Altera FPGAs
**  Implements a very simple memory mapped serial port interface
**  *Does Not* actually implement the serial communication
**
**  Change Log:
**  1/13/2012 - Adrian Caulfield - Initial Implementation
**
**
**  NOTE:  The Provided Modules do NOT follow the course coding standards
*/

module serial_buffer	(
	input	clock,
	input	reset,
		
	input [31:0] addr_in,
	output reg [31:0] data_out,
	input	re_in,
	input [31:0] data_in,
	input we_in,
		
	input	s_data_valid_in, //data to be read is available
	input [7:0] s_data_in,
	input	s_data_ready_in, //ready to recieve write data
	output s_rden_out,
	output [7:0] s_data_out,
	output s_wren_out
	);
	parameter MEM_ADDR = 16'hffff;
		
	//read values (async)
	always @(*) begin
		case(addr_in[3:2])
			2'h0:
				data_out = {31'b0, s_data_valid_in};
			2'h1:
				data_out = {24'b0, s_data_in};
			2'h2:
				data_out = {31'b0, s_data_ready_in};
			2'h3:
				data_out = {32'b0};
		endcase
	end
	
	
	
	reg	read_en;
	reg	write_en;
	reg [7:0] sbyte;
	
	assign s_rden_out = read_en;
	assign s_wren_out = write_en;
	assign s_data_out = sbyte;
	
	always @(posedge clock) begin
		if (reset) begin
			read_en <= 1'b0;
			write_en <= 1'b0;
			sbyte <= 8'b0;
		end else begin
			read_en <= 1'b0;
			write_en <= 1'b0;
			
			if (addr_in[31:16] == MEM_ADDR) begin
				if (re_in && (addr_in[3:2] == 2'h1)) begin //read data byte
					read_en <= 1'b0;
				end
				
				if (we_in && (addr_in[3:2] == 2'h3)) begin //byte write
					sbyte <= data_in[7:0];
					write_en <= 1'b1;
				end
			end
		end
	end
	
endmodule