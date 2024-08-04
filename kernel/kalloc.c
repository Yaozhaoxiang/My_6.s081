// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct kmem{
  struct spinlock lock;
  struct run *freelist;
} ;

struct kmem cpu_freelists[NCPU];
void
kinit()
{
//   initlock(&kmem.lock, "kmem");
for(int i=0;i<NCPU;++i)
{
    initlock(&cpu_freelists[i].lock, "kmem_freelist");
}
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;
push_off();
int c=cpuid();
pop_off();
struct kmem *f1=&cpu_freelists[c];
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&f1->lock);
  r->next = f1->freelist;
  f1->freelist = r;
  release(&f1->lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
// void *
// kalloc(void)
// {
//   struct run *r;

//   acquire(&kmem.lock);
//   r = kmem.freelist;
//   if(r)
//     kmem.freelist = r->next;
//   release(&kmem.lock);

//   if(r)
//     memset((char*)r, 5, PGSIZE); // fill with junk
//   return (void*)r;
// }
void *
kalloc(void)
{
    struct run *r;
  //获取当前cpu的空闲链表
push_off();
int c=cpuid();
pop_off();
struct kmem *f1=&cpu_freelists[c];

  acquire(&f1->lock);
  r = f1->freelist;
if(r)//当前链表不为空
{
    f1->freelist=r->next;
    release(&f1->lock);
    memset((char*)r, 5, PGSIZE);
    return (void*)r;
}
else //当前链表为空
{
    //如果当前链表为空，则从其他链表拿取
    for(int i=0;i<NCPU;++i)
    {
        if(i==c) continue; //跳过当前cpu

        struct kmem *other_f1=&cpu_freelists[i];
        acquire(&other_f1->lock);

        if(other_f1->freelist)
        {
            //从其他链表获取一个块
            struct run* block=other_f1->freelist;
            other_f1->freelist=block->next;
     
            release(&other_f1->lock);
            release(&f1->lock);
            memset((char*)block, 5, PGSIZE);
            return (void*)block;
        }
        release(&other_f1->lock);
    }
    // 如果所有链表都为空，释放锁并返回 0
    release(&f1->lock);
    return (void*)0;
}
}

