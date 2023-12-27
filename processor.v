module processor;
/* Variables */
// Clock
reg clk;

// Program counter
reg [31:0] pc;

// Data and instruction memory
reg [7:0] data_mem[0:63], inst_mem[0:31];
wire [31:0] read_data;

// Instructions
wire [31:0] instruction;
wire [5:0] inst_31_to_26;
wire [4:0] inst_25_to_21, inst_20_to_16, inst_15_to_11;
wire [5:0] inst_5_to_0;
wire [15:0] inst_15_to_0;

// Register file, read data 1 and read data 2
reg [31:0] register_file[0:31];
wire [31:0] data_1, data_2;

// Mux outs
wire [4:0] mux_reg_dest;
wire [31:0] mux_pc_out, mux_alu_src, mux_to_reg;
wire pc_mux_select;

// Alu
wire [2:0] alu_cont_out;
wire [31:0] alu_result;
wire z;

// Control
wire reg_dest, branch, mem_read, mem_to_reg,
alu_op1, alu_op0, mem_write, alu_src, reg_write;

// Adder
wire [31:0] pc_plus_4_out, pc_plus_branch_out;

// Shift
wire [31:0] shift_out;

// Sign extend
wire [31:0] sign_extend_out;

/* Initial */
initial
begin
	pc=0;
	#400 $finish;
end

initial
begin
	clk=0;
forever #20  clk=~clk;
end

initial
begin
	$readmemh("D:\\Uni\\311\\Lab\\MIPS_Processor\\init.dat",inst_mem);
	$readmemh("D:\\Uni\\311\\Lab\\MIPS_Processor\\initdata.dat",data_mem);
	$readmemh("D:\\Uni\\311\\Lab\\MIPS_Processor\\initreg.dat",register_file);
end


/* Main */
// pc + 4
adder add1(pc, 32'h4, pc_plus_4_out);

// Instruction
assign instruction = {inst_mem[pc[4:0]], inst_mem[pc[4:0] + 1], inst_mem[pc[4:0] + 2], inst_mem[pc[4:0] + 3]};
assign inst_31_to_26 = instruction[31:26];
assign inst_25_to_21 = instruction[25:21];
assign inst_20_to_16 = instruction[20:16];
assign inst_15_to_11 = instruction[15:11];
assign inst_5_to_0 = instruction[5:0];
assign inst_15_to_0 = instruction[15:0];

// Control
control cont(inst_31_to_26, reg_dest, branch, mem_read, mem_to_reg,
alu_op1, alu_op0, mem_write, alu_src, reg_write);

// Registers
assign data_1 = register_file[inst_25_to_21];
assign data_2 = register_file[inst_20_to_16];
mult2_to_1_5bit mux1(inst_20_to_16, inst_15_to_11, reg_dest, mux_reg_dest);

// Sign extend
sign_extend s_ext(inst_15_to_0, sign_extend_out);

// Shift
shift shift_extended(sign_extend_out, shift_out);

// pc adder with branch
adder add2(pc_plus_4_out, shift_out, pc_plus_branch_out);

// pc select
assign pc_mux_select = branch && z;
mult2_to_1_32bit mux4(pc_plus_4_out, pc_plus_branch_out, pc_mux_select, mux_pc_out);

// Alu control
alu_cont alu_control(alu_op1, alu_op0, instruction[3], instruction[2],
instruction[1], instruction[0], alu_cont_out);

// Alu
mult2_to_1_32bit mux2(data_2, sign_extend_out, alu_src, mux_alu_src);
alu_32 alu(data_1, mux_alu_src, alu_cont_out, alu_result, z);

// Data memory
assign read_data = {data_mem[alu_result[5:0]], data_mem[alu_result[5:0] + 1], data_mem[alu_result[5:0] + 2], data_mem[alu_result[5:0] + 3]};
mult2_to_1_32bit mux3(alu_result, read_data, mem_to_reg, mux_to_reg);

// Register write
always @(posedge clk)
begin
	register_file[mux_reg_dest] = reg_write ? mux_to_reg:register_file[mux_reg_dest];
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
pc = mux_pc_out;
endmodule
