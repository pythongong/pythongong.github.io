---
layout: post
title:  "Process Scheduling(1): Introduction"
date:   2025-04-08 17-00-00
tag: Operating System
---

Before introduce the scheduling policies, we will make the following assumptions about the processes, sometimes called jobs, that are running in the system:

1. Each job runs for the same amount of time.
2. All jobs arrive at the same time.
3. Once started, each job runs to completion.
4. All jobs only use the CPU (i.e., they perform no I/O)
5. The run-time of each job is known.

A job that interacts with the I/O devices or other hardware is sometimes called a **interactive job**.

A metric is just something that we use to measure something, and there are a number of different **scheduling metrics**.

One is the **turnaround time** of a job that is defined as the time at which the job completes minus the time at which the job arrived in the system: 

$$
T_\text{turnaround} = T_\text{completion}-T_\text{arrival}
$$

Because we have assumed that all jobs arrive at the same time, for now $T_\text{arrival}  = 0$ and hence $T_\text{turnaround} = T_\text{completion}$

The most basic algorithm is known as **First In, First Out** (FIFO) scheduling or sometimes First Come, First Served (FCFS). It is clearly simple and easy to implement. 

Let’s assume that while they all arrived simultaneously, A arrived just a hair before B which arrived just a hair before C. Assume also that each job runs for 10 seconds.

A finished at 10, B at 20, and C at 30. Thus, the average turnaround time = $\frac{10+20+30}3 = 20$.

Let’s relax assumption 1, and thus no longer assume that each job runs for the same amount of time.

Let’s again assume three jobs (A, B, and C), but this time A runs for 100 seconds while B and C run for 10 each. The average turnaround time = = $\frac{100+110+120}3 = 110$..

This problem is generally referred to as the **convoy effect** , where a number of relatively-short potential consumers of a resource get queued behind a heavyweight resource consumer.  

To solve this problem, we introduce a new scheduling discipline known as **Shortest Job First** (SJF),

Let’s take our example above but with SJF as our scheduling policy. We can calculate that the average turnaround time = 50.

We now assume that jobs can arrive at any time instead of all at once.

This time, assume A arrives at t = 0 and needs to run for 100 seconds, whereas B and C arrive at t = 10 and each need to run for 10 seconds. The average turnaround time = 103.33.

To address this concern, we need to relax assumption 3 (that jobs must run to completion) and a new scheduler known as the **Shortest Time-to-Completion First** (STCF) or Preemptive Shortest Job First (PSJF) scheduler. 

Any time a new job enters the system, the STCF scheduler determines which of the remaining jobs including the new job has the least time left, and schedules that one.

Thus, in our example, STCF would preempt A and run B and C to completion, the average turnaround time = 50.

If we knew job lengths, and that jobs only used the CPU, and our only metric was turnaround time, STCF would be a great policy. However, the introduction of time-shared machines changed all that. Thus, a new metric was born: **response time**.

We define response time as the time from when the job arrives in a system to the first time it is scheduled

$$
T_\text{response} = T_
\text{firstrun} - T_
\text{arrival} 

$$

Given the example above, the response time of each job is as follows: 0 for job A, 0 for B, and 10 for C for STCF. The average is 3.33 

If three jobs arrive at the same time, for example, the third job has to wait for the previous two jobs to run in their entirety before being scheduled just once. It’s not pleasant to imagine sitting at a terminal, typing, and having to wait 10 seconds to see a response from the system. Thus, we must consider the scheduler’s impact on response time.

To solve this problem, we will introduce a new scheduling algorithm, classically referred to as **Round-Robin** (RR) scheduling. 

The basic idea is simple: instead of running jobs to completion, RR runs a job for a **time slice** (sometimes called a scheduling quantum) and then switches to the next job in the run queue. It repeatedly does so until the jobs are finished. For this reason, RR is sometimes called **time-slicing**.

Note that the length of a time slice must be a multiple of the timer-interrupt period; thus if the timer interrupts every 10 milliseconds, the time slice could be 10, 20, or any other multiple of 10 ms.

Assume three jobs A, B, and C arrive at the same time in the system, and that they each wish to run for 5 seconds with a time-slice of 1 second. The average response time is 1.

The shorter the time slice is, the better the performance of RR under the response-time metric. However, making the time slice too short is problematic due to the cost of context switch. Thus, we must make it long enough to amortize the cost of switching.

Switching to another job also causes the old state to be flushed and new state relevant to the currently-running job to be brought in, which may exact a noticeable performance cost.

As for the turnaround time, we can see from the picture above that A finishes at 13, B at 14, and C at 15, for an average of 14. The average is 14. RR is indeed one of the worst policies if turnaround time is our metric. More generally, any policy (such as RR) that is **fair**, i.e., that evenly divides the CPU among active processes on a small time scale, will perform poorly on metrics such as turnaround time.

Then we’ll relax the assumption 4  that jobs do no I/O. The scheduler also has to make a decision when the I/O starts and completes. 

Let us assume we have two jobs, A and B, which each need 50ms of CPU time. A runs for 10ms and then issues an I/O request  which takes 10ms, whereas B performs no I/O. A common approach is to treat each 10-ms sub-job of A as an independent job.  With STCF, we choose to run A first as its sub-job is shorter than B. When the first sub-job of A has completed, only B is left, and it begins running. Then a new sub-job of A is submitted, and it preempts B and runs for 10 ms. Doing so allows for **overlap**.