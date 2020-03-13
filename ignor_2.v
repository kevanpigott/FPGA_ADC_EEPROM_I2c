module ignore_2 (in, out);
input  [9:0] in;
output reg[0:7] out;

always@(*) begin
	out = in[9:2];
end
endmodule