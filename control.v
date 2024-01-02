module control(in, funct, reg_dest, jump, j_and_link, j_reg, branch_eq, branc_not_eq, mem_read,
mem_to_reg, alu_op1, alu_op0, mem_write, alu_src, reg_write);

input [5:0] in;
input [5:0] funct;
output reg_dest, jump, j_and_link, j_reg, branch_eq, branc_not_eq, mem_read,
mem_to_reg, alu_op1, alu_op0, mem_write, alu_src, reg_write;

wire r_format, lw, sw, addi, j, jal, jr, beq, bne;

assign r_format = ~(| in);
assign lw = in[5] & ~in[4] & ~in[3] & ~in[2] & in[1] & in[0];
assign sw = in[5] & ~in[4] & in[3] & ~in[2] & in[1] & in[0];
assign addi = ~in[5] & ~in[4] & in[3] & ~in[2] & ~in[1] & ~in[0];
assign j = ~in[5] & ~in[4] & ~in[3] & ~in[2] & in[1] & ~in[0];
assign jal = ~in[5] & ~in[4] & ~in[3] & ~in[2] & in[1] & in[0];
assign jr = ~(|funct[5:4]) & funct[3] & ~(|funct[2:0]);
assign beq = ~in[5] & ~in[4] & ~in[3] & in[2] & ~in[1] & ~in[0];
assign beq = ~in[5] & ~in[4] & ~in[3] & in[2] & ~in[1] & in[0];

assign reg_dest = r_format;
assign jump = j | jal;
assign j_and_link = jal;
assign j_reg = jr;
assign branch_eq = beq;
assign branch_not_eq = bne;
assign mem_read = lw;
assign mem_to_reg = lw;
assign alu_op1 = r_format;
assign alu_op0 = beq | bne;
assign mem_write = sw;
assign alu_src = lw | sw | addi;
assign reg_write = r_format | lw | addi | jal;
endmodule
