// Copyright 2017 plutoo, 2020 SciresM
#include "result.h"
#include "kernel/svc.h"
#include "kernel/mutex.h"
#include "../internal.h"

#define HANDLE_WAIT_MASK 0x40000000u

#define dmb()          __asm__ __volatile__ ("dmb " : : : "memory")
#define LIKELY(expr)   (__builtin_expect_with_probability(!!(expr), 1, 1.0))
#define UNLIKELY(expr) (__builtin_expect_with_probability(!!(expr), 0, 1.0))

NX_INLINE u32 _GetTag(void) {
    return getThreadVars()->handle;
}

NX_INLINE u32 _LoadExclusive(Mutex *ptr) {
    u32 value;
#ifdef __ARM_ARCH_ISA_A64
    __asm__ __volatile__("ldaxr %w[value], %[ptr]" : [value]"=&r"(value) : [ptr]"Q"(*ptr) : "memory");
#else
    __asm__ __volatile__("ldrex %r[value], %[ptr]" : [value]"=&r"(value) : [ptr]"Q"(*ptr) : "memory");
#endif
    return value;
}

NX_INLINE bool _StoreExclusive(Mutex *ptr, u32 value) {
    u32 result;
#ifdef __ARM_ARCH_ISA_A64
    __asm__ __volatile__("stlxr %w[result], %w[value], %[ptr]" : [result]"=&r"(result) : [value]"r"(value), [ptr]"Q"(*ptr) : "memory");
#else
    __asm__ __volatile__("strex %r[result], %r[value], %[ptr]" : [result]"=&r"(result) : [value]"r"(value), [ptr]"Q"(*ptr) : "memory");
#endif
    return result != 0;
}

NX_INLINE void _ClearExclusive(void) {
    __asm__ __volatile__("clrex" ::: "memory");
}

void mutexLock(Mutex* m) {
    // Get the current thread handle.
    const u32 cur_handle = _GetTag();

    u32 value = _LoadExclusive(m);
    while (true) {
        // If the mutex isn't owned, try to take it.
        if (LIKELY(value == INVALID_HANDLE)) {
            // If we fail, try again.
            if (UNLIKELY(_StoreExclusive(m, cur_handle) != 0)) {
                value = _LoadExclusive(m);
                continue;
            }
            break;
        }

        // If the mutex doesn't have any waiters, try to register ourselves as the first waiter.
        if (LIKELY((value & HANDLE_WAIT_MASK) == 0)) {
            // If we fail, try again.
            if (UNLIKELY(_StoreExclusive(m, value | HANDLE_WAIT_MASK) != 0)) {
                value = _LoadExclusive(m);
                continue;
            }
        }

        // Ask the kernel to arbitrate the lock for us.
        if (UNLIKELY(R_FAILED(svcArbitrateLock(value & ~HANDLE_WAIT_MASK, (u32*)m, cur_handle)))) {
            // This should be impossible under normal circumstances.
            svcBreak(BreakReason_Assert, 0, 0);
        }

        // Reload the value, and check if we got the lock.
        value = _LoadExclusive(m);
        if (LIKELY((value & ~HANDLE_WAIT_MASK) == cur_handle)) {
            _ClearExclusive();
            break;
        }
    }

#ifndef __ARM_ARCH_ISA_A64
    dmb(); // Done only in aarch32 mode.
#endif
}

bool mutexTryLock(Mutex* m) {
    // Get the current thread handle.
    const u32 cur_handle = _GetTag();

    while (true) {
        // Check that the mutex is not owned.
        u32 value = _LoadExclusive(m);
        if (UNLIKELY(value != INVALID_HANDLE)) {
            break;
        }

#ifndef __ARM_ARCH_ISA_A64
        dmb(); // Done only in aarch32 mode.
#endif

        if (LIKELY(_StoreExclusive(m, cur_handle) == 0)) {
            return true;
        }
    }

    // Release our exclusive hold.
    _ClearExclusive();

#ifndef __ARM_ARCH_ISA_A64
    dmb(); // Done only in aarch32 mode.
#endif

    return false;
}

void mutexUnlock(Mutex* m) {
    // Get the current thread handle.
    const u32 cur_handle = _GetTag();

    u32 value = _LoadExclusive(m);
    while (true) {
        // If we have any listeners, we need to ask the kernel to arbitrate.
        if (UNLIKELY(value != cur_handle)) {
            _ClearExclusive();
            break;
        }

#ifndef __ARM_ARCH_ISA_A64
        dmb(); // Done only in aarch32 mode.
#endif

        // Try to release the lock.
        if (LIKELY(_StoreExclusive(m, INVALID_HANDLE) == 0)) {
            break;
        }

        // Reload the value and try again.
        value = _LoadExclusive(m);
    }

#ifndef __ARM_ARCH_ISA_A64
    dmb(); // Done only in aarch32 mode.
#endif

    if (value & HANDLE_WAIT_MASK) {
        // Ask the kernel to arbitrate unlock for us.
        if (UNLIKELY(R_FAILED(svcArbitrateUnlock((u32*)m)))) {
            // This should be impossible under normal circumstances.
            svcBreak(BreakReason_Assert, 0, 0);
        }
    }
}

bool mutexIsLockedByCurrentThread(const Mutex* m) {
    // Get the current thread handle.
    const u32 cur_handle = _GetTag();

    return (*m & ~HANDLE_WAIT_MASK) == cur_handle;
}

void rmutexLock(RMutex* m) {
    if (m->thread_tag != _GetTag()) {
        mutexLock(&m->lock);
        m->thread_tag = _GetTag();
    }

    m->counter++;
}

bool rmutexTryLock(RMutex* m) {
    if (m->thread_tag != _GetTag()) {
        if (!mutexTryLock(&m->lock)) {
            return false;
        }
        m->thread_tag = _GetTag();
    }

    m->counter++;
    return true;
}

void rmutexUnlock(RMutex* m) {
    if (--m->counter == 0) {
        m->thread_tag = 0;
        mutexUnlock(&m->lock);
    }
}
