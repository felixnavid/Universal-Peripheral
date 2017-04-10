`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2017 12:26:14 AM
// Design Name: 
// Module Name: i2cDevice
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


module i2cDevice( // this maybe should be a Bosch BMP280
	// system
    input systemClock,
    input reset,
    // data interface
    input rwBit,
    input [3:0] byteCounter,
    input [7:0] dataInput,
    output reg [7:0] dataOutput,
    // actual sensor data
    input [19:0] temperatureData
    );

	reg [7:0] registerPointer;

	localparam REG_ID = 8'hD0; // ic's id (should be 0x60 in case of BMP280)
	localparam REG_PRESS_MSB = 8'hF7; // higher section of pressure
	localparam REG_PRESS_LSB = 8'hF8; // mid section of pressure
	localparam REG_PRESS_XLSB = 8'hF9; // lower section of pressure
	localparam REG_TEMP_MSB = 8'hFA; // higher section of temperature
	localparam REG_TEMP_LSB = 8'hFB; // mid section of temperature
	localparam REG_TEMP_XLSB = 8'hFC; // lower section of temperature
	localparam REG_HUM_MSB = 8'hFD; // higher section of hummidity
	localparam REG_HUM_LSB = 8'hFE; // lower section of humidity

	always @(*) begin
		if(reset) begin
			registerPointer <= 8'h0;
			dataOutput <= 8'h0;
		end else begin
			if(rwBit) begin // reading
				case (registerPointer)
						  REG_ID :	dataOutput <= 8'h60;
					REG_PRESS_MSB:  dataOutput <= temperatureData[19:12]; // should be pressure data, not temperature
					REG_PRESS_LSB:	dataOutput <= temperatureData[11:4];
				   REG_PRESS_XLSB:	dataOutput <= {temperatureData[3:0], 4'h0 };
					 REG_TEMP_MSB:	dataOutput <= temperatureData[19:12];
					 REG_TEMP_LSB:	dataOutput <= temperatureData[11:4];
					REG_TEMP_XLSB:	dataOutput <= {temperatureData[3:0], 4'h0 };
					  REG_HUM_MSB:  dataOutput <= temperatureData[15:8]; // should be humidity data, not temperature
					  REG_HUM_LSB:  dataOutput <= temperatureData[7:0];
						 default :  dataOutput <= 8'h0;
				endcase
			end else begin // writing
				if(byteCounter==4'h1) begin 
					registerPointer <= dataInput;
				end
			end
		end
	end
endmodule
