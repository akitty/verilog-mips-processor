`timescale 1ns / 1ps

/*
**  UCSD CSE 141L Lab2/3 Provided Module
** -------------------------------------------------------------------
**  Instruction Rom for Single-Cycle MIPS Processor for Altera FPGAs
**
**  Change Log:
**  1/13/2012 - Adrian Caulfield - Initial Implementation
**
**
**  NOTE:  The Provided Modules do NOT follow the course coding standards
*/

module inst_rom (
	input	clock,
	input reset,
	input [31:0] addr_in,
	output [31:0] data_out
);
	parameter ADDR_WIDTH=8;
	parameter INIT_PROGRAM="C:/Users/evfung/Desktop/141Lab2/blank.memh";   //CHANGE

	reg [31:0] rom [0:2**ADDR_WIDTH-1];
	reg [31:0] out;
	
	assign data_out = {out[7:0],out[15:8],out[23:16],out[31:24]}; //flip bytes
	
	initial
	begin
		$readmemh(INIT_PROGRAM, rom);
	end
	
	always @(posedge clock) begin
		if (reset) begin
			out <= 32'h00000000;
		end else begin
			out <= rom[addr_in[ADDR_WIDTH+1:2]];
		end
	end

endmodule

