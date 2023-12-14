module alu_32(op1, op2, alu_cont, alu_result, z);
input [31:0] op1, op2;
input [2:0] alu_cont;
output reg [31:0] alu_result;
output reg z;
reg [31:0] less;
always @(op1 or op2 or alu_cont)
begin
	case(alu_cont)
	3'b010 : alu_result = op1 + op2;
	3'b110 : alu_result = op1 + 1 + ~op2;
	3'b000 : alu_result = op1 & op2;
	3'b001 : alu_result = op1 | op2;
	3'b111 : 
		begin
			less = op1 + 1 + ~op2;
			if(less[31])
			alu_result = 1;
			else
			alu_result = 0;
		end
	endcase
z = ~(| alu_result);
end

endmodule
