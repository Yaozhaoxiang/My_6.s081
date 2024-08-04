// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.


#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"

#define NUM_BUCKETS 13

struct {
  struct spinlock lock;
  struct buf buf[NBUF];
  int size;
  // Linked list of all buffers, through prev/next.
  // Sorted by how recently the buffer was used.
  // head.next is most recent, head.prev is least.
  struct buf buckets[NUM_BUCKETS];
  struct spinlock locks[NUM_BUCKETS];
  struct spinlock hashlock;
}bcache;


// void
// binit(void)
// {
//   struct buf *b;

//   initlock(&bcache.lock, "bcache");

//   // Create linked list of buffers
//   bcache.head.prev = &bcache.head;
//   bcache.head.next = &bcache.head;
//   for(b = bcache.buf; b < bcache.buf+NBUF; b++){
//     b->next = bcache.head.next;
//     b->prev = &bcache.head;
//     initsleeplock(&b->lock, "buffer");
//     bcache.head.next->prev = b;
//     bcache.head.next = b;
//   }
// }

void
binit(void)
{
struct buf *b;

bcache.size=0;
initlock(&bcache.lock, "bcache");
initlock(&bcache.hashlock, "bcache_hash");
for(int i=0;i<NUM_BUCKETS;i++)
    initlock(&bcache.locks[i], "bcache_buckets");


for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->timestamp=0;
    b->refcnt = 0;
    initsleeplock(&b->lock, "buffer");

}

}


// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
// static struct buf*
// bget(uint dev, uint blockno)
// {
//   struct buf *b;

//   acquire(&bcache.lock);

//   // Is the block already cached?
//   for(b = bcache.head.next; b != &bcache.head; b = b->next){
//     if(b->dev == dev && b->blockno == blockno){
//       b->refcnt++;
//       release(&bcache.lock);
//       acquiresleep(&b->lock);
//       return b;
//     }
//   }

//   // Not cached.
//   // Recycle the least recently used (LRU) unused buffer.
//   for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
//     if(b->refcnt == 0) {
//       b->dev = dev;
//       b->blockno = blockno;
//       b->valid = 0;
//       b->refcnt = 1;
//       release(&bcache.lock);
//       acquiresleep(&b->lock);
//       return b;
//     }
//   }
//   panic("bget: no buffers");
// }

static struct buf*
bget(uint dev, uint blockno)
{
    int idx=hash(dev,blockno);
    struct buf *b;
    struct buf *pre, *minb=0, *minpre;
    uint mintimestamp;
    int i;

    acquire(&bcache.locks[idx]);
  // Is the block already cached?
  for(b = bcache.buckets[idx].next; b; b=b->next){
    if(b->dev == dev && b->blockno == blockno){
      b->refcnt++;

      release(&bcache.locks[idx]);
      acquiresleep(&b->lock);
      return b;
    }
  }

  // Not cached.
  // 如果有空闲的，则使用
  acquire(&bcache.lock);
  if(bcache.size < NBUF)
  {
    b = &bcache.buf[bcache.size++];
    release(&bcache.lock);
    b->dev = dev;
    b->blockno = blockno;
    b->valid = 0;
    b->refcnt = 1;
    b->next = bcache.buckets[idx].next;
    bcache.buckets[idx].next = b;
    release(&bcache.locks[idx]);
    acquiresleep(&b->lock);
    return b; 
  }
  release(&bcache.lock);
  release(&bcache.locks[idx]);

  // Not cached.
  // 如果没有空闲的，则选择一个最久没有访问的buf，清空返回
  //这时可能会出现一种情况，两个访问同一块的进程都到这里,其中一个先进去，获得buf，那么第二个进程
  //就不用再分配了，而是直接扫描自己的桶
  //所以为了解决这种问题，应该首先从自己的桶先访问
    acquire(&bcache.hashlock);
    for(i=0;i<NUM_BUCKETS;++i)
    {
        mintimestamp = -1; //最大值
        //先访问当前桶
        acquire(&bcache.locks[idx]);
        for(pre = &bcache.buckets[idx],b = pre->next; b; pre=b,b=b->next)
        {
            if(idx == hash(dev,blockno) && b->dev == dev && b->blockno == blockno)
            {
                b->refcnt++;
                release(&bcache.locks[idx]);
                release(&bcache.hashlock);
                acquiresleep(&b->lock);
                return b;
            }
            if(b->refcnt == 0 && b->timestamp < mintimestamp)
            {
                minb = b;
                minpre = pre;
                mintimestamp = b->timestamp;
            }
        }
        if(minb) //如果在其他桶找到了
        {
            minb->dev = dev;
            minb->blockno = blockno;
            minb->valid = 0;
            minb->refcnt = 1;
            if(idx != hash(dev,blockno))
            {
                minpre->next = minb->next;
                release(&bcache.locks[idx]);
                idx = hash(dev,blockno);
                acquire(&bcache.locks[idx]);
                minb->next = bcache.buckets[idx].next;
                bcache.buckets[idx].next = minb;
            }
            release(&bcache.locks[idx]);
            release(&bcache.hashlock);
            acquiresleep(&minb->lock);
            return minb;
        }
        release(&bcache.locks[idx]);
        if(++idx == NUM_BUCKETS)
            idx = 0;
    }  
  panic("bget: no buffers");
}

// 将 dev 和 blockno 映射到桶中
int hash(uint dev, uint blockon)
{
    return (dev*31+blockon)% NUM_BUCKETS;
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  virtio_disk_rw(b, 1);
}

// Release a locked buffer.
// Move to the head of the most-recently-used list.
// void
// brelse(struct buf *b)
// {
//   if(!holdingsleep(&b->lock))
//     panic("brelse");

//   releasesleep(&b->lock);

//   acquire(&bcache.lock);
//   b->refcnt--;
//   if (b->refcnt == 0) {
//     // no one is waiting for it.
//     b->next->prev = b->prev;
//     b->prev->next = b->next;
//     b->next = bcache.head.next;
//     b->prev = &bcache.head;
//     bcache.head.next->prev = b;
//     bcache.head.next = b;
//   }
  
//   release(&bcache.lock);
// }
extern uint ticks;
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");

  releasesleep(&b->lock);

int idx = hash(b->dev,b->blockno);

  acquire(&bcache.locks[idx]);
  b->refcnt--;
  if (b->refcnt == 0) {
    // no one is waiting for it.
    b->timestamp=ticks;
  }
  
  release(&bcache.locks[idx]);
}

void
bpin(struct buf *b) {
int idx = hash(b->dev,b->blockno);
acquire(&bcache.locks[idx]);
  b->refcnt++;
release(&bcache.locks[idx]);
}

void
bunpin(struct buf *b) {
int idx = hash(b->dev,b->blockno);
acquire(&bcache.locks[idx]);
  b->refcnt--;
release(&bcache.locks[idx]);
}


