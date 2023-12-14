module shift(sh_in, sh_out);
input [31:0] sh_in;
output [31:0] sh_out;
assign sh_out = sh_in << 2;
endmodule
