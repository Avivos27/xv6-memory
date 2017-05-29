#include "param.h"
#include "types.h"
#include "defs.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "elf.h" 

extern char data[];  // defined by kernel.ld
pde_t *kpgdir;  // for use in scheduler()
struct segdesc gdt[NSEGS];



// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
  struct cpu *c;

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);

  lgdt(c->gdt, sizeof(c->gdt));
  loadgs(SEG_KCPU << 3);
  
  // Initialize cpu-local storage.
  cpu = c;
  proc = 0;
}


// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}

static int choosePTESwap(){
  uint addr = -1;
  #ifdef LIFO
    addr = popLast(proc->physPages,proc->last);
    proc->last--;
  #endif

  #ifdef SCFIFO
    while(1){
      addr = popFirst(proc->physPages,proc->last);
      proc->last--;
      pte_t* pte = walkpgdir(proc->pgdir,(void*)addr,0);
      if(*pte == 0)
        panic("SCFIFO choose pte = 0");
      else{
        if(*pte & PTE_A){
          *pte &= ~PTE_A; 
          push(proc->physPages,proc->last,addr);
          proc->last++;
        }
        else{
          break;
        }
      }
    }
  #endif

  #ifdef LAP

    int i=1;
    int j=0;
    int min = proc->accessCounts[0];
    for(;i<MAX_PSYC_PAGES;i++){
      if(min >= proc->accessCounts[i]){
        min = proc->accessCounts[i];
        j=i;
      }
    }
    addr = proc->physPages[j];

    for(;j<14;j++){
      proc->physPages[j] = proc->physPages[j+1];
      proc->accessCounts[j] = proc->accessCounts[j+1];
    }
    proc->last--;

  #endif

    if(addr<0)
      panic("choose pte swap failed");
  return addr;
} 


// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

// There is one page table per process, plus one that's used when
// a CPU is not running any process (kpgdir). The kernel uses the
// current process's page table during system calls and interrupts;
// page protection bits prevent user code from using the kernel's
// mappings.
// 
// setupkvm() and exec() set up every page table like this:
//
//   0..KERNBASE: user memory (text+data+stack+heap), mapped to
//                phys memory allocated by the kernel
//   KERNBASE..KERNBASE+EXTMEM: mapped to 0..EXTMEM (for I/O space)
//   KERNBASE+EXTMEM..data: mapped to EXTMEM..V2P(data)
//                for the kernel's instructions and r/o data
//   data..KERNBASE+PHYSTOP: mapped to V2P(data)..PHYSTOP, 
//                                  rw data + free physical memory
//   0xfe000000..0: mapped direct (devices such as ioapic)
//
// The kernel allocates physical memory for its heap and for user memory
// between V2P(end) and the end of physical memory (PHYSTOP)
// (directly addressable from end..P2V(PHYSTOP)).

// This table defines the kernel's mappings, which are present in
// every process's page table.
static struct kmap {
  void *virt;
  uint phys_start;
  uint phys_end;
  int perm;
} kmap[] = {
 { (void*)KERNBASE, 0,             EXTMEM,    PTE_W}, // I/O space
 { (void*)KERNLINK, V2P(KERNLINK), V2P(data), 0},     // kern text+rodata
 { (void*)data,     V2P(data),     PHYSTOP,   PTE_W}, // kern data+memory
 { (void*)DEVSPACE, DEVSPACE,      0,         PTE_W}, // more devices
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
}

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
  kpgdir = setupkvm();
  switchkvm();
}

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(v2p(kpgdir));   // switch to the kernel page table
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  pushcli();
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
  cpu->gdt[SEG_TSS].s = 0;
  cpu->ts.ss0 = SEG_KDATA << 3;
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  lcr3(v2p(p->pgdir));  // switch to new address space
  popcli();
}

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
}

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
}

int
writePTEToFile(pte_t *pte) {
  int i = 0;
  
  for(i=0;i < MAX_PSYC_PAGES;i++){
    if(!proc->storedPages[i].inUse){
      proc->storedPages[i].inUse = 1;
      break;
    }
  }

  if(i==MAX_PSYC_PAGES)
    panic("MAX PAGES");

  uint pa = PTE_ADDR(*pte);
  uint va = (uint)p2v(pa);
  // cprintf("%d. Writing to swap file %d\n",proc->pid,va);
  writeToSwapFile(proc, (char*)va, i*PGSIZE, PGSIZE);
  kfree((char*)va);

  *pte |= PTE_PG;
  *pte &= ~PTE_P;
  
  proc->numPhysPages--;
  proc->numStoredPages++;
  proc->numPagedOut++;
  return i;
}

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
    #ifndef NONE
      if (proc->pid > 2){
        if(proc->numPhysPages >= 15){
            pte_t* pte; 
            uint addr = choosePTESwap();
            pte = walkpgdir(proc->pgdir, (void*)addr, 0);
            int index = writePTEToFile(pte);
            proc->storedPages[index].inUse = 1;
            proc->storedPages[index].va = addr;
            
        }
      }
    #endif
    mem = kalloc();
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz,proc,1);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
    #ifndef NONE
      proc->numPhysPages++;
      // cprintf("%d. Writing to memory %d\n",proc->pid,a);
    
      push(proc->physPages,proc->last,a);
      proc->last++;
    #endif
  }
  return newsz;
}



// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz,struct proc* child,int delete)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a += (NPTENTRIES - 1) * PGSIZE;
    else if((*pte & PTE_P) != 0){ // page is present
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");

      char *v = p2v(pa);
      kfree(v);
       // cprintf("deallocating %d == %d \n",proc->pgdir,pgdir);
      #ifndef NONE
        if (delete){
          int index;
          index = removeItem(child->physPages,child->last, a);
          child->last--;
          child->accessCounts[index] = 0;
          child->numPhysPages--;
          // cprintf("%d. emptied page %d from memory %d\n",child->pid,a,child->numPhysPages);
        }
      #endif
      
      *pte = 0;
    }


    // else if(*pte & PTE_PG){ // page isn`t present and in secondary storage
    //   int i;
    //   cprintf("dealocate looking for addr = %d\n",a);
    //   for(i=0;i<MAX_PSYC_PAGES;i++){
    //     if(a == proc->storedPages[i].va)
    //       break;
    //   }

    //   if(i==MAX_PSYC_PAGES){
    //     cprintf("pages:\n");
    //     for(i=0;i<MAX_PSYC_PAGES;i++){
    //       cprintf("%d\n",proc->storedPages[i].va);  
    //     }
    //     panic("deallocuvm - page not found");
    //   }


    //   proc->storedPages[i].inUse = 0;
    //   proc->numStoredPages--;
    //   cprintf("%d. emptied page %d from file system %d\n",proc->pid,a,proc->numPhysPages);
    //   *pte = 0;
    // }
  }
  return newsz;
}

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir,struct proc* child,int delete)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0,child,delete);
  for(i = 0; i < NPDENTRIES; i++){
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
}

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
  *pte &= ~PTE_U;
}

//Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz,struct proc* child)
{
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P) && !(*pte & PTE_PG))
      panic("copyuvm: page not present");
    if (*pte & PTE_PG) {
      // cprintf("%d. copyuvm from swap file %d\n",proc->pid,i); // TODO delete
      flags = PTE_FLAGS(*pte);
      pte = walkpgdir(d, (void*)(PGROUNDDOWN((uint) i)), 1);
      *pte |= flags;
      continue;
    }
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    // cprintf("%d. copyuvm from memory %d\n",proc->pid,i); 
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;

bad:
  freevm(d,child,1);
  return 0;
}





//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)p2v(PTE_ADDR(*pte));
}

// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}

int swapPages(uint addr){

  pte_t* pte_file = (pte_t*)walkpgdir(proc->pgdir, (void*)addr, 0);
  // cprintf("%d. got to swapPages with addr %d\n",proc->pid,addr);
  if (strncmp(proc->name, "init",strlen(proc->name)) == 0 || strncmp(proc->name, "sh",strlen(proc->name)) == 0) {
    return 1;
  }

  char* allocPage = kalloc();
  if(allocPage == 0){
    panic("kalloc problem in swapPAges");
  }

  //char buf[PGSIZE];
  pte_t *pte_ram;
  int i = 0;
  // cprintf("%d. looking for %d in swap file\n",proc->pid,addr);
  for(i=0;i < MAX_PSYC_PAGES;i++){
    if(proc->storedPages[i].va == addr)
      break;
  }

  if(i==MAX_PSYC_PAGES)
    panic("MAX PAGES");

  
  
  int address = choosePTESwap();
  // cprintf("%d. swapPages from memory %d\n",proc->pid,address);
  pte_ram = walkpgdir(proc->pgdir, (void*)address, 0);
  
  readFromSwapFile(proc, allocPage, i*PGSIZE, PGSIZE);
  *pte_file = v2p(allocPage) | PTE_W | PTE_U | PTE_P;
  writeToSwapFile(proc, (char*)p2v(PTE_ADDR(*pte_ram)), i*PGSIZE, PGSIZE);
  kfree((char*)p2v(PTE_ADDR(*pte_ram)));
  *pte_ram |= PTE_PG;
  *pte_ram &= ~PTE_P;
  push(proc->physPages,proc->last,addr);
  proc->last++;
  proc->storedPages[i].va = address;
  //cprintf("=== %d === \n",p2v(PTE_ADDR(*pte_ram)));
  // cprintf("reading from swap\n");
  // cprintf("finished reading from swap\n");
    
  // memmove((void*)PTE_ADDR(*pte_file), (void*)buf, PGSIZE);
  

  // lapiceoi();
  lcr3(v2p(proc->pgdir));
  return 1;
}

//PAGEBREAK!
// Blank page.
//PAGEBREAK!
// Blank page.
//PAGEBREAK!
// Blank page.

