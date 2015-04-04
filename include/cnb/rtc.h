
#ifndef _RTC_H
#define _RTC_H

/***************************************************
 * register summary
 **************************************************/
/* time and date */
#define RTC_SECONDS 0
#define RTC_SECONDS_ALARM 1
#define RTC_MINUTES 2
#define RTC_MINUTES_ALARM 3
#define RTC_HOURS 4
#define RTC_HOURS_ALARM 5
#define DAY_OF_WEEK 6
#define DATE_OF_MONTH 7
#define MONTH 8
#define YEAR 9

/* status registers */
#define RTC_STATUS_A 10		/* bit 7 read only */
#define RTC_STATUS_B 11
#define RTC_STATUS_C 12		/* read only */
#define RTC_STATUS_D 13		/* read only */

/**************************************************
 * status register details
 *************************************************/
/*** Status register A ***************************/
/* periodic int rate select: 0=none, 1=32,8kHz, ..., F=2Hz */
#define RTC_RATE_SELECT 0x0F
/* 22-stage divider control */
#define RTC_REF_CLK_4MHZ 0x00
#define RTC_REF_CLK_1MHZ 0x10
#define RTC_REF_CLK_32KHZ 0x20
/* divider reset */
#define RTC_RESET1 0x60
#define RTC_RESET2 0x70
/* 1 means update of time and date in progress */
#define RTC_UIP 0x80

/*** Status register B ***************************/
#define RTC_SET 0x80		/* disable RTC */
#define RTC_PIE 0x40		/* periodic interrupt enable */
#define RTC_AIE 0x20		/* alarm interrupt enable */
#define RTC_UIE 0x10		/* update ended interrupt enable */

#define RTC_SWE 0x08		/* square wave enable */
#define RTC_DMD_BIN 0x04	/* set binary data mode */
#define RTC_24H 0x02		/* 24 hour mode */
#define RTC_DSE 0x01		/* daylight savings time */

/*** Status register C ***************************/
#define RTC_IRQF 0x80		/* IRQ flag; an interrupt ocurred */
#define RTC_PF 0x40			/* periodic interrupt flag */
#define RTC_AF 0x20			/* alarm interrupt flag */
#define RTC_UF 0x10			/* update ended interrupt flag */

/*** Status register D ***************************/
#define RTC_RAM_VALID 0x80	/* 0 means battery backup is dead and RAM lost */


/*************************************************
 * ioctl() calls
 ************************************************/
#define RTC_UIE_ON 0x0		/* update interrupt enable on/off */
#define RTC_UIE_OFF 0x1
#define RTC_AIE_ON 0x2		/* alarm interrupt enable on/off */
#define RTC_AIE_OFF 0x3
#define RTC_PIE_ON 0x4		/* periodic interrupt enable on/off */
#define RTC_PIE_OFF 0x5


#endif _RTC_H
