#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
  char *s, *last;
  int i, off;
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
  if((ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
  if(elf.magic != ELF_MAGIC)
    goto bad;

  if((pgdir = setupkvm()) == 0)
    goto bad;
#ifndef NONE
  // reset all paging fields
  proc->numPhysPages = 0;
  proc->numStoredPages = 0;
  proc->last = 0;
  for(int i=0;i<MAX_PSYC_PAGES;i++){
    proc->storedPages[i].inUse = 0;
    proc->physPages[i] = -1;
  }
  if(proc->swapFile){
    // char buf[MAX_PSYC_PAGES*PGSIZE];
    // writeToSwapFile(proc,buf,0,MAX_PSYC_PAGES*PGSIZE);
    removeSwapFile(proc);
  }
  createSwapFile(proc);
#endif



  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  proc->pgdir = pgdir;
  // cprintf("exec pid: %d: oldpgdir: %d newpgdir: %d\n",proc->pid,oldpgdir,pgdir);
  proc->sz = sz;
  proc->tf->eip = elf.entry;  // main
  proc->tf->esp = sp;
  switchuvm(proc);
  freevm(oldpgdir,proc,0);
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir,proc,1);
  if(ip){
    iunlockput(ip);
    end_op();
  }
  return -1;
}
