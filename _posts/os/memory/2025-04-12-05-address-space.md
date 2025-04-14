---
layout: post
title:  "Address Space"
date:   2025-04-13
tag: Operating System
---

The physical memory can be seen as a big array with a physical address as its index. Each array entry stores one byte data. 

As modern OS allows multiple process running at the same time, we can’t allow the program directly access the physical memory as it can affect other program’s memory. The OS provides an abstraction called the **address space** to help isolate and protect each process’s memory. It’s a general abstraction that hides differences between machine configurations.  It also provides the ability to allocate the memory that is larger than the physical main memory to the processes. 

 A **logical segment** is just a contiguous portion of the address space of a particular length. When the program is running, the memory gives it a address space which is divided into four sections — a **code segment**, a **heap segment**, a static data segment and a **stack segment**. Except the heap, size of all segments is fixed. 

Much of the state of a thread (local variables, function call return addresses) is stored on the thread’s stacks. Each process has two stacks: a **user stack** and a **kernel stack.** 

- When the process is executing user instructions, only its user stack is in use, and its kernel stack is empty.
- When the process enters the kernel, the kernel code executes on the process’s kernel stack. Its user stack still contains saved data, but isn’t actively used. The kernel stack is separate so that the kernel can execute even if a process has wrecked its user stack.

When executing a trap, the hardware must make sure to save enough of the caller’s registers in order to be able to return correctly. On x86, for example, the processor will push the program counter, flags, and a few other registers onto a per-process kernel stack; the return-from trap will pop these values off the stack and resume execution of the user mode program.

The stack will start from the highest address and grow **backward** while the heap can become larger by growing **forward**. 

The OS will grows the heap by performing a system call, such as `sbrk` in Unix, to grow the heap. If no more physical memory is available, or if it decides that the calling process already has too much, it could reject the request. 

The address space uses **virtual address** of the **virtual memory** provided by the OS instead of the real physical address. All addresses returned by the program are virtual addresses. The virtual memory is transparent to the running program and offers an illusion that the program behaves as if it has its own private physical memory. It allows us to place the address space anywhere we’d like in physical memory. 

How to translate between virtual address and physical address efficiently is the main issue of the hardware. With **hardware-based address translation**, or just address translation for short, the hardware transforms each memory access, changing the virtual address to a physical address. The OS must thus manage memory, keeping track of which locations are free and which are in use.