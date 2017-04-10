`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2017 11:37:47 PM
// Design Name: 
// Module Name: i2Core
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



module i2Core(
	//system
    input systemClock,
    input reset,
    // i2c interface
    input sdaIn,
    output reg sdaOut,
    input sclIn,
    // address negotiation
    output reg [6:0] receivedAddress,
    output reg rwBit,
    input thisIsMe,
    // payload
   	output reg [3:0] byteCounter,
   	output reg [7:0] dataReceived,
   	input [7:0] dataToSend,
   	// debug
   	output reg stateHint
    );

	localparam stIdle = 0,
			   stShift = 1,
			   stWrite = 2,
			   stAcknowledge = 3,
			   stAcknowledge2 = 4,
			   stAcknowledgeCheck = 5,
			   stSend = 6,
			   stSendLoad = 7;

	localparam ihigh = 1'b1;
	localparam ilow = 1'b0;

	(* syn_encoding = "safe" *)
	reg [2:0] state;

	reg [7:0] shiftRegister;
	reg [7:0] shiftRegisterSend;	
	
	reg [1:0] sclCount;
	reg [11:0] clockCount;		 

	reg writing, reading, continuing;

	reg nack;
	reg [6:0] chipAddrReg;
	wire [7:0] word;

	assign word = {shiftRegister[6:0], sdaShift};

	// Detecting falling & rising edges
	reg  sdaShift, sclShifted, sda2Shift, scl2Shift;
    wire sclRising, sclFalling, sda_rising, sdaFalling;

    assign sclRising  =  sclShifted && ~scl2Shift;
    assign sclFalling = ~sclShifted &&  scl2Shift;
    assign sdaRising  =  sdaShift && ~sda2Shift;
    assign sdaFalling = ~sdaShift &&  sda2Shift;


	always @(posedge systemClock) begin 
		if(reset) begin
			state <= stIdle;
			sdaOut <= ihigh; 
			shiftRegisterSend <= 8'b0;
			stateHint <= 1'b0;
			dataReceived <= 8'h0;
		end else begin
			sclShifted <= sclIn;
			scl2Shift <= sclShifted;
			sdaShift <= sdaIn;
			sda2Shift <= sdaShift;
			if(scl2Shift && sdaFalling) begin // start 
				state <= stShift;
				sdaOut <= ihigh; 
			end else if(scl2Shift && sdaRising) begin // stop
				state <= stIdle;
				sdaOut <= ihigh;
			end else begin
				case (state)
					stIdle: begin // Waiting around
						sdaOut <= ihigh;
						shiftRegister <= 8'h01;
						receivedAddress <= 8'b0;
						rwBit <= 1'b0;
						byteCounter <= 3'b0;
						stateHint <= 1'b0;
						dataReceived <= 8'h0;
					end
					stShift: begin // shift in a byte
						sdaOut <= ihigh;
						if(sclRising) begin
							shiftRegister <= word;
							if(shiftRegister[7]) begin // finished shifting in a byte
								byteCounter <= byteCounter + 1'b1;
								if(byteCounter == 3'b0) begin // address byte (just for 7 bits)
									state <= stAcknowledge;
									receivedAddress <= word[7:1];
									rwBit <= word[0];
								end else begin 
									state <= stAcknowledge;
									dataReceived <= word;
								end
							end
						end
					end
					stAcknowledge: begin
						if(~scl2Shift) begin
							state <= stAcknowledge2;							
							if(thisIsMe) begin						
								sdaOut <= ilow;
								shiftRegisterSend <= dataToSend;
								stateHint <= ~stateHint;
							end else begin
								sdaOut <= ihigh;
							end
						end
					end
					stAcknowledge2: begin
						shiftRegister <= 8'h01;
						if(sclFalling) begin
							if(rwBit) begin // MRSW master reads, slave writes 
								state <= stSend;
								sdaOut <= shiftRegisterSend[7];
								shiftRegisterSend <= shiftRegisterSend << 1;
							end else begin // MWSR master writes, slave reads
								state <= stShift;
								sdaOut <= ihigh;
							end
						end
					end
					stSend: begin
						if(sclFalling) begin
							shiftRegister <= word;
							if(shiftRegister[7]) begin
								state <= stAcknowledgeCheck;
								sdaOut <= 1'b1;
								byteCounter <= byteCounter + 1'b1;
							end else begin
								sdaOut <= shiftRegisterSend[7];
								shiftRegisterSend <= shiftRegisterSend << 1;
							end
						end
					end
					stAcknowledgeCheck: begin
						shiftRegister <= 8'h01;
						if(sclRising) begin
							nack <= sdaShift;
							shiftRegisterSend <= dataToSend;
							stateHint <= ~stateHint;
						end
						if(sclFalling) begin
							if(nack) begin
								state <= stIdle;
								sdaOut <= 1'b1;
							end else begin
								state <= stSend;
								sdaOut <= shiftRegisterSend[7];
								shiftRegisterSend <= shiftRegisterSend << 1;
							end
						end
					end
					stSendLoad: begin
						if(sclRising) begin
							state <= stSend;
							shiftRegisterSend <= dataToSend;
							stateHint <= ~stateHint;
						end
					end
					default : state <= stIdle;
				endcase
			end
		end
	end

endmodule
