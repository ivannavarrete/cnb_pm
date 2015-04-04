
/*
 * 23/04/2000
 *
 * DMA channel management
 */

#include <kernel.h>
#include <dma.h>
#include <errno.h>
#include <lowlevel.h>

/* dma controller and channel registers */
int dma_maskreg[] = {DMA1_MASKREG, DMA1_MASKREG, DMA1_MASKREG, DMA1_MASKREG,
				DMA2_MASKREG, DMA2_MASKREG, DMA2_MASKREG, DMA2_MASKREG};
int dma_page[] = {DMA_0_PAGE, DMA_1_PAGE, DMA_2_PAGE, DMA_3_PAGE,
				DMA_4_PAGE, DMA_5_PAGE, DMA_6_PAGE, DMA_7_PAGE};
int dma_addr[] = {DMA_0_ADDR, DMA_1_ADDR, DMA_2_ADDR, DMA_3_ADDR,
				DMA_4_ADDR, DMA_5_ADDR, DMA_6_ADDR, DMA_7_ADDR};
int dma_count[] = {DMA_0_COUNT, DMA_1_COUNT, DMA_2_COUNT, DMA_3_COUNT,
				DMA_4_COUNT, DMA_5_COUNT, DMA_6_COUNT, DMA_7_COUNT};

/* array of dma channel structures */
struct dma_chan dma_chans[MAX_DMA_CHAN] = {
	{0, NULL},
	{0, NULL},
	{0, NULL},
	{1, "cascade"},
};


/* request dma channel */
int request_dma(int chan, const char *dev) {
	if (chan > MAX_DMA_CHAN)
		return -EINVAL;
	if (dma_chans[chan].lock)
		return -EBUSY;
	
	dma_chans[chan].lock = 1;
	dma_chans[chan].dev_name = dev;

	return 0;
}


/* release dma channel */
int release_dma(int chan) {
	if (chan > MAX_DMA_CHAN)
		return -EINVAL;
	 if (!dma_chans[chan].lock)
	 	return -EINVAL;

	dma_chans[chan].lock = 0;
	return 0;
}


/* enable dma */
int enable_dma(int chan) {
	if (chan > MAX_DMA_CHAN)
		return -EINVAL;

	outb(dma_maskreg[chan], chan&0x03);
	return 0;
}


/* disable dma */
int disable_dma(int chan) {
	if (chan > MAX_DMA_CHAN)
		return -EINVAL;

	outb(dma_maskreg[chan], (chan&0x03)|0x04);
	return 0;
}


/* set dma mode */
/* not implemented */
int set_dma_mode(int chan, int mode) {
	return -1;
}


/* set dma page and page offset */
int set_dma_addr(int chan, int addr) {
	if (chan > MAX_DMA_CHAN || addr > MAX_DMA_ADDR)
		return -EINVAL;

	outb(dma_page[chan], (addr>>0x10)&0xFF);
	outb(dma_addr[chan], addr&0xFFFF);
	return 0;
}


/* set dma count */
/* not implemented */
int set_dma_count(int chan, int count) {
	return -1;
}
