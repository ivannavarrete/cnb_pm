
; VGA driver


%include "driver.h"


	section .text
;=== DriverInit ================================================================
DriverInit:

	ret


;=== DriverCleanup =============================================================
DriverCleanup:

	ret


;=== VGAInt ====================================================================
VGAInt:

	iret


	section .data
