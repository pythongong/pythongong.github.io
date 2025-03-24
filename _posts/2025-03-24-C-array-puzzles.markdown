---
layout: post
title:  "C Array Puzzles"
date:   2025-03-24
tag: C
---


C doesn’t check the boundary of the array. We are allowed to access or modify illegal memory by accessing an array out of bounds.

For example, 

```c
int array[10];
array[-4]=77;
array[25]=25;
printf("%p\n", &array[0]);
printf("%p\n", &array[-4]);
printf("%p\n", &array[25]);
```

This code can be compiled and may not crash. 

When you access array[i],  you access its value by its pointer. The square bracket syntax []  multiplies the index by the element size, adds the resulting offset to the base address, and finally dereferences the resulting pointer to get to the desired value.

![Alt Text]({{"/assets/images/C-array-puzzles01.png"  | relative_url }})


Print their addresses

```c
printf("%p\n", &array[0]);
printf("%p\n", &array[-4]);
printf("%p\n", &array[25]);
```

The output on my computer is

0x7fffffffde20
0x7fffffffde10 = 0x7fffffffde20 + (-4)*4
0x7fffffffde84 = 0x7fffffffde20 + 25*4

For (intArray + 3), intArray is of pointer type int* and 3 is of type int, so it equals to the pointer to intArray[3]. Another example is

```c
int *p;
p = p + 12;
```

It adds 12*4 = 48 to p.

We can also apply ++ syntax on pointer type to copy an array to anoter.

```c
void strcpy1(char dest[], const char source[])
{
	int i;
	for (i = 0; source[i] != '\0'; i++) {
		dest[i] = source[i];
	}
	dest[i] = '\0'; // don't forget to null-terminate!
}

// Move the assignment into the test
void strcpy2(char dest[], const char source[])
{
	int i = 0;
	while ((dest[i] = source[i]) != '\0')
	i++;
}
// Get rid of i and just move the pointers.
// Relies on the precedence of * and ++.
void strcpy3(char dest[], const char source[])
{
	while ((*dest++ = *source++) != '\0') ;
}
// Rely on the fact that '\0' is equivalent to FALSE
void strcpy4(char dest[], const char source[])
{
	while (*dest++ = *source++) ;
}
```

The base address of the array is a const pointer which cannot be changed in the code.

```c
int intArray[100]
int *intPtr;
int i;

intArray = NULL; // no, cannot change the base addr ptr
intArray = &i; // no
intArray = intArray + 1; // no
intArray++; // no

intPtr = intArray; // ok, intPtr is a regular pointer which can be changed
// here it is now pointing to same array intArray is
intPtr++; // ok, intPtr can still be changed (and intArray cannot)
intPtr = NULL; // ok
intPtr = &i; // ok

foo1(intArray); // ok, intArray can also be passed to foo2
foo2(intPtr); // ditto

```

Array parameters are passed as pointers. This two function mean the same for the compiler. If the pointer coming in is going to be treated as the base address of the array, then use []. Otherwise, the * notation is more appropriate.

```c
void foo1(int arrayParam[])
{
	arrayParam = NULL; // Silly but valid. Just changes the local pointer
}

void foo2(int *arrayParam)
{
	arrayParam = NULL; // ditto
}

```

You can also cast the type of array, but it will invoke problems.

```c
int array[5];
array[3] = 128;
printf("%d\n", array[3]);
```

We first assign 128 at the address of array[3].

![Untitled]({{"/assets/images/C-array-puzzles02.png"  | relative_url }})

Then we cast the array from int to short.

```c
((short*) array)[7] = 2;
printf("%d\n", array[3]);
```

It actually uses  the address between array[3] and array[4].

![Untitled]({{"/assets/images/C-array-puzzles03.png"  | relative_url }})

The output is neither 2 nor 128. The left half is 128 = 0000 0001 0000 0000 0000 0000 0000 0000 and the right half is  2 = 0100 0000 0000 0000 0000 0000 0000 0000. Combine them becomes 

$$
2^{17}+128=131200
$$

For this code

```c
((short*) (((char*) &array[1])+6))[3] = 100;
 printf("%d\n", array[4]);
```

It starts from the address of array[1] then add 6 bytes as char is 1 byte long. Then it adds 6 bytes as short is 2 bytes long. It finally gets the address of array[4].

![Untitled]({{"/assets/images/C-array-puzzles04.png"  | relative_url }})

The output is exactly 100.

This an example for void pointer

```c
void *ptr;
p = (char*)ptr + 4; 
```

It increments ptr by exactly 4.

```c
int *b;
b = malloc(sizeof(int) * 1000);
free(b);
```