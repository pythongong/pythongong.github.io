---
layout: post
title:  "Process Scheduling(2): MLFQ"
date:   2025-04-08 17-00-00
tag: Operating System
---

There’s an approach, known as the **Multi-level Feedback Queue** (MLFQ), that can optimize both turnaround time and responsive time.

The MLFQ has a number of distinct queues, each assigned a different **priority level**.  At any given time, a job that is ready to run is on a single queue. MLFQ uses priorities to decide which job should run at a given time: a job with higher priority is chosen to run. We will just use round-robin scheduling among jobs in the same queue.


Rather than giving a fixed priority to each job, MLFQ varies the priority of a job based on its **observed behavior**.  If, for example, a job repeatedly relinquishes the CPU while waiting for input from the keyboard, MLFQ will keep its priority high, as this is how an interactive process might behave. In this way, MLFQ will try to learn about processes as they run, and thus use the history of the job to predict its future behavior.

We now must decide how MLFQ is going to change the priority level of a job (and thus which queue it is on) over the lifetime of a job. For this, we need a new concept, which we will call the job’s **allotment**. The allotment is the amount of time a job can spend at a given priority level before the scheduler reduces its priority.

At first, we will assume the allotment is equal to a single time slice:

1. When a job enters the system, it is placed at the highest priority.
2. If a job uses up its allotment while running, its priority is reduced.
3. If a job gives up the CPU (for example, by performing an I/O operation) before the allotment is up, it stays at the same priority level

Suppose there are two jobs: A, which is a long-running CPU-intensive job, and B, which is a short-running interactive job which takes 20ms. Assume A has been running for some time, and then B arrives. These are what will happen: 

1. Job A (shown in black) is running along in the lowest-priority queue. 
2. B (shown in gray) arrives at time T = 100, and thus is inserted into the highest queue.
3. A suspends and B starts running.
4. As its run-time is short, B completes before reaching the bottom queue, in two time slices; 
5. A resumes running.


From this example, we know that MLFQ first assumes the new job might be a short job because it doesn’t know whether a job will be a short job or a long-running job. If it’s a long-running batch-like process, it will finally move down to the bottom queue with lowest priority. 

There’re still two problems

1. Starvation: if there are “too many” interactive jobs in the system, they will combine to consume all CPU time,  and thus long-running jobs will never receive any CPU time (they starve).
2. A program to game the scheduler. The algorithm we have described is susceptible to 
the following attack: before the allotment is used, issue an I/O operation and thus gain a higher percentage of CPU time. When done right (e.g., by running for 99% of the allotment before relinquishing the CPU), a job could nearly monopolize the CPU.
3. If the program issues an I/O after it relinquishes the CPU, its priority will be reduced. 

To avoid the problem 1 and 3, we **periodically boost** the priority of all the jobs in the system:  after some time period S, move all the jobs in the system to the topmost queue.

If S is set too high, long-running jobs could starve; too low, and interactive jobs may not get a proper share of the CPU. Such values in systems are called **voo-doo constants**, because they seemed to require some form of black magic to set them correctly. In the modern world, its right value is set by increasingly by automatic methods based on machine learning. 

We now have one more problem to solve: how to prevent gaming of our scheduler. The solution here is to perform **better accounting** of CPU time at each level of the MLFQ: once a job uses up its time allotment at a given level (regardless of how many times it has given up the CPU), its priority is reduced.


A few other issues arise with MIFQ scheduling: how many queues should there be? How big should the time slice be per queue? The allotment?  
In practice, most MLFQ variants allow for varying time-slice length across different queues. The high-priority queues are usually given short time slices and the low-priority queues are given longer time slices in contrast. 


Most OSs which implement MLFQ scheduling allow the system administrators to configure properties of MLFQ. The Solaris MLFQ implementation provides a set of tables that determine exactly how the priority of a process is altered throughout its lifetime. 

Others adjust priorities using **mathematical formulate**. For example, FreeBSD uses **decay-usage algorithms**. It calculates the current priority level of a job, basing it on how much CPU the process has used; in addition, usage is decayed over time, providing the desired priority boost in a different manner than described herein.

Some systems also allow some user advice to help set priorities; for example, by using the command-line utility **nice** you can increase or decrease the priority of a job.