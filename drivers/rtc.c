
/* Real Time Clock driver */

#include <cnb/rtc.h>

int rtc_ioctl(int cmd);



int rtc_ioctl(int cmd) {
	switch (cmd) {
		case RTC_AIE_ON:
			break;
		case RTC_AIE_OFF:
			break;
		case RTC_UIE_ON:
			break;
		case RTC_UIE_OFF:
			break;
		case RTC_PIE_ON:
			break;
		case RTC_PIE_OFF:
			break;
		default:
			return -1;
	}

	return 0;
}
