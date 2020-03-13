//Author: Kevan Pigott
module displayEncoder(in,outTen,outOne,outHundred,outThousand);
parameter L=7;
input [L:0] in;
output reg [3:0]outThousand;
output reg [3:0]outHundred;
output reg [3:0]outTen;
output reg [3:0]outOne;

reg [L:0]store;
reg [L:0] tempStore;

always@(*)
begin
		store=in;
		tempStore=((store/10)*10);
		tempStore=store-tempStore;//ones
		outOne=tempStore;
		
		store=store/10;
		
		tempStore=((store/10)*10);
		tempStore=store-tempStore;//tens
		outTen=tempStore;
		
		store=store/10;
		
		tempStore=((store/10)*10);
		tempStore=store-tempStore;//hundreds
		outHundred=tempStore;
//		
		store=store/10;
		
		tempStore=((store/10)*10);
		tempStore=store-tempStore;//thousands
		outThousand=tempStore;
		
end
endmodule
 