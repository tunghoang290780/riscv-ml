/* SPDX-License-Identifier: BSD-2-Clause */
/*
 * Copyright (C) 2019 FORTH-ICS/CARV
 *				Panagiotis Peristerakis <perister@ics.forth.gr>
 */

#include <sbi/riscv_asm.h>
#include <sbi/riscv_encoding.h>
#include <sbi/riscv_io.h>
#include <sbi/sbi_console.h>
#include <sbi/sbi_const.h>
#include <sbi/sbi_hart.h>
#include <sbi/sbi_platform.h>
#include <sbi_utils/fdt/fdt_helper.h>
#include <sbi_utils/fdt/fdt_fixup.h>
#include <sbi_utils/ipi/aclint_mswi.h>
#include <sbi_utils/irqchip/plic.h>
#include <sbi_utils/serial/uart8250.h>
#include <sbi_utils/timer/aclint_mtimer.h>

#define RISCV_ML_UART_ADDR			0x10000000
#define RISCV_ML_UART_FREQ			50000000
#define RISCV_ML_UART_BAUDRATE			115200
#define RISCV_ML_UART_REG_SHIFT			2
#define RISCV_ML_UART_REG_WIDTH			4
#define RISCV_ML_PLIC_ADDR			0xc000000
#define RISCV_ML_PLIC_NUM_SOURCES			3
#define RISCV_ML_HART_COUNT			1
#define RISCV_ML_CLINT_ADDR			0x2000000
#define RISCV_ML_ACLINT_MTIMER_FREQ		1000000
#define RISCV_ML_ACLINT_MSWI_ADDR			(RISCV_ML_CLINT_ADDR + \
						 CLINT_MSWI_OFFSET)
#define RISCV_ML_ACLINT_MTIMER_ADDR		(RISCV_ML_CLINT_ADDR + \
						 CLINT_MTIMER_OFFSET)

static struct plic_data plic = {
	.addr = RISCV_ML_PLIC_ADDR,
	.num_src = RISCV_ML_PLIC_NUM_SOURCES,
};

static struct aclint_mswi_data mswi = {
	.addr = RISCV_ML_ACLINT_MSWI_ADDR,
	.size = ACLINT_MSWI_SIZE,
	.first_hartid = 0,
	.hart_count = RISCV_ML_HART_COUNT,
};

static struct aclint_mtimer_data mtimer = {
	.mtime_freq = RISCV_ML_ACLINT_MTIMER_FREQ,
	.mtime_addr = RISCV_ML_ACLINT_MTIMER_ADDR +
		      ACLINT_DEFAULT_MTIME_OFFSET,
	.mtime_size = ACLINT_DEFAULT_MTIME_SIZE,
	.mtimecmp_addr = RISCV_ML_ACLINT_MTIMER_ADDR +
			 ACLINT_DEFAULT_MTIMECMP_OFFSET,
	.mtimecmp_size = ACLINT_DEFAULT_MTIMECMP_SIZE,
	.first_hartid = 0,
	.hart_count = RISCV_ML_HART_COUNT,
	.has_64bit_mmio = TRUE,
};

/*
 * RISCV_ML platform early initialization.
 */
static int riscv_ml_early_init(bool cold_boot)
{
	/* For now nothing to do. */
	return 0;
}

/*
 * RISCV_ML platform final initialization.
 */
static int riscv_ml_final_init(bool cold_boot)
{
	void *fdt;

	if (!cold_boot)
		return 0;

	fdt = fdt_get_address();
	fdt_fixups(fdt);

	return 0;
}

/*
 * Initialize the RISCV_ML console.
 */
static int riscv_ml_console_init(void)
{
	return uart8250_init(RISCV_ML_UART_ADDR,
			     RISCV_ML_UART_FREQ,
			     RISCV_ML_UART_BAUDRATE,
			     RISCV_ML_UART_REG_SHIFT,
			     RISCV_ML_UART_REG_WIDTH);
}

static int plic_RISCV_ml_warm_irqchip_init(int m_cntx_id, int s_cntx_id)
{
	size_t i, ie_words = RISCV_ML_PLIC_NUM_SOURCES / 32 + 1;

	/* By default, enable all IRQs for M-mode of target HART */
	if (m_cntx_id > -1) {
		for (i = 0; i < ie_words; i++)
			plic_set_ie(&plic, m_cntx_id, i, 1);
	}
	/* Enable all IRQs for S-mode of target HART */
	if (s_cntx_id > -1) {
		for (i = 0; i < ie_words; i++)
			plic_set_ie(&plic, s_cntx_id, i, 1);
	}
	/* By default, enable M-mode threshold */
	if (m_cntx_id > -1)
		plic_set_thresh(&plic, m_cntx_id, 1);
	/* By default, disable S-mode threshold */
	if (s_cntx_id > -1)
		plic_set_thresh(&plic, s_cntx_id, 0);

	return 0;
}

/*
 * Initialize the RISCV_ML interrupt controller for current HART.
 */
static int riscv_ml_irqchip_init(bool cold_boot)
{
	u32 hartid = current_hartid();
	int ret;

	if (cold_boot) {
		ret = plic_cold_irqchip_init(&plic);
		if (ret)
			return ret;
	}
	return plic_riscv_ml_warm_irqchip_init(2 * hartid, 2 * hartid + 1);
}

/*
 * Initialize IPI for current HART.
 */
static int riscv_ml_ipi_init(bool cold_boot)
{
	int ret;

	if (cold_boot) {
		ret = aclint_mswi_cold_init(&mswi);
		if (ret)
			return ret;
	}

	return aclint_mswi_warm_init();
}

/*
 * Initialize RISCV_ML timer for current HART.
 */
static int riscv_ml_timer_init(bool cold_boot)
{
	int ret;

	if (cold_boot) {
		ret = aclint_mtimer_cold_init(&mtimer, NULL);
		if (ret)
			return ret;
	}

	return aclint_mtimer_warm_init();
}

/*
 * Platform descriptor.
 */
const struct sbi_platform_operations platform_ops = {
	.early_init = riscv_ml_early_init,
	.final_init = riscv_ml_final_init,
	.console_init = riscv_ml_console_init,
	.irqchip_init = riscv_ml_irqchip_init,
	.ipi_init = riscv_ml_ipi_init,
	.timer_init = riscv_ml_timer_init,
};

const struct sbi_platform platform = {
	.opensbi_version = OPENSBI_VERSION,
	.platform_version = SBI_PLATFORM_VERSION(0x0, 0x01),
	.name = "RISCV_ML",
	.features = SBI_PLATFORM_DEFAULT_FEATURES,
	.hart_count = RISCV_ML_HART_COUNT,
	.hart_stack_size = SBI_PLATFORM_DEFAULT_HART_STACK_SIZE,
	.platform_ops_addr = (unsigned long)&platform_ops
};
