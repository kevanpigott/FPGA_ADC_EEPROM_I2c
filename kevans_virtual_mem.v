module kevans_virtual_mem(clk, write_en, read_en, data_in, is_full, data_out, mem_en);
	input clk, write_en, read_en, mem_en;
	input [7:0] data_in;
	
	output reg is_full;
	output reg [7:0] data_out;
	
	reg [7:0] virtual_mem[0:64];
	integer count;
	parameter MAX = 256; //65
	
	reg [3:0] CS;
	reg [3:0] NS;
		
	always@(negedge clk) begin
		CS <= NS;
	end
	
	always@(posedge clk) begin
		case(CS)
			4'd0:
				begin
					if(mem_en == 1'b1) begin
						NS <= 4'd1;
					end else begin
						NS <= 4'd0;
					end
				end
			4'd1:
				begin
					if(write_en == 1'b1)begin
						virtual_mem[count] <= data_in;
						count <= count +1;
						NS <= 4'd2;
					end else begin
						NS <= 4'd1;
					end
				end
			4'd2:
				begin
					if(count == MAX)begin
						count <= 0;
						NS <= 4'd3;
					end else begin
						NS <= 4'd1;
					end
				end
			4'd3:
				begin
					is_full <= 1'b1;
					if(read_en == 1'b1) begin
						NS <= 4'd4;
					end else begin
						NS <= 4'd3;
					end
				end
			4'd4:
				begin
					data_out <= virtual_mem[count];
					count <= count +1;
					NS <= 4'd5;
				end
			4'd5:
				begin
					if(count == MAX) begin
						NS <= 4'd6;
					end else begin
						NS <= 4'd3;
					end
				end
			4'd6:
				begin
					is_full <= 1'b0;
					NS <= 4'd6;
				end
		endcase
	end
endmodule