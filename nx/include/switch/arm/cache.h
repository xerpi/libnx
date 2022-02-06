/**
 * @file cache.h
 * @brief AArch64 cache operations.
 * @author plutoo
 * @copyright libnx Authors
 */
#pragma once
#include "../types.h"

/**
 * @brief Performs a data cache flush on the specified buffer.
 * @param addr Address of the buffer.
 * @param size Size of the buffer, in bytes.
 * @remarks Cache flush is defined as Clean + Invalidate.
 * @note The start and end addresses of the buffer are forcibly rounded to cache line boundaries (read from CTR_EL0 system register).
 */
void armDCacheFlush(void* addr, size_t size);

/**
 * @brief Performs a data cache clean on the specified buffer.
 * @param addr Address of the buffer.
 * @param size Size of the buffer, in bytes.
 * @note The start and end addresses of the buffer are forcibly rounded to cache line boundaries (read from CTR_EL0 system register).
 */
void armDCacheClean(void* addr, size_t size);

/**
 * @brief Performs an instruction cache invalidation clean on the specified buffer.
 * @param addr Address of the buffer.
 * @param size Size of the buffer, in bytes.
 * @note The start and end addresses of the buffer are forcibly rounded to cache line boundaries (read from CTR_EL0 system register).
 */
void armICacheInvalidate(void* addr, size_t size);

/**
 * @brief Performs a data cache zeroing operation on the specified buffer.
 * @param addr Address of the buffer.
 * @param size Size of the buffer, in bytes.
 * @note The start and end addresses of the buffer are forcibly rounded to cache line boundaries (read from CTR_EL0 system register).
 */
void armDCacheZero(void* addr, size_t size);

#ifndef __ARM_ARCH_ISA_A64

#include "switch/kernel/svc.h"

/*#define armDCacheFlush(addr, size) \
    svcFlushDataCache(addr, size)*/

#define armDCacheFlush(addr, size) \
    svcFlushProcessDataCache(CUR_PROCESS_HANDLE, (uint64_t)(uintptr_t)addr, size)

#define armDCacheClean(addr, size) \
    svcStoreProcessDataCache(CUR_PROCESS_HANDLE, (uint64_t)(uintptr_t)addr, size)

#define armICacheInvalidate(addr, size) (void)0

#define armDCacheZero(addr, size) \
    do { \
        memset(addr, 0, size); \
        armDCacheFlush((uint64_t)(uintptr_t)addr, size); \
    } while (0)

#endif
