module task_controller(clk, com, en, done, SDA, SCL);

input clk, en;
input [1:0]com;

output reg done, SDA, SCL;

//reg [5:0] SCL_bits;
reg [3:0] SDA_bits;
reg [1:0] com_store;
parameter RISE = 4'b1100, FALL = 4'b0011, ONE = 4'b1111, ZERO = 4'b0000;



reg [2:0] CS;
reg [2:0] NS;

always@(posedge clk) begin
		CS <= NS;
		
		case(CS)
			3'd0:
				begin
					
					if(en == 1'b1)begin
						com_store <= com;
						NS <= 3'd1;
					end
				end
			3'd1:
				begin
					if(com_store == 2'b00) begin
						SDA_bits <= ZERO;
					end
					if(com_store == 2'b11) begin
						SDA_bits <= ONE;
					end
					if(com_store == 2'b10) begin
						SDA_bits <= FALL;
					end
					if(com_store == 2'b01) begin
						SDA_bits <= RISE;
					end
					
					NS <= 3'd2;
				end
			3'd2://set SDA start
				begin
					SDA <= SDA_bits[0];
					NS <= 3'd3;
				end
			3'd3://start SCL read
				begin
					SCL <= 1'b1;
					NS <= 3'd4;
				end
			3'd4:
				begin
					SDA <= SDA_bits[1];
					NS <= 3'd5;
				end
			3'd5:
				begin
					SDA <= SDA_bits[2];
					NS <= 3'd6;
				end
			3'd6:
				begin
					SDA <= SDA_bits[3];
					NS <= 3'd7;
				end
			3'd7:
				begin
					SCL <= 1'b0;
					done <= 1'b1;
					
					if(en == 1'b0) begin
						SDA <= 1'b0;
						done <= 1'b0;
						NS <= 3'd0;
					end
				end
		endcase
end

endmodule