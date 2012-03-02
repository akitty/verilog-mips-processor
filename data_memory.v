`timescale 1ns / 1ps

/*
**  UCSD CSE 141L Lab2/3 Provided Module
** -------------------------------------------------------------------
**  Data Memory Module for Single-Cycle MIPS Processor for Altera FPGAs
**  
**  This module wraps several other modules to create the processors address space
**    A 4KB memory @ 0x7ffff000 to 0x7fffffff intended for the Stack
**		A 4KB memory @ 0x10000000 to 0x10000fff intended as RAM and static data
**		A Serial port interface @ 0xffff0000 to 0xffff000f  used for basic input and output
**
**		These memories will wrap - they only check the top 16-bits for an address match
**
**		This version also does not support reads with sizes other than 4-byte words (size_in == 2'b11)
**
**  Change Log:
**  1/13/2012 - Adrian Caulfield - Initial Implementation
**
**
**  NOTE:  The Provided Modules do NOT follow the course coding standards
*/


module data_memory(
	input clock,
	input reset,

	input		[31:0]	addr_in,
	input		[31:0]	writedata_in,
	input					re_in,
	input					we_in,
	input		[1:0]		size_in,
	output	reg [31:0]	readdata_out,
	
	//serial port connection that need to be routed out of the process
	input		[7:0]		serial_in,
	input					serial_ready_in,
	input					serial_valid_in,
	output	[7:0]		serial_out,
	output				serial_rden_out,
	output				serial_wren_out
);

parameter INIT_PROGRAM0 = "C:/Users/evfung/Desktop/141Lab2/blank.memh";
parameter INIT_PROGRAM1 = "C:/Users/evfung/Desktop/141Lab2/blank.memh";
parameter INIT_PROGRAM2 = "C:/Users/evfung/Desktop/141Lab2/blank.memh";
parameter INIT_PROGRAM3 = "C:/Users/evfung/Desktop/141Lab2/blank.memh";


	wire	[31:0]	data_readdata_serial;
	wire	[31:0]	data_readdata_data;
	wire	[31:0]	data_readdata_stack;

	
	//select correct source for memory reads
	always @(*) begin
		case(addr_in[31:16])
			16'h1000:
				readdata_out <= data_readdata_data;
			16'h7fff:
				readdata_out <= data_readdata_stack;
			16'hffff:
				readdata_out <= data_readdata_serial;
			default:
				readdata_out <= 32'b0;
		endcase
	end
	
		
	
	//DATA segment
	async_memory
		#(
		.MEM_ADDR(16'h1000),
		.DO_INIT(1),
		.INIT_PROGRAM0(INIT_PROGRAM0),
		.INIT_PROGRAM1(INIT_PROGRAM1),
		.INIT_PROGRAM2(INIT_PROGRAM2),
		.INIT_PROGRAM3(INIT_PROGRAM3)
		)
		data_seg
		(
		.clock(clock),
		.reset(reset),
		
		.addr_in(addr_in),
		.size_in(size_in),
		.data_out(data_readdata_data),
		.re_in(re_in),
		.data_in(writedata_in),
		.we_in(we_in)
	);
	
	//STACK segment
	async_memory
		#(
		.MEM_ADDR(16'h7fff)
		)
		stack_seg
		(
		.clock(clock),
		.reset(reset),
		
		.addr_in(addr_in),
		.size_in(size_in),
		.data_out(data_readdata_stack),
		.re_in(re_in),
		.data_in(writedata_in),
		.we_in(we_in)
	);
	
	//SERIAL MMIO
	serial_buffer	
		#(
		.MEM_ADDR(16'hffff)
		)
		ser
		(
		.clock(clock),
		.reset(reset),
		
		.addr_in(addr_in),
		.data_out(data_readdata_serial),
		.re_in(re_in),
		.data_in(writedata_in),
		.we_in(we_in),
		
		.s_data_valid_in(serial_valid_in),
		.s_data_ready_in(serial_ready_in),
		.s_data_in(serial_in),
		.s_rden_out(serial_rden_out),
		.s_data_out(serial_out),
		.s_wren_out(serial_wren_out)
	);



endmodule