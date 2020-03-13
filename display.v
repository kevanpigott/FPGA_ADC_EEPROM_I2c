//Author:Kevan Pigott
module display(in,out);
input [3:0]in;
output reg [6:0]out;
//..0
//5...1
//..6
//4...2
//..3
//
//
//
//
//
//reg [6:0] out;
always@(*)
begin
	case({in})
	4'b0000:out = 7'b1000000;
	4'b0001:out = 7'b1111001;
	4'b0010:out = 7'b0100100;
	4'd3:out = 7'b0110000;
	4'd4:out = 7'b0011001;
	4'd5:out = 7'b0010010;
	4'd6:out = 7'b0000010;
	4'd7:out = 7'b1111000;
	4'd8:out = 7'b0000000;
	4'd9:out = 7'b0010000;
	4'd10:out = 7'b0001000;//A
	4'd11:out = 7'b0000011;//B
	4'd12:out = 7'b1000110;//C
	4'd13:out = 7'b0100001;//D
	4'd14:out = 7'b0000110;//E
	4'd15:out = 7'b0001110;//F
	
	default:out = 7'b1111111;
	endcase
end
endmodule