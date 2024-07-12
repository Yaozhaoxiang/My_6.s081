
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0001e117          	auipc	sp,0x1e
    80000004:	14010113          	addi	sp,sp,320 # 8001e140 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	782050ef          	jal	ra,80005798 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	ebb9                	bnez	a5,80000082 <kfree+0x66>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00026797          	auipc	a5,0x26
    80000034:	21078793          	addi	a5,a5,528 # 80026240 <end>
    80000038:	04f56563          	bltu	a0,a5,80000082 <kfree+0x66>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	04f57163          	bgeu	a0,a5,80000082 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	00000097          	auipc	ra,0x0
    8000004c:	130080e7          	jalr	304(ra) # 80000178 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000050:	00009917          	auipc	s2,0x9
    80000054:	fe090913          	addi	s2,s2,-32 # 80009030 <kmem>
    80000058:	854a                	mv	a0,s2
    8000005a:	00006097          	auipc	ra,0x6
    8000005e:	194080e7          	jalr	404(ra) # 800061ee <acquire>
  r->next = kmem.freelist;
    80000062:	01893783          	ld	a5,24(s2)
    80000066:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000068:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000006c:	854a                	mv	a0,s2
    8000006e:	00006097          	auipc	ra,0x6
    80000072:	234080e7          	jalr	564(ra) # 800062a2 <release>
}
    80000076:	60e2                	ld	ra,24(sp)
    80000078:	6442                	ld	s0,16(sp)
    8000007a:	64a2                	ld	s1,8(sp)
    8000007c:	6902                	ld	s2,0(sp)
    8000007e:	6105                	addi	sp,sp,32
    80000080:	8082                	ret
    panic("kfree");
    80000082:	00008517          	auipc	a0,0x8
    80000086:	f8e50513          	addi	a0,a0,-114 # 80008010 <etext+0x10>
    8000008a:	00006097          	auipc	ra,0x6
    8000008e:	bbe080e7          	jalr	-1090(ra) # 80005c48 <panic>

0000000080000092 <freerange>:
{
    80000092:	7179                	addi	sp,sp,-48
    80000094:	f406                	sd	ra,40(sp)
    80000096:	f022                	sd	s0,32(sp)
    80000098:	ec26                	sd	s1,24(sp)
    8000009a:	e84a                	sd	s2,16(sp)
    8000009c:	e44e                	sd	s3,8(sp)
    8000009e:	e052                	sd	s4,0(sp)
    800000a0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800000a2:	6785                	lui	a5,0x1
    800000a4:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800000a8:	94aa                	add	s1,s1,a0
    800000aa:	757d                	lui	a0,0xfffff
    800000ac:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000ae:	94be                	add	s1,s1,a5
    800000b0:	0095ee63          	bltu	a1,s1,800000cc <freerange+0x3a>
    800000b4:	892e                	mv	s2,a1
    kfree(p);
    800000b6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000b8:	6985                	lui	s3,0x1
    kfree(p);
    800000ba:	01448533          	add	a0,s1,s4
    800000be:	00000097          	auipc	ra,0x0
    800000c2:	f5e080e7          	jalr	-162(ra) # 8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000c6:	94ce                	add	s1,s1,s3
    800000c8:	fe9979e3          	bgeu	s2,s1,800000ba <freerange+0x28>
}
    800000cc:	70a2                	ld	ra,40(sp)
    800000ce:	7402                	ld	s0,32(sp)
    800000d0:	64e2                	ld	s1,24(sp)
    800000d2:	6942                	ld	s2,16(sp)
    800000d4:	69a2                	ld	s3,8(sp)
    800000d6:	6a02                	ld	s4,0(sp)
    800000d8:	6145                	addi	sp,sp,48
    800000da:	8082                	ret

00000000800000dc <kinit>:
{
    800000dc:	1141                	addi	sp,sp,-16
    800000de:	e406                	sd	ra,8(sp)
    800000e0:	e022                	sd	s0,0(sp)
    800000e2:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000e4:	00008597          	auipc	a1,0x8
    800000e8:	f3458593          	addi	a1,a1,-204 # 80008018 <etext+0x18>
    800000ec:	00009517          	auipc	a0,0x9
    800000f0:	f4450513          	addi	a0,a0,-188 # 80009030 <kmem>
    800000f4:	00006097          	auipc	ra,0x6
    800000f8:	06a080e7          	jalr	106(ra) # 8000615e <initlock>
  freerange(end, (void*)PHYSTOP);
    800000fc:	45c5                	li	a1,17
    800000fe:	05ee                	slli	a1,a1,0x1b
    80000100:	00026517          	auipc	a0,0x26
    80000104:	14050513          	addi	a0,a0,320 # 80026240 <end>
    80000108:	00000097          	auipc	ra,0x0
    8000010c:	f8a080e7          	jalr	-118(ra) # 80000092 <freerange>
}
    80000110:	60a2                	ld	ra,8(sp)
    80000112:	6402                	ld	s0,0(sp)
    80000114:	0141                	addi	sp,sp,16
    80000116:	8082                	ret

0000000080000118 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000118:	1101                	addi	sp,sp,-32
    8000011a:	ec06                	sd	ra,24(sp)
    8000011c:	e822                	sd	s0,16(sp)
    8000011e:	e426                	sd	s1,8(sp)
    80000120:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000122:	00009497          	auipc	s1,0x9
    80000126:	f0e48493          	addi	s1,s1,-242 # 80009030 <kmem>
    8000012a:	8526                	mv	a0,s1
    8000012c:	00006097          	auipc	ra,0x6
    80000130:	0c2080e7          	jalr	194(ra) # 800061ee <acquire>
  r = kmem.freelist;
    80000134:	6c84                	ld	s1,24(s1)
  if(r)
    80000136:	c885                	beqz	s1,80000166 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000138:	609c                	ld	a5,0(s1)
    8000013a:	00009517          	auipc	a0,0x9
    8000013e:	ef650513          	addi	a0,a0,-266 # 80009030 <kmem>
    80000142:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000144:	00006097          	auipc	ra,0x6
    80000148:	15e080e7          	jalr	350(ra) # 800062a2 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000014c:	6605                	lui	a2,0x1
    8000014e:	4595                	li	a1,5
    80000150:	8526                	mv	a0,s1
    80000152:	00000097          	auipc	ra,0x0
    80000156:	026080e7          	jalr	38(ra) # 80000178 <memset>
  return (void*)r;
}
    8000015a:	8526                	mv	a0,s1
    8000015c:	60e2                	ld	ra,24(sp)
    8000015e:	6442                	ld	s0,16(sp)
    80000160:	64a2                	ld	s1,8(sp)
    80000162:	6105                	addi	sp,sp,32
    80000164:	8082                	ret
  release(&kmem.lock);
    80000166:	00009517          	auipc	a0,0x9
    8000016a:	eca50513          	addi	a0,a0,-310 # 80009030 <kmem>
    8000016e:	00006097          	auipc	ra,0x6
    80000172:	134080e7          	jalr	308(ra) # 800062a2 <release>
  if(r)
    80000176:	b7d5                	j	8000015a <kalloc+0x42>

0000000080000178 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000178:	1141                	addi	sp,sp,-16
    8000017a:	e422                	sd	s0,8(sp)
    8000017c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    8000017e:	ce09                	beqz	a2,80000198 <memset+0x20>
    80000180:	87aa                	mv	a5,a0
    80000182:	fff6071b          	addiw	a4,a2,-1
    80000186:	1702                	slli	a4,a4,0x20
    80000188:	9301                	srli	a4,a4,0x20
    8000018a:	0705                	addi	a4,a4,1
    8000018c:	972a                	add	a4,a4,a0
    cdst[i] = c;
    8000018e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000192:	0785                	addi	a5,a5,1
    80000194:	fee79de3          	bne	a5,a4,8000018e <memset+0x16>
  }
  return dst;
}
    80000198:	6422                	ld	s0,8(sp)
    8000019a:	0141                	addi	sp,sp,16
    8000019c:	8082                	ret

000000008000019e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    8000019e:	1141                	addi	sp,sp,-16
    800001a0:	e422                	sd	s0,8(sp)
    800001a2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800001a4:	ca05                	beqz	a2,800001d4 <memcmp+0x36>
    800001a6:	fff6069b          	addiw	a3,a2,-1
    800001aa:	1682                	slli	a3,a3,0x20
    800001ac:	9281                	srli	a3,a3,0x20
    800001ae:	0685                	addi	a3,a3,1
    800001b0:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800001b2:	00054783          	lbu	a5,0(a0)
    800001b6:	0005c703          	lbu	a4,0(a1)
    800001ba:	00e79863          	bne	a5,a4,800001ca <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800001be:	0505                	addi	a0,a0,1
    800001c0:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800001c2:	fed518e3          	bne	a0,a3,800001b2 <memcmp+0x14>
  }

  return 0;
    800001c6:	4501                	li	a0,0
    800001c8:	a019                	j	800001ce <memcmp+0x30>
      return *s1 - *s2;
    800001ca:	40e7853b          	subw	a0,a5,a4
}
    800001ce:	6422                	ld	s0,8(sp)
    800001d0:	0141                	addi	sp,sp,16
    800001d2:	8082                	ret
  return 0;
    800001d4:	4501                	li	a0,0
    800001d6:	bfe5                	j	800001ce <memcmp+0x30>

00000000800001d8 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001d8:	1141                	addi	sp,sp,-16
    800001da:	e422                	sd	s0,8(sp)
    800001dc:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800001de:	ca0d                	beqz	a2,80000210 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800001e0:	00a5f963          	bgeu	a1,a0,800001f2 <memmove+0x1a>
    800001e4:	02061693          	slli	a3,a2,0x20
    800001e8:	9281                	srli	a3,a3,0x20
    800001ea:	00d58733          	add	a4,a1,a3
    800001ee:	02e56463          	bltu	a0,a4,80000216 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001f2:	fff6079b          	addiw	a5,a2,-1
    800001f6:	1782                	slli	a5,a5,0x20
    800001f8:	9381                	srli	a5,a5,0x20
    800001fa:	0785                	addi	a5,a5,1
    800001fc:	97ae                	add	a5,a5,a1
    800001fe:	872a                	mv	a4,a0
      *d++ = *s++;
    80000200:	0585                	addi	a1,a1,1
    80000202:	0705                	addi	a4,a4,1
    80000204:	fff5c683          	lbu	a3,-1(a1)
    80000208:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    8000020c:	fef59ae3          	bne	a1,a5,80000200 <memmove+0x28>

  return dst;
}
    80000210:	6422                	ld	s0,8(sp)
    80000212:	0141                	addi	sp,sp,16
    80000214:	8082                	ret
    d += n;
    80000216:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000218:	fff6079b          	addiw	a5,a2,-1
    8000021c:	1782                	slli	a5,a5,0x20
    8000021e:	9381                	srli	a5,a5,0x20
    80000220:	fff7c793          	not	a5,a5
    80000224:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000226:	177d                	addi	a4,a4,-1
    80000228:	16fd                	addi	a3,a3,-1
    8000022a:	00074603          	lbu	a2,0(a4)
    8000022e:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000232:	fef71ae3          	bne	a4,a5,80000226 <memmove+0x4e>
    80000236:	bfe9                	j	80000210 <memmove+0x38>

0000000080000238 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000238:	1141                	addi	sp,sp,-16
    8000023a:	e406                	sd	ra,8(sp)
    8000023c:	e022                	sd	s0,0(sp)
    8000023e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000240:	00000097          	auipc	ra,0x0
    80000244:	f98080e7          	jalr	-104(ra) # 800001d8 <memmove>
}
    80000248:	60a2                	ld	ra,8(sp)
    8000024a:	6402                	ld	s0,0(sp)
    8000024c:	0141                	addi	sp,sp,16
    8000024e:	8082                	ret

0000000080000250 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000250:	1141                	addi	sp,sp,-16
    80000252:	e422                	sd	s0,8(sp)
    80000254:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000256:	ce11                	beqz	a2,80000272 <strncmp+0x22>
    80000258:	00054783          	lbu	a5,0(a0)
    8000025c:	cf89                	beqz	a5,80000276 <strncmp+0x26>
    8000025e:	0005c703          	lbu	a4,0(a1)
    80000262:	00f71a63          	bne	a4,a5,80000276 <strncmp+0x26>
    n--, p++, q++;
    80000266:	367d                	addiw	a2,a2,-1
    80000268:	0505                	addi	a0,a0,1
    8000026a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000026c:	f675                	bnez	a2,80000258 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000026e:	4501                	li	a0,0
    80000270:	a809                	j	80000282 <strncmp+0x32>
    80000272:	4501                	li	a0,0
    80000274:	a039                	j	80000282 <strncmp+0x32>
  if(n == 0)
    80000276:	ca09                	beqz	a2,80000288 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000278:	00054503          	lbu	a0,0(a0)
    8000027c:	0005c783          	lbu	a5,0(a1)
    80000280:	9d1d                	subw	a0,a0,a5
}
    80000282:	6422                	ld	s0,8(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    return 0;
    80000288:	4501                	li	a0,0
    8000028a:	bfe5                	j	80000282 <strncmp+0x32>

000000008000028c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000028c:	1141                	addi	sp,sp,-16
    8000028e:	e422                	sd	s0,8(sp)
    80000290:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000292:	872a                	mv	a4,a0
    80000294:	8832                	mv	a6,a2
    80000296:	367d                	addiw	a2,a2,-1
    80000298:	01005963          	blez	a6,800002aa <strncpy+0x1e>
    8000029c:	0705                	addi	a4,a4,1
    8000029e:	0005c783          	lbu	a5,0(a1)
    800002a2:	fef70fa3          	sb	a5,-1(a4)
    800002a6:	0585                	addi	a1,a1,1
    800002a8:	f7f5                	bnez	a5,80000294 <strncpy+0x8>
    ;
  while(n-- > 0)
    800002aa:	00c05d63          	blez	a2,800002c4 <strncpy+0x38>
    800002ae:	86ba                	mv	a3,a4
    *s++ = 0;
    800002b0:	0685                	addi	a3,a3,1
    800002b2:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800002b6:	fff6c793          	not	a5,a3
    800002ba:	9fb9                	addw	a5,a5,a4
    800002bc:	010787bb          	addw	a5,a5,a6
    800002c0:	fef048e3          	bgtz	a5,800002b0 <strncpy+0x24>
  return os;
}
    800002c4:	6422                	ld	s0,8(sp)
    800002c6:	0141                	addi	sp,sp,16
    800002c8:	8082                	ret

00000000800002ca <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800002ca:	1141                	addi	sp,sp,-16
    800002cc:	e422                	sd	s0,8(sp)
    800002ce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800002d0:	02c05363          	blez	a2,800002f6 <safestrcpy+0x2c>
    800002d4:	fff6069b          	addiw	a3,a2,-1
    800002d8:	1682                	slli	a3,a3,0x20
    800002da:	9281                	srli	a3,a3,0x20
    800002dc:	96ae                	add	a3,a3,a1
    800002de:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002e0:	00d58963          	beq	a1,a3,800002f2 <safestrcpy+0x28>
    800002e4:	0585                	addi	a1,a1,1
    800002e6:	0785                	addi	a5,a5,1
    800002e8:	fff5c703          	lbu	a4,-1(a1)
    800002ec:	fee78fa3          	sb	a4,-1(a5)
    800002f0:	fb65                	bnez	a4,800002e0 <safestrcpy+0x16>
    ;
  *s = 0;
    800002f2:	00078023          	sb	zero,0(a5)
  return os;
}
    800002f6:	6422                	ld	s0,8(sp)
    800002f8:	0141                	addi	sp,sp,16
    800002fa:	8082                	ret

00000000800002fc <strlen>:

int
strlen(const char *s)
{
    800002fc:	1141                	addi	sp,sp,-16
    800002fe:	e422                	sd	s0,8(sp)
    80000300:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000302:	00054783          	lbu	a5,0(a0)
    80000306:	cf91                	beqz	a5,80000322 <strlen+0x26>
    80000308:	0505                	addi	a0,a0,1
    8000030a:	87aa                	mv	a5,a0
    8000030c:	4685                	li	a3,1
    8000030e:	9e89                	subw	a3,a3,a0
    80000310:	00f6853b          	addw	a0,a3,a5
    80000314:	0785                	addi	a5,a5,1
    80000316:	fff7c703          	lbu	a4,-1(a5)
    8000031a:	fb7d                	bnez	a4,80000310 <strlen+0x14>
    ;
  return n;
}
    8000031c:	6422                	ld	s0,8(sp)
    8000031e:	0141                	addi	sp,sp,16
    80000320:	8082                	ret
  for(n = 0; s[n]; n++)
    80000322:	4501                	li	a0,0
    80000324:	bfe5                	j	8000031c <strlen+0x20>

0000000080000326 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000326:	1141                	addi	sp,sp,-16
    80000328:	e406                	sd	ra,8(sp)
    8000032a:	e022                	sd	s0,0(sp)
    8000032c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000032e:	00001097          	auipc	ra,0x1
    80000332:	aee080e7          	jalr	-1298(ra) # 80000e1c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000336:	00009717          	auipc	a4,0x9
    8000033a:	cca70713          	addi	a4,a4,-822 # 80009000 <started>
  if(cpuid() == 0){
    8000033e:	c139                	beqz	a0,80000384 <main+0x5e>
    while(started == 0)
    80000340:	431c                	lw	a5,0(a4)
    80000342:	2781                	sext.w	a5,a5
    80000344:	dff5                	beqz	a5,80000340 <main+0x1a>
      ;
    __sync_synchronize();
    80000346:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000034a:	00001097          	auipc	ra,0x1
    8000034e:	ad2080e7          	jalr	-1326(ra) # 80000e1c <cpuid>
    80000352:	85aa                	mv	a1,a0
    80000354:	00008517          	auipc	a0,0x8
    80000358:	ce450513          	addi	a0,a0,-796 # 80008038 <etext+0x38>
    8000035c:	00006097          	auipc	ra,0x6
    80000360:	936080e7          	jalr	-1738(ra) # 80005c92 <printf>
    kvminithart();    // turn on paging
    80000364:	00000097          	auipc	ra,0x0
    80000368:	0d8080e7          	jalr	216(ra) # 8000043c <kvminithart>
    trapinithart();   // install kernel trap vector
    8000036c:	00001097          	auipc	ra,0x1
    80000370:	77e080e7          	jalr	1918(ra) # 80001aea <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000374:	00005097          	auipc	ra,0x5
    80000378:	dac080e7          	jalr	-596(ra) # 80005120 <plicinithart>
  }

  scheduler();        
    8000037c:	00001097          	auipc	ra,0x1
    80000380:	02c080e7          	jalr	44(ra) # 800013a8 <scheduler>
    consoleinit();
    80000384:	00005097          	auipc	ra,0x5
    80000388:	7d6080e7          	jalr	2006(ra) # 80005b5a <consoleinit>
    printfinit();
    8000038c:	00006097          	auipc	ra,0x6
    80000390:	aec080e7          	jalr	-1300(ra) # 80005e78 <printfinit>
    printf("\n");
    80000394:	00008517          	auipc	a0,0x8
    80000398:	cb450513          	addi	a0,a0,-844 # 80008048 <etext+0x48>
    8000039c:	00006097          	auipc	ra,0x6
    800003a0:	8f6080e7          	jalr	-1802(ra) # 80005c92 <printf>
    printf("xv6 kernel is booting\n");
    800003a4:	00008517          	auipc	a0,0x8
    800003a8:	c7c50513          	addi	a0,a0,-900 # 80008020 <etext+0x20>
    800003ac:	00006097          	auipc	ra,0x6
    800003b0:	8e6080e7          	jalr	-1818(ra) # 80005c92 <printf>
    printf("\n");
    800003b4:	00008517          	auipc	a0,0x8
    800003b8:	c9450513          	addi	a0,a0,-876 # 80008048 <etext+0x48>
    800003bc:	00006097          	auipc	ra,0x6
    800003c0:	8d6080e7          	jalr	-1834(ra) # 80005c92 <printf>
    kinit();         // physical page allocator
    800003c4:	00000097          	auipc	ra,0x0
    800003c8:	d18080e7          	jalr	-744(ra) # 800000dc <kinit>
    kvminit();       // create kernel page table
    800003cc:	00000097          	auipc	ra,0x0
    800003d0:	322080e7          	jalr	802(ra) # 800006ee <kvminit>
    kvminithart();   // turn on paging
    800003d4:	00000097          	auipc	ra,0x0
    800003d8:	068080e7          	jalr	104(ra) # 8000043c <kvminithart>
    procinit();      // process table
    800003dc:	00001097          	auipc	ra,0x1
    800003e0:	990080e7          	jalr	-1648(ra) # 80000d6c <procinit>
    trapinit();      // trap vectors
    800003e4:	00001097          	auipc	ra,0x1
    800003e8:	6de080e7          	jalr	1758(ra) # 80001ac2 <trapinit>
    trapinithart();  // install kernel trap vector
    800003ec:	00001097          	auipc	ra,0x1
    800003f0:	6fe080e7          	jalr	1790(ra) # 80001aea <trapinithart>
    plicinit();      // set up interrupt controller
    800003f4:	00005097          	auipc	ra,0x5
    800003f8:	d16080e7          	jalr	-746(ra) # 8000510a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800003fc:	00005097          	auipc	ra,0x5
    80000400:	d24080e7          	jalr	-732(ra) # 80005120 <plicinithart>
    binit();         // buffer cache
    80000404:	00002097          	auipc	ra,0x2
    80000408:	f06080e7          	jalr	-250(ra) # 8000230a <binit>
    iinit();         // inode table
    8000040c:	00002097          	auipc	ra,0x2
    80000410:	596080e7          	jalr	1430(ra) # 800029a2 <iinit>
    fileinit();      // file table
    80000414:	00003097          	auipc	ra,0x3
    80000418:	540080e7          	jalr	1344(ra) # 80003954 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000041c:	00005097          	auipc	ra,0x5
    80000420:	e26080e7          	jalr	-474(ra) # 80005242 <virtio_disk_init>
    userinit();      // first user process
    80000424:	00001097          	auipc	ra,0x1
    80000428:	d52080e7          	jalr	-686(ra) # 80001176 <userinit>
    __sync_synchronize();
    8000042c:	0ff0000f          	fence
    started = 1;
    80000430:	4785                	li	a5,1
    80000432:	00009717          	auipc	a4,0x9
    80000436:	bcf72723          	sw	a5,-1074(a4) # 80009000 <started>
    8000043a:	b789                	j	8000037c <main+0x56>

000000008000043c <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e422                	sd	s0,8(sp)
    80000440:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000442:	00009797          	auipc	a5,0x9
    80000446:	bc67b783          	ld	a5,-1082(a5) # 80009008 <kernel_pagetable>
    8000044a:	83b1                	srli	a5,a5,0xc
    8000044c:	577d                	li	a4,-1
    8000044e:	177e                	slli	a4,a4,0x3f
    80000450:	8fd9                	or	a5,a5,a4
// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
  asm volatile("csrw satp, %0" : : "r" (x));
    80000452:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000456:	12000073          	sfence.vma
  sfence_vma();
}
    8000045a:	6422                	ld	s0,8(sp)
    8000045c:	0141                	addi	sp,sp,16
    8000045e:	8082                	ret

0000000080000460 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000460:	7139                	addi	sp,sp,-64
    80000462:	fc06                	sd	ra,56(sp)
    80000464:	f822                	sd	s0,48(sp)
    80000466:	f426                	sd	s1,40(sp)
    80000468:	f04a                	sd	s2,32(sp)
    8000046a:	ec4e                	sd	s3,24(sp)
    8000046c:	e852                	sd	s4,16(sp)
    8000046e:	e456                	sd	s5,8(sp)
    80000470:	e05a                	sd	s6,0(sp)
    80000472:	0080                	addi	s0,sp,64
    80000474:	84aa                	mv	s1,a0
    80000476:	89ae                	mv	s3,a1
    80000478:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000047a:	57fd                	li	a5,-1
    8000047c:	83e9                	srli	a5,a5,0x1a
    8000047e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000480:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000482:	04b7f263          	bgeu	a5,a1,800004c6 <walk+0x66>
    panic("walk");
    80000486:	00008517          	auipc	a0,0x8
    8000048a:	bca50513          	addi	a0,a0,-1078 # 80008050 <etext+0x50>
    8000048e:	00005097          	auipc	ra,0x5
    80000492:	7ba080e7          	jalr	1978(ra) # 80005c48 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000496:	060a8663          	beqz	s5,80000502 <walk+0xa2>
    8000049a:	00000097          	auipc	ra,0x0
    8000049e:	c7e080e7          	jalr	-898(ra) # 80000118 <kalloc>
    800004a2:	84aa                	mv	s1,a0
    800004a4:	c529                	beqz	a0,800004ee <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800004a6:	6605                	lui	a2,0x1
    800004a8:	4581                	li	a1,0
    800004aa:	00000097          	auipc	ra,0x0
    800004ae:	cce080e7          	jalr	-818(ra) # 80000178 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800004b2:	00c4d793          	srli	a5,s1,0xc
    800004b6:	07aa                	slli	a5,a5,0xa
    800004b8:	0017e793          	ori	a5,a5,1
    800004bc:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800004c0:	3a5d                	addiw	s4,s4,-9
    800004c2:	036a0063          	beq	s4,s6,800004e2 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800004c6:	0149d933          	srl	s2,s3,s4
    800004ca:	1ff97913          	andi	s2,s2,511
    800004ce:	090e                	slli	s2,s2,0x3
    800004d0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800004d2:	00093483          	ld	s1,0(s2)
    800004d6:	0014f793          	andi	a5,s1,1
    800004da:	dfd5                	beqz	a5,80000496 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800004dc:	80a9                	srli	s1,s1,0xa
    800004de:	04b2                	slli	s1,s1,0xc
    800004e0:	b7c5                	j	800004c0 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800004e2:	00c9d513          	srli	a0,s3,0xc
    800004e6:	1ff57513          	andi	a0,a0,511
    800004ea:	050e                	slli	a0,a0,0x3
    800004ec:	9526                	add	a0,a0,s1
}
    800004ee:	70e2                	ld	ra,56(sp)
    800004f0:	7442                	ld	s0,48(sp)
    800004f2:	74a2                	ld	s1,40(sp)
    800004f4:	7902                	ld	s2,32(sp)
    800004f6:	69e2                	ld	s3,24(sp)
    800004f8:	6a42                	ld	s4,16(sp)
    800004fa:	6aa2                	ld	s5,8(sp)
    800004fc:	6b02                	ld	s6,0(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
        return 0;
    80000502:	4501                	li	a0,0
    80000504:	b7ed                	j	800004ee <walk+0x8e>

0000000080000506 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000506:	57fd                	li	a5,-1
    80000508:	83e9                	srli	a5,a5,0x1a
    8000050a:	00b7f463          	bgeu	a5,a1,80000512 <walkaddr+0xc>
    return 0;
    8000050e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000510:	8082                	ret
{
    80000512:	1141                	addi	sp,sp,-16
    80000514:	e406                	sd	ra,8(sp)
    80000516:	e022                	sd	s0,0(sp)
    80000518:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000051a:	4601                	li	a2,0
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	f44080e7          	jalr	-188(ra) # 80000460 <walk>
  if(pte == 0)
    80000524:	c105                	beqz	a0,80000544 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80000526:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000528:	0117f693          	andi	a3,a5,17
    8000052c:	4745                	li	a4,17
    return 0;
    8000052e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000530:	00e68663          	beq	a3,a4,8000053c <walkaddr+0x36>
}
    80000534:	60a2                	ld	ra,8(sp)
    80000536:	6402                	ld	s0,0(sp)
    80000538:	0141                	addi	sp,sp,16
    8000053a:	8082                	ret
  pa = PTE2PA(*pte);
    8000053c:	00a7d513          	srli	a0,a5,0xa
    80000540:	0532                	slli	a0,a0,0xc
  return pa;
    80000542:	bfcd                	j	80000534 <walkaddr+0x2e>
    return 0;
    80000544:	4501                	li	a0,0
    80000546:	b7fd                	j	80000534 <walkaddr+0x2e>

0000000080000548 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000548:	715d                	addi	sp,sp,-80
    8000054a:	e486                	sd	ra,72(sp)
    8000054c:	e0a2                	sd	s0,64(sp)
    8000054e:	fc26                	sd	s1,56(sp)
    80000550:	f84a                	sd	s2,48(sp)
    80000552:	f44e                	sd	s3,40(sp)
    80000554:	f052                	sd	s4,32(sp)
    80000556:	ec56                	sd	s5,24(sp)
    80000558:	e85a                	sd	s6,16(sp)
    8000055a:	e45e                	sd	s7,8(sp)
    8000055c:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000055e:	c205                	beqz	a2,8000057e <mappages+0x36>
    80000560:	8aaa                	mv	s5,a0
    80000562:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80000564:	77fd                	lui	a5,0xfffff
    80000566:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    8000056a:	15fd                	addi	a1,a1,-1
    8000056c:	00c589b3          	add	s3,a1,a2
    80000570:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    80000574:	8952                	mv	s2,s4
    80000576:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000057a:	6b85                	lui	s7,0x1
    8000057c:	a015                	j	800005a0 <mappages+0x58>
    panic("mappages: size");
    8000057e:	00008517          	auipc	a0,0x8
    80000582:	ada50513          	addi	a0,a0,-1318 # 80008058 <etext+0x58>
    80000586:	00005097          	auipc	ra,0x5
    8000058a:	6c2080e7          	jalr	1730(ra) # 80005c48 <panic>
      panic("mappages: remap");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	ada50513          	addi	a0,a0,-1318 # 80008068 <etext+0x68>
    80000596:	00005097          	auipc	ra,0x5
    8000059a:	6b2080e7          	jalr	1714(ra) # 80005c48 <panic>
    a += PGSIZE;
    8000059e:	995e                	add	s2,s2,s7
  for(;;){
    800005a0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800005a4:	4605                	li	a2,1
    800005a6:	85ca                	mv	a1,s2
    800005a8:	8556                	mv	a0,s5
    800005aa:	00000097          	auipc	ra,0x0
    800005ae:	eb6080e7          	jalr	-330(ra) # 80000460 <walk>
    800005b2:	cd19                	beqz	a0,800005d0 <mappages+0x88>
    if(*pte & PTE_V)
    800005b4:	611c                	ld	a5,0(a0)
    800005b6:	8b85                	andi	a5,a5,1
    800005b8:	fbf9                	bnez	a5,8000058e <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800005ba:	80b1                	srli	s1,s1,0xc
    800005bc:	04aa                	slli	s1,s1,0xa
    800005be:	0164e4b3          	or	s1,s1,s6
    800005c2:	0014e493          	ori	s1,s1,1
    800005c6:	e104                	sd	s1,0(a0)
    if(a == last)
    800005c8:	fd391be3          	bne	s2,s3,8000059e <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    800005cc:	4501                	li	a0,0
    800005ce:	a011                	j	800005d2 <mappages+0x8a>
      return -1;
    800005d0:	557d                	li	a0,-1
}
    800005d2:	60a6                	ld	ra,72(sp)
    800005d4:	6406                	ld	s0,64(sp)
    800005d6:	74e2                	ld	s1,56(sp)
    800005d8:	7942                	ld	s2,48(sp)
    800005da:	79a2                	ld	s3,40(sp)
    800005dc:	7a02                	ld	s4,32(sp)
    800005de:	6ae2                	ld	s5,24(sp)
    800005e0:	6b42                	ld	s6,16(sp)
    800005e2:	6ba2                	ld	s7,8(sp)
    800005e4:	6161                	addi	sp,sp,80
    800005e6:	8082                	ret

00000000800005e8 <kvmmap>:
{
    800005e8:	1141                	addi	sp,sp,-16
    800005ea:	e406                	sd	ra,8(sp)
    800005ec:	e022                	sd	s0,0(sp)
    800005ee:	0800                	addi	s0,sp,16
    800005f0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800005f2:	86b2                	mv	a3,a2
    800005f4:	863e                	mv	a2,a5
    800005f6:	00000097          	auipc	ra,0x0
    800005fa:	f52080e7          	jalr	-174(ra) # 80000548 <mappages>
    800005fe:	e509                	bnez	a0,80000608 <kvmmap+0x20>
}
    80000600:	60a2                	ld	ra,8(sp)
    80000602:	6402                	ld	s0,0(sp)
    80000604:	0141                	addi	sp,sp,16
    80000606:	8082                	ret
    panic("kvmmap");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a7050513          	addi	a0,a0,-1424 # 80008078 <etext+0x78>
    80000610:	00005097          	auipc	ra,0x5
    80000614:	638080e7          	jalr	1592(ra) # 80005c48 <panic>

0000000080000618 <kvmmake>:
{
    80000618:	1101                	addi	sp,sp,-32
    8000061a:	ec06                	sd	ra,24(sp)
    8000061c:	e822                	sd	s0,16(sp)
    8000061e:	e426                	sd	s1,8(sp)
    80000620:	e04a                	sd	s2,0(sp)
    80000622:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000624:	00000097          	auipc	ra,0x0
    80000628:	af4080e7          	jalr	-1292(ra) # 80000118 <kalloc>
    8000062c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000062e:	6605                	lui	a2,0x1
    80000630:	4581                	li	a1,0
    80000632:	00000097          	auipc	ra,0x0
    80000636:	b46080e7          	jalr	-1210(ra) # 80000178 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000063a:	4719                	li	a4,6
    8000063c:	6685                	lui	a3,0x1
    8000063e:	10000637          	lui	a2,0x10000
    80000642:	100005b7          	lui	a1,0x10000
    80000646:	8526                	mv	a0,s1
    80000648:	00000097          	auipc	ra,0x0
    8000064c:	fa0080e7          	jalr	-96(ra) # 800005e8 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000650:	4719                	li	a4,6
    80000652:	6685                	lui	a3,0x1
    80000654:	10001637          	lui	a2,0x10001
    80000658:	100015b7          	lui	a1,0x10001
    8000065c:	8526                	mv	a0,s1
    8000065e:	00000097          	auipc	ra,0x0
    80000662:	f8a080e7          	jalr	-118(ra) # 800005e8 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80000666:	4719                	li	a4,6
    80000668:	004006b7          	lui	a3,0x400
    8000066c:	0c000637          	lui	a2,0xc000
    80000670:	0c0005b7          	lui	a1,0xc000
    80000674:	8526                	mv	a0,s1
    80000676:	00000097          	auipc	ra,0x0
    8000067a:	f72080e7          	jalr	-142(ra) # 800005e8 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000067e:	00008917          	auipc	s2,0x8
    80000682:	98290913          	addi	s2,s2,-1662 # 80008000 <etext>
    80000686:	4729                	li	a4,10
    80000688:	80008697          	auipc	a3,0x80008
    8000068c:	97868693          	addi	a3,a3,-1672 # 8000 <_entry-0x7fff8000>
    80000690:	4605                	li	a2,1
    80000692:	067e                	slli	a2,a2,0x1f
    80000694:	85b2                	mv	a1,a2
    80000696:	8526                	mv	a0,s1
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	f50080e7          	jalr	-176(ra) # 800005e8 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800006a0:	4719                	li	a4,6
    800006a2:	46c5                	li	a3,17
    800006a4:	06ee                	slli	a3,a3,0x1b
    800006a6:	412686b3          	sub	a3,a3,s2
    800006aa:	864a                	mv	a2,s2
    800006ac:	85ca                	mv	a1,s2
    800006ae:	8526                	mv	a0,s1
    800006b0:	00000097          	auipc	ra,0x0
    800006b4:	f38080e7          	jalr	-200(ra) # 800005e8 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800006b8:	4729                	li	a4,10
    800006ba:	6685                	lui	a3,0x1
    800006bc:	00007617          	auipc	a2,0x7
    800006c0:	94460613          	addi	a2,a2,-1724 # 80007000 <_trampoline>
    800006c4:	040005b7          	lui	a1,0x4000
    800006c8:	15fd                	addi	a1,a1,-1
    800006ca:	05b2                	slli	a1,a1,0xc
    800006cc:	8526                	mv	a0,s1
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	f1a080e7          	jalr	-230(ra) # 800005e8 <kvmmap>
  proc_mapstacks(kpgtbl);
    800006d6:	8526                	mv	a0,s1
    800006d8:	00000097          	auipc	ra,0x0
    800006dc:	5fe080e7          	jalr	1534(ra) # 80000cd6 <proc_mapstacks>
}
    800006e0:	8526                	mv	a0,s1
    800006e2:	60e2                	ld	ra,24(sp)
    800006e4:	6442                	ld	s0,16(sp)
    800006e6:	64a2                	ld	s1,8(sp)
    800006e8:	6902                	ld	s2,0(sp)
    800006ea:	6105                	addi	sp,sp,32
    800006ec:	8082                	ret

00000000800006ee <kvminit>:
{
    800006ee:	1141                	addi	sp,sp,-16
    800006f0:	e406                	sd	ra,8(sp)
    800006f2:	e022                	sd	s0,0(sp)
    800006f4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800006f6:	00000097          	auipc	ra,0x0
    800006fa:	f22080e7          	jalr	-222(ra) # 80000618 <kvmmake>
    800006fe:	00009797          	auipc	a5,0x9
    80000702:	90a7b523          	sd	a0,-1782(a5) # 80009008 <kernel_pagetable>
}
    80000706:	60a2                	ld	ra,8(sp)
    80000708:	6402                	ld	s0,0(sp)
    8000070a:	0141                	addi	sp,sp,16
    8000070c:	8082                	ret

000000008000070e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000070e:	715d                	addi	sp,sp,-80
    80000710:	e486                	sd	ra,72(sp)
    80000712:	e0a2                	sd	s0,64(sp)
    80000714:	fc26                	sd	s1,56(sp)
    80000716:	f84a                	sd	s2,48(sp)
    80000718:	f44e                	sd	s3,40(sp)
    8000071a:	f052                	sd	s4,32(sp)
    8000071c:	ec56                	sd	s5,24(sp)
    8000071e:	e85a                	sd	s6,16(sp)
    80000720:	e45e                	sd	s7,8(sp)
    80000722:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000724:	03459793          	slli	a5,a1,0x34
    80000728:	e795                	bnez	a5,80000754 <uvmunmap+0x46>
    8000072a:	8a2a                	mv	s4,a0
    8000072c:	892e                	mv	s2,a1
    8000072e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000730:	0632                	slli	a2,a2,0xc
    80000732:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80000736:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000738:	6b05                	lui	s6,0x1
    8000073a:	0735e863          	bltu	a1,s3,800007aa <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000073e:	60a6                	ld	ra,72(sp)
    80000740:	6406                	ld	s0,64(sp)
    80000742:	74e2                	ld	s1,56(sp)
    80000744:	7942                	ld	s2,48(sp)
    80000746:	79a2                	ld	s3,40(sp)
    80000748:	7a02                	ld	s4,32(sp)
    8000074a:	6ae2                	ld	s5,24(sp)
    8000074c:	6b42                	ld	s6,16(sp)
    8000074e:	6ba2                	ld	s7,8(sp)
    80000750:	6161                	addi	sp,sp,80
    80000752:	8082                	ret
    panic("uvmunmap: not aligned");
    80000754:	00008517          	auipc	a0,0x8
    80000758:	92c50513          	addi	a0,a0,-1748 # 80008080 <etext+0x80>
    8000075c:	00005097          	auipc	ra,0x5
    80000760:	4ec080e7          	jalr	1260(ra) # 80005c48 <panic>
      panic("uvmunmap: walk");
    80000764:	00008517          	auipc	a0,0x8
    80000768:	93450513          	addi	a0,a0,-1740 # 80008098 <etext+0x98>
    8000076c:	00005097          	auipc	ra,0x5
    80000770:	4dc080e7          	jalr	1244(ra) # 80005c48 <panic>
      panic("uvmunmap: not mapped");
    80000774:	00008517          	auipc	a0,0x8
    80000778:	93450513          	addi	a0,a0,-1740 # 800080a8 <etext+0xa8>
    8000077c:	00005097          	auipc	ra,0x5
    80000780:	4cc080e7          	jalr	1228(ra) # 80005c48 <panic>
      panic("uvmunmap: not a leaf");
    80000784:	00008517          	auipc	a0,0x8
    80000788:	93c50513          	addi	a0,a0,-1732 # 800080c0 <etext+0xc0>
    8000078c:	00005097          	auipc	ra,0x5
    80000790:	4bc080e7          	jalr	1212(ra) # 80005c48 <panic>
      uint64 pa = PTE2PA(*pte);
    80000794:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80000796:	0532                	slli	a0,a0,0xc
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	884080e7          	jalr	-1916(ra) # 8000001c <kfree>
    *pte = 0;
    800007a0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800007a4:	995a                	add	s2,s2,s6
    800007a6:	f9397ce3          	bgeu	s2,s3,8000073e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800007aa:	4601                	li	a2,0
    800007ac:	85ca                	mv	a1,s2
    800007ae:	8552                	mv	a0,s4
    800007b0:	00000097          	auipc	ra,0x0
    800007b4:	cb0080e7          	jalr	-848(ra) # 80000460 <walk>
    800007b8:	84aa                	mv	s1,a0
    800007ba:	d54d                	beqz	a0,80000764 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800007bc:	6108                	ld	a0,0(a0)
    800007be:	00157793          	andi	a5,a0,1
    800007c2:	dbcd                	beqz	a5,80000774 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800007c4:	3ff57793          	andi	a5,a0,1023
    800007c8:	fb778ee3          	beq	a5,s7,80000784 <uvmunmap+0x76>
    if(do_free){
    800007cc:	fc0a8ae3          	beqz	s5,800007a0 <uvmunmap+0x92>
    800007d0:	b7d1                	j	80000794 <uvmunmap+0x86>

00000000800007d2 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800007d2:	1101                	addi	sp,sp,-32
    800007d4:	ec06                	sd	ra,24(sp)
    800007d6:	e822                	sd	s0,16(sp)
    800007d8:	e426                	sd	s1,8(sp)
    800007da:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	93c080e7          	jalr	-1732(ra) # 80000118 <kalloc>
    800007e4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800007e6:	c519                	beqz	a0,800007f4 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800007e8:	6605                	lui	a2,0x1
    800007ea:	4581                	li	a1,0
    800007ec:	00000097          	auipc	ra,0x0
    800007f0:	98c080e7          	jalr	-1652(ra) # 80000178 <memset>
  return pagetable;
}
    800007f4:	8526                	mv	a0,s1
    800007f6:	60e2                	ld	ra,24(sp)
    800007f8:	6442                	ld	s0,16(sp)
    800007fa:	64a2                	ld	s1,8(sp)
    800007fc:	6105                	addi	sp,sp,32
    800007fe:	8082                	ret

0000000080000800 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80000800:	7179                	addi	sp,sp,-48
    80000802:	f406                	sd	ra,40(sp)
    80000804:	f022                	sd	s0,32(sp)
    80000806:	ec26                	sd	s1,24(sp)
    80000808:	e84a                	sd	s2,16(sp)
    8000080a:	e44e                	sd	s3,8(sp)
    8000080c:	e052                	sd	s4,0(sp)
    8000080e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000810:	6785                	lui	a5,0x1
    80000812:	04f67863          	bgeu	a2,a5,80000862 <uvminit+0x62>
    80000816:	8a2a                	mv	s4,a0
    80000818:	89ae                	mv	s3,a1
    8000081a:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000081c:	00000097          	auipc	ra,0x0
    80000820:	8fc080e7          	jalr	-1796(ra) # 80000118 <kalloc>
    80000824:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000826:	6605                	lui	a2,0x1
    80000828:	4581                	li	a1,0
    8000082a:	00000097          	auipc	ra,0x0
    8000082e:	94e080e7          	jalr	-1714(ra) # 80000178 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80000832:	4779                	li	a4,30
    80000834:	86ca                	mv	a3,s2
    80000836:	6605                	lui	a2,0x1
    80000838:	4581                	li	a1,0
    8000083a:	8552                	mv	a0,s4
    8000083c:	00000097          	auipc	ra,0x0
    80000840:	d0c080e7          	jalr	-756(ra) # 80000548 <mappages>
  memmove(mem, src, sz);
    80000844:	8626                	mv	a2,s1
    80000846:	85ce                	mv	a1,s3
    80000848:	854a                	mv	a0,s2
    8000084a:	00000097          	auipc	ra,0x0
    8000084e:	98e080e7          	jalr	-1650(ra) # 800001d8 <memmove>
}
    80000852:	70a2                	ld	ra,40(sp)
    80000854:	7402                	ld	s0,32(sp)
    80000856:	64e2                	ld	s1,24(sp)
    80000858:	6942                	ld	s2,16(sp)
    8000085a:	69a2                	ld	s3,8(sp)
    8000085c:	6a02                	ld	s4,0(sp)
    8000085e:	6145                	addi	sp,sp,48
    80000860:	8082                	ret
    panic("inituvm: more than a page");
    80000862:	00008517          	auipc	a0,0x8
    80000866:	87650513          	addi	a0,a0,-1930 # 800080d8 <etext+0xd8>
    8000086a:	00005097          	auipc	ra,0x5
    8000086e:	3de080e7          	jalr	990(ra) # 80005c48 <panic>

0000000080000872 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000872:	1101                	addi	sp,sp,-32
    80000874:	ec06                	sd	ra,24(sp)
    80000876:	e822                	sd	s0,16(sp)
    80000878:	e426                	sd	s1,8(sp)
    8000087a:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000087c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000087e:	00b67d63          	bgeu	a2,a1,80000898 <uvmdealloc+0x26>
    80000882:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000884:	6785                	lui	a5,0x1
    80000886:	17fd                	addi	a5,a5,-1
    80000888:	00f60733          	add	a4,a2,a5
    8000088c:	767d                	lui	a2,0xfffff
    8000088e:	8f71                	and	a4,a4,a2
    80000890:	97ae                	add	a5,a5,a1
    80000892:	8ff1                	and	a5,a5,a2
    80000894:	00f76863          	bltu	a4,a5,800008a4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80000898:	8526                	mv	a0,s1
    8000089a:	60e2                	ld	ra,24(sp)
    8000089c:	6442                	ld	s0,16(sp)
    8000089e:	64a2                	ld	s1,8(sp)
    800008a0:	6105                	addi	sp,sp,32
    800008a2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800008a4:	8f99                	sub	a5,a5,a4
    800008a6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800008a8:	4685                	li	a3,1
    800008aa:	0007861b          	sext.w	a2,a5
    800008ae:	85ba                	mv	a1,a4
    800008b0:	00000097          	auipc	ra,0x0
    800008b4:	e5e080e7          	jalr	-418(ra) # 8000070e <uvmunmap>
    800008b8:	b7c5                	j	80000898 <uvmdealloc+0x26>

00000000800008ba <uvmalloc>:
  if(newsz < oldsz)
    800008ba:	0ab66163          	bltu	a2,a1,8000095c <uvmalloc+0xa2>
{
    800008be:	7139                	addi	sp,sp,-64
    800008c0:	fc06                	sd	ra,56(sp)
    800008c2:	f822                	sd	s0,48(sp)
    800008c4:	f426                	sd	s1,40(sp)
    800008c6:	f04a                	sd	s2,32(sp)
    800008c8:	ec4e                	sd	s3,24(sp)
    800008ca:	e852                	sd	s4,16(sp)
    800008cc:	e456                	sd	s5,8(sp)
    800008ce:	0080                	addi	s0,sp,64
    800008d0:	8aaa                	mv	s5,a0
    800008d2:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800008d4:	6985                	lui	s3,0x1
    800008d6:	19fd                	addi	s3,s3,-1
    800008d8:	95ce                	add	a1,a1,s3
    800008da:	79fd                	lui	s3,0xfffff
    800008dc:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800008e0:	08c9f063          	bgeu	s3,a2,80000960 <uvmalloc+0xa6>
    800008e4:	894e                	mv	s2,s3
    mem = kalloc();
    800008e6:	00000097          	auipc	ra,0x0
    800008ea:	832080e7          	jalr	-1998(ra) # 80000118 <kalloc>
    800008ee:	84aa                	mv	s1,a0
    if(mem == 0){
    800008f0:	c51d                	beqz	a0,8000091e <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800008f2:	6605                	lui	a2,0x1
    800008f4:	4581                	li	a1,0
    800008f6:	00000097          	auipc	ra,0x0
    800008fa:	882080e7          	jalr	-1918(ra) # 80000178 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800008fe:	4779                	li	a4,30
    80000900:	86a6                	mv	a3,s1
    80000902:	6605                	lui	a2,0x1
    80000904:	85ca                	mv	a1,s2
    80000906:	8556                	mv	a0,s5
    80000908:	00000097          	auipc	ra,0x0
    8000090c:	c40080e7          	jalr	-960(ra) # 80000548 <mappages>
    80000910:	e905                	bnez	a0,80000940 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000912:	6785                	lui	a5,0x1
    80000914:	993e                	add	s2,s2,a5
    80000916:	fd4968e3          	bltu	s2,s4,800008e6 <uvmalloc+0x2c>
  return newsz;
    8000091a:	8552                	mv	a0,s4
    8000091c:	a809                	j	8000092e <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000091e:	864e                	mv	a2,s3
    80000920:	85ca                	mv	a1,s2
    80000922:	8556                	mv	a0,s5
    80000924:	00000097          	auipc	ra,0x0
    80000928:	f4e080e7          	jalr	-178(ra) # 80000872 <uvmdealloc>
      return 0;
    8000092c:	4501                	li	a0,0
}
    8000092e:	70e2                	ld	ra,56(sp)
    80000930:	7442                	ld	s0,48(sp)
    80000932:	74a2                	ld	s1,40(sp)
    80000934:	7902                	ld	s2,32(sp)
    80000936:	69e2                	ld	s3,24(sp)
    80000938:	6a42                	ld	s4,16(sp)
    8000093a:	6aa2                	ld	s5,8(sp)
    8000093c:	6121                	addi	sp,sp,64
    8000093e:	8082                	ret
      kfree(mem);
    80000940:	8526                	mv	a0,s1
    80000942:	fffff097          	auipc	ra,0xfffff
    80000946:	6da080e7          	jalr	1754(ra) # 8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000094a:	864e                	mv	a2,s3
    8000094c:	85ca                	mv	a1,s2
    8000094e:	8556                	mv	a0,s5
    80000950:	00000097          	auipc	ra,0x0
    80000954:	f22080e7          	jalr	-222(ra) # 80000872 <uvmdealloc>
      return 0;
    80000958:	4501                	li	a0,0
    8000095a:	bfd1                	j	8000092e <uvmalloc+0x74>
    return oldsz;
    8000095c:	852e                	mv	a0,a1
}
    8000095e:	8082                	ret
  return newsz;
    80000960:	8532                	mv	a0,a2
    80000962:	b7f1                	j	8000092e <uvmalloc+0x74>

0000000080000964 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80000964:	7179                	addi	sp,sp,-48
    80000966:	f406                	sd	ra,40(sp)
    80000968:	f022                	sd	s0,32(sp)
    8000096a:	ec26                	sd	s1,24(sp)
    8000096c:	e84a                	sd	s2,16(sp)
    8000096e:	e44e                	sd	s3,8(sp)
    80000970:	e052                	sd	s4,0(sp)
    80000972:	1800                	addi	s0,sp,48
    80000974:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000976:	84aa                	mv	s1,a0
    80000978:	6905                	lui	s2,0x1
    8000097a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000097c:	4985                	li	s3,1
    8000097e:	a821                	j	80000996 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000980:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000982:	0532                	slli	a0,a0,0xc
    80000984:	00000097          	auipc	ra,0x0
    80000988:	fe0080e7          	jalr	-32(ra) # 80000964 <freewalk>
      pagetable[i] = 0;
    8000098c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000990:	04a1                	addi	s1,s1,8
    80000992:	03248163          	beq	s1,s2,800009b4 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000996:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000998:	00f57793          	andi	a5,a0,15
    8000099c:	ff3782e3          	beq	a5,s3,80000980 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800009a0:	8905                	andi	a0,a0,1
    800009a2:	d57d                	beqz	a0,80000990 <freewalk+0x2c>
      panic("freewalk: leaf");
    800009a4:	00007517          	auipc	a0,0x7
    800009a8:	75450513          	addi	a0,a0,1876 # 800080f8 <etext+0xf8>
    800009ac:	00005097          	auipc	ra,0x5
    800009b0:	29c080e7          	jalr	668(ra) # 80005c48 <panic>
    }
  }
  kfree((void*)pagetable);
    800009b4:	8552                	mv	a0,s4
    800009b6:	fffff097          	auipc	ra,0xfffff
    800009ba:	666080e7          	jalr	1638(ra) # 8000001c <kfree>
}
    800009be:	70a2                	ld	ra,40(sp)
    800009c0:	7402                	ld	s0,32(sp)
    800009c2:	64e2                	ld	s1,24(sp)
    800009c4:	6942                	ld	s2,16(sp)
    800009c6:	69a2                	ld	s3,8(sp)
    800009c8:	6a02                	ld	s4,0(sp)
    800009ca:	6145                	addi	sp,sp,48
    800009cc:	8082                	ret

00000000800009ce <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800009ce:	1101                	addi	sp,sp,-32
    800009d0:	ec06                	sd	ra,24(sp)
    800009d2:	e822                	sd	s0,16(sp)
    800009d4:	e426                	sd	s1,8(sp)
    800009d6:	1000                	addi	s0,sp,32
    800009d8:	84aa                	mv	s1,a0
  if(sz > 0)
    800009da:	e999                	bnez	a1,800009f0 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800009dc:	8526                	mv	a0,s1
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	f86080e7          	jalr	-122(ra) # 80000964 <freewalk>
}
    800009e6:	60e2                	ld	ra,24(sp)
    800009e8:	6442                	ld	s0,16(sp)
    800009ea:	64a2                	ld	s1,8(sp)
    800009ec:	6105                	addi	sp,sp,32
    800009ee:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800009f0:	6605                	lui	a2,0x1
    800009f2:	167d                	addi	a2,a2,-1
    800009f4:	962e                	add	a2,a2,a1
    800009f6:	4685                	li	a3,1
    800009f8:	8231                	srli	a2,a2,0xc
    800009fa:	4581                	li	a1,0
    800009fc:	00000097          	auipc	ra,0x0
    80000a00:	d12080e7          	jalr	-750(ra) # 8000070e <uvmunmap>
    80000a04:	bfe1                	j	800009dc <uvmfree+0xe>

0000000080000a06 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80000a06:	c679                	beqz	a2,80000ad4 <uvmcopy+0xce>
{
    80000a08:	715d                	addi	sp,sp,-80
    80000a0a:	e486                	sd	ra,72(sp)
    80000a0c:	e0a2                	sd	s0,64(sp)
    80000a0e:	fc26                	sd	s1,56(sp)
    80000a10:	f84a                	sd	s2,48(sp)
    80000a12:	f44e                	sd	s3,40(sp)
    80000a14:	f052                	sd	s4,32(sp)
    80000a16:	ec56                	sd	s5,24(sp)
    80000a18:	e85a                	sd	s6,16(sp)
    80000a1a:	e45e                	sd	s7,8(sp)
    80000a1c:	0880                	addi	s0,sp,80
    80000a1e:	8b2a                	mv	s6,a0
    80000a20:	8aae                	mv	s5,a1
    80000a22:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80000a24:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80000a26:	4601                	li	a2,0
    80000a28:	85ce                	mv	a1,s3
    80000a2a:	855a                	mv	a0,s6
    80000a2c:	00000097          	auipc	ra,0x0
    80000a30:	a34080e7          	jalr	-1484(ra) # 80000460 <walk>
    80000a34:	c531                	beqz	a0,80000a80 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000a36:	6118                	ld	a4,0(a0)
    80000a38:	00177793          	andi	a5,a4,1
    80000a3c:	cbb1                	beqz	a5,80000a90 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000a3e:	00a75593          	srli	a1,a4,0xa
    80000a42:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000a46:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80000a4a:	fffff097          	auipc	ra,0xfffff
    80000a4e:	6ce080e7          	jalr	1742(ra) # 80000118 <kalloc>
    80000a52:	892a                	mv	s2,a0
    80000a54:	c939                	beqz	a0,80000aaa <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000a56:	6605                	lui	a2,0x1
    80000a58:	85de                	mv	a1,s7
    80000a5a:	fffff097          	auipc	ra,0xfffff
    80000a5e:	77e080e7          	jalr	1918(ra) # 800001d8 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80000a62:	8726                	mv	a4,s1
    80000a64:	86ca                	mv	a3,s2
    80000a66:	6605                	lui	a2,0x1
    80000a68:	85ce                	mv	a1,s3
    80000a6a:	8556                	mv	a0,s5
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	adc080e7          	jalr	-1316(ra) # 80000548 <mappages>
    80000a74:	e515                	bnez	a0,80000aa0 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80000a76:	6785                	lui	a5,0x1
    80000a78:	99be                	add	s3,s3,a5
    80000a7a:	fb49e6e3          	bltu	s3,s4,80000a26 <uvmcopy+0x20>
    80000a7e:	a081                	j	80000abe <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80000a80:	00007517          	auipc	a0,0x7
    80000a84:	68850513          	addi	a0,a0,1672 # 80008108 <etext+0x108>
    80000a88:	00005097          	auipc	ra,0x5
    80000a8c:	1c0080e7          	jalr	448(ra) # 80005c48 <panic>
      panic("uvmcopy: page not present");
    80000a90:	00007517          	auipc	a0,0x7
    80000a94:	69850513          	addi	a0,a0,1688 # 80008128 <etext+0x128>
    80000a98:	00005097          	auipc	ra,0x5
    80000a9c:	1b0080e7          	jalr	432(ra) # 80005c48 <panic>
      kfree(mem);
    80000aa0:	854a                	mv	a0,s2
    80000aa2:	fffff097          	auipc	ra,0xfffff
    80000aa6:	57a080e7          	jalr	1402(ra) # 8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000aaa:	4685                	li	a3,1
    80000aac:	00c9d613          	srli	a2,s3,0xc
    80000ab0:	4581                	li	a1,0
    80000ab2:	8556                	mv	a0,s5
    80000ab4:	00000097          	auipc	ra,0x0
    80000ab8:	c5a080e7          	jalr	-934(ra) # 8000070e <uvmunmap>
  return -1;
    80000abc:	557d                	li	a0,-1
}
    80000abe:	60a6                	ld	ra,72(sp)
    80000ac0:	6406                	ld	s0,64(sp)
    80000ac2:	74e2                	ld	s1,56(sp)
    80000ac4:	7942                	ld	s2,48(sp)
    80000ac6:	79a2                	ld	s3,40(sp)
    80000ac8:	7a02                	ld	s4,32(sp)
    80000aca:	6ae2                	ld	s5,24(sp)
    80000acc:	6b42                	ld	s6,16(sp)
    80000ace:	6ba2                	ld	s7,8(sp)
    80000ad0:	6161                	addi	sp,sp,80
    80000ad2:	8082                	ret
  return 0;
    80000ad4:	4501                	li	a0,0
}
    80000ad6:	8082                	ret

0000000080000ad8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000ad8:	1141                	addi	sp,sp,-16
    80000ada:	e406                	sd	ra,8(sp)
    80000adc:	e022                	sd	s0,0(sp)
    80000ade:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000ae0:	4601                	li	a2,0
    80000ae2:	00000097          	auipc	ra,0x0
    80000ae6:	97e080e7          	jalr	-1666(ra) # 80000460 <walk>
  if(pte == 0)
    80000aea:	c901                	beqz	a0,80000afa <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000aec:	611c                	ld	a5,0(a0)
    80000aee:	9bbd                	andi	a5,a5,-17
    80000af0:	e11c                	sd	a5,0(a0)
}
    80000af2:	60a2                	ld	ra,8(sp)
    80000af4:	6402                	ld	s0,0(sp)
    80000af6:	0141                	addi	sp,sp,16
    80000af8:	8082                	ret
    panic("uvmclear");
    80000afa:	00007517          	auipc	a0,0x7
    80000afe:	64e50513          	addi	a0,a0,1614 # 80008148 <etext+0x148>
    80000b02:	00005097          	auipc	ra,0x5
    80000b06:	146080e7          	jalr	326(ra) # 80005c48 <panic>

0000000080000b0a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000b0a:	c6bd                	beqz	a3,80000b78 <copyout+0x6e>
{
    80000b0c:	715d                	addi	sp,sp,-80
    80000b0e:	e486                	sd	ra,72(sp)
    80000b10:	e0a2                	sd	s0,64(sp)
    80000b12:	fc26                	sd	s1,56(sp)
    80000b14:	f84a                	sd	s2,48(sp)
    80000b16:	f44e                	sd	s3,40(sp)
    80000b18:	f052                	sd	s4,32(sp)
    80000b1a:	ec56                	sd	s5,24(sp)
    80000b1c:	e85a                	sd	s6,16(sp)
    80000b1e:	e45e                	sd	s7,8(sp)
    80000b20:	e062                	sd	s8,0(sp)
    80000b22:	0880                	addi	s0,sp,80
    80000b24:	8b2a                	mv	s6,a0
    80000b26:	8c2e                	mv	s8,a1
    80000b28:	8a32                	mv	s4,a2
    80000b2a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000b2c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80000b2e:	6a85                	lui	s5,0x1
    80000b30:	a015                	j	80000b54 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000b32:	9562                	add	a0,a0,s8
    80000b34:	0004861b          	sext.w	a2,s1
    80000b38:	85d2                	mv	a1,s4
    80000b3a:	41250533          	sub	a0,a0,s2
    80000b3e:	fffff097          	auipc	ra,0xfffff
    80000b42:	69a080e7          	jalr	1690(ra) # 800001d8 <memmove>

    len -= n;
    80000b46:	409989b3          	sub	s3,s3,s1
    src += n;
    80000b4a:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80000b4c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000b50:	02098263          	beqz	s3,80000b74 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80000b54:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000b58:	85ca                	mv	a1,s2
    80000b5a:	855a                	mv	a0,s6
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	9aa080e7          	jalr	-1622(ra) # 80000506 <walkaddr>
    if(pa0 == 0)
    80000b64:	cd01                	beqz	a0,80000b7c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80000b66:	418904b3          	sub	s1,s2,s8
    80000b6a:	94d6                	add	s1,s1,s5
    if(n > len)
    80000b6c:	fc99f3e3          	bgeu	s3,s1,80000b32 <copyout+0x28>
    80000b70:	84ce                	mv	s1,s3
    80000b72:	b7c1                	j	80000b32 <copyout+0x28>
  }
  return 0;
    80000b74:	4501                	li	a0,0
    80000b76:	a021                	j	80000b7e <copyout+0x74>
    80000b78:	4501                	li	a0,0
}
    80000b7a:	8082                	ret
      return -1;
    80000b7c:	557d                	li	a0,-1
}
    80000b7e:	60a6                	ld	ra,72(sp)
    80000b80:	6406                	ld	s0,64(sp)
    80000b82:	74e2                	ld	s1,56(sp)
    80000b84:	7942                	ld	s2,48(sp)
    80000b86:	79a2                	ld	s3,40(sp)
    80000b88:	7a02                	ld	s4,32(sp)
    80000b8a:	6ae2                	ld	s5,24(sp)
    80000b8c:	6b42                	ld	s6,16(sp)
    80000b8e:	6ba2                	ld	s7,8(sp)
    80000b90:	6c02                	ld	s8,0(sp)
    80000b92:	6161                	addi	sp,sp,80
    80000b94:	8082                	ret

0000000080000b96 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000b96:	c6bd                	beqz	a3,80000c04 <copyin+0x6e>
{
    80000b98:	715d                	addi	sp,sp,-80
    80000b9a:	e486                	sd	ra,72(sp)
    80000b9c:	e0a2                	sd	s0,64(sp)
    80000b9e:	fc26                	sd	s1,56(sp)
    80000ba0:	f84a                	sd	s2,48(sp)
    80000ba2:	f44e                	sd	s3,40(sp)
    80000ba4:	f052                	sd	s4,32(sp)
    80000ba6:	ec56                	sd	s5,24(sp)
    80000ba8:	e85a                	sd	s6,16(sp)
    80000baa:	e45e                	sd	s7,8(sp)
    80000bac:	e062                	sd	s8,0(sp)
    80000bae:	0880                	addi	s0,sp,80
    80000bb0:	8b2a                	mv	s6,a0
    80000bb2:	8a2e                	mv	s4,a1
    80000bb4:	8c32                	mv	s8,a2
    80000bb6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000bb8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000bba:	6a85                	lui	s5,0x1
    80000bbc:	a015                	j	80000be0 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000bbe:	9562                	add	a0,a0,s8
    80000bc0:	0004861b          	sext.w	a2,s1
    80000bc4:	412505b3          	sub	a1,a0,s2
    80000bc8:	8552                	mv	a0,s4
    80000bca:	fffff097          	auipc	ra,0xfffff
    80000bce:	60e080e7          	jalr	1550(ra) # 800001d8 <memmove>

    len -= n;
    80000bd2:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000bd6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000bd8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000bdc:	02098263          	beqz	s3,80000c00 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80000be0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000be4:	85ca                	mv	a1,s2
    80000be6:	855a                	mv	a0,s6
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	91e080e7          	jalr	-1762(ra) # 80000506 <walkaddr>
    if(pa0 == 0)
    80000bf0:	cd01                	beqz	a0,80000c08 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80000bf2:	418904b3          	sub	s1,s2,s8
    80000bf6:	94d6                	add	s1,s1,s5
    if(n > len)
    80000bf8:	fc99f3e3          	bgeu	s3,s1,80000bbe <copyin+0x28>
    80000bfc:	84ce                	mv	s1,s3
    80000bfe:	b7c1                	j	80000bbe <copyin+0x28>
  }
  return 0;
    80000c00:	4501                	li	a0,0
    80000c02:	a021                	j	80000c0a <copyin+0x74>
    80000c04:	4501                	li	a0,0
}
    80000c06:	8082                	ret
      return -1;
    80000c08:	557d                	li	a0,-1
}
    80000c0a:	60a6                	ld	ra,72(sp)
    80000c0c:	6406                	ld	s0,64(sp)
    80000c0e:	74e2                	ld	s1,56(sp)
    80000c10:	7942                	ld	s2,48(sp)
    80000c12:	79a2                	ld	s3,40(sp)
    80000c14:	7a02                	ld	s4,32(sp)
    80000c16:	6ae2                	ld	s5,24(sp)
    80000c18:	6b42                	ld	s6,16(sp)
    80000c1a:	6ba2                	ld	s7,8(sp)
    80000c1c:	6c02                	ld	s8,0(sp)
    80000c1e:	6161                	addi	sp,sp,80
    80000c20:	8082                	ret

0000000080000c22 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000c22:	c6c5                	beqz	a3,80000cca <copyinstr+0xa8>
{
    80000c24:	715d                	addi	sp,sp,-80
    80000c26:	e486                	sd	ra,72(sp)
    80000c28:	e0a2                	sd	s0,64(sp)
    80000c2a:	fc26                	sd	s1,56(sp)
    80000c2c:	f84a                	sd	s2,48(sp)
    80000c2e:	f44e                	sd	s3,40(sp)
    80000c30:	f052                	sd	s4,32(sp)
    80000c32:	ec56                	sd	s5,24(sp)
    80000c34:	e85a                	sd	s6,16(sp)
    80000c36:	e45e                	sd	s7,8(sp)
    80000c38:	0880                	addi	s0,sp,80
    80000c3a:	8a2a                	mv	s4,a0
    80000c3c:	8b2e                	mv	s6,a1
    80000c3e:	8bb2                	mv	s7,a2
    80000c40:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000c42:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000c44:	6985                	lui	s3,0x1
    80000c46:	a035                	j	80000c72 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000c48:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000c4c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000c4e:	0017b793          	seqz	a5,a5
    80000c52:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000c56:	60a6                	ld	ra,72(sp)
    80000c58:	6406                	ld	s0,64(sp)
    80000c5a:	74e2                	ld	s1,56(sp)
    80000c5c:	7942                	ld	s2,48(sp)
    80000c5e:	79a2                	ld	s3,40(sp)
    80000c60:	7a02                	ld	s4,32(sp)
    80000c62:	6ae2                	ld	s5,24(sp)
    80000c64:	6b42                	ld	s6,16(sp)
    80000c66:	6ba2                	ld	s7,8(sp)
    80000c68:	6161                	addi	sp,sp,80
    80000c6a:	8082                	ret
    srcva = va0 + PGSIZE;
    80000c6c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000c70:	c8a9                	beqz	s1,80000cc2 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80000c72:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000c76:	85ca                	mv	a1,s2
    80000c78:	8552                	mv	a0,s4
    80000c7a:	00000097          	auipc	ra,0x0
    80000c7e:	88c080e7          	jalr	-1908(ra) # 80000506 <walkaddr>
    if(pa0 == 0)
    80000c82:	c131                	beqz	a0,80000cc6 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80000c84:	41790833          	sub	a6,s2,s7
    80000c88:	984e                	add	a6,a6,s3
    if(n > max)
    80000c8a:	0104f363          	bgeu	s1,a6,80000c90 <copyinstr+0x6e>
    80000c8e:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000c90:	955e                	add	a0,a0,s7
    80000c92:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000c96:	fc080be3          	beqz	a6,80000c6c <copyinstr+0x4a>
    80000c9a:	985a                	add	a6,a6,s6
    80000c9c:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000c9e:	41650633          	sub	a2,a0,s6
    80000ca2:	14fd                	addi	s1,s1,-1
    80000ca4:	9b26                	add	s6,s6,s1
    80000ca6:	00f60733          	add	a4,a2,a5
    80000caa:	00074703          	lbu	a4,0(a4)
    80000cae:	df49                	beqz	a4,80000c48 <copyinstr+0x26>
        *dst = *p;
    80000cb0:	00e78023          	sb	a4,0(a5)
      --max;
    80000cb4:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80000cb8:	0785                	addi	a5,a5,1
    while(n > 0){
    80000cba:	ff0796e3          	bne	a5,a6,80000ca6 <copyinstr+0x84>
      dst++;
    80000cbe:	8b42                	mv	s6,a6
    80000cc0:	b775                	j	80000c6c <copyinstr+0x4a>
    80000cc2:	4781                	li	a5,0
    80000cc4:	b769                	j	80000c4e <copyinstr+0x2c>
      return -1;
    80000cc6:	557d                	li	a0,-1
    80000cc8:	b779                	j	80000c56 <copyinstr+0x34>
  int got_null = 0;
    80000cca:	4781                	li	a5,0
  if(got_null){
    80000ccc:	0017b793          	seqz	a5,a5
    80000cd0:	40f00533          	neg	a0,a5
}
    80000cd4:	8082                	ret

0000000080000cd6 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80000cd6:	7139                	addi	sp,sp,-64
    80000cd8:	fc06                	sd	ra,56(sp)
    80000cda:	f822                	sd	s0,48(sp)
    80000cdc:	f426                	sd	s1,40(sp)
    80000cde:	f04a                	sd	s2,32(sp)
    80000ce0:	ec4e                	sd	s3,24(sp)
    80000ce2:	e852                	sd	s4,16(sp)
    80000ce4:	e456                	sd	s5,8(sp)
    80000ce6:	e05a                	sd	s6,0(sp)
    80000ce8:	0080                	addi	s0,sp,64
    80000cea:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cec:	00008497          	auipc	s1,0x8
    80000cf0:	79448493          	addi	s1,s1,1940 # 80009480 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000cf4:	8b26                	mv	s6,s1
    80000cf6:	00007a97          	auipc	s5,0x7
    80000cfa:	30aa8a93          	addi	s5,s5,778 # 80008000 <etext>
    80000cfe:	04000937          	lui	s2,0x4000
    80000d02:	197d                	addi	s2,s2,-1
    80000d04:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d06:	0000fa17          	auipc	s4,0xf
    80000d0a:	b7aa0a13          	addi	s4,s4,-1158 # 8000f880 <tickslock>
    char *pa = kalloc();
    80000d0e:	fffff097          	auipc	ra,0xfffff
    80000d12:	40a080e7          	jalr	1034(ra) # 80000118 <kalloc>
    80000d16:	862a                	mv	a2,a0
    if(pa == 0)
    80000d18:	c131                	beqz	a0,80000d5c <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000d1a:	416485b3          	sub	a1,s1,s6
    80000d1e:	8591                	srai	a1,a1,0x4
    80000d20:	000ab783          	ld	a5,0(s5)
    80000d24:	02f585b3          	mul	a1,a1,a5
    80000d28:	2585                	addiw	a1,a1,1
    80000d2a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000d2e:	4719                	li	a4,6
    80000d30:	6685                	lui	a3,0x1
    80000d32:	40b905b3          	sub	a1,s2,a1
    80000d36:	854e                	mv	a0,s3
    80000d38:	00000097          	auipc	ra,0x0
    80000d3c:	8b0080e7          	jalr	-1872(ra) # 800005e8 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d40:	19048493          	addi	s1,s1,400
    80000d44:	fd4495e3          	bne	s1,s4,80000d0e <proc_mapstacks+0x38>
  }
}
    80000d48:	70e2                	ld	ra,56(sp)
    80000d4a:	7442                	ld	s0,48(sp)
    80000d4c:	74a2                	ld	s1,40(sp)
    80000d4e:	7902                	ld	s2,32(sp)
    80000d50:	69e2                	ld	s3,24(sp)
    80000d52:	6a42                	ld	s4,16(sp)
    80000d54:	6aa2                	ld	s5,8(sp)
    80000d56:	6b02                	ld	s6,0(sp)
    80000d58:	6121                	addi	sp,sp,64
    80000d5a:	8082                	ret
      panic("kalloc");
    80000d5c:	00007517          	auipc	a0,0x7
    80000d60:	3fc50513          	addi	a0,a0,1020 # 80008158 <etext+0x158>
    80000d64:	00005097          	auipc	ra,0x5
    80000d68:	ee4080e7          	jalr	-284(ra) # 80005c48 <panic>

0000000080000d6c <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80000d6c:	7139                	addi	sp,sp,-64
    80000d6e:	fc06                	sd	ra,56(sp)
    80000d70:	f822                	sd	s0,48(sp)
    80000d72:	f426                	sd	s1,40(sp)
    80000d74:	f04a                	sd	s2,32(sp)
    80000d76:	ec4e                	sd	s3,24(sp)
    80000d78:	e852                	sd	s4,16(sp)
    80000d7a:	e456                	sd	s5,8(sp)
    80000d7c:	e05a                	sd	s6,0(sp)
    80000d7e:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000d80:	00007597          	auipc	a1,0x7
    80000d84:	3e058593          	addi	a1,a1,992 # 80008160 <etext+0x160>
    80000d88:	00008517          	auipc	a0,0x8
    80000d8c:	2c850513          	addi	a0,a0,712 # 80009050 <pid_lock>
    80000d90:	00005097          	auipc	ra,0x5
    80000d94:	3ce080e7          	jalr	974(ra) # 8000615e <initlock>
  initlock(&wait_lock, "wait_lock");
    80000d98:	00007597          	auipc	a1,0x7
    80000d9c:	3d058593          	addi	a1,a1,976 # 80008168 <etext+0x168>
    80000da0:	00008517          	auipc	a0,0x8
    80000da4:	2c850513          	addi	a0,a0,712 # 80009068 <wait_lock>
    80000da8:	00005097          	auipc	ra,0x5
    80000dac:	3b6080e7          	jalr	950(ra) # 8000615e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000db0:	00008497          	auipc	s1,0x8
    80000db4:	6d048493          	addi	s1,s1,1744 # 80009480 <proc>
      initlock(&p->lock, "proc");
    80000db8:	00007b17          	auipc	s6,0x7
    80000dbc:	3c0b0b13          	addi	s6,s6,960 # 80008178 <etext+0x178>
      p->kstack = KSTACK((int) (p - proc));
    80000dc0:	8aa6                	mv	s5,s1
    80000dc2:	00007a17          	auipc	s4,0x7
    80000dc6:	23ea0a13          	addi	s4,s4,574 # 80008000 <etext>
    80000dca:	04000937          	lui	s2,0x4000
    80000dce:	197d                	addi	s2,s2,-1
    80000dd0:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dd2:	0000f997          	auipc	s3,0xf
    80000dd6:	aae98993          	addi	s3,s3,-1362 # 8000f880 <tickslock>
      initlock(&p->lock, "proc");
    80000dda:	85da                	mv	a1,s6
    80000ddc:	8526                	mv	a0,s1
    80000dde:	00005097          	auipc	ra,0x5
    80000de2:	380080e7          	jalr	896(ra) # 8000615e <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80000de6:	415487b3          	sub	a5,s1,s5
    80000dea:	8791                	srai	a5,a5,0x4
    80000dec:	000a3703          	ld	a4,0(s4)
    80000df0:	02e787b3          	mul	a5,a5,a4
    80000df4:	2785                	addiw	a5,a5,1
    80000df6:	00d7979b          	slliw	a5,a5,0xd
    80000dfa:	40f907b3          	sub	a5,s2,a5
    80000dfe:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e00:	19048493          	addi	s1,s1,400
    80000e04:	fd349be3          	bne	s1,s3,80000dda <procinit+0x6e>
  }
}
    80000e08:	70e2                	ld	ra,56(sp)
    80000e0a:	7442                	ld	s0,48(sp)
    80000e0c:	74a2                	ld	s1,40(sp)
    80000e0e:	7902                	ld	s2,32(sp)
    80000e10:	69e2                	ld	s3,24(sp)
    80000e12:	6a42                	ld	s4,16(sp)
    80000e14:	6aa2                	ld	s5,8(sp)
    80000e16:	6b02                	ld	s6,0(sp)
    80000e18:	6121                	addi	sp,sp,64
    80000e1a:	8082                	ret

0000000080000e1c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e22:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000e24:	2501                	sext.w	a0,a0
    80000e26:	6422                	ld	s0,8(sp)
    80000e28:	0141                	addi	sp,sp,16
    80000e2a:	8082                	ret

0000000080000e2c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80000e2c:	1141                	addi	sp,sp,-16
    80000e2e:	e422                	sd	s0,8(sp)
    80000e30:	0800                	addi	s0,sp,16
    80000e32:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000e34:	2781                	sext.w	a5,a5
    80000e36:	079e                	slli	a5,a5,0x7
  return c;
}
    80000e38:	00008517          	auipc	a0,0x8
    80000e3c:	24850513          	addi	a0,a0,584 # 80009080 <cpus>
    80000e40:	953e                	add	a0,a0,a5
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80000e48:	1101                	addi	sp,sp,-32
    80000e4a:	ec06                	sd	ra,24(sp)
    80000e4c:	e822                	sd	s0,16(sp)
    80000e4e:	e426                	sd	s1,8(sp)
    80000e50:	1000                	addi	s0,sp,32
  push_off();
    80000e52:	00005097          	auipc	ra,0x5
    80000e56:	350080e7          	jalr	848(ra) # 800061a2 <push_off>
    80000e5a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000e5c:	2781                	sext.w	a5,a5
    80000e5e:	079e                	slli	a5,a5,0x7
    80000e60:	00008717          	auipc	a4,0x8
    80000e64:	1f070713          	addi	a4,a4,496 # 80009050 <pid_lock>
    80000e68:	97ba                	add	a5,a5,a4
    80000e6a:	7b84                	ld	s1,48(a5)
  pop_off();
    80000e6c:	00005097          	auipc	ra,0x5
    80000e70:	3d6080e7          	jalr	982(ra) # 80006242 <pop_off>
  return p;
}
    80000e74:	8526                	mv	a0,s1
    80000e76:	60e2                	ld	ra,24(sp)
    80000e78:	6442                	ld	s0,16(sp)
    80000e7a:	64a2                	ld	s1,8(sp)
    80000e7c:	6105                	addi	sp,sp,32
    80000e7e:	8082                	ret

0000000080000e80 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000e80:	1141                	addi	sp,sp,-16
    80000e82:	e406                	sd	ra,8(sp)
    80000e84:	e022                	sd	s0,0(sp)
    80000e86:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000e88:	00000097          	auipc	ra,0x0
    80000e8c:	fc0080e7          	jalr	-64(ra) # 80000e48 <myproc>
    80000e90:	00005097          	auipc	ra,0x5
    80000e94:	412080e7          	jalr	1042(ra) # 800062a2 <release>

  if (first) {
    80000e98:	00008797          	auipc	a5,0x8
    80000e9c:	9b87a783          	lw	a5,-1608(a5) # 80008850 <first.1682>
    80000ea0:	eb89                	bnez	a5,80000eb2 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80000ea2:	00001097          	auipc	ra,0x1
    80000ea6:	c60080e7          	jalr	-928(ra) # 80001b02 <usertrapret>
}
    80000eaa:	60a2                	ld	ra,8(sp)
    80000eac:	6402                	ld	s0,0(sp)
    80000eae:	0141                	addi	sp,sp,16
    80000eb0:	8082                	ret
    first = 0;
    80000eb2:	00008797          	auipc	a5,0x8
    80000eb6:	9807af23          	sw	zero,-1634(a5) # 80008850 <first.1682>
    fsinit(ROOTDEV);
    80000eba:	4505                	li	a0,1
    80000ebc:	00002097          	auipc	ra,0x2
    80000ec0:	a66080e7          	jalr	-1434(ra) # 80002922 <fsinit>
    80000ec4:	bff9                	j	80000ea2 <forkret+0x22>

0000000080000ec6 <allocpid>:
allocpid() {
    80000ec6:	1101                	addi	sp,sp,-32
    80000ec8:	ec06                	sd	ra,24(sp)
    80000eca:	e822                	sd	s0,16(sp)
    80000ecc:	e426                	sd	s1,8(sp)
    80000ece:	e04a                	sd	s2,0(sp)
    80000ed0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000ed2:	00008917          	auipc	s2,0x8
    80000ed6:	17e90913          	addi	s2,s2,382 # 80009050 <pid_lock>
    80000eda:	854a                	mv	a0,s2
    80000edc:	00005097          	auipc	ra,0x5
    80000ee0:	312080e7          	jalr	786(ra) # 800061ee <acquire>
  pid = nextpid;
    80000ee4:	00008797          	auipc	a5,0x8
    80000ee8:	97078793          	addi	a5,a5,-1680 # 80008854 <nextpid>
    80000eec:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000eee:	0014871b          	addiw	a4,s1,1
    80000ef2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000ef4:	854a                	mv	a0,s2
    80000ef6:	00005097          	auipc	ra,0x5
    80000efa:	3ac080e7          	jalr	940(ra) # 800062a2 <release>
}
    80000efe:	8526                	mv	a0,s1
    80000f00:	60e2                	ld	ra,24(sp)
    80000f02:	6442                	ld	s0,16(sp)
    80000f04:	64a2                	ld	s1,8(sp)
    80000f06:	6902                	ld	s2,0(sp)
    80000f08:	6105                	addi	sp,sp,32
    80000f0a:	8082                	ret

0000000080000f0c <proc_pagetable>:
{
    80000f0c:	1101                	addi	sp,sp,-32
    80000f0e:	ec06                	sd	ra,24(sp)
    80000f10:	e822                	sd	s0,16(sp)
    80000f12:	e426                	sd	s1,8(sp)
    80000f14:	e04a                	sd	s2,0(sp)
    80000f16:	1000                	addi	s0,sp,32
    80000f18:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	8b8080e7          	jalr	-1864(ra) # 800007d2 <uvmcreate>
    80000f22:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000f24:	c121                	beqz	a0,80000f64 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000f26:	4729                	li	a4,10
    80000f28:	00006697          	auipc	a3,0x6
    80000f2c:	0d868693          	addi	a3,a3,216 # 80007000 <_trampoline>
    80000f30:	6605                	lui	a2,0x1
    80000f32:	040005b7          	lui	a1,0x4000
    80000f36:	15fd                	addi	a1,a1,-1
    80000f38:	05b2                	slli	a1,a1,0xc
    80000f3a:	fffff097          	auipc	ra,0xfffff
    80000f3e:	60e080e7          	jalr	1550(ra) # 80000548 <mappages>
    80000f42:	02054863          	bltz	a0,80000f72 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000f46:	4719                	li	a4,6
    80000f48:	05893683          	ld	a3,88(s2)
    80000f4c:	6605                	lui	a2,0x1
    80000f4e:	020005b7          	lui	a1,0x2000
    80000f52:	15fd                	addi	a1,a1,-1
    80000f54:	05b6                	slli	a1,a1,0xd
    80000f56:	8526                	mv	a0,s1
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	5f0080e7          	jalr	1520(ra) # 80000548 <mappages>
    80000f60:	02054163          	bltz	a0,80000f82 <proc_pagetable+0x76>
}
    80000f64:	8526                	mv	a0,s1
    80000f66:	60e2                	ld	ra,24(sp)
    80000f68:	6442                	ld	s0,16(sp)
    80000f6a:	64a2                	ld	s1,8(sp)
    80000f6c:	6902                	ld	s2,0(sp)
    80000f6e:	6105                	addi	sp,sp,32
    80000f70:	8082                	ret
    uvmfree(pagetable, 0);
    80000f72:	4581                	li	a1,0
    80000f74:	8526                	mv	a0,s1
    80000f76:	00000097          	auipc	ra,0x0
    80000f7a:	a58080e7          	jalr	-1448(ra) # 800009ce <uvmfree>
    return 0;
    80000f7e:	4481                	li	s1,0
    80000f80:	b7d5                	j	80000f64 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f82:	4681                	li	a3,0
    80000f84:	4605                	li	a2,1
    80000f86:	040005b7          	lui	a1,0x4000
    80000f8a:	15fd                	addi	a1,a1,-1
    80000f8c:	05b2                	slli	a1,a1,0xc
    80000f8e:	8526                	mv	a0,s1
    80000f90:	fffff097          	auipc	ra,0xfffff
    80000f94:	77e080e7          	jalr	1918(ra) # 8000070e <uvmunmap>
    uvmfree(pagetable, 0);
    80000f98:	4581                	li	a1,0
    80000f9a:	8526                	mv	a0,s1
    80000f9c:	00000097          	auipc	ra,0x0
    80000fa0:	a32080e7          	jalr	-1486(ra) # 800009ce <uvmfree>
    return 0;
    80000fa4:	4481                	li	s1,0
    80000fa6:	bf7d                	j	80000f64 <proc_pagetable+0x58>

0000000080000fa8 <proc_freepagetable>:
{
    80000fa8:	1101                	addi	sp,sp,-32
    80000faa:	ec06                	sd	ra,24(sp)
    80000fac:	e822                	sd	s0,16(sp)
    80000fae:	e426                	sd	s1,8(sp)
    80000fb0:	e04a                	sd	s2,0(sp)
    80000fb2:	1000                	addi	s0,sp,32
    80000fb4:	84aa                	mv	s1,a0
    80000fb6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000fb8:	4681                	li	a3,0
    80000fba:	4605                	li	a2,1
    80000fbc:	040005b7          	lui	a1,0x4000
    80000fc0:	15fd                	addi	a1,a1,-1
    80000fc2:	05b2                	slli	a1,a1,0xc
    80000fc4:	fffff097          	auipc	ra,0xfffff
    80000fc8:	74a080e7          	jalr	1866(ra) # 8000070e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000fcc:	4681                	li	a3,0
    80000fce:	4605                	li	a2,1
    80000fd0:	020005b7          	lui	a1,0x2000
    80000fd4:	15fd                	addi	a1,a1,-1
    80000fd6:	05b6                	slli	a1,a1,0xd
    80000fd8:	8526                	mv	a0,s1
    80000fda:	fffff097          	auipc	ra,0xfffff
    80000fde:	734080e7          	jalr	1844(ra) # 8000070e <uvmunmap>
  uvmfree(pagetable, sz);
    80000fe2:	85ca                	mv	a1,s2
    80000fe4:	8526                	mv	a0,s1
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	9e8080e7          	jalr	-1560(ra) # 800009ce <uvmfree>
}
    80000fee:	60e2                	ld	ra,24(sp)
    80000ff0:	6442                	ld	s0,16(sp)
    80000ff2:	64a2                	ld	s1,8(sp)
    80000ff4:	6902                	ld	s2,0(sp)
    80000ff6:	6105                	addi	sp,sp,32
    80000ff8:	8082                	ret

0000000080000ffa <freeproc>:
{
    80000ffa:	1101                	addi	sp,sp,-32
    80000ffc:	ec06                	sd	ra,24(sp)
    80000ffe:	e822                	sd	s0,16(sp)
    80001000:	e426                	sd	s1,8(sp)
    80001002:	1000                	addi	s0,sp,32
    80001004:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001006:	6d28                	ld	a0,88(a0)
    80001008:	c509                	beqz	a0,80001012 <freeproc+0x18>
    kfree((void*)p->trapframe);
    8000100a:	fffff097          	auipc	ra,0xfffff
    8000100e:	012080e7          	jalr	18(ra) # 8000001c <kfree>
  if(p->alarm_tf)
    80001012:	1804b503          	ld	a0,384(s1)
    80001016:	c509                	beqz	a0,80001020 <freeproc+0x26>
    kfree((void*)p->alarm_tf);
    80001018:	fffff097          	auipc	ra,0xfffff
    8000101c:	004080e7          	jalr	4(ra) # 8000001c <kfree>
  p->trapframe = 0;
    80001020:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001024:	68a8                	ld	a0,80(s1)
    80001026:	c511                	beqz	a0,80001032 <freeproc+0x38>
    proc_freepagetable(p->pagetable, p->sz);
    80001028:	64ac                	ld	a1,72(s1)
    8000102a:	00000097          	auipc	ra,0x0
    8000102e:	f7e080e7          	jalr	-130(ra) # 80000fa8 <proc_freepagetable>
  p->pagetable = 0;
    80001032:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001036:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    8000103a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000103e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001042:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001046:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    8000104a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000104e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001052:	0004ac23          	sw	zero,24(s1)
 p->alarm_interval = 0;
    80001056:	1604a423          	sw	zero,360(s1)
  p->alarm_handler = 0;
    8000105a:	1604b823          	sd	zero,368(s1)
  p->ticks_since_alarm = 0;
    8000105e:	1604ac23          	sw	zero,376(s1)
  p->in_alarm_handler = 0;
    80001062:	1804a423          	sw	zero,392(s1)
}
    80001066:	60e2                	ld	ra,24(sp)
    80001068:	6442                	ld	s0,16(sp)
    8000106a:	64a2                	ld	s1,8(sp)
    8000106c:	6105                	addi	sp,sp,32
    8000106e:	8082                	ret

0000000080001070 <allocproc>:
{
    80001070:	1101                	addi	sp,sp,-32
    80001072:	ec06                	sd	ra,24(sp)
    80001074:	e822                	sd	s0,16(sp)
    80001076:	e426                	sd	s1,8(sp)
    80001078:	e04a                	sd	s2,0(sp)
    8000107a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000107c:	00008497          	auipc	s1,0x8
    80001080:	40448493          	addi	s1,s1,1028 # 80009480 <proc>
    80001084:	0000e917          	auipc	s2,0xe
    80001088:	7fc90913          	addi	s2,s2,2044 # 8000f880 <tickslock>
    acquire(&p->lock);
    8000108c:	8526                	mv	a0,s1
    8000108e:	00005097          	auipc	ra,0x5
    80001092:	160080e7          	jalr	352(ra) # 800061ee <acquire>
    if(p->state == UNUSED) {
    80001096:	4c9c                	lw	a5,24(s1)
    80001098:	cf81                	beqz	a5,800010b0 <allocproc+0x40>
      release(&p->lock);
    8000109a:	8526                	mv	a0,s1
    8000109c:	00005097          	auipc	ra,0x5
    800010a0:	206080e7          	jalr	518(ra) # 800062a2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800010a4:	19048493          	addi	s1,s1,400
    800010a8:	ff2492e3          	bne	s1,s2,8000108c <allocproc+0x1c>
  return 0;
    800010ac:	4481                	li	s1,0
    800010ae:	a88d                	j	80001120 <allocproc+0xb0>
  p->pid = allocpid();
    800010b0:	00000097          	auipc	ra,0x0
    800010b4:	e16080e7          	jalr	-490(ra) # 80000ec6 <allocpid>
    800010b8:	d888                	sw	a0,48(s1)
  p->state = USED;
    800010ba:	4785                	li	a5,1
    800010bc:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800010be:	fffff097          	auipc	ra,0xfffff
    800010c2:	05a080e7          	jalr	90(ra) # 80000118 <kalloc>
    800010c6:	892a                	mv	s2,a0
    800010c8:	eca8                	sd	a0,88(s1)
    800010ca:	c135                	beqz	a0,8000112e <allocproc+0xbe>
    if((p->alarm_tf = (struct trapframe *)kalloc()) == 0){
    800010cc:	fffff097          	auipc	ra,0xfffff
    800010d0:	04c080e7          	jalr	76(ra) # 80000118 <kalloc>
    800010d4:	892a                	mv	s2,a0
    800010d6:	18a4b023          	sd	a0,384(s1)
    800010da:	c535                	beqz	a0,80001146 <allocproc+0xd6>
  p->pagetable = proc_pagetable(p);
    800010dc:	8526                	mv	a0,s1
    800010de:	00000097          	auipc	ra,0x0
    800010e2:	e2e080e7          	jalr	-466(ra) # 80000f0c <proc_pagetable>
    800010e6:	892a                	mv	s2,a0
    800010e8:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800010ea:	c935                	beqz	a0,8000115e <allocproc+0xee>
  memset(&p->context, 0, sizeof(p->context));
    800010ec:	07000613          	li	a2,112
    800010f0:	4581                	li	a1,0
    800010f2:	06048513          	addi	a0,s1,96
    800010f6:	fffff097          	auipc	ra,0xfffff
    800010fa:	082080e7          	jalr	130(ra) # 80000178 <memset>
  p->context.ra = (uint64)forkret;
    800010fe:	00000797          	auipc	a5,0x0
    80001102:	d8278793          	addi	a5,a5,-638 # 80000e80 <forkret>
    80001106:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001108:	60bc                	ld	a5,64(s1)
    8000110a:	6705                	lui	a4,0x1
    8000110c:	97ba                	add	a5,a5,a4
    8000110e:	f4bc                	sd	a5,104(s1)
  p->alarm_interval = 0;
    80001110:	1604a423          	sw	zero,360(s1)
  p->alarm_handler = 0;
    80001114:	1604b823          	sd	zero,368(s1)
  p->ticks_since_alarm = 0;
    80001118:	1604ac23          	sw	zero,376(s1)
  p->in_alarm_handler = 0;
    8000111c:	1804a423          	sw	zero,392(s1)
}
    80001120:	8526                	mv	a0,s1
    80001122:	60e2                	ld	ra,24(sp)
    80001124:	6442                	ld	s0,16(sp)
    80001126:	64a2                	ld	s1,8(sp)
    80001128:	6902                	ld	s2,0(sp)
    8000112a:	6105                	addi	sp,sp,32
    8000112c:	8082                	ret
    freeproc(p);
    8000112e:	8526                	mv	a0,s1
    80001130:	00000097          	auipc	ra,0x0
    80001134:	eca080e7          	jalr	-310(ra) # 80000ffa <freeproc>
    release(&p->lock);
    80001138:	8526                	mv	a0,s1
    8000113a:	00005097          	auipc	ra,0x5
    8000113e:	168080e7          	jalr	360(ra) # 800062a2 <release>
    return 0;
    80001142:	84ca                	mv	s1,s2
    80001144:	bff1                	j	80001120 <allocproc+0xb0>
    freeproc(p);
    80001146:	8526                	mv	a0,s1
    80001148:	00000097          	auipc	ra,0x0
    8000114c:	eb2080e7          	jalr	-334(ra) # 80000ffa <freeproc>
    release(&p->lock);
    80001150:	8526                	mv	a0,s1
    80001152:	00005097          	auipc	ra,0x5
    80001156:	150080e7          	jalr	336(ra) # 800062a2 <release>
    return 0;
    8000115a:	84ca                	mv	s1,s2
    8000115c:	b7d1                	j	80001120 <allocproc+0xb0>
    freeproc(p);
    8000115e:	8526                	mv	a0,s1
    80001160:	00000097          	auipc	ra,0x0
    80001164:	e9a080e7          	jalr	-358(ra) # 80000ffa <freeproc>
    release(&p->lock);
    80001168:	8526                	mv	a0,s1
    8000116a:	00005097          	auipc	ra,0x5
    8000116e:	138080e7          	jalr	312(ra) # 800062a2 <release>
    return 0;
    80001172:	84ca                	mv	s1,s2
    80001174:	b775                	j	80001120 <allocproc+0xb0>

0000000080001176 <userinit>:
{
    80001176:	1101                	addi	sp,sp,-32
    80001178:	ec06                	sd	ra,24(sp)
    8000117a:	e822                	sd	s0,16(sp)
    8000117c:	e426                	sd	s1,8(sp)
    8000117e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001180:	00000097          	auipc	ra,0x0
    80001184:	ef0080e7          	jalr	-272(ra) # 80001070 <allocproc>
    80001188:	84aa                	mv	s1,a0
  initproc = p;
    8000118a:	00008797          	auipc	a5,0x8
    8000118e:	e8a7b323          	sd	a0,-378(a5) # 80009010 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001192:	03400613          	li	a2,52
    80001196:	00007597          	auipc	a1,0x7
    8000119a:	6ca58593          	addi	a1,a1,1738 # 80008860 <initcode>
    8000119e:	6928                	ld	a0,80(a0)
    800011a0:	fffff097          	auipc	ra,0xfffff
    800011a4:	660080e7          	jalr	1632(ra) # 80000800 <uvminit>
  p->sz = PGSIZE;
    800011a8:	6785                	lui	a5,0x1
    800011aa:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800011ac:	6cb8                	ld	a4,88(s1)
    800011ae:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800011b2:	6cb8                	ld	a4,88(s1)
    800011b4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800011b6:	4641                	li	a2,16
    800011b8:	00007597          	auipc	a1,0x7
    800011bc:	fc858593          	addi	a1,a1,-56 # 80008180 <etext+0x180>
    800011c0:	15848513          	addi	a0,s1,344
    800011c4:	fffff097          	auipc	ra,0xfffff
    800011c8:	106080e7          	jalr	262(ra) # 800002ca <safestrcpy>
  p->cwd = namei("/");
    800011cc:	00007517          	auipc	a0,0x7
    800011d0:	fc450513          	addi	a0,a0,-60 # 80008190 <etext+0x190>
    800011d4:	00002097          	auipc	ra,0x2
    800011d8:	17c080e7          	jalr	380(ra) # 80003350 <namei>
    800011dc:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800011e0:	478d                	li	a5,3
    800011e2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800011e4:	8526                	mv	a0,s1
    800011e6:	00005097          	auipc	ra,0x5
    800011ea:	0bc080e7          	jalr	188(ra) # 800062a2 <release>
}
    800011ee:	60e2                	ld	ra,24(sp)
    800011f0:	6442                	ld	s0,16(sp)
    800011f2:	64a2                	ld	s1,8(sp)
    800011f4:	6105                	addi	sp,sp,32
    800011f6:	8082                	ret

00000000800011f8 <growproc>:
{
    800011f8:	1101                	addi	sp,sp,-32
    800011fa:	ec06                	sd	ra,24(sp)
    800011fc:	e822                	sd	s0,16(sp)
    800011fe:	e426                	sd	s1,8(sp)
    80001200:	e04a                	sd	s2,0(sp)
    80001202:	1000                	addi	s0,sp,32
    80001204:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	c42080e7          	jalr	-958(ra) # 80000e48 <myproc>
    8000120e:	892a                	mv	s2,a0
  sz = p->sz;
    80001210:	652c                	ld	a1,72(a0)
    80001212:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001216:	00904f63          	bgtz	s1,80001234 <growproc+0x3c>
  } else if(n < 0){
    8000121a:	0204cc63          	bltz	s1,80001252 <growproc+0x5a>
  p->sz = sz;
    8000121e:	1602                	slli	a2,a2,0x20
    80001220:	9201                	srli	a2,a2,0x20
    80001222:	04c93423          	sd	a2,72(s2)
  return 0;
    80001226:	4501                	li	a0,0
}
    80001228:	60e2                	ld	ra,24(sp)
    8000122a:	6442                	ld	s0,16(sp)
    8000122c:	64a2                	ld	s1,8(sp)
    8000122e:	6902                	ld	s2,0(sp)
    80001230:	6105                	addi	sp,sp,32
    80001232:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001234:	9e25                	addw	a2,a2,s1
    80001236:	1602                	slli	a2,a2,0x20
    80001238:	9201                	srli	a2,a2,0x20
    8000123a:	1582                	slli	a1,a1,0x20
    8000123c:	9181                	srli	a1,a1,0x20
    8000123e:	6928                	ld	a0,80(a0)
    80001240:	fffff097          	auipc	ra,0xfffff
    80001244:	67a080e7          	jalr	1658(ra) # 800008ba <uvmalloc>
    80001248:	0005061b          	sext.w	a2,a0
    8000124c:	fa69                	bnez	a2,8000121e <growproc+0x26>
      return -1;
    8000124e:	557d                	li	a0,-1
    80001250:	bfe1                	j	80001228 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001252:	9e25                	addw	a2,a2,s1
    80001254:	1602                	slli	a2,a2,0x20
    80001256:	9201                	srli	a2,a2,0x20
    80001258:	1582                	slli	a1,a1,0x20
    8000125a:	9181                	srli	a1,a1,0x20
    8000125c:	6928                	ld	a0,80(a0)
    8000125e:	fffff097          	auipc	ra,0xfffff
    80001262:	614080e7          	jalr	1556(ra) # 80000872 <uvmdealloc>
    80001266:	0005061b          	sext.w	a2,a0
    8000126a:	bf55                	j	8000121e <growproc+0x26>

000000008000126c <fork>:
{
    8000126c:	7179                	addi	sp,sp,-48
    8000126e:	f406                	sd	ra,40(sp)
    80001270:	f022                	sd	s0,32(sp)
    80001272:	ec26                	sd	s1,24(sp)
    80001274:	e84a                	sd	s2,16(sp)
    80001276:	e44e                	sd	s3,8(sp)
    80001278:	e052                	sd	s4,0(sp)
    8000127a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000127c:	00000097          	auipc	ra,0x0
    80001280:	bcc080e7          	jalr	-1076(ra) # 80000e48 <myproc>
    80001284:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001286:	00000097          	auipc	ra,0x0
    8000128a:	dea080e7          	jalr	-534(ra) # 80001070 <allocproc>
    8000128e:	10050b63          	beqz	a0,800013a4 <fork+0x138>
    80001292:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001294:	04893603          	ld	a2,72(s2)
    80001298:	692c                	ld	a1,80(a0)
    8000129a:	05093503          	ld	a0,80(s2)
    8000129e:	fffff097          	auipc	ra,0xfffff
    800012a2:	768080e7          	jalr	1896(ra) # 80000a06 <uvmcopy>
    800012a6:	04054663          	bltz	a0,800012f2 <fork+0x86>
  np->sz = p->sz;
    800012aa:	04893783          	ld	a5,72(s2)
    800012ae:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800012b2:	05893683          	ld	a3,88(s2)
    800012b6:	87b6                	mv	a5,a3
    800012b8:	0589b703          	ld	a4,88(s3)
    800012bc:	12068693          	addi	a3,a3,288
    800012c0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800012c4:	6788                	ld	a0,8(a5)
    800012c6:	6b8c                	ld	a1,16(a5)
    800012c8:	6f90                	ld	a2,24(a5)
    800012ca:	01073023          	sd	a6,0(a4)
    800012ce:	e708                	sd	a0,8(a4)
    800012d0:	eb0c                	sd	a1,16(a4)
    800012d2:	ef10                	sd	a2,24(a4)
    800012d4:	02078793          	addi	a5,a5,32
    800012d8:	02070713          	addi	a4,a4,32
    800012dc:	fed792e3          	bne	a5,a3,800012c0 <fork+0x54>
  np->trapframe->a0 = 0;
    800012e0:	0589b783          	ld	a5,88(s3)
    800012e4:	0607b823          	sd	zero,112(a5)
    800012e8:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    800012ec:	15000a13          	li	s4,336
    800012f0:	a03d                	j	8000131e <fork+0xb2>
    freeproc(np);
    800012f2:	854e                	mv	a0,s3
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	d06080e7          	jalr	-762(ra) # 80000ffa <freeproc>
    release(&np->lock);
    800012fc:	854e                	mv	a0,s3
    800012fe:	00005097          	auipc	ra,0x5
    80001302:	fa4080e7          	jalr	-92(ra) # 800062a2 <release>
    return -1;
    80001306:	5a7d                	li	s4,-1
    80001308:	a069                	j	80001392 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    8000130a:	00002097          	auipc	ra,0x2
    8000130e:	6dc080e7          	jalr	1756(ra) # 800039e6 <filedup>
    80001312:	009987b3          	add	a5,s3,s1
    80001316:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001318:	04a1                	addi	s1,s1,8
    8000131a:	01448763          	beq	s1,s4,80001328 <fork+0xbc>
    if(p->ofile[i])
    8000131e:	009907b3          	add	a5,s2,s1
    80001322:	6388                	ld	a0,0(a5)
    80001324:	f17d                	bnez	a0,8000130a <fork+0x9e>
    80001326:	bfcd                	j	80001318 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001328:	15093503          	ld	a0,336(s2)
    8000132c:	00002097          	auipc	ra,0x2
    80001330:	830080e7          	jalr	-2000(ra) # 80002b5c <idup>
    80001334:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001338:	4641                	li	a2,16
    8000133a:	15890593          	addi	a1,s2,344
    8000133e:	15898513          	addi	a0,s3,344
    80001342:	fffff097          	auipc	ra,0xfffff
    80001346:	f88080e7          	jalr	-120(ra) # 800002ca <safestrcpy>
  pid = np->pid;
    8000134a:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    8000134e:	854e                	mv	a0,s3
    80001350:	00005097          	auipc	ra,0x5
    80001354:	f52080e7          	jalr	-174(ra) # 800062a2 <release>
  acquire(&wait_lock);
    80001358:	00008497          	auipc	s1,0x8
    8000135c:	d1048493          	addi	s1,s1,-752 # 80009068 <wait_lock>
    80001360:	8526                	mv	a0,s1
    80001362:	00005097          	auipc	ra,0x5
    80001366:	e8c080e7          	jalr	-372(ra) # 800061ee <acquire>
  np->parent = p;
    8000136a:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    8000136e:	8526                	mv	a0,s1
    80001370:	00005097          	auipc	ra,0x5
    80001374:	f32080e7          	jalr	-206(ra) # 800062a2 <release>
  acquire(&np->lock);
    80001378:	854e                	mv	a0,s3
    8000137a:	00005097          	auipc	ra,0x5
    8000137e:	e74080e7          	jalr	-396(ra) # 800061ee <acquire>
  np->state = RUNNABLE;
    80001382:	478d                	li	a5,3
    80001384:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001388:	854e                	mv	a0,s3
    8000138a:	00005097          	auipc	ra,0x5
    8000138e:	f18080e7          	jalr	-232(ra) # 800062a2 <release>
}
    80001392:	8552                	mv	a0,s4
    80001394:	70a2                	ld	ra,40(sp)
    80001396:	7402                	ld	s0,32(sp)
    80001398:	64e2                	ld	s1,24(sp)
    8000139a:	6942                	ld	s2,16(sp)
    8000139c:	69a2                	ld	s3,8(sp)
    8000139e:	6a02                	ld	s4,0(sp)
    800013a0:	6145                	addi	sp,sp,48
    800013a2:	8082                	ret
    return -1;
    800013a4:	5a7d                	li	s4,-1
    800013a6:	b7f5                	j	80001392 <fork+0x126>

00000000800013a8 <scheduler>:
{
    800013a8:	7139                	addi	sp,sp,-64
    800013aa:	fc06                	sd	ra,56(sp)
    800013ac:	f822                	sd	s0,48(sp)
    800013ae:	f426                	sd	s1,40(sp)
    800013b0:	f04a                	sd	s2,32(sp)
    800013b2:	ec4e                	sd	s3,24(sp)
    800013b4:	e852                	sd	s4,16(sp)
    800013b6:	e456                	sd	s5,8(sp)
    800013b8:	e05a                	sd	s6,0(sp)
    800013ba:	0080                	addi	s0,sp,64
    800013bc:	8792                	mv	a5,tp
  int id = r_tp();
    800013be:	2781                	sext.w	a5,a5
  c->proc = 0;
    800013c0:	00779a93          	slli	s5,a5,0x7
    800013c4:	00008717          	auipc	a4,0x8
    800013c8:	c8c70713          	addi	a4,a4,-884 # 80009050 <pid_lock>
    800013cc:	9756                	add	a4,a4,s5
    800013ce:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800013d2:	00008717          	auipc	a4,0x8
    800013d6:	cb670713          	addi	a4,a4,-842 # 80009088 <cpus+0x8>
    800013da:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    800013dc:	498d                	li	s3,3
        p->state = RUNNING;
    800013de:	4b11                	li	s6,4
        c->proc = p;
    800013e0:	079e                	slli	a5,a5,0x7
    800013e2:	00008a17          	auipc	s4,0x8
    800013e6:	c6ea0a13          	addi	s4,s4,-914 # 80009050 <pid_lock>
    800013ea:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800013ec:	0000e917          	auipc	s2,0xe
    800013f0:	49490913          	addi	s2,s2,1172 # 8000f880 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013f4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800013f8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013fc:	10079073          	csrw	sstatus,a5
    80001400:	00008497          	auipc	s1,0x8
    80001404:	08048493          	addi	s1,s1,128 # 80009480 <proc>
    80001408:	a03d                	j	80001436 <scheduler+0x8e>
        p->state = RUNNING;
    8000140a:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000140e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001412:	06048593          	addi	a1,s1,96
    80001416:	8556                	mv	a0,s5
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	640080e7          	jalr	1600(ra) # 80001a58 <swtch>
        c->proc = 0;
    80001420:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80001424:	8526                	mv	a0,s1
    80001426:	00005097          	auipc	ra,0x5
    8000142a:	e7c080e7          	jalr	-388(ra) # 800062a2 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000142e:	19048493          	addi	s1,s1,400
    80001432:	fd2481e3          	beq	s1,s2,800013f4 <scheduler+0x4c>
      acquire(&p->lock);
    80001436:	8526                	mv	a0,s1
    80001438:	00005097          	auipc	ra,0x5
    8000143c:	db6080e7          	jalr	-586(ra) # 800061ee <acquire>
      if(p->state == RUNNABLE) {
    80001440:	4c9c                	lw	a5,24(s1)
    80001442:	ff3791e3          	bne	a5,s3,80001424 <scheduler+0x7c>
    80001446:	b7d1                	j	8000140a <scheduler+0x62>

0000000080001448 <sched>:
{
    80001448:	7179                	addi	sp,sp,-48
    8000144a:	f406                	sd	ra,40(sp)
    8000144c:	f022                	sd	s0,32(sp)
    8000144e:	ec26                	sd	s1,24(sp)
    80001450:	e84a                	sd	s2,16(sp)
    80001452:	e44e                	sd	s3,8(sp)
    80001454:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001456:	00000097          	auipc	ra,0x0
    8000145a:	9f2080e7          	jalr	-1550(ra) # 80000e48 <myproc>
    8000145e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001460:	00005097          	auipc	ra,0x5
    80001464:	d14080e7          	jalr	-748(ra) # 80006174 <holding>
    80001468:	c93d                	beqz	a0,800014de <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000146a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000146c:	2781                	sext.w	a5,a5
    8000146e:	079e                	slli	a5,a5,0x7
    80001470:	00008717          	auipc	a4,0x8
    80001474:	be070713          	addi	a4,a4,-1056 # 80009050 <pid_lock>
    80001478:	97ba                	add	a5,a5,a4
    8000147a:	0a87a703          	lw	a4,168(a5)
    8000147e:	4785                	li	a5,1
    80001480:	06f71763          	bne	a4,a5,800014ee <sched+0xa6>
  if(p->state == RUNNING)
    80001484:	4c98                	lw	a4,24(s1)
    80001486:	4791                	li	a5,4
    80001488:	06f70b63          	beq	a4,a5,800014fe <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000148c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001490:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001492:	efb5                	bnez	a5,8000150e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001494:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001496:	00008917          	auipc	s2,0x8
    8000149a:	bba90913          	addi	s2,s2,-1094 # 80009050 <pid_lock>
    8000149e:	2781                	sext.w	a5,a5
    800014a0:	079e                	slli	a5,a5,0x7
    800014a2:	97ca                	add	a5,a5,s2
    800014a4:	0ac7a983          	lw	s3,172(a5)
    800014a8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800014aa:	2781                	sext.w	a5,a5
    800014ac:	079e                	slli	a5,a5,0x7
    800014ae:	00008597          	auipc	a1,0x8
    800014b2:	bda58593          	addi	a1,a1,-1062 # 80009088 <cpus+0x8>
    800014b6:	95be                	add	a1,a1,a5
    800014b8:	06048513          	addi	a0,s1,96
    800014bc:	00000097          	auipc	ra,0x0
    800014c0:	59c080e7          	jalr	1436(ra) # 80001a58 <swtch>
    800014c4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800014c6:	2781                	sext.w	a5,a5
    800014c8:	079e                	slli	a5,a5,0x7
    800014ca:	97ca                	add	a5,a5,s2
    800014cc:	0b37a623          	sw	s3,172(a5)
}
    800014d0:	70a2                	ld	ra,40(sp)
    800014d2:	7402                	ld	s0,32(sp)
    800014d4:	64e2                	ld	s1,24(sp)
    800014d6:	6942                	ld	s2,16(sp)
    800014d8:	69a2                	ld	s3,8(sp)
    800014da:	6145                	addi	sp,sp,48
    800014dc:	8082                	ret
    panic("sched p->lock");
    800014de:	00007517          	auipc	a0,0x7
    800014e2:	cba50513          	addi	a0,a0,-838 # 80008198 <etext+0x198>
    800014e6:	00004097          	auipc	ra,0x4
    800014ea:	762080e7          	jalr	1890(ra) # 80005c48 <panic>
    panic("sched locks");
    800014ee:	00007517          	auipc	a0,0x7
    800014f2:	cba50513          	addi	a0,a0,-838 # 800081a8 <etext+0x1a8>
    800014f6:	00004097          	auipc	ra,0x4
    800014fa:	752080e7          	jalr	1874(ra) # 80005c48 <panic>
    panic("sched running");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	cba50513          	addi	a0,a0,-838 # 800081b8 <etext+0x1b8>
    80001506:	00004097          	auipc	ra,0x4
    8000150a:	742080e7          	jalr	1858(ra) # 80005c48 <panic>
    panic("sched interruptible");
    8000150e:	00007517          	auipc	a0,0x7
    80001512:	cba50513          	addi	a0,a0,-838 # 800081c8 <etext+0x1c8>
    80001516:	00004097          	auipc	ra,0x4
    8000151a:	732080e7          	jalr	1842(ra) # 80005c48 <panic>

000000008000151e <yield>:
{
    8000151e:	1101                	addi	sp,sp,-32
    80001520:	ec06                	sd	ra,24(sp)
    80001522:	e822                	sd	s0,16(sp)
    80001524:	e426                	sd	s1,8(sp)
    80001526:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001528:	00000097          	auipc	ra,0x0
    8000152c:	920080e7          	jalr	-1760(ra) # 80000e48 <myproc>
    80001530:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001532:	00005097          	auipc	ra,0x5
    80001536:	cbc080e7          	jalr	-836(ra) # 800061ee <acquire>
  p->state = RUNNABLE;
    8000153a:	478d                	li	a5,3
    8000153c:	cc9c                	sw	a5,24(s1)
  sched();
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f0a080e7          	jalr	-246(ra) # 80001448 <sched>
  release(&p->lock);
    80001546:	8526                	mv	a0,s1
    80001548:	00005097          	auipc	ra,0x5
    8000154c:	d5a080e7          	jalr	-678(ra) # 800062a2 <release>
}
    80001550:	60e2                	ld	ra,24(sp)
    80001552:	6442                	ld	s0,16(sp)
    80001554:	64a2                	ld	s1,8(sp)
    80001556:	6105                	addi	sp,sp,32
    80001558:	8082                	ret

000000008000155a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000155a:	7179                	addi	sp,sp,-48
    8000155c:	f406                	sd	ra,40(sp)
    8000155e:	f022                	sd	s0,32(sp)
    80001560:	ec26                	sd	s1,24(sp)
    80001562:	e84a                	sd	s2,16(sp)
    80001564:	e44e                	sd	s3,8(sp)
    80001566:	1800                	addi	s0,sp,48
    80001568:	89aa                	mv	s3,a0
    8000156a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000156c:	00000097          	auipc	ra,0x0
    80001570:	8dc080e7          	jalr	-1828(ra) # 80000e48 <myproc>
    80001574:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001576:	00005097          	auipc	ra,0x5
    8000157a:	c78080e7          	jalr	-904(ra) # 800061ee <acquire>
  release(lk);
    8000157e:	854a                	mv	a0,s2
    80001580:	00005097          	auipc	ra,0x5
    80001584:	d22080e7          	jalr	-734(ra) # 800062a2 <release>

  // Go to sleep.
  p->chan = chan;
    80001588:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000158c:	4789                	li	a5,2
    8000158e:	cc9c                	sw	a5,24(s1)

  sched();
    80001590:	00000097          	auipc	ra,0x0
    80001594:	eb8080e7          	jalr	-328(ra) # 80001448 <sched>

  // Tidy up.
  p->chan = 0;
    80001598:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000159c:	8526                	mv	a0,s1
    8000159e:	00005097          	auipc	ra,0x5
    800015a2:	d04080e7          	jalr	-764(ra) # 800062a2 <release>
  acquire(lk);
    800015a6:	854a                	mv	a0,s2
    800015a8:	00005097          	auipc	ra,0x5
    800015ac:	c46080e7          	jalr	-954(ra) # 800061ee <acquire>
}
    800015b0:	70a2                	ld	ra,40(sp)
    800015b2:	7402                	ld	s0,32(sp)
    800015b4:	64e2                	ld	s1,24(sp)
    800015b6:	6942                	ld	s2,16(sp)
    800015b8:	69a2                	ld	s3,8(sp)
    800015ba:	6145                	addi	sp,sp,48
    800015bc:	8082                	ret

00000000800015be <wait>:
{
    800015be:	715d                	addi	sp,sp,-80
    800015c0:	e486                	sd	ra,72(sp)
    800015c2:	e0a2                	sd	s0,64(sp)
    800015c4:	fc26                	sd	s1,56(sp)
    800015c6:	f84a                	sd	s2,48(sp)
    800015c8:	f44e                	sd	s3,40(sp)
    800015ca:	f052                	sd	s4,32(sp)
    800015cc:	ec56                	sd	s5,24(sp)
    800015ce:	e85a                	sd	s6,16(sp)
    800015d0:	e45e                	sd	s7,8(sp)
    800015d2:	e062                	sd	s8,0(sp)
    800015d4:	0880                	addi	s0,sp,80
    800015d6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800015d8:	00000097          	auipc	ra,0x0
    800015dc:	870080e7          	jalr	-1936(ra) # 80000e48 <myproc>
    800015e0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800015e2:	00008517          	auipc	a0,0x8
    800015e6:	a8650513          	addi	a0,a0,-1402 # 80009068 <wait_lock>
    800015ea:	00005097          	auipc	ra,0x5
    800015ee:	c04080e7          	jalr	-1020(ra) # 800061ee <acquire>
    havekids = 0;
    800015f2:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800015f4:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    800015f6:	0000e997          	auipc	s3,0xe
    800015fa:	28a98993          	addi	s3,s3,650 # 8000f880 <tickslock>
        havekids = 1;
    800015fe:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001600:	00008c17          	auipc	s8,0x8
    80001604:	a68c0c13          	addi	s8,s8,-1432 # 80009068 <wait_lock>
    havekids = 0;
    80001608:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000160a:	00008497          	auipc	s1,0x8
    8000160e:	e7648493          	addi	s1,s1,-394 # 80009480 <proc>
    80001612:	a0bd                	j	80001680 <wait+0xc2>
          pid = np->pid;
    80001614:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80001618:	000b0e63          	beqz	s6,80001634 <wait+0x76>
    8000161c:	4691                	li	a3,4
    8000161e:	02c48613          	addi	a2,s1,44
    80001622:	85da                	mv	a1,s6
    80001624:	05093503          	ld	a0,80(s2)
    80001628:	fffff097          	auipc	ra,0xfffff
    8000162c:	4e2080e7          	jalr	1250(ra) # 80000b0a <copyout>
    80001630:	02054563          	bltz	a0,8000165a <wait+0x9c>
          freeproc(np);
    80001634:	8526                	mv	a0,s1
    80001636:	00000097          	auipc	ra,0x0
    8000163a:	9c4080e7          	jalr	-1596(ra) # 80000ffa <freeproc>
          release(&np->lock);
    8000163e:	8526                	mv	a0,s1
    80001640:	00005097          	auipc	ra,0x5
    80001644:	c62080e7          	jalr	-926(ra) # 800062a2 <release>
          release(&wait_lock);
    80001648:	00008517          	auipc	a0,0x8
    8000164c:	a2050513          	addi	a0,a0,-1504 # 80009068 <wait_lock>
    80001650:	00005097          	auipc	ra,0x5
    80001654:	c52080e7          	jalr	-942(ra) # 800062a2 <release>
          return pid;
    80001658:	a09d                	j	800016be <wait+0x100>
            release(&np->lock);
    8000165a:	8526                	mv	a0,s1
    8000165c:	00005097          	auipc	ra,0x5
    80001660:	c46080e7          	jalr	-954(ra) # 800062a2 <release>
            release(&wait_lock);
    80001664:	00008517          	auipc	a0,0x8
    80001668:	a0450513          	addi	a0,a0,-1532 # 80009068 <wait_lock>
    8000166c:	00005097          	auipc	ra,0x5
    80001670:	c36080e7          	jalr	-970(ra) # 800062a2 <release>
            return -1;
    80001674:	59fd                	li	s3,-1
    80001676:	a0a1                	j	800016be <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80001678:	19048493          	addi	s1,s1,400
    8000167c:	03348463          	beq	s1,s3,800016a4 <wait+0xe6>
      if(np->parent == p){
    80001680:	7c9c                	ld	a5,56(s1)
    80001682:	ff279be3          	bne	a5,s2,80001678 <wait+0xba>
        acquire(&np->lock);
    80001686:	8526                	mv	a0,s1
    80001688:	00005097          	auipc	ra,0x5
    8000168c:	b66080e7          	jalr	-1178(ra) # 800061ee <acquire>
        if(np->state == ZOMBIE){
    80001690:	4c9c                	lw	a5,24(s1)
    80001692:	f94781e3          	beq	a5,s4,80001614 <wait+0x56>
        release(&np->lock);
    80001696:	8526                	mv	a0,s1
    80001698:	00005097          	auipc	ra,0x5
    8000169c:	c0a080e7          	jalr	-1014(ra) # 800062a2 <release>
        havekids = 1;
    800016a0:	8756                	mv	a4,s5
    800016a2:	bfd9                	j	80001678 <wait+0xba>
    if(!havekids || p->killed){
    800016a4:	c701                	beqz	a4,800016ac <wait+0xee>
    800016a6:	02892783          	lw	a5,40(s2)
    800016aa:	c79d                	beqz	a5,800016d8 <wait+0x11a>
      release(&wait_lock);
    800016ac:	00008517          	auipc	a0,0x8
    800016b0:	9bc50513          	addi	a0,a0,-1604 # 80009068 <wait_lock>
    800016b4:	00005097          	auipc	ra,0x5
    800016b8:	bee080e7          	jalr	-1042(ra) # 800062a2 <release>
      return -1;
    800016bc:	59fd                	li	s3,-1
}
    800016be:	854e                	mv	a0,s3
    800016c0:	60a6                	ld	ra,72(sp)
    800016c2:	6406                	ld	s0,64(sp)
    800016c4:	74e2                	ld	s1,56(sp)
    800016c6:	7942                	ld	s2,48(sp)
    800016c8:	79a2                	ld	s3,40(sp)
    800016ca:	7a02                	ld	s4,32(sp)
    800016cc:	6ae2                	ld	s5,24(sp)
    800016ce:	6b42                	ld	s6,16(sp)
    800016d0:	6ba2                	ld	s7,8(sp)
    800016d2:	6c02                	ld	s8,0(sp)
    800016d4:	6161                	addi	sp,sp,80
    800016d6:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800016d8:	85e2                	mv	a1,s8
    800016da:	854a                	mv	a0,s2
    800016dc:	00000097          	auipc	ra,0x0
    800016e0:	e7e080e7          	jalr	-386(ra) # 8000155a <sleep>
    havekids = 0;
    800016e4:	b715                	j	80001608 <wait+0x4a>

00000000800016e6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800016e6:	7139                	addi	sp,sp,-64
    800016e8:	fc06                	sd	ra,56(sp)
    800016ea:	f822                	sd	s0,48(sp)
    800016ec:	f426                	sd	s1,40(sp)
    800016ee:	f04a                	sd	s2,32(sp)
    800016f0:	ec4e                	sd	s3,24(sp)
    800016f2:	e852                	sd	s4,16(sp)
    800016f4:	e456                	sd	s5,8(sp)
    800016f6:	0080                	addi	s0,sp,64
    800016f8:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800016fa:	00008497          	auipc	s1,0x8
    800016fe:	d8648493          	addi	s1,s1,-634 # 80009480 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001702:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001704:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001706:	0000e917          	auipc	s2,0xe
    8000170a:	17a90913          	addi	s2,s2,378 # 8000f880 <tickslock>
    8000170e:	a821                	j	80001726 <wakeup+0x40>
        p->state = RUNNABLE;
    80001710:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80001714:	8526                	mv	a0,s1
    80001716:	00005097          	auipc	ra,0x5
    8000171a:	b8c080e7          	jalr	-1140(ra) # 800062a2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000171e:	19048493          	addi	s1,s1,400
    80001722:	03248463          	beq	s1,s2,8000174a <wakeup+0x64>
    if(p != myproc()){
    80001726:	fffff097          	auipc	ra,0xfffff
    8000172a:	722080e7          	jalr	1826(ra) # 80000e48 <myproc>
    8000172e:	fea488e3          	beq	s1,a0,8000171e <wakeup+0x38>
      acquire(&p->lock);
    80001732:	8526                	mv	a0,s1
    80001734:	00005097          	auipc	ra,0x5
    80001738:	aba080e7          	jalr	-1350(ra) # 800061ee <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000173c:	4c9c                	lw	a5,24(s1)
    8000173e:	fd379be3          	bne	a5,s3,80001714 <wakeup+0x2e>
    80001742:	709c                	ld	a5,32(s1)
    80001744:	fd4798e3          	bne	a5,s4,80001714 <wakeup+0x2e>
    80001748:	b7e1                	j	80001710 <wakeup+0x2a>
    }
  }
}
    8000174a:	70e2                	ld	ra,56(sp)
    8000174c:	7442                	ld	s0,48(sp)
    8000174e:	74a2                	ld	s1,40(sp)
    80001750:	7902                	ld	s2,32(sp)
    80001752:	69e2                	ld	s3,24(sp)
    80001754:	6a42                	ld	s4,16(sp)
    80001756:	6aa2                	ld	s5,8(sp)
    80001758:	6121                	addi	sp,sp,64
    8000175a:	8082                	ret

000000008000175c <reparent>:
{
    8000175c:	7179                	addi	sp,sp,-48
    8000175e:	f406                	sd	ra,40(sp)
    80001760:	f022                	sd	s0,32(sp)
    80001762:	ec26                	sd	s1,24(sp)
    80001764:	e84a                	sd	s2,16(sp)
    80001766:	e44e                	sd	s3,8(sp)
    80001768:	e052                	sd	s4,0(sp)
    8000176a:	1800                	addi	s0,sp,48
    8000176c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000176e:	00008497          	auipc	s1,0x8
    80001772:	d1248493          	addi	s1,s1,-750 # 80009480 <proc>
      pp->parent = initproc;
    80001776:	00008a17          	auipc	s4,0x8
    8000177a:	89aa0a13          	addi	s4,s4,-1894 # 80009010 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000177e:	0000e997          	auipc	s3,0xe
    80001782:	10298993          	addi	s3,s3,258 # 8000f880 <tickslock>
    80001786:	a029                	j	80001790 <reparent+0x34>
    80001788:	19048493          	addi	s1,s1,400
    8000178c:	01348d63          	beq	s1,s3,800017a6 <reparent+0x4a>
    if(pp->parent == p){
    80001790:	7c9c                	ld	a5,56(s1)
    80001792:	ff279be3          	bne	a5,s2,80001788 <reparent+0x2c>
      pp->parent = initproc;
    80001796:	000a3503          	ld	a0,0(s4)
    8000179a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000179c:	00000097          	auipc	ra,0x0
    800017a0:	f4a080e7          	jalr	-182(ra) # 800016e6 <wakeup>
    800017a4:	b7d5                	j	80001788 <reparent+0x2c>
}
    800017a6:	70a2                	ld	ra,40(sp)
    800017a8:	7402                	ld	s0,32(sp)
    800017aa:	64e2                	ld	s1,24(sp)
    800017ac:	6942                	ld	s2,16(sp)
    800017ae:	69a2                	ld	s3,8(sp)
    800017b0:	6a02                	ld	s4,0(sp)
    800017b2:	6145                	addi	sp,sp,48
    800017b4:	8082                	ret

00000000800017b6 <exit>:
{
    800017b6:	7179                	addi	sp,sp,-48
    800017b8:	f406                	sd	ra,40(sp)
    800017ba:	f022                	sd	s0,32(sp)
    800017bc:	ec26                	sd	s1,24(sp)
    800017be:	e84a                	sd	s2,16(sp)
    800017c0:	e44e                	sd	s3,8(sp)
    800017c2:	e052                	sd	s4,0(sp)
    800017c4:	1800                	addi	s0,sp,48
    800017c6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800017c8:	fffff097          	auipc	ra,0xfffff
    800017cc:	680080e7          	jalr	1664(ra) # 80000e48 <myproc>
    800017d0:	89aa                	mv	s3,a0
  if(p == initproc)
    800017d2:	00008797          	auipc	a5,0x8
    800017d6:	83e7b783          	ld	a5,-1986(a5) # 80009010 <initproc>
    800017da:	0d050493          	addi	s1,a0,208
    800017de:	15050913          	addi	s2,a0,336
    800017e2:	02a79363          	bne	a5,a0,80001808 <exit+0x52>
    panic("init exiting");
    800017e6:	00007517          	auipc	a0,0x7
    800017ea:	9fa50513          	addi	a0,a0,-1542 # 800081e0 <etext+0x1e0>
    800017ee:	00004097          	auipc	ra,0x4
    800017f2:	45a080e7          	jalr	1114(ra) # 80005c48 <panic>
      fileclose(f);
    800017f6:	00002097          	auipc	ra,0x2
    800017fa:	242080e7          	jalr	578(ra) # 80003a38 <fileclose>
      p->ofile[fd] = 0;
    800017fe:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001802:	04a1                	addi	s1,s1,8
    80001804:	01248563          	beq	s1,s2,8000180e <exit+0x58>
    if(p->ofile[fd]){
    80001808:	6088                	ld	a0,0(s1)
    8000180a:	f575                	bnez	a0,800017f6 <exit+0x40>
    8000180c:	bfdd                	j	80001802 <exit+0x4c>
  begin_op();
    8000180e:	00002097          	auipc	ra,0x2
    80001812:	d5e080e7          	jalr	-674(ra) # 8000356c <begin_op>
  iput(p->cwd);
    80001816:	1509b503          	ld	a0,336(s3)
    8000181a:	00001097          	auipc	ra,0x1
    8000181e:	53a080e7          	jalr	1338(ra) # 80002d54 <iput>
  end_op();
    80001822:	00002097          	auipc	ra,0x2
    80001826:	dca080e7          	jalr	-566(ra) # 800035ec <end_op>
  p->cwd = 0;
    8000182a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000182e:	00008497          	auipc	s1,0x8
    80001832:	83a48493          	addi	s1,s1,-1990 # 80009068 <wait_lock>
    80001836:	8526                	mv	a0,s1
    80001838:	00005097          	auipc	ra,0x5
    8000183c:	9b6080e7          	jalr	-1610(ra) # 800061ee <acquire>
  reparent(p);
    80001840:	854e                	mv	a0,s3
    80001842:	00000097          	auipc	ra,0x0
    80001846:	f1a080e7          	jalr	-230(ra) # 8000175c <reparent>
  wakeup(p->parent);
    8000184a:	0389b503          	ld	a0,56(s3)
    8000184e:	00000097          	auipc	ra,0x0
    80001852:	e98080e7          	jalr	-360(ra) # 800016e6 <wakeup>
  acquire(&p->lock);
    80001856:	854e                	mv	a0,s3
    80001858:	00005097          	auipc	ra,0x5
    8000185c:	996080e7          	jalr	-1642(ra) # 800061ee <acquire>
  p->xstate = status;
    80001860:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001864:	4795                	li	a5,5
    80001866:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000186a:	8526                	mv	a0,s1
    8000186c:	00005097          	auipc	ra,0x5
    80001870:	a36080e7          	jalr	-1482(ra) # 800062a2 <release>
  sched();
    80001874:	00000097          	auipc	ra,0x0
    80001878:	bd4080e7          	jalr	-1068(ra) # 80001448 <sched>
  panic("zombie exit");
    8000187c:	00007517          	auipc	a0,0x7
    80001880:	97450513          	addi	a0,a0,-1676 # 800081f0 <etext+0x1f0>
    80001884:	00004097          	auipc	ra,0x4
    80001888:	3c4080e7          	jalr	964(ra) # 80005c48 <panic>

000000008000188c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000188c:	7179                	addi	sp,sp,-48
    8000188e:	f406                	sd	ra,40(sp)
    80001890:	f022                	sd	s0,32(sp)
    80001892:	ec26                	sd	s1,24(sp)
    80001894:	e84a                	sd	s2,16(sp)
    80001896:	e44e                	sd	s3,8(sp)
    80001898:	1800                	addi	s0,sp,48
    8000189a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000189c:	00008497          	auipc	s1,0x8
    800018a0:	be448493          	addi	s1,s1,-1052 # 80009480 <proc>
    800018a4:	0000e997          	auipc	s3,0xe
    800018a8:	fdc98993          	addi	s3,s3,-36 # 8000f880 <tickslock>
    acquire(&p->lock);
    800018ac:	8526                	mv	a0,s1
    800018ae:	00005097          	auipc	ra,0x5
    800018b2:	940080e7          	jalr	-1728(ra) # 800061ee <acquire>
    if(p->pid == pid){
    800018b6:	589c                	lw	a5,48(s1)
    800018b8:	01278d63          	beq	a5,s2,800018d2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800018bc:	8526                	mv	a0,s1
    800018be:	00005097          	auipc	ra,0x5
    800018c2:	9e4080e7          	jalr	-1564(ra) # 800062a2 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800018c6:	19048493          	addi	s1,s1,400
    800018ca:	ff3491e3          	bne	s1,s3,800018ac <kill+0x20>
  }
  return -1;
    800018ce:	557d                	li	a0,-1
    800018d0:	a829                	j	800018ea <kill+0x5e>
      p->killed = 1;
    800018d2:	4785                	li	a5,1
    800018d4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800018d6:	4c98                	lw	a4,24(s1)
    800018d8:	4789                	li	a5,2
    800018da:	00f70f63          	beq	a4,a5,800018f8 <kill+0x6c>
      release(&p->lock);
    800018de:	8526                	mv	a0,s1
    800018e0:	00005097          	auipc	ra,0x5
    800018e4:	9c2080e7          	jalr	-1598(ra) # 800062a2 <release>
      return 0;
    800018e8:	4501                	li	a0,0
}
    800018ea:	70a2                	ld	ra,40(sp)
    800018ec:	7402                	ld	s0,32(sp)
    800018ee:	64e2                	ld	s1,24(sp)
    800018f0:	6942                	ld	s2,16(sp)
    800018f2:	69a2                	ld	s3,8(sp)
    800018f4:	6145                	addi	sp,sp,48
    800018f6:	8082                	ret
        p->state = RUNNABLE;
    800018f8:	478d                	li	a5,3
    800018fa:	cc9c                	sw	a5,24(s1)
    800018fc:	b7cd                	j	800018de <kill+0x52>

00000000800018fe <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800018fe:	7179                	addi	sp,sp,-48
    80001900:	f406                	sd	ra,40(sp)
    80001902:	f022                	sd	s0,32(sp)
    80001904:	ec26                	sd	s1,24(sp)
    80001906:	e84a                	sd	s2,16(sp)
    80001908:	e44e                	sd	s3,8(sp)
    8000190a:	e052                	sd	s4,0(sp)
    8000190c:	1800                	addi	s0,sp,48
    8000190e:	84aa                	mv	s1,a0
    80001910:	892e                	mv	s2,a1
    80001912:	89b2                	mv	s3,a2
    80001914:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001916:	fffff097          	auipc	ra,0xfffff
    8000191a:	532080e7          	jalr	1330(ra) # 80000e48 <myproc>
  if(user_dst){
    8000191e:	c08d                	beqz	s1,80001940 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80001920:	86d2                	mv	a3,s4
    80001922:	864e                	mv	a2,s3
    80001924:	85ca                	mv	a1,s2
    80001926:	6928                	ld	a0,80(a0)
    80001928:	fffff097          	auipc	ra,0xfffff
    8000192c:	1e2080e7          	jalr	482(ra) # 80000b0a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001930:	70a2                	ld	ra,40(sp)
    80001932:	7402                	ld	s0,32(sp)
    80001934:	64e2                	ld	s1,24(sp)
    80001936:	6942                	ld	s2,16(sp)
    80001938:	69a2                	ld	s3,8(sp)
    8000193a:	6a02                	ld	s4,0(sp)
    8000193c:	6145                	addi	sp,sp,48
    8000193e:	8082                	ret
    memmove((char *)dst, src, len);
    80001940:	000a061b          	sext.w	a2,s4
    80001944:	85ce                	mv	a1,s3
    80001946:	854a                	mv	a0,s2
    80001948:	fffff097          	auipc	ra,0xfffff
    8000194c:	890080e7          	jalr	-1904(ra) # 800001d8 <memmove>
    return 0;
    80001950:	8526                	mv	a0,s1
    80001952:	bff9                	j	80001930 <either_copyout+0x32>

0000000080001954 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001954:	7179                	addi	sp,sp,-48
    80001956:	f406                	sd	ra,40(sp)
    80001958:	f022                	sd	s0,32(sp)
    8000195a:	ec26                	sd	s1,24(sp)
    8000195c:	e84a                	sd	s2,16(sp)
    8000195e:	e44e                	sd	s3,8(sp)
    80001960:	e052                	sd	s4,0(sp)
    80001962:	1800                	addi	s0,sp,48
    80001964:	892a                	mv	s2,a0
    80001966:	84ae                	mv	s1,a1
    80001968:	89b2                	mv	s3,a2
    8000196a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000196c:	fffff097          	auipc	ra,0xfffff
    80001970:	4dc080e7          	jalr	1244(ra) # 80000e48 <myproc>
  if(user_src){
    80001974:	c08d                	beqz	s1,80001996 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80001976:	86d2                	mv	a3,s4
    80001978:	864e                	mv	a2,s3
    8000197a:	85ca                	mv	a1,s2
    8000197c:	6928                	ld	a0,80(a0)
    8000197e:	fffff097          	auipc	ra,0xfffff
    80001982:	218080e7          	jalr	536(ra) # 80000b96 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001986:	70a2                	ld	ra,40(sp)
    80001988:	7402                	ld	s0,32(sp)
    8000198a:	64e2                	ld	s1,24(sp)
    8000198c:	6942                	ld	s2,16(sp)
    8000198e:	69a2                	ld	s3,8(sp)
    80001990:	6a02                	ld	s4,0(sp)
    80001992:	6145                	addi	sp,sp,48
    80001994:	8082                	ret
    memmove(dst, (char*)src, len);
    80001996:	000a061b          	sext.w	a2,s4
    8000199a:	85ce                	mv	a1,s3
    8000199c:	854a                	mv	a0,s2
    8000199e:	fffff097          	auipc	ra,0xfffff
    800019a2:	83a080e7          	jalr	-1990(ra) # 800001d8 <memmove>
    return 0;
    800019a6:	8526                	mv	a0,s1
    800019a8:	bff9                	j	80001986 <either_copyin+0x32>

00000000800019aa <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800019aa:	715d                	addi	sp,sp,-80
    800019ac:	e486                	sd	ra,72(sp)
    800019ae:	e0a2                	sd	s0,64(sp)
    800019b0:	fc26                	sd	s1,56(sp)
    800019b2:	f84a                	sd	s2,48(sp)
    800019b4:	f44e                	sd	s3,40(sp)
    800019b6:	f052                	sd	s4,32(sp)
    800019b8:	ec56                	sd	s5,24(sp)
    800019ba:	e85a                	sd	s6,16(sp)
    800019bc:	e45e                	sd	s7,8(sp)
    800019be:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800019c0:	00006517          	auipc	a0,0x6
    800019c4:	68850513          	addi	a0,a0,1672 # 80008048 <etext+0x48>
    800019c8:	00004097          	auipc	ra,0x4
    800019cc:	2ca080e7          	jalr	714(ra) # 80005c92 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800019d0:	00008497          	auipc	s1,0x8
    800019d4:	c0848493          	addi	s1,s1,-1016 # 800095d8 <proc+0x158>
    800019d8:	0000e917          	auipc	s2,0xe
    800019dc:	00090913          	mv	s2,s2
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800019e0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800019e2:	00007997          	auipc	s3,0x7
    800019e6:	81e98993          	addi	s3,s3,-2018 # 80008200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    800019ea:	00007a97          	auipc	s5,0x7
    800019ee:	81ea8a93          	addi	s5,s5,-2018 # 80008208 <etext+0x208>
    printf("\n");
    800019f2:	00006a17          	auipc	s4,0x6
    800019f6:	656a0a13          	addi	s4,s4,1622 # 80008048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800019fa:	00007b97          	auipc	s7,0x7
    800019fe:	846b8b93          	addi	s7,s7,-1978 # 80008240 <states.1719>
    80001a02:	a00d                	j	80001a24 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001a04:	ed86a583          	lw	a1,-296(a3)
    80001a08:	8556                	mv	a0,s5
    80001a0a:	00004097          	auipc	ra,0x4
    80001a0e:	288080e7          	jalr	648(ra) # 80005c92 <printf>
    printf("\n");
    80001a12:	8552                	mv	a0,s4
    80001a14:	00004097          	auipc	ra,0x4
    80001a18:	27e080e7          	jalr	638(ra) # 80005c92 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a1c:	19048493          	addi	s1,s1,400
    80001a20:	03248163          	beq	s1,s2,80001a42 <procdump+0x98>
    if(p->state == UNUSED)
    80001a24:	86a6                	mv	a3,s1
    80001a26:	ec04a783          	lw	a5,-320(s1)
    80001a2a:	dbed                	beqz	a5,80001a1c <procdump+0x72>
      state = "???";
    80001a2c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a2e:	fcfb6be3          	bltu	s6,a5,80001a04 <procdump+0x5a>
    80001a32:	1782                	slli	a5,a5,0x20
    80001a34:	9381                	srli	a5,a5,0x20
    80001a36:	078e                	slli	a5,a5,0x3
    80001a38:	97de                	add	a5,a5,s7
    80001a3a:	6390                	ld	a2,0(a5)
    80001a3c:	f661                	bnez	a2,80001a04 <procdump+0x5a>
      state = "???";
    80001a3e:	864e                	mv	a2,s3
    80001a40:	b7d1                	j	80001a04 <procdump+0x5a>
  }
}
    80001a42:	60a6                	ld	ra,72(sp)
    80001a44:	6406                	ld	s0,64(sp)
    80001a46:	74e2                	ld	s1,56(sp)
    80001a48:	7942                	ld	s2,48(sp)
    80001a4a:	79a2                	ld	s3,40(sp)
    80001a4c:	7a02                	ld	s4,32(sp)
    80001a4e:	6ae2                	ld	s5,24(sp)
    80001a50:	6b42                	ld	s6,16(sp)
    80001a52:	6ba2                	ld	s7,8(sp)
    80001a54:	6161                	addi	sp,sp,80
    80001a56:	8082                	ret

0000000080001a58 <swtch>:
    80001a58:	00153023          	sd	ra,0(a0)
    80001a5c:	00253423          	sd	sp,8(a0)
    80001a60:	e900                	sd	s0,16(a0)
    80001a62:	ed04                	sd	s1,24(a0)
    80001a64:	03253023          	sd	s2,32(a0)
    80001a68:	03353423          	sd	s3,40(a0)
    80001a6c:	03453823          	sd	s4,48(a0)
    80001a70:	03553c23          	sd	s5,56(a0)
    80001a74:	05653023          	sd	s6,64(a0)
    80001a78:	05753423          	sd	s7,72(a0)
    80001a7c:	05853823          	sd	s8,80(a0)
    80001a80:	05953c23          	sd	s9,88(a0)
    80001a84:	07a53023          	sd	s10,96(a0)
    80001a88:	07b53423          	sd	s11,104(a0)
    80001a8c:	0005b083          	ld	ra,0(a1)
    80001a90:	0085b103          	ld	sp,8(a1)
    80001a94:	6980                	ld	s0,16(a1)
    80001a96:	6d84                	ld	s1,24(a1)
    80001a98:	0205b903          	ld	s2,32(a1)
    80001a9c:	0285b983          	ld	s3,40(a1)
    80001aa0:	0305ba03          	ld	s4,48(a1)
    80001aa4:	0385ba83          	ld	s5,56(a1)
    80001aa8:	0405bb03          	ld	s6,64(a1)
    80001aac:	0485bb83          	ld	s7,72(a1)
    80001ab0:	0505bc03          	ld	s8,80(a1)
    80001ab4:	0585bc83          	ld	s9,88(a1)
    80001ab8:	0605bd03          	ld	s10,96(a1)
    80001abc:	0685bd83          	ld	s11,104(a1)
    80001ac0:	8082                	ret

0000000080001ac2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001ac2:	1141                	addi	sp,sp,-16
    80001ac4:	e406                	sd	ra,8(sp)
    80001ac6:	e022                	sd	s0,0(sp)
    80001ac8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001aca:	00006597          	auipc	a1,0x6
    80001ace:	7a658593          	addi	a1,a1,1958 # 80008270 <states.1719+0x30>
    80001ad2:	0000e517          	auipc	a0,0xe
    80001ad6:	dae50513          	addi	a0,a0,-594 # 8000f880 <tickslock>
    80001ada:	00004097          	auipc	ra,0x4
    80001ade:	684080e7          	jalr	1668(ra) # 8000615e <initlock>
}
    80001ae2:	60a2                	ld	ra,8(sp)
    80001ae4:	6402                	ld	s0,0(sp)
    80001ae6:	0141                	addi	sp,sp,16
    80001ae8:	8082                	ret

0000000080001aea <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001aea:	1141                	addi	sp,sp,-16
    80001aec:	e422                	sd	s0,8(sp)
    80001aee:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001af0:	00003797          	auipc	a5,0x3
    80001af4:	56078793          	addi	a5,a5,1376 # 80005050 <kernelvec>
    80001af8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001afc:	6422                	ld	s0,8(sp)
    80001afe:	0141                	addi	sp,sp,16
    80001b00:	8082                	ret

0000000080001b02 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001b02:	1141                	addi	sp,sp,-16
    80001b04:	e406                	sd	ra,8(sp)
    80001b06:	e022                	sd	s0,0(sp)
    80001b08:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001b0a:	fffff097          	auipc	ra,0xfffff
    80001b0e:	33e080e7          	jalr	830(ra) # 80000e48 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b12:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001b16:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b18:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80001b1c:	00005617          	auipc	a2,0x5
    80001b20:	4e460613          	addi	a2,a2,1252 # 80007000 <_trampoline>
    80001b24:	00005697          	auipc	a3,0x5
    80001b28:	4dc68693          	addi	a3,a3,1244 # 80007000 <_trampoline>
    80001b2c:	8e91                	sub	a3,a3,a2
    80001b2e:	040007b7          	lui	a5,0x4000
    80001b32:	17fd                	addi	a5,a5,-1
    80001b34:	07b2                	slli	a5,a5,0xc
    80001b36:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b38:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001b3c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001b3e:	180026f3          	csrr	a3,satp
    80001b42:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001b44:	6d38                	ld	a4,88(a0)
    80001b46:	6134                	ld	a3,64(a0)
    80001b48:	6585                	lui	a1,0x1
    80001b4a:	96ae                	add	a3,a3,a1
    80001b4c:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001b4e:	6d38                	ld	a4,88(a0)
    80001b50:	00000697          	auipc	a3,0x0
    80001b54:	13868693          	addi	a3,a3,312 # 80001c88 <usertrap>
    80001b58:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001b5a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b5c:	8692                	mv	a3,tp
    80001b5e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b60:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001b64:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001b68:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b6c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001b70:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001b72:	6f18                	ld	a4,24(a4)
    80001b74:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b78:	692c                	ld	a1,80(a0)
    80001b7a:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80001b7c:	00005717          	auipc	a4,0x5
    80001b80:	51470713          	addi	a4,a4,1300 # 80007090 <userret>
    80001b84:	8f11                	sub	a4,a4,a2
    80001b86:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80001b88:	577d                	li	a4,-1
    80001b8a:	177e                	slli	a4,a4,0x3f
    80001b8c:	8dd9                	or	a1,a1,a4
    80001b8e:	02000537          	lui	a0,0x2000
    80001b92:	157d                	addi	a0,a0,-1
    80001b94:	0536                	slli	a0,a0,0xd
    80001b96:	9782                	jalr	a5
}
    80001b98:	60a2                	ld	ra,8(sp)
    80001b9a:	6402                	ld	s0,0(sp)
    80001b9c:	0141                	addi	sp,sp,16
    80001b9e:	8082                	ret

0000000080001ba0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001ba0:	1101                	addi	sp,sp,-32
    80001ba2:	ec06                	sd	ra,24(sp)
    80001ba4:	e822                	sd	s0,16(sp)
    80001ba6:	e426                	sd	s1,8(sp)
    80001ba8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001baa:	0000e497          	auipc	s1,0xe
    80001bae:	cd648493          	addi	s1,s1,-810 # 8000f880 <tickslock>
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	00004097          	auipc	ra,0x4
    80001bb8:	63a080e7          	jalr	1594(ra) # 800061ee <acquire>
  ticks++;
    80001bbc:	00007517          	auipc	a0,0x7
    80001bc0:	45c50513          	addi	a0,a0,1116 # 80009018 <ticks>
    80001bc4:	411c                	lw	a5,0(a0)
    80001bc6:	2785                	addiw	a5,a5,1
    80001bc8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001bca:	00000097          	auipc	ra,0x0
    80001bce:	b1c080e7          	jalr	-1252(ra) # 800016e6 <wakeup>
  release(&tickslock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	00004097          	auipc	ra,0x4
    80001bd8:	6ce080e7          	jalr	1742(ra) # 800062a2 <release>
}
    80001bdc:	60e2                	ld	ra,24(sp)
    80001bde:	6442                	ld	s0,16(sp)
    80001be0:	64a2                	ld	s1,8(sp)
    80001be2:	6105                	addi	sp,sp,32
    80001be4:	8082                	ret

0000000080001be6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001be6:	1101                	addi	sp,sp,-32
    80001be8:	ec06                	sd	ra,24(sp)
    80001bea:	e822                	sd	s0,16(sp)
    80001bec:	e426                	sd	s1,8(sp)
    80001bee:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001bf0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001bf4:	00074d63          	bltz	a4,80001c0e <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001bf8:	57fd                	li	a5,-1
    80001bfa:	17fe                	slli	a5,a5,0x3f
    80001bfc:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001bfe:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001c00:	06f70363          	beq	a4,a5,80001c66 <devintr+0x80>
  }
}
    80001c04:	60e2                	ld	ra,24(sp)
    80001c06:	6442                	ld	s0,16(sp)
    80001c08:	64a2                	ld	s1,8(sp)
    80001c0a:	6105                	addi	sp,sp,32
    80001c0c:	8082                	ret
     (scause & 0xff) == 9){
    80001c0e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80001c12:	46a5                	li	a3,9
    80001c14:	fed792e3          	bne	a5,a3,80001bf8 <devintr+0x12>
    int irq = plic_claim();
    80001c18:	00003097          	auipc	ra,0x3
    80001c1c:	540080e7          	jalr	1344(ra) # 80005158 <plic_claim>
    80001c20:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001c22:	47a9                	li	a5,10
    80001c24:	02f50763          	beq	a0,a5,80001c52 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001c28:	4785                	li	a5,1
    80001c2a:	02f50963          	beq	a0,a5,80001c5c <devintr+0x76>
    return 1;
    80001c2e:	4505                	li	a0,1
    } else if(irq){
    80001c30:	d8f1                	beqz	s1,80001c04 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001c32:	85a6                	mv	a1,s1
    80001c34:	00006517          	auipc	a0,0x6
    80001c38:	64450513          	addi	a0,a0,1604 # 80008278 <states.1719+0x38>
    80001c3c:	00004097          	auipc	ra,0x4
    80001c40:	056080e7          	jalr	86(ra) # 80005c92 <printf>
      plic_complete(irq);
    80001c44:	8526                	mv	a0,s1
    80001c46:	00003097          	auipc	ra,0x3
    80001c4a:	536080e7          	jalr	1334(ra) # 8000517c <plic_complete>
    return 1;
    80001c4e:	4505                	li	a0,1
    80001c50:	bf55                	j	80001c04 <devintr+0x1e>
      uartintr();
    80001c52:	00004097          	auipc	ra,0x4
    80001c56:	4bc080e7          	jalr	1212(ra) # 8000610e <uartintr>
    80001c5a:	b7ed                	j	80001c44 <devintr+0x5e>
      virtio_disk_intr();
    80001c5c:	00004097          	auipc	ra,0x4
    80001c60:	a00080e7          	jalr	-1536(ra) # 8000565c <virtio_disk_intr>
    80001c64:	b7c5                	j	80001c44 <devintr+0x5e>
    if(cpuid() == 0){
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	1b6080e7          	jalr	438(ra) # 80000e1c <cpuid>
    80001c6e:	c901                	beqz	a0,80001c7e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001c70:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001c74:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001c76:	14479073          	csrw	sip,a5
    return 2;
    80001c7a:	4509                	li	a0,2
    80001c7c:	b761                	j	80001c04 <devintr+0x1e>
      clockintr();
    80001c7e:	00000097          	auipc	ra,0x0
    80001c82:	f22080e7          	jalr	-222(ra) # 80001ba0 <clockintr>
    80001c86:	b7ed                	j	80001c70 <devintr+0x8a>

0000000080001c88 <usertrap>:
{
    80001c88:	1101                	addi	sp,sp,-32
    80001c8a:	ec06                	sd	ra,24(sp)
    80001c8c:	e822                	sd	s0,16(sp)
    80001c8e:	e426                	sd	s1,8(sp)
    80001c90:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c92:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001c96:	1007f793          	andi	a5,a5,256
    80001c9a:	e3a5                	bnez	a5,80001cfa <usertrap+0x72>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c9c:	00003797          	auipc	a5,0x3
    80001ca0:	3b478793          	addi	a5,a5,948 # 80005050 <kernelvec>
    80001ca4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	1a0080e7          	jalr	416(ra) # 80000e48 <myproc>
    80001cb0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001cb2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001cb4:	14102773          	csrr	a4,sepc
    80001cb8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001cba:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001cbe:	47a1                	li	a5,8
    80001cc0:	04f71b63          	bne	a4,a5,80001d16 <usertrap+0x8e>
    if(p->killed)
    80001cc4:	551c                	lw	a5,40(a0)
    80001cc6:	e3b1                	bnez	a5,80001d0a <usertrap+0x82>
    p->trapframe->epc += 4;
    80001cc8:	6cb8                	ld	a4,88(s1)
    80001cca:	6f1c                	ld	a5,24(a4)
    80001ccc:	0791                	addi	a5,a5,4
    80001cce:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cd0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001cd4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001cd8:	10079073          	csrw	sstatus,a5
    syscall();
    80001cdc:	00000097          	auipc	ra,0x0
    80001ce0:	318080e7          	jalr	792(ra) # 80001ff4 <syscall>
  if(p->killed)
    80001ce4:	549c                	lw	a5,40(s1)
    80001ce6:	e3e1                	bnez	a5,80001da6 <usertrap+0x11e>
  usertrapret();
    80001ce8:	00000097          	auipc	ra,0x0
    80001cec:	e1a080e7          	jalr	-486(ra) # 80001b02 <usertrapret>
}
    80001cf0:	60e2                	ld	ra,24(sp)
    80001cf2:	6442                	ld	s0,16(sp)
    80001cf4:	64a2                	ld	s1,8(sp)
    80001cf6:	6105                	addi	sp,sp,32
    80001cf8:	8082                	ret
    panic("usertrap: not from user mode");
    80001cfa:	00006517          	auipc	a0,0x6
    80001cfe:	59e50513          	addi	a0,a0,1438 # 80008298 <states.1719+0x58>
    80001d02:	00004097          	auipc	ra,0x4
    80001d06:	f46080e7          	jalr	-186(ra) # 80005c48 <panic>
      exit(-1);
    80001d0a:	557d                	li	a0,-1
    80001d0c:	00000097          	auipc	ra,0x0
    80001d10:	aaa080e7          	jalr	-1366(ra) # 800017b6 <exit>
    80001d14:	bf55                	j	80001cc8 <usertrap+0x40>
  } else if((which_dev = devintr()) != 0){
    80001d16:	00000097          	auipc	ra,0x0
    80001d1a:	ed0080e7          	jalr	-304(ra) # 80001be6 <devintr>
    80001d1e:	c939                	beqz	a0,80001d74 <usertrap+0xec>
      if(which_dev == 2)
    80001d20:	4789                	li	a5,2
    80001d22:	fcf511e3          	bne	a0,a5,80001ce4 <usertrap+0x5c>
        if(p->alarm_interval > 0 && p->in_alarm_handler==0)
    80001d26:	1684a783          	lw	a5,360(s1)
    80001d2a:	00f05e63          	blez	a5,80001d46 <usertrap+0xbe>
    80001d2e:	1884a703          	lw	a4,392(s1)
    80001d32:	eb11                	bnez	a4,80001d46 <usertrap+0xbe>
            p->ticks_since_alarm++;
    80001d34:	1784a703          	lw	a4,376(s1)
    80001d38:	2705                	addiw	a4,a4,1
    80001d3a:	0007069b          	sext.w	a3,a4
            if(p->ticks_since_alarm >= p->alarm_interval)
    80001d3e:	00f6d963          	bge	a3,a5,80001d50 <usertrap+0xc8>
            p->ticks_since_alarm++;
    80001d42:	16e4ac23          	sw	a4,376(s1)
        yield();
    80001d46:	fffff097          	auipc	ra,0xfffff
    80001d4a:	7d8080e7          	jalr	2008(ra) # 8000151e <yield>
    80001d4e:	bf59                	j	80001ce4 <usertrap+0x5c>
                p->ticks_since_alarm = 0;
    80001d50:	1604ac23          	sw	zero,376(s1)
                memmove(p->alarm_tf, p->trapframe, PGSIZE);
    80001d54:	6605                	lui	a2,0x1
    80001d56:	6cac                	ld	a1,88(s1)
    80001d58:	1804b503          	ld	a0,384(s1)
    80001d5c:	ffffe097          	auipc	ra,0xffffe
    80001d60:	47c080e7          	jalr	1148(ra) # 800001d8 <memmove>
                p->trapframe->epc = p->alarm_handler;
    80001d64:	6cbc                	ld	a5,88(s1)
    80001d66:	1704b703          	ld	a4,368(s1)
    80001d6a:	ef98                	sd	a4,24(a5)
                p->in_alarm_handler = 1;
    80001d6c:	4785                	li	a5,1
    80001d6e:	18f4a423          	sw	a5,392(s1)
    80001d72:	bfd1                	j	80001d46 <usertrap+0xbe>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d74:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001d78:	5890                	lw	a2,48(s1)
    80001d7a:	00006517          	auipc	a0,0x6
    80001d7e:	53e50513          	addi	a0,a0,1342 # 800082b8 <states.1719+0x78>
    80001d82:	00004097          	auipc	ra,0x4
    80001d86:	f10080e7          	jalr	-240(ra) # 80005c92 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d8a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001d8e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001d92:	00006517          	auipc	a0,0x6
    80001d96:	55650513          	addi	a0,a0,1366 # 800082e8 <states.1719+0xa8>
    80001d9a:	00004097          	auipc	ra,0x4
    80001d9e:	ef8080e7          	jalr	-264(ra) # 80005c92 <printf>
    p->killed = 1;
    80001da2:	4785                	li	a5,1
    80001da4:	d49c                	sw	a5,40(s1)
    exit(-1);
    80001da6:	557d                	li	a0,-1
    80001da8:	00000097          	auipc	ra,0x0
    80001dac:	a0e080e7          	jalr	-1522(ra) # 800017b6 <exit>
    80001db0:	bf25                	j	80001ce8 <usertrap+0x60>

0000000080001db2 <kerneltrap>:
{
    80001db2:	7179                	addi	sp,sp,-48
    80001db4:	f406                	sd	ra,40(sp)
    80001db6:	f022                	sd	s0,32(sp)
    80001db8:	ec26                	sd	s1,24(sp)
    80001dba:	e84a                	sd	s2,16(sp)
    80001dbc:	e44e                	sd	s3,8(sp)
    80001dbe:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001dc0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dc4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001dc8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001dcc:	1004f793          	andi	a5,s1,256
    80001dd0:	cb85                	beqz	a5,80001e00 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dd2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001dd6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001dd8:	ef85                	bnez	a5,80001e10 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001dda:	00000097          	auipc	ra,0x0
    80001dde:	e0c080e7          	jalr	-500(ra) # 80001be6 <devintr>
    80001de2:	cd1d                	beqz	a0,80001e20 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001de4:	4789                	li	a5,2
    80001de6:	06f50a63          	beq	a0,a5,80001e5a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001dea:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dee:	10049073          	csrw	sstatus,s1
}
    80001df2:	70a2                	ld	ra,40(sp)
    80001df4:	7402                	ld	s0,32(sp)
    80001df6:	64e2                	ld	s1,24(sp)
    80001df8:	6942                	ld	s2,16(sp)
    80001dfa:	69a2                	ld	s3,8(sp)
    80001dfc:	6145                	addi	sp,sp,48
    80001dfe:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001e00:	00006517          	auipc	a0,0x6
    80001e04:	50850513          	addi	a0,a0,1288 # 80008308 <states.1719+0xc8>
    80001e08:	00004097          	auipc	ra,0x4
    80001e0c:	e40080e7          	jalr	-448(ra) # 80005c48 <panic>
    panic("kerneltrap: interrupts enabled");
    80001e10:	00006517          	auipc	a0,0x6
    80001e14:	52050513          	addi	a0,a0,1312 # 80008330 <states.1719+0xf0>
    80001e18:	00004097          	auipc	ra,0x4
    80001e1c:	e30080e7          	jalr	-464(ra) # 80005c48 <panic>
    printf("scause %p\n", scause);
    80001e20:	85ce                	mv	a1,s3
    80001e22:	00006517          	auipc	a0,0x6
    80001e26:	52e50513          	addi	a0,a0,1326 # 80008350 <states.1719+0x110>
    80001e2a:	00004097          	auipc	ra,0x4
    80001e2e:	e68080e7          	jalr	-408(ra) # 80005c92 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e32:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e36:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e3a:	00006517          	auipc	a0,0x6
    80001e3e:	52650513          	addi	a0,a0,1318 # 80008360 <states.1719+0x120>
    80001e42:	00004097          	auipc	ra,0x4
    80001e46:	e50080e7          	jalr	-432(ra) # 80005c92 <printf>
    panic("kerneltrap");
    80001e4a:	00006517          	auipc	a0,0x6
    80001e4e:	52e50513          	addi	a0,a0,1326 # 80008378 <states.1719+0x138>
    80001e52:	00004097          	auipc	ra,0x4
    80001e56:	df6080e7          	jalr	-522(ra) # 80005c48 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	fee080e7          	jalr	-18(ra) # 80000e48 <myproc>
    80001e62:	d541                	beqz	a0,80001dea <kerneltrap+0x38>
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	fe4080e7          	jalr	-28(ra) # 80000e48 <myproc>
    80001e6c:	4d18                	lw	a4,24(a0)
    80001e6e:	4791                	li	a5,4
    80001e70:	f6f71de3          	bne	a4,a5,80001dea <kerneltrap+0x38>
    yield();
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	6aa080e7          	jalr	1706(ra) # 8000151e <yield>
    80001e7c:	b7bd                	j	80001dea <kerneltrap+0x38>

0000000080001e7e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001e7e:	1101                	addi	sp,sp,-32
    80001e80:	ec06                	sd	ra,24(sp)
    80001e82:	e822                	sd	s0,16(sp)
    80001e84:	e426                	sd	s1,8(sp)
    80001e86:	1000                	addi	s0,sp,32
    80001e88:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	fbe080e7          	jalr	-66(ra) # 80000e48 <myproc>
  switch (n) {
    80001e92:	4795                	li	a5,5
    80001e94:	0497e163          	bltu	a5,s1,80001ed6 <argraw+0x58>
    80001e98:	048a                	slli	s1,s1,0x2
    80001e9a:	00006717          	auipc	a4,0x6
    80001e9e:	51670713          	addi	a4,a4,1302 # 800083b0 <states.1719+0x170>
    80001ea2:	94ba                	add	s1,s1,a4
    80001ea4:	409c                	lw	a5,0(s1)
    80001ea6:	97ba                	add	a5,a5,a4
    80001ea8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001eaa:	6d3c                	ld	a5,88(a0)
    80001eac:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001eae:	60e2                	ld	ra,24(sp)
    80001eb0:	6442                	ld	s0,16(sp)
    80001eb2:	64a2                	ld	s1,8(sp)
    80001eb4:	6105                	addi	sp,sp,32
    80001eb6:	8082                	ret
    return p->trapframe->a1;
    80001eb8:	6d3c                	ld	a5,88(a0)
    80001eba:	7fa8                	ld	a0,120(a5)
    80001ebc:	bfcd                	j	80001eae <argraw+0x30>
    return p->trapframe->a2;
    80001ebe:	6d3c                	ld	a5,88(a0)
    80001ec0:	63c8                	ld	a0,128(a5)
    80001ec2:	b7f5                	j	80001eae <argraw+0x30>
    return p->trapframe->a3;
    80001ec4:	6d3c                	ld	a5,88(a0)
    80001ec6:	67c8                	ld	a0,136(a5)
    80001ec8:	b7dd                	j	80001eae <argraw+0x30>
    return p->trapframe->a4;
    80001eca:	6d3c                	ld	a5,88(a0)
    80001ecc:	6bc8                	ld	a0,144(a5)
    80001ece:	b7c5                	j	80001eae <argraw+0x30>
    return p->trapframe->a5;
    80001ed0:	6d3c                	ld	a5,88(a0)
    80001ed2:	6fc8                	ld	a0,152(a5)
    80001ed4:	bfe9                	j	80001eae <argraw+0x30>
  panic("argraw");
    80001ed6:	00006517          	auipc	a0,0x6
    80001eda:	4b250513          	addi	a0,a0,1202 # 80008388 <states.1719+0x148>
    80001ede:	00004097          	auipc	ra,0x4
    80001ee2:	d6a080e7          	jalr	-662(ra) # 80005c48 <panic>

0000000080001ee6 <fetchaddr>:
{
    80001ee6:	1101                	addi	sp,sp,-32
    80001ee8:	ec06                	sd	ra,24(sp)
    80001eea:	e822                	sd	s0,16(sp)
    80001eec:	e426                	sd	s1,8(sp)
    80001eee:	e04a                	sd	s2,0(sp)
    80001ef0:	1000                	addi	s0,sp,32
    80001ef2:	84aa                	mv	s1,a0
    80001ef4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	f52080e7          	jalr	-174(ra) # 80000e48 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80001efe:	653c                	ld	a5,72(a0)
    80001f00:	02f4f863          	bgeu	s1,a5,80001f30 <fetchaddr+0x4a>
    80001f04:	00848713          	addi	a4,s1,8
    80001f08:	02e7e663          	bltu	a5,a4,80001f34 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001f0c:	46a1                	li	a3,8
    80001f0e:	8626                	mv	a2,s1
    80001f10:	85ca                	mv	a1,s2
    80001f12:	6928                	ld	a0,80(a0)
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	c82080e7          	jalr	-894(ra) # 80000b96 <copyin>
    80001f1c:	00a03533          	snez	a0,a0
    80001f20:	40a00533          	neg	a0,a0
}
    80001f24:	60e2                	ld	ra,24(sp)
    80001f26:	6442                	ld	s0,16(sp)
    80001f28:	64a2                	ld	s1,8(sp)
    80001f2a:	6902                	ld	s2,0(sp)
    80001f2c:	6105                	addi	sp,sp,32
    80001f2e:	8082                	ret
    return -1;
    80001f30:	557d                	li	a0,-1
    80001f32:	bfcd                	j	80001f24 <fetchaddr+0x3e>
    80001f34:	557d                	li	a0,-1
    80001f36:	b7fd                	j	80001f24 <fetchaddr+0x3e>

0000000080001f38 <fetchstr>:
{
    80001f38:	7179                	addi	sp,sp,-48
    80001f3a:	f406                	sd	ra,40(sp)
    80001f3c:	f022                	sd	s0,32(sp)
    80001f3e:	ec26                	sd	s1,24(sp)
    80001f40:	e84a                	sd	s2,16(sp)
    80001f42:	e44e                	sd	s3,8(sp)
    80001f44:	1800                	addi	s0,sp,48
    80001f46:	892a                	mv	s2,a0
    80001f48:	84ae                	mv	s1,a1
    80001f4a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	efc080e7          	jalr	-260(ra) # 80000e48 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80001f54:	86ce                	mv	a3,s3
    80001f56:	864a                	mv	a2,s2
    80001f58:	85a6                	mv	a1,s1
    80001f5a:	6928                	ld	a0,80(a0)
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	cc6080e7          	jalr	-826(ra) # 80000c22 <copyinstr>
  if(err < 0)
    80001f64:	00054763          	bltz	a0,80001f72 <fetchstr+0x3a>
  return strlen(buf);
    80001f68:	8526                	mv	a0,s1
    80001f6a:	ffffe097          	auipc	ra,0xffffe
    80001f6e:	392080e7          	jalr	914(ra) # 800002fc <strlen>
}
    80001f72:	70a2                	ld	ra,40(sp)
    80001f74:	7402                	ld	s0,32(sp)
    80001f76:	64e2                	ld	s1,24(sp)
    80001f78:	6942                	ld	s2,16(sp)
    80001f7a:	69a2                	ld	s3,8(sp)
    80001f7c:	6145                	addi	sp,sp,48
    80001f7e:	8082                	ret

0000000080001f80 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80001f80:	1101                	addi	sp,sp,-32
    80001f82:	ec06                	sd	ra,24(sp)
    80001f84:	e822                	sd	s0,16(sp)
    80001f86:	e426                	sd	s1,8(sp)
    80001f88:	1000                	addi	s0,sp,32
    80001f8a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001f8c:	00000097          	auipc	ra,0x0
    80001f90:	ef2080e7          	jalr	-270(ra) # 80001e7e <argraw>
    80001f94:	c088                	sw	a0,0(s1)
  return 0;
}
    80001f96:	4501                	li	a0,0
    80001f98:	60e2                	ld	ra,24(sp)
    80001f9a:	6442                	ld	s0,16(sp)
    80001f9c:	64a2                	ld	s1,8(sp)
    80001f9e:	6105                	addi	sp,sp,32
    80001fa0:	8082                	ret

0000000080001fa2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80001fa2:	1101                	addi	sp,sp,-32
    80001fa4:	ec06                	sd	ra,24(sp)
    80001fa6:	e822                	sd	s0,16(sp)
    80001fa8:	e426                	sd	s1,8(sp)
    80001faa:	1000                	addi	s0,sp,32
    80001fac:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001fae:	00000097          	auipc	ra,0x0
    80001fb2:	ed0080e7          	jalr	-304(ra) # 80001e7e <argraw>
    80001fb6:	e088                	sd	a0,0(s1)
  return 0;
}
    80001fb8:	4501                	li	a0,0
    80001fba:	60e2                	ld	ra,24(sp)
    80001fbc:	6442                	ld	s0,16(sp)
    80001fbe:	64a2                	ld	s1,8(sp)
    80001fc0:	6105                	addi	sp,sp,32
    80001fc2:	8082                	ret

0000000080001fc4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001fc4:	1101                	addi	sp,sp,-32
    80001fc6:	ec06                	sd	ra,24(sp)
    80001fc8:	e822                	sd	s0,16(sp)
    80001fca:	e426                	sd	s1,8(sp)
    80001fcc:	e04a                	sd	s2,0(sp)
    80001fce:	1000                	addi	s0,sp,32
    80001fd0:	84ae                	mv	s1,a1
    80001fd2:	8932                	mv	s2,a2
  *ip = argraw(n);
    80001fd4:	00000097          	auipc	ra,0x0
    80001fd8:	eaa080e7          	jalr	-342(ra) # 80001e7e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80001fdc:	864a                	mv	a2,s2
    80001fde:	85a6                	mv	a1,s1
    80001fe0:	00000097          	auipc	ra,0x0
    80001fe4:	f58080e7          	jalr	-168(ra) # 80001f38 <fetchstr>
}
    80001fe8:	60e2                	ld	ra,24(sp)
    80001fea:	6442                	ld	s0,16(sp)
    80001fec:	64a2                	ld	s1,8(sp)
    80001fee:	6902                	ld	s2,0(sp)
    80001ff0:	6105                	addi	sp,sp,32
    80001ff2:	8082                	ret

0000000080001ff4 <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    80001ff4:	1101                	addi	sp,sp,-32
    80001ff6:	ec06                	sd	ra,24(sp)
    80001ff8:	e822                	sd	s0,16(sp)
    80001ffa:	e426                	sd	s1,8(sp)
    80001ffc:	e04a                	sd	s2,0(sp)
    80001ffe:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	e48080e7          	jalr	-440(ra) # 80000e48 <myproc>
    80002008:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000200a:	05853903          	ld	s2,88(a0)
    8000200e:	0a893783          	ld	a5,168(s2) # 8000fa80 <bcache+0x1e8>
    80002012:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002016:	37fd                	addiw	a5,a5,-1
    80002018:	4759                	li	a4,22
    8000201a:	00f76f63          	bltu	a4,a5,80002038 <syscall+0x44>
    8000201e:	00369713          	slli	a4,a3,0x3
    80002022:	00006797          	auipc	a5,0x6
    80002026:	3a678793          	addi	a5,a5,934 # 800083c8 <syscalls>
    8000202a:	97ba                	add	a5,a5,a4
    8000202c:	639c                	ld	a5,0(a5)
    8000202e:	c789                	beqz	a5,80002038 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002030:	9782                	jalr	a5
    80002032:	06a93823          	sd	a0,112(s2)
    80002036:	a839                	j	80002054 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002038:	15848613          	addi	a2,s1,344
    8000203c:	588c                	lw	a1,48(s1)
    8000203e:	00006517          	auipc	a0,0x6
    80002042:	35250513          	addi	a0,a0,850 # 80008390 <states.1719+0x150>
    80002046:	00004097          	auipc	ra,0x4
    8000204a:	c4c080e7          	jalr	-948(ra) # 80005c92 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000204e:	6cbc                	ld	a5,88(s1)
    80002050:	577d                	li	a4,-1
    80002052:	fbb8                	sd	a4,112(a5)
  }
}
    80002054:	60e2                	ld	ra,24(sp)
    80002056:	6442                	ld	s0,16(sp)
    80002058:	64a2                	ld	s1,8(sp)
    8000205a:	6902                	ld	s2,0(sp)
    8000205c:	6105                	addi	sp,sp,32
    8000205e:	8082                	ret

0000000080002060 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002060:	1101                	addi	sp,sp,-32
    80002062:	ec06                	sd	ra,24(sp)
    80002064:	e822                	sd	s0,16(sp)
    80002066:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002068:	fec40593          	addi	a1,s0,-20
    8000206c:	4501                	li	a0,0
    8000206e:	00000097          	auipc	ra,0x0
    80002072:	f12080e7          	jalr	-238(ra) # 80001f80 <argint>
    return -1;
    80002076:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002078:	00054963          	bltz	a0,8000208a <sys_exit+0x2a>
  exit(n);
    8000207c:	fec42503          	lw	a0,-20(s0)
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	736080e7          	jalr	1846(ra) # 800017b6 <exit>
  return 0;  // not reached
    80002088:	4781                	li	a5,0
}
    8000208a:	853e                	mv	a0,a5
    8000208c:	60e2                	ld	ra,24(sp)
    8000208e:	6442                	ld	s0,16(sp)
    80002090:	6105                	addi	sp,sp,32
    80002092:	8082                	ret

0000000080002094 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002094:	1141                	addi	sp,sp,-16
    80002096:	e406                	sd	ra,8(sp)
    80002098:	e022                	sd	s0,0(sp)
    8000209a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000209c:	fffff097          	auipc	ra,0xfffff
    800020a0:	dac080e7          	jalr	-596(ra) # 80000e48 <myproc>
}
    800020a4:	5908                	lw	a0,48(a0)
    800020a6:	60a2                	ld	ra,8(sp)
    800020a8:	6402                	ld	s0,0(sp)
    800020aa:	0141                	addi	sp,sp,16
    800020ac:	8082                	ret

00000000800020ae <sys_fork>:

uint64
sys_fork(void)
{
    800020ae:	1141                	addi	sp,sp,-16
    800020b0:	e406                	sd	ra,8(sp)
    800020b2:	e022                	sd	s0,0(sp)
    800020b4:	0800                	addi	s0,sp,16
  return fork();
    800020b6:	fffff097          	auipc	ra,0xfffff
    800020ba:	1b6080e7          	jalr	438(ra) # 8000126c <fork>
}
    800020be:	60a2                	ld	ra,8(sp)
    800020c0:	6402                	ld	s0,0(sp)
    800020c2:	0141                	addi	sp,sp,16
    800020c4:	8082                	ret

00000000800020c6 <sys_wait>:

uint64
sys_wait(void)
{
    800020c6:	1101                	addi	sp,sp,-32
    800020c8:	ec06                	sd	ra,24(sp)
    800020ca:	e822                	sd	s0,16(sp)
    800020cc:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800020ce:	fe840593          	addi	a1,s0,-24
    800020d2:	4501                	li	a0,0
    800020d4:	00000097          	auipc	ra,0x0
    800020d8:	ece080e7          	jalr	-306(ra) # 80001fa2 <argaddr>
    800020dc:	87aa                	mv	a5,a0
    return -1;
    800020de:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800020e0:	0007c863          	bltz	a5,800020f0 <sys_wait+0x2a>
  return wait(p);
    800020e4:	fe843503          	ld	a0,-24(s0)
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	4d6080e7          	jalr	1238(ra) # 800015be <wait>
}
    800020f0:	60e2                	ld	ra,24(sp)
    800020f2:	6442                	ld	s0,16(sp)
    800020f4:	6105                	addi	sp,sp,32
    800020f6:	8082                	ret

00000000800020f8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800020f8:	7179                	addi	sp,sp,-48
    800020fa:	f406                	sd	ra,40(sp)
    800020fc:	f022                	sd	s0,32(sp)
    800020fe:	ec26                	sd	s1,24(sp)
    80002100:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002102:	fdc40593          	addi	a1,s0,-36
    80002106:	4501                	li	a0,0
    80002108:	00000097          	auipc	ra,0x0
    8000210c:	e78080e7          	jalr	-392(ra) # 80001f80 <argint>
    80002110:	87aa                	mv	a5,a0
    return -1;
    80002112:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002114:	0207c063          	bltz	a5,80002134 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	d30080e7          	jalr	-720(ra) # 80000e48 <myproc>
    80002120:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002122:	fdc42503          	lw	a0,-36(s0)
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	0d2080e7          	jalr	210(ra) # 800011f8 <growproc>
    8000212e:	00054863          	bltz	a0,8000213e <sys_sbrk+0x46>
    return -1;
  return addr;
    80002132:	8526                	mv	a0,s1
}
    80002134:	70a2                	ld	ra,40(sp)
    80002136:	7402                	ld	s0,32(sp)
    80002138:	64e2                	ld	s1,24(sp)
    8000213a:	6145                	addi	sp,sp,48
    8000213c:	8082                	ret
    return -1;
    8000213e:	557d                	li	a0,-1
    80002140:	bfd5                	j	80002134 <sys_sbrk+0x3c>

0000000080002142 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002142:	7139                	addi	sp,sp,-64
    80002144:	fc06                	sd	ra,56(sp)
    80002146:	f822                	sd	s0,48(sp)
    80002148:	f426                	sd	s1,40(sp)
    8000214a:	f04a                	sd	s2,32(sp)
    8000214c:	ec4e                	sd	s3,24(sp)
    8000214e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;
  if(argint(0, &n) < 0)
    80002150:	fcc40593          	addi	a1,s0,-52
    80002154:	4501                	li	a0,0
    80002156:	00000097          	auipc	ra,0x0
    8000215a:	e2a080e7          	jalr	-470(ra) # 80001f80 <argint>
    return -1;
    8000215e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002160:	06054963          	bltz	a0,800021d2 <sys_sleep+0x90>
  acquire(&tickslock);
    80002164:	0000d517          	auipc	a0,0xd
    80002168:	71c50513          	addi	a0,a0,1820 # 8000f880 <tickslock>
    8000216c:	00004097          	auipc	ra,0x4
    80002170:	082080e7          	jalr	130(ra) # 800061ee <acquire>
  ticks0 = ticks;
    80002174:	00007917          	auipc	s2,0x7
    80002178:	ea492903          	lw	s2,-348(s2) # 80009018 <ticks>
  while(ticks - ticks0 < n){
    8000217c:	fcc42783          	lw	a5,-52(s0)
    80002180:	cf85                	beqz	a5,800021b8 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002182:	0000d997          	auipc	s3,0xd
    80002186:	6fe98993          	addi	s3,s3,1790 # 8000f880 <tickslock>
    8000218a:	00007497          	auipc	s1,0x7
    8000218e:	e8e48493          	addi	s1,s1,-370 # 80009018 <ticks>
    if(myproc()->killed){
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	cb6080e7          	jalr	-842(ra) # 80000e48 <myproc>
    8000219a:	551c                	lw	a5,40(a0)
    8000219c:	e3b9                	bnez	a5,800021e2 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    8000219e:	85ce                	mv	a1,s3
    800021a0:	8526                	mv	a0,s1
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	3b8080e7          	jalr	952(ra) # 8000155a <sleep>
  while(ticks - ticks0 < n){
    800021aa:	409c                	lw	a5,0(s1)
    800021ac:	412787bb          	subw	a5,a5,s2
    800021b0:	fcc42703          	lw	a4,-52(s0)
    800021b4:	fce7efe3          	bltu	a5,a4,80002192 <sys_sleep+0x50>
  }
  backtrace();
    800021b8:	00004097          	auipc	ra,0x4
    800021bc:	cf2080e7          	jalr	-782(ra) # 80005eaa <backtrace>
  release(&tickslock);
    800021c0:	0000d517          	auipc	a0,0xd
    800021c4:	6c050513          	addi	a0,a0,1728 # 8000f880 <tickslock>
    800021c8:	00004097          	auipc	ra,0x4
    800021cc:	0da080e7          	jalr	218(ra) # 800062a2 <release>
  return 0;
    800021d0:	4781                	li	a5,0
}
    800021d2:	853e                	mv	a0,a5
    800021d4:	70e2                	ld	ra,56(sp)
    800021d6:	7442                	ld	s0,48(sp)
    800021d8:	74a2                	ld	s1,40(sp)
    800021da:	7902                	ld	s2,32(sp)
    800021dc:	69e2                	ld	s3,24(sp)
    800021de:	6121                	addi	sp,sp,64
    800021e0:	8082                	ret
      release(&tickslock);
    800021e2:	0000d517          	auipc	a0,0xd
    800021e6:	69e50513          	addi	a0,a0,1694 # 8000f880 <tickslock>
    800021ea:	00004097          	auipc	ra,0x4
    800021ee:	0b8080e7          	jalr	184(ra) # 800062a2 <release>
      return -1;
    800021f2:	57fd                	li	a5,-1
    800021f4:	bff9                	j	800021d2 <sys_sleep+0x90>

00000000800021f6 <sys_kill>:

uint64
sys_kill(void)
{
    800021f6:	1101                	addi	sp,sp,-32
    800021f8:	ec06                	sd	ra,24(sp)
    800021fa:	e822                	sd	s0,16(sp)
    800021fc:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800021fe:	fec40593          	addi	a1,s0,-20
    80002202:	4501                	li	a0,0
    80002204:	00000097          	auipc	ra,0x0
    80002208:	d7c080e7          	jalr	-644(ra) # 80001f80 <argint>
    8000220c:	87aa                	mv	a5,a0
    return -1;
    8000220e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002210:	0007c863          	bltz	a5,80002220 <sys_kill+0x2a>
  return kill(pid);
    80002214:	fec42503          	lw	a0,-20(s0)
    80002218:	fffff097          	auipc	ra,0xfffff
    8000221c:	674080e7          	jalr	1652(ra) # 8000188c <kill>
}
    80002220:	60e2                	ld	ra,24(sp)
    80002222:	6442                	ld	s0,16(sp)
    80002224:	6105                	addi	sp,sp,32
    80002226:	8082                	ret

0000000080002228 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002228:	1101                	addi	sp,sp,-32
    8000222a:	ec06                	sd	ra,24(sp)
    8000222c:	e822                	sd	s0,16(sp)
    8000222e:	e426                	sd	s1,8(sp)
    80002230:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002232:	0000d517          	auipc	a0,0xd
    80002236:	64e50513          	addi	a0,a0,1614 # 8000f880 <tickslock>
    8000223a:	00004097          	auipc	ra,0x4
    8000223e:	fb4080e7          	jalr	-76(ra) # 800061ee <acquire>
  xticks = ticks;
    80002242:	00007497          	auipc	s1,0x7
    80002246:	dd64a483          	lw	s1,-554(s1) # 80009018 <ticks>
  release(&tickslock);
    8000224a:	0000d517          	auipc	a0,0xd
    8000224e:	63650513          	addi	a0,a0,1590 # 8000f880 <tickslock>
    80002252:	00004097          	auipc	ra,0x4
    80002256:	050080e7          	jalr	80(ra) # 800062a2 <release>
  return xticks;
}
    8000225a:	02049513          	slli	a0,s1,0x20
    8000225e:	9101                	srli	a0,a0,0x20
    80002260:	60e2                	ld	ra,24(sp)
    80002262:	6442                	ld	s0,16(sp)
    80002264:	64a2                	ld	s1,8(sp)
    80002266:	6105                	addi	sp,sp,32
    80002268:	8082                	ret

000000008000226a <sys_sigalarm>:

uint64 sys_sigalarm()
{
    8000226a:	1101                	addi	sp,sp,-32
    8000226c:	ec06                	sd	ra,24(sp)
    8000226e:	e822                	sd	s0,16(sp)
    80002270:	1000                	addi	s0,sp,32
  printf("sys_sigalarm\n");
    80002272:	00006517          	auipc	a0,0x6
    80002276:	21650513          	addi	a0,a0,534 # 80008488 <syscalls+0xc0>
    8000227a:	00004097          	auipc	ra,0x4
    8000227e:	a18080e7          	jalr	-1512(ra) # 80005c92 <printf>
  int interval;
  uint64 handler;
  if(argint(0, &interval) < 0)
    80002282:	fec40593          	addi	a1,s0,-20
    80002286:	4501                	li	a0,0
    80002288:	00000097          	auipc	ra,0x0
    8000228c:	cf8080e7          	jalr	-776(ra) # 80001f80 <argint>
    return -1;
    80002290:	57fd                	li	a5,-1
  if(argint(0, &interval) < 0)
    80002292:	02054d63          	bltz	a0,800022cc <sys_sigalarm+0x62>
  if (argaddr(1, &handler) < 0)
    80002296:	fe040593          	addi	a1,s0,-32
    8000229a:	4505                	li	a0,1
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	d06080e7          	jalr	-762(ra) # 80001fa2 <argaddr>
    return -1;
    800022a4:	57fd                	li	a5,-1
  if (argaddr(1, &handler) < 0)
    800022a6:	02054363          	bltz	a0,800022cc <sys_sigalarm+0x62>
  struct proc *p = myproc();
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	b9e080e7          	jalr	-1122(ra) # 80000e48 <myproc>
  p->alarm_interval = interval;
    800022b2:	fec42783          	lw	a5,-20(s0)
    800022b6:	16f52423          	sw	a5,360(a0)
  p->alarm_handler = handler;;
    800022ba:	fe043783          	ld	a5,-32(s0)
    800022be:	16f53823          	sd	a5,368(a0)
  p->ticks_since_alarm = 0;
    800022c2:	16052c23          	sw	zero,376(a0)
  p->in_alarm_handler = 0;
    800022c6:	18052423          	sw	zero,392(a0)
  return 0;
    800022ca:	4781                	li	a5,0
}
    800022cc:	853e                	mv	a0,a5
    800022ce:	60e2                	ld	ra,24(sp)
    800022d0:	6442                	ld	s0,16(sp)
    800022d2:	6105                	addi	sp,sp,32
    800022d4:	8082                	ret

00000000800022d6 <sys_sigreturn>:
uint64 sys_sigreturn(void)
{
    800022d6:	1101                	addi	sp,sp,-32
    800022d8:	ec06                	sd	ra,24(sp)
    800022da:	e822                	sd	s0,16(sp)
    800022dc:	e426                	sd	s1,8(sp)
    800022de:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	b68080e7          	jalr	-1176(ra) # 80000e48 <myproc>
    800022e8:	84aa                	mv	s1,a0

    memmove(p->trapframe, p->alarm_tf, PGSIZE);
    800022ea:	6605                	lui	a2,0x1
    800022ec:	18053583          	ld	a1,384(a0)
    800022f0:	6d28                	ld	a0,88(a0)
    800022f2:	ffffe097          	auipc	ra,0xffffe
    800022f6:	ee6080e7          	jalr	-282(ra) # 800001d8 <memmove>
    p->in_alarm_handler = 0;
    800022fa:	1804a423          	sw	zero,392(s1)

  return 0;
}
    800022fe:	4501                	li	a0,0
    80002300:	60e2                	ld	ra,24(sp)
    80002302:	6442                	ld	s0,16(sp)
    80002304:	64a2                	ld	s1,8(sp)
    80002306:	6105                	addi	sp,sp,32
    80002308:	8082                	ret

000000008000230a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000230a:	7179                	addi	sp,sp,-48
    8000230c:	f406                	sd	ra,40(sp)
    8000230e:	f022                	sd	s0,32(sp)
    80002310:	ec26                	sd	s1,24(sp)
    80002312:	e84a                	sd	s2,16(sp)
    80002314:	e44e                	sd	s3,8(sp)
    80002316:	e052                	sd	s4,0(sp)
    80002318:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000231a:	00006597          	auipc	a1,0x6
    8000231e:	17e58593          	addi	a1,a1,382 # 80008498 <syscalls+0xd0>
    80002322:	0000d517          	auipc	a0,0xd
    80002326:	57650513          	addi	a0,a0,1398 # 8000f898 <bcache>
    8000232a:	00004097          	auipc	ra,0x4
    8000232e:	e34080e7          	jalr	-460(ra) # 8000615e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002332:	00015797          	auipc	a5,0x15
    80002336:	56678793          	addi	a5,a5,1382 # 80017898 <bcache+0x8000>
    8000233a:	00015717          	auipc	a4,0x15
    8000233e:	7c670713          	addi	a4,a4,1990 # 80017b00 <bcache+0x8268>
    80002342:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002346:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000234a:	0000d497          	auipc	s1,0xd
    8000234e:	56648493          	addi	s1,s1,1382 # 8000f8b0 <bcache+0x18>
    b->next = bcache.head.next;
    80002352:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002354:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002356:	00006a17          	auipc	s4,0x6
    8000235a:	14aa0a13          	addi	s4,s4,330 # 800084a0 <syscalls+0xd8>
    b->next = bcache.head.next;
    8000235e:	2b893783          	ld	a5,696(s2)
    80002362:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002364:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002368:	85d2                	mv	a1,s4
    8000236a:	01048513          	addi	a0,s1,16
    8000236e:	00001097          	auipc	ra,0x1
    80002372:	4bc080e7          	jalr	1212(ra) # 8000382a <initsleeplock>
    bcache.head.next->prev = b;
    80002376:	2b893783          	ld	a5,696(s2)
    8000237a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000237c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002380:	45848493          	addi	s1,s1,1112
    80002384:	fd349de3          	bne	s1,s3,8000235e <binit+0x54>
  }
}
    80002388:	70a2                	ld	ra,40(sp)
    8000238a:	7402                	ld	s0,32(sp)
    8000238c:	64e2                	ld	s1,24(sp)
    8000238e:	6942                	ld	s2,16(sp)
    80002390:	69a2                	ld	s3,8(sp)
    80002392:	6a02                	ld	s4,0(sp)
    80002394:	6145                	addi	sp,sp,48
    80002396:	8082                	ret

0000000080002398 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002398:	7179                	addi	sp,sp,-48
    8000239a:	f406                	sd	ra,40(sp)
    8000239c:	f022                	sd	s0,32(sp)
    8000239e:	ec26                	sd	s1,24(sp)
    800023a0:	e84a                	sd	s2,16(sp)
    800023a2:	e44e                	sd	s3,8(sp)
    800023a4:	1800                	addi	s0,sp,48
    800023a6:	89aa                	mv	s3,a0
    800023a8:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800023aa:	0000d517          	auipc	a0,0xd
    800023ae:	4ee50513          	addi	a0,a0,1262 # 8000f898 <bcache>
    800023b2:	00004097          	auipc	ra,0x4
    800023b6:	e3c080e7          	jalr	-452(ra) # 800061ee <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800023ba:	00015497          	auipc	s1,0x15
    800023be:	7964b483          	ld	s1,1942(s1) # 80017b50 <bcache+0x82b8>
    800023c2:	00015797          	auipc	a5,0x15
    800023c6:	73e78793          	addi	a5,a5,1854 # 80017b00 <bcache+0x8268>
    800023ca:	02f48f63          	beq	s1,a5,80002408 <bread+0x70>
    800023ce:	873e                	mv	a4,a5
    800023d0:	a021                	j	800023d8 <bread+0x40>
    800023d2:	68a4                	ld	s1,80(s1)
    800023d4:	02e48a63          	beq	s1,a4,80002408 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800023d8:	449c                	lw	a5,8(s1)
    800023da:	ff379ce3          	bne	a5,s3,800023d2 <bread+0x3a>
    800023de:	44dc                	lw	a5,12(s1)
    800023e0:	ff2799e3          	bne	a5,s2,800023d2 <bread+0x3a>
      b->refcnt++;
    800023e4:	40bc                	lw	a5,64(s1)
    800023e6:	2785                	addiw	a5,a5,1
    800023e8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800023ea:	0000d517          	auipc	a0,0xd
    800023ee:	4ae50513          	addi	a0,a0,1198 # 8000f898 <bcache>
    800023f2:	00004097          	auipc	ra,0x4
    800023f6:	eb0080e7          	jalr	-336(ra) # 800062a2 <release>
      acquiresleep(&b->lock);
    800023fa:	01048513          	addi	a0,s1,16
    800023fe:	00001097          	auipc	ra,0x1
    80002402:	466080e7          	jalr	1126(ra) # 80003864 <acquiresleep>
      return b;
    80002406:	a8b9                	j	80002464 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002408:	00015497          	auipc	s1,0x15
    8000240c:	7404b483          	ld	s1,1856(s1) # 80017b48 <bcache+0x82b0>
    80002410:	00015797          	auipc	a5,0x15
    80002414:	6f078793          	addi	a5,a5,1776 # 80017b00 <bcache+0x8268>
    80002418:	00f48863          	beq	s1,a5,80002428 <bread+0x90>
    8000241c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000241e:	40bc                	lw	a5,64(s1)
    80002420:	cf81                	beqz	a5,80002438 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002422:	64a4                	ld	s1,72(s1)
    80002424:	fee49de3          	bne	s1,a4,8000241e <bread+0x86>
  panic("bget: no buffers");
    80002428:	00006517          	auipc	a0,0x6
    8000242c:	08050513          	addi	a0,a0,128 # 800084a8 <syscalls+0xe0>
    80002430:	00004097          	auipc	ra,0x4
    80002434:	818080e7          	jalr	-2024(ra) # 80005c48 <panic>
      b->dev = dev;
    80002438:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000243c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002440:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002444:	4785                	li	a5,1
    80002446:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002448:	0000d517          	auipc	a0,0xd
    8000244c:	45050513          	addi	a0,a0,1104 # 8000f898 <bcache>
    80002450:	00004097          	auipc	ra,0x4
    80002454:	e52080e7          	jalr	-430(ra) # 800062a2 <release>
      acquiresleep(&b->lock);
    80002458:	01048513          	addi	a0,s1,16
    8000245c:	00001097          	auipc	ra,0x1
    80002460:	408080e7          	jalr	1032(ra) # 80003864 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002464:	409c                	lw	a5,0(s1)
    80002466:	cb89                	beqz	a5,80002478 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002468:	8526                	mv	a0,s1
    8000246a:	70a2                	ld	ra,40(sp)
    8000246c:	7402                	ld	s0,32(sp)
    8000246e:	64e2                	ld	s1,24(sp)
    80002470:	6942                	ld	s2,16(sp)
    80002472:	69a2                	ld	s3,8(sp)
    80002474:	6145                	addi	sp,sp,48
    80002476:	8082                	ret
    virtio_disk_rw(b, 0);
    80002478:	4581                	li	a1,0
    8000247a:	8526                	mv	a0,s1
    8000247c:	00003097          	auipc	ra,0x3
    80002480:	f0a080e7          	jalr	-246(ra) # 80005386 <virtio_disk_rw>
    b->valid = 1;
    80002484:	4785                	li	a5,1
    80002486:	c09c                	sw	a5,0(s1)
  return b;
    80002488:	b7c5                	j	80002468 <bread+0xd0>

000000008000248a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000248a:	1101                	addi	sp,sp,-32
    8000248c:	ec06                	sd	ra,24(sp)
    8000248e:	e822                	sd	s0,16(sp)
    80002490:	e426                	sd	s1,8(sp)
    80002492:	1000                	addi	s0,sp,32
    80002494:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002496:	0541                	addi	a0,a0,16
    80002498:	00001097          	auipc	ra,0x1
    8000249c:	466080e7          	jalr	1126(ra) # 800038fe <holdingsleep>
    800024a0:	cd01                	beqz	a0,800024b8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800024a2:	4585                	li	a1,1
    800024a4:	8526                	mv	a0,s1
    800024a6:	00003097          	auipc	ra,0x3
    800024aa:	ee0080e7          	jalr	-288(ra) # 80005386 <virtio_disk_rw>
}
    800024ae:	60e2                	ld	ra,24(sp)
    800024b0:	6442                	ld	s0,16(sp)
    800024b2:	64a2                	ld	s1,8(sp)
    800024b4:	6105                	addi	sp,sp,32
    800024b6:	8082                	ret
    panic("bwrite");
    800024b8:	00006517          	auipc	a0,0x6
    800024bc:	00850513          	addi	a0,a0,8 # 800084c0 <syscalls+0xf8>
    800024c0:	00003097          	auipc	ra,0x3
    800024c4:	788080e7          	jalr	1928(ra) # 80005c48 <panic>

00000000800024c8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800024c8:	1101                	addi	sp,sp,-32
    800024ca:	ec06                	sd	ra,24(sp)
    800024cc:	e822                	sd	s0,16(sp)
    800024ce:	e426                	sd	s1,8(sp)
    800024d0:	e04a                	sd	s2,0(sp)
    800024d2:	1000                	addi	s0,sp,32
    800024d4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800024d6:	01050913          	addi	s2,a0,16
    800024da:	854a                	mv	a0,s2
    800024dc:	00001097          	auipc	ra,0x1
    800024e0:	422080e7          	jalr	1058(ra) # 800038fe <holdingsleep>
    800024e4:	c92d                	beqz	a0,80002556 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800024e6:	854a                	mv	a0,s2
    800024e8:	00001097          	auipc	ra,0x1
    800024ec:	3d2080e7          	jalr	978(ra) # 800038ba <releasesleep>

  acquire(&bcache.lock);
    800024f0:	0000d517          	auipc	a0,0xd
    800024f4:	3a850513          	addi	a0,a0,936 # 8000f898 <bcache>
    800024f8:	00004097          	auipc	ra,0x4
    800024fc:	cf6080e7          	jalr	-778(ra) # 800061ee <acquire>
  b->refcnt--;
    80002500:	40bc                	lw	a5,64(s1)
    80002502:	37fd                	addiw	a5,a5,-1
    80002504:	0007871b          	sext.w	a4,a5
    80002508:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000250a:	eb05                	bnez	a4,8000253a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000250c:	68bc                	ld	a5,80(s1)
    8000250e:	64b8                	ld	a4,72(s1)
    80002510:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002512:	64bc                	ld	a5,72(s1)
    80002514:	68b8                	ld	a4,80(s1)
    80002516:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002518:	00015797          	auipc	a5,0x15
    8000251c:	38078793          	addi	a5,a5,896 # 80017898 <bcache+0x8000>
    80002520:	2b87b703          	ld	a4,696(a5)
    80002524:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002526:	00015717          	auipc	a4,0x15
    8000252a:	5da70713          	addi	a4,a4,1498 # 80017b00 <bcache+0x8268>
    8000252e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002530:	2b87b703          	ld	a4,696(a5)
    80002534:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002536:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000253a:	0000d517          	auipc	a0,0xd
    8000253e:	35e50513          	addi	a0,a0,862 # 8000f898 <bcache>
    80002542:	00004097          	auipc	ra,0x4
    80002546:	d60080e7          	jalr	-672(ra) # 800062a2 <release>
}
    8000254a:	60e2                	ld	ra,24(sp)
    8000254c:	6442                	ld	s0,16(sp)
    8000254e:	64a2                	ld	s1,8(sp)
    80002550:	6902                	ld	s2,0(sp)
    80002552:	6105                	addi	sp,sp,32
    80002554:	8082                	ret
    panic("brelse");
    80002556:	00006517          	auipc	a0,0x6
    8000255a:	f7250513          	addi	a0,a0,-142 # 800084c8 <syscalls+0x100>
    8000255e:	00003097          	auipc	ra,0x3
    80002562:	6ea080e7          	jalr	1770(ra) # 80005c48 <panic>

0000000080002566 <bpin>:

void
bpin(struct buf *b) {
    80002566:	1101                	addi	sp,sp,-32
    80002568:	ec06                	sd	ra,24(sp)
    8000256a:	e822                	sd	s0,16(sp)
    8000256c:	e426                	sd	s1,8(sp)
    8000256e:	1000                	addi	s0,sp,32
    80002570:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002572:	0000d517          	auipc	a0,0xd
    80002576:	32650513          	addi	a0,a0,806 # 8000f898 <bcache>
    8000257a:	00004097          	auipc	ra,0x4
    8000257e:	c74080e7          	jalr	-908(ra) # 800061ee <acquire>
  b->refcnt++;
    80002582:	40bc                	lw	a5,64(s1)
    80002584:	2785                	addiw	a5,a5,1
    80002586:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002588:	0000d517          	auipc	a0,0xd
    8000258c:	31050513          	addi	a0,a0,784 # 8000f898 <bcache>
    80002590:	00004097          	auipc	ra,0x4
    80002594:	d12080e7          	jalr	-750(ra) # 800062a2 <release>
}
    80002598:	60e2                	ld	ra,24(sp)
    8000259a:	6442                	ld	s0,16(sp)
    8000259c:	64a2                	ld	s1,8(sp)
    8000259e:	6105                	addi	sp,sp,32
    800025a0:	8082                	ret

00000000800025a2 <bunpin>:

void
bunpin(struct buf *b) {
    800025a2:	1101                	addi	sp,sp,-32
    800025a4:	ec06                	sd	ra,24(sp)
    800025a6:	e822                	sd	s0,16(sp)
    800025a8:	e426                	sd	s1,8(sp)
    800025aa:	1000                	addi	s0,sp,32
    800025ac:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800025ae:	0000d517          	auipc	a0,0xd
    800025b2:	2ea50513          	addi	a0,a0,746 # 8000f898 <bcache>
    800025b6:	00004097          	auipc	ra,0x4
    800025ba:	c38080e7          	jalr	-968(ra) # 800061ee <acquire>
  b->refcnt--;
    800025be:	40bc                	lw	a5,64(s1)
    800025c0:	37fd                	addiw	a5,a5,-1
    800025c2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800025c4:	0000d517          	auipc	a0,0xd
    800025c8:	2d450513          	addi	a0,a0,724 # 8000f898 <bcache>
    800025cc:	00004097          	auipc	ra,0x4
    800025d0:	cd6080e7          	jalr	-810(ra) # 800062a2 <release>
}
    800025d4:	60e2                	ld	ra,24(sp)
    800025d6:	6442                	ld	s0,16(sp)
    800025d8:	64a2                	ld	s1,8(sp)
    800025da:	6105                	addi	sp,sp,32
    800025dc:	8082                	ret

00000000800025de <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800025de:	1101                	addi	sp,sp,-32
    800025e0:	ec06                	sd	ra,24(sp)
    800025e2:	e822                	sd	s0,16(sp)
    800025e4:	e426                	sd	s1,8(sp)
    800025e6:	e04a                	sd	s2,0(sp)
    800025e8:	1000                	addi	s0,sp,32
    800025ea:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800025ec:	00d5d59b          	srliw	a1,a1,0xd
    800025f0:	00016797          	auipc	a5,0x16
    800025f4:	9847a783          	lw	a5,-1660(a5) # 80017f74 <sb+0x1c>
    800025f8:	9dbd                	addw	a1,a1,a5
    800025fa:	00000097          	auipc	ra,0x0
    800025fe:	d9e080e7          	jalr	-610(ra) # 80002398 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002602:	0074f713          	andi	a4,s1,7
    80002606:	4785                	li	a5,1
    80002608:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000260c:	14ce                	slli	s1,s1,0x33
    8000260e:	90d9                	srli	s1,s1,0x36
    80002610:	00950733          	add	a4,a0,s1
    80002614:	05874703          	lbu	a4,88(a4)
    80002618:	00e7f6b3          	and	a3,a5,a4
    8000261c:	c69d                	beqz	a3,8000264a <bfree+0x6c>
    8000261e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002620:	94aa                	add	s1,s1,a0
    80002622:	fff7c793          	not	a5,a5
    80002626:	8ff9                	and	a5,a5,a4
    80002628:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000262c:	00001097          	auipc	ra,0x1
    80002630:	118080e7          	jalr	280(ra) # 80003744 <log_write>
  brelse(bp);
    80002634:	854a                	mv	a0,s2
    80002636:	00000097          	auipc	ra,0x0
    8000263a:	e92080e7          	jalr	-366(ra) # 800024c8 <brelse>
}
    8000263e:	60e2                	ld	ra,24(sp)
    80002640:	6442                	ld	s0,16(sp)
    80002642:	64a2                	ld	s1,8(sp)
    80002644:	6902                	ld	s2,0(sp)
    80002646:	6105                	addi	sp,sp,32
    80002648:	8082                	ret
    panic("freeing free block");
    8000264a:	00006517          	auipc	a0,0x6
    8000264e:	e8650513          	addi	a0,a0,-378 # 800084d0 <syscalls+0x108>
    80002652:	00003097          	auipc	ra,0x3
    80002656:	5f6080e7          	jalr	1526(ra) # 80005c48 <panic>

000000008000265a <balloc>:
{
    8000265a:	711d                	addi	sp,sp,-96
    8000265c:	ec86                	sd	ra,88(sp)
    8000265e:	e8a2                	sd	s0,80(sp)
    80002660:	e4a6                	sd	s1,72(sp)
    80002662:	e0ca                	sd	s2,64(sp)
    80002664:	fc4e                	sd	s3,56(sp)
    80002666:	f852                	sd	s4,48(sp)
    80002668:	f456                	sd	s5,40(sp)
    8000266a:	f05a                	sd	s6,32(sp)
    8000266c:	ec5e                	sd	s7,24(sp)
    8000266e:	e862                	sd	s8,16(sp)
    80002670:	e466                	sd	s9,8(sp)
    80002672:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002674:	00016797          	auipc	a5,0x16
    80002678:	8e87a783          	lw	a5,-1816(a5) # 80017f5c <sb+0x4>
    8000267c:	cbd1                	beqz	a5,80002710 <balloc+0xb6>
    8000267e:	8baa                	mv	s7,a0
    80002680:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002682:	00016b17          	auipc	s6,0x16
    80002686:	8d6b0b13          	addi	s6,s6,-1834 # 80017f58 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000268a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000268c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000268e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002690:	6c89                	lui	s9,0x2
    80002692:	a831                	j	800026ae <balloc+0x54>
    brelse(bp);
    80002694:	854a                	mv	a0,s2
    80002696:	00000097          	auipc	ra,0x0
    8000269a:	e32080e7          	jalr	-462(ra) # 800024c8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000269e:	015c87bb          	addw	a5,s9,s5
    800026a2:	00078a9b          	sext.w	s5,a5
    800026a6:	004b2703          	lw	a4,4(s6)
    800026aa:	06eaf363          	bgeu	s5,a4,80002710 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800026ae:	41fad79b          	sraiw	a5,s5,0x1f
    800026b2:	0137d79b          	srliw	a5,a5,0x13
    800026b6:	015787bb          	addw	a5,a5,s5
    800026ba:	40d7d79b          	sraiw	a5,a5,0xd
    800026be:	01cb2583          	lw	a1,28(s6)
    800026c2:	9dbd                	addw	a1,a1,a5
    800026c4:	855e                	mv	a0,s7
    800026c6:	00000097          	auipc	ra,0x0
    800026ca:	cd2080e7          	jalr	-814(ra) # 80002398 <bread>
    800026ce:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800026d0:	004b2503          	lw	a0,4(s6)
    800026d4:	000a849b          	sext.w	s1,s5
    800026d8:	8662                	mv	a2,s8
    800026da:	faa4fde3          	bgeu	s1,a0,80002694 <balloc+0x3a>
      m = 1 << (bi % 8);
    800026de:	41f6579b          	sraiw	a5,a2,0x1f
    800026e2:	01d7d69b          	srliw	a3,a5,0x1d
    800026e6:	00c6873b          	addw	a4,a3,a2
    800026ea:	00777793          	andi	a5,a4,7
    800026ee:	9f95                	subw	a5,a5,a3
    800026f0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800026f4:	4037571b          	sraiw	a4,a4,0x3
    800026f8:	00e906b3          	add	a3,s2,a4
    800026fc:	0586c683          	lbu	a3,88(a3)
    80002700:	00d7f5b3          	and	a1,a5,a3
    80002704:	cd91                	beqz	a1,80002720 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002706:	2605                	addiw	a2,a2,1
    80002708:	2485                	addiw	s1,s1,1
    8000270a:	fd4618e3          	bne	a2,s4,800026da <balloc+0x80>
    8000270e:	b759                	j	80002694 <balloc+0x3a>
  panic("balloc: out of blocks");
    80002710:	00006517          	auipc	a0,0x6
    80002714:	dd850513          	addi	a0,a0,-552 # 800084e8 <syscalls+0x120>
    80002718:	00003097          	auipc	ra,0x3
    8000271c:	530080e7          	jalr	1328(ra) # 80005c48 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002720:	974a                	add	a4,a4,s2
    80002722:	8fd5                	or	a5,a5,a3
    80002724:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002728:	854a                	mv	a0,s2
    8000272a:	00001097          	auipc	ra,0x1
    8000272e:	01a080e7          	jalr	26(ra) # 80003744 <log_write>
        brelse(bp);
    80002732:	854a                	mv	a0,s2
    80002734:	00000097          	auipc	ra,0x0
    80002738:	d94080e7          	jalr	-620(ra) # 800024c8 <brelse>
  bp = bread(dev, bno);
    8000273c:	85a6                	mv	a1,s1
    8000273e:	855e                	mv	a0,s7
    80002740:	00000097          	auipc	ra,0x0
    80002744:	c58080e7          	jalr	-936(ra) # 80002398 <bread>
    80002748:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000274a:	40000613          	li	a2,1024
    8000274e:	4581                	li	a1,0
    80002750:	05850513          	addi	a0,a0,88
    80002754:	ffffe097          	auipc	ra,0xffffe
    80002758:	a24080e7          	jalr	-1500(ra) # 80000178 <memset>
  log_write(bp);
    8000275c:	854a                	mv	a0,s2
    8000275e:	00001097          	auipc	ra,0x1
    80002762:	fe6080e7          	jalr	-26(ra) # 80003744 <log_write>
  brelse(bp);
    80002766:	854a                	mv	a0,s2
    80002768:	00000097          	auipc	ra,0x0
    8000276c:	d60080e7          	jalr	-672(ra) # 800024c8 <brelse>
}
    80002770:	8526                	mv	a0,s1
    80002772:	60e6                	ld	ra,88(sp)
    80002774:	6446                	ld	s0,80(sp)
    80002776:	64a6                	ld	s1,72(sp)
    80002778:	6906                	ld	s2,64(sp)
    8000277a:	79e2                	ld	s3,56(sp)
    8000277c:	7a42                	ld	s4,48(sp)
    8000277e:	7aa2                	ld	s5,40(sp)
    80002780:	7b02                	ld	s6,32(sp)
    80002782:	6be2                	ld	s7,24(sp)
    80002784:	6c42                	ld	s8,16(sp)
    80002786:	6ca2                	ld	s9,8(sp)
    80002788:	6125                	addi	sp,sp,96
    8000278a:	8082                	ret

000000008000278c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000278c:	7179                	addi	sp,sp,-48
    8000278e:	f406                	sd	ra,40(sp)
    80002790:	f022                	sd	s0,32(sp)
    80002792:	ec26                	sd	s1,24(sp)
    80002794:	e84a                	sd	s2,16(sp)
    80002796:	e44e                	sd	s3,8(sp)
    80002798:	e052                	sd	s4,0(sp)
    8000279a:	1800                	addi	s0,sp,48
    8000279c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000279e:	47ad                	li	a5,11
    800027a0:	04b7fe63          	bgeu	a5,a1,800027fc <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800027a4:	ff45849b          	addiw	s1,a1,-12
    800027a8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800027ac:	0ff00793          	li	a5,255
    800027b0:	0ae7e363          	bltu	a5,a4,80002856 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800027b4:	08052583          	lw	a1,128(a0)
    800027b8:	c5ad                	beqz	a1,80002822 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800027ba:	00092503          	lw	a0,0(s2)
    800027be:	00000097          	auipc	ra,0x0
    800027c2:	bda080e7          	jalr	-1062(ra) # 80002398 <bread>
    800027c6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800027c8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800027cc:	02049593          	slli	a1,s1,0x20
    800027d0:	9181                	srli	a1,a1,0x20
    800027d2:	058a                	slli	a1,a1,0x2
    800027d4:	00b784b3          	add	s1,a5,a1
    800027d8:	0004a983          	lw	s3,0(s1)
    800027dc:	04098d63          	beqz	s3,80002836 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800027e0:	8552                	mv	a0,s4
    800027e2:	00000097          	auipc	ra,0x0
    800027e6:	ce6080e7          	jalr	-794(ra) # 800024c8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800027ea:	854e                	mv	a0,s3
    800027ec:	70a2                	ld	ra,40(sp)
    800027ee:	7402                	ld	s0,32(sp)
    800027f0:	64e2                	ld	s1,24(sp)
    800027f2:	6942                	ld	s2,16(sp)
    800027f4:	69a2                	ld	s3,8(sp)
    800027f6:	6a02                	ld	s4,0(sp)
    800027f8:	6145                	addi	sp,sp,48
    800027fa:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800027fc:	02059493          	slli	s1,a1,0x20
    80002800:	9081                	srli	s1,s1,0x20
    80002802:	048a                	slli	s1,s1,0x2
    80002804:	94aa                	add	s1,s1,a0
    80002806:	0504a983          	lw	s3,80(s1)
    8000280a:	fe0990e3          	bnez	s3,800027ea <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000280e:	4108                	lw	a0,0(a0)
    80002810:	00000097          	auipc	ra,0x0
    80002814:	e4a080e7          	jalr	-438(ra) # 8000265a <balloc>
    80002818:	0005099b          	sext.w	s3,a0
    8000281c:	0534a823          	sw	s3,80(s1)
    80002820:	b7e9                	j	800027ea <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80002822:	4108                	lw	a0,0(a0)
    80002824:	00000097          	auipc	ra,0x0
    80002828:	e36080e7          	jalr	-458(ra) # 8000265a <balloc>
    8000282c:	0005059b          	sext.w	a1,a0
    80002830:	08b92023          	sw	a1,128(s2)
    80002834:	b759                	j	800027ba <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80002836:	00092503          	lw	a0,0(s2)
    8000283a:	00000097          	auipc	ra,0x0
    8000283e:	e20080e7          	jalr	-480(ra) # 8000265a <balloc>
    80002842:	0005099b          	sext.w	s3,a0
    80002846:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000284a:	8552                	mv	a0,s4
    8000284c:	00001097          	auipc	ra,0x1
    80002850:	ef8080e7          	jalr	-264(ra) # 80003744 <log_write>
    80002854:	b771                	j	800027e0 <bmap+0x54>
  panic("bmap: out of range");
    80002856:	00006517          	auipc	a0,0x6
    8000285a:	caa50513          	addi	a0,a0,-854 # 80008500 <syscalls+0x138>
    8000285e:	00003097          	auipc	ra,0x3
    80002862:	3ea080e7          	jalr	1002(ra) # 80005c48 <panic>

0000000080002866 <iget>:
{
    80002866:	7179                	addi	sp,sp,-48
    80002868:	f406                	sd	ra,40(sp)
    8000286a:	f022                	sd	s0,32(sp)
    8000286c:	ec26                	sd	s1,24(sp)
    8000286e:	e84a                	sd	s2,16(sp)
    80002870:	e44e                	sd	s3,8(sp)
    80002872:	e052                	sd	s4,0(sp)
    80002874:	1800                	addi	s0,sp,48
    80002876:	89aa                	mv	s3,a0
    80002878:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000287a:	00015517          	auipc	a0,0x15
    8000287e:	6fe50513          	addi	a0,a0,1790 # 80017f78 <itable>
    80002882:	00004097          	auipc	ra,0x4
    80002886:	96c080e7          	jalr	-1684(ra) # 800061ee <acquire>
  empty = 0;
    8000288a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000288c:	00015497          	auipc	s1,0x15
    80002890:	70448493          	addi	s1,s1,1796 # 80017f90 <itable+0x18>
    80002894:	00017697          	auipc	a3,0x17
    80002898:	18c68693          	addi	a3,a3,396 # 80019a20 <log>
    8000289c:	a039                	j	800028aa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000289e:	02090b63          	beqz	s2,800028d4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800028a2:	08848493          	addi	s1,s1,136
    800028a6:	02d48a63          	beq	s1,a3,800028da <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800028aa:	449c                	lw	a5,8(s1)
    800028ac:	fef059e3          	blez	a5,8000289e <iget+0x38>
    800028b0:	4098                	lw	a4,0(s1)
    800028b2:	ff3716e3          	bne	a4,s3,8000289e <iget+0x38>
    800028b6:	40d8                	lw	a4,4(s1)
    800028b8:	ff4713e3          	bne	a4,s4,8000289e <iget+0x38>
      ip->ref++;
    800028bc:	2785                	addiw	a5,a5,1
    800028be:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800028c0:	00015517          	auipc	a0,0x15
    800028c4:	6b850513          	addi	a0,a0,1720 # 80017f78 <itable>
    800028c8:	00004097          	auipc	ra,0x4
    800028cc:	9da080e7          	jalr	-1574(ra) # 800062a2 <release>
      return ip;
    800028d0:	8926                	mv	s2,s1
    800028d2:	a03d                	j	80002900 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800028d4:	f7f9                	bnez	a5,800028a2 <iget+0x3c>
    800028d6:	8926                	mv	s2,s1
    800028d8:	b7e9                	j	800028a2 <iget+0x3c>
  if(empty == 0)
    800028da:	02090c63          	beqz	s2,80002912 <iget+0xac>
  ip->dev = dev;
    800028de:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800028e2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800028e6:	4785                	li	a5,1
    800028e8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800028ec:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800028f0:	00015517          	auipc	a0,0x15
    800028f4:	68850513          	addi	a0,a0,1672 # 80017f78 <itable>
    800028f8:	00004097          	auipc	ra,0x4
    800028fc:	9aa080e7          	jalr	-1622(ra) # 800062a2 <release>
}
    80002900:	854a                	mv	a0,s2
    80002902:	70a2                	ld	ra,40(sp)
    80002904:	7402                	ld	s0,32(sp)
    80002906:	64e2                	ld	s1,24(sp)
    80002908:	6942                	ld	s2,16(sp)
    8000290a:	69a2                	ld	s3,8(sp)
    8000290c:	6a02                	ld	s4,0(sp)
    8000290e:	6145                	addi	sp,sp,48
    80002910:	8082                	ret
    panic("iget: no inodes");
    80002912:	00006517          	auipc	a0,0x6
    80002916:	c0650513          	addi	a0,a0,-1018 # 80008518 <syscalls+0x150>
    8000291a:	00003097          	auipc	ra,0x3
    8000291e:	32e080e7          	jalr	814(ra) # 80005c48 <panic>

0000000080002922 <fsinit>:
fsinit(int dev) {
    80002922:	7179                	addi	sp,sp,-48
    80002924:	f406                	sd	ra,40(sp)
    80002926:	f022                	sd	s0,32(sp)
    80002928:	ec26                	sd	s1,24(sp)
    8000292a:	e84a                	sd	s2,16(sp)
    8000292c:	e44e                	sd	s3,8(sp)
    8000292e:	1800                	addi	s0,sp,48
    80002930:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002932:	4585                	li	a1,1
    80002934:	00000097          	auipc	ra,0x0
    80002938:	a64080e7          	jalr	-1436(ra) # 80002398 <bread>
    8000293c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000293e:	00015997          	auipc	s3,0x15
    80002942:	61a98993          	addi	s3,s3,1562 # 80017f58 <sb>
    80002946:	02000613          	li	a2,32
    8000294a:	05850593          	addi	a1,a0,88
    8000294e:	854e                	mv	a0,s3
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	888080e7          	jalr	-1912(ra) # 800001d8 <memmove>
  brelse(bp);
    80002958:	8526                	mv	a0,s1
    8000295a:	00000097          	auipc	ra,0x0
    8000295e:	b6e080e7          	jalr	-1170(ra) # 800024c8 <brelse>
  if(sb.magic != FSMAGIC)
    80002962:	0009a703          	lw	a4,0(s3)
    80002966:	102037b7          	lui	a5,0x10203
    8000296a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000296e:	02f71263          	bne	a4,a5,80002992 <fsinit+0x70>
  initlog(dev, &sb);
    80002972:	00015597          	auipc	a1,0x15
    80002976:	5e658593          	addi	a1,a1,1510 # 80017f58 <sb>
    8000297a:	854a                	mv	a0,s2
    8000297c:	00001097          	auipc	ra,0x1
    80002980:	b4c080e7          	jalr	-1204(ra) # 800034c8 <initlog>
}
    80002984:	70a2                	ld	ra,40(sp)
    80002986:	7402                	ld	s0,32(sp)
    80002988:	64e2                	ld	s1,24(sp)
    8000298a:	6942                	ld	s2,16(sp)
    8000298c:	69a2                	ld	s3,8(sp)
    8000298e:	6145                	addi	sp,sp,48
    80002990:	8082                	ret
    panic("invalid file system");
    80002992:	00006517          	auipc	a0,0x6
    80002996:	b9650513          	addi	a0,a0,-1130 # 80008528 <syscalls+0x160>
    8000299a:	00003097          	auipc	ra,0x3
    8000299e:	2ae080e7          	jalr	686(ra) # 80005c48 <panic>

00000000800029a2 <iinit>:
{
    800029a2:	7179                	addi	sp,sp,-48
    800029a4:	f406                	sd	ra,40(sp)
    800029a6:	f022                	sd	s0,32(sp)
    800029a8:	ec26                	sd	s1,24(sp)
    800029aa:	e84a                	sd	s2,16(sp)
    800029ac:	e44e                	sd	s3,8(sp)
    800029ae:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800029b0:	00006597          	auipc	a1,0x6
    800029b4:	b9058593          	addi	a1,a1,-1136 # 80008540 <syscalls+0x178>
    800029b8:	00015517          	auipc	a0,0x15
    800029bc:	5c050513          	addi	a0,a0,1472 # 80017f78 <itable>
    800029c0:	00003097          	auipc	ra,0x3
    800029c4:	79e080e7          	jalr	1950(ra) # 8000615e <initlock>
  for(i = 0; i < NINODE; i++) {
    800029c8:	00015497          	auipc	s1,0x15
    800029cc:	5d848493          	addi	s1,s1,1496 # 80017fa0 <itable+0x28>
    800029d0:	00017997          	auipc	s3,0x17
    800029d4:	06098993          	addi	s3,s3,96 # 80019a30 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800029d8:	00006917          	auipc	s2,0x6
    800029dc:	b7090913          	addi	s2,s2,-1168 # 80008548 <syscalls+0x180>
    800029e0:	85ca                	mv	a1,s2
    800029e2:	8526                	mv	a0,s1
    800029e4:	00001097          	auipc	ra,0x1
    800029e8:	e46080e7          	jalr	-442(ra) # 8000382a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800029ec:	08848493          	addi	s1,s1,136
    800029f0:	ff3498e3          	bne	s1,s3,800029e0 <iinit+0x3e>
}
    800029f4:	70a2                	ld	ra,40(sp)
    800029f6:	7402                	ld	s0,32(sp)
    800029f8:	64e2                	ld	s1,24(sp)
    800029fa:	6942                	ld	s2,16(sp)
    800029fc:	69a2                	ld	s3,8(sp)
    800029fe:	6145                	addi	sp,sp,48
    80002a00:	8082                	ret

0000000080002a02 <ialloc>:
{
    80002a02:	715d                	addi	sp,sp,-80
    80002a04:	e486                	sd	ra,72(sp)
    80002a06:	e0a2                	sd	s0,64(sp)
    80002a08:	fc26                	sd	s1,56(sp)
    80002a0a:	f84a                	sd	s2,48(sp)
    80002a0c:	f44e                	sd	s3,40(sp)
    80002a0e:	f052                	sd	s4,32(sp)
    80002a10:	ec56                	sd	s5,24(sp)
    80002a12:	e85a                	sd	s6,16(sp)
    80002a14:	e45e                	sd	s7,8(sp)
    80002a16:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a18:	00015717          	auipc	a4,0x15
    80002a1c:	54c72703          	lw	a4,1356(a4) # 80017f64 <sb+0xc>
    80002a20:	4785                	li	a5,1
    80002a22:	04e7fa63          	bgeu	a5,a4,80002a76 <ialloc+0x74>
    80002a26:	8aaa                	mv	s5,a0
    80002a28:	8bae                	mv	s7,a1
    80002a2a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002a2c:	00015a17          	auipc	s4,0x15
    80002a30:	52ca0a13          	addi	s4,s4,1324 # 80017f58 <sb>
    80002a34:	00048b1b          	sext.w	s6,s1
    80002a38:	0044d593          	srli	a1,s1,0x4
    80002a3c:	018a2783          	lw	a5,24(s4)
    80002a40:	9dbd                	addw	a1,a1,a5
    80002a42:	8556                	mv	a0,s5
    80002a44:	00000097          	auipc	ra,0x0
    80002a48:	954080e7          	jalr	-1708(ra) # 80002398 <bread>
    80002a4c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002a4e:	05850993          	addi	s3,a0,88
    80002a52:	00f4f793          	andi	a5,s1,15
    80002a56:	079a                	slli	a5,a5,0x6
    80002a58:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002a5a:	00099783          	lh	a5,0(s3)
    80002a5e:	c785                	beqz	a5,80002a86 <ialloc+0x84>
    brelse(bp);
    80002a60:	00000097          	auipc	ra,0x0
    80002a64:	a68080e7          	jalr	-1432(ra) # 800024c8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a68:	0485                	addi	s1,s1,1
    80002a6a:	00ca2703          	lw	a4,12(s4)
    80002a6e:	0004879b          	sext.w	a5,s1
    80002a72:	fce7e1e3          	bltu	a5,a4,80002a34 <ialloc+0x32>
  panic("ialloc: no inodes");
    80002a76:	00006517          	auipc	a0,0x6
    80002a7a:	ada50513          	addi	a0,a0,-1318 # 80008550 <syscalls+0x188>
    80002a7e:	00003097          	auipc	ra,0x3
    80002a82:	1ca080e7          	jalr	458(ra) # 80005c48 <panic>
      memset(dip, 0, sizeof(*dip));
    80002a86:	04000613          	li	a2,64
    80002a8a:	4581                	li	a1,0
    80002a8c:	854e                	mv	a0,s3
    80002a8e:	ffffd097          	auipc	ra,0xffffd
    80002a92:	6ea080e7          	jalr	1770(ra) # 80000178 <memset>
      dip->type = type;
    80002a96:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002a9a:	854a                	mv	a0,s2
    80002a9c:	00001097          	auipc	ra,0x1
    80002aa0:	ca8080e7          	jalr	-856(ra) # 80003744 <log_write>
      brelse(bp);
    80002aa4:	854a                	mv	a0,s2
    80002aa6:	00000097          	auipc	ra,0x0
    80002aaa:	a22080e7          	jalr	-1502(ra) # 800024c8 <brelse>
      return iget(dev, inum);
    80002aae:	85da                	mv	a1,s6
    80002ab0:	8556                	mv	a0,s5
    80002ab2:	00000097          	auipc	ra,0x0
    80002ab6:	db4080e7          	jalr	-588(ra) # 80002866 <iget>
}
    80002aba:	60a6                	ld	ra,72(sp)
    80002abc:	6406                	ld	s0,64(sp)
    80002abe:	74e2                	ld	s1,56(sp)
    80002ac0:	7942                	ld	s2,48(sp)
    80002ac2:	79a2                	ld	s3,40(sp)
    80002ac4:	7a02                	ld	s4,32(sp)
    80002ac6:	6ae2                	ld	s5,24(sp)
    80002ac8:	6b42                	ld	s6,16(sp)
    80002aca:	6ba2                	ld	s7,8(sp)
    80002acc:	6161                	addi	sp,sp,80
    80002ace:	8082                	ret

0000000080002ad0 <iupdate>:
{
    80002ad0:	1101                	addi	sp,sp,-32
    80002ad2:	ec06                	sd	ra,24(sp)
    80002ad4:	e822                	sd	s0,16(sp)
    80002ad6:	e426                	sd	s1,8(sp)
    80002ad8:	e04a                	sd	s2,0(sp)
    80002ada:	1000                	addi	s0,sp,32
    80002adc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002ade:	415c                	lw	a5,4(a0)
    80002ae0:	0047d79b          	srliw	a5,a5,0x4
    80002ae4:	00015597          	auipc	a1,0x15
    80002ae8:	48c5a583          	lw	a1,1164(a1) # 80017f70 <sb+0x18>
    80002aec:	9dbd                	addw	a1,a1,a5
    80002aee:	4108                	lw	a0,0(a0)
    80002af0:	00000097          	auipc	ra,0x0
    80002af4:	8a8080e7          	jalr	-1880(ra) # 80002398 <bread>
    80002af8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002afa:	05850793          	addi	a5,a0,88
    80002afe:	40c8                	lw	a0,4(s1)
    80002b00:	893d                	andi	a0,a0,15
    80002b02:	051a                	slli	a0,a0,0x6
    80002b04:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002b06:	04449703          	lh	a4,68(s1)
    80002b0a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002b0e:	04649703          	lh	a4,70(s1)
    80002b12:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80002b16:	04849703          	lh	a4,72(s1)
    80002b1a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002b1e:	04a49703          	lh	a4,74(s1)
    80002b22:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80002b26:	44f8                	lw	a4,76(s1)
    80002b28:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002b2a:	03400613          	li	a2,52
    80002b2e:	05048593          	addi	a1,s1,80
    80002b32:	0531                	addi	a0,a0,12
    80002b34:	ffffd097          	auipc	ra,0xffffd
    80002b38:	6a4080e7          	jalr	1700(ra) # 800001d8 <memmove>
  log_write(bp);
    80002b3c:	854a                	mv	a0,s2
    80002b3e:	00001097          	auipc	ra,0x1
    80002b42:	c06080e7          	jalr	-1018(ra) # 80003744 <log_write>
  brelse(bp);
    80002b46:	854a                	mv	a0,s2
    80002b48:	00000097          	auipc	ra,0x0
    80002b4c:	980080e7          	jalr	-1664(ra) # 800024c8 <brelse>
}
    80002b50:	60e2                	ld	ra,24(sp)
    80002b52:	6442                	ld	s0,16(sp)
    80002b54:	64a2                	ld	s1,8(sp)
    80002b56:	6902                	ld	s2,0(sp)
    80002b58:	6105                	addi	sp,sp,32
    80002b5a:	8082                	ret

0000000080002b5c <idup>:
{
    80002b5c:	1101                	addi	sp,sp,-32
    80002b5e:	ec06                	sd	ra,24(sp)
    80002b60:	e822                	sd	s0,16(sp)
    80002b62:	e426                	sd	s1,8(sp)
    80002b64:	1000                	addi	s0,sp,32
    80002b66:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002b68:	00015517          	auipc	a0,0x15
    80002b6c:	41050513          	addi	a0,a0,1040 # 80017f78 <itable>
    80002b70:	00003097          	auipc	ra,0x3
    80002b74:	67e080e7          	jalr	1662(ra) # 800061ee <acquire>
  ip->ref++;
    80002b78:	449c                	lw	a5,8(s1)
    80002b7a:	2785                	addiw	a5,a5,1
    80002b7c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002b7e:	00015517          	auipc	a0,0x15
    80002b82:	3fa50513          	addi	a0,a0,1018 # 80017f78 <itable>
    80002b86:	00003097          	auipc	ra,0x3
    80002b8a:	71c080e7          	jalr	1820(ra) # 800062a2 <release>
}
    80002b8e:	8526                	mv	a0,s1
    80002b90:	60e2                	ld	ra,24(sp)
    80002b92:	6442                	ld	s0,16(sp)
    80002b94:	64a2                	ld	s1,8(sp)
    80002b96:	6105                	addi	sp,sp,32
    80002b98:	8082                	ret

0000000080002b9a <ilock>:
{
    80002b9a:	1101                	addi	sp,sp,-32
    80002b9c:	ec06                	sd	ra,24(sp)
    80002b9e:	e822                	sd	s0,16(sp)
    80002ba0:	e426                	sd	s1,8(sp)
    80002ba2:	e04a                	sd	s2,0(sp)
    80002ba4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002ba6:	c115                	beqz	a0,80002bca <ilock+0x30>
    80002ba8:	84aa                	mv	s1,a0
    80002baa:	451c                	lw	a5,8(a0)
    80002bac:	00f05f63          	blez	a5,80002bca <ilock+0x30>
  acquiresleep(&ip->lock);
    80002bb0:	0541                	addi	a0,a0,16
    80002bb2:	00001097          	auipc	ra,0x1
    80002bb6:	cb2080e7          	jalr	-846(ra) # 80003864 <acquiresleep>
  if(ip->valid == 0){
    80002bba:	40bc                	lw	a5,64(s1)
    80002bbc:	cf99                	beqz	a5,80002bda <ilock+0x40>
}
    80002bbe:	60e2                	ld	ra,24(sp)
    80002bc0:	6442                	ld	s0,16(sp)
    80002bc2:	64a2                	ld	s1,8(sp)
    80002bc4:	6902                	ld	s2,0(sp)
    80002bc6:	6105                	addi	sp,sp,32
    80002bc8:	8082                	ret
    panic("ilock");
    80002bca:	00006517          	auipc	a0,0x6
    80002bce:	99e50513          	addi	a0,a0,-1634 # 80008568 <syscalls+0x1a0>
    80002bd2:	00003097          	auipc	ra,0x3
    80002bd6:	076080e7          	jalr	118(ra) # 80005c48 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002bda:	40dc                	lw	a5,4(s1)
    80002bdc:	0047d79b          	srliw	a5,a5,0x4
    80002be0:	00015597          	auipc	a1,0x15
    80002be4:	3905a583          	lw	a1,912(a1) # 80017f70 <sb+0x18>
    80002be8:	9dbd                	addw	a1,a1,a5
    80002bea:	4088                	lw	a0,0(s1)
    80002bec:	fffff097          	auipc	ra,0xfffff
    80002bf0:	7ac080e7          	jalr	1964(ra) # 80002398 <bread>
    80002bf4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002bf6:	05850593          	addi	a1,a0,88
    80002bfa:	40dc                	lw	a5,4(s1)
    80002bfc:	8bbd                	andi	a5,a5,15
    80002bfe:	079a                	slli	a5,a5,0x6
    80002c00:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002c02:	00059783          	lh	a5,0(a1)
    80002c06:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002c0a:	00259783          	lh	a5,2(a1)
    80002c0e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002c12:	00459783          	lh	a5,4(a1)
    80002c16:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002c1a:	00659783          	lh	a5,6(a1)
    80002c1e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002c22:	459c                	lw	a5,8(a1)
    80002c24:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002c26:	03400613          	li	a2,52
    80002c2a:	05b1                	addi	a1,a1,12
    80002c2c:	05048513          	addi	a0,s1,80
    80002c30:	ffffd097          	auipc	ra,0xffffd
    80002c34:	5a8080e7          	jalr	1448(ra) # 800001d8 <memmove>
    brelse(bp);
    80002c38:	854a                	mv	a0,s2
    80002c3a:	00000097          	auipc	ra,0x0
    80002c3e:	88e080e7          	jalr	-1906(ra) # 800024c8 <brelse>
    ip->valid = 1;
    80002c42:	4785                	li	a5,1
    80002c44:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002c46:	04449783          	lh	a5,68(s1)
    80002c4a:	fbb5                	bnez	a5,80002bbe <ilock+0x24>
      panic("ilock: no type");
    80002c4c:	00006517          	auipc	a0,0x6
    80002c50:	92450513          	addi	a0,a0,-1756 # 80008570 <syscalls+0x1a8>
    80002c54:	00003097          	auipc	ra,0x3
    80002c58:	ff4080e7          	jalr	-12(ra) # 80005c48 <panic>

0000000080002c5c <iunlock>:
{
    80002c5c:	1101                	addi	sp,sp,-32
    80002c5e:	ec06                	sd	ra,24(sp)
    80002c60:	e822                	sd	s0,16(sp)
    80002c62:	e426                	sd	s1,8(sp)
    80002c64:	e04a                	sd	s2,0(sp)
    80002c66:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002c68:	c905                	beqz	a0,80002c98 <iunlock+0x3c>
    80002c6a:	84aa                	mv	s1,a0
    80002c6c:	01050913          	addi	s2,a0,16
    80002c70:	854a                	mv	a0,s2
    80002c72:	00001097          	auipc	ra,0x1
    80002c76:	c8c080e7          	jalr	-884(ra) # 800038fe <holdingsleep>
    80002c7a:	cd19                	beqz	a0,80002c98 <iunlock+0x3c>
    80002c7c:	449c                	lw	a5,8(s1)
    80002c7e:	00f05d63          	blez	a5,80002c98 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002c82:	854a                	mv	a0,s2
    80002c84:	00001097          	auipc	ra,0x1
    80002c88:	c36080e7          	jalr	-970(ra) # 800038ba <releasesleep>
}
    80002c8c:	60e2                	ld	ra,24(sp)
    80002c8e:	6442                	ld	s0,16(sp)
    80002c90:	64a2                	ld	s1,8(sp)
    80002c92:	6902                	ld	s2,0(sp)
    80002c94:	6105                	addi	sp,sp,32
    80002c96:	8082                	ret
    panic("iunlock");
    80002c98:	00006517          	auipc	a0,0x6
    80002c9c:	8e850513          	addi	a0,a0,-1816 # 80008580 <syscalls+0x1b8>
    80002ca0:	00003097          	auipc	ra,0x3
    80002ca4:	fa8080e7          	jalr	-88(ra) # 80005c48 <panic>

0000000080002ca8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002ca8:	7179                	addi	sp,sp,-48
    80002caa:	f406                	sd	ra,40(sp)
    80002cac:	f022                	sd	s0,32(sp)
    80002cae:	ec26                	sd	s1,24(sp)
    80002cb0:	e84a                	sd	s2,16(sp)
    80002cb2:	e44e                	sd	s3,8(sp)
    80002cb4:	e052                	sd	s4,0(sp)
    80002cb6:	1800                	addi	s0,sp,48
    80002cb8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002cba:	05050493          	addi	s1,a0,80
    80002cbe:	08050913          	addi	s2,a0,128
    80002cc2:	a021                	j	80002cca <itrunc+0x22>
    80002cc4:	0491                	addi	s1,s1,4
    80002cc6:	01248d63          	beq	s1,s2,80002ce0 <itrunc+0x38>
    if(ip->addrs[i]){
    80002cca:	408c                	lw	a1,0(s1)
    80002ccc:	dde5                	beqz	a1,80002cc4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002cce:	0009a503          	lw	a0,0(s3)
    80002cd2:	00000097          	auipc	ra,0x0
    80002cd6:	90c080e7          	jalr	-1780(ra) # 800025de <bfree>
      ip->addrs[i] = 0;
    80002cda:	0004a023          	sw	zero,0(s1)
    80002cde:	b7dd                	j	80002cc4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002ce0:	0809a583          	lw	a1,128(s3)
    80002ce4:	e185                	bnez	a1,80002d04 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002ce6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002cea:	854e                	mv	a0,s3
    80002cec:	00000097          	auipc	ra,0x0
    80002cf0:	de4080e7          	jalr	-540(ra) # 80002ad0 <iupdate>
}
    80002cf4:	70a2                	ld	ra,40(sp)
    80002cf6:	7402                	ld	s0,32(sp)
    80002cf8:	64e2                	ld	s1,24(sp)
    80002cfa:	6942                	ld	s2,16(sp)
    80002cfc:	69a2                	ld	s3,8(sp)
    80002cfe:	6a02                	ld	s4,0(sp)
    80002d00:	6145                	addi	sp,sp,48
    80002d02:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002d04:	0009a503          	lw	a0,0(s3)
    80002d08:	fffff097          	auipc	ra,0xfffff
    80002d0c:	690080e7          	jalr	1680(ra) # 80002398 <bread>
    80002d10:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002d12:	05850493          	addi	s1,a0,88
    80002d16:	45850913          	addi	s2,a0,1112
    80002d1a:	a811                	j	80002d2e <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80002d1c:	0009a503          	lw	a0,0(s3)
    80002d20:	00000097          	auipc	ra,0x0
    80002d24:	8be080e7          	jalr	-1858(ra) # 800025de <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80002d28:	0491                	addi	s1,s1,4
    80002d2a:	01248563          	beq	s1,s2,80002d34 <itrunc+0x8c>
      if(a[j])
    80002d2e:	408c                	lw	a1,0(s1)
    80002d30:	dde5                	beqz	a1,80002d28 <itrunc+0x80>
    80002d32:	b7ed                	j	80002d1c <itrunc+0x74>
    brelse(bp);
    80002d34:	8552                	mv	a0,s4
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	792080e7          	jalr	1938(ra) # 800024c8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002d3e:	0809a583          	lw	a1,128(s3)
    80002d42:	0009a503          	lw	a0,0(s3)
    80002d46:	00000097          	auipc	ra,0x0
    80002d4a:	898080e7          	jalr	-1896(ra) # 800025de <bfree>
    ip->addrs[NDIRECT] = 0;
    80002d4e:	0809a023          	sw	zero,128(s3)
    80002d52:	bf51                	j	80002ce6 <itrunc+0x3e>

0000000080002d54 <iput>:
{
    80002d54:	1101                	addi	sp,sp,-32
    80002d56:	ec06                	sd	ra,24(sp)
    80002d58:	e822                	sd	s0,16(sp)
    80002d5a:	e426                	sd	s1,8(sp)
    80002d5c:	e04a                	sd	s2,0(sp)
    80002d5e:	1000                	addi	s0,sp,32
    80002d60:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002d62:	00015517          	auipc	a0,0x15
    80002d66:	21650513          	addi	a0,a0,534 # 80017f78 <itable>
    80002d6a:	00003097          	auipc	ra,0x3
    80002d6e:	484080e7          	jalr	1156(ra) # 800061ee <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002d72:	4498                	lw	a4,8(s1)
    80002d74:	4785                	li	a5,1
    80002d76:	02f70363          	beq	a4,a5,80002d9c <iput+0x48>
  ip->ref--;
    80002d7a:	449c                	lw	a5,8(s1)
    80002d7c:	37fd                	addiw	a5,a5,-1
    80002d7e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002d80:	00015517          	auipc	a0,0x15
    80002d84:	1f850513          	addi	a0,a0,504 # 80017f78 <itable>
    80002d88:	00003097          	auipc	ra,0x3
    80002d8c:	51a080e7          	jalr	1306(ra) # 800062a2 <release>
}
    80002d90:	60e2                	ld	ra,24(sp)
    80002d92:	6442                	ld	s0,16(sp)
    80002d94:	64a2                	ld	s1,8(sp)
    80002d96:	6902                	ld	s2,0(sp)
    80002d98:	6105                	addi	sp,sp,32
    80002d9a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002d9c:	40bc                	lw	a5,64(s1)
    80002d9e:	dff1                	beqz	a5,80002d7a <iput+0x26>
    80002da0:	04a49783          	lh	a5,74(s1)
    80002da4:	fbf9                	bnez	a5,80002d7a <iput+0x26>
    acquiresleep(&ip->lock);
    80002da6:	01048913          	addi	s2,s1,16
    80002daa:	854a                	mv	a0,s2
    80002dac:	00001097          	auipc	ra,0x1
    80002db0:	ab8080e7          	jalr	-1352(ra) # 80003864 <acquiresleep>
    release(&itable.lock);
    80002db4:	00015517          	auipc	a0,0x15
    80002db8:	1c450513          	addi	a0,a0,452 # 80017f78 <itable>
    80002dbc:	00003097          	auipc	ra,0x3
    80002dc0:	4e6080e7          	jalr	1254(ra) # 800062a2 <release>
    itrunc(ip);
    80002dc4:	8526                	mv	a0,s1
    80002dc6:	00000097          	auipc	ra,0x0
    80002dca:	ee2080e7          	jalr	-286(ra) # 80002ca8 <itrunc>
    ip->type = 0;
    80002dce:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002dd2:	8526                	mv	a0,s1
    80002dd4:	00000097          	auipc	ra,0x0
    80002dd8:	cfc080e7          	jalr	-772(ra) # 80002ad0 <iupdate>
    ip->valid = 0;
    80002ddc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002de0:	854a                	mv	a0,s2
    80002de2:	00001097          	auipc	ra,0x1
    80002de6:	ad8080e7          	jalr	-1320(ra) # 800038ba <releasesleep>
    acquire(&itable.lock);
    80002dea:	00015517          	auipc	a0,0x15
    80002dee:	18e50513          	addi	a0,a0,398 # 80017f78 <itable>
    80002df2:	00003097          	auipc	ra,0x3
    80002df6:	3fc080e7          	jalr	1020(ra) # 800061ee <acquire>
    80002dfa:	b741                	j	80002d7a <iput+0x26>

0000000080002dfc <iunlockput>:
{
    80002dfc:	1101                	addi	sp,sp,-32
    80002dfe:	ec06                	sd	ra,24(sp)
    80002e00:	e822                	sd	s0,16(sp)
    80002e02:	e426                	sd	s1,8(sp)
    80002e04:	1000                	addi	s0,sp,32
    80002e06:	84aa                	mv	s1,a0
  iunlock(ip);
    80002e08:	00000097          	auipc	ra,0x0
    80002e0c:	e54080e7          	jalr	-428(ra) # 80002c5c <iunlock>
  iput(ip);
    80002e10:	8526                	mv	a0,s1
    80002e12:	00000097          	auipc	ra,0x0
    80002e16:	f42080e7          	jalr	-190(ra) # 80002d54 <iput>
}
    80002e1a:	60e2                	ld	ra,24(sp)
    80002e1c:	6442                	ld	s0,16(sp)
    80002e1e:	64a2                	ld	s1,8(sp)
    80002e20:	6105                	addi	sp,sp,32
    80002e22:	8082                	ret

0000000080002e24 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002e24:	1141                	addi	sp,sp,-16
    80002e26:	e422                	sd	s0,8(sp)
    80002e28:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002e2a:	411c                	lw	a5,0(a0)
    80002e2c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002e2e:	415c                	lw	a5,4(a0)
    80002e30:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002e32:	04451783          	lh	a5,68(a0)
    80002e36:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002e3a:	04a51783          	lh	a5,74(a0)
    80002e3e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002e42:	04c56783          	lwu	a5,76(a0)
    80002e46:	e99c                	sd	a5,16(a1)
}
    80002e48:	6422                	ld	s0,8(sp)
    80002e4a:	0141                	addi	sp,sp,16
    80002e4c:	8082                	ret

0000000080002e4e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002e4e:	457c                	lw	a5,76(a0)
    80002e50:	0ed7e963          	bltu	a5,a3,80002f42 <readi+0xf4>
{
    80002e54:	7159                	addi	sp,sp,-112
    80002e56:	f486                	sd	ra,104(sp)
    80002e58:	f0a2                	sd	s0,96(sp)
    80002e5a:	eca6                	sd	s1,88(sp)
    80002e5c:	e8ca                	sd	s2,80(sp)
    80002e5e:	e4ce                	sd	s3,72(sp)
    80002e60:	e0d2                	sd	s4,64(sp)
    80002e62:	fc56                	sd	s5,56(sp)
    80002e64:	f85a                	sd	s6,48(sp)
    80002e66:	f45e                	sd	s7,40(sp)
    80002e68:	f062                	sd	s8,32(sp)
    80002e6a:	ec66                	sd	s9,24(sp)
    80002e6c:	e86a                	sd	s10,16(sp)
    80002e6e:	e46e                	sd	s11,8(sp)
    80002e70:	1880                	addi	s0,sp,112
    80002e72:	8baa                	mv	s7,a0
    80002e74:	8c2e                	mv	s8,a1
    80002e76:	8ab2                	mv	s5,a2
    80002e78:	84b6                	mv	s1,a3
    80002e7a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002e7c:	9f35                	addw	a4,a4,a3
    return 0;
    80002e7e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002e80:	0ad76063          	bltu	a4,a3,80002f20 <readi+0xd2>
  if(off + n > ip->size)
    80002e84:	00e7f463          	bgeu	a5,a4,80002e8c <readi+0x3e>
    n = ip->size - off;
    80002e88:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002e8c:	0a0b0963          	beqz	s6,80002f3e <readi+0xf0>
    80002e90:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80002e92:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002e96:	5cfd                	li	s9,-1
    80002e98:	a82d                	j	80002ed2 <readi+0x84>
    80002e9a:	020a1d93          	slli	s11,s4,0x20
    80002e9e:	020ddd93          	srli	s11,s11,0x20
    80002ea2:	05890613          	addi	a2,s2,88
    80002ea6:	86ee                	mv	a3,s11
    80002ea8:	963a                	add	a2,a2,a4
    80002eaa:	85d6                	mv	a1,s5
    80002eac:	8562                	mv	a0,s8
    80002eae:	fffff097          	auipc	ra,0xfffff
    80002eb2:	a50080e7          	jalr	-1456(ra) # 800018fe <either_copyout>
    80002eb6:	05950d63          	beq	a0,s9,80002f10 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002eba:	854a                	mv	a0,s2
    80002ebc:	fffff097          	auipc	ra,0xfffff
    80002ec0:	60c080e7          	jalr	1548(ra) # 800024c8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002ec4:	013a09bb          	addw	s3,s4,s3
    80002ec8:	009a04bb          	addw	s1,s4,s1
    80002ecc:	9aee                	add	s5,s5,s11
    80002ece:	0569f763          	bgeu	s3,s6,80002f1c <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80002ed2:	000ba903          	lw	s2,0(s7)
    80002ed6:	00a4d59b          	srliw	a1,s1,0xa
    80002eda:	855e                	mv	a0,s7
    80002edc:	00000097          	auipc	ra,0x0
    80002ee0:	8b0080e7          	jalr	-1872(ra) # 8000278c <bmap>
    80002ee4:	0005059b          	sext.w	a1,a0
    80002ee8:	854a                	mv	a0,s2
    80002eea:	fffff097          	auipc	ra,0xfffff
    80002eee:	4ae080e7          	jalr	1198(ra) # 80002398 <bread>
    80002ef2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ef4:	3ff4f713          	andi	a4,s1,1023
    80002ef8:	40ed07bb          	subw	a5,s10,a4
    80002efc:	413b06bb          	subw	a3,s6,s3
    80002f00:	8a3e                	mv	s4,a5
    80002f02:	2781                	sext.w	a5,a5
    80002f04:	0006861b          	sext.w	a2,a3
    80002f08:	f8f679e3          	bgeu	a2,a5,80002e9a <readi+0x4c>
    80002f0c:	8a36                	mv	s4,a3
    80002f0e:	b771                	j	80002e9a <readi+0x4c>
      brelse(bp);
    80002f10:	854a                	mv	a0,s2
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	5b6080e7          	jalr	1462(ra) # 800024c8 <brelse>
      tot = -1;
    80002f1a:	59fd                	li	s3,-1
  }
  return tot;
    80002f1c:	0009851b          	sext.w	a0,s3
}
    80002f20:	70a6                	ld	ra,104(sp)
    80002f22:	7406                	ld	s0,96(sp)
    80002f24:	64e6                	ld	s1,88(sp)
    80002f26:	6946                	ld	s2,80(sp)
    80002f28:	69a6                	ld	s3,72(sp)
    80002f2a:	6a06                	ld	s4,64(sp)
    80002f2c:	7ae2                	ld	s5,56(sp)
    80002f2e:	7b42                	ld	s6,48(sp)
    80002f30:	7ba2                	ld	s7,40(sp)
    80002f32:	7c02                	ld	s8,32(sp)
    80002f34:	6ce2                	ld	s9,24(sp)
    80002f36:	6d42                	ld	s10,16(sp)
    80002f38:	6da2                	ld	s11,8(sp)
    80002f3a:	6165                	addi	sp,sp,112
    80002f3c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002f3e:	89da                	mv	s3,s6
    80002f40:	bff1                	j	80002f1c <readi+0xce>
    return 0;
    80002f42:	4501                	li	a0,0
}
    80002f44:	8082                	ret

0000000080002f46 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002f46:	457c                	lw	a5,76(a0)
    80002f48:	10d7e863          	bltu	a5,a3,80003058 <writei+0x112>
{
    80002f4c:	7159                	addi	sp,sp,-112
    80002f4e:	f486                	sd	ra,104(sp)
    80002f50:	f0a2                	sd	s0,96(sp)
    80002f52:	eca6                	sd	s1,88(sp)
    80002f54:	e8ca                	sd	s2,80(sp)
    80002f56:	e4ce                	sd	s3,72(sp)
    80002f58:	e0d2                	sd	s4,64(sp)
    80002f5a:	fc56                	sd	s5,56(sp)
    80002f5c:	f85a                	sd	s6,48(sp)
    80002f5e:	f45e                	sd	s7,40(sp)
    80002f60:	f062                	sd	s8,32(sp)
    80002f62:	ec66                	sd	s9,24(sp)
    80002f64:	e86a                	sd	s10,16(sp)
    80002f66:	e46e                	sd	s11,8(sp)
    80002f68:	1880                	addi	s0,sp,112
    80002f6a:	8b2a                	mv	s6,a0
    80002f6c:	8c2e                	mv	s8,a1
    80002f6e:	8ab2                	mv	s5,a2
    80002f70:	8936                	mv	s2,a3
    80002f72:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80002f74:	00e687bb          	addw	a5,a3,a4
    80002f78:	0ed7e263          	bltu	a5,a3,8000305c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002f7c:	00043737          	lui	a4,0x43
    80002f80:	0ef76063          	bltu	a4,a5,80003060 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002f84:	0c0b8863          	beqz	s7,80003054 <writei+0x10e>
    80002f88:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f8a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002f8e:	5cfd                	li	s9,-1
    80002f90:	a091                	j	80002fd4 <writei+0x8e>
    80002f92:	02099d93          	slli	s11,s3,0x20
    80002f96:	020ddd93          	srli	s11,s11,0x20
    80002f9a:	05848513          	addi	a0,s1,88
    80002f9e:	86ee                	mv	a3,s11
    80002fa0:	8656                	mv	a2,s5
    80002fa2:	85e2                	mv	a1,s8
    80002fa4:	953a                	add	a0,a0,a4
    80002fa6:	fffff097          	auipc	ra,0xfffff
    80002faa:	9ae080e7          	jalr	-1618(ra) # 80001954 <either_copyin>
    80002fae:	07950263          	beq	a0,s9,80003012 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002fb2:	8526                	mv	a0,s1
    80002fb4:	00000097          	auipc	ra,0x0
    80002fb8:	790080e7          	jalr	1936(ra) # 80003744 <log_write>
    brelse(bp);
    80002fbc:	8526                	mv	a0,s1
    80002fbe:	fffff097          	auipc	ra,0xfffff
    80002fc2:	50a080e7          	jalr	1290(ra) # 800024c8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002fc6:	01498a3b          	addw	s4,s3,s4
    80002fca:	0129893b          	addw	s2,s3,s2
    80002fce:	9aee                	add	s5,s5,s11
    80002fd0:	057a7663          	bgeu	s4,s7,8000301c <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80002fd4:	000b2483          	lw	s1,0(s6)
    80002fd8:	00a9559b          	srliw	a1,s2,0xa
    80002fdc:	855a                	mv	a0,s6
    80002fde:	fffff097          	auipc	ra,0xfffff
    80002fe2:	7ae080e7          	jalr	1966(ra) # 8000278c <bmap>
    80002fe6:	0005059b          	sext.w	a1,a0
    80002fea:	8526                	mv	a0,s1
    80002fec:	fffff097          	auipc	ra,0xfffff
    80002ff0:	3ac080e7          	jalr	940(ra) # 80002398 <bread>
    80002ff4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ff6:	3ff97713          	andi	a4,s2,1023
    80002ffa:	40ed07bb          	subw	a5,s10,a4
    80002ffe:	414b86bb          	subw	a3,s7,s4
    80003002:	89be                	mv	s3,a5
    80003004:	2781                	sext.w	a5,a5
    80003006:	0006861b          	sext.w	a2,a3
    8000300a:	f8f674e3          	bgeu	a2,a5,80002f92 <writei+0x4c>
    8000300e:	89b6                	mv	s3,a3
    80003010:	b749                	j	80002f92 <writei+0x4c>
      brelse(bp);
    80003012:	8526                	mv	a0,s1
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	4b4080e7          	jalr	1204(ra) # 800024c8 <brelse>
  }

  if(off > ip->size)
    8000301c:	04cb2783          	lw	a5,76(s6)
    80003020:	0127f463          	bgeu	a5,s2,80003028 <writei+0xe2>
    ip->size = off;
    80003024:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003028:	855a                	mv	a0,s6
    8000302a:	00000097          	auipc	ra,0x0
    8000302e:	aa6080e7          	jalr	-1370(ra) # 80002ad0 <iupdate>

  return tot;
    80003032:	000a051b          	sext.w	a0,s4
}
    80003036:	70a6                	ld	ra,104(sp)
    80003038:	7406                	ld	s0,96(sp)
    8000303a:	64e6                	ld	s1,88(sp)
    8000303c:	6946                	ld	s2,80(sp)
    8000303e:	69a6                	ld	s3,72(sp)
    80003040:	6a06                	ld	s4,64(sp)
    80003042:	7ae2                	ld	s5,56(sp)
    80003044:	7b42                	ld	s6,48(sp)
    80003046:	7ba2                	ld	s7,40(sp)
    80003048:	7c02                	ld	s8,32(sp)
    8000304a:	6ce2                	ld	s9,24(sp)
    8000304c:	6d42                	ld	s10,16(sp)
    8000304e:	6da2                	ld	s11,8(sp)
    80003050:	6165                	addi	sp,sp,112
    80003052:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003054:	8a5e                	mv	s4,s7
    80003056:	bfc9                	j	80003028 <writei+0xe2>
    return -1;
    80003058:	557d                	li	a0,-1
}
    8000305a:	8082                	ret
    return -1;
    8000305c:	557d                	li	a0,-1
    8000305e:	bfe1                	j	80003036 <writei+0xf0>
    return -1;
    80003060:	557d                	li	a0,-1
    80003062:	bfd1                	j	80003036 <writei+0xf0>

0000000080003064 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003064:	1141                	addi	sp,sp,-16
    80003066:	e406                	sd	ra,8(sp)
    80003068:	e022                	sd	s0,0(sp)
    8000306a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000306c:	4639                	li	a2,14
    8000306e:	ffffd097          	auipc	ra,0xffffd
    80003072:	1e2080e7          	jalr	482(ra) # 80000250 <strncmp>
}
    80003076:	60a2                	ld	ra,8(sp)
    80003078:	6402                	ld	s0,0(sp)
    8000307a:	0141                	addi	sp,sp,16
    8000307c:	8082                	ret

000000008000307e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000307e:	7139                	addi	sp,sp,-64
    80003080:	fc06                	sd	ra,56(sp)
    80003082:	f822                	sd	s0,48(sp)
    80003084:	f426                	sd	s1,40(sp)
    80003086:	f04a                	sd	s2,32(sp)
    80003088:	ec4e                	sd	s3,24(sp)
    8000308a:	e852                	sd	s4,16(sp)
    8000308c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000308e:	04451703          	lh	a4,68(a0)
    80003092:	4785                	li	a5,1
    80003094:	00f71a63          	bne	a4,a5,800030a8 <dirlookup+0x2a>
    80003098:	892a                	mv	s2,a0
    8000309a:	89ae                	mv	s3,a1
    8000309c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000309e:	457c                	lw	a5,76(a0)
    800030a0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800030a2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800030a4:	e79d                	bnez	a5,800030d2 <dirlookup+0x54>
    800030a6:	a8a5                	j	8000311e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800030a8:	00005517          	auipc	a0,0x5
    800030ac:	4e050513          	addi	a0,a0,1248 # 80008588 <syscalls+0x1c0>
    800030b0:	00003097          	auipc	ra,0x3
    800030b4:	b98080e7          	jalr	-1128(ra) # 80005c48 <panic>
      panic("dirlookup read");
    800030b8:	00005517          	auipc	a0,0x5
    800030bc:	4e850513          	addi	a0,a0,1256 # 800085a0 <syscalls+0x1d8>
    800030c0:	00003097          	auipc	ra,0x3
    800030c4:	b88080e7          	jalr	-1144(ra) # 80005c48 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800030c8:	24c1                	addiw	s1,s1,16
    800030ca:	04c92783          	lw	a5,76(s2)
    800030ce:	04f4f763          	bgeu	s1,a5,8000311c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800030d2:	4741                	li	a4,16
    800030d4:	86a6                	mv	a3,s1
    800030d6:	fc040613          	addi	a2,s0,-64
    800030da:	4581                	li	a1,0
    800030dc:	854a                	mv	a0,s2
    800030de:	00000097          	auipc	ra,0x0
    800030e2:	d70080e7          	jalr	-656(ra) # 80002e4e <readi>
    800030e6:	47c1                	li	a5,16
    800030e8:	fcf518e3          	bne	a0,a5,800030b8 <dirlookup+0x3a>
    if(de.inum == 0)
    800030ec:	fc045783          	lhu	a5,-64(s0)
    800030f0:	dfe1                	beqz	a5,800030c8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800030f2:	fc240593          	addi	a1,s0,-62
    800030f6:	854e                	mv	a0,s3
    800030f8:	00000097          	auipc	ra,0x0
    800030fc:	f6c080e7          	jalr	-148(ra) # 80003064 <namecmp>
    80003100:	f561                	bnez	a0,800030c8 <dirlookup+0x4a>
      if(poff)
    80003102:	000a0463          	beqz	s4,8000310a <dirlookup+0x8c>
        *poff = off;
    80003106:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000310a:	fc045583          	lhu	a1,-64(s0)
    8000310e:	00092503          	lw	a0,0(s2)
    80003112:	fffff097          	auipc	ra,0xfffff
    80003116:	754080e7          	jalr	1876(ra) # 80002866 <iget>
    8000311a:	a011                	j	8000311e <dirlookup+0xa0>
  return 0;
    8000311c:	4501                	li	a0,0
}
    8000311e:	70e2                	ld	ra,56(sp)
    80003120:	7442                	ld	s0,48(sp)
    80003122:	74a2                	ld	s1,40(sp)
    80003124:	7902                	ld	s2,32(sp)
    80003126:	69e2                	ld	s3,24(sp)
    80003128:	6a42                	ld	s4,16(sp)
    8000312a:	6121                	addi	sp,sp,64
    8000312c:	8082                	ret

000000008000312e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000312e:	711d                	addi	sp,sp,-96
    80003130:	ec86                	sd	ra,88(sp)
    80003132:	e8a2                	sd	s0,80(sp)
    80003134:	e4a6                	sd	s1,72(sp)
    80003136:	e0ca                	sd	s2,64(sp)
    80003138:	fc4e                	sd	s3,56(sp)
    8000313a:	f852                	sd	s4,48(sp)
    8000313c:	f456                	sd	s5,40(sp)
    8000313e:	f05a                	sd	s6,32(sp)
    80003140:	ec5e                	sd	s7,24(sp)
    80003142:	e862                	sd	s8,16(sp)
    80003144:	e466                	sd	s9,8(sp)
    80003146:	1080                	addi	s0,sp,96
    80003148:	84aa                	mv	s1,a0
    8000314a:	8b2e                	mv	s6,a1
    8000314c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000314e:	00054703          	lbu	a4,0(a0)
    80003152:	02f00793          	li	a5,47
    80003156:	02f70363          	beq	a4,a5,8000317c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000315a:	ffffe097          	auipc	ra,0xffffe
    8000315e:	cee080e7          	jalr	-786(ra) # 80000e48 <myproc>
    80003162:	15053503          	ld	a0,336(a0)
    80003166:	00000097          	auipc	ra,0x0
    8000316a:	9f6080e7          	jalr	-1546(ra) # 80002b5c <idup>
    8000316e:	89aa                	mv	s3,a0
  while(*path == '/')
    80003170:	02f00913          	li	s2,47
  len = path - s;
    80003174:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003176:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003178:	4c05                	li	s8,1
    8000317a:	a865                	j	80003232 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000317c:	4585                	li	a1,1
    8000317e:	4505                	li	a0,1
    80003180:	fffff097          	auipc	ra,0xfffff
    80003184:	6e6080e7          	jalr	1766(ra) # 80002866 <iget>
    80003188:	89aa                	mv	s3,a0
    8000318a:	b7dd                	j	80003170 <namex+0x42>
      iunlockput(ip);
    8000318c:	854e                	mv	a0,s3
    8000318e:	00000097          	auipc	ra,0x0
    80003192:	c6e080e7          	jalr	-914(ra) # 80002dfc <iunlockput>
      return 0;
    80003196:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003198:	854e                	mv	a0,s3
    8000319a:	60e6                	ld	ra,88(sp)
    8000319c:	6446                	ld	s0,80(sp)
    8000319e:	64a6                	ld	s1,72(sp)
    800031a0:	6906                	ld	s2,64(sp)
    800031a2:	79e2                	ld	s3,56(sp)
    800031a4:	7a42                	ld	s4,48(sp)
    800031a6:	7aa2                	ld	s5,40(sp)
    800031a8:	7b02                	ld	s6,32(sp)
    800031aa:	6be2                	ld	s7,24(sp)
    800031ac:	6c42                	ld	s8,16(sp)
    800031ae:	6ca2                	ld	s9,8(sp)
    800031b0:	6125                	addi	sp,sp,96
    800031b2:	8082                	ret
      iunlock(ip);
    800031b4:	854e                	mv	a0,s3
    800031b6:	00000097          	auipc	ra,0x0
    800031ba:	aa6080e7          	jalr	-1370(ra) # 80002c5c <iunlock>
      return ip;
    800031be:	bfe9                	j	80003198 <namex+0x6a>
      iunlockput(ip);
    800031c0:	854e                	mv	a0,s3
    800031c2:	00000097          	auipc	ra,0x0
    800031c6:	c3a080e7          	jalr	-966(ra) # 80002dfc <iunlockput>
      return 0;
    800031ca:	89d2                	mv	s3,s4
    800031cc:	b7f1                	j	80003198 <namex+0x6a>
  len = path - s;
    800031ce:	40b48633          	sub	a2,s1,a1
    800031d2:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800031d6:	094cd463          	bge	s9,s4,8000325e <namex+0x130>
    memmove(name, s, DIRSIZ);
    800031da:	4639                	li	a2,14
    800031dc:	8556                	mv	a0,s5
    800031de:	ffffd097          	auipc	ra,0xffffd
    800031e2:	ffa080e7          	jalr	-6(ra) # 800001d8 <memmove>
  while(*path == '/')
    800031e6:	0004c783          	lbu	a5,0(s1)
    800031ea:	01279763          	bne	a5,s2,800031f8 <namex+0xca>
    path++;
    800031ee:	0485                	addi	s1,s1,1
  while(*path == '/')
    800031f0:	0004c783          	lbu	a5,0(s1)
    800031f4:	ff278de3          	beq	a5,s2,800031ee <namex+0xc0>
    ilock(ip);
    800031f8:	854e                	mv	a0,s3
    800031fa:	00000097          	auipc	ra,0x0
    800031fe:	9a0080e7          	jalr	-1632(ra) # 80002b9a <ilock>
    if(ip->type != T_DIR){
    80003202:	04499783          	lh	a5,68(s3)
    80003206:	f98793e3          	bne	a5,s8,8000318c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000320a:	000b0563          	beqz	s6,80003214 <namex+0xe6>
    8000320e:	0004c783          	lbu	a5,0(s1)
    80003212:	d3cd                	beqz	a5,800031b4 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003214:	865e                	mv	a2,s7
    80003216:	85d6                	mv	a1,s5
    80003218:	854e                	mv	a0,s3
    8000321a:	00000097          	auipc	ra,0x0
    8000321e:	e64080e7          	jalr	-412(ra) # 8000307e <dirlookup>
    80003222:	8a2a                	mv	s4,a0
    80003224:	dd51                	beqz	a0,800031c0 <namex+0x92>
    iunlockput(ip);
    80003226:	854e                	mv	a0,s3
    80003228:	00000097          	auipc	ra,0x0
    8000322c:	bd4080e7          	jalr	-1068(ra) # 80002dfc <iunlockput>
    ip = next;
    80003230:	89d2                	mv	s3,s4
  while(*path == '/')
    80003232:	0004c783          	lbu	a5,0(s1)
    80003236:	05279763          	bne	a5,s2,80003284 <namex+0x156>
    path++;
    8000323a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000323c:	0004c783          	lbu	a5,0(s1)
    80003240:	ff278de3          	beq	a5,s2,8000323a <namex+0x10c>
  if(*path == 0)
    80003244:	c79d                	beqz	a5,80003272 <namex+0x144>
    path++;
    80003246:	85a6                	mv	a1,s1
  len = path - s;
    80003248:	8a5e                	mv	s4,s7
    8000324a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000324c:	01278963          	beq	a5,s2,8000325e <namex+0x130>
    80003250:	dfbd                	beqz	a5,800031ce <namex+0xa0>
    path++;
    80003252:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003254:	0004c783          	lbu	a5,0(s1)
    80003258:	ff279ce3          	bne	a5,s2,80003250 <namex+0x122>
    8000325c:	bf8d                	j	800031ce <namex+0xa0>
    memmove(name, s, len);
    8000325e:	2601                	sext.w	a2,a2
    80003260:	8556                	mv	a0,s5
    80003262:	ffffd097          	auipc	ra,0xffffd
    80003266:	f76080e7          	jalr	-138(ra) # 800001d8 <memmove>
    name[len] = 0;
    8000326a:	9a56                	add	s4,s4,s5
    8000326c:	000a0023          	sb	zero,0(s4)
    80003270:	bf9d                	j	800031e6 <namex+0xb8>
  if(nameiparent){
    80003272:	f20b03e3          	beqz	s6,80003198 <namex+0x6a>
    iput(ip);
    80003276:	854e                	mv	a0,s3
    80003278:	00000097          	auipc	ra,0x0
    8000327c:	adc080e7          	jalr	-1316(ra) # 80002d54 <iput>
    return 0;
    80003280:	4981                	li	s3,0
    80003282:	bf19                	j	80003198 <namex+0x6a>
  if(*path == 0)
    80003284:	d7fd                	beqz	a5,80003272 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003286:	0004c783          	lbu	a5,0(s1)
    8000328a:	85a6                	mv	a1,s1
    8000328c:	b7d1                	j	80003250 <namex+0x122>

000000008000328e <dirlink>:
{
    8000328e:	7139                	addi	sp,sp,-64
    80003290:	fc06                	sd	ra,56(sp)
    80003292:	f822                	sd	s0,48(sp)
    80003294:	f426                	sd	s1,40(sp)
    80003296:	f04a                	sd	s2,32(sp)
    80003298:	ec4e                	sd	s3,24(sp)
    8000329a:	e852                	sd	s4,16(sp)
    8000329c:	0080                	addi	s0,sp,64
    8000329e:	892a                	mv	s2,a0
    800032a0:	8a2e                	mv	s4,a1
    800032a2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800032a4:	4601                	li	a2,0
    800032a6:	00000097          	auipc	ra,0x0
    800032aa:	dd8080e7          	jalr	-552(ra) # 8000307e <dirlookup>
    800032ae:	e93d                	bnez	a0,80003324 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032b0:	04c92483          	lw	s1,76(s2)
    800032b4:	c49d                	beqz	s1,800032e2 <dirlink+0x54>
    800032b6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800032b8:	4741                	li	a4,16
    800032ba:	86a6                	mv	a3,s1
    800032bc:	fc040613          	addi	a2,s0,-64
    800032c0:	4581                	li	a1,0
    800032c2:	854a                	mv	a0,s2
    800032c4:	00000097          	auipc	ra,0x0
    800032c8:	b8a080e7          	jalr	-1142(ra) # 80002e4e <readi>
    800032cc:	47c1                	li	a5,16
    800032ce:	06f51163          	bne	a0,a5,80003330 <dirlink+0xa2>
    if(de.inum == 0)
    800032d2:	fc045783          	lhu	a5,-64(s0)
    800032d6:	c791                	beqz	a5,800032e2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032d8:	24c1                	addiw	s1,s1,16
    800032da:	04c92783          	lw	a5,76(s2)
    800032de:	fcf4ede3          	bltu	s1,a5,800032b8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800032e2:	4639                	li	a2,14
    800032e4:	85d2                	mv	a1,s4
    800032e6:	fc240513          	addi	a0,s0,-62
    800032ea:	ffffd097          	auipc	ra,0xffffd
    800032ee:	fa2080e7          	jalr	-94(ra) # 8000028c <strncpy>
  de.inum = inum;
    800032f2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800032f6:	4741                	li	a4,16
    800032f8:	86a6                	mv	a3,s1
    800032fa:	fc040613          	addi	a2,s0,-64
    800032fe:	4581                	li	a1,0
    80003300:	854a                	mv	a0,s2
    80003302:	00000097          	auipc	ra,0x0
    80003306:	c44080e7          	jalr	-956(ra) # 80002f46 <writei>
    8000330a:	872a                	mv	a4,a0
    8000330c:	47c1                	li	a5,16
  return 0;
    8000330e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003310:	02f71863          	bne	a4,a5,80003340 <dirlink+0xb2>
}
    80003314:	70e2                	ld	ra,56(sp)
    80003316:	7442                	ld	s0,48(sp)
    80003318:	74a2                	ld	s1,40(sp)
    8000331a:	7902                	ld	s2,32(sp)
    8000331c:	69e2                	ld	s3,24(sp)
    8000331e:	6a42                	ld	s4,16(sp)
    80003320:	6121                	addi	sp,sp,64
    80003322:	8082                	ret
    iput(ip);
    80003324:	00000097          	auipc	ra,0x0
    80003328:	a30080e7          	jalr	-1488(ra) # 80002d54 <iput>
    return -1;
    8000332c:	557d                	li	a0,-1
    8000332e:	b7dd                	j	80003314 <dirlink+0x86>
      panic("dirlink read");
    80003330:	00005517          	auipc	a0,0x5
    80003334:	28050513          	addi	a0,a0,640 # 800085b0 <syscalls+0x1e8>
    80003338:	00003097          	auipc	ra,0x3
    8000333c:	910080e7          	jalr	-1776(ra) # 80005c48 <panic>
    panic("dirlink");
    80003340:	00005517          	auipc	a0,0x5
    80003344:	38050513          	addi	a0,a0,896 # 800086c0 <syscalls+0x2f8>
    80003348:	00003097          	auipc	ra,0x3
    8000334c:	900080e7          	jalr	-1792(ra) # 80005c48 <panic>

0000000080003350 <namei>:

struct inode*
namei(char *path)
{
    80003350:	1101                	addi	sp,sp,-32
    80003352:	ec06                	sd	ra,24(sp)
    80003354:	e822                	sd	s0,16(sp)
    80003356:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003358:	fe040613          	addi	a2,s0,-32
    8000335c:	4581                	li	a1,0
    8000335e:	00000097          	auipc	ra,0x0
    80003362:	dd0080e7          	jalr	-560(ra) # 8000312e <namex>
}
    80003366:	60e2                	ld	ra,24(sp)
    80003368:	6442                	ld	s0,16(sp)
    8000336a:	6105                	addi	sp,sp,32
    8000336c:	8082                	ret

000000008000336e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000336e:	1141                	addi	sp,sp,-16
    80003370:	e406                	sd	ra,8(sp)
    80003372:	e022                	sd	s0,0(sp)
    80003374:	0800                	addi	s0,sp,16
    80003376:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003378:	4585                	li	a1,1
    8000337a:	00000097          	auipc	ra,0x0
    8000337e:	db4080e7          	jalr	-588(ra) # 8000312e <namex>
}
    80003382:	60a2                	ld	ra,8(sp)
    80003384:	6402                	ld	s0,0(sp)
    80003386:	0141                	addi	sp,sp,16
    80003388:	8082                	ret

000000008000338a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000338a:	1101                	addi	sp,sp,-32
    8000338c:	ec06                	sd	ra,24(sp)
    8000338e:	e822                	sd	s0,16(sp)
    80003390:	e426                	sd	s1,8(sp)
    80003392:	e04a                	sd	s2,0(sp)
    80003394:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003396:	00016917          	auipc	s2,0x16
    8000339a:	68a90913          	addi	s2,s2,1674 # 80019a20 <log>
    8000339e:	01892583          	lw	a1,24(s2)
    800033a2:	02892503          	lw	a0,40(s2)
    800033a6:	fffff097          	auipc	ra,0xfffff
    800033aa:	ff2080e7          	jalr	-14(ra) # 80002398 <bread>
    800033ae:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800033b0:	02c92683          	lw	a3,44(s2)
    800033b4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800033b6:	02d05763          	blez	a3,800033e4 <write_head+0x5a>
    800033ba:	00016797          	auipc	a5,0x16
    800033be:	69678793          	addi	a5,a5,1686 # 80019a50 <log+0x30>
    800033c2:	05c50713          	addi	a4,a0,92
    800033c6:	36fd                	addiw	a3,a3,-1
    800033c8:	1682                	slli	a3,a3,0x20
    800033ca:	9281                	srli	a3,a3,0x20
    800033cc:	068a                	slli	a3,a3,0x2
    800033ce:	00016617          	auipc	a2,0x16
    800033d2:	68660613          	addi	a2,a2,1670 # 80019a54 <log+0x34>
    800033d6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800033d8:	4390                	lw	a2,0(a5)
    800033da:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800033dc:	0791                	addi	a5,a5,4
    800033de:	0711                	addi	a4,a4,4
    800033e0:	fed79ce3          	bne	a5,a3,800033d8 <write_head+0x4e>
  }
  bwrite(buf);
    800033e4:	8526                	mv	a0,s1
    800033e6:	fffff097          	auipc	ra,0xfffff
    800033ea:	0a4080e7          	jalr	164(ra) # 8000248a <bwrite>
  brelse(buf);
    800033ee:	8526                	mv	a0,s1
    800033f0:	fffff097          	auipc	ra,0xfffff
    800033f4:	0d8080e7          	jalr	216(ra) # 800024c8 <brelse>
}
    800033f8:	60e2                	ld	ra,24(sp)
    800033fa:	6442                	ld	s0,16(sp)
    800033fc:	64a2                	ld	s1,8(sp)
    800033fe:	6902                	ld	s2,0(sp)
    80003400:	6105                	addi	sp,sp,32
    80003402:	8082                	ret

0000000080003404 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003404:	00016797          	auipc	a5,0x16
    80003408:	6487a783          	lw	a5,1608(a5) # 80019a4c <log+0x2c>
    8000340c:	0af05d63          	blez	a5,800034c6 <install_trans+0xc2>
{
    80003410:	7139                	addi	sp,sp,-64
    80003412:	fc06                	sd	ra,56(sp)
    80003414:	f822                	sd	s0,48(sp)
    80003416:	f426                	sd	s1,40(sp)
    80003418:	f04a                	sd	s2,32(sp)
    8000341a:	ec4e                	sd	s3,24(sp)
    8000341c:	e852                	sd	s4,16(sp)
    8000341e:	e456                	sd	s5,8(sp)
    80003420:	e05a                	sd	s6,0(sp)
    80003422:	0080                	addi	s0,sp,64
    80003424:	8b2a                	mv	s6,a0
    80003426:	00016a97          	auipc	s5,0x16
    8000342a:	62aa8a93          	addi	s5,s5,1578 # 80019a50 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000342e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003430:	00016997          	auipc	s3,0x16
    80003434:	5f098993          	addi	s3,s3,1520 # 80019a20 <log>
    80003438:	a035                	j	80003464 <install_trans+0x60>
      bunpin(dbuf);
    8000343a:	8526                	mv	a0,s1
    8000343c:	fffff097          	auipc	ra,0xfffff
    80003440:	166080e7          	jalr	358(ra) # 800025a2 <bunpin>
    brelse(lbuf);
    80003444:	854a                	mv	a0,s2
    80003446:	fffff097          	auipc	ra,0xfffff
    8000344a:	082080e7          	jalr	130(ra) # 800024c8 <brelse>
    brelse(dbuf);
    8000344e:	8526                	mv	a0,s1
    80003450:	fffff097          	auipc	ra,0xfffff
    80003454:	078080e7          	jalr	120(ra) # 800024c8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003458:	2a05                	addiw	s4,s4,1
    8000345a:	0a91                	addi	s5,s5,4
    8000345c:	02c9a783          	lw	a5,44(s3)
    80003460:	04fa5963          	bge	s4,a5,800034b2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003464:	0189a583          	lw	a1,24(s3)
    80003468:	014585bb          	addw	a1,a1,s4
    8000346c:	2585                	addiw	a1,a1,1
    8000346e:	0289a503          	lw	a0,40(s3)
    80003472:	fffff097          	auipc	ra,0xfffff
    80003476:	f26080e7          	jalr	-218(ra) # 80002398 <bread>
    8000347a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000347c:	000aa583          	lw	a1,0(s5)
    80003480:	0289a503          	lw	a0,40(s3)
    80003484:	fffff097          	auipc	ra,0xfffff
    80003488:	f14080e7          	jalr	-236(ra) # 80002398 <bread>
    8000348c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000348e:	40000613          	li	a2,1024
    80003492:	05890593          	addi	a1,s2,88
    80003496:	05850513          	addi	a0,a0,88
    8000349a:	ffffd097          	auipc	ra,0xffffd
    8000349e:	d3e080e7          	jalr	-706(ra) # 800001d8 <memmove>
    bwrite(dbuf);  // write dst to disk
    800034a2:	8526                	mv	a0,s1
    800034a4:	fffff097          	auipc	ra,0xfffff
    800034a8:	fe6080e7          	jalr	-26(ra) # 8000248a <bwrite>
    if(recovering == 0)
    800034ac:	f80b1ce3          	bnez	s6,80003444 <install_trans+0x40>
    800034b0:	b769                	j	8000343a <install_trans+0x36>
}
    800034b2:	70e2                	ld	ra,56(sp)
    800034b4:	7442                	ld	s0,48(sp)
    800034b6:	74a2                	ld	s1,40(sp)
    800034b8:	7902                	ld	s2,32(sp)
    800034ba:	69e2                	ld	s3,24(sp)
    800034bc:	6a42                	ld	s4,16(sp)
    800034be:	6aa2                	ld	s5,8(sp)
    800034c0:	6b02                	ld	s6,0(sp)
    800034c2:	6121                	addi	sp,sp,64
    800034c4:	8082                	ret
    800034c6:	8082                	ret

00000000800034c8 <initlog>:
{
    800034c8:	7179                	addi	sp,sp,-48
    800034ca:	f406                	sd	ra,40(sp)
    800034cc:	f022                	sd	s0,32(sp)
    800034ce:	ec26                	sd	s1,24(sp)
    800034d0:	e84a                	sd	s2,16(sp)
    800034d2:	e44e                	sd	s3,8(sp)
    800034d4:	1800                	addi	s0,sp,48
    800034d6:	892a                	mv	s2,a0
    800034d8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800034da:	00016497          	auipc	s1,0x16
    800034de:	54648493          	addi	s1,s1,1350 # 80019a20 <log>
    800034e2:	00005597          	auipc	a1,0x5
    800034e6:	0de58593          	addi	a1,a1,222 # 800085c0 <syscalls+0x1f8>
    800034ea:	8526                	mv	a0,s1
    800034ec:	00003097          	auipc	ra,0x3
    800034f0:	c72080e7          	jalr	-910(ra) # 8000615e <initlock>
  log.start = sb->logstart;
    800034f4:	0149a583          	lw	a1,20(s3)
    800034f8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800034fa:	0109a783          	lw	a5,16(s3)
    800034fe:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003500:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003504:	854a                	mv	a0,s2
    80003506:	fffff097          	auipc	ra,0xfffff
    8000350a:	e92080e7          	jalr	-366(ra) # 80002398 <bread>
  log.lh.n = lh->n;
    8000350e:	4d3c                	lw	a5,88(a0)
    80003510:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003512:	02f05563          	blez	a5,8000353c <initlog+0x74>
    80003516:	05c50713          	addi	a4,a0,92
    8000351a:	00016697          	auipc	a3,0x16
    8000351e:	53668693          	addi	a3,a3,1334 # 80019a50 <log+0x30>
    80003522:	37fd                	addiw	a5,a5,-1
    80003524:	1782                	slli	a5,a5,0x20
    80003526:	9381                	srli	a5,a5,0x20
    80003528:	078a                	slli	a5,a5,0x2
    8000352a:	06050613          	addi	a2,a0,96
    8000352e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003530:	4310                	lw	a2,0(a4)
    80003532:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003534:	0711                	addi	a4,a4,4
    80003536:	0691                	addi	a3,a3,4
    80003538:	fef71ce3          	bne	a4,a5,80003530 <initlog+0x68>
  brelse(buf);
    8000353c:	fffff097          	auipc	ra,0xfffff
    80003540:	f8c080e7          	jalr	-116(ra) # 800024c8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003544:	4505                	li	a0,1
    80003546:	00000097          	auipc	ra,0x0
    8000354a:	ebe080e7          	jalr	-322(ra) # 80003404 <install_trans>
  log.lh.n = 0;
    8000354e:	00016797          	auipc	a5,0x16
    80003552:	4e07af23          	sw	zero,1278(a5) # 80019a4c <log+0x2c>
  write_head(); // clear the log
    80003556:	00000097          	auipc	ra,0x0
    8000355a:	e34080e7          	jalr	-460(ra) # 8000338a <write_head>
}
    8000355e:	70a2                	ld	ra,40(sp)
    80003560:	7402                	ld	s0,32(sp)
    80003562:	64e2                	ld	s1,24(sp)
    80003564:	6942                	ld	s2,16(sp)
    80003566:	69a2                	ld	s3,8(sp)
    80003568:	6145                	addi	sp,sp,48
    8000356a:	8082                	ret

000000008000356c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000356c:	1101                	addi	sp,sp,-32
    8000356e:	ec06                	sd	ra,24(sp)
    80003570:	e822                	sd	s0,16(sp)
    80003572:	e426                	sd	s1,8(sp)
    80003574:	e04a                	sd	s2,0(sp)
    80003576:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003578:	00016517          	auipc	a0,0x16
    8000357c:	4a850513          	addi	a0,a0,1192 # 80019a20 <log>
    80003580:	00003097          	auipc	ra,0x3
    80003584:	c6e080e7          	jalr	-914(ra) # 800061ee <acquire>
  while(1){
    if(log.committing){
    80003588:	00016497          	auipc	s1,0x16
    8000358c:	49848493          	addi	s1,s1,1176 # 80019a20 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003590:	4979                	li	s2,30
    80003592:	a039                	j	800035a0 <begin_op+0x34>
      sleep(&log, &log.lock);
    80003594:	85a6                	mv	a1,s1
    80003596:	8526                	mv	a0,s1
    80003598:	ffffe097          	auipc	ra,0xffffe
    8000359c:	fc2080e7          	jalr	-62(ra) # 8000155a <sleep>
    if(log.committing){
    800035a0:	50dc                	lw	a5,36(s1)
    800035a2:	fbed                	bnez	a5,80003594 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800035a4:	509c                	lw	a5,32(s1)
    800035a6:	0017871b          	addiw	a4,a5,1
    800035aa:	0007069b          	sext.w	a3,a4
    800035ae:	0027179b          	slliw	a5,a4,0x2
    800035b2:	9fb9                	addw	a5,a5,a4
    800035b4:	0017979b          	slliw	a5,a5,0x1
    800035b8:	54d8                	lw	a4,44(s1)
    800035ba:	9fb9                	addw	a5,a5,a4
    800035bc:	00f95963          	bge	s2,a5,800035ce <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800035c0:	85a6                	mv	a1,s1
    800035c2:	8526                	mv	a0,s1
    800035c4:	ffffe097          	auipc	ra,0xffffe
    800035c8:	f96080e7          	jalr	-106(ra) # 8000155a <sleep>
    800035cc:	bfd1                	j	800035a0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800035ce:	00016517          	auipc	a0,0x16
    800035d2:	45250513          	addi	a0,a0,1106 # 80019a20 <log>
    800035d6:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800035d8:	00003097          	auipc	ra,0x3
    800035dc:	cca080e7          	jalr	-822(ra) # 800062a2 <release>
      break;
    }
  }
}
    800035e0:	60e2                	ld	ra,24(sp)
    800035e2:	6442                	ld	s0,16(sp)
    800035e4:	64a2                	ld	s1,8(sp)
    800035e6:	6902                	ld	s2,0(sp)
    800035e8:	6105                	addi	sp,sp,32
    800035ea:	8082                	ret

00000000800035ec <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800035ec:	7139                	addi	sp,sp,-64
    800035ee:	fc06                	sd	ra,56(sp)
    800035f0:	f822                	sd	s0,48(sp)
    800035f2:	f426                	sd	s1,40(sp)
    800035f4:	f04a                	sd	s2,32(sp)
    800035f6:	ec4e                	sd	s3,24(sp)
    800035f8:	e852                	sd	s4,16(sp)
    800035fa:	e456                	sd	s5,8(sp)
    800035fc:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800035fe:	00016497          	auipc	s1,0x16
    80003602:	42248493          	addi	s1,s1,1058 # 80019a20 <log>
    80003606:	8526                	mv	a0,s1
    80003608:	00003097          	auipc	ra,0x3
    8000360c:	be6080e7          	jalr	-1050(ra) # 800061ee <acquire>
  log.outstanding -= 1;
    80003610:	509c                	lw	a5,32(s1)
    80003612:	37fd                	addiw	a5,a5,-1
    80003614:	0007891b          	sext.w	s2,a5
    80003618:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000361a:	50dc                	lw	a5,36(s1)
    8000361c:	efb9                	bnez	a5,8000367a <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000361e:	06091663          	bnez	s2,8000368a <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80003622:	00016497          	auipc	s1,0x16
    80003626:	3fe48493          	addi	s1,s1,1022 # 80019a20 <log>
    8000362a:	4785                	li	a5,1
    8000362c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000362e:	8526                	mv	a0,s1
    80003630:	00003097          	auipc	ra,0x3
    80003634:	c72080e7          	jalr	-910(ra) # 800062a2 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003638:	54dc                	lw	a5,44(s1)
    8000363a:	06f04763          	bgtz	a5,800036a8 <end_op+0xbc>
    acquire(&log.lock);
    8000363e:	00016497          	auipc	s1,0x16
    80003642:	3e248493          	addi	s1,s1,994 # 80019a20 <log>
    80003646:	8526                	mv	a0,s1
    80003648:	00003097          	auipc	ra,0x3
    8000364c:	ba6080e7          	jalr	-1114(ra) # 800061ee <acquire>
    log.committing = 0;
    80003650:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003654:	8526                	mv	a0,s1
    80003656:	ffffe097          	auipc	ra,0xffffe
    8000365a:	090080e7          	jalr	144(ra) # 800016e6 <wakeup>
    release(&log.lock);
    8000365e:	8526                	mv	a0,s1
    80003660:	00003097          	auipc	ra,0x3
    80003664:	c42080e7          	jalr	-958(ra) # 800062a2 <release>
}
    80003668:	70e2                	ld	ra,56(sp)
    8000366a:	7442                	ld	s0,48(sp)
    8000366c:	74a2                	ld	s1,40(sp)
    8000366e:	7902                	ld	s2,32(sp)
    80003670:	69e2                	ld	s3,24(sp)
    80003672:	6a42                	ld	s4,16(sp)
    80003674:	6aa2                	ld	s5,8(sp)
    80003676:	6121                	addi	sp,sp,64
    80003678:	8082                	ret
    panic("log.committing");
    8000367a:	00005517          	auipc	a0,0x5
    8000367e:	f4e50513          	addi	a0,a0,-178 # 800085c8 <syscalls+0x200>
    80003682:	00002097          	auipc	ra,0x2
    80003686:	5c6080e7          	jalr	1478(ra) # 80005c48 <panic>
    wakeup(&log);
    8000368a:	00016497          	auipc	s1,0x16
    8000368e:	39648493          	addi	s1,s1,918 # 80019a20 <log>
    80003692:	8526                	mv	a0,s1
    80003694:	ffffe097          	auipc	ra,0xffffe
    80003698:	052080e7          	jalr	82(ra) # 800016e6 <wakeup>
  release(&log.lock);
    8000369c:	8526                	mv	a0,s1
    8000369e:	00003097          	auipc	ra,0x3
    800036a2:	c04080e7          	jalr	-1020(ra) # 800062a2 <release>
  if(do_commit){
    800036a6:	b7c9                	j	80003668 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800036a8:	00016a97          	auipc	s5,0x16
    800036ac:	3a8a8a93          	addi	s5,s5,936 # 80019a50 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800036b0:	00016a17          	auipc	s4,0x16
    800036b4:	370a0a13          	addi	s4,s4,880 # 80019a20 <log>
    800036b8:	018a2583          	lw	a1,24(s4)
    800036bc:	012585bb          	addw	a1,a1,s2
    800036c0:	2585                	addiw	a1,a1,1
    800036c2:	028a2503          	lw	a0,40(s4)
    800036c6:	fffff097          	auipc	ra,0xfffff
    800036ca:	cd2080e7          	jalr	-814(ra) # 80002398 <bread>
    800036ce:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800036d0:	000aa583          	lw	a1,0(s5)
    800036d4:	028a2503          	lw	a0,40(s4)
    800036d8:	fffff097          	auipc	ra,0xfffff
    800036dc:	cc0080e7          	jalr	-832(ra) # 80002398 <bread>
    800036e0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800036e2:	40000613          	li	a2,1024
    800036e6:	05850593          	addi	a1,a0,88
    800036ea:	05848513          	addi	a0,s1,88
    800036ee:	ffffd097          	auipc	ra,0xffffd
    800036f2:	aea080e7          	jalr	-1302(ra) # 800001d8 <memmove>
    bwrite(to);  // write the log
    800036f6:	8526                	mv	a0,s1
    800036f8:	fffff097          	auipc	ra,0xfffff
    800036fc:	d92080e7          	jalr	-622(ra) # 8000248a <bwrite>
    brelse(from);
    80003700:	854e                	mv	a0,s3
    80003702:	fffff097          	auipc	ra,0xfffff
    80003706:	dc6080e7          	jalr	-570(ra) # 800024c8 <brelse>
    brelse(to);
    8000370a:	8526                	mv	a0,s1
    8000370c:	fffff097          	auipc	ra,0xfffff
    80003710:	dbc080e7          	jalr	-580(ra) # 800024c8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003714:	2905                	addiw	s2,s2,1
    80003716:	0a91                	addi	s5,s5,4
    80003718:	02ca2783          	lw	a5,44(s4)
    8000371c:	f8f94ee3          	blt	s2,a5,800036b8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003720:	00000097          	auipc	ra,0x0
    80003724:	c6a080e7          	jalr	-918(ra) # 8000338a <write_head>
    install_trans(0); // Now install writes to home locations
    80003728:	4501                	li	a0,0
    8000372a:	00000097          	auipc	ra,0x0
    8000372e:	cda080e7          	jalr	-806(ra) # 80003404 <install_trans>
    log.lh.n = 0;
    80003732:	00016797          	auipc	a5,0x16
    80003736:	3007ad23          	sw	zero,794(a5) # 80019a4c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000373a:	00000097          	auipc	ra,0x0
    8000373e:	c50080e7          	jalr	-944(ra) # 8000338a <write_head>
    80003742:	bdf5                	j	8000363e <end_op+0x52>

0000000080003744 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003744:	1101                	addi	sp,sp,-32
    80003746:	ec06                	sd	ra,24(sp)
    80003748:	e822                	sd	s0,16(sp)
    8000374a:	e426                	sd	s1,8(sp)
    8000374c:	e04a                	sd	s2,0(sp)
    8000374e:	1000                	addi	s0,sp,32
    80003750:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003752:	00016917          	auipc	s2,0x16
    80003756:	2ce90913          	addi	s2,s2,718 # 80019a20 <log>
    8000375a:	854a                	mv	a0,s2
    8000375c:	00003097          	auipc	ra,0x3
    80003760:	a92080e7          	jalr	-1390(ra) # 800061ee <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003764:	02c92603          	lw	a2,44(s2)
    80003768:	47f5                	li	a5,29
    8000376a:	06c7c563          	blt	a5,a2,800037d4 <log_write+0x90>
    8000376e:	00016797          	auipc	a5,0x16
    80003772:	2ce7a783          	lw	a5,718(a5) # 80019a3c <log+0x1c>
    80003776:	37fd                	addiw	a5,a5,-1
    80003778:	04f65e63          	bge	a2,a5,800037d4 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000377c:	00016797          	auipc	a5,0x16
    80003780:	2c47a783          	lw	a5,708(a5) # 80019a40 <log+0x20>
    80003784:	06f05063          	blez	a5,800037e4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003788:	4781                	li	a5,0
    8000378a:	06c05563          	blez	a2,800037f4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000378e:	44cc                	lw	a1,12(s1)
    80003790:	00016717          	auipc	a4,0x16
    80003794:	2c070713          	addi	a4,a4,704 # 80019a50 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003798:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000379a:	4314                	lw	a3,0(a4)
    8000379c:	04b68c63          	beq	a3,a1,800037f4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800037a0:	2785                	addiw	a5,a5,1
    800037a2:	0711                	addi	a4,a4,4
    800037a4:	fef61be3          	bne	a2,a5,8000379a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800037a8:	0621                	addi	a2,a2,8
    800037aa:	060a                	slli	a2,a2,0x2
    800037ac:	00016797          	auipc	a5,0x16
    800037b0:	27478793          	addi	a5,a5,628 # 80019a20 <log>
    800037b4:	963e                	add	a2,a2,a5
    800037b6:	44dc                	lw	a5,12(s1)
    800037b8:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800037ba:	8526                	mv	a0,s1
    800037bc:	fffff097          	auipc	ra,0xfffff
    800037c0:	daa080e7          	jalr	-598(ra) # 80002566 <bpin>
    log.lh.n++;
    800037c4:	00016717          	auipc	a4,0x16
    800037c8:	25c70713          	addi	a4,a4,604 # 80019a20 <log>
    800037cc:	575c                	lw	a5,44(a4)
    800037ce:	2785                	addiw	a5,a5,1
    800037d0:	d75c                	sw	a5,44(a4)
    800037d2:	a835                	j	8000380e <log_write+0xca>
    panic("too big a transaction");
    800037d4:	00005517          	auipc	a0,0x5
    800037d8:	e0450513          	addi	a0,a0,-508 # 800085d8 <syscalls+0x210>
    800037dc:	00002097          	auipc	ra,0x2
    800037e0:	46c080e7          	jalr	1132(ra) # 80005c48 <panic>
    panic("log_write outside of trans");
    800037e4:	00005517          	auipc	a0,0x5
    800037e8:	e0c50513          	addi	a0,a0,-500 # 800085f0 <syscalls+0x228>
    800037ec:	00002097          	auipc	ra,0x2
    800037f0:	45c080e7          	jalr	1116(ra) # 80005c48 <panic>
  log.lh.block[i] = b->blockno;
    800037f4:	00878713          	addi	a4,a5,8
    800037f8:	00271693          	slli	a3,a4,0x2
    800037fc:	00016717          	auipc	a4,0x16
    80003800:	22470713          	addi	a4,a4,548 # 80019a20 <log>
    80003804:	9736                	add	a4,a4,a3
    80003806:	44d4                	lw	a3,12(s1)
    80003808:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000380a:	faf608e3          	beq	a2,a5,800037ba <log_write+0x76>
  }
  release(&log.lock);
    8000380e:	00016517          	auipc	a0,0x16
    80003812:	21250513          	addi	a0,a0,530 # 80019a20 <log>
    80003816:	00003097          	auipc	ra,0x3
    8000381a:	a8c080e7          	jalr	-1396(ra) # 800062a2 <release>
}
    8000381e:	60e2                	ld	ra,24(sp)
    80003820:	6442                	ld	s0,16(sp)
    80003822:	64a2                	ld	s1,8(sp)
    80003824:	6902                	ld	s2,0(sp)
    80003826:	6105                	addi	sp,sp,32
    80003828:	8082                	ret

000000008000382a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000382a:	1101                	addi	sp,sp,-32
    8000382c:	ec06                	sd	ra,24(sp)
    8000382e:	e822                	sd	s0,16(sp)
    80003830:	e426                	sd	s1,8(sp)
    80003832:	e04a                	sd	s2,0(sp)
    80003834:	1000                	addi	s0,sp,32
    80003836:	84aa                	mv	s1,a0
    80003838:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000383a:	00005597          	auipc	a1,0x5
    8000383e:	dd658593          	addi	a1,a1,-554 # 80008610 <syscalls+0x248>
    80003842:	0521                	addi	a0,a0,8
    80003844:	00003097          	auipc	ra,0x3
    80003848:	91a080e7          	jalr	-1766(ra) # 8000615e <initlock>
  lk->name = name;
    8000384c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003850:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003854:	0204a423          	sw	zero,40(s1)
}
    80003858:	60e2                	ld	ra,24(sp)
    8000385a:	6442                	ld	s0,16(sp)
    8000385c:	64a2                	ld	s1,8(sp)
    8000385e:	6902                	ld	s2,0(sp)
    80003860:	6105                	addi	sp,sp,32
    80003862:	8082                	ret

0000000080003864 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003864:	1101                	addi	sp,sp,-32
    80003866:	ec06                	sd	ra,24(sp)
    80003868:	e822                	sd	s0,16(sp)
    8000386a:	e426                	sd	s1,8(sp)
    8000386c:	e04a                	sd	s2,0(sp)
    8000386e:	1000                	addi	s0,sp,32
    80003870:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003872:	00850913          	addi	s2,a0,8
    80003876:	854a                	mv	a0,s2
    80003878:	00003097          	auipc	ra,0x3
    8000387c:	976080e7          	jalr	-1674(ra) # 800061ee <acquire>
  while (lk->locked) {
    80003880:	409c                	lw	a5,0(s1)
    80003882:	cb89                	beqz	a5,80003894 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80003884:	85ca                	mv	a1,s2
    80003886:	8526                	mv	a0,s1
    80003888:	ffffe097          	auipc	ra,0xffffe
    8000388c:	cd2080e7          	jalr	-814(ra) # 8000155a <sleep>
  while (lk->locked) {
    80003890:	409c                	lw	a5,0(s1)
    80003892:	fbed                	bnez	a5,80003884 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80003894:	4785                	li	a5,1
    80003896:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003898:	ffffd097          	auipc	ra,0xffffd
    8000389c:	5b0080e7          	jalr	1456(ra) # 80000e48 <myproc>
    800038a0:	591c                	lw	a5,48(a0)
    800038a2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800038a4:	854a                	mv	a0,s2
    800038a6:	00003097          	auipc	ra,0x3
    800038aa:	9fc080e7          	jalr	-1540(ra) # 800062a2 <release>
}
    800038ae:	60e2                	ld	ra,24(sp)
    800038b0:	6442                	ld	s0,16(sp)
    800038b2:	64a2                	ld	s1,8(sp)
    800038b4:	6902                	ld	s2,0(sp)
    800038b6:	6105                	addi	sp,sp,32
    800038b8:	8082                	ret

00000000800038ba <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800038ba:	1101                	addi	sp,sp,-32
    800038bc:	ec06                	sd	ra,24(sp)
    800038be:	e822                	sd	s0,16(sp)
    800038c0:	e426                	sd	s1,8(sp)
    800038c2:	e04a                	sd	s2,0(sp)
    800038c4:	1000                	addi	s0,sp,32
    800038c6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800038c8:	00850913          	addi	s2,a0,8
    800038cc:	854a                	mv	a0,s2
    800038ce:	00003097          	auipc	ra,0x3
    800038d2:	920080e7          	jalr	-1760(ra) # 800061ee <acquire>
  lk->locked = 0;
    800038d6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800038da:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800038de:	8526                	mv	a0,s1
    800038e0:	ffffe097          	auipc	ra,0xffffe
    800038e4:	e06080e7          	jalr	-506(ra) # 800016e6 <wakeup>
  release(&lk->lk);
    800038e8:	854a                	mv	a0,s2
    800038ea:	00003097          	auipc	ra,0x3
    800038ee:	9b8080e7          	jalr	-1608(ra) # 800062a2 <release>
}
    800038f2:	60e2                	ld	ra,24(sp)
    800038f4:	6442                	ld	s0,16(sp)
    800038f6:	64a2                	ld	s1,8(sp)
    800038f8:	6902                	ld	s2,0(sp)
    800038fa:	6105                	addi	sp,sp,32
    800038fc:	8082                	ret

00000000800038fe <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800038fe:	7179                	addi	sp,sp,-48
    80003900:	f406                	sd	ra,40(sp)
    80003902:	f022                	sd	s0,32(sp)
    80003904:	ec26                	sd	s1,24(sp)
    80003906:	e84a                	sd	s2,16(sp)
    80003908:	e44e                	sd	s3,8(sp)
    8000390a:	1800                	addi	s0,sp,48
    8000390c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000390e:	00850913          	addi	s2,a0,8
    80003912:	854a                	mv	a0,s2
    80003914:	00003097          	auipc	ra,0x3
    80003918:	8da080e7          	jalr	-1830(ra) # 800061ee <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000391c:	409c                	lw	a5,0(s1)
    8000391e:	ef99                	bnez	a5,8000393c <holdingsleep+0x3e>
    80003920:	4481                	li	s1,0
  release(&lk->lk);
    80003922:	854a                	mv	a0,s2
    80003924:	00003097          	auipc	ra,0x3
    80003928:	97e080e7          	jalr	-1666(ra) # 800062a2 <release>
  return r;
}
    8000392c:	8526                	mv	a0,s1
    8000392e:	70a2                	ld	ra,40(sp)
    80003930:	7402                	ld	s0,32(sp)
    80003932:	64e2                	ld	s1,24(sp)
    80003934:	6942                	ld	s2,16(sp)
    80003936:	69a2                	ld	s3,8(sp)
    80003938:	6145                	addi	sp,sp,48
    8000393a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000393c:	0284a983          	lw	s3,40(s1)
    80003940:	ffffd097          	auipc	ra,0xffffd
    80003944:	508080e7          	jalr	1288(ra) # 80000e48 <myproc>
    80003948:	5904                	lw	s1,48(a0)
    8000394a:	413484b3          	sub	s1,s1,s3
    8000394e:	0014b493          	seqz	s1,s1
    80003952:	bfc1                	j	80003922 <holdingsleep+0x24>

0000000080003954 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003954:	1141                	addi	sp,sp,-16
    80003956:	e406                	sd	ra,8(sp)
    80003958:	e022                	sd	s0,0(sp)
    8000395a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000395c:	00005597          	auipc	a1,0x5
    80003960:	cc458593          	addi	a1,a1,-828 # 80008620 <syscalls+0x258>
    80003964:	00016517          	auipc	a0,0x16
    80003968:	20450513          	addi	a0,a0,516 # 80019b68 <ftable>
    8000396c:	00002097          	auipc	ra,0x2
    80003970:	7f2080e7          	jalr	2034(ra) # 8000615e <initlock>
}
    80003974:	60a2                	ld	ra,8(sp)
    80003976:	6402                	ld	s0,0(sp)
    80003978:	0141                	addi	sp,sp,16
    8000397a:	8082                	ret

000000008000397c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000397c:	1101                	addi	sp,sp,-32
    8000397e:	ec06                	sd	ra,24(sp)
    80003980:	e822                	sd	s0,16(sp)
    80003982:	e426                	sd	s1,8(sp)
    80003984:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003986:	00016517          	auipc	a0,0x16
    8000398a:	1e250513          	addi	a0,a0,482 # 80019b68 <ftable>
    8000398e:	00003097          	auipc	ra,0x3
    80003992:	860080e7          	jalr	-1952(ra) # 800061ee <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003996:	00016497          	auipc	s1,0x16
    8000399a:	1ea48493          	addi	s1,s1,490 # 80019b80 <ftable+0x18>
    8000399e:	00017717          	auipc	a4,0x17
    800039a2:	18270713          	addi	a4,a4,386 # 8001ab20 <ftable+0xfb8>
    if(f->ref == 0){
    800039a6:	40dc                	lw	a5,4(s1)
    800039a8:	cf99                	beqz	a5,800039c6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800039aa:	02848493          	addi	s1,s1,40
    800039ae:	fee49ce3          	bne	s1,a4,800039a6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800039b2:	00016517          	auipc	a0,0x16
    800039b6:	1b650513          	addi	a0,a0,438 # 80019b68 <ftable>
    800039ba:	00003097          	auipc	ra,0x3
    800039be:	8e8080e7          	jalr	-1816(ra) # 800062a2 <release>
  return 0;
    800039c2:	4481                	li	s1,0
    800039c4:	a819                	j	800039da <filealloc+0x5e>
      f->ref = 1;
    800039c6:	4785                	li	a5,1
    800039c8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800039ca:	00016517          	auipc	a0,0x16
    800039ce:	19e50513          	addi	a0,a0,414 # 80019b68 <ftable>
    800039d2:	00003097          	auipc	ra,0x3
    800039d6:	8d0080e7          	jalr	-1840(ra) # 800062a2 <release>
}
    800039da:	8526                	mv	a0,s1
    800039dc:	60e2                	ld	ra,24(sp)
    800039de:	6442                	ld	s0,16(sp)
    800039e0:	64a2                	ld	s1,8(sp)
    800039e2:	6105                	addi	sp,sp,32
    800039e4:	8082                	ret

00000000800039e6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800039e6:	1101                	addi	sp,sp,-32
    800039e8:	ec06                	sd	ra,24(sp)
    800039ea:	e822                	sd	s0,16(sp)
    800039ec:	e426                	sd	s1,8(sp)
    800039ee:	1000                	addi	s0,sp,32
    800039f0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800039f2:	00016517          	auipc	a0,0x16
    800039f6:	17650513          	addi	a0,a0,374 # 80019b68 <ftable>
    800039fa:	00002097          	auipc	ra,0x2
    800039fe:	7f4080e7          	jalr	2036(ra) # 800061ee <acquire>
  if(f->ref < 1)
    80003a02:	40dc                	lw	a5,4(s1)
    80003a04:	02f05263          	blez	a5,80003a28 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003a08:	2785                	addiw	a5,a5,1
    80003a0a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003a0c:	00016517          	auipc	a0,0x16
    80003a10:	15c50513          	addi	a0,a0,348 # 80019b68 <ftable>
    80003a14:	00003097          	auipc	ra,0x3
    80003a18:	88e080e7          	jalr	-1906(ra) # 800062a2 <release>
  return f;
}
    80003a1c:	8526                	mv	a0,s1
    80003a1e:	60e2                	ld	ra,24(sp)
    80003a20:	6442                	ld	s0,16(sp)
    80003a22:	64a2                	ld	s1,8(sp)
    80003a24:	6105                	addi	sp,sp,32
    80003a26:	8082                	ret
    panic("filedup");
    80003a28:	00005517          	auipc	a0,0x5
    80003a2c:	c0050513          	addi	a0,a0,-1024 # 80008628 <syscalls+0x260>
    80003a30:	00002097          	auipc	ra,0x2
    80003a34:	218080e7          	jalr	536(ra) # 80005c48 <panic>

0000000080003a38 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003a38:	7139                	addi	sp,sp,-64
    80003a3a:	fc06                	sd	ra,56(sp)
    80003a3c:	f822                	sd	s0,48(sp)
    80003a3e:	f426                	sd	s1,40(sp)
    80003a40:	f04a                	sd	s2,32(sp)
    80003a42:	ec4e                	sd	s3,24(sp)
    80003a44:	e852                	sd	s4,16(sp)
    80003a46:	e456                	sd	s5,8(sp)
    80003a48:	0080                	addi	s0,sp,64
    80003a4a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003a4c:	00016517          	auipc	a0,0x16
    80003a50:	11c50513          	addi	a0,a0,284 # 80019b68 <ftable>
    80003a54:	00002097          	auipc	ra,0x2
    80003a58:	79a080e7          	jalr	1946(ra) # 800061ee <acquire>
  if(f->ref < 1)
    80003a5c:	40dc                	lw	a5,4(s1)
    80003a5e:	06f05163          	blez	a5,80003ac0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003a62:	37fd                	addiw	a5,a5,-1
    80003a64:	0007871b          	sext.w	a4,a5
    80003a68:	c0dc                	sw	a5,4(s1)
    80003a6a:	06e04363          	bgtz	a4,80003ad0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003a6e:	0004a903          	lw	s2,0(s1)
    80003a72:	0094ca83          	lbu	s5,9(s1)
    80003a76:	0104ba03          	ld	s4,16(s1)
    80003a7a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003a7e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003a82:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003a86:	00016517          	auipc	a0,0x16
    80003a8a:	0e250513          	addi	a0,a0,226 # 80019b68 <ftable>
    80003a8e:	00003097          	auipc	ra,0x3
    80003a92:	814080e7          	jalr	-2028(ra) # 800062a2 <release>

  if(ff.type == FD_PIPE){
    80003a96:	4785                	li	a5,1
    80003a98:	04f90d63          	beq	s2,a5,80003af2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003a9c:	3979                	addiw	s2,s2,-2
    80003a9e:	4785                	li	a5,1
    80003aa0:	0527e063          	bltu	a5,s2,80003ae0 <fileclose+0xa8>
    begin_op();
    80003aa4:	00000097          	auipc	ra,0x0
    80003aa8:	ac8080e7          	jalr	-1336(ra) # 8000356c <begin_op>
    iput(ff.ip);
    80003aac:	854e                	mv	a0,s3
    80003aae:	fffff097          	auipc	ra,0xfffff
    80003ab2:	2a6080e7          	jalr	678(ra) # 80002d54 <iput>
    end_op();
    80003ab6:	00000097          	auipc	ra,0x0
    80003aba:	b36080e7          	jalr	-1226(ra) # 800035ec <end_op>
    80003abe:	a00d                	j	80003ae0 <fileclose+0xa8>
    panic("fileclose");
    80003ac0:	00005517          	auipc	a0,0x5
    80003ac4:	b7050513          	addi	a0,a0,-1168 # 80008630 <syscalls+0x268>
    80003ac8:	00002097          	auipc	ra,0x2
    80003acc:	180080e7          	jalr	384(ra) # 80005c48 <panic>
    release(&ftable.lock);
    80003ad0:	00016517          	auipc	a0,0x16
    80003ad4:	09850513          	addi	a0,a0,152 # 80019b68 <ftable>
    80003ad8:	00002097          	auipc	ra,0x2
    80003adc:	7ca080e7          	jalr	1994(ra) # 800062a2 <release>
  }
}
    80003ae0:	70e2                	ld	ra,56(sp)
    80003ae2:	7442                	ld	s0,48(sp)
    80003ae4:	74a2                	ld	s1,40(sp)
    80003ae6:	7902                	ld	s2,32(sp)
    80003ae8:	69e2                	ld	s3,24(sp)
    80003aea:	6a42                	ld	s4,16(sp)
    80003aec:	6aa2                	ld	s5,8(sp)
    80003aee:	6121                	addi	sp,sp,64
    80003af0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003af2:	85d6                	mv	a1,s5
    80003af4:	8552                	mv	a0,s4
    80003af6:	00000097          	auipc	ra,0x0
    80003afa:	34c080e7          	jalr	844(ra) # 80003e42 <pipeclose>
    80003afe:	b7cd                	j	80003ae0 <fileclose+0xa8>

0000000080003b00 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003b00:	715d                	addi	sp,sp,-80
    80003b02:	e486                	sd	ra,72(sp)
    80003b04:	e0a2                	sd	s0,64(sp)
    80003b06:	fc26                	sd	s1,56(sp)
    80003b08:	f84a                	sd	s2,48(sp)
    80003b0a:	f44e                	sd	s3,40(sp)
    80003b0c:	0880                	addi	s0,sp,80
    80003b0e:	84aa                	mv	s1,a0
    80003b10:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003b12:	ffffd097          	auipc	ra,0xffffd
    80003b16:	336080e7          	jalr	822(ra) # 80000e48 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003b1a:	409c                	lw	a5,0(s1)
    80003b1c:	37f9                	addiw	a5,a5,-2
    80003b1e:	4705                	li	a4,1
    80003b20:	04f76763          	bltu	a4,a5,80003b6e <filestat+0x6e>
    80003b24:	892a                	mv	s2,a0
    ilock(f->ip);
    80003b26:	6c88                	ld	a0,24(s1)
    80003b28:	fffff097          	auipc	ra,0xfffff
    80003b2c:	072080e7          	jalr	114(ra) # 80002b9a <ilock>
    stati(f->ip, &st);
    80003b30:	fb840593          	addi	a1,s0,-72
    80003b34:	6c88                	ld	a0,24(s1)
    80003b36:	fffff097          	auipc	ra,0xfffff
    80003b3a:	2ee080e7          	jalr	750(ra) # 80002e24 <stati>
    iunlock(f->ip);
    80003b3e:	6c88                	ld	a0,24(s1)
    80003b40:	fffff097          	auipc	ra,0xfffff
    80003b44:	11c080e7          	jalr	284(ra) # 80002c5c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003b48:	46e1                	li	a3,24
    80003b4a:	fb840613          	addi	a2,s0,-72
    80003b4e:	85ce                	mv	a1,s3
    80003b50:	05093503          	ld	a0,80(s2)
    80003b54:	ffffd097          	auipc	ra,0xffffd
    80003b58:	fb6080e7          	jalr	-74(ra) # 80000b0a <copyout>
    80003b5c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003b60:	60a6                	ld	ra,72(sp)
    80003b62:	6406                	ld	s0,64(sp)
    80003b64:	74e2                	ld	s1,56(sp)
    80003b66:	7942                	ld	s2,48(sp)
    80003b68:	79a2                	ld	s3,40(sp)
    80003b6a:	6161                	addi	sp,sp,80
    80003b6c:	8082                	ret
  return -1;
    80003b6e:	557d                	li	a0,-1
    80003b70:	bfc5                	j	80003b60 <filestat+0x60>

0000000080003b72 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003b72:	7179                	addi	sp,sp,-48
    80003b74:	f406                	sd	ra,40(sp)
    80003b76:	f022                	sd	s0,32(sp)
    80003b78:	ec26                	sd	s1,24(sp)
    80003b7a:	e84a                	sd	s2,16(sp)
    80003b7c:	e44e                	sd	s3,8(sp)
    80003b7e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003b80:	00854783          	lbu	a5,8(a0)
    80003b84:	c3d5                	beqz	a5,80003c28 <fileread+0xb6>
    80003b86:	84aa                	mv	s1,a0
    80003b88:	89ae                	mv	s3,a1
    80003b8a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003b8c:	411c                	lw	a5,0(a0)
    80003b8e:	4705                	li	a4,1
    80003b90:	04e78963          	beq	a5,a4,80003be2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003b94:	470d                	li	a4,3
    80003b96:	04e78d63          	beq	a5,a4,80003bf0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003b9a:	4709                	li	a4,2
    80003b9c:	06e79e63          	bne	a5,a4,80003c18 <fileread+0xa6>
    ilock(f->ip);
    80003ba0:	6d08                	ld	a0,24(a0)
    80003ba2:	fffff097          	auipc	ra,0xfffff
    80003ba6:	ff8080e7          	jalr	-8(ra) # 80002b9a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003baa:	874a                	mv	a4,s2
    80003bac:	5094                	lw	a3,32(s1)
    80003bae:	864e                	mv	a2,s3
    80003bb0:	4585                	li	a1,1
    80003bb2:	6c88                	ld	a0,24(s1)
    80003bb4:	fffff097          	auipc	ra,0xfffff
    80003bb8:	29a080e7          	jalr	666(ra) # 80002e4e <readi>
    80003bbc:	892a                	mv	s2,a0
    80003bbe:	00a05563          	blez	a0,80003bc8 <fileread+0x56>
      f->off += r;
    80003bc2:	509c                	lw	a5,32(s1)
    80003bc4:	9fa9                	addw	a5,a5,a0
    80003bc6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003bc8:	6c88                	ld	a0,24(s1)
    80003bca:	fffff097          	auipc	ra,0xfffff
    80003bce:	092080e7          	jalr	146(ra) # 80002c5c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003bd2:	854a                	mv	a0,s2
    80003bd4:	70a2                	ld	ra,40(sp)
    80003bd6:	7402                	ld	s0,32(sp)
    80003bd8:	64e2                	ld	s1,24(sp)
    80003bda:	6942                	ld	s2,16(sp)
    80003bdc:	69a2                	ld	s3,8(sp)
    80003bde:	6145                	addi	sp,sp,48
    80003be0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003be2:	6908                	ld	a0,16(a0)
    80003be4:	00000097          	auipc	ra,0x0
    80003be8:	3c8080e7          	jalr	968(ra) # 80003fac <piperead>
    80003bec:	892a                	mv	s2,a0
    80003bee:	b7d5                	j	80003bd2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003bf0:	02451783          	lh	a5,36(a0)
    80003bf4:	03079693          	slli	a3,a5,0x30
    80003bf8:	92c1                	srli	a3,a3,0x30
    80003bfa:	4725                	li	a4,9
    80003bfc:	02d76863          	bltu	a4,a3,80003c2c <fileread+0xba>
    80003c00:	0792                	slli	a5,a5,0x4
    80003c02:	00016717          	auipc	a4,0x16
    80003c06:	ec670713          	addi	a4,a4,-314 # 80019ac8 <devsw>
    80003c0a:	97ba                	add	a5,a5,a4
    80003c0c:	639c                	ld	a5,0(a5)
    80003c0e:	c38d                	beqz	a5,80003c30 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003c10:	4505                	li	a0,1
    80003c12:	9782                	jalr	a5
    80003c14:	892a                	mv	s2,a0
    80003c16:	bf75                	j	80003bd2 <fileread+0x60>
    panic("fileread");
    80003c18:	00005517          	auipc	a0,0x5
    80003c1c:	a2850513          	addi	a0,a0,-1496 # 80008640 <syscalls+0x278>
    80003c20:	00002097          	auipc	ra,0x2
    80003c24:	028080e7          	jalr	40(ra) # 80005c48 <panic>
    return -1;
    80003c28:	597d                	li	s2,-1
    80003c2a:	b765                	j	80003bd2 <fileread+0x60>
      return -1;
    80003c2c:	597d                	li	s2,-1
    80003c2e:	b755                	j	80003bd2 <fileread+0x60>
    80003c30:	597d                	li	s2,-1
    80003c32:	b745                	j	80003bd2 <fileread+0x60>

0000000080003c34 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003c34:	715d                	addi	sp,sp,-80
    80003c36:	e486                	sd	ra,72(sp)
    80003c38:	e0a2                	sd	s0,64(sp)
    80003c3a:	fc26                	sd	s1,56(sp)
    80003c3c:	f84a                	sd	s2,48(sp)
    80003c3e:	f44e                	sd	s3,40(sp)
    80003c40:	f052                	sd	s4,32(sp)
    80003c42:	ec56                	sd	s5,24(sp)
    80003c44:	e85a                	sd	s6,16(sp)
    80003c46:	e45e                	sd	s7,8(sp)
    80003c48:	e062                	sd	s8,0(sp)
    80003c4a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003c4c:	00954783          	lbu	a5,9(a0)
    80003c50:	10078663          	beqz	a5,80003d5c <filewrite+0x128>
    80003c54:	892a                	mv	s2,a0
    80003c56:	8aae                	mv	s5,a1
    80003c58:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003c5a:	411c                	lw	a5,0(a0)
    80003c5c:	4705                	li	a4,1
    80003c5e:	02e78263          	beq	a5,a4,80003c82 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003c62:	470d                	li	a4,3
    80003c64:	02e78663          	beq	a5,a4,80003c90 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003c68:	4709                	li	a4,2
    80003c6a:	0ee79163          	bne	a5,a4,80003d4c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003c6e:	0ac05d63          	blez	a2,80003d28 <filewrite+0xf4>
    int i = 0;
    80003c72:	4981                	li	s3,0
    80003c74:	6b05                	lui	s6,0x1
    80003c76:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003c7a:	6b85                	lui	s7,0x1
    80003c7c:	c00b8b9b          	addiw	s7,s7,-1024
    80003c80:	a861                	j	80003d18 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003c82:	6908                	ld	a0,16(a0)
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	22e080e7          	jalr	558(ra) # 80003eb2 <pipewrite>
    80003c8c:	8a2a                	mv	s4,a0
    80003c8e:	a045                	j	80003d2e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003c90:	02451783          	lh	a5,36(a0)
    80003c94:	03079693          	slli	a3,a5,0x30
    80003c98:	92c1                	srli	a3,a3,0x30
    80003c9a:	4725                	li	a4,9
    80003c9c:	0cd76263          	bltu	a4,a3,80003d60 <filewrite+0x12c>
    80003ca0:	0792                	slli	a5,a5,0x4
    80003ca2:	00016717          	auipc	a4,0x16
    80003ca6:	e2670713          	addi	a4,a4,-474 # 80019ac8 <devsw>
    80003caa:	97ba                	add	a5,a5,a4
    80003cac:	679c                	ld	a5,8(a5)
    80003cae:	cbdd                	beqz	a5,80003d64 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003cb0:	4505                	li	a0,1
    80003cb2:	9782                	jalr	a5
    80003cb4:	8a2a                	mv	s4,a0
    80003cb6:	a8a5                	j	80003d2e <filewrite+0xfa>
    80003cb8:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003cbc:	00000097          	auipc	ra,0x0
    80003cc0:	8b0080e7          	jalr	-1872(ra) # 8000356c <begin_op>
      ilock(f->ip);
    80003cc4:	01893503          	ld	a0,24(s2)
    80003cc8:	fffff097          	auipc	ra,0xfffff
    80003ccc:	ed2080e7          	jalr	-302(ra) # 80002b9a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003cd0:	8762                	mv	a4,s8
    80003cd2:	02092683          	lw	a3,32(s2)
    80003cd6:	01598633          	add	a2,s3,s5
    80003cda:	4585                	li	a1,1
    80003cdc:	01893503          	ld	a0,24(s2)
    80003ce0:	fffff097          	auipc	ra,0xfffff
    80003ce4:	266080e7          	jalr	614(ra) # 80002f46 <writei>
    80003ce8:	84aa                	mv	s1,a0
    80003cea:	00a05763          	blez	a0,80003cf8 <filewrite+0xc4>
        f->off += r;
    80003cee:	02092783          	lw	a5,32(s2)
    80003cf2:	9fa9                	addw	a5,a5,a0
    80003cf4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003cf8:	01893503          	ld	a0,24(s2)
    80003cfc:	fffff097          	auipc	ra,0xfffff
    80003d00:	f60080e7          	jalr	-160(ra) # 80002c5c <iunlock>
      end_op();
    80003d04:	00000097          	auipc	ra,0x0
    80003d08:	8e8080e7          	jalr	-1816(ra) # 800035ec <end_op>

      if(r != n1){
    80003d0c:	009c1f63          	bne	s8,s1,80003d2a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003d10:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003d14:	0149db63          	bge	s3,s4,80003d2a <filewrite+0xf6>
      int n1 = n - i;
    80003d18:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80003d1c:	84be                	mv	s1,a5
    80003d1e:	2781                	sext.w	a5,a5
    80003d20:	f8fb5ce3          	bge	s6,a5,80003cb8 <filewrite+0x84>
    80003d24:	84de                	mv	s1,s7
    80003d26:	bf49                	j	80003cb8 <filewrite+0x84>
    int i = 0;
    80003d28:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003d2a:	013a1f63          	bne	s4,s3,80003d48 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003d2e:	8552                	mv	a0,s4
    80003d30:	60a6                	ld	ra,72(sp)
    80003d32:	6406                	ld	s0,64(sp)
    80003d34:	74e2                	ld	s1,56(sp)
    80003d36:	7942                	ld	s2,48(sp)
    80003d38:	79a2                	ld	s3,40(sp)
    80003d3a:	7a02                	ld	s4,32(sp)
    80003d3c:	6ae2                	ld	s5,24(sp)
    80003d3e:	6b42                	ld	s6,16(sp)
    80003d40:	6ba2                	ld	s7,8(sp)
    80003d42:	6c02                	ld	s8,0(sp)
    80003d44:	6161                	addi	sp,sp,80
    80003d46:	8082                	ret
    ret = (i == n ? n : -1);
    80003d48:	5a7d                	li	s4,-1
    80003d4a:	b7d5                	j	80003d2e <filewrite+0xfa>
    panic("filewrite");
    80003d4c:	00005517          	auipc	a0,0x5
    80003d50:	90450513          	addi	a0,a0,-1788 # 80008650 <syscalls+0x288>
    80003d54:	00002097          	auipc	ra,0x2
    80003d58:	ef4080e7          	jalr	-268(ra) # 80005c48 <panic>
    return -1;
    80003d5c:	5a7d                	li	s4,-1
    80003d5e:	bfc1                	j	80003d2e <filewrite+0xfa>
      return -1;
    80003d60:	5a7d                	li	s4,-1
    80003d62:	b7f1                	j	80003d2e <filewrite+0xfa>
    80003d64:	5a7d                	li	s4,-1
    80003d66:	b7e1                	j	80003d2e <filewrite+0xfa>

0000000080003d68 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003d68:	7179                	addi	sp,sp,-48
    80003d6a:	f406                	sd	ra,40(sp)
    80003d6c:	f022                	sd	s0,32(sp)
    80003d6e:	ec26                	sd	s1,24(sp)
    80003d70:	e84a                	sd	s2,16(sp)
    80003d72:	e44e                	sd	s3,8(sp)
    80003d74:	e052                	sd	s4,0(sp)
    80003d76:	1800                	addi	s0,sp,48
    80003d78:	84aa                	mv	s1,a0
    80003d7a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003d7c:	0005b023          	sd	zero,0(a1)
    80003d80:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003d84:	00000097          	auipc	ra,0x0
    80003d88:	bf8080e7          	jalr	-1032(ra) # 8000397c <filealloc>
    80003d8c:	e088                	sd	a0,0(s1)
    80003d8e:	c551                	beqz	a0,80003e1a <pipealloc+0xb2>
    80003d90:	00000097          	auipc	ra,0x0
    80003d94:	bec080e7          	jalr	-1044(ra) # 8000397c <filealloc>
    80003d98:	00aa3023          	sd	a0,0(s4)
    80003d9c:	c92d                	beqz	a0,80003e0e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003d9e:	ffffc097          	auipc	ra,0xffffc
    80003da2:	37a080e7          	jalr	890(ra) # 80000118 <kalloc>
    80003da6:	892a                	mv	s2,a0
    80003da8:	c125                	beqz	a0,80003e08 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003daa:	4985                	li	s3,1
    80003dac:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003db0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003db4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003db8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003dbc:	00005597          	auipc	a1,0x5
    80003dc0:	8a458593          	addi	a1,a1,-1884 # 80008660 <syscalls+0x298>
    80003dc4:	00002097          	auipc	ra,0x2
    80003dc8:	39a080e7          	jalr	922(ra) # 8000615e <initlock>
  (*f0)->type = FD_PIPE;
    80003dcc:	609c                	ld	a5,0(s1)
    80003dce:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003dd2:	609c                	ld	a5,0(s1)
    80003dd4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003dd8:	609c                	ld	a5,0(s1)
    80003dda:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003dde:	609c                	ld	a5,0(s1)
    80003de0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003de4:	000a3783          	ld	a5,0(s4)
    80003de8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003dec:	000a3783          	ld	a5,0(s4)
    80003df0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003df4:	000a3783          	ld	a5,0(s4)
    80003df8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003dfc:	000a3783          	ld	a5,0(s4)
    80003e00:	0127b823          	sd	s2,16(a5)
  return 0;
    80003e04:	4501                	li	a0,0
    80003e06:	a025                	j	80003e2e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003e08:	6088                	ld	a0,0(s1)
    80003e0a:	e501                	bnez	a0,80003e12 <pipealloc+0xaa>
    80003e0c:	a039                	j	80003e1a <pipealloc+0xb2>
    80003e0e:	6088                	ld	a0,0(s1)
    80003e10:	c51d                	beqz	a0,80003e3e <pipealloc+0xd6>
    fileclose(*f0);
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	c26080e7          	jalr	-986(ra) # 80003a38 <fileclose>
  if(*f1)
    80003e1a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003e1e:	557d                	li	a0,-1
  if(*f1)
    80003e20:	c799                	beqz	a5,80003e2e <pipealloc+0xc6>
    fileclose(*f1);
    80003e22:	853e                	mv	a0,a5
    80003e24:	00000097          	auipc	ra,0x0
    80003e28:	c14080e7          	jalr	-1004(ra) # 80003a38 <fileclose>
  return -1;
    80003e2c:	557d                	li	a0,-1
}
    80003e2e:	70a2                	ld	ra,40(sp)
    80003e30:	7402                	ld	s0,32(sp)
    80003e32:	64e2                	ld	s1,24(sp)
    80003e34:	6942                	ld	s2,16(sp)
    80003e36:	69a2                	ld	s3,8(sp)
    80003e38:	6a02                	ld	s4,0(sp)
    80003e3a:	6145                	addi	sp,sp,48
    80003e3c:	8082                	ret
  return -1;
    80003e3e:	557d                	li	a0,-1
    80003e40:	b7fd                	j	80003e2e <pipealloc+0xc6>

0000000080003e42 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003e42:	1101                	addi	sp,sp,-32
    80003e44:	ec06                	sd	ra,24(sp)
    80003e46:	e822                	sd	s0,16(sp)
    80003e48:	e426                	sd	s1,8(sp)
    80003e4a:	e04a                	sd	s2,0(sp)
    80003e4c:	1000                	addi	s0,sp,32
    80003e4e:	84aa                	mv	s1,a0
    80003e50:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003e52:	00002097          	auipc	ra,0x2
    80003e56:	39c080e7          	jalr	924(ra) # 800061ee <acquire>
  if(writable){
    80003e5a:	02090d63          	beqz	s2,80003e94 <pipeclose+0x52>
    pi->writeopen = 0;
    80003e5e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003e62:	21848513          	addi	a0,s1,536
    80003e66:	ffffe097          	auipc	ra,0xffffe
    80003e6a:	880080e7          	jalr	-1920(ra) # 800016e6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003e6e:	2204b783          	ld	a5,544(s1)
    80003e72:	eb95                	bnez	a5,80003ea6 <pipeclose+0x64>
    release(&pi->lock);
    80003e74:	8526                	mv	a0,s1
    80003e76:	00002097          	auipc	ra,0x2
    80003e7a:	42c080e7          	jalr	1068(ra) # 800062a2 <release>
    kfree((char*)pi);
    80003e7e:	8526                	mv	a0,s1
    80003e80:	ffffc097          	auipc	ra,0xffffc
    80003e84:	19c080e7          	jalr	412(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003e88:	60e2                	ld	ra,24(sp)
    80003e8a:	6442                	ld	s0,16(sp)
    80003e8c:	64a2                	ld	s1,8(sp)
    80003e8e:	6902                	ld	s2,0(sp)
    80003e90:	6105                	addi	sp,sp,32
    80003e92:	8082                	ret
    pi->readopen = 0;
    80003e94:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003e98:	21c48513          	addi	a0,s1,540
    80003e9c:	ffffe097          	auipc	ra,0xffffe
    80003ea0:	84a080e7          	jalr	-1974(ra) # 800016e6 <wakeup>
    80003ea4:	b7e9                	j	80003e6e <pipeclose+0x2c>
    release(&pi->lock);
    80003ea6:	8526                	mv	a0,s1
    80003ea8:	00002097          	auipc	ra,0x2
    80003eac:	3fa080e7          	jalr	1018(ra) # 800062a2 <release>
}
    80003eb0:	bfe1                	j	80003e88 <pipeclose+0x46>

0000000080003eb2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003eb2:	7159                	addi	sp,sp,-112
    80003eb4:	f486                	sd	ra,104(sp)
    80003eb6:	f0a2                	sd	s0,96(sp)
    80003eb8:	eca6                	sd	s1,88(sp)
    80003eba:	e8ca                	sd	s2,80(sp)
    80003ebc:	e4ce                	sd	s3,72(sp)
    80003ebe:	e0d2                	sd	s4,64(sp)
    80003ec0:	fc56                	sd	s5,56(sp)
    80003ec2:	f85a                	sd	s6,48(sp)
    80003ec4:	f45e                	sd	s7,40(sp)
    80003ec6:	f062                	sd	s8,32(sp)
    80003ec8:	ec66                	sd	s9,24(sp)
    80003eca:	1880                	addi	s0,sp,112
    80003ecc:	84aa                	mv	s1,a0
    80003ece:	8aae                	mv	s5,a1
    80003ed0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003ed2:	ffffd097          	auipc	ra,0xffffd
    80003ed6:	f76080e7          	jalr	-138(ra) # 80000e48 <myproc>
    80003eda:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003edc:	8526                	mv	a0,s1
    80003ede:	00002097          	auipc	ra,0x2
    80003ee2:	310080e7          	jalr	784(ra) # 800061ee <acquire>
  while(i < n){
    80003ee6:	0d405163          	blez	s4,80003fa8 <pipewrite+0xf6>
    80003eea:	8ba6                	mv	s7,s1
  int i = 0;
    80003eec:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003eee:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003ef0:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003ef4:	21c48c13          	addi	s8,s1,540
    80003ef8:	a08d                	j	80003f5a <pipewrite+0xa8>
      release(&pi->lock);
    80003efa:	8526                	mv	a0,s1
    80003efc:	00002097          	auipc	ra,0x2
    80003f00:	3a6080e7          	jalr	934(ra) # 800062a2 <release>
      return -1;
    80003f04:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003f06:	854a                	mv	a0,s2
    80003f08:	70a6                	ld	ra,104(sp)
    80003f0a:	7406                	ld	s0,96(sp)
    80003f0c:	64e6                	ld	s1,88(sp)
    80003f0e:	6946                	ld	s2,80(sp)
    80003f10:	69a6                	ld	s3,72(sp)
    80003f12:	6a06                	ld	s4,64(sp)
    80003f14:	7ae2                	ld	s5,56(sp)
    80003f16:	7b42                	ld	s6,48(sp)
    80003f18:	7ba2                	ld	s7,40(sp)
    80003f1a:	7c02                	ld	s8,32(sp)
    80003f1c:	6ce2                	ld	s9,24(sp)
    80003f1e:	6165                	addi	sp,sp,112
    80003f20:	8082                	ret
      wakeup(&pi->nread);
    80003f22:	8566                	mv	a0,s9
    80003f24:	ffffd097          	auipc	ra,0xffffd
    80003f28:	7c2080e7          	jalr	1986(ra) # 800016e6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003f2c:	85de                	mv	a1,s7
    80003f2e:	8562                	mv	a0,s8
    80003f30:	ffffd097          	auipc	ra,0xffffd
    80003f34:	62a080e7          	jalr	1578(ra) # 8000155a <sleep>
    80003f38:	a839                	j	80003f56 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003f3a:	21c4a783          	lw	a5,540(s1)
    80003f3e:	0017871b          	addiw	a4,a5,1
    80003f42:	20e4ae23          	sw	a4,540(s1)
    80003f46:	1ff7f793          	andi	a5,a5,511
    80003f4a:	97a6                	add	a5,a5,s1
    80003f4c:	f9f44703          	lbu	a4,-97(s0)
    80003f50:	00e78c23          	sb	a4,24(a5)
      i++;
    80003f54:	2905                	addiw	s2,s2,1
  while(i < n){
    80003f56:	03495d63          	bge	s2,s4,80003f90 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80003f5a:	2204a783          	lw	a5,544(s1)
    80003f5e:	dfd1                	beqz	a5,80003efa <pipewrite+0x48>
    80003f60:	0289a783          	lw	a5,40(s3)
    80003f64:	fbd9                	bnez	a5,80003efa <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003f66:	2184a783          	lw	a5,536(s1)
    80003f6a:	21c4a703          	lw	a4,540(s1)
    80003f6e:	2007879b          	addiw	a5,a5,512
    80003f72:	faf708e3          	beq	a4,a5,80003f22 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003f76:	4685                	li	a3,1
    80003f78:	01590633          	add	a2,s2,s5
    80003f7c:	f9f40593          	addi	a1,s0,-97
    80003f80:	0509b503          	ld	a0,80(s3)
    80003f84:	ffffd097          	auipc	ra,0xffffd
    80003f88:	c12080e7          	jalr	-1006(ra) # 80000b96 <copyin>
    80003f8c:	fb6517e3          	bne	a0,s6,80003f3a <pipewrite+0x88>
  wakeup(&pi->nread);
    80003f90:	21848513          	addi	a0,s1,536
    80003f94:	ffffd097          	auipc	ra,0xffffd
    80003f98:	752080e7          	jalr	1874(ra) # 800016e6 <wakeup>
  release(&pi->lock);
    80003f9c:	8526                	mv	a0,s1
    80003f9e:	00002097          	auipc	ra,0x2
    80003fa2:	304080e7          	jalr	772(ra) # 800062a2 <release>
  return i;
    80003fa6:	b785                	j	80003f06 <pipewrite+0x54>
  int i = 0;
    80003fa8:	4901                	li	s2,0
    80003faa:	b7dd                	j	80003f90 <pipewrite+0xde>

0000000080003fac <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003fac:	715d                	addi	sp,sp,-80
    80003fae:	e486                	sd	ra,72(sp)
    80003fb0:	e0a2                	sd	s0,64(sp)
    80003fb2:	fc26                	sd	s1,56(sp)
    80003fb4:	f84a                	sd	s2,48(sp)
    80003fb6:	f44e                	sd	s3,40(sp)
    80003fb8:	f052                	sd	s4,32(sp)
    80003fba:	ec56                	sd	s5,24(sp)
    80003fbc:	e85a                	sd	s6,16(sp)
    80003fbe:	0880                	addi	s0,sp,80
    80003fc0:	84aa                	mv	s1,a0
    80003fc2:	892e                	mv	s2,a1
    80003fc4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003fc6:	ffffd097          	auipc	ra,0xffffd
    80003fca:	e82080e7          	jalr	-382(ra) # 80000e48 <myproc>
    80003fce:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003fd0:	8b26                	mv	s6,s1
    80003fd2:	8526                	mv	a0,s1
    80003fd4:	00002097          	auipc	ra,0x2
    80003fd8:	21a080e7          	jalr	538(ra) # 800061ee <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003fdc:	2184a703          	lw	a4,536(s1)
    80003fe0:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003fe4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003fe8:	02f71463          	bne	a4,a5,80004010 <piperead+0x64>
    80003fec:	2244a783          	lw	a5,548(s1)
    80003ff0:	c385                	beqz	a5,80004010 <piperead+0x64>
    if(pr->killed){
    80003ff2:	028a2783          	lw	a5,40(s4)
    80003ff6:	ebc1                	bnez	a5,80004086 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003ff8:	85da                	mv	a1,s6
    80003ffa:	854e                	mv	a0,s3
    80003ffc:	ffffd097          	auipc	ra,0xffffd
    80004000:	55e080e7          	jalr	1374(ra) # 8000155a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004004:	2184a703          	lw	a4,536(s1)
    80004008:	21c4a783          	lw	a5,540(s1)
    8000400c:	fef700e3          	beq	a4,a5,80003fec <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004010:	09505263          	blez	s5,80004094 <piperead+0xe8>
    80004014:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004016:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004018:	2184a783          	lw	a5,536(s1)
    8000401c:	21c4a703          	lw	a4,540(s1)
    80004020:	02f70d63          	beq	a4,a5,8000405a <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004024:	0017871b          	addiw	a4,a5,1
    80004028:	20e4ac23          	sw	a4,536(s1)
    8000402c:	1ff7f793          	andi	a5,a5,511
    80004030:	97a6                	add	a5,a5,s1
    80004032:	0187c783          	lbu	a5,24(a5)
    80004036:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000403a:	4685                	li	a3,1
    8000403c:	fbf40613          	addi	a2,s0,-65
    80004040:	85ca                	mv	a1,s2
    80004042:	050a3503          	ld	a0,80(s4)
    80004046:	ffffd097          	auipc	ra,0xffffd
    8000404a:	ac4080e7          	jalr	-1340(ra) # 80000b0a <copyout>
    8000404e:	01650663          	beq	a0,s6,8000405a <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004052:	2985                	addiw	s3,s3,1
    80004054:	0905                	addi	s2,s2,1
    80004056:	fd3a91e3          	bne	s5,s3,80004018 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000405a:	21c48513          	addi	a0,s1,540
    8000405e:	ffffd097          	auipc	ra,0xffffd
    80004062:	688080e7          	jalr	1672(ra) # 800016e6 <wakeup>
  release(&pi->lock);
    80004066:	8526                	mv	a0,s1
    80004068:	00002097          	auipc	ra,0x2
    8000406c:	23a080e7          	jalr	570(ra) # 800062a2 <release>
  return i;
}
    80004070:	854e                	mv	a0,s3
    80004072:	60a6                	ld	ra,72(sp)
    80004074:	6406                	ld	s0,64(sp)
    80004076:	74e2                	ld	s1,56(sp)
    80004078:	7942                	ld	s2,48(sp)
    8000407a:	79a2                	ld	s3,40(sp)
    8000407c:	7a02                	ld	s4,32(sp)
    8000407e:	6ae2                	ld	s5,24(sp)
    80004080:	6b42                	ld	s6,16(sp)
    80004082:	6161                	addi	sp,sp,80
    80004084:	8082                	ret
      release(&pi->lock);
    80004086:	8526                	mv	a0,s1
    80004088:	00002097          	auipc	ra,0x2
    8000408c:	21a080e7          	jalr	538(ra) # 800062a2 <release>
      return -1;
    80004090:	59fd                	li	s3,-1
    80004092:	bff9                	j	80004070 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004094:	4981                	li	s3,0
    80004096:	b7d1                	j	8000405a <piperead+0xae>

0000000080004098 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004098:	df010113          	addi	sp,sp,-528
    8000409c:	20113423          	sd	ra,520(sp)
    800040a0:	20813023          	sd	s0,512(sp)
    800040a4:	ffa6                	sd	s1,504(sp)
    800040a6:	fbca                	sd	s2,496(sp)
    800040a8:	f7ce                	sd	s3,488(sp)
    800040aa:	f3d2                	sd	s4,480(sp)
    800040ac:	efd6                	sd	s5,472(sp)
    800040ae:	ebda                	sd	s6,464(sp)
    800040b0:	e7de                	sd	s7,456(sp)
    800040b2:	e3e2                	sd	s8,448(sp)
    800040b4:	ff66                	sd	s9,440(sp)
    800040b6:	fb6a                	sd	s10,432(sp)
    800040b8:	f76e                	sd	s11,424(sp)
    800040ba:	0c00                	addi	s0,sp,528
    800040bc:	84aa                	mv	s1,a0
    800040be:	dea43c23          	sd	a0,-520(s0)
    800040c2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800040c6:	ffffd097          	auipc	ra,0xffffd
    800040ca:	d82080e7          	jalr	-638(ra) # 80000e48 <myproc>
    800040ce:	892a                	mv	s2,a0

  begin_op();
    800040d0:	fffff097          	auipc	ra,0xfffff
    800040d4:	49c080e7          	jalr	1180(ra) # 8000356c <begin_op>

  if((ip = namei(path)) == 0){
    800040d8:	8526                	mv	a0,s1
    800040da:	fffff097          	auipc	ra,0xfffff
    800040de:	276080e7          	jalr	630(ra) # 80003350 <namei>
    800040e2:	c92d                	beqz	a0,80004154 <exec+0xbc>
    800040e4:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800040e6:	fffff097          	auipc	ra,0xfffff
    800040ea:	ab4080e7          	jalr	-1356(ra) # 80002b9a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800040ee:	04000713          	li	a4,64
    800040f2:	4681                	li	a3,0
    800040f4:	e5040613          	addi	a2,s0,-432
    800040f8:	4581                	li	a1,0
    800040fa:	8526                	mv	a0,s1
    800040fc:	fffff097          	auipc	ra,0xfffff
    80004100:	d52080e7          	jalr	-686(ra) # 80002e4e <readi>
    80004104:	04000793          	li	a5,64
    80004108:	00f51a63          	bne	a0,a5,8000411c <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000410c:	e5042703          	lw	a4,-432(s0)
    80004110:	464c47b7          	lui	a5,0x464c4
    80004114:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004118:	04f70463          	beq	a4,a5,80004160 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000411c:	8526                	mv	a0,s1
    8000411e:	fffff097          	auipc	ra,0xfffff
    80004122:	cde080e7          	jalr	-802(ra) # 80002dfc <iunlockput>
    end_op();
    80004126:	fffff097          	auipc	ra,0xfffff
    8000412a:	4c6080e7          	jalr	1222(ra) # 800035ec <end_op>
  }
  return -1;
    8000412e:	557d                	li	a0,-1
}
    80004130:	20813083          	ld	ra,520(sp)
    80004134:	20013403          	ld	s0,512(sp)
    80004138:	74fe                	ld	s1,504(sp)
    8000413a:	795e                	ld	s2,496(sp)
    8000413c:	79be                	ld	s3,488(sp)
    8000413e:	7a1e                	ld	s4,480(sp)
    80004140:	6afe                	ld	s5,472(sp)
    80004142:	6b5e                	ld	s6,464(sp)
    80004144:	6bbe                	ld	s7,456(sp)
    80004146:	6c1e                	ld	s8,448(sp)
    80004148:	7cfa                	ld	s9,440(sp)
    8000414a:	7d5a                	ld	s10,432(sp)
    8000414c:	7dba                	ld	s11,424(sp)
    8000414e:	21010113          	addi	sp,sp,528
    80004152:	8082                	ret
    end_op();
    80004154:	fffff097          	auipc	ra,0xfffff
    80004158:	498080e7          	jalr	1176(ra) # 800035ec <end_op>
    return -1;
    8000415c:	557d                	li	a0,-1
    8000415e:	bfc9                	j	80004130 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004160:	854a                	mv	a0,s2
    80004162:	ffffd097          	auipc	ra,0xffffd
    80004166:	daa080e7          	jalr	-598(ra) # 80000f0c <proc_pagetable>
    8000416a:	8baa                	mv	s7,a0
    8000416c:	d945                	beqz	a0,8000411c <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000416e:	e7042983          	lw	s3,-400(s0)
    80004172:	e8845783          	lhu	a5,-376(s0)
    80004176:	c7ad                	beqz	a5,800041e0 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004178:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000417a:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    8000417c:	6c85                	lui	s9,0x1
    8000417e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004182:	def43823          	sd	a5,-528(s0)
    80004186:	a42d                	j	800043b0 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004188:	00004517          	auipc	a0,0x4
    8000418c:	4e050513          	addi	a0,a0,1248 # 80008668 <syscalls+0x2a0>
    80004190:	00002097          	auipc	ra,0x2
    80004194:	ab8080e7          	jalr	-1352(ra) # 80005c48 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004198:	8756                	mv	a4,s5
    8000419a:	012d86bb          	addw	a3,s11,s2
    8000419e:	4581                	li	a1,0
    800041a0:	8526                	mv	a0,s1
    800041a2:	fffff097          	auipc	ra,0xfffff
    800041a6:	cac080e7          	jalr	-852(ra) # 80002e4e <readi>
    800041aa:	2501                	sext.w	a0,a0
    800041ac:	1aaa9963          	bne	s5,a0,8000435e <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    800041b0:	6785                	lui	a5,0x1
    800041b2:	0127893b          	addw	s2,a5,s2
    800041b6:	77fd                	lui	a5,0xfffff
    800041b8:	01478a3b          	addw	s4,a5,s4
    800041bc:	1f897163          	bgeu	s2,s8,8000439e <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    800041c0:	02091593          	slli	a1,s2,0x20
    800041c4:	9181                	srli	a1,a1,0x20
    800041c6:	95ea                	add	a1,a1,s10
    800041c8:	855e                	mv	a0,s7
    800041ca:	ffffc097          	auipc	ra,0xffffc
    800041ce:	33c080e7          	jalr	828(ra) # 80000506 <walkaddr>
    800041d2:	862a                	mv	a2,a0
    if(pa == 0)
    800041d4:	d955                	beqz	a0,80004188 <exec+0xf0>
      n = PGSIZE;
    800041d6:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800041d8:	fd9a70e3          	bgeu	s4,s9,80004198 <exec+0x100>
      n = sz - i;
    800041dc:	8ad2                	mv	s5,s4
    800041de:	bf6d                	j	80004198 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800041e0:	4901                	li	s2,0
  iunlockput(ip);
    800041e2:	8526                	mv	a0,s1
    800041e4:	fffff097          	auipc	ra,0xfffff
    800041e8:	c18080e7          	jalr	-1000(ra) # 80002dfc <iunlockput>
  end_op();
    800041ec:	fffff097          	auipc	ra,0xfffff
    800041f0:	400080e7          	jalr	1024(ra) # 800035ec <end_op>
  p = myproc();
    800041f4:	ffffd097          	auipc	ra,0xffffd
    800041f8:	c54080e7          	jalr	-940(ra) # 80000e48 <myproc>
    800041fc:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800041fe:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004202:	6785                	lui	a5,0x1
    80004204:	17fd                	addi	a5,a5,-1
    80004206:	993e                	add	s2,s2,a5
    80004208:	757d                	lui	a0,0xfffff
    8000420a:	00a977b3          	and	a5,s2,a0
    8000420e:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004212:	6609                	lui	a2,0x2
    80004214:	963e                	add	a2,a2,a5
    80004216:	85be                	mv	a1,a5
    80004218:	855e                	mv	a0,s7
    8000421a:	ffffc097          	auipc	ra,0xffffc
    8000421e:	6a0080e7          	jalr	1696(ra) # 800008ba <uvmalloc>
    80004222:	8b2a                	mv	s6,a0
  ip = 0;
    80004224:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004226:	12050c63          	beqz	a0,8000435e <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000422a:	75f9                	lui	a1,0xffffe
    8000422c:	95aa                	add	a1,a1,a0
    8000422e:	855e                	mv	a0,s7
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	8a8080e7          	jalr	-1880(ra) # 80000ad8 <uvmclear>
  stackbase = sp - PGSIZE;
    80004238:	7c7d                	lui	s8,0xfffff
    8000423a:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000423c:	e0043783          	ld	a5,-512(s0)
    80004240:	6388                	ld	a0,0(a5)
    80004242:	c535                	beqz	a0,800042ae <exec+0x216>
    80004244:	e9040993          	addi	s3,s0,-368
    80004248:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000424c:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    8000424e:	ffffc097          	auipc	ra,0xffffc
    80004252:	0ae080e7          	jalr	174(ra) # 800002fc <strlen>
    80004256:	2505                	addiw	a0,a0,1
    80004258:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000425c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004260:	13896363          	bltu	s2,s8,80004386 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004264:	e0043d83          	ld	s11,-512(s0)
    80004268:	000dba03          	ld	s4,0(s11)
    8000426c:	8552                	mv	a0,s4
    8000426e:	ffffc097          	auipc	ra,0xffffc
    80004272:	08e080e7          	jalr	142(ra) # 800002fc <strlen>
    80004276:	0015069b          	addiw	a3,a0,1
    8000427a:	8652                	mv	a2,s4
    8000427c:	85ca                	mv	a1,s2
    8000427e:	855e                	mv	a0,s7
    80004280:	ffffd097          	auipc	ra,0xffffd
    80004284:	88a080e7          	jalr	-1910(ra) # 80000b0a <copyout>
    80004288:	10054363          	bltz	a0,8000438e <exec+0x2f6>
    ustack[argc] = sp;
    8000428c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004290:	0485                	addi	s1,s1,1
    80004292:	008d8793          	addi	a5,s11,8
    80004296:	e0f43023          	sd	a5,-512(s0)
    8000429a:	008db503          	ld	a0,8(s11)
    8000429e:	c911                	beqz	a0,800042b2 <exec+0x21a>
    if(argc >= MAXARG)
    800042a0:	09a1                	addi	s3,s3,8
    800042a2:	fb3c96e3          	bne	s9,s3,8000424e <exec+0x1b6>
  sz = sz1;
    800042a6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800042aa:	4481                	li	s1,0
    800042ac:	a84d                	j	8000435e <exec+0x2c6>
  sp = sz;
    800042ae:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800042b0:	4481                	li	s1,0
  ustack[argc] = 0;
    800042b2:	00349793          	slli	a5,s1,0x3
    800042b6:	f9040713          	addi	a4,s0,-112
    800042ba:	97ba                	add	a5,a5,a4
    800042bc:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800042c0:	00148693          	addi	a3,s1,1
    800042c4:	068e                	slli	a3,a3,0x3
    800042c6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800042ca:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800042ce:	01897663          	bgeu	s2,s8,800042da <exec+0x242>
  sz = sz1;
    800042d2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800042d6:	4481                	li	s1,0
    800042d8:	a059                	j	8000435e <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800042da:	e9040613          	addi	a2,s0,-368
    800042de:	85ca                	mv	a1,s2
    800042e0:	855e                	mv	a0,s7
    800042e2:	ffffd097          	auipc	ra,0xffffd
    800042e6:	828080e7          	jalr	-2008(ra) # 80000b0a <copyout>
    800042ea:	0a054663          	bltz	a0,80004396 <exec+0x2fe>
  p->trapframe->a1 = sp;
    800042ee:	058ab783          	ld	a5,88(s5)
    800042f2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800042f6:	df843783          	ld	a5,-520(s0)
    800042fa:	0007c703          	lbu	a4,0(a5)
    800042fe:	cf11                	beqz	a4,8000431a <exec+0x282>
    80004300:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004302:	02f00693          	li	a3,47
    80004306:	a039                	j	80004314 <exec+0x27c>
      last = s+1;
    80004308:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000430c:	0785                	addi	a5,a5,1
    8000430e:	fff7c703          	lbu	a4,-1(a5)
    80004312:	c701                	beqz	a4,8000431a <exec+0x282>
    if(*s == '/')
    80004314:	fed71ce3          	bne	a4,a3,8000430c <exec+0x274>
    80004318:	bfc5                	j	80004308 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    8000431a:	4641                	li	a2,16
    8000431c:	df843583          	ld	a1,-520(s0)
    80004320:	158a8513          	addi	a0,s5,344
    80004324:	ffffc097          	auipc	ra,0xffffc
    80004328:	fa6080e7          	jalr	-90(ra) # 800002ca <safestrcpy>
  oldpagetable = p->pagetable;
    8000432c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004330:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004334:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004338:	058ab783          	ld	a5,88(s5)
    8000433c:	e6843703          	ld	a4,-408(s0)
    80004340:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004342:	058ab783          	ld	a5,88(s5)
    80004346:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000434a:	85ea                	mv	a1,s10
    8000434c:	ffffd097          	auipc	ra,0xffffd
    80004350:	c5c080e7          	jalr	-932(ra) # 80000fa8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004354:	0004851b          	sext.w	a0,s1
    80004358:	bbe1                	j	80004130 <exec+0x98>
    8000435a:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000435e:	e0843583          	ld	a1,-504(s0)
    80004362:	855e                	mv	a0,s7
    80004364:	ffffd097          	auipc	ra,0xffffd
    80004368:	c44080e7          	jalr	-956(ra) # 80000fa8 <proc_freepagetable>
  if(ip){
    8000436c:	da0498e3          	bnez	s1,8000411c <exec+0x84>
  return -1;
    80004370:	557d                	li	a0,-1
    80004372:	bb7d                	j	80004130 <exec+0x98>
    80004374:	e1243423          	sd	s2,-504(s0)
    80004378:	b7dd                	j	8000435e <exec+0x2c6>
    8000437a:	e1243423          	sd	s2,-504(s0)
    8000437e:	b7c5                	j	8000435e <exec+0x2c6>
    80004380:	e1243423          	sd	s2,-504(s0)
    80004384:	bfe9                	j	8000435e <exec+0x2c6>
  sz = sz1;
    80004386:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000438a:	4481                	li	s1,0
    8000438c:	bfc9                	j	8000435e <exec+0x2c6>
  sz = sz1;
    8000438e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004392:	4481                	li	s1,0
    80004394:	b7e9                	j	8000435e <exec+0x2c6>
  sz = sz1;
    80004396:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000439a:	4481                	li	s1,0
    8000439c:	b7c9                	j	8000435e <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000439e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800043a2:	2b05                	addiw	s6,s6,1
    800043a4:	0389899b          	addiw	s3,s3,56
    800043a8:	e8845783          	lhu	a5,-376(s0)
    800043ac:	e2fb5be3          	bge	s6,a5,800041e2 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800043b0:	2981                	sext.w	s3,s3
    800043b2:	03800713          	li	a4,56
    800043b6:	86ce                	mv	a3,s3
    800043b8:	e1840613          	addi	a2,s0,-488
    800043bc:	4581                	li	a1,0
    800043be:	8526                	mv	a0,s1
    800043c0:	fffff097          	auipc	ra,0xfffff
    800043c4:	a8e080e7          	jalr	-1394(ra) # 80002e4e <readi>
    800043c8:	03800793          	li	a5,56
    800043cc:	f8f517e3          	bne	a0,a5,8000435a <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800043d0:	e1842783          	lw	a5,-488(s0)
    800043d4:	4705                	li	a4,1
    800043d6:	fce796e3          	bne	a5,a4,800043a2 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    800043da:	e4043603          	ld	a2,-448(s0)
    800043de:	e3843783          	ld	a5,-456(s0)
    800043e2:	f8f669e3          	bltu	a2,a5,80004374 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800043e6:	e2843783          	ld	a5,-472(s0)
    800043ea:	963e                	add	a2,a2,a5
    800043ec:	f8f667e3          	bltu	a2,a5,8000437a <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800043f0:	85ca                	mv	a1,s2
    800043f2:	855e                	mv	a0,s7
    800043f4:	ffffc097          	auipc	ra,0xffffc
    800043f8:	4c6080e7          	jalr	1222(ra) # 800008ba <uvmalloc>
    800043fc:	e0a43423          	sd	a0,-504(s0)
    80004400:	d141                	beqz	a0,80004380 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    80004402:	e2843d03          	ld	s10,-472(s0)
    80004406:	df043783          	ld	a5,-528(s0)
    8000440a:	00fd77b3          	and	a5,s10,a5
    8000440e:	fba1                	bnez	a5,8000435e <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004410:	e2042d83          	lw	s11,-480(s0)
    80004414:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004418:	f80c03e3          	beqz	s8,8000439e <exec+0x306>
    8000441c:	8a62                	mv	s4,s8
    8000441e:	4901                	li	s2,0
    80004420:	b345                	j	800041c0 <exec+0x128>

0000000080004422 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004422:	7179                	addi	sp,sp,-48
    80004424:	f406                	sd	ra,40(sp)
    80004426:	f022                	sd	s0,32(sp)
    80004428:	ec26                	sd	s1,24(sp)
    8000442a:	e84a                	sd	s2,16(sp)
    8000442c:	1800                	addi	s0,sp,48
    8000442e:	892e                	mv	s2,a1
    80004430:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004432:	fdc40593          	addi	a1,s0,-36
    80004436:	ffffe097          	auipc	ra,0xffffe
    8000443a:	b4a080e7          	jalr	-1206(ra) # 80001f80 <argint>
    8000443e:	04054063          	bltz	a0,8000447e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004442:	fdc42703          	lw	a4,-36(s0)
    80004446:	47bd                	li	a5,15
    80004448:	02e7ed63          	bltu	a5,a4,80004482 <argfd+0x60>
    8000444c:	ffffd097          	auipc	ra,0xffffd
    80004450:	9fc080e7          	jalr	-1540(ra) # 80000e48 <myproc>
    80004454:	fdc42703          	lw	a4,-36(s0)
    80004458:	01a70793          	addi	a5,a4,26
    8000445c:	078e                	slli	a5,a5,0x3
    8000445e:	953e                	add	a0,a0,a5
    80004460:	611c                	ld	a5,0(a0)
    80004462:	c395                	beqz	a5,80004486 <argfd+0x64>
    return -1;
  if(pfd)
    80004464:	00090463          	beqz	s2,8000446c <argfd+0x4a>
    *pfd = fd;
    80004468:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000446c:	4501                	li	a0,0
  if(pf)
    8000446e:	c091                	beqz	s1,80004472 <argfd+0x50>
    *pf = f;
    80004470:	e09c                	sd	a5,0(s1)
}
    80004472:	70a2                	ld	ra,40(sp)
    80004474:	7402                	ld	s0,32(sp)
    80004476:	64e2                	ld	s1,24(sp)
    80004478:	6942                	ld	s2,16(sp)
    8000447a:	6145                	addi	sp,sp,48
    8000447c:	8082                	ret
    return -1;
    8000447e:	557d                	li	a0,-1
    80004480:	bfcd                	j	80004472 <argfd+0x50>
    return -1;
    80004482:	557d                	li	a0,-1
    80004484:	b7fd                	j	80004472 <argfd+0x50>
    80004486:	557d                	li	a0,-1
    80004488:	b7ed                	j	80004472 <argfd+0x50>

000000008000448a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000448a:	1101                	addi	sp,sp,-32
    8000448c:	ec06                	sd	ra,24(sp)
    8000448e:	e822                	sd	s0,16(sp)
    80004490:	e426                	sd	s1,8(sp)
    80004492:	1000                	addi	s0,sp,32
    80004494:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004496:	ffffd097          	auipc	ra,0xffffd
    8000449a:	9b2080e7          	jalr	-1614(ra) # 80000e48 <myproc>
    8000449e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800044a0:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd8e90>
    800044a4:	4501                	li	a0,0
    800044a6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800044a8:	6398                	ld	a4,0(a5)
    800044aa:	cb19                	beqz	a4,800044c0 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800044ac:	2505                	addiw	a0,a0,1
    800044ae:	07a1                	addi	a5,a5,8
    800044b0:	fed51ce3          	bne	a0,a3,800044a8 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800044b4:	557d                	li	a0,-1
}
    800044b6:	60e2                	ld	ra,24(sp)
    800044b8:	6442                	ld	s0,16(sp)
    800044ba:	64a2                	ld	s1,8(sp)
    800044bc:	6105                	addi	sp,sp,32
    800044be:	8082                	ret
      p->ofile[fd] = f;
    800044c0:	01a50793          	addi	a5,a0,26
    800044c4:	078e                	slli	a5,a5,0x3
    800044c6:	963e                	add	a2,a2,a5
    800044c8:	e204                	sd	s1,0(a2)
      return fd;
    800044ca:	b7f5                	j	800044b6 <fdalloc+0x2c>

00000000800044cc <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800044cc:	715d                	addi	sp,sp,-80
    800044ce:	e486                	sd	ra,72(sp)
    800044d0:	e0a2                	sd	s0,64(sp)
    800044d2:	fc26                	sd	s1,56(sp)
    800044d4:	f84a                	sd	s2,48(sp)
    800044d6:	f44e                	sd	s3,40(sp)
    800044d8:	f052                	sd	s4,32(sp)
    800044da:	ec56                	sd	s5,24(sp)
    800044dc:	0880                	addi	s0,sp,80
    800044de:	89ae                	mv	s3,a1
    800044e0:	8ab2                	mv	s5,a2
    800044e2:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800044e4:	fb040593          	addi	a1,s0,-80
    800044e8:	fffff097          	auipc	ra,0xfffff
    800044ec:	e86080e7          	jalr	-378(ra) # 8000336e <nameiparent>
    800044f0:	892a                	mv	s2,a0
    800044f2:	12050f63          	beqz	a0,80004630 <create+0x164>
    return 0;

  ilock(dp);
    800044f6:	ffffe097          	auipc	ra,0xffffe
    800044fa:	6a4080e7          	jalr	1700(ra) # 80002b9a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800044fe:	4601                	li	a2,0
    80004500:	fb040593          	addi	a1,s0,-80
    80004504:	854a                	mv	a0,s2
    80004506:	fffff097          	auipc	ra,0xfffff
    8000450a:	b78080e7          	jalr	-1160(ra) # 8000307e <dirlookup>
    8000450e:	84aa                	mv	s1,a0
    80004510:	c921                	beqz	a0,80004560 <create+0x94>
    iunlockput(dp);
    80004512:	854a                	mv	a0,s2
    80004514:	fffff097          	auipc	ra,0xfffff
    80004518:	8e8080e7          	jalr	-1816(ra) # 80002dfc <iunlockput>
    ilock(ip);
    8000451c:	8526                	mv	a0,s1
    8000451e:	ffffe097          	auipc	ra,0xffffe
    80004522:	67c080e7          	jalr	1660(ra) # 80002b9a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004526:	2981                	sext.w	s3,s3
    80004528:	4789                	li	a5,2
    8000452a:	02f99463          	bne	s3,a5,80004552 <create+0x86>
    8000452e:	0444d783          	lhu	a5,68(s1)
    80004532:	37f9                	addiw	a5,a5,-2
    80004534:	17c2                	slli	a5,a5,0x30
    80004536:	93c1                	srli	a5,a5,0x30
    80004538:	4705                	li	a4,1
    8000453a:	00f76c63          	bltu	a4,a5,80004552 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000453e:	8526                	mv	a0,s1
    80004540:	60a6                	ld	ra,72(sp)
    80004542:	6406                	ld	s0,64(sp)
    80004544:	74e2                	ld	s1,56(sp)
    80004546:	7942                	ld	s2,48(sp)
    80004548:	79a2                	ld	s3,40(sp)
    8000454a:	7a02                	ld	s4,32(sp)
    8000454c:	6ae2                	ld	s5,24(sp)
    8000454e:	6161                	addi	sp,sp,80
    80004550:	8082                	ret
    iunlockput(ip);
    80004552:	8526                	mv	a0,s1
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	8a8080e7          	jalr	-1880(ra) # 80002dfc <iunlockput>
    return 0;
    8000455c:	4481                	li	s1,0
    8000455e:	b7c5                	j	8000453e <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004560:	85ce                	mv	a1,s3
    80004562:	00092503          	lw	a0,0(s2)
    80004566:	ffffe097          	auipc	ra,0xffffe
    8000456a:	49c080e7          	jalr	1180(ra) # 80002a02 <ialloc>
    8000456e:	84aa                	mv	s1,a0
    80004570:	c529                	beqz	a0,800045ba <create+0xee>
  ilock(ip);
    80004572:	ffffe097          	auipc	ra,0xffffe
    80004576:	628080e7          	jalr	1576(ra) # 80002b9a <ilock>
  ip->major = major;
    8000457a:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000457e:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004582:	4785                	li	a5,1
    80004584:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004588:	8526                	mv	a0,s1
    8000458a:	ffffe097          	auipc	ra,0xffffe
    8000458e:	546080e7          	jalr	1350(ra) # 80002ad0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004592:	2981                	sext.w	s3,s3
    80004594:	4785                	li	a5,1
    80004596:	02f98a63          	beq	s3,a5,800045ca <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000459a:	40d0                	lw	a2,4(s1)
    8000459c:	fb040593          	addi	a1,s0,-80
    800045a0:	854a                	mv	a0,s2
    800045a2:	fffff097          	auipc	ra,0xfffff
    800045a6:	cec080e7          	jalr	-788(ra) # 8000328e <dirlink>
    800045aa:	06054b63          	bltz	a0,80004620 <create+0x154>
  iunlockput(dp);
    800045ae:	854a                	mv	a0,s2
    800045b0:	fffff097          	auipc	ra,0xfffff
    800045b4:	84c080e7          	jalr	-1972(ra) # 80002dfc <iunlockput>
  return ip;
    800045b8:	b759                	j	8000453e <create+0x72>
    panic("create: ialloc");
    800045ba:	00004517          	auipc	a0,0x4
    800045be:	0ce50513          	addi	a0,a0,206 # 80008688 <syscalls+0x2c0>
    800045c2:	00001097          	auipc	ra,0x1
    800045c6:	686080e7          	jalr	1670(ra) # 80005c48 <panic>
    dp->nlink++;  // for ".."
    800045ca:	04a95783          	lhu	a5,74(s2)
    800045ce:	2785                	addiw	a5,a5,1
    800045d0:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800045d4:	854a                	mv	a0,s2
    800045d6:	ffffe097          	auipc	ra,0xffffe
    800045da:	4fa080e7          	jalr	1274(ra) # 80002ad0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800045de:	40d0                	lw	a2,4(s1)
    800045e0:	00004597          	auipc	a1,0x4
    800045e4:	0b858593          	addi	a1,a1,184 # 80008698 <syscalls+0x2d0>
    800045e8:	8526                	mv	a0,s1
    800045ea:	fffff097          	auipc	ra,0xfffff
    800045ee:	ca4080e7          	jalr	-860(ra) # 8000328e <dirlink>
    800045f2:	00054f63          	bltz	a0,80004610 <create+0x144>
    800045f6:	00492603          	lw	a2,4(s2)
    800045fa:	00004597          	auipc	a1,0x4
    800045fe:	0a658593          	addi	a1,a1,166 # 800086a0 <syscalls+0x2d8>
    80004602:	8526                	mv	a0,s1
    80004604:	fffff097          	auipc	ra,0xfffff
    80004608:	c8a080e7          	jalr	-886(ra) # 8000328e <dirlink>
    8000460c:	f80557e3          	bgez	a0,8000459a <create+0xce>
      panic("create dots");
    80004610:	00004517          	auipc	a0,0x4
    80004614:	09850513          	addi	a0,a0,152 # 800086a8 <syscalls+0x2e0>
    80004618:	00001097          	auipc	ra,0x1
    8000461c:	630080e7          	jalr	1584(ra) # 80005c48 <panic>
    panic("create: dirlink");
    80004620:	00004517          	auipc	a0,0x4
    80004624:	09850513          	addi	a0,a0,152 # 800086b8 <syscalls+0x2f0>
    80004628:	00001097          	auipc	ra,0x1
    8000462c:	620080e7          	jalr	1568(ra) # 80005c48 <panic>
    return 0;
    80004630:	84aa                	mv	s1,a0
    80004632:	b731                	j	8000453e <create+0x72>

0000000080004634 <sys_dup>:
{
    80004634:	7179                	addi	sp,sp,-48
    80004636:	f406                	sd	ra,40(sp)
    80004638:	f022                	sd	s0,32(sp)
    8000463a:	ec26                	sd	s1,24(sp)
    8000463c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000463e:	fd840613          	addi	a2,s0,-40
    80004642:	4581                	li	a1,0
    80004644:	4501                	li	a0,0
    80004646:	00000097          	auipc	ra,0x0
    8000464a:	ddc080e7          	jalr	-548(ra) # 80004422 <argfd>
    return -1;
    8000464e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004650:	02054363          	bltz	a0,80004676 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80004654:	fd843503          	ld	a0,-40(s0)
    80004658:	00000097          	auipc	ra,0x0
    8000465c:	e32080e7          	jalr	-462(ra) # 8000448a <fdalloc>
    80004660:	84aa                	mv	s1,a0
    return -1;
    80004662:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004664:	00054963          	bltz	a0,80004676 <sys_dup+0x42>
  filedup(f);
    80004668:	fd843503          	ld	a0,-40(s0)
    8000466c:	fffff097          	auipc	ra,0xfffff
    80004670:	37a080e7          	jalr	890(ra) # 800039e6 <filedup>
  return fd;
    80004674:	87a6                	mv	a5,s1
}
    80004676:	853e                	mv	a0,a5
    80004678:	70a2                	ld	ra,40(sp)
    8000467a:	7402                	ld	s0,32(sp)
    8000467c:	64e2                	ld	s1,24(sp)
    8000467e:	6145                	addi	sp,sp,48
    80004680:	8082                	ret

0000000080004682 <sys_read>:
{
    80004682:	7179                	addi	sp,sp,-48
    80004684:	f406                	sd	ra,40(sp)
    80004686:	f022                	sd	s0,32(sp)
    80004688:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000468a:	fe840613          	addi	a2,s0,-24
    8000468e:	4581                	li	a1,0
    80004690:	4501                	li	a0,0
    80004692:	00000097          	auipc	ra,0x0
    80004696:	d90080e7          	jalr	-624(ra) # 80004422 <argfd>
    return -1;
    8000469a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000469c:	04054163          	bltz	a0,800046de <sys_read+0x5c>
    800046a0:	fe440593          	addi	a1,s0,-28
    800046a4:	4509                	li	a0,2
    800046a6:	ffffe097          	auipc	ra,0xffffe
    800046aa:	8da080e7          	jalr	-1830(ra) # 80001f80 <argint>
    return -1;
    800046ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046b0:	02054763          	bltz	a0,800046de <sys_read+0x5c>
    800046b4:	fd840593          	addi	a1,s0,-40
    800046b8:	4505                	li	a0,1
    800046ba:	ffffe097          	auipc	ra,0xffffe
    800046be:	8e8080e7          	jalr	-1816(ra) # 80001fa2 <argaddr>
    return -1;
    800046c2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046c4:	00054d63          	bltz	a0,800046de <sys_read+0x5c>
  return fileread(f, p, n);
    800046c8:	fe442603          	lw	a2,-28(s0)
    800046cc:	fd843583          	ld	a1,-40(s0)
    800046d0:	fe843503          	ld	a0,-24(s0)
    800046d4:	fffff097          	auipc	ra,0xfffff
    800046d8:	49e080e7          	jalr	1182(ra) # 80003b72 <fileread>
    800046dc:	87aa                	mv	a5,a0
}
    800046de:	853e                	mv	a0,a5
    800046e0:	70a2                	ld	ra,40(sp)
    800046e2:	7402                	ld	s0,32(sp)
    800046e4:	6145                	addi	sp,sp,48
    800046e6:	8082                	ret

00000000800046e8 <sys_write>:
{
    800046e8:	7179                	addi	sp,sp,-48
    800046ea:	f406                	sd	ra,40(sp)
    800046ec:	f022                	sd	s0,32(sp)
    800046ee:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046f0:	fe840613          	addi	a2,s0,-24
    800046f4:	4581                	li	a1,0
    800046f6:	4501                	li	a0,0
    800046f8:	00000097          	auipc	ra,0x0
    800046fc:	d2a080e7          	jalr	-726(ra) # 80004422 <argfd>
    return -1;
    80004700:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004702:	04054163          	bltz	a0,80004744 <sys_write+0x5c>
    80004706:	fe440593          	addi	a1,s0,-28
    8000470a:	4509                	li	a0,2
    8000470c:	ffffe097          	auipc	ra,0xffffe
    80004710:	874080e7          	jalr	-1932(ra) # 80001f80 <argint>
    return -1;
    80004714:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004716:	02054763          	bltz	a0,80004744 <sys_write+0x5c>
    8000471a:	fd840593          	addi	a1,s0,-40
    8000471e:	4505                	li	a0,1
    80004720:	ffffe097          	auipc	ra,0xffffe
    80004724:	882080e7          	jalr	-1918(ra) # 80001fa2 <argaddr>
    return -1;
    80004728:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000472a:	00054d63          	bltz	a0,80004744 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000472e:	fe442603          	lw	a2,-28(s0)
    80004732:	fd843583          	ld	a1,-40(s0)
    80004736:	fe843503          	ld	a0,-24(s0)
    8000473a:	fffff097          	auipc	ra,0xfffff
    8000473e:	4fa080e7          	jalr	1274(ra) # 80003c34 <filewrite>
    80004742:	87aa                	mv	a5,a0
}
    80004744:	853e                	mv	a0,a5
    80004746:	70a2                	ld	ra,40(sp)
    80004748:	7402                	ld	s0,32(sp)
    8000474a:	6145                	addi	sp,sp,48
    8000474c:	8082                	ret

000000008000474e <sys_close>:
{
    8000474e:	1101                	addi	sp,sp,-32
    80004750:	ec06                	sd	ra,24(sp)
    80004752:	e822                	sd	s0,16(sp)
    80004754:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004756:	fe040613          	addi	a2,s0,-32
    8000475a:	fec40593          	addi	a1,s0,-20
    8000475e:	4501                	li	a0,0
    80004760:	00000097          	auipc	ra,0x0
    80004764:	cc2080e7          	jalr	-830(ra) # 80004422 <argfd>
    return -1;
    80004768:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000476a:	02054463          	bltz	a0,80004792 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	6da080e7          	jalr	1754(ra) # 80000e48 <myproc>
    80004776:	fec42783          	lw	a5,-20(s0)
    8000477a:	07e9                	addi	a5,a5,26
    8000477c:	078e                	slli	a5,a5,0x3
    8000477e:	97aa                	add	a5,a5,a0
    80004780:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004784:	fe043503          	ld	a0,-32(s0)
    80004788:	fffff097          	auipc	ra,0xfffff
    8000478c:	2b0080e7          	jalr	688(ra) # 80003a38 <fileclose>
  return 0;
    80004790:	4781                	li	a5,0
}
    80004792:	853e                	mv	a0,a5
    80004794:	60e2                	ld	ra,24(sp)
    80004796:	6442                	ld	s0,16(sp)
    80004798:	6105                	addi	sp,sp,32
    8000479a:	8082                	ret

000000008000479c <sys_fstat>:
{
    8000479c:	1101                	addi	sp,sp,-32
    8000479e:	ec06                	sd	ra,24(sp)
    800047a0:	e822                	sd	s0,16(sp)
    800047a2:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800047a4:	fe840613          	addi	a2,s0,-24
    800047a8:	4581                	li	a1,0
    800047aa:	4501                	li	a0,0
    800047ac:	00000097          	auipc	ra,0x0
    800047b0:	c76080e7          	jalr	-906(ra) # 80004422 <argfd>
    return -1;
    800047b4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800047b6:	02054563          	bltz	a0,800047e0 <sys_fstat+0x44>
    800047ba:	fe040593          	addi	a1,s0,-32
    800047be:	4505                	li	a0,1
    800047c0:	ffffd097          	auipc	ra,0xffffd
    800047c4:	7e2080e7          	jalr	2018(ra) # 80001fa2 <argaddr>
    return -1;
    800047c8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800047ca:	00054b63          	bltz	a0,800047e0 <sys_fstat+0x44>
  return filestat(f, st);
    800047ce:	fe043583          	ld	a1,-32(s0)
    800047d2:	fe843503          	ld	a0,-24(s0)
    800047d6:	fffff097          	auipc	ra,0xfffff
    800047da:	32a080e7          	jalr	810(ra) # 80003b00 <filestat>
    800047de:	87aa                	mv	a5,a0
}
    800047e0:	853e                	mv	a0,a5
    800047e2:	60e2                	ld	ra,24(sp)
    800047e4:	6442                	ld	s0,16(sp)
    800047e6:	6105                	addi	sp,sp,32
    800047e8:	8082                	ret

00000000800047ea <sys_link>:
{
    800047ea:	7169                	addi	sp,sp,-304
    800047ec:	f606                	sd	ra,296(sp)
    800047ee:	f222                	sd	s0,288(sp)
    800047f0:	ee26                	sd	s1,280(sp)
    800047f2:	ea4a                	sd	s2,272(sp)
    800047f4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800047f6:	08000613          	li	a2,128
    800047fa:	ed040593          	addi	a1,s0,-304
    800047fe:	4501                	li	a0,0
    80004800:	ffffd097          	auipc	ra,0xffffd
    80004804:	7c4080e7          	jalr	1988(ra) # 80001fc4 <argstr>
    return -1;
    80004808:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000480a:	10054e63          	bltz	a0,80004926 <sys_link+0x13c>
    8000480e:	08000613          	li	a2,128
    80004812:	f5040593          	addi	a1,s0,-176
    80004816:	4505                	li	a0,1
    80004818:	ffffd097          	auipc	ra,0xffffd
    8000481c:	7ac080e7          	jalr	1964(ra) # 80001fc4 <argstr>
    return -1;
    80004820:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004822:	10054263          	bltz	a0,80004926 <sys_link+0x13c>
  begin_op();
    80004826:	fffff097          	auipc	ra,0xfffff
    8000482a:	d46080e7          	jalr	-698(ra) # 8000356c <begin_op>
  if((ip = namei(old)) == 0){
    8000482e:	ed040513          	addi	a0,s0,-304
    80004832:	fffff097          	auipc	ra,0xfffff
    80004836:	b1e080e7          	jalr	-1250(ra) # 80003350 <namei>
    8000483a:	84aa                	mv	s1,a0
    8000483c:	c551                	beqz	a0,800048c8 <sys_link+0xde>
  ilock(ip);
    8000483e:	ffffe097          	auipc	ra,0xffffe
    80004842:	35c080e7          	jalr	860(ra) # 80002b9a <ilock>
  if(ip->type == T_DIR){
    80004846:	04449703          	lh	a4,68(s1)
    8000484a:	4785                	li	a5,1
    8000484c:	08f70463          	beq	a4,a5,800048d4 <sys_link+0xea>
  ip->nlink++;
    80004850:	04a4d783          	lhu	a5,74(s1)
    80004854:	2785                	addiw	a5,a5,1
    80004856:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000485a:	8526                	mv	a0,s1
    8000485c:	ffffe097          	auipc	ra,0xffffe
    80004860:	274080e7          	jalr	628(ra) # 80002ad0 <iupdate>
  iunlock(ip);
    80004864:	8526                	mv	a0,s1
    80004866:	ffffe097          	auipc	ra,0xffffe
    8000486a:	3f6080e7          	jalr	1014(ra) # 80002c5c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000486e:	fd040593          	addi	a1,s0,-48
    80004872:	f5040513          	addi	a0,s0,-176
    80004876:	fffff097          	auipc	ra,0xfffff
    8000487a:	af8080e7          	jalr	-1288(ra) # 8000336e <nameiparent>
    8000487e:	892a                	mv	s2,a0
    80004880:	c935                	beqz	a0,800048f4 <sys_link+0x10a>
  ilock(dp);
    80004882:	ffffe097          	auipc	ra,0xffffe
    80004886:	318080e7          	jalr	792(ra) # 80002b9a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000488a:	00092703          	lw	a4,0(s2)
    8000488e:	409c                	lw	a5,0(s1)
    80004890:	04f71d63          	bne	a4,a5,800048ea <sys_link+0x100>
    80004894:	40d0                	lw	a2,4(s1)
    80004896:	fd040593          	addi	a1,s0,-48
    8000489a:	854a                	mv	a0,s2
    8000489c:	fffff097          	auipc	ra,0xfffff
    800048a0:	9f2080e7          	jalr	-1550(ra) # 8000328e <dirlink>
    800048a4:	04054363          	bltz	a0,800048ea <sys_link+0x100>
  iunlockput(dp);
    800048a8:	854a                	mv	a0,s2
    800048aa:	ffffe097          	auipc	ra,0xffffe
    800048ae:	552080e7          	jalr	1362(ra) # 80002dfc <iunlockput>
  iput(ip);
    800048b2:	8526                	mv	a0,s1
    800048b4:	ffffe097          	auipc	ra,0xffffe
    800048b8:	4a0080e7          	jalr	1184(ra) # 80002d54 <iput>
  end_op();
    800048bc:	fffff097          	auipc	ra,0xfffff
    800048c0:	d30080e7          	jalr	-720(ra) # 800035ec <end_op>
  return 0;
    800048c4:	4781                	li	a5,0
    800048c6:	a085                	j	80004926 <sys_link+0x13c>
    end_op();
    800048c8:	fffff097          	auipc	ra,0xfffff
    800048cc:	d24080e7          	jalr	-732(ra) # 800035ec <end_op>
    return -1;
    800048d0:	57fd                	li	a5,-1
    800048d2:	a891                	j	80004926 <sys_link+0x13c>
    iunlockput(ip);
    800048d4:	8526                	mv	a0,s1
    800048d6:	ffffe097          	auipc	ra,0xffffe
    800048da:	526080e7          	jalr	1318(ra) # 80002dfc <iunlockput>
    end_op();
    800048de:	fffff097          	auipc	ra,0xfffff
    800048e2:	d0e080e7          	jalr	-754(ra) # 800035ec <end_op>
    return -1;
    800048e6:	57fd                	li	a5,-1
    800048e8:	a83d                	j	80004926 <sys_link+0x13c>
    iunlockput(dp);
    800048ea:	854a                	mv	a0,s2
    800048ec:	ffffe097          	auipc	ra,0xffffe
    800048f0:	510080e7          	jalr	1296(ra) # 80002dfc <iunlockput>
  ilock(ip);
    800048f4:	8526                	mv	a0,s1
    800048f6:	ffffe097          	auipc	ra,0xffffe
    800048fa:	2a4080e7          	jalr	676(ra) # 80002b9a <ilock>
  ip->nlink--;
    800048fe:	04a4d783          	lhu	a5,74(s1)
    80004902:	37fd                	addiw	a5,a5,-1
    80004904:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004908:	8526                	mv	a0,s1
    8000490a:	ffffe097          	auipc	ra,0xffffe
    8000490e:	1c6080e7          	jalr	454(ra) # 80002ad0 <iupdate>
  iunlockput(ip);
    80004912:	8526                	mv	a0,s1
    80004914:	ffffe097          	auipc	ra,0xffffe
    80004918:	4e8080e7          	jalr	1256(ra) # 80002dfc <iunlockput>
  end_op();
    8000491c:	fffff097          	auipc	ra,0xfffff
    80004920:	cd0080e7          	jalr	-816(ra) # 800035ec <end_op>
  return -1;
    80004924:	57fd                	li	a5,-1
}
    80004926:	853e                	mv	a0,a5
    80004928:	70b2                	ld	ra,296(sp)
    8000492a:	7412                	ld	s0,288(sp)
    8000492c:	64f2                	ld	s1,280(sp)
    8000492e:	6952                	ld	s2,272(sp)
    80004930:	6155                	addi	sp,sp,304
    80004932:	8082                	ret

0000000080004934 <sys_unlink>:
{
    80004934:	7151                	addi	sp,sp,-240
    80004936:	f586                	sd	ra,232(sp)
    80004938:	f1a2                	sd	s0,224(sp)
    8000493a:	eda6                	sd	s1,216(sp)
    8000493c:	e9ca                	sd	s2,208(sp)
    8000493e:	e5ce                	sd	s3,200(sp)
    80004940:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004942:	08000613          	li	a2,128
    80004946:	f3040593          	addi	a1,s0,-208
    8000494a:	4501                	li	a0,0
    8000494c:	ffffd097          	auipc	ra,0xffffd
    80004950:	678080e7          	jalr	1656(ra) # 80001fc4 <argstr>
    80004954:	18054163          	bltz	a0,80004ad6 <sys_unlink+0x1a2>
  begin_op();
    80004958:	fffff097          	auipc	ra,0xfffff
    8000495c:	c14080e7          	jalr	-1004(ra) # 8000356c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004960:	fb040593          	addi	a1,s0,-80
    80004964:	f3040513          	addi	a0,s0,-208
    80004968:	fffff097          	auipc	ra,0xfffff
    8000496c:	a06080e7          	jalr	-1530(ra) # 8000336e <nameiparent>
    80004970:	84aa                	mv	s1,a0
    80004972:	c979                	beqz	a0,80004a48 <sys_unlink+0x114>
  ilock(dp);
    80004974:	ffffe097          	auipc	ra,0xffffe
    80004978:	226080e7          	jalr	550(ra) # 80002b9a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000497c:	00004597          	auipc	a1,0x4
    80004980:	d1c58593          	addi	a1,a1,-740 # 80008698 <syscalls+0x2d0>
    80004984:	fb040513          	addi	a0,s0,-80
    80004988:	ffffe097          	auipc	ra,0xffffe
    8000498c:	6dc080e7          	jalr	1756(ra) # 80003064 <namecmp>
    80004990:	14050a63          	beqz	a0,80004ae4 <sys_unlink+0x1b0>
    80004994:	00004597          	auipc	a1,0x4
    80004998:	d0c58593          	addi	a1,a1,-756 # 800086a0 <syscalls+0x2d8>
    8000499c:	fb040513          	addi	a0,s0,-80
    800049a0:	ffffe097          	auipc	ra,0xffffe
    800049a4:	6c4080e7          	jalr	1732(ra) # 80003064 <namecmp>
    800049a8:	12050e63          	beqz	a0,80004ae4 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800049ac:	f2c40613          	addi	a2,s0,-212
    800049b0:	fb040593          	addi	a1,s0,-80
    800049b4:	8526                	mv	a0,s1
    800049b6:	ffffe097          	auipc	ra,0xffffe
    800049ba:	6c8080e7          	jalr	1736(ra) # 8000307e <dirlookup>
    800049be:	892a                	mv	s2,a0
    800049c0:	12050263          	beqz	a0,80004ae4 <sys_unlink+0x1b0>
  ilock(ip);
    800049c4:	ffffe097          	auipc	ra,0xffffe
    800049c8:	1d6080e7          	jalr	470(ra) # 80002b9a <ilock>
  if(ip->nlink < 1)
    800049cc:	04a91783          	lh	a5,74(s2)
    800049d0:	08f05263          	blez	a5,80004a54 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800049d4:	04491703          	lh	a4,68(s2)
    800049d8:	4785                	li	a5,1
    800049da:	08f70563          	beq	a4,a5,80004a64 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800049de:	4641                	li	a2,16
    800049e0:	4581                	li	a1,0
    800049e2:	fc040513          	addi	a0,s0,-64
    800049e6:	ffffb097          	auipc	ra,0xffffb
    800049ea:	792080e7          	jalr	1938(ra) # 80000178 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800049ee:	4741                	li	a4,16
    800049f0:	f2c42683          	lw	a3,-212(s0)
    800049f4:	fc040613          	addi	a2,s0,-64
    800049f8:	4581                	li	a1,0
    800049fa:	8526                	mv	a0,s1
    800049fc:	ffffe097          	auipc	ra,0xffffe
    80004a00:	54a080e7          	jalr	1354(ra) # 80002f46 <writei>
    80004a04:	47c1                	li	a5,16
    80004a06:	0af51563          	bne	a0,a5,80004ab0 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004a0a:	04491703          	lh	a4,68(s2)
    80004a0e:	4785                	li	a5,1
    80004a10:	0af70863          	beq	a4,a5,80004ac0 <sys_unlink+0x18c>
  iunlockput(dp);
    80004a14:	8526                	mv	a0,s1
    80004a16:	ffffe097          	auipc	ra,0xffffe
    80004a1a:	3e6080e7          	jalr	998(ra) # 80002dfc <iunlockput>
  ip->nlink--;
    80004a1e:	04a95783          	lhu	a5,74(s2)
    80004a22:	37fd                	addiw	a5,a5,-1
    80004a24:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004a28:	854a                	mv	a0,s2
    80004a2a:	ffffe097          	auipc	ra,0xffffe
    80004a2e:	0a6080e7          	jalr	166(ra) # 80002ad0 <iupdate>
  iunlockput(ip);
    80004a32:	854a                	mv	a0,s2
    80004a34:	ffffe097          	auipc	ra,0xffffe
    80004a38:	3c8080e7          	jalr	968(ra) # 80002dfc <iunlockput>
  end_op();
    80004a3c:	fffff097          	auipc	ra,0xfffff
    80004a40:	bb0080e7          	jalr	-1104(ra) # 800035ec <end_op>
  return 0;
    80004a44:	4501                	li	a0,0
    80004a46:	a84d                	j	80004af8 <sys_unlink+0x1c4>
    end_op();
    80004a48:	fffff097          	auipc	ra,0xfffff
    80004a4c:	ba4080e7          	jalr	-1116(ra) # 800035ec <end_op>
    return -1;
    80004a50:	557d                	li	a0,-1
    80004a52:	a05d                	j	80004af8 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004a54:	00004517          	auipc	a0,0x4
    80004a58:	c7450513          	addi	a0,a0,-908 # 800086c8 <syscalls+0x300>
    80004a5c:	00001097          	auipc	ra,0x1
    80004a60:	1ec080e7          	jalr	492(ra) # 80005c48 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004a64:	04c92703          	lw	a4,76(s2)
    80004a68:	02000793          	li	a5,32
    80004a6c:	f6e7f9e3          	bgeu	a5,a4,800049de <sys_unlink+0xaa>
    80004a70:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a74:	4741                	li	a4,16
    80004a76:	86ce                	mv	a3,s3
    80004a78:	f1840613          	addi	a2,s0,-232
    80004a7c:	4581                	li	a1,0
    80004a7e:	854a                	mv	a0,s2
    80004a80:	ffffe097          	auipc	ra,0xffffe
    80004a84:	3ce080e7          	jalr	974(ra) # 80002e4e <readi>
    80004a88:	47c1                	li	a5,16
    80004a8a:	00f51b63          	bne	a0,a5,80004aa0 <sys_unlink+0x16c>
    if(de.inum != 0)
    80004a8e:	f1845783          	lhu	a5,-232(s0)
    80004a92:	e7a1                	bnez	a5,80004ada <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004a94:	29c1                	addiw	s3,s3,16
    80004a96:	04c92783          	lw	a5,76(s2)
    80004a9a:	fcf9ede3          	bltu	s3,a5,80004a74 <sys_unlink+0x140>
    80004a9e:	b781                	j	800049de <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004aa0:	00004517          	auipc	a0,0x4
    80004aa4:	c4050513          	addi	a0,a0,-960 # 800086e0 <syscalls+0x318>
    80004aa8:	00001097          	auipc	ra,0x1
    80004aac:	1a0080e7          	jalr	416(ra) # 80005c48 <panic>
    panic("unlink: writei");
    80004ab0:	00004517          	auipc	a0,0x4
    80004ab4:	c4850513          	addi	a0,a0,-952 # 800086f8 <syscalls+0x330>
    80004ab8:	00001097          	auipc	ra,0x1
    80004abc:	190080e7          	jalr	400(ra) # 80005c48 <panic>
    dp->nlink--;
    80004ac0:	04a4d783          	lhu	a5,74(s1)
    80004ac4:	37fd                	addiw	a5,a5,-1
    80004ac6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004aca:	8526                	mv	a0,s1
    80004acc:	ffffe097          	auipc	ra,0xffffe
    80004ad0:	004080e7          	jalr	4(ra) # 80002ad0 <iupdate>
    80004ad4:	b781                	j	80004a14 <sys_unlink+0xe0>
    return -1;
    80004ad6:	557d                	li	a0,-1
    80004ad8:	a005                	j	80004af8 <sys_unlink+0x1c4>
    iunlockput(ip);
    80004ada:	854a                	mv	a0,s2
    80004adc:	ffffe097          	auipc	ra,0xffffe
    80004ae0:	320080e7          	jalr	800(ra) # 80002dfc <iunlockput>
  iunlockput(dp);
    80004ae4:	8526                	mv	a0,s1
    80004ae6:	ffffe097          	auipc	ra,0xffffe
    80004aea:	316080e7          	jalr	790(ra) # 80002dfc <iunlockput>
  end_op();
    80004aee:	fffff097          	auipc	ra,0xfffff
    80004af2:	afe080e7          	jalr	-1282(ra) # 800035ec <end_op>
  return -1;
    80004af6:	557d                	li	a0,-1
}
    80004af8:	70ae                	ld	ra,232(sp)
    80004afa:	740e                	ld	s0,224(sp)
    80004afc:	64ee                	ld	s1,216(sp)
    80004afe:	694e                	ld	s2,208(sp)
    80004b00:	69ae                	ld	s3,200(sp)
    80004b02:	616d                	addi	sp,sp,240
    80004b04:	8082                	ret

0000000080004b06 <sys_open>:

uint64
sys_open(void)
{
    80004b06:	7131                	addi	sp,sp,-192
    80004b08:	fd06                	sd	ra,184(sp)
    80004b0a:	f922                	sd	s0,176(sp)
    80004b0c:	f526                	sd	s1,168(sp)
    80004b0e:	f14a                	sd	s2,160(sp)
    80004b10:	ed4e                	sd	s3,152(sp)
    80004b12:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004b14:	08000613          	li	a2,128
    80004b18:	f5040593          	addi	a1,s0,-176
    80004b1c:	4501                	li	a0,0
    80004b1e:	ffffd097          	auipc	ra,0xffffd
    80004b22:	4a6080e7          	jalr	1190(ra) # 80001fc4 <argstr>
    return -1;
    80004b26:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004b28:	0c054163          	bltz	a0,80004bea <sys_open+0xe4>
    80004b2c:	f4c40593          	addi	a1,s0,-180
    80004b30:	4505                	li	a0,1
    80004b32:	ffffd097          	auipc	ra,0xffffd
    80004b36:	44e080e7          	jalr	1102(ra) # 80001f80 <argint>
    80004b3a:	0a054863          	bltz	a0,80004bea <sys_open+0xe4>

  begin_op();
    80004b3e:	fffff097          	auipc	ra,0xfffff
    80004b42:	a2e080e7          	jalr	-1490(ra) # 8000356c <begin_op>

  if(omode & O_CREATE){
    80004b46:	f4c42783          	lw	a5,-180(s0)
    80004b4a:	2007f793          	andi	a5,a5,512
    80004b4e:	cbdd                	beqz	a5,80004c04 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004b50:	4681                	li	a3,0
    80004b52:	4601                	li	a2,0
    80004b54:	4589                	li	a1,2
    80004b56:	f5040513          	addi	a0,s0,-176
    80004b5a:	00000097          	auipc	ra,0x0
    80004b5e:	972080e7          	jalr	-1678(ra) # 800044cc <create>
    80004b62:	892a                	mv	s2,a0
    if(ip == 0){
    80004b64:	c959                	beqz	a0,80004bfa <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004b66:	04491703          	lh	a4,68(s2)
    80004b6a:	478d                	li	a5,3
    80004b6c:	00f71763          	bne	a4,a5,80004b7a <sys_open+0x74>
    80004b70:	04695703          	lhu	a4,70(s2)
    80004b74:	47a5                	li	a5,9
    80004b76:	0ce7ec63          	bltu	a5,a4,80004c4e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004b7a:	fffff097          	auipc	ra,0xfffff
    80004b7e:	e02080e7          	jalr	-510(ra) # 8000397c <filealloc>
    80004b82:	89aa                	mv	s3,a0
    80004b84:	10050263          	beqz	a0,80004c88 <sys_open+0x182>
    80004b88:	00000097          	auipc	ra,0x0
    80004b8c:	902080e7          	jalr	-1790(ra) # 8000448a <fdalloc>
    80004b90:	84aa                	mv	s1,a0
    80004b92:	0e054663          	bltz	a0,80004c7e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004b96:	04491703          	lh	a4,68(s2)
    80004b9a:	478d                	li	a5,3
    80004b9c:	0cf70463          	beq	a4,a5,80004c64 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004ba0:	4789                	li	a5,2
    80004ba2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004ba6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004baa:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004bae:	f4c42783          	lw	a5,-180(s0)
    80004bb2:	0017c713          	xori	a4,a5,1
    80004bb6:	8b05                	andi	a4,a4,1
    80004bb8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004bbc:	0037f713          	andi	a4,a5,3
    80004bc0:	00e03733          	snez	a4,a4
    80004bc4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004bc8:	4007f793          	andi	a5,a5,1024
    80004bcc:	c791                	beqz	a5,80004bd8 <sys_open+0xd2>
    80004bce:	04491703          	lh	a4,68(s2)
    80004bd2:	4789                	li	a5,2
    80004bd4:	08f70f63          	beq	a4,a5,80004c72 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004bd8:	854a                	mv	a0,s2
    80004bda:	ffffe097          	auipc	ra,0xffffe
    80004bde:	082080e7          	jalr	130(ra) # 80002c5c <iunlock>
  end_op();
    80004be2:	fffff097          	auipc	ra,0xfffff
    80004be6:	a0a080e7          	jalr	-1526(ra) # 800035ec <end_op>

  return fd;
}
    80004bea:	8526                	mv	a0,s1
    80004bec:	70ea                	ld	ra,184(sp)
    80004bee:	744a                	ld	s0,176(sp)
    80004bf0:	74aa                	ld	s1,168(sp)
    80004bf2:	790a                	ld	s2,160(sp)
    80004bf4:	69ea                	ld	s3,152(sp)
    80004bf6:	6129                	addi	sp,sp,192
    80004bf8:	8082                	ret
      end_op();
    80004bfa:	fffff097          	auipc	ra,0xfffff
    80004bfe:	9f2080e7          	jalr	-1550(ra) # 800035ec <end_op>
      return -1;
    80004c02:	b7e5                	j	80004bea <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004c04:	f5040513          	addi	a0,s0,-176
    80004c08:	ffffe097          	auipc	ra,0xffffe
    80004c0c:	748080e7          	jalr	1864(ra) # 80003350 <namei>
    80004c10:	892a                	mv	s2,a0
    80004c12:	c905                	beqz	a0,80004c42 <sys_open+0x13c>
    ilock(ip);
    80004c14:	ffffe097          	auipc	ra,0xffffe
    80004c18:	f86080e7          	jalr	-122(ra) # 80002b9a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004c1c:	04491703          	lh	a4,68(s2)
    80004c20:	4785                	li	a5,1
    80004c22:	f4f712e3          	bne	a4,a5,80004b66 <sys_open+0x60>
    80004c26:	f4c42783          	lw	a5,-180(s0)
    80004c2a:	dba1                	beqz	a5,80004b7a <sys_open+0x74>
      iunlockput(ip);
    80004c2c:	854a                	mv	a0,s2
    80004c2e:	ffffe097          	auipc	ra,0xffffe
    80004c32:	1ce080e7          	jalr	462(ra) # 80002dfc <iunlockput>
      end_op();
    80004c36:	fffff097          	auipc	ra,0xfffff
    80004c3a:	9b6080e7          	jalr	-1610(ra) # 800035ec <end_op>
      return -1;
    80004c3e:	54fd                	li	s1,-1
    80004c40:	b76d                	j	80004bea <sys_open+0xe4>
      end_op();
    80004c42:	fffff097          	auipc	ra,0xfffff
    80004c46:	9aa080e7          	jalr	-1622(ra) # 800035ec <end_op>
      return -1;
    80004c4a:	54fd                	li	s1,-1
    80004c4c:	bf79                	j	80004bea <sys_open+0xe4>
    iunlockput(ip);
    80004c4e:	854a                	mv	a0,s2
    80004c50:	ffffe097          	auipc	ra,0xffffe
    80004c54:	1ac080e7          	jalr	428(ra) # 80002dfc <iunlockput>
    end_op();
    80004c58:	fffff097          	auipc	ra,0xfffff
    80004c5c:	994080e7          	jalr	-1644(ra) # 800035ec <end_op>
    return -1;
    80004c60:	54fd                	li	s1,-1
    80004c62:	b761                	j	80004bea <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004c64:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004c68:	04691783          	lh	a5,70(s2)
    80004c6c:	02f99223          	sh	a5,36(s3)
    80004c70:	bf2d                	j	80004baa <sys_open+0xa4>
    itrunc(ip);
    80004c72:	854a                	mv	a0,s2
    80004c74:	ffffe097          	auipc	ra,0xffffe
    80004c78:	034080e7          	jalr	52(ra) # 80002ca8 <itrunc>
    80004c7c:	bfb1                	j	80004bd8 <sys_open+0xd2>
      fileclose(f);
    80004c7e:	854e                	mv	a0,s3
    80004c80:	fffff097          	auipc	ra,0xfffff
    80004c84:	db8080e7          	jalr	-584(ra) # 80003a38 <fileclose>
    iunlockput(ip);
    80004c88:	854a                	mv	a0,s2
    80004c8a:	ffffe097          	auipc	ra,0xffffe
    80004c8e:	172080e7          	jalr	370(ra) # 80002dfc <iunlockput>
    end_op();
    80004c92:	fffff097          	auipc	ra,0xfffff
    80004c96:	95a080e7          	jalr	-1702(ra) # 800035ec <end_op>
    return -1;
    80004c9a:	54fd                	li	s1,-1
    80004c9c:	b7b9                	j	80004bea <sys_open+0xe4>

0000000080004c9e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004c9e:	7175                	addi	sp,sp,-144
    80004ca0:	e506                	sd	ra,136(sp)
    80004ca2:	e122                	sd	s0,128(sp)
    80004ca4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004ca6:	fffff097          	auipc	ra,0xfffff
    80004caa:	8c6080e7          	jalr	-1850(ra) # 8000356c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004cae:	08000613          	li	a2,128
    80004cb2:	f7040593          	addi	a1,s0,-144
    80004cb6:	4501                	li	a0,0
    80004cb8:	ffffd097          	auipc	ra,0xffffd
    80004cbc:	30c080e7          	jalr	780(ra) # 80001fc4 <argstr>
    80004cc0:	02054963          	bltz	a0,80004cf2 <sys_mkdir+0x54>
    80004cc4:	4681                	li	a3,0
    80004cc6:	4601                	li	a2,0
    80004cc8:	4585                	li	a1,1
    80004cca:	f7040513          	addi	a0,s0,-144
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	7fe080e7          	jalr	2046(ra) # 800044cc <create>
    80004cd6:	cd11                	beqz	a0,80004cf2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004cd8:	ffffe097          	auipc	ra,0xffffe
    80004cdc:	124080e7          	jalr	292(ra) # 80002dfc <iunlockput>
  end_op();
    80004ce0:	fffff097          	auipc	ra,0xfffff
    80004ce4:	90c080e7          	jalr	-1780(ra) # 800035ec <end_op>
  return 0;
    80004ce8:	4501                	li	a0,0
}
    80004cea:	60aa                	ld	ra,136(sp)
    80004cec:	640a                	ld	s0,128(sp)
    80004cee:	6149                	addi	sp,sp,144
    80004cf0:	8082                	ret
    end_op();
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	8fa080e7          	jalr	-1798(ra) # 800035ec <end_op>
    return -1;
    80004cfa:	557d                	li	a0,-1
    80004cfc:	b7fd                	j	80004cea <sys_mkdir+0x4c>

0000000080004cfe <sys_mknod>:

uint64
sys_mknod(void)
{
    80004cfe:	7135                	addi	sp,sp,-160
    80004d00:	ed06                	sd	ra,152(sp)
    80004d02:	e922                	sd	s0,144(sp)
    80004d04:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004d06:	fffff097          	auipc	ra,0xfffff
    80004d0a:	866080e7          	jalr	-1946(ra) # 8000356c <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004d0e:	08000613          	li	a2,128
    80004d12:	f7040593          	addi	a1,s0,-144
    80004d16:	4501                	li	a0,0
    80004d18:	ffffd097          	auipc	ra,0xffffd
    80004d1c:	2ac080e7          	jalr	684(ra) # 80001fc4 <argstr>
    80004d20:	04054a63          	bltz	a0,80004d74 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80004d24:	f6c40593          	addi	a1,s0,-148
    80004d28:	4505                	li	a0,1
    80004d2a:	ffffd097          	auipc	ra,0xffffd
    80004d2e:	256080e7          	jalr	598(ra) # 80001f80 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004d32:	04054163          	bltz	a0,80004d74 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80004d36:	f6840593          	addi	a1,s0,-152
    80004d3a:	4509                	li	a0,2
    80004d3c:	ffffd097          	auipc	ra,0xffffd
    80004d40:	244080e7          	jalr	580(ra) # 80001f80 <argint>
     argint(1, &major) < 0 ||
    80004d44:	02054863          	bltz	a0,80004d74 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004d48:	f6841683          	lh	a3,-152(s0)
    80004d4c:	f6c41603          	lh	a2,-148(s0)
    80004d50:	458d                	li	a1,3
    80004d52:	f7040513          	addi	a0,s0,-144
    80004d56:	fffff097          	auipc	ra,0xfffff
    80004d5a:	776080e7          	jalr	1910(ra) # 800044cc <create>
     argint(2, &minor) < 0 ||
    80004d5e:	c919                	beqz	a0,80004d74 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004d60:	ffffe097          	auipc	ra,0xffffe
    80004d64:	09c080e7          	jalr	156(ra) # 80002dfc <iunlockput>
  end_op();
    80004d68:	fffff097          	auipc	ra,0xfffff
    80004d6c:	884080e7          	jalr	-1916(ra) # 800035ec <end_op>
  return 0;
    80004d70:	4501                	li	a0,0
    80004d72:	a031                	j	80004d7e <sys_mknod+0x80>
    end_op();
    80004d74:	fffff097          	auipc	ra,0xfffff
    80004d78:	878080e7          	jalr	-1928(ra) # 800035ec <end_op>
    return -1;
    80004d7c:	557d                	li	a0,-1
}
    80004d7e:	60ea                	ld	ra,152(sp)
    80004d80:	644a                	ld	s0,144(sp)
    80004d82:	610d                	addi	sp,sp,160
    80004d84:	8082                	ret

0000000080004d86 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004d86:	7135                	addi	sp,sp,-160
    80004d88:	ed06                	sd	ra,152(sp)
    80004d8a:	e922                	sd	s0,144(sp)
    80004d8c:	e526                	sd	s1,136(sp)
    80004d8e:	e14a                	sd	s2,128(sp)
    80004d90:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	0b6080e7          	jalr	182(ra) # 80000e48 <myproc>
    80004d9a:	892a                	mv	s2,a0
  
  begin_op();
    80004d9c:	ffffe097          	auipc	ra,0xffffe
    80004da0:	7d0080e7          	jalr	2000(ra) # 8000356c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004da4:	08000613          	li	a2,128
    80004da8:	f6040593          	addi	a1,s0,-160
    80004dac:	4501                	li	a0,0
    80004dae:	ffffd097          	auipc	ra,0xffffd
    80004db2:	216080e7          	jalr	534(ra) # 80001fc4 <argstr>
    80004db6:	04054b63          	bltz	a0,80004e0c <sys_chdir+0x86>
    80004dba:	f6040513          	addi	a0,s0,-160
    80004dbe:	ffffe097          	auipc	ra,0xffffe
    80004dc2:	592080e7          	jalr	1426(ra) # 80003350 <namei>
    80004dc6:	84aa                	mv	s1,a0
    80004dc8:	c131                	beqz	a0,80004e0c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80004dca:	ffffe097          	auipc	ra,0xffffe
    80004dce:	dd0080e7          	jalr	-560(ra) # 80002b9a <ilock>
  if(ip->type != T_DIR){
    80004dd2:	04449703          	lh	a4,68(s1)
    80004dd6:	4785                	li	a5,1
    80004dd8:	04f71063          	bne	a4,a5,80004e18 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004ddc:	8526                	mv	a0,s1
    80004dde:	ffffe097          	auipc	ra,0xffffe
    80004de2:	e7e080e7          	jalr	-386(ra) # 80002c5c <iunlock>
  iput(p->cwd);
    80004de6:	15093503          	ld	a0,336(s2)
    80004dea:	ffffe097          	auipc	ra,0xffffe
    80004dee:	f6a080e7          	jalr	-150(ra) # 80002d54 <iput>
  end_op();
    80004df2:	ffffe097          	auipc	ra,0xffffe
    80004df6:	7fa080e7          	jalr	2042(ra) # 800035ec <end_op>
  p->cwd = ip;
    80004dfa:	14993823          	sd	s1,336(s2)
  return 0;
    80004dfe:	4501                	li	a0,0
}
    80004e00:	60ea                	ld	ra,152(sp)
    80004e02:	644a                	ld	s0,144(sp)
    80004e04:	64aa                	ld	s1,136(sp)
    80004e06:	690a                	ld	s2,128(sp)
    80004e08:	610d                	addi	sp,sp,160
    80004e0a:	8082                	ret
    end_op();
    80004e0c:	ffffe097          	auipc	ra,0xffffe
    80004e10:	7e0080e7          	jalr	2016(ra) # 800035ec <end_op>
    return -1;
    80004e14:	557d                	li	a0,-1
    80004e16:	b7ed                	j	80004e00 <sys_chdir+0x7a>
    iunlockput(ip);
    80004e18:	8526                	mv	a0,s1
    80004e1a:	ffffe097          	auipc	ra,0xffffe
    80004e1e:	fe2080e7          	jalr	-30(ra) # 80002dfc <iunlockput>
    end_op();
    80004e22:	ffffe097          	auipc	ra,0xffffe
    80004e26:	7ca080e7          	jalr	1994(ra) # 800035ec <end_op>
    return -1;
    80004e2a:	557d                	li	a0,-1
    80004e2c:	bfd1                	j	80004e00 <sys_chdir+0x7a>

0000000080004e2e <sys_exec>:

uint64
sys_exec(void)
{
    80004e2e:	7145                	addi	sp,sp,-464
    80004e30:	e786                	sd	ra,456(sp)
    80004e32:	e3a2                	sd	s0,448(sp)
    80004e34:	ff26                	sd	s1,440(sp)
    80004e36:	fb4a                	sd	s2,432(sp)
    80004e38:	f74e                	sd	s3,424(sp)
    80004e3a:	f352                	sd	s4,416(sp)
    80004e3c:	ef56                	sd	s5,408(sp)
    80004e3e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004e40:	08000613          	li	a2,128
    80004e44:	f4040593          	addi	a1,s0,-192
    80004e48:	4501                	li	a0,0
    80004e4a:	ffffd097          	auipc	ra,0xffffd
    80004e4e:	17a080e7          	jalr	378(ra) # 80001fc4 <argstr>
    return -1;
    80004e52:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004e54:	0c054a63          	bltz	a0,80004f28 <sys_exec+0xfa>
    80004e58:	e3840593          	addi	a1,s0,-456
    80004e5c:	4505                	li	a0,1
    80004e5e:	ffffd097          	auipc	ra,0xffffd
    80004e62:	144080e7          	jalr	324(ra) # 80001fa2 <argaddr>
    80004e66:	0c054163          	bltz	a0,80004f28 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80004e6a:	10000613          	li	a2,256
    80004e6e:	4581                	li	a1,0
    80004e70:	e4040513          	addi	a0,s0,-448
    80004e74:	ffffb097          	auipc	ra,0xffffb
    80004e78:	304080e7          	jalr	772(ra) # 80000178 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004e7c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004e80:	89a6                	mv	s3,s1
    80004e82:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004e84:	02000a13          	li	s4,32
    80004e88:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004e8c:	00391513          	slli	a0,s2,0x3
    80004e90:	e3040593          	addi	a1,s0,-464
    80004e94:	e3843783          	ld	a5,-456(s0)
    80004e98:	953e                	add	a0,a0,a5
    80004e9a:	ffffd097          	auipc	ra,0xffffd
    80004e9e:	04c080e7          	jalr	76(ra) # 80001ee6 <fetchaddr>
    80004ea2:	02054a63          	bltz	a0,80004ed6 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80004ea6:	e3043783          	ld	a5,-464(s0)
    80004eaa:	c3b9                	beqz	a5,80004ef0 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004eac:	ffffb097          	auipc	ra,0xffffb
    80004eb0:	26c080e7          	jalr	620(ra) # 80000118 <kalloc>
    80004eb4:	85aa                	mv	a1,a0
    80004eb6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004eba:	cd11                	beqz	a0,80004ed6 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004ebc:	6605                	lui	a2,0x1
    80004ebe:	e3043503          	ld	a0,-464(s0)
    80004ec2:	ffffd097          	auipc	ra,0xffffd
    80004ec6:	076080e7          	jalr	118(ra) # 80001f38 <fetchstr>
    80004eca:	00054663          	bltz	a0,80004ed6 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80004ece:	0905                	addi	s2,s2,1
    80004ed0:	09a1                	addi	s3,s3,8
    80004ed2:	fb491be3          	bne	s2,s4,80004e88 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ed6:	10048913          	addi	s2,s1,256
    80004eda:	6088                	ld	a0,0(s1)
    80004edc:	c529                	beqz	a0,80004f26 <sys_exec+0xf8>
    kfree(argv[i]);
    80004ede:	ffffb097          	auipc	ra,0xffffb
    80004ee2:	13e080e7          	jalr	318(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ee6:	04a1                	addi	s1,s1,8
    80004ee8:	ff2499e3          	bne	s1,s2,80004eda <sys_exec+0xac>
  return -1;
    80004eec:	597d                	li	s2,-1
    80004eee:	a82d                	j	80004f28 <sys_exec+0xfa>
      argv[i] = 0;
    80004ef0:	0a8e                	slli	s5,s5,0x3
    80004ef2:	fc040793          	addi	a5,s0,-64
    80004ef6:	9abe                	add	s5,s5,a5
    80004ef8:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004efc:	e4040593          	addi	a1,s0,-448
    80004f00:	f4040513          	addi	a0,s0,-192
    80004f04:	fffff097          	auipc	ra,0xfffff
    80004f08:	194080e7          	jalr	404(ra) # 80004098 <exec>
    80004f0c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f0e:	10048993          	addi	s3,s1,256
    80004f12:	6088                	ld	a0,0(s1)
    80004f14:	c911                	beqz	a0,80004f28 <sys_exec+0xfa>
    kfree(argv[i]);
    80004f16:	ffffb097          	auipc	ra,0xffffb
    80004f1a:	106080e7          	jalr	262(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f1e:	04a1                	addi	s1,s1,8
    80004f20:	ff3499e3          	bne	s1,s3,80004f12 <sys_exec+0xe4>
    80004f24:	a011                	j	80004f28 <sys_exec+0xfa>
  return -1;
    80004f26:	597d                	li	s2,-1
}
    80004f28:	854a                	mv	a0,s2
    80004f2a:	60be                	ld	ra,456(sp)
    80004f2c:	641e                	ld	s0,448(sp)
    80004f2e:	74fa                	ld	s1,440(sp)
    80004f30:	795a                	ld	s2,432(sp)
    80004f32:	79ba                	ld	s3,424(sp)
    80004f34:	7a1a                	ld	s4,416(sp)
    80004f36:	6afa                	ld	s5,408(sp)
    80004f38:	6179                	addi	sp,sp,464
    80004f3a:	8082                	ret

0000000080004f3c <sys_pipe>:

uint64
sys_pipe(void)
{
    80004f3c:	7139                	addi	sp,sp,-64
    80004f3e:	fc06                	sd	ra,56(sp)
    80004f40:	f822                	sd	s0,48(sp)
    80004f42:	f426                	sd	s1,40(sp)
    80004f44:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004f46:	ffffc097          	auipc	ra,0xffffc
    80004f4a:	f02080e7          	jalr	-254(ra) # 80000e48 <myproc>
    80004f4e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80004f50:	fd840593          	addi	a1,s0,-40
    80004f54:	4501                	li	a0,0
    80004f56:	ffffd097          	auipc	ra,0xffffd
    80004f5a:	04c080e7          	jalr	76(ra) # 80001fa2 <argaddr>
    return -1;
    80004f5e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80004f60:	0e054063          	bltz	a0,80005040 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80004f64:	fc840593          	addi	a1,s0,-56
    80004f68:	fd040513          	addi	a0,s0,-48
    80004f6c:	fffff097          	auipc	ra,0xfffff
    80004f70:	dfc080e7          	jalr	-516(ra) # 80003d68 <pipealloc>
    return -1;
    80004f74:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004f76:	0c054563          	bltz	a0,80005040 <sys_pipe+0x104>
  fd0 = -1;
    80004f7a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004f7e:	fd043503          	ld	a0,-48(s0)
    80004f82:	fffff097          	auipc	ra,0xfffff
    80004f86:	508080e7          	jalr	1288(ra) # 8000448a <fdalloc>
    80004f8a:	fca42223          	sw	a0,-60(s0)
    80004f8e:	08054c63          	bltz	a0,80005026 <sys_pipe+0xea>
    80004f92:	fc843503          	ld	a0,-56(s0)
    80004f96:	fffff097          	auipc	ra,0xfffff
    80004f9a:	4f4080e7          	jalr	1268(ra) # 8000448a <fdalloc>
    80004f9e:	fca42023          	sw	a0,-64(s0)
    80004fa2:	06054863          	bltz	a0,80005012 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004fa6:	4691                	li	a3,4
    80004fa8:	fc440613          	addi	a2,s0,-60
    80004fac:	fd843583          	ld	a1,-40(s0)
    80004fb0:	68a8                	ld	a0,80(s1)
    80004fb2:	ffffc097          	auipc	ra,0xffffc
    80004fb6:	b58080e7          	jalr	-1192(ra) # 80000b0a <copyout>
    80004fba:	02054063          	bltz	a0,80004fda <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004fbe:	4691                	li	a3,4
    80004fc0:	fc040613          	addi	a2,s0,-64
    80004fc4:	fd843583          	ld	a1,-40(s0)
    80004fc8:	0591                	addi	a1,a1,4
    80004fca:	68a8                	ld	a0,80(s1)
    80004fcc:	ffffc097          	auipc	ra,0xffffc
    80004fd0:	b3e080e7          	jalr	-1218(ra) # 80000b0a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004fd4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004fd6:	06055563          	bgez	a0,80005040 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80004fda:	fc442783          	lw	a5,-60(s0)
    80004fde:	07e9                	addi	a5,a5,26
    80004fe0:	078e                	slli	a5,a5,0x3
    80004fe2:	97a6                	add	a5,a5,s1
    80004fe4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004fe8:	fc042503          	lw	a0,-64(s0)
    80004fec:	0569                	addi	a0,a0,26
    80004fee:	050e                	slli	a0,a0,0x3
    80004ff0:	9526                	add	a0,a0,s1
    80004ff2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80004ff6:	fd043503          	ld	a0,-48(s0)
    80004ffa:	fffff097          	auipc	ra,0xfffff
    80004ffe:	a3e080e7          	jalr	-1474(ra) # 80003a38 <fileclose>
    fileclose(wf);
    80005002:	fc843503          	ld	a0,-56(s0)
    80005006:	fffff097          	auipc	ra,0xfffff
    8000500a:	a32080e7          	jalr	-1486(ra) # 80003a38 <fileclose>
    return -1;
    8000500e:	57fd                	li	a5,-1
    80005010:	a805                	j	80005040 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005012:	fc442783          	lw	a5,-60(s0)
    80005016:	0007c863          	bltz	a5,80005026 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    8000501a:	01a78513          	addi	a0,a5,26
    8000501e:	050e                	slli	a0,a0,0x3
    80005020:	9526                	add	a0,a0,s1
    80005022:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005026:	fd043503          	ld	a0,-48(s0)
    8000502a:	fffff097          	auipc	ra,0xfffff
    8000502e:	a0e080e7          	jalr	-1522(ra) # 80003a38 <fileclose>
    fileclose(wf);
    80005032:	fc843503          	ld	a0,-56(s0)
    80005036:	fffff097          	auipc	ra,0xfffff
    8000503a:	a02080e7          	jalr	-1534(ra) # 80003a38 <fileclose>
    return -1;
    8000503e:	57fd                	li	a5,-1
}
    80005040:	853e                	mv	a0,a5
    80005042:	70e2                	ld	ra,56(sp)
    80005044:	7442                	ld	s0,48(sp)
    80005046:	74a2                	ld	s1,40(sp)
    80005048:	6121                	addi	sp,sp,64
    8000504a:	8082                	ret
    8000504c:	0000                	unimp
	...

0000000080005050 <kernelvec>:
    80005050:	7111                	addi	sp,sp,-256
    80005052:	e006                	sd	ra,0(sp)
    80005054:	e40a                	sd	sp,8(sp)
    80005056:	e80e                	sd	gp,16(sp)
    80005058:	ec12                	sd	tp,24(sp)
    8000505a:	f016                	sd	t0,32(sp)
    8000505c:	f41a                	sd	t1,40(sp)
    8000505e:	f81e                	sd	t2,48(sp)
    80005060:	fc22                	sd	s0,56(sp)
    80005062:	e0a6                	sd	s1,64(sp)
    80005064:	e4aa                	sd	a0,72(sp)
    80005066:	e8ae                	sd	a1,80(sp)
    80005068:	ecb2                	sd	a2,88(sp)
    8000506a:	f0b6                	sd	a3,96(sp)
    8000506c:	f4ba                	sd	a4,104(sp)
    8000506e:	f8be                	sd	a5,112(sp)
    80005070:	fcc2                	sd	a6,120(sp)
    80005072:	e146                	sd	a7,128(sp)
    80005074:	e54a                	sd	s2,136(sp)
    80005076:	e94e                	sd	s3,144(sp)
    80005078:	ed52                	sd	s4,152(sp)
    8000507a:	f156                	sd	s5,160(sp)
    8000507c:	f55a                	sd	s6,168(sp)
    8000507e:	f95e                	sd	s7,176(sp)
    80005080:	fd62                	sd	s8,184(sp)
    80005082:	e1e6                	sd	s9,192(sp)
    80005084:	e5ea                	sd	s10,200(sp)
    80005086:	e9ee                	sd	s11,208(sp)
    80005088:	edf2                	sd	t3,216(sp)
    8000508a:	f1f6                	sd	t4,224(sp)
    8000508c:	f5fa                	sd	t5,232(sp)
    8000508e:	f9fe                	sd	t6,240(sp)
    80005090:	d23fc0ef          	jal	ra,80001db2 <kerneltrap>
    80005094:	6082                	ld	ra,0(sp)
    80005096:	6122                	ld	sp,8(sp)
    80005098:	61c2                	ld	gp,16(sp)
    8000509a:	7282                	ld	t0,32(sp)
    8000509c:	7322                	ld	t1,40(sp)
    8000509e:	73c2                	ld	t2,48(sp)
    800050a0:	7462                	ld	s0,56(sp)
    800050a2:	6486                	ld	s1,64(sp)
    800050a4:	6526                	ld	a0,72(sp)
    800050a6:	65c6                	ld	a1,80(sp)
    800050a8:	6666                	ld	a2,88(sp)
    800050aa:	7686                	ld	a3,96(sp)
    800050ac:	7726                	ld	a4,104(sp)
    800050ae:	77c6                	ld	a5,112(sp)
    800050b0:	7866                	ld	a6,120(sp)
    800050b2:	688a                	ld	a7,128(sp)
    800050b4:	692a                	ld	s2,136(sp)
    800050b6:	69ca                	ld	s3,144(sp)
    800050b8:	6a6a                	ld	s4,152(sp)
    800050ba:	7a8a                	ld	s5,160(sp)
    800050bc:	7b2a                	ld	s6,168(sp)
    800050be:	7bca                	ld	s7,176(sp)
    800050c0:	7c6a                	ld	s8,184(sp)
    800050c2:	6c8e                	ld	s9,192(sp)
    800050c4:	6d2e                	ld	s10,200(sp)
    800050c6:	6dce                	ld	s11,208(sp)
    800050c8:	6e6e                	ld	t3,216(sp)
    800050ca:	7e8e                	ld	t4,224(sp)
    800050cc:	7f2e                	ld	t5,232(sp)
    800050ce:	7fce                	ld	t6,240(sp)
    800050d0:	6111                	addi	sp,sp,256
    800050d2:	10200073          	sret
    800050d6:	00000013          	nop
    800050da:	00000013          	nop
    800050de:	0001                	nop

00000000800050e0 <timervec>:
    800050e0:	34051573          	csrrw	a0,mscratch,a0
    800050e4:	e10c                	sd	a1,0(a0)
    800050e6:	e510                	sd	a2,8(a0)
    800050e8:	e914                	sd	a3,16(a0)
    800050ea:	6d0c                	ld	a1,24(a0)
    800050ec:	7110                	ld	a2,32(a0)
    800050ee:	6194                	ld	a3,0(a1)
    800050f0:	96b2                	add	a3,a3,a2
    800050f2:	e194                	sd	a3,0(a1)
    800050f4:	4589                	li	a1,2
    800050f6:	14459073          	csrw	sip,a1
    800050fa:	6914                	ld	a3,16(a0)
    800050fc:	6510                	ld	a2,8(a0)
    800050fe:	610c                	ld	a1,0(a0)
    80005100:	34051573          	csrrw	a0,mscratch,a0
    80005104:	30200073          	mret
	...

000000008000510a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000510a:	1141                	addi	sp,sp,-16
    8000510c:	e422                	sd	s0,8(sp)
    8000510e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005110:	0c0007b7          	lui	a5,0xc000
    80005114:	4705                	li	a4,1
    80005116:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005118:	c3d8                	sw	a4,4(a5)
}
    8000511a:	6422                	ld	s0,8(sp)
    8000511c:	0141                	addi	sp,sp,16
    8000511e:	8082                	ret

0000000080005120 <plicinithart>:

void
plicinithart(void)
{
    80005120:	1141                	addi	sp,sp,-16
    80005122:	e406                	sd	ra,8(sp)
    80005124:	e022                	sd	s0,0(sp)
    80005126:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005128:	ffffc097          	auipc	ra,0xffffc
    8000512c:	cf4080e7          	jalr	-780(ra) # 80000e1c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005130:	0085171b          	slliw	a4,a0,0x8
    80005134:	0c0027b7          	lui	a5,0xc002
    80005138:	97ba                	add	a5,a5,a4
    8000513a:	40200713          	li	a4,1026
    8000513e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005142:	00d5151b          	slliw	a0,a0,0xd
    80005146:	0c2017b7          	lui	a5,0xc201
    8000514a:	953e                	add	a0,a0,a5
    8000514c:	00052023          	sw	zero,0(a0)
}
    80005150:	60a2                	ld	ra,8(sp)
    80005152:	6402                	ld	s0,0(sp)
    80005154:	0141                	addi	sp,sp,16
    80005156:	8082                	ret

0000000080005158 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005158:	1141                	addi	sp,sp,-16
    8000515a:	e406                	sd	ra,8(sp)
    8000515c:	e022                	sd	s0,0(sp)
    8000515e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005160:	ffffc097          	auipc	ra,0xffffc
    80005164:	cbc080e7          	jalr	-836(ra) # 80000e1c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005168:	00d5179b          	slliw	a5,a0,0xd
    8000516c:	0c201537          	lui	a0,0xc201
    80005170:	953e                	add	a0,a0,a5
  return irq;
}
    80005172:	4148                	lw	a0,4(a0)
    80005174:	60a2                	ld	ra,8(sp)
    80005176:	6402                	ld	s0,0(sp)
    80005178:	0141                	addi	sp,sp,16
    8000517a:	8082                	ret

000000008000517c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000517c:	1101                	addi	sp,sp,-32
    8000517e:	ec06                	sd	ra,24(sp)
    80005180:	e822                	sd	s0,16(sp)
    80005182:	e426                	sd	s1,8(sp)
    80005184:	1000                	addi	s0,sp,32
    80005186:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005188:	ffffc097          	auipc	ra,0xffffc
    8000518c:	c94080e7          	jalr	-876(ra) # 80000e1c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005190:	00d5151b          	slliw	a0,a0,0xd
    80005194:	0c2017b7          	lui	a5,0xc201
    80005198:	97aa                	add	a5,a5,a0
    8000519a:	c3c4                	sw	s1,4(a5)
}
    8000519c:	60e2                	ld	ra,24(sp)
    8000519e:	6442                	ld	s0,16(sp)
    800051a0:	64a2                	ld	s1,8(sp)
    800051a2:	6105                	addi	sp,sp,32
    800051a4:	8082                	ret

00000000800051a6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800051a6:	1141                	addi	sp,sp,-16
    800051a8:	e406                	sd	ra,8(sp)
    800051aa:	e022                	sd	s0,0(sp)
    800051ac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800051ae:	479d                	li	a5,7
    800051b0:	06a7c963          	blt	a5,a0,80005222 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800051b4:	00016797          	auipc	a5,0x16
    800051b8:	e4c78793          	addi	a5,a5,-436 # 8001b000 <disk>
    800051bc:	00a78733          	add	a4,a5,a0
    800051c0:	6789                	lui	a5,0x2
    800051c2:	97ba                	add	a5,a5,a4
    800051c4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800051c8:	e7ad                	bnez	a5,80005232 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800051ca:	00451793          	slli	a5,a0,0x4
    800051ce:	00018717          	auipc	a4,0x18
    800051d2:	e3270713          	addi	a4,a4,-462 # 8001d000 <disk+0x2000>
    800051d6:	6314                	ld	a3,0(a4)
    800051d8:	96be                	add	a3,a3,a5
    800051da:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800051de:	6314                	ld	a3,0(a4)
    800051e0:	96be                	add	a3,a3,a5
    800051e2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800051e6:	6314                	ld	a3,0(a4)
    800051e8:	96be                	add	a3,a3,a5
    800051ea:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800051ee:	6318                	ld	a4,0(a4)
    800051f0:	97ba                	add	a5,a5,a4
    800051f2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800051f6:	00016797          	auipc	a5,0x16
    800051fa:	e0a78793          	addi	a5,a5,-502 # 8001b000 <disk>
    800051fe:	97aa                	add	a5,a5,a0
    80005200:	6509                	lui	a0,0x2
    80005202:	953e                	add	a0,a0,a5
    80005204:	4785                	li	a5,1
    80005206:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000520a:	00018517          	auipc	a0,0x18
    8000520e:	e0e50513          	addi	a0,a0,-498 # 8001d018 <disk+0x2018>
    80005212:	ffffc097          	auipc	ra,0xffffc
    80005216:	4d4080e7          	jalr	1236(ra) # 800016e6 <wakeup>
}
    8000521a:	60a2                	ld	ra,8(sp)
    8000521c:	6402                	ld	s0,0(sp)
    8000521e:	0141                	addi	sp,sp,16
    80005220:	8082                	ret
    panic("free_desc 1");
    80005222:	00003517          	auipc	a0,0x3
    80005226:	4e650513          	addi	a0,a0,1254 # 80008708 <syscalls+0x340>
    8000522a:	00001097          	auipc	ra,0x1
    8000522e:	a1e080e7          	jalr	-1506(ra) # 80005c48 <panic>
    panic("free_desc 2");
    80005232:	00003517          	auipc	a0,0x3
    80005236:	4e650513          	addi	a0,a0,1254 # 80008718 <syscalls+0x350>
    8000523a:	00001097          	auipc	ra,0x1
    8000523e:	a0e080e7          	jalr	-1522(ra) # 80005c48 <panic>

0000000080005242 <virtio_disk_init>:
{
    80005242:	1101                	addi	sp,sp,-32
    80005244:	ec06                	sd	ra,24(sp)
    80005246:	e822                	sd	s0,16(sp)
    80005248:	e426                	sd	s1,8(sp)
    8000524a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000524c:	00003597          	auipc	a1,0x3
    80005250:	4dc58593          	addi	a1,a1,1244 # 80008728 <syscalls+0x360>
    80005254:	00018517          	auipc	a0,0x18
    80005258:	ed450513          	addi	a0,a0,-300 # 8001d128 <disk+0x2128>
    8000525c:	00001097          	auipc	ra,0x1
    80005260:	f02080e7          	jalr	-254(ra) # 8000615e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005264:	100017b7          	lui	a5,0x10001
    80005268:	4398                	lw	a4,0(a5)
    8000526a:	2701                	sext.w	a4,a4
    8000526c:	747277b7          	lui	a5,0x74727
    80005270:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005274:	0ef71163          	bne	a4,a5,80005356 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005278:	100017b7          	lui	a5,0x10001
    8000527c:	43dc                	lw	a5,4(a5)
    8000527e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005280:	4705                	li	a4,1
    80005282:	0ce79a63          	bne	a5,a4,80005356 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005286:	100017b7          	lui	a5,0x10001
    8000528a:	479c                	lw	a5,8(a5)
    8000528c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000528e:	4709                	li	a4,2
    80005290:	0ce79363          	bne	a5,a4,80005356 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005294:	100017b7          	lui	a5,0x10001
    80005298:	47d8                	lw	a4,12(a5)
    8000529a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000529c:	554d47b7          	lui	a5,0x554d4
    800052a0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800052a4:	0af71963          	bne	a4,a5,80005356 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800052a8:	100017b7          	lui	a5,0x10001
    800052ac:	4705                	li	a4,1
    800052ae:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800052b0:	470d                	li	a4,3
    800052b2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800052b4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800052b6:	c7ffe737          	lui	a4,0xc7ffe
    800052ba:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd851f>
    800052be:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800052c0:	2701                	sext.w	a4,a4
    800052c2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800052c4:	472d                	li	a4,11
    800052c6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800052c8:	473d                	li	a4,15
    800052ca:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800052cc:	6705                	lui	a4,0x1
    800052ce:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800052d0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800052d4:	5bdc                	lw	a5,52(a5)
    800052d6:	2781                	sext.w	a5,a5
  if(max == 0)
    800052d8:	c7d9                	beqz	a5,80005366 <virtio_disk_init+0x124>
  if(max < NUM)
    800052da:	471d                	li	a4,7
    800052dc:	08f77d63          	bgeu	a4,a5,80005376 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800052e0:	100014b7          	lui	s1,0x10001
    800052e4:	47a1                	li	a5,8
    800052e6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800052e8:	6609                	lui	a2,0x2
    800052ea:	4581                	li	a1,0
    800052ec:	00016517          	auipc	a0,0x16
    800052f0:	d1450513          	addi	a0,a0,-748 # 8001b000 <disk>
    800052f4:	ffffb097          	auipc	ra,0xffffb
    800052f8:	e84080e7          	jalr	-380(ra) # 80000178 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800052fc:	00016717          	auipc	a4,0x16
    80005300:	d0470713          	addi	a4,a4,-764 # 8001b000 <disk>
    80005304:	00c75793          	srli	a5,a4,0xc
    80005308:	2781                	sext.w	a5,a5
    8000530a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000530c:	00018797          	auipc	a5,0x18
    80005310:	cf478793          	addi	a5,a5,-780 # 8001d000 <disk+0x2000>
    80005314:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005316:	00016717          	auipc	a4,0x16
    8000531a:	d6a70713          	addi	a4,a4,-662 # 8001b080 <disk+0x80>
    8000531e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005320:	00017717          	auipc	a4,0x17
    80005324:	ce070713          	addi	a4,a4,-800 # 8001c000 <disk+0x1000>
    80005328:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000532a:	4705                	li	a4,1
    8000532c:	00e78c23          	sb	a4,24(a5)
    80005330:	00e78ca3          	sb	a4,25(a5)
    80005334:	00e78d23          	sb	a4,26(a5)
    80005338:	00e78da3          	sb	a4,27(a5)
    8000533c:	00e78e23          	sb	a4,28(a5)
    80005340:	00e78ea3          	sb	a4,29(a5)
    80005344:	00e78f23          	sb	a4,30(a5)
    80005348:	00e78fa3          	sb	a4,31(a5)
}
    8000534c:	60e2                	ld	ra,24(sp)
    8000534e:	6442                	ld	s0,16(sp)
    80005350:	64a2                	ld	s1,8(sp)
    80005352:	6105                	addi	sp,sp,32
    80005354:	8082                	ret
    panic("could not find virtio disk");
    80005356:	00003517          	auipc	a0,0x3
    8000535a:	3e250513          	addi	a0,a0,994 # 80008738 <syscalls+0x370>
    8000535e:	00001097          	auipc	ra,0x1
    80005362:	8ea080e7          	jalr	-1814(ra) # 80005c48 <panic>
    panic("virtio disk has no queue 0");
    80005366:	00003517          	auipc	a0,0x3
    8000536a:	3f250513          	addi	a0,a0,1010 # 80008758 <syscalls+0x390>
    8000536e:	00001097          	auipc	ra,0x1
    80005372:	8da080e7          	jalr	-1830(ra) # 80005c48 <panic>
    panic("virtio disk max queue too short");
    80005376:	00003517          	auipc	a0,0x3
    8000537a:	40250513          	addi	a0,a0,1026 # 80008778 <syscalls+0x3b0>
    8000537e:	00001097          	auipc	ra,0x1
    80005382:	8ca080e7          	jalr	-1846(ra) # 80005c48 <panic>

0000000080005386 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005386:	7159                	addi	sp,sp,-112
    80005388:	f486                	sd	ra,104(sp)
    8000538a:	f0a2                	sd	s0,96(sp)
    8000538c:	eca6                	sd	s1,88(sp)
    8000538e:	e8ca                	sd	s2,80(sp)
    80005390:	e4ce                	sd	s3,72(sp)
    80005392:	e0d2                	sd	s4,64(sp)
    80005394:	fc56                	sd	s5,56(sp)
    80005396:	f85a                	sd	s6,48(sp)
    80005398:	f45e                	sd	s7,40(sp)
    8000539a:	f062                	sd	s8,32(sp)
    8000539c:	ec66                	sd	s9,24(sp)
    8000539e:	e86a                	sd	s10,16(sp)
    800053a0:	1880                	addi	s0,sp,112
    800053a2:	892a                	mv	s2,a0
    800053a4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800053a6:	00c52c83          	lw	s9,12(a0)
    800053aa:	001c9c9b          	slliw	s9,s9,0x1
    800053ae:	1c82                	slli	s9,s9,0x20
    800053b0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800053b4:	00018517          	auipc	a0,0x18
    800053b8:	d7450513          	addi	a0,a0,-652 # 8001d128 <disk+0x2128>
    800053bc:	00001097          	auipc	ra,0x1
    800053c0:	e32080e7          	jalr	-462(ra) # 800061ee <acquire>
  for(int i = 0; i < 3; i++){
    800053c4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800053c6:	4c21                	li	s8,8
      disk.free[i] = 0;
    800053c8:	00016b97          	auipc	s7,0x16
    800053cc:	c38b8b93          	addi	s7,s7,-968 # 8001b000 <disk>
    800053d0:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    800053d2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800053d4:	8a4e                	mv	s4,s3
    800053d6:	a051                	j	8000545a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    800053d8:	00fb86b3          	add	a3,s7,a5
    800053dc:	96da                	add	a3,a3,s6
    800053de:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800053e2:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800053e4:	0207c563          	bltz	a5,8000540e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800053e8:	2485                	addiw	s1,s1,1
    800053ea:	0711                	addi	a4,a4,4
    800053ec:	25548063          	beq	s1,s5,8000562c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    800053f0:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800053f2:	00018697          	auipc	a3,0x18
    800053f6:	c2668693          	addi	a3,a3,-986 # 8001d018 <disk+0x2018>
    800053fa:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800053fc:	0006c583          	lbu	a1,0(a3)
    80005400:	fde1                	bnez	a1,800053d8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005402:	2785                	addiw	a5,a5,1
    80005404:	0685                	addi	a3,a3,1
    80005406:	ff879be3          	bne	a5,s8,800053fc <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000540a:	57fd                	li	a5,-1
    8000540c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000540e:	02905a63          	blez	s1,80005442 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005412:	f9042503          	lw	a0,-112(s0)
    80005416:	00000097          	auipc	ra,0x0
    8000541a:	d90080e7          	jalr	-624(ra) # 800051a6 <free_desc>
      for(int j = 0; j < i; j++)
    8000541e:	4785                	li	a5,1
    80005420:	0297d163          	bge	a5,s1,80005442 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005424:	f9442503          	lw	a0,-108(s0)
    80005428:	00000097          	auipc	ra,0x0
    8000542c:	d7e080e7          	jalr	-642(ra) # 800051a6 <free_desc>
      for(int j = 0; j < i; j++)
    80005430:	4789                	li	a5,2
    80005432:	0097d863          	bge	a5,s1,80005442 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005436:	f9842503          	lw	a0,-104(s0)
    8000543a:	00000097          	auipc	ra,0x0
    8000543e:	d6c080e7          	jalr	-660(ra) # 800051a6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005442:	00018597          	auipc	a1,0x18
    80005446:	ce658593          	addi	a1,a1,-794 # 8001d128 <disk+0x2128>
    8000544a:	00018517          	auipc	a0,0x18
    8000544e:	bce50513          	addi	a0,a0,-1074 # 8001d018 <disk+0x2018>
    80005452:	ffffc097          	auipc	ra,0xffffc
    80005456:	108080e7          	jalr	264(ra) # 8000155a <sleep>
  for(int i = 0; i < 3; i++){
    8000545a:	f9040713          	addi	a4,s0,-112
    8000545e:	84ce                	mv	s1,s3
    80005460:	bf41                	j	800053f0 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005462:	20058713          	addi	a4,a1,512
    80005466:	00471693          	slli	a3,a4,0x4
    8000546a:	00016717          	auipc	a4,0x16
    8000546e:	b9670713          	addi	a4,a4,-1130 # 8001b000 <disk>
    80005472:	9736                	add	a4,a4,a3
    80005474:	4685                	li	a3,1
    80005476:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000547a:	20058713          	addi	a4,a1,512
    8000547e:	00471693          	slli	a3,a4,0x4
    80005482:	00016717          	auipc	a4,0x16
    80005486:	b7e70713          	addi	a4,a4,-1154 # 8001b000 <disk>
    8000548a:	9736                	add	a4,a4,a3
    8000548c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80005490:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005494:	7679                	lui	a2,0xffffe
    80005496:	963e                	add	a2,a2,a5
    80005498:	00018697          	auipc	a3,0x18
    8000549c:	b6868693          	addi	a3,a3,-1176 # 8001d000 <disk+0x2000>
    800054a0:	6298                	ld	a4,0(a3)
    800054a2:	9732                	add	a4,a4,a2
    800054a4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800054a6:	6298                	ld	a4,0(a3)
    800054a8:	9732                	add	a4,a4,a2
    800054aa:	4541                	li	a0,16
    800054ac:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800054ae:	6298                	ld	a4,0(a3)
    800054b0:	9732                	add	a4,a4,a2
    800054b2:	4505                	li	a0,1
    800054b4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800054b8:	f9442703          	lw	a4,-108(s0)
    800054bc:	6288                	ld	a0,0(a3)
    800054be:	962a                	add	a2,a2,a0
    800054c0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd7dce>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800054c4:	0712                	slli	a4,a4,0x4
    800054c6:	6290                	ld	a2,0(a3)
    800054c8:	963a                	add	a2,a2,a4
    800054ca:	05890513          	addi	a0,s2,88
    800054ce:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800054d0:	6294                	ld	a3,0(a3)
    800054d2:	96ba                	add	a3,a3,a4
    800054d4:	40000613          	li	a2,1024
    800054d8:	c690                	sw	a2,8(a3)
  if(write)
    800054da:	140d0063          	beqz	s10,8000561a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800054de:	00018697          	auipc	a3,0x18
    800054e2:	b226b683          	ld	a3,-1246(a3) # 8001d000 <disk+0x2000>
    800054e6:	96ba                	add	a3,a3,a4
    800054e8:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800054ec:	00016817          	auipc	a6,0x16
    800054f0:	b1480813          	addi	a6,a6,-1260 # 8001b000 <disk>
    800054f4:	00018517          	auipc	a0,0x18
    800054f8:	b0c50513          	addi	a0,a0,-1268 # 8001d000 <disk+0x2000>
    800054fc:	6114                	ld	a3,0(a0)
    800054fe:	96ba                	add	a3,a3,a4
    80005500:	00c6d603          	lhu	a2,12(a3)
    80005504:	00166613          	ori	a2,a2,1
    80005508:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000550c:	f9842683          	lw	a3,-104(s0)
    80005510:	6110                	ld	a2,0(a0)
    80005512:	9732                	add	a4,a4,a2
    80005514:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005518:	20058613          	addi	a2,a1,512
    8000551c:	0612                	slli	a2,a2,0x4
    8000551e:	9642                	add	a2,a2,a6
    80005520:	577d                	li	a4,-1
    80005522:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005526:	00469713          	slli	a4,a3,0x4
    8000552a:	6114                	ld	a3,0(a0)
    8000552c:	96ba                	add	a3,a3,a4
    8000552e:	03078793          	addi	a5,a5,48
    80005532:	97c2                	add	a5,a5,a6
    80005534:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80005536:	611c                	ld	a5,0(a0)
    80005538:	97ba                	add	a5,a5,a4
    8000553a:	4685                	li	a3,1
    8000553c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000553e:	611c                	ld	a5,0(a0)
    80005540:	97ba                	add	a5,a5,a4
    80005542:	4809                	li	a6,2
    80005544:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80005548:	611c                	ld	a5,0(a0)
    8000554a:	973e                	add	a4,a4,a5
    8000554c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005550:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80005554:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005558:	6518                	ld	a4,8(a0)
    8000555a:	00275783          	lhu	a5,2(a4)
    8000555e:	8b9d                	andi	a5,a5,7
    80005560:	0786                	slli	a5,a5,0x1
    80005562:	97ba                	add	a5,a5,a4
    80005564:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005568:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000556c:	6518                	ld	a4,8(a0)
    8000556e:	00275783          	lhu	a5,2(a4)
    80005572:	2785                	addiw	a5,a5,1
    80005574:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005578:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000557c:	100017b7          	lui	a5,0x10001
    80005580:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005584:	00492703          	lw	a4,4(s2)
    80005588:	4785                	li	a5,1
    8000558a:	02f71163          	bne	a4,a5,800055ac <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000558e:	00018997          	auipc	s3,0x18
    80005592:	b9a98993          	addi	s3,s3,-1126 # 8001d128 <disk+0x2128>
  while(b->disk == 1) {
    80005596:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005598:	85ce                	mv	a1,s3
    8000559a:	854a                	mv	a0,s2
    8000559c:	ffffc097          	auipc	ra,0xffffc
    800055a0:	fbe080e7          	jalr	-66(ra) # 8000155a <sleep>
  while(b->disk == 1) {
    800055a4:	00492783          	lw	a5,4(s2)
    800055a8:	fe9788e3          	beq	a5,s1,80005598 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800055ac:	f9042903          	lw	s2,-112(s0)
    800055b0:	20090793          	addi	a5,s2,512
    800055b4:	00479713          	slli	a4,a5,0x4
    800055b8:	00016797          	auipc	a5,0x16
    800055bc:	a4878793          	addi	a5,a5,-1464 # 8001b000 <disk>
    800055c0:	97ba                	add	a5,a5,a4
    800055c2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800055c6:	00018997          	auipc	s3,0x18
    800055ca:	a3a98993          	addi	s3,s3,-1478 # 8001d000 <disk+0x2000>
    800055ce:	00491713          	slli	a4,s2,0x4
    800055d2:	0009b783          	ld	a5,0(s3)
    800055d6:	97ba                	add	a5,a5,a4
    800055d8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800055dc:	854a                	mv	a0,s2
    800055de:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800055e2:	00000097          	auipc	ra,0x0
    800055e6:	bc4080e7          	jalr	-1084(ra) # 800051a6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800055ea:	8885                	andi	s1,s1,1
    800055ec:	f0ed                	bnez	s1,800055ce <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800055ee:	00018517          	auipc	a0,0x18
    800055f2:	b3a50513          	addi	a0,a0,-1222 # 8001d128 <disk+0x2128>
    800055f6:	00001097          	auipc	ra,0x1
    800055fa:	cac080e7          	jalr	-852(ra) # 800062a2 <release>
}
    800055fe:	70a6                	ld	ra,104(sp)
    80005600:	7406                	ld	s0,96(sp)
    80005602:	64e6                	ld	s1,88(sp)
    80005604:	6946                	ld	s2,80(sp)
    80005606:	69a6                	ld	s3,72(sp)
    80005608:	6a06                	ld	s4,64(sp)
    8000560a:	7ae2                	ld	s5,56(sp)
    8000560c:	7b42                	ld	s6,48(sp)
    8000560e:	7ba2                	ld	s7,40(sp)
    80005610:	7c02                	ld	s8,32(sp)
    80005612:	6ce2                	ld	s9,24(sp)
    80005614:	6d42                	ld	s10,16(sp)
    80005616:	6165                	addi	sp,sp,112
    80005618:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000561a:	00018697          	auipc	a3,0x18
    8000561e:	9e66b683          	ld	a3,-1562(a3) # 8001d000 <disk+0x2000>
    80005622:	96ba                	add	a3,a3,a4
    80005624:	4609                	li	a2,2
    80005626:	00c69623          	sh	a2,12(a3)
    8000562a:	b5c9                	j	800054ec <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000562c:	f9042583          	lw	a1,-112(s0)
    80005630:	20058793          	addi	a5,a1,512
    80005634:	0792                	slli	a5,a5,0x4
    80005636:	00016517          	auipc	a0,0x16
    8000563a:	a7250513          	addi	a0,a0,-1422 # 8001b0a8 <disk+0xa8>
    8000563e:	953e                	add	a0,a0,a5
  if(write)
    80005640:	e20d11e3          	bnez	s10,80005462 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80005644:	20058713          	addi	a4,a1,512
    80005648:	00471693          	slli	a3,a4,0x4
    8000564c:	00016717          	auipc	a4,0x16
    80005650:	9b470713          	addi	a4,a4,-1612 # 8001b000 <disk>
    80005654:	9736                	add	a4,a4,a3
    80005656:	0a072423          	sw	zero,168(a4)
    8000565a:	b505                	j	8000547a <virtio_disk_rw+0xf4>

000000008000565c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000565c:	1101                	addi	sp,sp,-32
    8000565e:	ec06                	sd	ra,24(sp)
    80005660:	e822                	sd	s0,16(sp)
    80005662:	e426                	sd	s1,8(sp)
    80005664:	e04a                	sd	s2,0(sp)
    80005666:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005668:	00018517          	auipc	a0,0x18
    8000566c:	ac050513          	addi	a0,a0,-1344 # 8001d128 <disk+0x2128>
    80005670:	00001097          	auipc	ra,0x1
    80005674:	b7e080e7          	jalr	-1154(ra) # 800061ee <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005678:	10001737          	lui	a4,0x10001
    8000567c:	533c                	lw	a5,96(a4)
    8000567e:	8b8d                	andi	a5,a5,3
    80005680:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005682:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005686:	00018797          	auipc	a5,0x18
    8000568a:	97a78793          	addi	a5,a5,-1670 # 8001d000 <disk+0x2000>
    8000568e:	6b94                	ld	a3,16(a5)
    80005690:	0207d703          	lhu	a4,32(a5)
    80005694:	0026d783          	lhu	a5,2(a3)
    80005698:	06f70163          	beq	a4,a5,800056fa <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000569c:	00016917          	auipc	s2,0x16
    800056a0:	96490913          	addi	s2,s2,-1692 # 8001b000 <disk>
    800056a4:	00018497          	auipc	s1,0x18
    800056a8:	95c48493          	addi	s1,s1,-1700 # 8001d000 <disk+0x2000>
    __sync_synchronize();
    800056ac:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800056b0:	6898                	ld	a4,16(s1)
    800056b2:	0204d783          	lhu	a5,32(s1)
    800056b6:	8b9d                	andi	a5,a5,7
    800056b8:	078e                	slli	a5,a5,0x3
    800056ba:	97ba                	add	a5,a5,a4
    800056bc:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800056be:	20078713          	addi	a4,a5,512
    800056c2:	0712                	slli	a4,a4,0x4
    800056c4:	974a                	add	a4,a4,s2
    800056c6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800056ca:	e731                	bnez	a4,80005716 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800056cc:	20078793          	addi	a5,a5,512
    800056d0:	0792                	slli	a5,a5,0x4
    800056d2:	97ca                	add	a5,a5,s2
    800056d4:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800056d6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800056da:	ffffc097          	auipc	ra,0xffffc
    800056de:	00c080e7          	jalr	12(ra) # 800016e6 <wakeup>

    disk.used_idx += 1;
    800056e2:	0204d783          	lhu	a5,32(s1)
    800056e6:	2785                	addiw	a5,a5,1
    800056e8:	17c2                	slli	a5,a5,0x30
    800056ea:	93c1                	srli	a5,a5,0x30
    800056ec:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800056f0:	6898                	ld	a4,16(s1)
    800056f2:	00275703          	lhu	a4,2(a4)
    800056f6:	faf71be3          	bne	a4,a5,800056ac <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800056fa:	00018517          	auipc	a0,0x18
    800056fe:	a2e50513          	addi	a0,a0,-1490 # 8001d128 <disk+0x2128>
    80005702:	00001097          	auipc	ra,0x1
    80005706:	ba0080e7          	jalr	-1120(ra) # 800062a2 <release>
}
    8000570a:	60e2                	ld	ra,24(sp)
    8000570c:	6442                	ld	s0,16(sp)
    8000570e:	64a2                	ld	s1,8(sp)
    80005710:	6902                	ld	s2,0(sp)
    80005712:	6105                	addi	sp,sp,32
    80005714:	8082                	ret
      panic("virtio_disk_intr status");
    80005716:	00003517          	auipc	a0,0x3
    8000571a:	08250513          	addi	a0,a0,130 # 80008798 <syscalls+0x3d0>
    8000571e:	00000097          	auipc	ra,0x0
    80005722:	52a080e7          	jalr	1322(ra) # 80005c48 <panic>

0000000080005726 <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    80005726:	1141                	addi	sp,sp,-16
    80005728:	e422                	sd	s0,8(sp)
    8000572a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    8000572c:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80005730:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80005734:	0037979b          	slliw	a5,a5,0x3
    80005738:	02004737          	lui	a4,0x2004
    8000573c:	97ba                	add	a5,a5,a4
    8000573e:	0200c737          	lui	a4,0x200c
    80005742:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80005746:	000f4637          	lui	a2,0xf4
    8000574a:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    8000574e:	95b2                	add	a1,a1,a2
    80005750:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80005752:	00269713          	slli	a4,a3,0x2
    80005756:	9736                	add	a4,a4,a3
    80005758:	00371693          	slli	a3,a4,0x3
    8000575c:	00019717          	auipc	a4,0x19
    80005760:	8a470713          	addi	a4,a4,-1884 # 8001e000 <timer_scratch>
    80005764:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80005766:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    80005768:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000576a:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000576e:	00000797          	auipc	a5,0x0
    80005772:	97278793          	addi	a5,a5,-1678 # 800050e0 <timervec>
    80005776:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000577a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000577e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005782:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80005786:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000578a:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000578e:	30479073          	csrw	mie,a5
}
    80005792:	6422                	ld	s0,8(sp)
    80005794:	0141                	addi	sp,sp,16
    80005796:	8082                	ret

0000000080005798 <start>:
{
    80005798:	1141                	addi	sp,sp,-16
    8000579a:	e406                	sd	ra,8(sp)
    8000579c:	e022                	sd	s0,0(sp)
    8000579e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800057a0:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    800057a4:	7779                	lui	a4,0xffffe
    800057a6:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd85bf>
    800057aa:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800057ac:	6705                	lui	a4,0x1
    800057ae:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800057b2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800057b4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800057b8:	ffffb797          	auipc	a5,0xffffb
    800057bc:	b6e78793          	addi	a5,a5,-1170 # 80000326 <main>
    800057c0:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800057c4:	4781                	li	a5,0
    800057c6:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800057ca:	67c1                	lui	a5,0x10
    800057cc:	17fd                	addi	a5,a5,-1
    800057ce:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800057d2:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800057d6:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800057da:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800057de:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800057e2:	57fd                	li	a5,-1
    800057e4:	83a9                	srli	a5,a5,0xa
    800057e6:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800057ea:	47bd                	li	a5,15
    800057ec:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800057f0:	00000097          	auipc	ra,0x0
    800057f4:	f36080e7          	jalr	-202(ra) # 80005726 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800057f8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800057fc:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    800057fe:	823e                	mv	tp,a5
  asm volatile("mret");
    80005800:	30200073          	mret
}
    80005804:	60a2                	ld	ra,8(sp)
    80005806:	6402                	ld	s0,0(sp)
    80005808:	0141                	addi	sp,sp,16
    8000580a:	8082                	ret

000000008000580c <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    8000580c:	715d                	addi	sp,sp,-80
    8000580e:	e486                	sd	ra,72(sp)
    80005810:	e0a2                	sd	s0,64(sp)
    80005812:	fc26                	sd	s1,56(sp)
    80005814:	f84a                	sd	s2,48(sp)
    80005816:	f44e                	sd	s3,40(sp)
    80005818:	f052                	sd	s4,32(sp)
    8000581a:	ec56                	sd	s5,24(sp)
    8000581c:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000581e:	04c05663          	blez	a2,8000586a <consolewrite+0x5e>
    80005822:	8a2a                	mv	s4,a0
    80005824:	84ae                	mv	s1,a1
    80005826:	89b2                	mv	s3,a2
    80005828:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000582a:	5afd                	li	s5,-1
    8000582c:	4685                	li	a3,1
    8000582e:	8626                	mv	a2,s1
    80005830:	85d2                	mv	a1,s4
    80005832:	fbf40513          	addi	a0,s0,-65
    80005836:	ffffc097          	auipc	ra,0xffffc
    8000583a:	11e080e7          	jalr	286(ra) # 80001954 <either_copyin>
    8000583e:	01550c63          	beq	a0,s5,80005856 <consolewrite+0x4a>
      break;
    uartputc(c);
    80005842:	fbf44503          	lbu	a0,-65(s0)
    80005846:	00000097          	auipc	ra,0x0
    8000584a:	7ea080e7          	jalr	2026(ra) # 80006030 <uartputc>
  for(i = 0; i < n; i++){
    8000584e:	2905                	addiw	s2,s2,1
    80005850:	0485                	addi	s1,s1,1
    80005852:	fd299de3          	bne	s3,s2,8000582c <consolewrite+0x20>
  }

  return i;
}
    80005856:	854a                	mv	a0,s2
    80005858:	60a6                	ld	ra,72(sp)
    8000585a:	6406                	ld	s0,64(sp)
    8000585c:	74e2                	ld	s1,56(sp)
    8000585e:	7942                	ld	s2,48(sp)
    80005860:	79a2                	ld	s3,40(sp)
    80005862:	7a02                	ld	s4,32(sp)
    80005864:	6ae2                	ld	s5,24(sp)
    80005866:	6161                	addi	sp,sp,80
    80005868:	8082                	ret
  for(i = 0; i < n; i++){
    8000586a:	4901                	li	s2,0
    8000586c:	b7ed                	j	80005856 <consolewrite+0x4a>

000000008000586e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000586e:	7119                	addi	sp,sp,-128
    80005870:	fc86                	sd	ra,120(sp)
    80005872:	f8a2                	sd	s0,112(sp)
    80005874:	f4a6                	sd	s1,104(sp)
    80005876:	f0ca                	sd	s2,96(sp)
    80005878:	ecce                	sd	s3,88(sp)
    8000587a:	e8d2                	sd	s4,80(sp)
    8000587c:	e4d6                	sd	s5,72(sp)
    8000587e:	e0da                	sd	s6,64(sp)
    80005880:	fc5e                	sd	s7,56(sp)
    80005882:	f862                	sd	s8,48(sp)
    80005884:	f466                	sd	s9,40(sp)
    80005886:	f06a                	sd	s10,32(sp)
    80005888:	ec6e                	sd	s11,24(sp)
    8000588a:	0100                	addi	s0,sp,128
    8000588c:	8b2a                	mv	s6,a0
    8000588e:	8aae                	mv	s5,a1
    80005890:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005892:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80005896:	00021517          	auipc	a0,0x21
    8000589a:	8aa50513          	addi	a0,a0,-1878 # 80026140 <cons>
    8000589e:	00001097          	auipc	ra,0x1
    800058a2:	950080e7          	jalr	-1712(ra) # 800061ee <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800058a6:	00021497          	auipc	s1,0x21
    800058aa:	89a48493          	addi	s1,s1,-1894 # 80026140 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800058ae:	89a6                	mv	s3,s1
    800058b0:	00021917          	auipc	s2,0x21
    800058b4:	92890913          	addi	s2,s2,-1752 # 800261d8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800058b8:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800058ba:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800058bc:	4da9                	li	s11,10
  while(n > 0){
    800058be:	07405863          	blez	s4,8000592e <consoleread+0xc0>
    while(cons.r == cons.w){
    800058c2:	0984a783          	lw	a5,152(s1)
    800058c6:	09c4a703          	lw	a4,156(s1)
    800058ca:	02f71463          	bne	a4,a5,800058f2 <consoleread+0x84>
      if(myproc()->killed){
    800058ce:	ffffb097          	auipc	ra,0xffffb
    800058d2:	57a080e7          	jalr	1402(ra) # 80000e48 <myproc>
    800058d6:	551c                	lw	a5,40(a0)
    800058d8:	e7b5                	bnez	a5,80005944 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800058da:	85ce                	mv	a1,s3
    800058dc:	854a                	mv	a0,s2
    800058de:	ffffc097          	auipc	ra,0xffffc
    800058e2:	c7c080e7          	jalr	-900(ra) # 8000155a <sleep>
    while(cons.r == cons.w){
    800058e6:	0984a783          	lw	a5,152(s1)
    800058ea:	09c4a703          	lw	a4,156(s1)
    800058ee:	fef700e3          	beq	a4,a5,800058ce <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800058f2:	0017871b          	addiw	a4,a5,1
    800058f6:	08e4ac23          	sw	a4,152(s1)
    800058fa:	07f7f713          	andi	a4,a5,127
    800058fe:	9726                	add	a4,a4,s1
    80005900:	01874703          	lbu	a4,24(a4)
    80005904:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80005908:	079c0663          	beq	s8,s9,80005974 <consoleread+0x106>
    cbuf = c;
    8000590c:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005910:	4685                	li	a3,1
    80005912:	f8f40613          	addi	a2,s0,-113
    80005916:	85d6                	mv	a1,s5
    80005918:	855a                	mv	a0,s6
    8000591a:	ffffc097          	auipc	ra,0xffffc
    8000591e:	fe4080e7          	jalr	-28(ra) # 800018fe <either_copyout>
    80005922:	01a50663          	beq	a0,s10,8000592e <consoleread+0xc0>
    dst++;
    80005926:	0a85                	addi	s5,s5,1
    --n;
    80005928:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000592a:	f9bc1ae3          	bne	s8,s11,800058be <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000592e:	00021517          	auipc	a0,0x21
    80005932:	81250513          	addi	a0,a0,-2030 # 80026140 <cons>
    80005936:	00001097          	auipc	ra,0x1
    8000593a:	96c080e7          	jalr	-1684(ra) # 800062a2 <release>

  return target - n;
    8000593e:	414b853b          	subw	a0,s7,s4
    80005942:	a811                	j	80005956 <consoleread+0xe8>
        release(&cons.lock);
    80005944:	00020517          	auipc	a0,0x20
    80005948:	7fc50513          	addi	a0,a0,2044 # 80026140 <cons>
    8000594c:	00001097          	auipc	ra,0x1
    80005950:	956080e7          	jalr	-1706(ra) # 800062a2 <release>
        return -1;
    80005954:	557d                	li	a0,-1
}
    80005956:	70e6                	ld	ra,120(sp)
    80005958:	7446                	ld	s0,112(sp)
    8000595a:	74a6                	ld	s1,104(sp)
    8000595c:	7906                	ld	s2,96(sp)
    8000595e:	69e6                	ld	s3,88(sp)
    80005960:	6a46                	ld	s4,80(sp)
    80005962:	6aa6                	ld	s5,72(sp)
    80005964:	6b06                	ld	s6,64(sp)
    80005966:	7be2                	ld	s7,56(sp)
    80005968:	7c42                	ld	s8,48(sp)
    8000596a:	7ca2                	ld	s9,40(sp)
    8000596c:	7d02                	ld	s10,32(sp)
    8000596e:	6de2                	ld	s11,24(sp)
    80005970:	6109                	addi	sp,sp,128
    80005972:	8082                	ret
      if(n < target){
    80005974:	000a071b          	sext.w	a4,s4
    80005978:	fb777be3          	bgeu	a4,s7,8000592e <consoleread+0xc0>
        cons.r--;
    8000597c:	00021717          	auipc	a4,0x21
    80005980:	84f72e23          	sw	a5,-1956(a4) # 800261d8 <cons+0x98>
    80005984:	b76d                	j	8000592e <consoleread+0xc0>

0000000080005986 <consputc>:
{
    80005986:	1141                	addi	sp,sp,-16
    80005988:	e406                	sd	ra,8(sp)
    8000598a:	e022                	sd	s0,0(sp)
    8000598c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000598e:	10000793          	li	a5,256
    80005992:	00f50a63          	beq	a0,a5,800059a6 <consputc+0x20>
    uartputc_sync(c);
    80005996:	00000097          	auipc	ra,0x0
    8000599a:	5c0080e7          	jalr	1472(ra) # 80005f56 <uartputc_sync>
}
    8000599e:	60a2                	ld	ra,8(sp)
    800059a0:	6402                	ld	s0,0(sp)
    800059a2:	0141                	addi	sp,sp,16
    800059a4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800059a6:	4521                	li	a0,8
    800059a8:	00000097          	auipc	ra,0x0
    800059ac:	5ae080e7          	jalr	1454(ra) # 80005f56 <uartputc_sync>
    800059b0:	02000513          	li	a0,32
    800059b4:	00000097          	auipc	ra,0x0
    800059b8:	5a2080e7          	jalr	1442(ra) # 80005f56 <uartputc_sync>
    800059bc:	4521                	li	a0,8
    800059be:	00000097          	auipc	ra,0x0
    800059c2:	598080e7          	jalr	1432(ra) # 80005f56 <uartputc_sync>
    800059c6:	bfe1                	j	8000599e <consputc+0x18>

00000000800059c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800059c8:	1101                	addi	sp,sp,-32
    800059ca:	ec06                	sd	ra,24(sp)
    800059cc:	e822                	sd	s0,16(sp)
    800059ce:	e426                	sd	s1,8(sp)
    800059d0:	e04a                	sd	s2,0(sp)
    800059d2:	1000                	addi	s0,sp,32
    800059d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800059d6:	00020517          	auipc	a0,0x20
    800059da:	76a50513          	addi	a0,a0,1898 # 80026140 <cons>
    800059de:	00001097          	auipc	ra,0x1
    800059e2:	810080e7          	jalr	-2032(ra) # 800061ee <acquire>

  switch(c){
    800059e6:	47d5                	li	a5,21
    800059e8:	0af48663          	beq	s1,a5,80005a94 <consoleintr+0xcc>
    800059ec:	0297ca63          	blt	a5,s1,80005a20 <consoleintr+0x58>
    800059f0:	47a1                	li	a5,8
    800059f2:	0ef48763          	beq	s1,a5,80005ae0 <consoleintr+0x118>
    800059f6:	47c1                	li	a5,16
    800059f8:	10f49a63          	bne	s1,a5,80005b0c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800059fc:	ffffc097          	auipc	ra,0xffffc
    80005a00:	fae080e7          	jalr	-82(ra) # 800019aa <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005a04:	00020517          	auipc	a0,0x20
    80005a08:	73c50513          	addi	a0,a0,1852 # 80026140 <cons>
    80005a0c:	00001097          	auipc	ra,0x1
    80005a10:	896080e7          	jalr	-1898(ra) # 800062a2 <release>
}
    80005a14:	60e2                	ld	ra,24(sp)
    80005a16:	6442                	ld	s0,16(sp)
    80005a18:	64a2                	ld	s1,8(sp)
    80005a1a:	6902                	ld	s2,0(sp)
    80005a1c:	6105                	addi	sp,sp,32
    80005a1e:	8082                	ret
  switch(c){
    80005a20:	07f00793          	li	a5,127
    80005a24:	0af48e63          	beq	s1,a5,80005ae0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80005a28:	00020717          	auipc	a4,0x20
    80005a2c:	71870713          	addi	a4,a4,1816 # 80026140 <cons>
    80005a30:	0a072783          	lw	a5,160(a4)
    80005a34:	09872703          	lw	a4,152(a4)
    80005a38:	9f99                	subw	a5,a5,a4
    80005a3a:	07f00713          	li	a4,127
    80005a3e:	fcf763e3          	bltu	a4,a5,80005a04 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005a42:	47b5                	li	a5,13
    80005a44:	0cf48763          	beq	s1,a5,80005b12 <consoleintr+0x14a>
      consputc(c);
    80005a48:	8526                	mv	a0,s1
    80005a4a:	00000097          	auipc	ra,0x0
    80005a4e:	f3c080e7          	jalr	-196(ra) # 80005986 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005a52:	00020797          	auipc	a5,0x20
    80005a56:	6ee78793          	addi	a5,a5,1774 # 80026140 <cons>
    80005a5a:	0a07a703          	lw	a4,160(a5)
    80005a5e:	0017069b          	addiw	a3,a4,1
    80005a62:	0006861b          	sext.w	a2,a3
    80005a66:	0ad7a023          	sw	a3,160(a5)
    80005a6a:	07f77713          	andi	a4,a4,127
    80005a6e:	97ba                	add	a5,a5,a4
    80005a70:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80005a74:	47a9                	li	a5,10
    80005a76:	0cf48563          	beq	s1,a5,80005b40 <consoleintr+0x178>
    80005a7a:	4791                	li	a5,4
    80005a7c:	0cf48263          	beq	s1,a5,80005b40 <consoleintr+0x178>
    80005a80:	00020797          	auipc	a5,0x20
    80005a84:	7587a783          	lw	a5,1880(a5) # 800261d8 <cons+0x98>
    80005a88:	0807879b          	addiw	a5,a5,128
    80005a8c:	f6f61ce3          	bne	a2,a5,80005a04 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005a90:	863e                	mv	a2,a5
    80005a92:	a07d                	j	80005b40 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005a94:	00020717          	auipc	a4,0x20
    80005a98:	6ac70713          	addi	a4,a4,1708 # 80026140 <cons>
    80005a9c:	0a072783          	lw	a5,160(a4)
    80005aa0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80005aa4:	00020497          	auipc	s1,0x20
    80005aa8:	69c48493          	addi	s1,s1,1692 # 80026140 <cons>
    while(cons.e != cons.w &&
    80005aac:	4929                	li	s2,10
    80005aae:	f4f70be3          	beq	a4,a5,80005a04 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80005ab2:	37fd                	addiw	a5,a5,-1
    80005ab4:	07f7f713          	andi	a4,a5,127
    80005ab8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005aba:	01874703          	lbu	a4,24(a4)
    80005abe:	f52703e3          	beq	a4,s2,80005a04 <consoleintr+0x3c>
      cons.e--;
    80005ac2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005ac6:	10000513          	li	a0,256
    80005aca:	00000097          	auipc	ra,0x0
    80005ace:	ebc080e7          	jalr	-324(ra) # 80005986 <consputc>
    while(cons.e != cons.w &&
    80005ad2:	0a04a783          	lw	a5,160(s1)
    80005ad6:	09c4a703          	lw	a4,156(s1)
    80005ada:	fcf71ce3          	bne	a4,a5,80005ab2 <consoleintr+0xea>
    80005ade:	b71d                	j	80005a04 <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005ae0:	00020717          	auipc	a4,0x20
    80005ae4:	66070713          	addi	a4,a4,1632 # 80026140 <cons>
    80005ae8:	0a072783          	lw	a5,160(a4)
    80005aec:	09c72703          	lw	a4,156(a4)
    80005af0:	f0f70ae3          	beq	a4,a5,80005a04 <consoleintr+0x3c>
      cons.e--;
    80005af4:	37fd                	addiw	a5,a5,-1
    80005af6:	00020717          	auipc	a4,0x20
    80005afa:	6ef72523          	sw	a5,1770(a4) # 800261e0 <cons+0xa0>
      consputc(BACKSPACE);
    80005afe:	10000513          	li	a0,256
    80005b02:	00000097          	auipc	ra,0x0
    80005b06:	e84080e7          	jalr	-380(ra) # 80005986 <consputc>
    80005b0a:	bded                	j	80005a04 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80005b0c:	ee048ce3          	beqz	s1,80005a04 <consoleintr+0x3c>
    80005b10:	bf21                	j	80005a28 <consoleintr+0x60>
      consputc(c);
    80005b12:	4529                	li	a0,10
    80005b14:	00000097          	auipc	ra,0x0
    80005b18:	e72080e7          	jalr	-398(ra) # 80005986 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005b1c:	00020797          	auipc	a5,0x20
    80005b20:	62478793          	addi	a5,a5,1572 # 80026140 <cons>
    80005b24:	0a07a703          	lw	a4,160(a5)
    80005b28:	0017069b          	addiw	a3,a4,1
    80005b2c:	0006861b          	sext.w	a2,a3
    80005b30:	0ad7a023          	sw	a3,160(a5)
    80005b34:	07f77713          	andi	a4,a4,127
    80005b38:	97ba                	add	a5,a5,a4
    80005b3a:	4729                	li	a4,10
    80005b3c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005b40:	00020797          	auipc	a5,0x20
    80005b44:	68c7ae23          	sw	a2,1692(a5) # 800261dc <cons+0x9c>
        wakeup(&cons.r);
    80005b48:	00020517          	auipc	a0,0x20
    80005b4c:	69050513          	addi	a0,a0,1680 # 800261d8 <cons+0x98>
    80005b50:	ffffc097          	auipc	ra,0xffffc
    80005b54:	b96080e7          	jalr	-1130(ra) # 800016e6 <wakeup>
    80005b58:	b575                	j	80005a04 <consoleintr+0x3c>

0000000080005b5a <consoleinit>:

void
consoleinit(void)
{
    80005b5a:	1141                	addi	sp,sp,-16
    80005b5c:	e406                	sd	ra,8(sp)
    80005b5e:	e022                	sd	s0,0(sp)
    80005b60:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005b62:	00003597          	auipc	a1,0x3
    80005b66:	c4e58593          	addi	a1,a1,-946 # 800087b0 <syscalls+0x3e8>
    80005b6a:	00020517          	auipc	a0,0x20
    80005b6e:	5d650513          	addi	a0,a0,1494 # 80026140 <cons>
    80005b72:	00000097          	auipc	ra,0x0
    80005b76:	5ec080e7          	jalr	1516(ra) # 8000615e <initlock>

  uartinit();
    80005b7a:	00000097          	auipc	ra,0x0
    80005b7e:	38c080e7          	jalr	908(ra) # 80005f06 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005b82:	00014797          	auipc	a5,0x14
    80005b86:	f4678793          	addi	a5,a5,-186 # 80019ac8 <devsw>
    80005b8a:	00000717          	auipc	a4,0x0
    80005b8e:	ce470713          	addi	a4,a4,-796 # 8000586e <consoleread>
    80005b92:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005b94:	00000717          	auipc	a4,0x0
    80005b98:	c7870713          	addi	a4,a4,-904 # 8000580c <consolewrite>
    80005b9c:	ef98                	sd	a4,24(a5)
}
    80005b9e:	60a2                	ld	ra,8(sp)
    80005ba0:	6402                	ld	s0,0(sp)
    80005ba2:	0141                	addi	sp,sp,16
    80005ba4:	8082                	ret

0000000080005ba6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005ba6:	7179                	addi	sp,sp,-48
    80005ba8:	f406                	sd	ra,40(sp)
    80005baa:	f022                	sd	s0,32(sp)
    80005bac:	ec26                	sd	s1,24(sp)
    80005bae:	e84a                	sd	s2,16(sp)
    80005bb0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005bb2:	c219                	beqz	a2,80005bb8 <printint+0x12>
    80005bb4:	08054663          	bltz	a0,80005c40 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    80005bb8:	2501                	sext.w	a0,a0
    80005bba:	4881                	li	a7,0
    80005bbc:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005bc0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005bc2:	2581                	sext.w	a1,a1
    80005bc4:	00003617          	auipc	a2,0x3
    80005bc8:	c3460613          	addi	a2,a2,-972 # 800087f8 <digits>
    80005bcc:	883a                	mv	a6,a4
    80005bce:	2705                	addiw	a4,a4,1
    80005bd0:	02b577bb          	remuw	a5,a0,a1
    80005bd4:	1782                	slli	a5,a5,0x20
    80005bd6:	9381                	srli	a5,a5,0x20
    80005bd8:	97b2                	add	a5,a5,a2
    80005bda:	0007c783          	lbu	a5,0(a5)
    80005bde:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005be2:	0005079b          	sext.w	a5,a0
    80005be6:	02b5553b          	divuw	a0,a0,a1
    80005bea:	0685                	addi	a3,a3,1
    80005bec:	feb7f0e3          	bgeu	a5,a1,80005bcc <printint+0x26>

  if(sign)
    80005bf0:	00088b63          	beqz	a7,80005c06 <printint+0x60>
    buf[i++] = '-';
    80005bf4:	fe040793          	addi	a5,s0,-32
    80005bf8:	973e                	add	a4,a4,a5
    80005bfa:	02d00793          	li	a5,45
    80005bfe:	fef70823          	sb	a5,-16(a4)
    80005c02:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005c06:	02e05763          	blez	a4,80005c34 <printint+0x8e>
    80005c0a:	fd040793          	addi	a5,s0,-48
    80005c0e:	00e784b3          	add	s1,a5,a4
    80005c12:	fff78913          	addi	s2,a5,-1
    80005c16:	993a                	add	s2,s2,a4
    80005c18:	377d                	addiw	a4,a4,-1
    80005c1a:	1702                	slli	a4,a4,0x20
    80005c1c:	9301                	srli	a4,a4,0x20
    80005c1e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005c22:	fff4c503          	lbu	a0,-1(s1)
    80005c26:	00000097          	auipc	ra,0x0
    80005c2a:	d60080e7          	jalr	-672(ra) # 80005986 <consputc>
  while(--i >= 0)
    80005c2e:	14fd                	addi	s1,s1,-1
    80005c30:	ff2499e3          	bne	s1,s2,80005c22 <printint+0x7c>
}
    80005c34:	70a2                	ld	ra,40(sp)
    80005c36:	7402                	ld	s0,32(sp)
    80005c38:	64e2                	ld	s1,24(sp)
    80005c3a:	6942                	ld	s2,16(sp)
    80005c3c:	6145                	addi	sp,sp,48
    80005c3e:	8082                	ret
    x = -xx;
    80005c40:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005c44:	4885                	li	a7,1
    x = -xx;
    80005c46:	bf9d                	j	80005bbc <printint+0x16>

0000000080005c48 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005c48:	1101                	addi	sp,sp,-32
    80005c4a:	ec06                	sd	ra,24(sp)
    80005c4c:	e822                	sd	s0,16(sp)
    80005c4e:	e426                	sd	s1,8(sp)
    80005c50:	1000                	addi	s0,sp,32
    80005c52:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005c54:	00020797          	auipc	a5,0x20
    80005c58:	5a07a623          	sw	zero,1452(a5) # 80026200 <pr+0x18>
  printf("panic: ");
    80005c5c:	00003517          	auipc	a0,0x3
    80005c60:	b5c50513          	addi	a0,a0,-1188 # 800087b8 <syscalls+0x3f0>
    80005c64:	00000097          	auipc	ra,0x0
    80005c68:	02e080e7          	jalr	46(ra) # 80005c92 <printf>
  printf(s);
    80005c6c:	8526                	mv	a0,s1
    80005c6e:	00000097          	auipc	ra,0x0
    80005c72:	024080e7          	jalr	36(ra) # 80005c92 <printf>
  printf("\n");
    80005c76:	00002517          	auipc	a0,0x2
    80005c7a:	3d250513          	addi	a0,a0,978 # 80008048 <etext+0x48>
    80005c7e:	00000097          	auipc	ra,0x0
    80005c82:	014080e7          	jalr	20(ra) # 80005c92 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005c86:	4785                	li	a5,1
    80005c88:	00003717          	auipc	a4,0x3
    80005c8c:	38f72a23          	sw	a5,916(a4) # 8000901c <panicked>
  for(;;)
    80005c90:	a001                	j	80005c90 <panic+0x48>

0000000080005c92 <printf>:
{
    80005c92:	7131                	addi	sp,sp,-192
    80005c94:	fc86                	sd	ra,120(sp)
    80005c96:	f8a2                	sd	s0,112(sp)
    80005c98:	f4a6                	sd	s1,104(sp)
    80005c9a:	f0ca                	sd	s2,96(sp)
    80005c9c:	ecce                	sd	s3,88(sp)
    80005c9e:	e8d2                	sd	s4,80(sp)
    80005ca0:	e4d6                	sd	s5,72(sp)
    80005ca2:	e0da                	sd	s6,64(sp)
    80005ca4:	fc5e                	sd	s7,56(sp)
    80005ca6:	f862                	sd	s8,48(sp)
    80005ca8:	f466                	sd	s9,40(sp)
    80005caa:	f06a                	sd	s10,32(sp)
    80005cac:	ec6e                	sd	s11,24(sp)
    80005cae:	0100                	addi	s0,sp,128
    80005cb0:	8a2a                	mv	s4,a0
    80005cb2:	e40c                	sd	a1,8(s0)
    80005cb4:	e810                	sd	a2,16(s0)
    80005cb6:	ec14                	sd	a3,24(s0)
    80005cb8:	f018                	sd	a4,32(s0)
    80005cba:	f41c                	sd	a5,40(s0)
    80005cbc:	03043823          	sd	a6,48(s0)
    80005cc0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005cc4:	00020d97          	auipc	s11,0x20
    80005cc8:	53cdad83          	lw	s11,1340(s11) # 80026200 <pr+0x18>
  if(locking)
    80005ccc:	020d9b63          	bnez	s11,80005d02 <printf+0x70>
  if (fmt == 0)
    80005cd0:	040a0263          	beqz	s4,80005d14 <printf+0x82>
  va_start(ap, fmt);
    80005cd4:	00840793          	addi	a5,s0,8
    80005cd8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005cdc:	000a4503          	lbu	a0,0(s4)
    80005ce0:	16050263          	beqz	a0,80005e44 <printf+0x1b2>
    80005ce4:	4481                	li	s1,0
    if(c != '%'){
    80005ce6:	02500a93          	li	s5,37
    switch(c){
    80005cea:	07000b13          	li	s6,112
  consputc('x');
    80005cee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005cf0:	00003b97          	auipc	s7,0x3
    80005cf4:	b08b8b93          	addi	s7,s7,-1272 # 800087f8 <digits>
    switch(c){
    80005cf8:	07300c93          	li	s9,115
    80005cfc:	06400c13          	li	s8,100
    80005d00:	a82d                	j	80005d3a <printf+0xa8>
    acquire(&pr.lock);
    80005d02:	00020517          	auipc	a0,0x20
    80005d06:	4e650513          	addi	a0,a0,1254 # 800261e8 <pr>
    80005d0a:	00000097          	auipc	ra,0x0
    80005d0e:	4e4080e7          	jalr	1252(ra) # 800061ee <acquire>
    80005d12:	bf7d                	j	80005cd0 <printf+0x3e>
    panic("null fmt");
    80005d14:	00003517          	auipc	a0,0x3
    80005d18:	ab450513          	addi	a0,a0,-1356 # 800087c8 <syscalls+0x400>
    80005d1c:	00000097          	auipc	ra,0x0
    80005d20:	f2c080e7          	jalr	-212(ra) # 80005c48 <panic>
      consputc(c);
    80005d24:	00000097          	auipc	ra,0x0
    80005d28:	c62080e7          	jalr	-926(ra) # 80005986 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005d2c:	2485                	addiw	s1,s1,1
    80005d2e:	009a07b3          	add	a5,s4,s1
    80005d32:	0007c503          	lbu	a0,0(a5)
    80005d36:	10050763          	beqz	a0,80005e44 <printf+0x1b2>
    if(c != '%'){
    80005d3a:	ff5515e3          	bne	a0,s5,80005d24 <printf+0x92>
    c = fmt[++i] & 0xff;
    80005d3e:	2485                	addiw	s1,s1,1
    80005d40:	009a07b3          	add	a5,s4,s1
    80005d44:	0007c783          	lbu	a5,0(a5)
    80005d48:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80005d4c:	cfe5                	beqz	a5,80005e44 <printf+0x1b2>
    switch(c){
    80005d4e:	05678a63          	beq	a5,s6,80005da2 <printf+0x110>
    80005d52:	02fb7663          	bgeu	s6,a5,80005d7e <printf+0xec>
    80005d56:	09978963          	beq	a5,s9,80005de8 <printf+0x156>
    80005d5a:	07800713          	li	a4,120
    80005d5e:	0ce79863          	bne	a5,a4,80005e2e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80005d62:	f8843783          	ld	a5,-120(s0)
    80005d66:	00878713          	addi	a4,a5,8
    80005d6a:	f8e43423          	sd	a4,-120(s0)
    80005d6e:	4605                	li	a2,1
    80005d70:	85ea                	mv	a1,s10
    80005d72:	4388                	lw	a0,0(a5)
    80005d74:	00000097          	auipc	ra,0x0
    80005d78:	e32080e7          	jalr	-462(ra) # 80005ba6 <printint>
      break;
    80005d7c:	bf45                	j	80005d2c <printf+0x9a>
    switch(c){
    80005d7e:	0b578263          	beq	a5,s5,80005e22 <printf+0x190>
    80005d82:	0b879663          	bne	a5,s8,80005e2e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80005d86:	f8843783          	ld	a5,-120(s0)
    80005d8a:	00878713          	addi	a4,a5,8
    80005d8e:	f8e43423          	sd	a4,-120(s0)
    80005d92:	4605                	li	a2,1
    80005d94:	45a9                	li	a1,10
    80005d96:	4388                	lw	a0,0(a5)
    80005d98:	00000097          	auipc	ra,0x0
    80005d9c:	e0e080e7          	jalr	-498(ra) # 80005ba6 <printint>
      break;
    80005da0:	b771                	j	80005d2c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80005da2:	f8843783          	ld	a5,-120(s0)
    80005da6:	00878713          	addi	a4,a5,8
    80005daa:	f8e43423          	sd	a4,-120(s0)
    80005dae:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005db2:	03000513          	li	a0,48
    80005db6:	00000097          	auipc	ra,0x0
    80005dba:	bd0080e7          	jalr	-1072(ra) # 80005986 <consputc>
  consputc('x');
    80005dbe:	07800513          	li	a0,120
    80005dc2:	00000097          	auipc	ra,0x0
    80005dc6:	bc4080e7          	jalr	-1084(ra) # 80005986 <consputc>
    80005dca:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005dcc:	03c9d793          	srli	a5,s3,0x3c
    80005dd0:	97de                	add	a5,a5,s7
    80005dd2:	0007c503          	lbu	a0,0(a5)
    80005dd6:	00000097          	auipc	ra,0x0
    80005dda:	bb0080e7          	jalr	-1104(ra) # 80005986 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005dde:	0992                	slli	s3,s3,0x4
    80005de0:	397d                	addiw	s2,s2,-1
    80005de2:	fe0915e3          	bnez	s2,80005dcc <printf+0x13a>
    80005de6:	b799                	j	80005d2c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80005de8:	f8843783          	ld	a5,-120(s0)
    80005dec:	00878713          	addi	a4,a5,8
    80005df0:	f8e43423          	sd	a4,-120(s0)
    80005df4:	0007b903          	ld	s2,0(a5)
    80005df8:	00090e63          	beqz	s2,80005e14 <printf+0x182>
      for(; *s; s++)
    80005dfc:	00094503          	lbu	a0,0(s2)
    80005e00:	d515                	beqz	a0,80005d2c <printf+0x9a>
        consputc(*s);
    80005e02:	00000097          	auipc	ra,0x0
    80005e06:	b84080e7          	jalr	-1148(ra) # 80005986 <consputc>
      for(; *s; s++)
    80005e0a:	0905                	addi	s2,s2,1
    80005e0c:	00094503          	lbu	a0,0(s2)
    80005e10:	f96d                	bnez	a0,80005e02 <printf+0x170>
    80005e12:	bf29                	j	80005d2c <printf+0x9a>
        s = "(null)";
    80005e14:	00003917          	auipc	s2,0x3
    80005e18:	9ac90913          	addi	s2,s2,-1620 # 800087c0 <syscalls+0x3f8>
      for(; *s; s++)
    80005e1c:	02800513          	li	a0,40
    80005e20:	b7cd                	j	80005e02 <printf+0x170>
      consputc('%');
    80005e22:	8556                	mv	a0,s5
    80005e24:	00000097          	auipc	ra,0x0
    80005e28:	b62080e7          	jalr	-1182(ra) # 80005986 <consputc>
      break;
    80005e2c:	b701                	j	80005d2c <printf+0x9a>
      consputc('%');
    80005e2e:	8556                	mv	a0,s5
    80005e30:	00000097          	auipc	ra,0x0
    80005e34:	b56080e7          	jalr	-1194(ra) # 80005986 <consputc>
      consputc(c);
    80005e38:	854a                	mv	a0,s2
    80005e3a:	00000097          	auipc	ra,0x0
    80005e3e:	b4c080e7          	jalr	-1204(ra) # 80005986 <consputc>
      break;
    80005e42:	b5ed                	j	80005d2c <printf+0x9a>
  if(locking)
    80005e44:	020d9163          	bnez	s11,80005e66 <printf+0x1d4>
}
    80005e48:	70e6                	ld	ra,120(sp)
    80005e4a:	7446                	ld	s0,112(sp)
    80005e4c:	74a6                	ld	s1,104(sp)
    80005e4e:	7906                	ld	s2,96(sp)
    80005e50:	69e6                	ld	s3,88(sp)
    80005e52:	6a46                	ld	s4,80(sp)
    80005e54:	6aa6                	ld	s5,72(sp)
    80005e56:	6b06                	ld	s6,64(sp)
    80005e58:	7be2                	ld	s7,56(sp)
    80005e5a:	7c42                	ld	s8,48(sp)
    80005e5c:	7ca2                	ld	s9,40(sp)
    80005e5e:	7d02                	ld	s10,32(sp)
    80005e60:	6de2                	ld	s11,24(sp)
    80005e62:	6129                	addi	sp,sp,192
    80005e64:	8082                	ret
    release(&pr.lock);
    80005e66:	00020517          	auipc	a0,0x20
    80005e6a:	38250513          	addi	a0,a0,898 # 800261e8 <pr>
    80005e6e:	00000097          	auipc	ra,0x0
    80005e72:	434080e7          	jalr	1076(ra) # 800062a2 <release>
}
    80005e76:	bfc9                	j	80005e48 <printf+0x1b6>

0000000080005e78 <printfinit>:
    ;
}

void
printfinit(void)
{
    80005e78:	1101                	addi	sp,sp,-32
    80005e7a:	ec06                	sd	ra,24(sp)
    80005e7c:	e822                	sd	s0,16(sp)
    80005e7e:	e426                	sd	s1,8(sp)
    80005e80:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005e82:	00020497          	auipc	s1,0x20
    80005e86:	36648493          	addi	s1,s1,870 # 800261e8 <pr>
    80005e8a:	00003597          	auipc	a1,0x3
    80005e8e:	94e58593          	addi	a1,a1,-1714 # 800087d8 <syscalls+0x410>
    80005e92:	8526                	mv	a0,s1
    80005e94:	00000097          	auipc	ra,0x0
    80005e98:	2ca080e7          	jalr	714(ra) # 8000615e <initlock>
  pr.locking = 1;
    80005e9c:	4785                	li	a5,1
    80005e9e:	cc9c                	sw	a5,24(s1)
}
    80005ea0:	60e2                	ld	ra,24(sp)
    80005ea2:	6442                	ld	s0,16(sp)
    80005ea4:	64a2                	ld	s1,8(sp)
    80005ea6:	6105                	addi	sp,sp,32
    80005ea8:	8082                	ret

0000000080005eaa <backtrace>:

void
backtrace(void)
{
    80005eaa:	7179                	addi	sp,sp,-48
    80005eac:	f406                	sd	ra,40(sp)
    80005eae:	f022                	sd	s0,32(sp)
    80005eb0:	ec26                	sd	s1,24(sp)
    80005eb2:	e84a                	sd	s2,16(sp)
    80005eb4:	e44e                	sd	s3,8(sp)
    80005eb6:	1800                	addi	s0,sp,48
    printf("backtrace:\n");
    80005eb8:	00003517          	auipc	a0,0x3
    80005ebc:	92850513          	addi	a0,a0,-1752 # 800087e0 <syscalls+0x418>
    80005ec0:	00000097          	auipc	ra,0x0
    80005ec4:	dd2080e7          	jalr	-558(ra) # 80005c92 <printf>
// 读取s0
static inline uint64
r_fp()
{
  uint64 x;
  asm volatile("mv %0, s0" : "=r" (x) );
    80005ec8:	84a2                	mv	s1,s0
    uint64 fp = r_fp(); 
    uint64 top = PGROUNDUP(fp);
    80005eca:	6905                	lui	s2,0x1
    80005ecc:	197d                	addi	s2,s2,-1
    80005ece:	9926                	add	s2,s2,s1
    80005ed0:	77fd                	lui	a5,0xfffff
    80005ed2:	00f97933          	and	s2,s2,a5


    uint64 return_address;
    while(fp!=top)
    80005ed6:	02990163          	beq	s2,s1,80005ef8 <backtrace+0x4e>
    {
        return_address = *((uint64*)(fp - 8));
        fp = *((uint64*)(fp - 16));
        printf("%p\n",return_address);
    80005eda:	00003997          	auipc	s3,0x3
    80005ede:	91698993          	addi	s3,s3,-1770 # 800087f0 <syscalls+0x428>
        return_address = *((uint64*)(fp - 8));
    80005ee2:	ff84b583          	ld	a1,-8(s1)
        fp = *((uint64*)(fp - 16));
    80005ee6:	ff04b483          	ld	s1,-16(s1)
        printf("%p\n",return_address);
    80005eea:	854e                	mv	a0,s3
    80005eec:	00000097          	auipc	ra,0x0
    80005ef0:	da6080e7          	jalr	-602(ra) # 80005c92 <printf>
    while(fp!=top)
    80005ef4:	fe9917e3          	bne	s2,s1,80005ee2 <backtrace+0x38>
    }
}
    80005ef8:	70a2                	ld	ra,40(sp)
    80005efa:	7402                	ld	s0,32(sp)
    80005efc:	64e2                	ld	s1,24(sp)
    80005efe:	6942                	ld	s2,16(sp)
    80005f00:	69a2                	ld	s3,8(sp)
    80005f02:	6145                	addi	sp,sp,48
    80005f04:	8082                	ret

0000000080005f06 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80005f06:	1141                	addi	sp,sp,-16
    80005f08:	e406                	sd	ra,8(sp)
    80005f0a:	e022                	sd	s0,0(sp)
    80005f0c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005f0e:	100007b7          	lui	a5,0x10000
    80005f12:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80005f16:	f8000713          	li	a4,-128
    80005f1a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005f1e:	470d                	li	a4,3
    80005f20:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005f24:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005f28:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005f2c:	469d                	li	a3,7
    80005f2e:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005f32:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005f36:	00003597          	auipc	a1,0x3
    80005f3a:	8da58593          	addi	a1,a1,-1830 # 80008810 <digits+0x18>
    80005f3e:	00020517          	auipc	a0,0x20
    80005f42:	2ca50513          	addi	a0,a0,714 # 80026208 <uart_tx_lock>
    80005f46:	00000097          	auipc	ra,0x0
    80005f4a:	218080e7          	jalr	536(ra) # 8000615e <initlock>
}
    80005f4e:	60a2                	ld	ra,8(sp)
    80005f50:	6402                	ld	s0,0(sp)
    80005f52:	0141                	addi	sp,sp,16
    80005f54:	8082                	ret

0000000080005f56 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005f56:	1101                	addi	sp,sp,-32
    80005f58:	ec06                	sd	ra,24(sp)
    80005f5a:	e822                	sd	s0,16(sp)
    80005f5c:	e426                	sd	s1,8(sp)
    80005f5e:	1000                	addi	s0,sp,32
    80005f60:	84aa                	mv	s1,a0
  push_off();
    80005f62:	00000097          	auipc	ra,0x0
    80005f66:	240080e7          	jalr	576(ra) # 800061a2 <push_off>

  if(panicked){
    80005f6a:	00003797          	auipc	a5,0x3
    80005f6e:	0b27a783          	lw	a5,178(a5) # 8000901c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005f72:	10000737          	lui	a4,0x10000
  if(panicked){
    80005f76:	c391                	beqz	a5,80005f7a <uartputc_sync+0x24>
    for(;;)
    80005f78:	a001                	j	80005f78 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005f7a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80005f7e:	0ff7f793          	andi	a5,a5,255
    80005f82:	0207f793          	andi	a5,a5,32
    80005f86:	dbf5                	beqz	a5,80005f7a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80005f88:	0ff4f793          	andi	a5,s1,255
    80005f8c:	10000737          	lui	a4,0x10000
    80005f90:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80005f94:	00000097          	auipc	ra,0x0
    80005f98:	2ae080e7          	jalr	686(ra) # 80006242 <pop_off>
}
    80005f9c:	60e2                	ld	ra,24(sp)
    80005f9e:	6442                	ld	s0,16(sp)
    80005fa0:	64a2                	ld	s1,8(sp)
    80005fa2:	6105                	addi	sp,sp,32
    80005fa4:	8082                	ret

0000000080005fa6 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80005fa6:	00003717          	auipc	a4,0x3
    80005faa:	07a73703          	ld	a4,122(a4) # 80009020 <uart_tx_r>
    80005fae:	00003797          	auipc	a5,0x3
    80005fb2:	07a7b783          	ld	a5,122(a5) # 80009028 <uart_tx_w>
    80005fb6:	06e78c63          	beq	a5,a4,8000602e <uartstart+0x88>
{
    80005fba:	7139                	addi	sp,sp,-64
    80005fbc:	fc06                	sd	ra,56(sp)
    80005fbe:	f822                	sd	s0,48(sp)
    80005fc0:	f426                	sd	s1,40(sp)
    80005fc2:	f04a                	sd	s2,32(sp)
    80005fc4:	ec4e                	sd	s3,24(sp)
    80005fc6:	e852                	sd	s4,16(sp)
    80005fc8:	e456                	sd	s5,8(sp)
    80005fca:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005fcc:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005fd0:	00020a17          	auipc	s4,0x20
    80005fd4:	238a0a13          	addi	s4,s4,568 # 80026208 <uart_tx_lock>
    uart_tx_r += 1;
    80005fd8:	00003497          	auipc	s1,0x3
    80005fdc:	04848493          	addi	s1,s1,72 # 80009020 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80005fe0:	00003997          	auipc	s3,0x3
    80005fe4:	04898993          	addi	s3,s3,72 # 80009028 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005fe8:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80005fec:	0ff7f793          	andi	a5,a5,255
    80005ff0:	0207f793          	andi	a5,a5,32
    80005ff4:	c785                	beqz	a5,8000601c <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005ff6:	01f77793          	andi	a5,a4,31
    80005ffa:	97d2                	add	a5,a5,s4
    80005ffc:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    80006000:	0705                	addi	a4,a4,1
    80006002:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80006004:	8526                	mv	a0,s1
    80006006:	ffffb097          	auipc	ra,0xffffb
    8000600a:	6e0080e7          	jalr	1760(ra) # 800016e6 <wakeup>
    
    WriteReg(THR, c);
    8000600e:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80006012:	6098                	ld	a4,0(s1)
    80006014:	0009b783          	ld	a5,0(s3)
    80006018:	fce798e3          	bne	a5,a4,80005fe8 <uartstart+0x42>
  }
}
    8000601c:	70e2                	ld	ra,56(sp)
    8000601e:	7442                	ld	s0,48(sp)
    80006020:	74a2                	ld	s1,40(sp)
    80006022:	7902                	ld	s2,32(sp)
    80006024:	69e2                	ld	s3,24(sp)
    80006026:	6a42                	ld	s4,16(sp)
    80006028:	6aa2                	ld	s5,8(sp)
    8000602a:	6121                	addi	sp,sp,64
    8000602c:	8082                	ret
    8000602e:	8082                	ret

0000000080006030 <uartputc>:
{
    80006030:	7179                	addi	sp,sp,-48
    80006032:	f406                	sd	ra,40(sp)
    80006034:	f022                	sd	s0,32(sp)
    80006036:	ec26                	sd	s1,24(sp)
    80006038:	e84a                	sd	s2,16(sp)
    8000603a:	e44e                	sd	s3,8(sp)
    8000603c:	e052                	sd	s4,0(sp)
    8000603e:	1800                	addi	s0,sp,48
    80006040:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80006042:	00020517          	auipc	a0,0x20
    80006046:	1c650513          	addi	a0,a0,454 # 80026208 <uart_tx_lock>
    8000604a:	00000097          	auipc	ra,0x0
    8000604e:	1a4080e7          	jalr	420(ra) # 800061ee <acquire>
  if(panicked){
    80006052:	00003797          	auipc	a5,0x3
    80006056:	fca7a783          	lw	a5,-54(a5) # 8000901c <panicked>
    8000605a:	c391                	beqz	a5,8000605e <uartputc+0x2e>
    for(;;)
    8000605c:	a001                	j	8000605c <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000605e:	00003797          	auipc	a5,0x3
    80006062:	fca7b783          	ld	a5,-54(a5) # 80009028 <uart_tx_w>
    80006066:	00003717          	auipc	a4,0x3
    8000606a:	fba73703          	ld	a4,-70(a4) # 80009020 <uart_tx_r>
    8000606e:	02070713          	addi	a4,a4,32
    80006072:	02f71b63          	bne	a4,a5,800060a8 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80006076:	00020a17          	auipc	s4,0x20
    8000607a:	192a0a13          	addi	s4,s4,402 # 80026208 <uart_tx_lock>
    8000607e:	00003497          	auipc	s1,0x3
    80006082:	fa248493          	addi	s1,s1,-94 # 80009020 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006086:	00003917          	auipc	s2,0x3
    8000608a:	fa290913          	addi	s2,s2,-94 # 80009028 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000608e:	85d2                	mv	a1,s4
    80006090:	8526                	mv	a0,s1
    80006092:	ffffb097          	auipc	ra,0xffffb
    80006096:	4c8080e7          	jalr	1224(ra) # 8000155a <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000609a:	00093783          	ld	a5,0(s2)
    8000609e:	6098                	ld	a4,0(s1)
    800060a0:	02070713          	addi	a4,a4,32
    800060a4:	fef705e3          	beq	a4,a5,8000608e <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800060a8:	00020497          	auipc	s1,0x20
    800060ac:	16048493          	addi	s1,s1,352 # 80026208 <uart_tx_lock>
    800060b0:	01f7f713          	andi	a4,a5,31
    800060b4:	9726                	add	a4,a4,s1
    800060b6:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    800060ba:	0785                	addi	a5,a5,1
    800060bc:	00003717          	auipc	a4,0x3
    800060c0:	f6f73623          	sd	a5,-148(a4) # 80009028 <uart_tx_w>
      uartstart();
    800060c4:	00000097          	auipc	ra,0x0
    800060c8:	ee2080e7          	jalr	-286(ra) # 80005fa6 <uartstart>
      release(&uart_tx_lock);
    800060cc:	8526                	mv	a0,s1
    800060ce:	00000097          	auipc	ra,0x0
    800060d2:	1d4080e7          	jalr	468(ra) # 800062a2 <release>
}
    800060d6:	70a2                	ld	ra,40(sp)
    800060d8:	7402                	ld	s0,32(sp)
    800060da:	64e2                	ld	s1,24(sp)
    800060dc:	6942                	ld	s2,16(sp)
    800060de:	69a2                	ld	s3,8(sp)
    800060e0:	6a02                	ld	s4,0(sp)
    800060e2:	6145                	addi	sp,sp,48
    800060e4:	8082                	ret

00000000800060e6 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800060e6:	1141                	addi	sp,sp,-16
    800060e8:	e422                	sd	s0,8(sp)
    800060ea:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800060ec:	100007b7          	lui	a5,0x10000
    800060f0:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800060f4:	8b85                	andi	a5,a5,1
    800060f6:	cb91                	beqz	a5,8000610a <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800060f8:	100007b7          	lui	a5,0x10000
    800060fc:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80006100:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80006104:	6422                	ld	s0,8(sp)
    80006106:	0141                	addi	sp,sp,16
    80006108:	8082                	ret
    return -1;
    8000610a:	557d                	li	a0,-1
    8000610c:	bfe5                	j	80006104 <uartgetc+0x1e>

000000008000610e <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    8000610e:	1101                	addi	sp,sp,-32
    80006110:	ec06                	sd	ra,24(sp)
    80006112:	e822                	sd	s0,16(sp)
    80006114:	e426                	sd	s1,8(sp)
    80006116:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80006118:	54fd                	li	s1,-1
    int c = uartgetc();
    8000611a:	00000097          	auipc	ra,0x0
    8000611e:	fcc080e7          	jalr	-52(ra) # 800060e6 <uartgetc>
    if(c == -1)
    80006122:	00950763          	beq	a0,s1,80006130 <uartintr+0x22>
      break;
    consoleintr(c);
    80006126:	00000097          	auipc	ra,0x0
    8000612a:	8a2080e7          	jalr	-1886(ra) # 800059c8 <consoleintr>
  while(1){
    8000612e:	b7f5                	j	8000611a <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80006130:	00020497          	auipc	s1,0x20
    80006134:	0d848493          	addi	s1,s1,216 # 80026208 <uart_tx_lock>
    80006138:	8526                	mv	a0,s1
    8000613a:	00000097          	auipc	ra,0x0
    8000613e:	0b4080e7          	jalr	180(ra) # 800061ee <acquire>
  uartstart();
    80006142:	00000097          	auipc	ra,0x0
    80006146:	e64080e7          	jalr	-412(ra) # 80005fa6 <uartstart>
  release(&uart_tx_lock);
    8000614a:	8526                	mv	a0,s1
    8000614c:	00000097          	auipc	ra,0x0
    80006150:	156080e7          	jalr	342(ra) # 800062a2 <release>
}
    80006154:	60e2                	ld	ra,24(sp)
    80006156:	6442                	ld	s0,16(sp)
    80006158:	64a2                	ld	s1,8(sp)
    8000615a:	6105                	addi	sp,sp,32
    8000615c:	8082                	ret

000000008000615e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    8000615e:	1141                	addi	sp,sp,-16
    80006160:	e422                	sd	s0,8(sp)
    80006162:	0800                	addi	s0,sp,16
  lk->name = name;
    80006164:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80006166:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000616a:	00053823          	sd	zero,16(a0)
}
    8000616e:	6422                	ld	s0,8(sp)
    80006170:	0141                	addi	sp,sp,16
    80006172:	8082                	ret

0000000080006174 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80006174:	411c                	lw	a5,0(a0)
    80006176:	e399                	bnez	a5,8000617c <holding+0x8>
    80006178:	4501                	li	a0,0
  return r;
}
    8000617a:	8082                	ret
{
    8000617c:	1101                	addi	sp,sp,-32
    8000617e:	ec06                	sd	ra,24(sp)
    80006180:	e822                	sd	s0,16(sp)
    80006182:	e426                	sd	s1,8(sp)
    80006184:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80006186:	6904                	ld	s1,16(a0)
    80006188:	ffffb097          	auipc	ra,0xffffb
    8000618c:	ca4080e7          	jalr	-860(ra) # 80000e2c <mycpu>
    80006190:	40a48533          	sub	a0,s1,a0
    80006194:	00153513          	seqz	a0,a0
}
    80006198:	60e2                	ld	ra,24(sp)
    8000619a:	6442                	ld	s0,16(sp)
    8000619c:	64a2                	ld	s1,8(sp)
    8000619e:	6105                	addi	sp,sp,32
    800061a0:	8082                	ret

00000000800061a2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800061a2:	1101                	addi	sp,sp,-32
    800061a4:	ec06                	sd	ra,24(sp)
    800061a6:	e822                	sd	s0,16(sp)
    800061a8:	e426                	sd	s1,8(sp)
    800061aa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800061ac:	100024f3          	csrr	s1,sstatus
    800061b0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800061b4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800061b6:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800061ba:	ffffb097          	auipc	ra,0xffffb
    800061be:	c72080e7          	jalr	-910(ra) # 80000e2c <mycpu>
    800061c2:	5d3c                	lw	a5,120(a0)
    800061c4:	cf89                	beqz	a5,800061de <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800061c6:	ffffb097          	auipc	ra,0xffffb
    800061ca:	c66080e7          	jalr	-922(ra) # 80000e2c <mycpu>
    800061ce:	5d3c                	lw	a5,120(a0)
    800061d0:	2785                	addiw	a5,a5,1
    800061d2:	dd3c                	sw	a5,120(a0)
}
    800061d4:	60e2                	ld	ra,24(sp)
    800061d6:	6442                	ld	s0,16(sp)
    800061d8:	64a2                	ld	s1,8(sp)
    800061da:	6105                	addi	sp,sp,32
    800061dc:	8082                	ret
    mycpu()->intena = old;
    800061de:	ffffb097          	auipc	ra,0xffffb
    800061e2:	c4e080e7          	jalr	-946(ra) # 80000e2c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800061e6:	8085                	srli	s1,s1,0x1
    800061e8:	8885                	andi	s1,s1,1
    800061ea:	dd64                	sw	s1,124(a0)
    800061ec:	bfe9                	j	800061c6 <push_off+0x24>

00000000800061ee <acquire>:
{
    800061ee:	1101                	addi	sp,sp,-32
    800061f0:	ec06                	sd	ra,24(sp)
    800061f2:	e822                	sd	s0,16(sp)
    800061f4:	e426                	sd	s1,8(sp)
    800061f6:	1000                	addi	s0,sp,32
    800061f8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800061fa:	00000097          	auipc	ra,0x0
    800061fe:	fa8080e7          	jalr	-88(ra) # 800061a2 <push_off>
  if(holding(lk))
    80006202:	8526                	mv	a0,s1
    80006204:	00000097          	auipc	ra,0x0
    80006208:	f70080e7          	jalr	-144(ra) # 80006174 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000620c:	4705                	li	a4,1
  if(holding(lk))
    8000620e:	e115                	bnez	a0,80006232 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80006210:	87ba                	mv	a5,a4
    80006212:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80006216:	2781                	sext.w	a5,a5
    80006218:	ffe5                	bnez	a5,80006210 <acquire+0x22>
  __sync_synchronize();
    8000621a:	0ff0000f          	fence
  lk->cpu = mycpu();
    8000621e:	ffffb097          	auipc	ra,0xffffb
    80006222:	c0e080e7          	jalr	-1010(ra) # 80000e2c <mycpu>
    80006226:	e888                	sd	a0,16(s1)
}
    80006228:	60e2                	ld	ra,24(sp)
    8000622a:	6442                	ld	s0,16(sp)
    8000622c:	64a2                	ld	s1,8(sp)
    8000622e:	6105                	addi	sp,sp,32
    80006230:	8082                	ret
    panic("acquire");
    80006232:	00002517          	auipc	a0,0x2
    80006236:	5e650513          	addi	a0,a0,1510 # 80008818 <digits+0x20>
    8000623a:	00000097          	auipc	ra,0x0
    8000623e:	a0e080e7          	jalr	-1522(ra) # 80005c48 <panic>

0000000080006242 <pop_off>:

void
pop_off(void)
{
    80006242:	1141                	addi	sp,sp,-16
    80006244:	e406                	sd	ra,8(sp)
    80006246:	e022                	sd	s0,0(sp)
    80006248:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    8000624a:	ffffb097          	auipc	ra,0xffffb
    8000624e:	be2080e7          	jalr	-1054(ra) # 80000e2c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006252:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80006256:	8b89                	andi	a5,a5,2
  if(intr_get())
    80006258:	e78d                	bnez	a5,80006282 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    8000625a:	5d3c                	lw	a5,120(a0)
    8000625c:	02f05b63          	blez	a5,80006292 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80006260:	37fd                	addiw	a5,a5,-1
    80006262:	0007871b          	sext.w	a4,a5
    80006266:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80006268:	eb09                	bnez	a4,8000627a <pop_off+0x38>
    8000626a:	5d7c                	lw	a5,124(a0)
    8000626c:	c799                	beqz	a5,8000627a <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000626e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80006272:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006276:	10079073          	csrw	sstatus,a5
    intr_on();
}
    8000627a:	60a2                	ld	ra,8(sp)
    8000627c:	6402                	ld	s0,0(sp)
    8000627e:	0141                	addi	sp,sp,16
    80006280:	8082                	ret
    panic("pop_off - interruptible");
    80006282:	00002517          	auipc	a0,0x2
    80006286:	59e50513          	addi	a0,a0,1438 # 80008820 <digits+0x28>
    8000628a:	00000097          	auipc	ra,0x0
    8000628e:	9be080e7          	jalr	-1602(ra) # 80005c48 <panic>
    panic("pop_off");
    80006292:	00002517          	auipc	a0,0x2
    80006296:	5a650513          	addi	a0,a0,1446 # 80008838 <digits+0x40>
    8000629a:	00000097          	auipc	ra,0x0
    8000629e:	9ae080e7          	jalr	-1618(ra) # 80005c48 <panic>

00000000800062a2 <release>:
{
    800062a2:	1101                	addi	sp,sp,-32
    800062a4:	ec06                	sd	ra,24(sp)
    800062a6:	e822                	sd	s0,16(sp)
    800062a8:	e426                	sd	s1,8(sp)
    800062aa:	1000                	addi	s0,sp,32
    800062ac:	84aa                	mv	s1,a0
  if(!holding(lk))
    800062ae:	00000097          	auipc	ra,0x0
    800062b2:	ec6080e7          	jalr	-314(ra) # 80006174 <holding>
    800062b6:	c115                	beqz	a0,800062da <release+0x38>
  lk->cpu = 0;
    800062b8:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800062bc:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    800062c0:	0f50000f          	fence	iorw,ow
    800062c4:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800062c8:	00000097          	auipc	ra,0x0
    800062cc:	f7a080e7          	jalr	-134(ra) # 80006242 <pop_off>
}
    800062d0:	60e2                	ld	ra,24(sp)
    800062d2:	6442                	ld	s0,16(sp)
    800062d4:	64a2                	ld	s1,8(sp)
    800062d6:	6105                	addi	sp,sp,32
    800062d8:	8082                	ret
    panic("release");
    800062da:	00002517          	auipc	a0,0x2
    800062de:	56650513          	addi	a0,a0,1382 # 80008840 <digits+0x48>
    800062e2:	00000097          	auipc	ra,0x0
    800062e6:	966080e7          	jalr	-1690(ra) # 80005c48 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
