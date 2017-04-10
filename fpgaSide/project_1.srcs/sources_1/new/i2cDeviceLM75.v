`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2017 12:50:15 PM
// Design Name: 
// Module Name: i2cDeviceLM75
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


module i2cDeviceLM75(
    input systemClock,
    input reset,
    input rwBit,
    input [3:0] byteCounter,
    input [7:0] dataInput,
    output reg [7:0] dataOutput,
    input [8:0] temperatureData);

	localparam REG_TEMP = 2'b00;
	localparam REG_CONF = 2'b01;
	localparam REG_THYST = 2'b10;
	localparam REG_TOS = 2'b11;

	reg [1:0] registerPointer;
	reg [7:0] configurationReg;
	reg [8:0] HystTemperature;
	reg [8:0] OsTemperature;

	always @(*) begin // TODO: rethink all of this
		if(reset) begin
			registerPointer <= 2'b00;
			configurationReg <= 2'b00;
			HystTemperature <= 9'h96; // equivalent to +75*C
			OsTemperature <= 9'hA0; // equivalent to +80*C
		end else begin
			if(rwBit) begin // read
				case (registerPointer) 
					REG_TEMP: dataOutput <= (byteCounter==4'h1)? temperatureData[8:1] : {temperatureData[0], 7'b0 };
					REG_CONF: dataOutput <= configurationReg;
					REG_THYST: dataOutput <= (byteCounter==4'h1)? HystTemperature[8:1] : {HystTemperature[0], 7'b0 };
					REG_TOS: dataOutput <= (byteCounter==4'h1)? OsTemperature[8:1] : {OsTemperature[0], 7'b0 };
					default : dataOutput <= (byteCounter==4'h1)? temperatureData[8:1] : {temperatureData[0], 7'b0 };
				endcase
			end else begin
				if(byteCounter==4'h1) begin
					registerPointer <= dataInput[1:0];
				end
			end
		end
	end
endmodule
