.section .crt0, "ax", %progbits
.global _start
.align 2

_start:
    b 1f
    .word __nx_mod0 - _start
    .ascii "HOMEBREW"

.org _start+0x80; 1:
    // Arguments on NSO entry:
    //   r0=zero                  | r1=main thread handle
    // Arguments on NRO entry (homebrew ABI):
    //   r0=ptr to env context    | r1=UINT32_MAX (-1 aka 0xFFFFFFFF)
    // Arguments on user-mode exception entry:
    //   r0=excpt type (non-zero) | r1=ptr to excpt context

    // Detect and handle user-mode exceptions first:
    // if (r0 != 0 && r1 != UINT32_MAX) __libnx_exception_entry(<inargs>);
    cmp   r0, #0
    beq  .Lcrt0_main_entry
    mvn  r2, #0
    cmp  r2, r1
    beq  .Lcrt0_main_entry
    b     __libnx_exception_entry

.Lcrt0_main_entry:
    // Get pointer to MOD0 struct (contains offsets to important places)
    adr  r4, __nx_mod0

    // Calculate BSS address/size
    ldr  r2, [r4, #8]      // load BSS start offset from MOD0
    ldr  r3, [r4, #12]     // load BSS end offset from MOD0
    sub  r3, r3, r2        // calculate BSS size
    add  r3, r3, #7        // round up to 8
    bic  r3, r3, #7        // ^
    add  r2, r4, r2        // fixup the start pointer

    // Clear the BSS in 4-byte units
    mov r5, #0
1:  subs r3, r3, #4
    str  r5, [r2], #4
    bne  1b

    // Preserve registers across function calls
    mov r5, r0  // entrypoint argument 0
    mov r6, r1  // entrypoint argument 1
    mov r7, lr  // loader return address

    // Save initial stack pointer
    adr  r2, __stack_top_addr
    ldr  r3, [r2]
    add  r2, r2, r3
    str  sp, [r2]

    // Parse ELF .dynamic section (which applies relocations to our module)
    adr  r0, _start    // get aslr base
    ldr  r1, [r4, #4]  // pointer to .dynamic section
    add  r1, r4, r1
    bl   __nx_dynamic

    // Perform system initialization
    mov  r0, r5
    mov  r1, r6
    mov  r2, r7
    bl   __libnx_init

    // Jump to the main function
    adr  r2, __system_args_addr
    ldr  r0, [r2, #0] // argc
    add  r0, r2
    ldr  r1, [r2, #4] // argv
    add  r1, r2
    ldr  lr, [r2, #8] // exit
    add  lr, r2
    b    main

__stack_top_addr:
    .word __stack_top - __stack_top_addr

__system_args_addr:
    .word __system_argc - __system_args_addr
    .word __system_argv - __system_args_addr
    .word exit          - __system_args_addr



.global __nx_exit
.type   __nx_exit, %function
__nx_exit:
    // Restore stack pointer
    adr  r2, __stack_top_addr
    ldr  r3, [r2]
    add  r2, r2, r3
    ldr  sp, [r2]

    // Jump back to loader
    bx   r1

.global __nx_mod0
__nx_mod0:
    .ascii "MOD0"
    .word  _DYNAMIC             - __nx_mod0
    .word  __bss_start__        - __nx_mod0
    .word  __bss_end__          - __nx_mod0
    .word  __eh_frame_hdr_start - __nx_mod0
    .word  __eh_frame_hdr_end   - __nx_mod0
    .word  0 // "offset to runtime-generated module object" (neither needed, used nor supported in homebrew)

    // MOD0 extensions for homebrew
    .ascii "LNY0"
    .word  __got_start__        - __nx_mod0
    .word  __got_end__          - __nx_mod0

.section .bss.__stack_top, "aw", %nobits
.global __stack_top
.align 2

__stack_top:
    .space 4
