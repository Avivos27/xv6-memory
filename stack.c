/*
 * File:    stack.c
 * Author:  zentut.com
 * Purpose: stack source code file
 */
#include "types.h"
#include "defs.h"
/*
	initialize stack pointer
*/
void initStack(uint *top)
{
    *top = 0;
}

/*
	push an element into stack
	precondition: the stack is not full
*/
void push(uint *s,uint last, uint element)
{	
	//cprintf("element: %d\n", element);
	//cprintf("last: %d\n", last);
	if(last < 15){
    	s[last] = element;
    }
    else
    	panic("panic in stack push");
}
/*
	remove an element from stack
	precondition: stack is not empty
*/
uint pop(uint *s,uint *last)
{	
    cprintf("NOT GOOD!!\n");
	return 0;
}
/*
	return 1 if stack is full, otherwise return 0
*/
int full(uint *top,const int size)
{
    return *top == size ? 1 : 0;
}
/*
	return 1 if the stack is empty, otherwise return 0
*/
int empty(uint *top)
{
    return top == 0 ? 1 : 0;
}

int removeItem(uint *s,uint last, uint element){
    int i=0;
    // cprintf("element: %d\n", element);
    for(;i<last+1;i++){
    	if(s[i] == element)
    		break;
    }
    int ans = i;
    if(i==last+1)
    	panic("removeItem: element not found");


    for(;i<last;i++){
    	s[i] = s[i+1];
    }
    return ans;
}

uint popLast(uint *s,uint last){
    return s[last-1];
}

uint popFirst(uint *s,uint last){
    
    uint elem = s[0];
    removeItem(s,last,elem);
    return elem;
}

/*
    display stack content
*/
// void display(int *s,int *top)
// {
//     printf(1,"Stack: ");
//     int i;
//     for(i = 0; i < *top; i++)
//     {
//         printf(1,"%d ",s[i]);
//     }
//     printf(1,"\n");
// }
