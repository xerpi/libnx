/**
 * @file tls.h
 * @brief AArch64 thread local storage.
 * @author plutoo
 * @copyright libnx Authors
 */
#pragma once
#include "../types.h"

/**
 * @brief Gets the thread local storage buffer.
 * @return The thread local storage buffer.
 */
static inline void* armGetTls(void) {
    void* ret;
#ifdef __ARM_ARCH_ISA_A64
    __asm__ ("mrs %x[data], tpidrro_el0" : [data] "=r" (ret));
#else
    __asm__ ("mrc p15, 0, %r[data], c13, c0, 3" : [data] "=r" (ret));
#endif
    return ret;
}
