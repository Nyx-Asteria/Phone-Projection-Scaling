/* SPDX-License-Identifier: GPL-3.0-or-later
 * Adapted from CarPlay Ultra-Lite source/native/seg.S. */
.syntax unified
.thumb
.section .text.entry,"ax",%progbits
.global pps_stub_info
.thumb_func
pps_stub_info:
    push {r4,r5}
    adr.w r12, pps_table
    ldr r3,[r12,#0]
    add r3,r12
    blx r3
    mov r4,r0
    cbz r0,1f
    bl pps_info
1:  mov r0,r4
    pop {r4,r5}
    adr.w r12,pps_table
    ldr r3,[r12,#4]
    add r3,r12
    bx r3

.global pps_sys3
.thumb_func
pps_sys3:
    push {r7,lr}
    mov r7,r0
    mov r0,r1
    mov r1,r2
    mov r2,r3
    svc #0
    pop {r7,pc}

.balign 4
.global pps_table
.hidden pps_table
pps_table:
    .rept 19
    .word 0
    .endr
