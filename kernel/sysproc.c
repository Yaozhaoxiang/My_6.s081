#include "types.h"
#include "riscv.h"
#include "param.h"
#include "defs.h"
#include "date.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0)
    return -1;
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0)
    return -1;
  return wait(p);
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;


  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}


#ifdef LAB_PGTBL
int
sys_pgaccess(void)
{
  // lab pgtbl: your code here.
  //获取参数
  // 虚拟地址
    uint64 vaddr;
    if(argaddr(0,&vaddr)<0)
        return -1;
  //数量
    int num;
    if(argint(1,&num)<0)
        return -1;
  //储存地址
    uint64 uaddr;  
    if(argaddr(2,&uaddr)<0)
        return -1;   

    struct proc *p = myproc();
    uint64 mask=0;
    // printf("sys_pgaccess: %d %d %d\n",vaddr,num,uaddr);
    for(int i=0;i<num;i++)
    {
        pte_t* pte = walk(p->pagetable,vaddr+i*PGSIZE,0);
        if(pte && (*pte & PTE_A))
        {
            mask = mask | (1<<i);
            // printf("mask=%d\n",mask);
            *pte = (*pte) & (~PTE_A);
        } 
    }
    if(copyout(p->pagetable,uaddr,(char*)&mask,sizeof(mask))<0)
        return -1;
    // printf("sys_pgaccess: %d %d %d\n",vaddr,num,uaddr);
    return 0;
}
#endif

uint64
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
