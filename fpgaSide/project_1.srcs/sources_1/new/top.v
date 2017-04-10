`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2017 10:48:18 PM
// Design Name: 
// Module Name: top
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


module top(
    input systemClock,
    input scl,
    inout sda,
    output [7:0] debug
    );
	
	wire sdaIn, sdaOut;
	assign sdaIn = sda;
	assign sda = (sdaOut? 1'bz : 1'b0);

	wire [6:0] receivedAddress;
	wire rwBit;
	wire thisIsMe;
	assign thisIsMe = (receivedAddress == 7'h4C);

	wire stateHint;

	wire [3:0] byteCounter;
	wire [7:0] handData;

	wire [7:0] dataReceived;

    i2cDeviceLM75 device75(
    .systemClock(systemClock),
    .reset(1'b0),
    // to the I2C Core
    .rwBit(rwBit),
    .byteCounter(byteCounter),
    .dataInput(dataReceived),
    .dataOutput(handData),
    // actual temperature Data
    .temperatureData(tempData)
    );
	
	i2Core insta(
    	.systemClock(systemClock),
    	.reset(1'b0),
    	// I2C Pins
    	.sdaIn(sdaIn),
    	.sdaOut(sdaOut),
    	.sclIn(scl),
    	// to the I2C Device
    	.receivedAddress(receivedAddress),
    	.rwBit(rwBit),
    	.thisIsMe(thisIsMe),
    	.byteCounter(byteCounter),
   		.dataToSend(handData),
   		.dataReceived(dataReceived),
   		// debug
   		.stateHint(stateHint)
    );

	wire slowClock; // for the slow counter
	wire [7:0] memAddress;
	wire [8:0] tempData;

	clk_wiz_0 clockDivider (
		.clk_in1(systemClock),
    	.clk_out1(slowClock)
    );

    slowCounter slowCounter(
    	.clock(slowClock),  //4.688 Mhz input
   		.reset(1'b0),
    	.adressGenerated(memAddress)
   	);

    blk_mem_gen_0 temperatureDataMemory (
  		.clka(systemClock),    // input wire clka
  		.addra(memAddress),  // address
  		.douta(tempData) // temperature data output
  	);
    assign debug[0] = scl;
    assign debug[2] = sda;
    assign debug[3] = thisIsMe;
    assign debug[4] = memAddress[0];
    assign debug[5] = handData[1];
    assign debug[7] = handData[2];
endmodule
