`define ADDER_CONST 4
`define WORD_WIDTH 31

module processor
(
	input clock,
	input reset,
	
	// these ports are used for serial IO
	// must be wired up to the data_memory module
	input [7:0] serial_in,
	input serial_valid_in,
	input serial_ready_in,
	output [7:0] serial_out,
	output serial_rden_out,
	output serial_wren_out
);

	wire [`WORD_WIDTH:0] pc_plus4;
	wire [`WORD_WIDTH:0] pc_in;
	wire [`WORD_WIDTH:0] pc_out;
	
	wire [`WORD_WIDTH:0] branch_amount;
	wire [`WORD_WIDTH:0] branch_address;
	wire [`WORD_WIDTH:0] jump_shifted_addr;
	
	wire [`WORD_WIDTH:0] inst_out;
	
	wire [4:0] 	rs_or_rt;
	wire [4:0] reg_write_addr;
	wire [`WORD_WIDTH:0] reg_read_data1;
	wire [`WORD_WIDTH:0] reg_read_data2;
	wire [`WORD_WIDTH:0] mux_to_alu_out;
    wire [31:0] write_data_wire;
	wire [`WORD_WIDTH:0] nonlink_write_data;
	wire [`WORD_WIDTH:0] sign_extension_out;
	wire [`WORD_WIDTH:0] alu_out;
	wire [`WORD_WIDTH:0] datamem_read_data_out;
	
	//pat added

	wire [1:0] word_size;
	wire load_signed;

	wire [5:0] alu_func;
	wire is_rtype;
	wire select_mux_to_alu;
	wire select_mux_to_write_data;
	wire reg_write_enable;
	wire datamem_read_enable;
	wire datamem_write_enable;
	
	wire is_linking;
	wire is_jump;
	wire is_jump_reg;
	wire is_branch;
	
	wire [31:0] sign8out;
	wire [31:0] sign16out;
	wire [31:0] load8;
	wire [31:0] load16;

	wire [7:0] load8_out;
	wire [31:0] load_data;
	wire [31:0] to_alu_mux;
	
	wire is_signed;
	wire is_lui;
	wire [31:0] to_signed_mux;
	wire [31:0] pc_plus8;
    
    //pipeline1
    
    //end pipeline1
    
    // Instruction Memory
	inst_rom #(
		.INIT_PROGRAM("C:/lab4/fib.inst_rom.memh"),
		.ADDR_WIDTH(10)
				) instr_mem
	(
		.clock(clock),
		.reset(reset),
		.addr_in(pc_in),
		.data_out(inst_out)
	);
    
    // Data/Stack Memory
	data_memory #(			    .INIT_PROGRAM0("C:/lab4/fib.data_ram0.memh"),
								.INIT_PROGRAM1("C:/lab4/fib.data_ram1.memh"),
								.INIT_PROGRAM2("C:/lab4/fib.data_ram2.memh"),
								.INIT_PROGRAM3("C:/lab4/fib.data_ram3.memh"))
								dm
	(
		.clock(clock),
		.reset(reset),
		.addr_in(alu_out),
		.re_in(datamem_read_enable),
		.we_in(datamem_write_enable),
		.writedata_in(reg_read_data2), 
		.readdata_out(datamem_read_data_out), //where data comes out
		.size_in(2'b11), //change this to depend on the store instructions
		.serial_in(serial_in),
		.serial_ready_in(serial_ready_in),
		.serial_valid_in(serial_valid_in),
		.serial_out(serial_out),
		.serial_rden_out(serial_rden_out),
		.serial_wren_out(serial_wren_out)
	);
    
    
	// adder to add 4 to program counter
	adder pc_adder
	(
		.left_in(`ADDER_CONST),
		.right_in(pc_out),
		.sum_out(pc_plus4)
	);
							
	// adder to add branch offset to PC+4 for branching
	adder branch_adder
	(
		.left_in(pc_plus4),
		.right_in(branch_amount),
		.sum_out(branch_address)
	);
	
	// Program Counter
	program_counter pc
	(
		.clock(clock),
		.reset(reset),
		.in(pc_in),
		.out(pc_out)
	);
										
	
								
	// 5-bit MUX which determines which register to write to
	mux #(.W(5)) mux_to_write_reg
	(
		.select_in(is_rtype),
		._0_in(inst_out[20:16]),
		._1_in(inst_out[15:11]),
		.out(rs_or_rt)
	);
							
	// Sign Extender
	sign_extend extension
	(
		.in(inst_out[15:0]),
		.out(sign_extension_out)
	);	

	// Register File
	reg_file registers
	(
		.clock(clock),
		.reset(reset),
		.read_reg1_in(inst_out[25:21]),
		.read_reg2_in(inst_out[20:16]),
		.write_en_in(reg_write_enable),
		.write_reg_in(reg_write_addr),
		.write_data_in(write_data_wire),
		.read_data1_out(reg_read_data1),
		.read_data2_out(reg_read_data2)
	);
	
	// 32-bit MUX to determine if a register or an immediate value should go to the ALU
	mux mux_to_alu
	(
		.select_in(select_mux_to_alu),
		._0_in(reg_read_data2),
		._1_in(to_alu_mux),
		.out(mux_to_alu_out)
	);
	
	// ALU
	alu alu
	(
		.Func_in(alu_func),
		.A_in(reg_read_data1),
		.B_in(mux_to_alu_out),
		.O_out(alu_out),
		.Branch_out(is_branch),
		.Jump_out(is_jump)
	);
	
	
	
	// 32-bit mux determines if result from ALU or data read from stack should be written in destination register
	mux mux_nonlink_write_data
	(
		.select_in(select_mux_to_write_data),
		._1_in(load_data), //changed
		._0_in(alu_out),
		.out(nonlink_write_data)
	);

	// 32-bit MUX used how the new PC is calculated depending on branches and jumpes
	mux4to1 mux_to_pc
	(
		.select_in({is_jump,is_branch^is_jump_reg}), // TODO: for control path
		.data0_in(pc_plus4),
		.data1_in(branch_address),
		.data2_in({pc_plus4[31:28],jump_shifted_addr[27:0]}),
		.data3_in(alu_out),
		.data_out(pc_in)
	);
		
	// left shifter to shift 16-bit branch immediate value 
	leftshift2 #(.W(16)) branch_shifter
	(
		.in(sign_extension_out),
		.out(branch_amount)
	);

	// left shifter to shift 26-bit jump immediate value
	leftshift2 #(.W(26)) jump_shifter
	(
		.in(inst_out[25:0]),
		.out(jump_shifted_addr)
	);
	
	// MUX to determine if destination register will be return register due to a link
	mux #(.W(5)) mux_link_reg
	(
		.select_in(is_linking),
		._0_in(rs_or_rt),
		._1_in(5'd31),
		.out(reg_write_addr)
	);
	
	
	adder link_adder
	(
		.left_in(`ADDER_CONST),
		.right_in(pc_plus4),
		.sum_out(pc_plus8)
	);
	
	// MUX to determine if data to be written to register will be PC+8 due to a link
	mux mux_is_linking_load
	(
		.select_in(is_linking),
		._0_in(nonlink_write_data),
		._1_in(pc_plus8),
		.out(write_data_wire)
	);
	
	
	
	
	
	
	//pat added
	//load byte, hw, word mux


	//chooses between 8 bits in 32 bit word
	mux4to1#(.W(8)) load8s
	(
		.select_in(alu_out[1:0]),
		.data0_in(datamem_read_data_out[7:0]),//00
		.data1_in(datamem_read_data_out[15:8]), //01
		.data2_in(datamem_read_data_out[23:16]), //10
		.data3_in(datamem_read_data_out[31:24]), //11
		.data_out(load8_out)
	);

	//sign extends 8 bit loads
	sign_extend#(.W(8)) sign8
	(
		.in(load8_out),
		.out(sign8out)
	);

	//selects from signed or unsigned 8 bits
	mux signed8
	(
		.select_in(load_signed),
		._0_in( { {24{1'b0}},load8_out} ),
		._1_in(sign8out),
		.out(load8)
	);
	wire [15:0] load16_out;
	//selects upper or lower 16 load
	mux#(.W(16)) load16s
	(
		.select_in(alu_out[1]),
		._0_in(datamem_read_data_out[15:0]),//first 15
		._1_in(datamem_read_data_out[31:16]),//second 16
		.out(load16_out)
	);
	//sign extends 16 bit loads
	sign_extend#(.W(16)) sign16
	(
		.in(load16_out),
		.out(sign16out)
	);
	//selects from signed or unsigned 16 bit loads
	mux signed16
	(
		.select_in(load_signed),
		._0_in( {{16{1'b0}} ,load16_out} ),
		._1_in(sign16out),
		.out(load16)
	);
	wire [1:0] word_size2;
	//final load data
	mux4to1 load_size
	(
		.select_in(word_size2),
		.data0_in(load8), //8bit
		.data1_in(load16), //16 bits
		.data2_in(0), //unused
		.data3_in(datamem_read_data_out), //32 bit
		.data_out(load_data)
	);

	
	
	//unsigned signed immedites
	


	mux mux_lui
	(
		.select_in(is_lui),
		._0_in( {{16{1'b0}}, inst_out[15:0]}),
		._1_in(   {inst_out[15:0], {16{1'b0}}}   ),
		.out(to_signed_mux)
	);
	
	mux mux_signedi
	(
		.select_in(is_signed),
		._0_in(to_signed_mux),
		._1_in(sign_extension_out),
		.out(to_alu_mux)
	);
	
	
	// controller
	control controller
	(
		.rt(inst_out[20:16]),
		.opcode_in(inst_out[31:26]),
		.funct_in(inst_out[5:0]),
		.is_r_type(is_rtype),
		.uses_immediate_in_alu(select_mux_to_alu),
		.reads_memory(select_mux_to_write_data),
		.reg_write_enabled(reg_write_enable),
		.datamem_read_enable(datamem_read_enable),
		.datamem_write_enable(datamem_write_enable),
		.alu_function(alu_func),
		//pat's new connections
		.word_size(word_size),
		.load_signed(load_signed),
		.is_lui(is_lui),
		.is_signed(is_signed),
		.is_jump_reg(is_jump_reg),
		.is_link(is_linking),
		.word_size2(word_size2)
	);
endmodule
