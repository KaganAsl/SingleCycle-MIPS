module alu_cont(alu_op1, alu_op0, f3, f2, f1, f0, out);
input alu_op1, alu_op0, f3, f2, f1, f0;
output reg [2:0] out;
always @(alu_op1 or alu_op0 or f3 or f2 or f1 or f0)
begin
	if(~(alu_op1 | alu_op0))
	out = 3'b010;
	if(alu_op0)
	out = 3'b110;
	if(alu_op1)
	begin
		if(~(f3 | f2 | f1 | f0))
		out = 3'b010;
		if(f3 & f2 & ~f1 & f0)
		out = 3'b110;
		if(f3 & ~f2 & f1 & f0)
		out = 3'b000;
		if(~f3 & f2 & ~f1 & f0)
		out = 3'b001;
		if(f3 & ~f2 & f1 & ~f0)
		out = 3'b111;
	end
end
endmodule
