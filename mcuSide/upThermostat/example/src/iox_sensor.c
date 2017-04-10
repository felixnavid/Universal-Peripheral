/*
 * @brief LCD Example for LPCXpresso shiled board
 *
 * @note
 * Copyright(C) NXP Semiconductors, 2013
 * All rights reserved.
 *
 * @par
 * Software that is described herein is for illustrative purposes only
 * which provides customers with programming information regarding the
 * LPC products.  This software is supplied "AS IS" without any warranties of
 * any kind, and NXP Semiconductors and its licensor disclaim any and
 * all warranties, express or implied, including all implied warranties of
 * merchantability, fitness for a particular purpose and non-infringement of
 * intellectual property rights.  NXP Semiconductors assumes no responsibility
 * or liability for the use of the software, conveys no license or rights under any
 * patent, copyright, mask work right, or any other intellectual property rights in
 * or to any products. NXP Semiconductors reserves the right to make changes
 * in the software without notification. NXP Semiconductors also makes no
 * representation or warranty that such application will be suitable for the
 * specified use without further testing or modification.
 *
 * @par
 * Permission to use, copy, modify, and distribute this software and its
 * documentation is hereby granted, under NXP Semiconductors' and its
 * licensor's relevant copyrights in the software, without fee, provided that it
 * is used in conjunction with NXP Semiconductors microcontrollers.  This
 * copyright, permission, and disclaimer notice must appear in all copies of
 * this code.
 */

#include <stdlib.h>
#include "board.h"
#include "lcd_st7565s.h"

/* Font header file from SWIM sources*/
#include "lpc_rom8x8.h"
/*****************************************************************************
 * Private types/enumerations/variables
 ****************************************************************************/
#define SENSORS_ON_SHIELD
#if defined(SENSORS_ON_SHIELD)
	#define SHIELD_I2C I2C1
#elif defined(SENSORS_ON_FPGA)
	#define SHIELD_I2C I2C0
#else
	#warning "Channel configurations not set for the board!"
#endif

#define TEMPSEN_SLV_ADDR           0x4C    /* Temperature sensor Slave address */
#define IMUSEN_SLV_ADDR            0x68    /* Bosch IMU Sensor slave address */


static volatile uint32_t tick;

/*****************************************************************************
 * Public types/enumerations/variables
 ****************************************************************************/

/*****************************************************************************
 * Private functions
 ****************************************************************************/

static void i2c_init(void)
{
	Board_I2C_Init(SHIELD_I2C);

	/* Initialize I2C */
	Chip_I2C_Init(SHIELD_I2C);
	Chip_I2C_SetClockRate(SHIELD_I2C, 100000);
	Chip_I2C_SetMasterEventHandler(SHIELD_I2C, Chip_I2C_EventHandler);
	NVIC_EnableIRQ(SHIELD_I2C == I2C0 ? I2C0_IRQn : I2C1_IRQn);
}


static void temp_update(void) {
	uint8_t buf[32] = {0};
	int16_t val;
	int dc, df;
	I2C_XFER_T xfer = {
		TEMPSEN_SLV_ADDR,
		0, // tx buffer
		1, // tx buffer size
		0, // rx buffer
		2, // rx buffer size
	};
	xfer.txBuff = xfer.rxBuff = &buf[0];
	Chip_I2C_MasterSend(SHIELD_I2C, TEMPSEN_SLV_ADDR, buf, 1);
	Chip_I2C_MasterRead(SHIELD_I2C, TEMPSEN_SLV_ADDR, buf, 2);
	//if (xfer.status != I2C_STATUS_DONE) return ;

	val = (buf[0] << 8) | buf[1];
	val = (val >> 5);
	dc = (val * 1000) / 8;

	DEBUGOUT("VAL = %d\r\n", val);
	snprintf((char *) buf, 31, "TMP[C]: %d.00", dc / 1000);
	LCD_FillRect(3, 8, LCD_X_RES - 3, 8 + 8, 0);
	LCD_PutStrXY(3, 8, (char *)buf);
}

static void temp_update_xfer(void) {
	uint8_t buf[32] = {0};
	int16_t val;
	int dc, df;
	I2C_XFER_T xfer = {
		TEMPSEN_SLV_ADDR,
		0, // tx buffer
		1, // tx buffer size
		0, // rx buffer
		2, // rx buffer size
	};
	xfer.txBuff = xfer.rxBuff = &buf[0];
	Chip_I2C_MasterTransfer(SHIELD_I2C, &xfer);
	if (xfer.status != I2C_STATUS_DONE) return ;

	val = (buf[0] << 8) | buf[1];
	val = (val >> 5);
	dc = (val * 1000) / 8;

	DEBUGOUT("VAL = %d\r\n", val);
	//snprintf((char *) buf, 31, "TMP[C]: %d.%00d", dc / 1000, abs(dc) % 1000);
	snprintf((char *) buf, 31, "TMP[C]: %d .00", dc / 1000);
	LCD_FillRect(3, 8, LCD_X_RES - 3, 8 + 8, 0);
	LCD_PutStrXY(3, 8, (char *)buf);
}


/* Systick interrupt handler */
void SysTick_Handler(void) {
	tick ++;
}

/**
 * @brief	I2C Interrupt Handler
 * @return	None
 */
void I2C1_IRQHandler(void) {
	Chip_I2C_MasterStateHandler(I2C1);
}

/**
 * @brief	I2C0 Interrupt handler
 * @return	None
 */
void I2C0_IRQHandler(void) {
	Chip_I2C_MasterStateHandler(I2C0);
}


/**
 * @brief	main routine for lcd hello world example
 * @return	Function should not exit.
 */
int main(void) {
	SystemCoreClockUpdate();
	Board_Init();

	Board_LCD_Init(); /* Pin Mux and Clock initialization */
	LCD_Init(); /* Initialize LCD Device and Turn it ON */
	i2c_init();

	/* Set foreground as ON */
	LCD_SetFontColor(1);
	LCD_SetFontBgColor(0); /* Background is OFF */
	LCD_SetFont(&font_rom8x8); /* Use 8x8 Fonts */
	//LCD_PutStrXY(3, 4, "IOX-SENSOR DEMO"); /* Print string */


	/* Enable and setup SysTick Timer at a periodic rate */
	SysTick_Config(SystemCoreClock / 10000);

	while (1) {
		if (!(tick & 1023)) {
			temp_update();
		}
		__WFI();
	}

	return 0;
}
