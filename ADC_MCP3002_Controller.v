module ADC_MCP3002_Controller(clk,ADC_Dout,ADC_Din,ADC_CS,set_out,data_sent);
output reg ADC_Din; // this connects to the Din pin of the ADC
input ADC_Dout; // this connects to the Dout pin of the ADC
output reg ADC_CS; // chip select;
output reg [9:0]set_out;
output reg data_sent;
input clk;

parameter SGL_DIFF = 1'b1; // 0 for psuedo differential, 1 for single ended
parameter ODD_SIGN = 1'b0; // 0 for CH0 , 1 for CH1 (selects which chanel to use)
parameter MSB = 1'b1; // 0 for MSBL, 1 for MSBF (most significant bit first or last)

reg [5:0]count; // counts to 16
reg [15:0] options_bits = 16'b0000000000010110; // initiate 
reg [15:0] cs_bits = 16'b0000000000000001; // set cs to 1 at start and 0 for rest

reg [9:0] store;
//initial begin
// options_bits[0] = 1'b0;
// options_bits[1] = 1'b1;
// options_bits[2] = SGL_DIFF;
// options_bits[3] = ODD_SIGN;
// options_bits[4] = MSB;
//end

always@(negedge clk) begin // operate ADC_Din on neg edge
	ADC_CS <= cs_bits[count];
	ADC_Din <= options_bits[count];
	count <= count + 1'b1;
end

always@(posedge clk) begin
	data_sent = 1'b0;
	if(count > 4) begin // count > 4
		store[count-5] <= ADC_Dout;
	end
	
	if(count == 0) begin
	   data_sent = 1'b1;
		set_out <= store;
	end

end

endmodule