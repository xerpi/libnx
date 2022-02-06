/**
 * @file counter.h
 * @brief AArch64 system counter-timer.
 * @author fincs
 * @copyright libnx Authors
 */
#pragma once
#include "../types.h"

/**
 * @brief Gets the current system tick.
 * @return The current system tick.
 */
static inline u64 armGetSystemTick(void) {
#ifdef __ARM_ARCH_ISA_A64
    u64 ret;
    __asm__ __volatile__ ("mrs %x[data], cntpct_el0" : [data] "=r" (ret));
    return ret;
#else
    u32 lo, hi;
    __asm__ __volatile__ ("mrrc p15, 0, %r[lo], %r[hi], c14" : [lo] "=r" (lo), [hi] "=r" (hi));
    return lo | ((u64)hi << 32);
#endif
}

/**
 * @brief Gets the system counter-timer frequency
 * @return The system counter-timer frequency, in Hz.
 */
static inline u64 armGetSystemTickFreq(void) {
#ifdef __ARM_ARCH_ISA_A64
    u64 ret;
    __asm__ ("mrs %x[data], cntfrq_el0" : [data] "=r" (ret));
    return ret;
#else
    u32 ret;
     __asm__ ("mrc p15, 0, %r[data], c14, c0, 0" : [data] "=r" (ret));
    return (u64)ret;
#endif
}

/**
 * @brief Converts from nanoseconds to CPU ticks unit.
 * @param ns Time in nanoseconds.
 * @return Time in CPU ticks.
 */
static inline u64 armNsToTicks(u64 ns) {
    return (ns * 12) / 625;
}

/**
 * @brief Converts from CPU ticks unit to nanoseconds.
 * @param tick Time in ticks.
 * @return Time in nanoseconds.
 */
static inline u64 armTicksToNs(u64 tick) {
    return (tick * 625) / 12;
}
