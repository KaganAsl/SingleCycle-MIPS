module mult2_to_1_5bit(i0, i1, s, out);
input [4:0] i0, i1;
input s;
output [4:0] out;
assign out = s ? i1:i0;
endmodule
