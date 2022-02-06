.macro CODE_BEGIN name
    .section .text.\name, "ax", %progbits
    .global \name
    .type \name, %function
    .align 2
    .cfi_startproc
\name:
.endm

.macro CODE_END
    .cfi_endproc
.endm

// Called by crt0 when the args at the time of entry indicate an exception occured.

.weak __libnx_exception_handler

.weak __libnx_exception_entry
CODE_BEGIN __libnx_exception_entry
   // TODO

__libnx_exception_entry_start:
    // TODO
    b __libnx_exception_entry_end

__libnx_exception_entry_abort:
    mov r0, #0xf801
__libnx_exception_entry_end:
    bl svcReturnFromException
    b .
CODE_END

// Jumped to by kernel in svcReturnFromException via the overridden elr_el1, with x0 set to __nx_exceptiondump.
CODE_BEGIN __libnx_exception_returnentry
    // TODO
CODE_END

