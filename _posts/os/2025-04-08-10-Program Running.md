---
layout: post
title:  "How the OS gets a program up and running"
date:   2025-04-08 10-00-00
tag: Operating System
---

1. Programs codes initially reside on disk or flash-based SSDs in some kind of executable format, the OS reads those bytes from disk and create a process.
2. The OS allocates an address space for the process. 
3. The OS loads their codes and any static data into the address space of the process in the memory. Modern OSes perform the loading process lazily, i.e., by loading pieces of code or data only as they are needed during program execution.
4. Once the code and static data are loaded into memory, some memory must be allocated for the program’s **run-time stack** (or just stack) for local variables, function parameters, and return addresses. The OS may also allocate some memory for the program’s heap. 
5. The OS will fill in the parameters to the main() function when initializing, i.e., `argc` and the `argv` array. 
6. Other initialization tasks, particularly as related to input/output (I/O).  For example, in UNIX systems, each process by default has three open file descriptors, for standard input, output, and error
7. Jumping to the main() routine,  the OS transfers control of the CPU to the newly-created process, and thus the program begins its execution.

![image]({{"/assets/images/os/Program Running.png" | relative_url}})