---
layout: post
title:  "Concurrency introduction"
date:   2025-04-11
tag: Operating System
---

Each process has a thread of execution or **thread** for short that executes the process’s instructions.    Each thread is very much like a separate process, except for one difference: they share the same address space and thus can access the same data. 

Modern operating systems support several threads within a process, to allow a single process to exploit multiple CPUs. Indeed, the OS was the first concurrent program, and many techniques were created for use within the OS.  A multi-threaded program has the following properties:

- The state of a thread is very similar to that of a process. Each thread has its own private set of registers. It has its own program counter (PC) that tracks where the program is fetching instructions from.
- If there are two threads that are running on a single processor, when switching from running one (T1) to running the other (T2), a **context switch** must take place. The context switch between threads is quite similar to the context switch between processes, as the register state of T1 must be saved and the register state of T2 restored before running T2. It happens so fast and the time slices are so small that it looks all threads are running simultaneously.
- With processes, we saved state to a PCB; now, we’ll need one or more **thread control blocks** (TCBs) to store the state of each thread of a process.
- There is one major difference, **the address space remains the same** between different threads.  Thus, there is no need to switch which page table for the context switch. Communication is done through shared memory.

All thread shares the same heap but there will be one stack per thread. Stack segment can be divided into several sub stack frames within the address space. Thus, any stack-allocated variables, parameters, return values, and other things that we put on the stack will be placed in what is sometimes called **thread-local storage**, i.e., the stack of the relevant thread.

Each process has a thread of execution or **thread** for short that executes the process’s instructions.    Each thread is very much like a separate process, except for one difference: they share the same address space and thus can access the same data. 

Modern operating systems support several threads within a process, to allow a single process to exploit multiple CPUs. Indeed, the OS was the first concurrent program, and many techniques were created for use within the OS.  A multi-threaded program has the following properties:

- The state of a thread is very similar to that of a process. Each thread has its own private set of registers. It has its own program counter (PC) that tracks where the program is fetching instructions from.
- If there are two threads that are running on a single processor, when switching from running one (T1) to running the other (T2), a **context switch** must take place. The context switch between threads is quite similar to the context switch between processes, as the register state of T1 must be saved and the register state of T2 restored before running T2. It happens so fast and the time slices are so small that it looks all threads are running simultaneously.
- With processes, we saved state to a PCB; now, we’ll need one or more **thread control blocks** (TCBs) to store the state of each thread of a process.
- There is one major difference, **the address space remains the same** between different threads.  Thus, there is no need to switch which page table for the context switch. Communication is done through shared memory.

All thread shares the same heap but there will be one stack per thread. Stack segment can be divided into several sub stack frames within the address space. Thus, any stack-allocated variables, parameters, return values, and other things that we put on the stack will be placed in what is sometimes called **thread-local storage**, i.e., the stack of the relevant thread.

![image.png]({{"/assets/images/os/concurrency/concurrency-intro.png" | relative_url}})

In this figure, you can see two stacks spread throughout the address space of the process. 

There are at least two major reasons you should use threads: 

The first is parallelism.  Modern OSs are executing the program with multiple processors, so we have the potential of speeding up this process considerably by using the processors to each perform a portion of the work. For example, if you are adding two large arrays together, you can divide two large arrays into small parts, each of which is executed by one CPU. The task of transforming your standard single-threaded program into a program that does this sort of work on multiple CPUs is called **parallelization**.

The second reason is to avoid blocking program progress due to slow I/O. Threading enables **overlap** of I/O with other activities within a single program. Thus, instead of waiting for the I/O task to complete and let the CPU is switched to another process , your program may wish to create a thread to do something else, including utilizing the CPU to perform computation, or even issuing further I/O requests. Many modern server-based applications (web servers, database management systems, and the like) make use of threads. 

Of course, in either of the cases mentioned above, you could use multiple processes instead of threads. However, if your need to share many data structures between your logically separate tasks, the multiple threads is a more sound choice as it’s easier to share data in the same address space.

In this figure, you can see two stacks spread throughout the address space of the process. 

There are at least two major reasons you should use threads: 

The first is parallelism.  Modern OSs are executing the program with multiple processors, so we have the potential of speeding up this process considerably by using the processors to each perform a portion of the work. For example, if you are adding two large arrays together, you can divide two large arrays into small parts, each of which is executed by one CPU. The task of transforming your standard single-threaded program into a program that does this sort of work on multiple CPUs is called **parallelization**.

The second reason is to avoid blocking program progress due to slow I/O. Threading enables **overlap** of I/O with other activities within a single program. Thus, instead of waiting for the I/O task to complete and let the CPU is switched to another process , your program may wish to create a thread to do something else, including utilizing the CPU to perform computation, or even issuing further I/O requests. Many modern server-based applications (web servers, database management systems, and the like) make use of threads. 

Of course, in either of the cases mentioned above, you could use multiple processes instead of threads. However, if your need to share many data structures between your logically separate tasks, the multiple threads is a more sound choice as it’s easier to share data in the same address space.