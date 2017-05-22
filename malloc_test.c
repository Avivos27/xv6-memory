#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < 40; i++){
  	malloc(4096);
  }
  printf(1,"finished malloc test - shit in your face\n");

    
  exit();
}
