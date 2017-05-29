#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "memlayout.h"
#include "mmu.h"

#define NUM_OF_PAGES 20
char* pages[NUM_OF_PAGES];

volatile int
main(int argc, char *argv[])
{
  int i = 0;
  int j = 0;
  printf(1,"Allocating pages...\n");
  for (i = 0; i < NUM_OF_PAGES ; i++)
  {
    pages[i] = sbrk(PGSIZE);
    pages[i][0] = i;

  }

  printf(1, "\nforking...\n");  
  if (fork()) {
    wait();
    printf(1, "\nfather thread data:\n");

    for (i = 0; i < NUM_OF_PAGES ; i++)
    {
      for (j = 0; j < i; j++) {
        printf(1, "%d, ",pages[j][0]);
      }
      printf(1, "\n");
    }
    printf(1, "\n");
    exit();
  }
  printf(1,"child is modifying data\n");
  for (i = 0; i < NUM_OF_PAGES ; i++)
  {
    for (j = 0; j < i; j++) {
      pages[j][0]= (j*2);
    }
  }


  printf(1, "\nchild thread data:\n");

  for (i = 0; i < NUM_OF_PAGES ; i++)
  {
    for (j = 0; j < i; j++) {
      printf(1, "%d, ",pages[j][0]);
    }
    printf(1, "\n");
  }
  printf(1, "\n");



  exit();
  return 0;
}
