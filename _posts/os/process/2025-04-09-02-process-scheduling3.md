---
layout: post
title:  "Process Scheduling(3): Proportional Share "
date:   2025-04-08 17-00-00
tag: Operating System
---

We’ll examine a different type of scheduler known as a **proportional-share** scheduler, also sometimes referred to as a **fair-share** scheduler. Proportional-share is based around a simple concept: instead of optimizing for turnaround or response time, a scheduler might instead try to guarantee that each job obtain a certain percentage of CPU time. An example of it is known as **lottery scheduling**.

Underlying lottery scheduling is one very basic concept: **tickets**, which are numbers used to represent the share of a resource that a process should receive.  Lottery scheduling achieves this probabilistically (but not deterministically) by holding a lottery every so often (say, every time slice). The scheduler then picks a winning ticket within the total tickets.

Imagine two processes, A and B, and further that A has 75 tickets while B has only 25. Assuming A holds tickets 0 through 74 and B 75 through 99. The scheduler picks a number from 0 to 99 and the process which holds that ticket will run.  

Here is an example of output: 63 85 70 39 76 17 29 41 36 39 10 99 68 83 63 62 43 0 49 12.

In our example above, B only gets to run 4 out of 20 time slices (20%), instead of the desired 25% allocation. However, the longer these two jobs compete, the more likely they are to achieve the desired percentages.

**Ticket Concurrency** allows a user with a set of tickets to allocate tickets among their own jobs in whatever currency they would like. Then the system then automatically converts these tickets into the correct global value.

For example, assume users A and B have each been given 100 tickets. User A is running two jobs, A1 and A2, and gives them each 500 tickets in A’s currency. User B is running only 1 job and gives it 10 tickets. The system converts A1’s and A2’s allocation from 500 each in A’s currency to 50 each in the global currency; similarly, B1’s 10 tickets is converted to 100 tickets.

Another useful mechanism is **ticket transfer.** With transfers, a process can temporarily hand off its tickets to another process. 

This ability is especially useful in a **client/server setting**. When server is doing the job from the client, the client can pass its tickets to the server to speed up. When finished, the server transfer the tickets back the client. 

With **ticket inflation**, a process can temporarily raise or lower the number of tickets it owns without communicating with any other processes. It can only be applied in an environment where a group of processes trust one another. Otherwise, one process could give it a vast number of tickets and take over the CPU.

The implementation of lottery scheduling is very simple. All you need is: 

- a good random number generator to pick the winning ticket
- a data structure to track the processes of the system (e.g., a list)
- the total number of tickets

Let’s assume we keep the processes in a list. Here is an example comprised of three processes, A, B, and C, each with some number of tickets.

To make a scheduling decision, we first have to pick a random number (the winner) from the total number of tickets (400). Let’s say we pick the number 300. Then, we simply traverse the list, with a simple counter to add ticket number of each process. If the sum exceeds winner, then we run the current process. When we add the ticket of C to the sum, counter is update to 400 which is greater than 300, so we run process C. To make this process most efficient, we should sort the list from the highest number of tickets to the lowest.

While randomness gets us a simple scheduler, it occasionally will not deliver the exact right proportions, especially over short time scales. For this reason, Waldspurger invented **stride scheduling**, a deterministic fair-share scheduler.

- Each job in the system divides the total ticket number by its own ticket number to get a **stride**.
- Every time a process runs, we will increment a counter for it (called its **pass value**) by its stride to track its global progress.
- All processes  have pass values initially at 0.
- At any given time, pick the process to run that has the lowest pass value so far. If the pass values are equally low, we pick a process randomly.

Assume the system has jobs A, B, and C, with 100, 50, and 250 tickets. The stride values for A, B, and C are: 100, 200, and 40. We randomly pick A to run. A runs; when finished with the time slice, we update its pass value to 100. Then we run B whose pass value is updated to 200. Finally, we keep running C until its pass value exceeds 100. 

However, lottery scheduling has one nice property that stride scheduling does not: no global state. It’s hard to set the pass value of a new job which enters in the middle of our stride scheduling. If it’s pass value is set to 0, it will monopolize the CPU as its stride is 0. In this way, lottery makes it much easier to incorporate new processes in a sensible manner.

Despite these earlier works in fair-share scheduling, the current Linux implements a new fair scheduler,  the **Completely Fair Scheduler** (or CFS) in a highly efficient and scalable manner. 

Its goal is simple: to fairly divide a CPU evenly among all competing processes. It does so through a simple counting-based technique known as **virtual runtime** (vruntime).

