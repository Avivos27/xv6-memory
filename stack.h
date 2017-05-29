
/*
 * File:   stack.h
 * Author: zentut.com
 * Purpose: stack header file
 */
#ifndef STACK_H_INCLUDED
#define STACK_H_INCLUDED

void push(uint *s,uint last, uint element);
uint pop(uint *s,uint *top);
int full(uint *top,const int size);
int empty(uint *top);
void initStack(uint *top);
int removeItem(uint *s,uint last, uint element);
uint popLast(uint *s,uint last);
uint popFirst(uint *s,uint last);

#endif // STACK_H_INCLUDED
