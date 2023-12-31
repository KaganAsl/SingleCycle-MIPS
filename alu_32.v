module alu_32(op1, op2, alu_cont, alu_result, z);
input [31:0] op1, op2;
input [3:0] alu_cont;
output reg [31:0] alu_result;
output reg z;
reg [31:0] less;
always @(op1 or op2 or alu_cont)
begin
	case(alu_cont)
	4'b0010 : alu_result = op1 + op2;
	4'b0110 : alu_result = op1 + 1 + ~op2;
	4'b0000 : alu_result = op1 & op2;
	4'b0001 : alu_result = op1 | op2;
	4'b1000 : alu_result = op2;
	4'b0111 : 
		begin
			less = op1 + 1 + ~op2;
			if(less[31])
			alu_result = 1;
			else
			alu_result = 0;
		end
	endcase
z = ~(|alu_result);
end

endmodule