1. In the most basic case, each process’s vruntime increases at the same rate, in proportion with physical (real) time. 
2. When a scheduling decision occurs, CFS will pick the process with the lowest `vruntime` to run next.

The tension here is clear: if CFS switches too often, fairness is increased but at the cost of performance. 

CFS manages this tension through two control parameters.

One is `sched_latency`. A typical `sched_latency` value is 48 (milliseconds); CFS divides this value by the number (n) of processes running on the CPU to determine the time slice for a process.

or example, if there are n = 4 processes running, CFS arrives at a per-process time slice of 12. CFS then schedules the first job and runs it until it has used 12ms of (virtual) runtime, and then checks to see if there is a job with lower `vruntime` to run instead. In this case, there is, and CFS would switch to other jobs, and so forth.

But what if there are “too many” processes running? To address this issue, CFS adds another parameter, `min_granularity`, which is usually set to a value like 6ms. CFS will never set the time slice of a process to less than this value.

CFS utilizes a periodic timer interrupt (e.g., every 1ms) to wake up and determine if the current job has reached the end of its run. A job may have a time slice that is not a perfect multiple of the timer. However, CFS tracks `vruntime` precisely, which means that over the long haul, it will eventually approximate ideal sharing of the CPU.

Figure below shows an example where the four jobs (A, B, C, D) each run for two time slices in this fashion; two of them (C, D) then complete, leaving just two remaining, which then each run for 24ms in round-robin fashion.

CFS also enables controls over process priority through a classic UNIX mechanism known as the **nice** level of a process. The nice parameter can be set anywhere from -20 to +19 for a process, with a default of 0. Positive nice values imply lower priority and negative values imply higher priority.

CFS maps the nice value of each process to a weight. 

```bash
static const int prio_to_weight[40] = {
	/* -20 */ 88761, 71755, 56483, 46273, 36291,
	/* -15 */ 29154, 23254, 18705, 14949, 11916,
	/* -10 */ 9548, 7620, 6100, 4904, 3906,
	/* -5 */ 3121, 2501, 1991, 1586, 1277,
	/* 0 */ 1024, 820, 655, 526, 423,
	/* 5 */ 335, 272, 215, 172, 137,
	/* 10 */ 110, 87, 70, 56, 45,
	/* 15 */ 36, 29, 23, 18, 15,
};
```

The formula used to compute the time slice is as follows, assuming n processes: 

$$
\text{time slice}_k = \frac{\text{weight}}{\sum_{i=0}^{n-1}\text{weight}_i} \cdot \text{sched latency} 

$$

Here is the new formula to calculate `vruntime`, which takes the actual run time that process i has accrued and scales it inversely by the weight of the process, by dividing the default weight of 1024 by its weight.

$$
\text{vruntime}_i = \text{vruntime}_i+ \frac{\text{weight}_0}{\text{weight}_i} \cdot \text{runtime}_i 

$$

Assume there are two jobs, A and B. A is assigned to a nice value of -5 and B is assigned to default value. This means the weight of A is is 3121 whereas the weight of B is 1024. A’s time slice is about 36ms, and B’s about 12ms. A’s `vruntime` will accumulate at one-third the rate of B’s.

Modern systems sometimes are comprised of 1000s of processes, and thus searching through a long-list every so many milliseconds is wasteful. CFS addresses this by keeping processes in a r**ed-black tree**. CFS does not keep all processes in this structure; rather, only running processes are kept therein. If a process goes to sleep, it is removed from the tree and kept track of elsewhere

Imagine two processes, A and B, one of which (A) runs continuously, and the other (B) which has gone to sleep for a long period of time (say, 10 seconds). When B wakes up, its vruntime will be 10 seconds behind A’s and thus, B will now monopolize the CPU for the next 10 seconds while it catches up, effectively starving A.  CFS handles this case by **altering** the `vruntime` of a job A when it wakes up. Specifically, CFS sets the vruntime of that job to the minimum value found in the tree. But this approach comes not without a cost: jobs that sleep for short periods of time frequently do not ever get their fair share of the CPU.

All theses fair-share schedulers have the common problems:

1. Jobs that perform I/O occasionally may not get their fair share of CPU.
2. They leave open the hard problem of ticket or priority assignment.

The good news is that there are many domains in which these problems are not the dominant concern, and proportional-share schedulers are used to great effect. For example, in a virtualized data center (or **cloud**), where you might like to assign one-quarter of your CPU cycles to the Windows VM and the rest to your base Linux installation