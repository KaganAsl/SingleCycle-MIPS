module mult2_to_1_32bit(i0, i1, s, out);
input [31:0] i0, i1;
input s;
output [31:0] out;
assign out = s ? i1:i0;
endmodule
