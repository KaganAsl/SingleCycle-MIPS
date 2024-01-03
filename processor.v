module processor;
/* Variables */
// Clock
reg clk;

// Program counter
reg [31:0] pc;

// Data and instruction memory
reg [7:0] data_mem[0:127], inst_mem[0:63];
wire [31:0] read_data;

// Instructions
wire [31:0] instruction;
wire [5:0] inst_31_to_26;
wire [4:0] inst_25_to_21, inst_20_to_16, inst_15_to_11;
wire [5:0] inst_5_to_0;
wire [15:0] inst_15_to_0;
wire [25:0] inst_25_to_0;

// Register file, read data 1 and read data 2
reg [31:0] register_file[0:31];
wire [31:0] data_1, data_2;

// Mux outs
wire [4:0] mux_reg_dest, mux_jal_address_out;
wire [31:0] mux_pc_out, mux_alu_src, mux_to_reg, mux_jump_out, mux_jr_out, mux_jal_data_out;
wire pc_mux_select, branch_eq_select, branch_not_eq_select;

// Alu
wire [3:0] alu_cont_out;
wire [31:0] alu_result;
wire z;

// Control
wire reg_dest, jump, j_and_link, j_reg, branch_eq, branch_not_eq, mem_read,
mem_to_reg, alu_op1, alu_op0, mem_write, alu_src, reg_write;

// Adder
wire [31:0] pc_plus_4_out, pc_plus_branch_out;

// Shift
wire [31:0] shift_out;

// Sign extend
wire [31:0] sign_extend_out;

// Shift and extend
wire [27:0] shif_and_extend_out;

// Jump address
wire [31:0] jump_address;

/* Initial */
initial
begin
	pc=0;
	#620 $finish;
end

initial
begin
	clk=0;
forever #20  clk=~clk;
end

initial
begin
	$readmemh("Data/instruction_memory.dat",inst_mem);
	$readmemh("Data/data_memory.dat",data_mem);
	$readmemh("Data/registers.dat",register_file);
end


/* Main */
// pc + 4
adder add1(pc, 32'h4, pc_plus_4_out);

// Instruction
assign instruction = {inst_mem[pc[5:0]], inst_mem[pc[5:0] + 1], inst_mem[pc[5:0] + 2], inst_mem[pc[5:0] + 3]};
assign inst_31_to_26 = instruction[31:26];
assign inst_25_to_21 = instruction[25:21];
assign inst_20_to_16 = instruction[20:16];
assign inst_15_to_11 = instruction[15:11];
assign inst_5_to_0 = instruction[5:0];
assign inst_15_to_0 = instruction[15:0];
assign inst_25_to_0 = instruction[25:0];

// Control
control cont(inst_31_to_26, inst_5_to_0, reg_dest, jump, j_and_link, j_reg, branch_eq, branch_not_eq, mem_read,
mem_to_reg, alu_op1, alu_op0, mem_write, alu_src, reg_write);

// Registers
assign data_1 = register_file[inst_25_to_21];
assign data_2 = register_file[inst_20_to_16];
mult2_to_1_5bit mux1(inst_20_to_16, inst_15_to_11, reg_dest, mux_reg_dest);

// Sign extend
sign_extend s_ext(inst_15_to_0, sign_extend_out);

// Shift
shift shift_extended(sign_extend_out, shift_out);

// Shift and extend
shift_and_extend s_and_extend(inst_25_to_0, shif_and_extend_out);

// Jump address
assign jump_address = {pc_plus_4_out[31:28], shif_and_extend_out};

// pc adder with branch
adder add2(pc_plus_4_out, shift_out, pc_plus_branch_out);

// pc select
assign branch_eq_select = branch_eq & z;
assign branch_not_eq_select = branch_not_eq & ~z;
assign pc_mux_select = branch_eq_select | branch_not_eq_select;
mult2_to_1_32bit mux2(pc_plus_4_out, pc_plus_branch_out, pc_mux_select, mux_pc_out);

// pc jump select
mult2_to_1_32bit mux3(mux_pc_out, jump_address, jump, mux_jump_out);

// pc jr select
mult2_to_1_32bit mux4(mux_jump_out, data_1, j_reg, mux_jr_out);

// Alu control
alu_cont alu_control(alu_op1, alu_op0, inst_5_to_0, alu_cont_out);

// Alu
mult2_to_1_32bit mux5(data_2, sign_extend_out, alu_src, mux_alu_src);
alu_32 alu(data_1, mux_alu_src, alu_cont_out, alu_result, z);

// Data memory
assign read_data = {data_mem[alu_result[6:0]], data_mem[alu_result[6:0] + 1], data_mem[alu_result[6:0] + 2], data_mem[alu_result[6:0] + 3]};
mult2_to_1_32bit mux6(alu_result, read_data, mem_to_reg, mux_to_reg);

// Jal data
mult2_to_1_32bit mux7(mux_to_reg, pc_plus_4_out, j_and_link, mux_jal_data_out);

// Jal address
mult2_to_1_5bit mux8(mux_reg_dest, 5'b11111, j_and_link, mux_jal_address_out);

// Register write
always @(posedge clk)
begin
	register_file[mux_jal_address_out] = reg_write ? mux_jal_data_out:register_file[mux_jal_address_out];
end

// Memory write
always @(posedge clk)
begin
	if(mem_write)
	begin
		data_mem[alu_result[4:0] + 3] <= data_2[7:0];
		data_mem[alu_result[4:0] + 2] <= data_2[15:8];
		data_mem[alu_result[4:0] + 1] <= data_2[23:16];
		data_mem[alu_result[4:0]] <= data_2[31:24];
	end
end

// Load pc
always @(posedge clk)
pc = mux_jr_out;
endmodule
