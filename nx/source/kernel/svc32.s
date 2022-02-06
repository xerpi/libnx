/*
 * Copyright (c) 2019 Hydrosphère Developers
 *
 * Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
 * http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
 * <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
 * option. This file may not be copied, modified, or distributed
 * except according to those terms.
 */

.arm
.align 4

.macro SVC_BEGIN name
    .section .text.\name, "ax", %progbits
    .global \name
    .type \name, %function
    .align 2
    .cfi_startproc
\name:
.endm

.macro SVC_END
    .cfi_endproc
.endm

.macro DEFINE_OUT00_SVC id name
    SVC_BEGIN \name
        svc \id
        bx lr
    SVC_END
.endm

.macro DEFINE_OUT32_SVC id, name
    SVC_BEGIN \name
        str r0, [sp, #-0x4]!
        svc \id
        ldr r2, [sp]
        str r1, [r2]
        add sp, sp, #0x4
        bx lr
    SVC_END
.endm

.macro DEFINE_OUT32_ARG2_SVC id, name
    SVC_BEGIN \name
        str r1, [sp, #-0x4]!
        svc \id
        ldr r2, [sp]
        str r1, [r2]
        add sp, sp, #0x4
        bx lr
    SVC_END
.endm


DEFINE_OUT32_SVC      0x1 svcSetHeapSize
DEFINE_OUT00_SVC      0x2 svcSetMemoryPermission
DEFINE_OUT00_SVC      0x3 svcSetMemoryAttribute
DEFINE_OUT00_SVC      0x4 svcMapMemory
DEFINE_OUT00_SVC      0x5 svcUnmapMemory
DEFINE_OUT32_ARG2_SVC 0x6 svcQueryMemory
DEFINE_OUT00_SVC      0x7 svcExitProcess

SVC_BEGIN svcCreateThread
    stmfd sp!, {r0, r4}
    ldr r0, [sp, #0x8]
    ldr r4, [sp, #0xC]
    svc 0x8
    ldr r2, [sp]
    str r1, [r2]
    add sp, sp, #0x4
    pop {r4}
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x9 svcStartThread
DEFINE_OUT00_SVC      0xA svcExitThread
DEFINE_OUT00_SVC      0xB svcSleepThread
DEFINE_OUT32_SVC      0xC svcGetThreadPriority
DEFINE_OUT00_SVC      0xD svcSetThreadPriority

SVC_BEGIN svcGetThreadCoreMask
    stmfd sp!, {r0, r1, r4}
    svc 0xE
    ldr r4, [sp]
    str r1, [r4]
    ldr r4, [sp, #0x4]
    str r2, [r4]
    str r3, [r4, #0x4]
    add sp, sp, #0x4
    pop {r4}
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x0F svcSetThreadCoreMask

DEFINE_OUT00_SVC      0x10 svcGetCurrentProcessorNumber
DEFINE_OUT00_SVC      0x11 svcSignalEvent
DEFINE_OUT00_SVC      0x12 svcClearEvent
DEFINE_OUT00_SVC      0x13 svcMapSharedMemory
DEFINE_OUT00_SVC      0x14 svcUnmapSharedMemory
DEFINE_OUT32_SVC      0x15 svcCreateTransferMemory
DEFINE_OUT00_SVC      0x16 svcCloseHandle
DEFINE_OUT00_SVC      0x17 svcResetSignal

SVC_BEGIN svcWaitSynchronization
    str r0, [sp, #-0x4]!
    ldr r0, [sp, #0x4]
    ldr r3, [sp, #0x8]
    svc 0x18
    ldr r2, [sp]
    str r1, [r2]
    add sp, sp, #0x4
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x19 svcCancelSynchronization
DEFINE_OUT00_SVC      0x1A svcArbitrateLock
DEFINE_OUT00_SVC      0x1B svcArbitrateUnlock

SVC_BEGIN svcWaitProcessWideKeyAtomic
    str r4, [sp, #-0x4]!
    ldr r3, [sp, #0x4]
    ldr r4, [sp, #0x8]
    svc 0x1C
    pop {r4}
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x1D svcSignalProcessWideKey
DEFINE_OUT00_SVC      0x1E svcGetSystemTick
DEFINE_OUT32_SVC      0x1F svcConnectToNamedPort

DEFINE_OUT00_SVC      0x20 svcSendSyncRequestLight
DEFINE_OUT00_SVC      0x21 svcSendSyncRequest
DEFINE_OUT00_SVC      0x22 svcSendSyncRequestWithUserBuffer
DEFINE_OUT32_SVC      0x23 svcSendAsyncRequestWithUserBuffer

SVC_BEGIN svcGetProcessId
    str r0, [sp, #-0x4]!
    svc 0x24
    ldr r3, [sp]
    str r1, [r3]
    str r2, [r3, #0x4]
    add sp, sp, #0x4
    bx lr
SVC_END

SVC_BEGIN svcGetThreadId
    str r0, [sp, #-0x4]!
    svc 0x25
    ldr r3, [sp]
    str r1, [r3]
    str r2, [r3, #0x4]
    add sp, sp, #0x4
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x26 svcBreak
DEFINE_OUT00_SVC      0x27 svcOutputDebugString
DEFINE_OUT00_SVC      0x28 svcReturnFromException

SVC_BEGIN svcGetInfo
    str r0, [sp, #-0x4]!
    ldr r0, [sp, #0x4]
    ldr r3, [sp, #0x8]
    svc 0x29
    ldr r3, [sp]
    str r1, [r3]
    str r2, [r3, #0x4]
    add sp, sp, #0x4
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x2A svcFlushEntireDataCache
DEFINE_OUT00_SVC      0x2B svcFlushDataCache
# [3.0.0+] 0x2C - MapPhysicalMemory
# [3.0.0+] 0x2D - UnmapPhysicalMemory
# [5.0.0+] 0x2E - GetFutureThreadInfo
# TODO(Kaenbyō): [1.0.0+] 0x2F - GetLastThreadInfo

SVC_BEGIN svcGetResourceLimitLimitValue
    str r0, [sp, #-0x4]!
    svc 0x30
    ldr r3, [sp]
    str r1, [r3]
    str r2, [r3, #0x4]
    add sp, sp, #0x4
    bx lr
SVC_END

SVC_BEGIN svcGetResourceLimitCurrentValue
    str r0, [sp, #-0x4]!
    svc 0x31
    ldr r3, [sp]
    str r1, [r3]
    str r2, [r3, #0x4]
    add sp, sp, #0x4
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x32 svcSetThreadActivity
# TODO(Kaenbyō): [1.0.0+] 0x33 - GetThreadContext3
# [4.0.0+] 0x34 - WaitForAddress
# [4.0.0+] 0x35 - SignalToAddress
# [8.0.0+] 0x36 - SynchronizePreemptionState
# [1.0.0+] 0x3C - DumpInfo (stubbed?)
# [4.0.0+] 0x3D - DumpInfoNew (subbed?)

SVC_BEGIN svcCreateSession
    stmfd sp!, {r0, r1}
    svc 0x40
    ldr r3, [sp]
    str r1, [r3]
    ldr r3, [sp, #0x4]
    str r2, [r3]
    add sp, sp, #0x8
    bx lr
SVC_END

DEFINE_OUT32_SVC      0x41 svcAcceptSession
DEFINE_OUT00_SVC      0x42 svcReplyAndReceiveLight
SVC_BEGIN svcReplyAndReceive
    stmfd sp!, {r0, r4}
    ldr r0, [sp, #0x8]
    ldr r4, [sp, #0xC]
    svc 0x43
    ldr r2, [sp]
    str r1, [r2]
    add sp, sp, #0x4
    pop {r4}
    bx lr
SVC_END

SVC_BEGIN svcReplyAndReceiveWithUserBuffer
    stmfd sp!, {r0, r4-r6}
    ldr r0, [sp, #0x10]
    ldr r4, [sp, #0x14]
    ldr r5, [sp, #0x18]
    ldr r6, [sp, #0x1C]
    svc 0x44
    ldr r2, [sp]
    str r1, [r2]
    add sp, sp, #4
    ldmfd sp!, {r4-r6}
    bx lr
SVC_END

SVC_BEGIN svcCreateEvent
    stmfd sp!, {r0, r1}
    svc 0x45
    ldr r3, [sp]
    str r1, [r3]
    ldr r3, [sp, #0x4]
    str r2, [r3]
    add sp, sp, #0x8
    bx lr
SVC_END

DEFINE_OUT32_SVC      0x4B svcCreateCodeMemory

SVC_BEGIN svcControlCodeMemory
    stmfd sp!, {r4-r6}
    ldr r4, [sp, #0x0C]
    ldr r5, [sp, #0x10]
    ldr r6, [sp, #0x14]
    svc 0x4C
    ldmfd sp!, {r4-r6}
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x4D svcSleepSystem

SVC_BEGIN svcReadWriteRegister
    str r0, [sp, #-0x4]!
    ldr r0, [sp, #0x4]
    ldr r1, [sp, #0x8]
    svc 0x4E
    ldr r2, [sp]
    str r1, [r2]
    add sp, sp, #0x4
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x4F svcSetProcessActivity

DEFINE_OUT32_SVC      0x50 svcCreateSharedMemory
DEFINE_OUT00_SVC      0x51 svcMapTransferMemory
DEFINE_OUT00_SVC      0x52 svcUnmapTransferMemory
DEFINE_OUT32_SVC      0x53 svcCreateInterruptEvent
# [1.0.0+] 0x54 - QueryPhysicalAddress (leftover, never used in prod)

SVC_BEGIN svcQueryIoMapping
    str r0, [sp, #-0x4]!
    ldr r0, [sp, #0x4]
    svc 0x55
    ldr r2, [sp]
    str r1, [r2]
    add sp, sp, #0x4
    bx lr
SVC_END

SVC_BEGIN svcCreateDeviceAddressSpace
    str r0, [sp, #-0x4]!
    ldr r0, [sp, #0x4]
    ldr r1, [sp, #0x8]
    svc 0x56
    ldr r2, [sp]
    str r1, [r2]
    add sp, sp, #0x4
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x57 svcAttachDeviceAddressSpace
DEFINE_OUT00_SVC      0x58 svcDetachDeviceAddressSpace

SVC_BEGIN svcMapDeviceAddressSpaceByForce
    stmfd sp!, {r4-r7}
    ldr r4, [sp, #0x10]
    ldr r5, [sp, #0x18]
    ldr r6, [sp, #0x1C]
    ldr r7, [sp, #0x20]
    svc 0x59
    ldmfd sp!, {r4-r7}
    bx lr
SVC_END

SVC_BEGIN svcMapDeviceAddressSpaceAligned
    stmfd sp!, {r4-r7}
    ldr r4, [sp, #0x10]
    ldr r5, [sp, #0x18]
    ldr r6, [sp, #0x1C]
    ldr r7, [sp, #0x20]
    svc 0x5A
    ldmfd sp!, {r4-r7}
    bx lr
SVC_END

SVC_BEGIN svcMapDeviceAddressSpace
    stmfd sp!, {r0, r4-r7}
    ldr r0, [sp, #0x14]
    ldr r3, [sp, #0x18]
    ldr r4, [sp, #0x1C]
    ldr r5, [sp, #0x24]
    ldr r6, [sp, #0x28]
    ldr r7, [sp, #0x2C]
    svc 0x5B
    ldr r2, [sp]
    str r1, [r2]
    add sp, sp, #0x4
    ldmfd sp!, {r4-r7}
    bx lr
SVC_END

SVC_BEGIN svcUnmapDeviceAddressSpace
    stmfd sp!, {r4-r6}
    ldr r4, [sp, #0xC]
    ldr r5, [sp, #0x14]
    ldr r6, [sp, #0x18]
    svc 0x5C
    ldmfd sp!, {r4-r6}
    bx lr
SVC_END

SVC_BEGIN svcInvalidateProcessDataCache
    str r4, [sp, #-0x4]!
    ldr r1, [sp, #0x4]
    ldr r4, [sp, #0x8]
    svc 0x5D
    pop {r4}
    bx lr
SVC_END

SVC_BEGIN svcStoreProcessDataCache
    str r4, [sp, #-0x4]!
    ldr r1, [sp, #0x4]
    ldr r4, [sp, #0x8]
    svc 0x5E
    pop {r4}
    bx lr
SVC_END

SVC_BEGIN svcFlushProcessDataCache
    str r4, [sp, #-0x4]!
    ldr r1, [sp, #0x4]
    ldr r4, [sp, #0x8]
    svc 0x5F
    pop {r4}
    bx lr
SVC_END

DEFINE_OUT32_SVC      0x60 svcDebugActiveProcess
DEFINE_OUT00_SVC      0x61 svcBreakDebugProcess
DEFINE_OUT00_SVC      0x62 svcTerminateDebugProcess
# TODO(Kaenbyō): [1.0.0+] 0x63 - GetDebugEvent
# TODO(Kaenbyō): [1.0.0+, changed in 3.0.0] 0x64 - ContinueDebugEvent
DEFINE_OUT32_SVC      0x65 svcGetProcessList
DEFINE_OUT32_SVC      0x66 svcGetThreadList
# TODO(Kaenbyō): [1.0.0+] 0x67 - GetDebugThreadContext
# TODO(Kaenbyō): [1.0.0+] 0x68 - SetDebugThreadContext
# TODO(Kaenbyō): [1.0.0+] 0x69 - QueryDebugProcessMemory
# TODO(Kaenbyō): [1.0.0+] 0x6A - ReadDebugProcessMemory
# TODO(Kaenbyō): [1.0.0+] 0x6B - WriteDebugProcessMemory
# TODO(Kaenbyō): [1.0.0+] 0x6C - SetHardwareBreakPoint
# TODO(Kaenbyō): [1.0.0+] 0x6D - GetDebugThreadParam
# [5.0.0+] 0x6F - GetSystemInfo

SVC_BEGIN svcCreatePort
    stmfd sp!, {r0, r1}
    ldr r0, [sp, #0x8]
    svc 0x70
    ldr r3, [sp]
    str r1, [r3]
    ldr r3, [sp, #0x4]
    str r2, [r3]
    add sp, sp, #0x8
    bx lr
SVC_END

DEFINE_OUT32_SVC      0x71 svcManageNamedPort
DEFINE_OUT32_SVC      0x72 svcConnectToPort

SVC_BEGIN svcSetProcessMemoryPermission
    stmfd sp!, {r4, r5}
    ldr r1, [sp, #0x8]
    ldr r4, [sp, #0xC]
    ldr r5, [sp, #0x10]
    svc 0x73
    ldmfd sp!, {r4, r5}
    bx lr
SVC_END

SVC_BEGIN svcMapProcessMemory
    str r4, [sp, #-0x4]!
    ldr r4, [sp, #0x4]
    svc 0x74
    pop {r4}
    bx lr
SVC_END

SVC_BEGIN svcUnmapProcessMemory
    str r4, [sp, #-0x4]!
    ldr r4, [sp, #0x4]
    svc 0x75
    pop {r4}
    bx lr
SVC_END

SVC_BEGIN svcQueryProcessMemory
    str r1, [sp, #-0x4]!
    ldr r1, [sp, #0x4]
    ldr r3, [sp, #0x8]
    svc 0x76
    ldr r2, [sp]
    str r1, [r2]
    add sp, sp, #0x4
    bx lr
SVC_END

SVC_BEGIN svcMapProcessCodeMemory
    stmfd sp!, {r4-r6}
    ldr r1, [sp, #0xC]
    ldr r4, [sp, #0x10]
    ldr r5, [sp, #0x14]
    ldr r6, [sp, #0x18]
    svc 0x77
    ldmfd sp!, {r4-r6}
    bx lr
SVC_END

SVC_BEGIN svcUnmapProcessCodeMemory
    stmfd sp!, {r4-r6}
    ldr r1, [sp, #0xC]
    ldr r4, [sp, #0x10]
    ldr r5, [sp, #0x14]
    ldr r6, [sp, #0x18]
    svc 0x78
    ldmfd sp!, {r4-r6}
    bx lr
SVC_END

DEFINE_OUT32_SVC      0x79 svcCreateProcess

SVC_BEGIN svcStartProcess
    str r4, [sp, #-0x4]!
    ldr r3, [sp, #0x4]
    ldr r3, [sp, #0x8]
    svc 0x7A
    pop {r4}
    bx lr
SVC_END

DEFINE_OUT00_SVC      0x7B svcTerminateProcess

SVC_BEGIN svcGetProcessInfo
    str r0, [sp, #-0x4]!
    svc 0x7C
    ldr r3, [sp]
    str r1, [r3]
    str r2, [r3, #0x4]
    add sp, sp, #0x4
    bx lr
SVC_END


DEFINE_OUT32_SVC      0x7D svcCreateResourceLimit
DEFINE_OUT00_SVC      0x7E svcSetResourceLimitLimitValue
DEFINE_OUT00_SVC      0x7F svcCallSecureMonitor
