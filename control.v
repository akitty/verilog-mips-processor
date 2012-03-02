module control#(parameter W = 6)
(
	input [W-1:0] opcode_in,
	input [W-1:0] funct_in,
	input [4:0] rt,
	output reg is_r_type,
	output reg uses_immediate_in_alu,
	output reg reads_memory,
	output reg reg_write_enabled,
	output reg datamem_read_enable,
	output reg datamem_write_enable,
	output reg is_link,
	output reg[W-1:0] alu_function,
	//pat added
	output reg [1:0] word_size,
	output reg load_signed,
	output reg is_lui,
	output reg is_signed,
	output reg is_jump_reg,
	output reg [1:0] word_size2
);

	// Constants
	localparam ALU_DONT_CARE = 6'b000000;
	localparam FLAG_DONT_CARE = 1'b0;
	localparam R_TYPE = 6'd0;
	localparam J_TYPE = 5'b00001;
	localparam ADDI = 6'b001000;
	localparam ADD_FUNC = 6'b100000;
	localparam LW = 6'b100011;
	localparam SW = 6'b101011;
	
	//funcs
	localparam FBEQ = 6'b111100;
	localparam FBNE = 6'b111101;
	localparam FBLTZ= 6'b111000; 
	localparam FBGEZ= 6'b111001;
	localparam FBGTZ= 6'b111111;
	localparam FBLEZ = 6'b111110;
	localparam FJ= 6'b111010;
	localparam FANDI= 6'b100100;
	localparam FORI= 6'b100101;
	localparam FXORI= 6'b100110;
	localparam FLUI= 6'b100101;
	localparam FSLT= 6'b101110;
	localparam FSLTU= 6'b101111;
	//pat added
	localparam JARL =6'b001001;
	localparam LB = 6'b100000;
	localparam LBU= 6'b100100;
	localparam LH = 6'b100001;
	localparam LHU =6'b100101;
	localparam SB = 6'b101000;
	localparam SH = 6'b101001;
	localparam BEQ = 6'b00100;
	localparam BNE = 6'b000101;
	localparam BLTZ = 6'b000001;
	localparam BLTZ_RT= 5'b00000;
	
	localparam BGEZ= 6'b000001;
	localparam BGEZ_RT=5'b00001;
	
	localparam BLEZ= 6'b000110;
	localparam BLEZ_RT=5'b00000;

	localparam BGTZ= 6'b000111;
	localparam BGTZ_RT=5'b00000;
	localparam JR= 6'b001000;
	localparam JALR= 6'b001001;
	localparam ADDU= 6'b100001;
	localparam ADDIU= 6'b001001;
	localparam SUBU= 6'b100011;
	localparam ANDI= 6'b001100;
	localparam ORI= 6'b001101;
	localparam XORI= 6'b001110;
	localparam LUI= 6'b001111;
	localparam SLT= 6'b101010;
	localparam SLTU= 6'b101011;
	
	always @(*)
		begin
			//defaults
			reg_write_enabled = FLAG_DONT_CARE;
			alu_function = ALU_DONT_CARE;
			datamem_read_enable = FLAG_DONT_CARE;
			datamem_write_enable = FLAG_DONT_CARE;
			is_r_type = FLAG_DONT_CARE;
			uses_immediate_in_alu = FLAG_DONT_CARE;
			reads_memory = FLAG_DONT_CARE;
			is_link = FLAG_DONT_CARE;
			//pat added
			load_signed=1'b0;
			word_size=2'b11;
			is_signed=1;
			is_lui=0;
			is_jump_reg=0;
			word_size2=2'b11;
			if(opcode_in == R_TYPE)
				case(funct_in)
				JR:
					begin
                    is_jump_reg =1;
					is_link=0;
					alu_function=FJ;
					end
				JARL:
					begin
                    is_jump_reg=1;
					is_link=1;
					alu_function=FJ;
					reg_write_enabled = 1;
					end
				
				
				default:
					begin
					reg_write_enabled = 1;
					alu_function = funct_in;
					datamem_read_enable = 0;
					datamem_write_enable = 0;
					is_r_type = 1;
					uses_immediate_in_alu = 0;
					reads_memory = 0;
					end
			
				endcase
			
			else if(opcode_in[5:1] == J_TYPE)
				begin
					case(opcode_in[0])	
						1'b0:	
							begin// jump
							is_link = 0;
							reg_write_enabled = 1;
							alu_function = FJ;
							datamem_read_enable = 0;
							datamem_write_enable = 0;
							is_r_type = 1;
							uses_immediate_in_alu = 0;
							reads_memory = 0;
							end
						1'b1: // jump and link
							begin
							is_link = 1;
							reg_write_enabled = 1;
							alu_function = FJ;
							datamem_read_enable = 0;
							datamem_write_enable = 0;
							is_r_type = 1;
							uses_immediate_in_alu = 0;
							reads_memory = 0;
						
							end
					endcase
					
				end
			
			else
				begin
					case(opcode_in)
						ADDI:
							begin
							reg_write_enabled = 1;
							alu_function = ADD_FUNC;
							datamem_read_enable = 0;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							reads_memory = 0;
                            
							end
						LW:
							begin
							reg_write_enabled = 1;
							alu_function = ADD_FUNC;
							datamem_read_enable = 1;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							reads_memory = 1;
							word_size=2'b11;
							end
						SW:
							begin
							reg_write_enabled = 0;
							alu_function = ADD_FUNC;
							datamem_read_enable = 0;
							datamem_write_enable = 1;
							is_r_type = 1'bx;
							uses_immediate_in_alu = 1;
							reads_memory = 1'bx;
							word_size=2'b11;
							end
						
						LB:
							begin
							reg_write_enabled = 1;
							alu_function = ADD_FUNC;
							datamem_read_enable = 1;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							load_signed=1;
							reads_memory=1;
							word_size=2'b11;
							word_size2=2'b0;
							end
						LBU:
							begin
							reg_write_enabled = 1;
							alu_function = ADD_FUNC;
							datamem_read_enable = 1;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							load_signed=0;
							reads_memory=1;
							word_size=2'b11;
							word_size2=2'b0;
							end
						LH:
							begin
							reg_write_enabled = 1;
							alu_function = ADD_FUNC;
							datamem_read_enable = 1;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							load_signed=1;
							reads_memory=1;
							word_size=2'b11;
							word_size2=2'b01;
							end
						LHU:
							begin
							reg_write_enabled = 1;
							alu_function = ADD_FUNC;
							datamem_read_enable = 1;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							load_signed=0;
							reads_memory=1;
							word_size=2'b11;
							word_size2=2'b01;
							end
						SB:
							begin
							reg_write_enabled = 0;
							alu_function = ADD_FUNC;
							datamem_read_enable = 0;
							datamem_write_enable = 1;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							word_size= 2'b00; //from asynch mem
							reads_memory=0;
							end
						SH:
							begin
							reg_write_enabled = 0;
							alu_function = ADD_FUNC;
							datamem_read_enable = 0;
							datamem_write_enable = 1;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							word_size=2'b01; //from asynch mem
							reads_memory=0;
							end	
							
							
						ADDIU:
							begin
							reg_write_enabled = 1;
							alu_function = ADD_FUNC;
							datamem_read_enable = 0;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
			
							reads_memory=0;
						
							end
						ANDI:
							begin
							reg_write_enabled = 1;
							alu_function = FANDI;
							datamem_read_enable = 0;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							
							reads_memory=0;
							is_signed=0;
							end
						ORI:
							begin
							reg_write_enabled = 1;
							alu_function = FORI;
							datamem_read_enable = 0;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							reads_memory=0;
							is_signed=0;
							end
						XORI:
							begin
							reg_write_enabled = 1;
							alu_function = FXORI;
							datamem_read_enable = 0;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							reads_memory=0;
							is_signed=0;
							end
						LUI:
							begin
							reg_write_enabled = 1;
							alu_function = FXORI;
							datamem_read_enable = 0;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 1;
							reads_memory=0;
							is_signed=0;
							is_lui=1;
							end
						BEQ:
							begin
							reg_write_enabled = 0;
							alu_function = FBEQ;
							datamem_read_enable = 0;
							datamem_write_enable = 0;
							is_r_type = 0;
							uses_immediate_in_alu = 0;
							reads_memory=0;
							is_signed=0;
							end
						BNE:
							begin
							alu_function = FBNE;
							end
						BLTZ:
						begin
							if(rt==5'b00000)
								begin
								alu_function = FBLTZ;
								end
							else if(rt==5'b00001)
								begin
									alu_function =FBGEZ;
								end
						end
						BGTZ:
						begin
							if(rt==5'b00000)
								alu_function=FBGTZ;
						end
					
						BLEZ:
						begin
							if(rt==5'b00000)
								alu_function=FBLEZ;
						end
						

						endcase
				end
		end
endmodule


