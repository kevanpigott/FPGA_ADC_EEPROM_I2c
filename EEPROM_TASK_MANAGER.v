module EEPROM_TASK_MANAGER (clk, com, en, data_in, TASK_MANAGER_DONE, is_done, TASK_MAN_START, state_debug);
	//maybe it would be nice to output how many bytes we have written or that the eeprom is full to an LED so we know when to stop
	input [7:0] data_in;
	input clk,is_done,TASK_MAN_START;// is done is command has been successfully executed. must raise en to 1'b1 UNTIL done = 1'b1; lowering en will turn done to 1'b0;
	output reg [1:0] com;//command sent
	output reg en, TASK_MANAGER_DONE; //enable command, this program is done
	output reg [7:0] state_debug;
	parameter START = 2'b10, END = 2'b01, ACK = 2'b00, ERROR = 4'd15; //start is falling edge, end is rising edge
	parameter MAX = 8'b11111111; //00111110
	reg [3:0] count;
	reg [0:7] data_store;
	reg [4:0] CS;
	reg [4:0] NS;
	reg [0:3] CTRL_BITS = 4'b1010;
	reg [0:3] CHIP_SEL_BITS = 4'b0000; //includes the R/W bit
	reg [0:7] adr_high = 8'b00000000;
	reg [0:7] adr_low = 8'b00000000;
	
	initial begin
		TASK_MANAGER_DONE = 1'b0;
		state_debug = 8'd0;
		en = 1'b0;
	end
	always@(negedge clk) begin
		CS <= NS;
		state_debug <= CS;
	end
	
	always@(posedge clk) begin
		case(CS)
			5'd0://get current data
				begin
					if(TASK_MAN_START == 1'b1) begin
						TASK_MANAGER_DONE <= 1'b0;
						data_store <= data_in; //save this data incase it changes mid-process who knows if ADC will be faster
						NS <= 5'd1;
					end else begin
						NS <= 5'd0;
					end
				end
			5'd1://start
				begin
					com <= START; //set the command
					en <= 1'b1;	// enable task
					if(is_done == 1'b1) begin
						en <= 1'b0;	//end task
						NS <= 5'd2;
					end else begin
						NS <= 5'd1; //wait for done signal
					end
				end
			5'd2: //send CTRL bits enable
				begin
					if(count == 4'd4) begin // if ctrl bits done, set count to zero, go to case 4
						count <= 4'd0;
						NS <= 5'd4;
					end else begin
						com[0] <= CTRL_BITS[count];
						com[1] <= CTRL_BITS[count];
						en <= 1'b1;
						NS <= 5'd3;
					end
				end
			5'd3:
				begin
					if(is_done == 1'b1) begin //wait for done or increment count, lower enable
						en <= 1'b0;
						count <= count + 1;
						NS <= 5'd2;
					end else begin
						NS <=5'd3;
					end
				end
			5'd4: // send chip select
				begin
					if(count == 4'd4) begin // if chip sel bits done, set count to zero, go to case 6
						count <= 4'd0;
						NS <= 5'd6;
					end else begin
						com[0] <= CHIP_SEL_BITS[count];
						com[1] <= CHIP_SEL_BITS[count];
						en <= 1'b1;
						NS <= 5'd5;
					end
				end
			5'd5:
				begin
					if(is_done == 1'b1) begin //wait for done or increment count, lower enable
						en <= 1'b0;
						count <= count + 1;
						NS <= 5'd4;
					end else begin
						NS <=5'd5;
					end
				end
			5'd6: // "wait" for ack by sending a zero
				begin
					com <= ACK; //set the command
					en <= 1'b1;	// enable task
					if(is_done == 1'b1) begin
						en <= 1'b0;	//end task
						NS <= 5'd7; // cur state + 1;
					end else begin
						NS <= 5'd6; //wait for done signal, cur state
					end
				end
			5'd7: //send addr high
				begin
					if(count == 4'd8) begin // if adr high bits done, set count to zero, go to case 6
						count <= 4'd0;
						NS <= 5'd9;//cur state + 2, next task
					end else begin
						com[0] <= adr_high[count];
						com[1] <= adr_high[count];
						en <= 1'b1;
						NS <= 5'd8; // cur state + 1, wait
					end
				end
			5'd8:
				begin
					if(is_done == 1'b1) begin //wait for done or increment count, lower enable
						en <= 1'b0;
						count <= count + 1;
						NS <= 5'd7; //cur state - 1
					end else begin
						NS <= 5'd8; //cur state
					end
				end
			5'd9:// ACK
				begin
					com <= ACK; //set the command
					en <= 1'b1;	// enable task
					if(is_done == 1'b1) begin
						en <= 1'b0;	//end task
						NS <= 5'd10; // cur state + 1;
					end else begin
						NS <= 5'd9; //wait for done signal, cur state
					end
				end
			5'd10: //send addr low
				begin
					if(count == 4'd8) begin // if adr low bits done, set count to zero, go to case 6
						count <= 4'd0;
						NS <= 5'd12;
					end else begin
						com[0] <= adr_low[count];
						com[1] <= adr_low[count];
						en <= 1'b1;
						NS <= 5'd11;
					end
				end
			5'd11:
				begin
					if(is_done == 1'b1) begin //wait for done or increment count, lower enable
						en <= 1'b0;
						count <= count + 1;
						NS <= 5'd10;
					end else begin
						NS <=5'd11;
					end
				end
			5'd12:// ACK
				begin
					com <= ACK; //set the command
					en <= 1'b1;	// enable task
					if(is_done == 1'b1) begin
						en <= 1'b0;	//end task
						NS <= 5'd13; // cur state + 1;
					end else begin
						NS <= 5'd12; //wait for done signal, cur state
					end
				end
			5'd13: //send data
				begin
					if(count == 4'd8) begin // if adr low bits done, set count to zero, go to case 6
						count <= 4'd0;
						NS <= 5'd15;
					end else begin
						com[0] <= data_store[count];
						com[1] <= data_store[count];
						en <= 1'b1;
						NS <= 5'd14;
					end
				end
				//com[0] <= data[bit]
				//com[1] <= dat[bit]
				//so if bit is a 1 we send 11 or 0 we send 00 this avoids an if statement
			5'd14:
				begin
					if(is_done == 1'b1) begin //wait for done or increment count, lower enable
						en <= 1'b0;
						count <= count + 1;
						NS <= 5'd13;
					end else begin
						NS <=5'd14;
					end
				end
			5'd15:// ACK
				begin
					com <= ACK; //set the command
					en <= 1'b1;	// enable task
					if(is_done == 1'b1) begin
						en <= 1'b0;	//end task
						NS <= 5'd16; // cur state + 1;
					end else begin
						NS <= 5'd15; //wait for done signal, cur state
					end
				end
			5'd16: //send end and go back to start maybe increment addresses too
				begin
					com <= END; //set the command
					en <= 1'b1;	// enable task
					if(is_done == 1'b1) begin
						en <= 1'b0;	//end task
						NS <= 5'd17;
					end else begin
						NS <= 5'd16; //wait for done signal
					end
				end
			5'd17:
				begin
					adr_low <= adr_low +1;
					TASK_MANAGER_DONE <= 1'b1;
					if(adr_low == MAX) begin
						NS <= 5'd18;
					end else begin
						NS <= 5'd0;
					end
				end
			5'd18:
				begin
					TASK_MANAGER_DONE <= 1'b1;
					NS <= 5'd18;
				end
			5'd19: //ERROR STATE
				begin
					TASK_MANAGER_DONE <= !TASK_MANAGER_DONE;
					NS <= 5'd19;
				end
			default:
				begin
					NS <= ERROR;
				end
		endcase
	end
endmodule