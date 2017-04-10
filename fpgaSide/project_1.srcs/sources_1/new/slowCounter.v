`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2017 04:59:54 PM
// Design Name: 
// Module Name: slowCounter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module slowCounter(
    input clock,  //4.688 Mhz input
    input reset,
    output [7:0] adressGenerated
   	);
	
	reg [30:0] internalValue; 

	always @(posedge clock) begin 
		if(reset) begin
			internalValue <= 21'b0;
		end else begin
			internalValue <= internalValue + 1'b1;
		end
	end
	assign adressGenerated = internalValue[30:23];
endmodule
