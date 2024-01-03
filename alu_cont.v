module alu_cont(alu_op1, alu_op0, f_bits, out);
input alu_op1, alu_op0;
input [5:0] f_bits;
output reg [3:0] out;
always @(alu_op1 or alu_op0 or f_bits)
begin
	if(~(alu_op1 | alu_op0))
	out = 4'b0010;
	if(alu_op0)
	out = 4'b0110;
	if(alu_op1)
	begin
		if(f_bits[5] & ~(|f_bits[4:1]) & f_bits[0])
		out = 4'b0011;
		if(f_bits[5] & ~(|f_bits[4:0]))
		out = 4'b0010;
		if(f_bits[5] & ~(|f_bits[4:2]) & f_bits[1] & ~f_bits[0])
		out = 4'b0110;
		if(f_bits[5] & ~(|f_bits[4:3]) & f_bits[2] & ~(|f_bits[1:0]))
		out = 4'b0000;
		if(f_bits[5] & ~(|f_bits[4:3]) & f_bits[2] & ~f_bits[1] & f_bits[0])
		out = 4'b0001;
		if(f_bits[5] & ~f_bits[4] & f_bits[3] & ~f_bits[2] & f_bits[1] & ~f_bits[0])
		out = 4'b0111;
		if(~(|f_bits[5:4]) & f_bits[3] & ~(|f_bits[2:0]))
		out = 4'b1000;
	end
end
endmodule
