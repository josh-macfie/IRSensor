`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TTU ECE Dept
// Engineer: 
// 
// Create Date:    21:00:46 08/27/2010 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This is a working example of a bi-directional pin! The circuit layout
// is pin driving->2.2kOhm->LED->4.7KOhm->GND, +5V->470Ohm->Switch-> Driving Pin
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ir(
	 //external
	 input clk,
	 input cal_btn,
	 input rst_btn,
	 inout sig_io,
	 output finish_state,

	 //internal
	 output charge
    );
wire pulse;

reg enable;
reg [1:0] old_enable;
reg [21:0] count;
reg charge_reg;
reg still_lap;
reg [25:0] pulse_count, hold_count, cal_count;
reg [2:0] lap;
reg finish;

initial begin
enable = 1'b0;
old_enable = 2'b0;
count = 22'b0;
charge_reg = 1'b0;
pulse_count = 26'b0;
hold_count = 26'b0;
cal_count = 26'b0;
lap = 3'b0;
still_lap = 0;
finish = 1;
end

assign sig_io = (~enable) ? charge: 1'bz; //write to sig out
assign pulse = sig_io;

always @(posedge clk) begin
	if (rst_btn) begin
		lap = 3'b0;
		finish = 1'b1;
	end
	count = count + 1;
	if (&count[18:13]) begin //1.28us charge every 655us
		enable = 0;
		charge_reg = 1;
	end else begin
		charge_reg = 0;
		enable = 1;
		pulse_count = pulse_count - pulse;
	end


	if ((enable == 0) && (old_enable[1] == 1)) begin
		hold_count = pulse_count;
	end
	
	if ((enable == 0) && (old_enable[1] == 0)) begin
		pulse_count = 26'b11111111111111111111111111;
	end
	
	if (cal_btn) begin
		if ((enable == 0) && (old_enable[1] == 1)) begin
			cal_count = hold_count;
			lap = 8'b0;
		end
	end else begin
		if	((enable == 0) && (old_enable[1] == 1)) begin
			if ((hold_count > cal_count - 6) && (cal_count < hold_count + 6)) begin
				if (~still_lap) begin
					lap = lap + 1;
					still_lap = 1;
				end
			end else begin
				still_lap = 0;
			end
		end
	end
	
	if (lap == 3) begin
		finish = 1'b0;
		lap = 3'b0;
	end
	
	old_enable = old_enable << 1;
	old_enable[0] = enable;
end

assign charge = charge_reg;
assign finish_state = finish;


endmodule
