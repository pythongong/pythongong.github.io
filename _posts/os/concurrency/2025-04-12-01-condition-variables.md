---
layout: post
title:  "Condition Variables"
date:   2025-04-12
tag: Operating System
---

There are many cases where a thread wishes to check whether a condition is true before continuing its execution. For example, a parent thread might wish to check whether a child thread has completed before continuing. We could try using a shared variable. This solution will generally work, but it is hugely inefficient as the parent spins and wastes CPU time. What we would like here instead is some way to put the parent to sleep until the condition we are waiting for comes true. It uses a **condition variable** that is an explicit queue that threads can put themselves on when waiting on the condition. When the condition comes true, condition variable wakes one or more of those waiting threads by signaling on the condition.

A condition variable has two operations associated with it: wait() and signal(). The wait() call is executed when a thread wishes to put itself to sleep. The signal() call is executed when the condition has been changed and a thread needs wake a sleeping thread.

```c
pthread_cond_wait(pthread_cond_t *c, pthread_mutex_t *m);
pthread_cond_signal(pthread_cond_t *c);
```

The responsibility of wait() is to release the lock and put the calling thread to sleep (atomically).  When the thread wakes up, it must re-acquire the lock before returning to the caller.

We use the conditional variable to solve a synchronization problem, known as the **producer/consumer** problem, or sometimes as the bounded buffer problem, which was first posed by Dijkstra. Imagine one or more producer threads and one or more consumer threads. Producers generate data items and place them in a buffer; consumers grab said items from the buffer and consume them in some way. 

This arrangement occurs in many real systems. For example, in a multi-threaded web server, a producer puts HTTP requests into a the bounded buffer ; consumer threads take requests out of this queue and process them.

A UNIX pipe is another example. When executing the command `grep foo file.txt | wc -l`, the grep process is the producer; the `wc` process is the consumer; between them is an in-kernel bounded buffer. 

We use if to check if the condition is fufilled at the begining

```c
void *producer(void *arg) {
	......
	if (count == 1)
		Pthread_cond_wait(&cond, &mutex);
	......
	Pthread_cond_signal(&cond);
	......
}

void *consumer(void *arg) {
	......
	if (count == 0)
		Pthread_cond_wait(&cond, &mutex);
	......
	Pthread_cond_signal(&cond);
	......
}
```
When a producer wants to fill the buffer, it waits for it to be empty. The consumer has the exact same logic, but waits for a different condition: fullness. Suppose we have one producer thread P1 and two consumers C1 and C2. When P1 signals that a buffer has been filled, C1 wakes up and is now able to run. Before C1 ever ran, C2 also wakes up and sneaks in. If C2 consumes the value in the buffer, there are no buffers left for C1 to consume. This interpretation of what a signal means is often referred to as **Mesa semantics**; he contrast, referred to as **Hoare semantics**, is harder to build but provides a stronger guarantee that the woken thread will run immediately upon being woken

Fortunately, this fix is easy: change the if to a while. 

```c
void *producer(void *arg) {
	......
	while (count == 1)
		Pthread_cond_wait(&cond, &mutex);
	......
	Pthread_cond_signal(&cond);
	......
}

void *consumer(void *arg) {
	......
	while (count == 0)
		Pthread_cond_wait(&cond, &mutex);
	......
	Pthread_cond_signal(&cond);
	......
}
```

In our example above, after C2 has consumed the buffer, C1 will recheck the state of the shared variable and find the buffer is empty. C1 then sleeps again. 

For Mesa semantics, a simple rule to remember with condition variables is to always use while loops.

But another problem occurs. As we don’t which thread will wake up, it’s possible for C1 to wake C2 after C1 has consumed the buffer. C2 goes back to sleep without waking the producer P1. All three threads are left sleeping. 

The solution here is: use two condition variables. Producer threads wait on the condition empty, and signals fill. Conversely, consumer threads wait on fill and signal empty.  And to support more producers and consumers, we make sure that a producer only sleeps if all buffers are currently filled ; similarly, a consumer only sleeps if all buffers are currently empty.

```c

#define MAX 4;
int count = 0;
int buffer[MAX];
int fill_ptr = 0;
int use_ptr = 0;

void put(int value) {
    buffer[fill_ptr] = value;
    fill_ptr = (fill_ptr + 1) % max;
    count++;
}

int get() {
    int tmp = buffer[use_ptr];
    use_ptr = (use_ptr + 1) % max;
    count--;
    return tmp;
}

void *producer(void *arg) {
	......
	while (count == MAX)
		Pthread_cond_wait(&cond, &mutex);
	put();
	Pthread_cond_signal(&cond);
	......
}

void *consumer(void *arg) {
	......
	while (count == 0)
		Pthread_cond_wait(&cond, &mutex);
	int temp = get();
	Pthread_cond_signal(&cond);
	......
}
```

We can also solve the problem by waking up all waiting threads. Such a condition is called a **covering condition**. The cost is that we might needlessly wake up many other waiting threads