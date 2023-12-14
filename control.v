module control(in, reg_dest, branch, mem_read, mem_to_reg,
alu_op1, alu_op0, mem_write, alu_src, reg_write);
input [5:0] in;
output reg_dest, branch, mem_read, mem_to_reg,
alu_op1, alu_op0, mem_write, alu_src, reg_write;
wire r_format, lw, sw, beq;
assign r_format = ~(| in);
assign lw = in[5] & (~in[4]) & (~in[3]) & (~in[2]) & in[1] & in[0];
assign sw = in[5] & (~in[4]) & in[3] & (~in[2]) & in[1] & in[0];
assign lw = (~in[5]) & (~in[4]) & (~in[3]) & in[2] & (~in[1]) & (~in[0]);
assign reg_dest = r_format;
assign branch = beq;
assign mem_read = lw;
assign mem_to_reg = lw;
assign alu_op1 = r_format;
assign alu_op0 = beq;
assign mem_write = sw;
assign alu_src = lw | sw;
assign reg_write = r_format | lw;
endmodule
