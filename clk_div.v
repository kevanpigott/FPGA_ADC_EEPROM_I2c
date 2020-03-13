module clk_div(in_clk, out_clk);
input in_clk;
output reg out_clk;
parameter count_max = 6'd10;
reg [6:0]count;//2:0
initial begin
	out_clk = 1'b1;
end

always@(posedge in_clk) begin
	if(count == 0) begin
		out_clk <= ~out_clk;
		count <= 0;
	end 
		count <= count+1'b1;
	
end
endmodule