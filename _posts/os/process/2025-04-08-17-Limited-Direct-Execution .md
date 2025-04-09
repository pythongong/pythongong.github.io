---
layout: post
title:  "Limited Direct Execution "
date:   2025-04-08 17-00-00
tag: Operating System
---
The limited direct execution is like: 
<table border="2">
  <tr>
    <th>OS </th><th>Hardware</th><th>Program</th>
  </tr>
  <tr>
    <td>1. Create entry for process list  <br> 2. Allocate memory for program <br> 3. Load program into memory <br> 4. Setup user stack with argv <br> 5. Fill kernel stack with reg/PC return-from-trap </td>  
    <td> 6. restore regs (from kernel stack) move to user mode jump to main</td>
    <td> 7. Run the code <br>
8. Make a system call</td>
  </tr>
  
  <tr> 
  <td> </td>
  <td> 9. save regs (to kernel stack) move to kernel mode jump to trap handler</td>
  <td> </td> 
  </tr>

  <tr> 
  <td> 10. Handle a trap to do work of a system call <br> 11. return-from-trap</td>
  <td>12. restore regs (from kernel stack) move to user mode jump to PC after trap</td>
  <td>13. return from the trap and resume the process.</td> 
  </tr>
 <tr> 
  <td>14. Free memory of process <br> 15. Remove the process from process list</td>
  <td> </td>
  <td> </td> 
  </tr>


</table>





Next, we’ll achieve a switch between processes. The main issue is that how can the operating system regain control of the CPU so that it can switch between processes?

One approach that some systems have taken in the past is known as the **cooperative approach**.

In a cooperative scheduling system, the OS regains the control of the CPU by waiting for a system call, such as **yield ,** an interruption or an exception. If the OS thinks the process run too long, it will let the process give up the CPU to run other processes when the OS has the control of the CPU. The downside of the approach is that the process could never make a system call if it ends up in an infinite loop. In such case, the OS never regain the control of the CPU and the user has to reboot the machine.

The another way turns out to be simple: a **timer interrupt**. 

1. During the boot sequence, the OS starts the timer. 
2. When the timer expires every so many milliseconds, it raises an interrupt.  
3. When the interrupt is raised, the currently running process is halted, and a pre-configured trap handler in the OS runs. 
4. The OS regains control of the CPU and can stop the current process.

If the scheduler decides to out the state of CPU between processes, the OS then executes a low-level assembly code which we refer to as a **context switch**. 

A context switch is conceptually simple: 

- The trap handler saves a few register values for the currently-executing process (onto its kernel stack, for example)
- Trap handler then restores the next process’s registers  (from its kernel stack).

If a timer interrupt occurs, the program may make a system call or have an another interrupt. To solve this problem, the OS **disables interrupts** during interrupt processing to make sure that only one interrupt will be delivered to the CPU. The OS also have developed a number of sophisticated **locking schemes** to protect concurrent access to internal data structures.