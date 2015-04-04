
int task_htable[MAX_TASKS];
struct tss task_list[MAX_TASKS];

int current_task;



int CreateTask(void *addr) {
	/* search for an empty entry in task_htable */

	/* search for a free TSS in task_list
	 * (replaced with dynamic alloc. later) */
	
	/* store addr of TSS in task_htable */

	/* clear TSS */

	/* init TSS */

	/* allocate a TSS descriptor in the GDT */
	if ( (res = RequestDesc(+SYS_ADDR, TSS_SIZE, D_TSS32| D_GB | D_DPL0,
				GDT, gdt_sel)) < 0)
		return res;

}


