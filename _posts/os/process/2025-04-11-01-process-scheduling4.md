---
layout: post
title:  "Process Scheduling(4): Multiprocessor Scheduling"
date:   2025-04-11
tag: Operating System
---

If our system has multiple CPUs, each of them will have its own hardware cache and he problem of **cache coherence** occurs. For example, CPU 1 caches the value at address A. Then CPU 1 the updates the value. As it has cached the old value, so it first updates the cache. Before it updates the main memory, the OS decides to run the program on CPU 2. CPU 2 will read the old value at address A. 

In addition, when a process running on a particular CPU, it builds up a fair bit of state in the caches and TLBs of the CPU.  Thus, this process will run faster on this CPU the next time it runs. This issue is known as **cache affinity**. 

The most basic scheduling approach for a multi-processor architecture is putting all jobs that need to be scheduled into a single queue; we call this **single queue multiprocessor scheduling** or SQMS for short.

It’s simple to implement, but it will have two main problems. The first issue is a lack of scalability. This queue must have some locks to make the proper outcome arise. However, the locks can greatly reduce performance. You can use a lock-free data structure but it’s very complex to implement. 

The second main problem is cache affinity. Because each CPU simply picks the next job to run from the globally shared queue, each job ends up bouncing around from CPU to CPU. The scheduler provides affinity for some jobs, but moves others around to balance load.  

Because of these problems, we can use a **multi-queue multiprocessor scheduling**(MQMS) instead.
When a job enters the system, it is placed on exactly one scheduling queue. Then it is scheduled essentially independently, thus avoiding the problems of  synchronization found in the single-queue approach. 

However, we have a new problem: **load imbalance**. For example, assume we have a system where there are just two CPUs (labeled CPU 0 and CPU 1), and some number of jobs enter the system: A, B, C, and D for example. If the scheduler allocates A, B for CPU 1 and C, D for CPU 2. When C has finished, we now have the following scheduling queues:

![image.png]({{"/assets/images/os/process/multi-scheduling1.png" | relative_url}})

If we then run our round-robin policy on each queue of the system, we will see this resulting schedule:

![image.png]({{"/assets/images/os/process/multi-scheduling2.png" | relative_url}})

As you can see from this diagram, A gets twice as much CPU as B and D. Even worse if A has finished, CPU 0 will be idle. One solution is to move jobs around, a technique which we refer to as **migration**. When CPU 0 is idle, the OS should simply move one of B or D to CPU 0.
![image.png]({{"/assets/images/os/process/multi-scheduling3.png" | relative_url}})

In our earlier example, where A was left alone on CPU 0 and B and D were alternating on CPU 1, a single migration does not solve the problem.  One possible solution is to keep switching jobs, as we see in the following timeline. In the figure, first A is alone on CPU 0, and B and D alternate on CPU 1. After a few time slices, B is moved to compete with A on CPU 0.

Of course, many other possible migration patterns exist. But now for the tricky part: how should the system decide to enact such a migration? One basic approach is to use a technique known as **work stealing**. With a work-stealing approach, a (source) queue that is low on jobs will occasionally peek at another (target) queue, to see how full it is. If the target queue is (notably) more full than the source queue, the source will “steal” one or more jobs from the target to help balance load. However, finding the right threshold, about how often should the source queue peek at target queue, remains a black art.