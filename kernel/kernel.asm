
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	83010113          	addi	sp,sp,-2000 # 80009830 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	e2478793          	addi	a5,a5,-476 # 80005e80 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	fa278793          	addi	a5,a5,-94 # 80001048 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	c8e080e7          	jalr	-882(ra) # 80000d9a <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	628080e7          	jalr	1576(ra) # 8000274e <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	7aa080e7          	jalr	1962(ra) # 800008e0 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	d00080e7          	jalr	-768(ra) # 80000e4e <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7119                	addi	sp,sp,-128
    80000170:	fc86                	sd	ra,120(sp)
    80000172:	f8a2                	sd	s0,112(sp)
    80000174:	f4a6                	sd	s1,104(sp)
    80000176:	f0ca                	sd	s2,96(sp)
    80000178:	ecce                	sd	s3,88(sp)
    8000017a:	e8d2                	sd	s4,80(sp)
    8000017c:	e4d6                	sd	s5,72(sp)
    8000017e:	e0da                	sd	s6,64(sp)
    80000180:	fc5e                	sd	s7,56(sp)
    80000182:	f862                	sd	s8,48(sp)
    80000184:	f466                	sd	s9,40(sp)
    80000186:	f06a                	sd	s10,32(sp)
    80000188:	ec6e                	sd	s11,24(sp)
    8000018a:	0100                	addi	s0,sp,128
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8aae                	mv	s5,a1
    80000190:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	69a50513          	addi	a0,a0,1690 # 80011830 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	bfc080e7          	jalr	-1028(ra) # 80000d9a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	68a48493          	addi	s1,s1,1674 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ae:	89a6                	mv	s3,s1
    800001b0:	00011917          	auipc	s2,0x11
    800001b4:	71890913          	addi	s2,s2,1816 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b8:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ba:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001bc:	4da9                	li	s11,10
  while(n > 0){
    800001be:	07405863          	blez	s4,8000022e <consoleread+0xc0>
    while(cons.r == cons.w){
    800001c2:	0984a783          	lw	a5,152(s1)
    800001c6:	09c4a703          	lw	a4,156(s1)
    800001ca:	02f71463          	bne	a4,a5,800001f2 <consoleread+0x84>
      if(myproc()->killed){
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	ab8080e7          	jalr	-1352(ra) # 80001c86 <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	2b8080e7          	jalr	696(ra) # 80002496 <sleep>
    while(cons.r == cons.w){
    800001e6:	0984a783          	lw	a5,152(s1)
    800001ea:	09c4a703          	lw	a4,156(s1)
    800001ee:	fef700e3          	beq	a4,a5,800001ce <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f2:	0017871b          	addiw	a4,a5,1
    800001f6:	08e4ac23          	sw	a4,152(s1)
    800001fa:	07f7f713          	andi	a4,a5,127
    800001fe:	9726                	add	a4,a4,s1
    80000200:	01874703          	lbu	a4,24(a4)
    80000204:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000208:	079c0663          	beq	s8,s9,80000274 <consoleread+0x106>
    cbuf = c;
    8000020c:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	f8f40613          	addi	a2,s0,-113
    80000216:	85d6                	mv	a1,s5
    80000218:	855a                	mv	a0,s6
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	4de080e7          	jalr	1246(ra) # 800026f8 <either_copyout>
    80000222:	01a50663          	beq	a0,s10,8000022e <consoleread+0xc0>
    dst++;
    80000226:	0a85                	addi	s5,s5,1
    --n;
    80000228:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000022a:	f9bc1ae3          	bne	s8,s11,800001be <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022e:	00011517          	auipc	a0,0x11
    80000232:	60250513          	addi	a0,a0,1538 # 80011830 <cons>
    80000236:	00001097          	auipc	ra,0x1
    8000023a:	c18080e7          	jalr	-1000(ra) # 80000e4e <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	c02080e7          	jalr	-1022(ra) # 80000e4e <release>
        return -1;
    80000254:	557d                	li	a0,-1
}
    80000256:	70e6                	ld	ra,120(sp)
    80000258:	7446                	ld	s0,112(sp)
    8000025a:	74a6                	ld	s1,104(sp)
    8000025c:	7906                	ld	s2,96(sp)
    8000025e:	69e6                	ld	s3,88(sp)
    80000260:	6a46                	ld	s4,80(sp)
    80000262:	6aa6                	ld	s5,72(sp)
    80000264:	6b06                	ld	s6,64(sp)
    80000266:	7be2                	ld	s7,56(sp)
    80000268:	7c42                	ld	s8,48(sp)
    8000026a:	7ca2                	ld	s9,40(sp)
    8000026c:	7d02                	ld	s10,32(sp)
    8000026e:	6de2                	ld	s11,24(sp)
    80000270:	6109                	addi	sp,sp,128
    80000272:	8082                	ret
      if(n < target){
    80000274:	000a071b          	sext.w	a4,s4
    80000278:	fb777be3          	bgeu	a4,s7,8000022e <consoleread+0xc0>
        cons.r--;
    8000027c:	00011717          	auipc	a4,0x11
    80000280:	64f72623          	sw	a5,1612(a4) # 800118c8 <cons+0x98>
    80000284:	b76d                	j	8000022e <consoleread+0xc0>

0000000080000286 <consputc>:
{
    80000286:	1141                	addi	sp,sp,-16
    80000288:	e406                	sd	ra,8(sp)
    8000028a:	e022                	sd	s0,0(sp)
    8000028c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028e:	10000793          	li	a5,256
    80000292:	00f50a63          	beq	a0,a5,800002a6 <consputc+0x20>
    uartputc_sync(c);
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	564080e7          	jalr	1380(ra) # 800007fa <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	552080e7          	jalr	1362(ra) # 800007fa <uartputc_sync>
    800002b0:	02000513          	li	a0,32
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	546080e7          	jalr	1350(ra) # 800007fa <uartputc_sync>
    800002bc:	4521                	li	a0,8
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	53c080e7          	jalr	1340(ra) # 800007fa <uartputc_sync>
    800002c6:	bfe1                	j	8000029e <consputc+0x18>

00000000800002c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	e04a                	sd	s2,0(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00011517          	auipc	a0,0x11
    800002da:	55a50513          	addi	a0,a0,1370 # 80011830 <cons>
    800002de:	00001097          	auipc	ra,0x1
    800002e2:	abc080e7          	jalr	-1348(ra) # 80000d9a <acquire>

  switch(c){
    800002e6:	47d5                	li	a5,21
    800002e8:	0af48663          	beq	s1,a5,80000394 <consoleintr+0xcc>
    800002ec:	0297ca63          	blt	a5,s1,80000320 <consoleintr+0x58>
    800002f0:	47a1                	li	a5,8
    800002f2:	0ef48763          	beq	s1,a5,800003e0 <consoleintr+0x118>
    800002f6:	47c1                	li	a5,16
    800002f8:	10f49a63          	bne	s1,a5,8000040c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fc:	00002097          	auipc	ra,0x2
    80000300:	4a8080e7          	jalr	1192(ra) # 800027a4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	b42080e7          	jalr	-1214(ra) # 80000e4e <release>
}
    80000314:	60e2                	ld	ra,24(sp)
    80000316:	6442                	ld	s0,16(sp)
    80000318:	64a2                	ld	s1,8(sp)
    8000031a:	6902                	ld	s2,0(sp)
    8000031c:	6105                	addi	sp,sp,32
    8000031e:	8082                	ret
  switch(c){
    80000320:	07f00793          	li	a5,127
    80000324:	0af48e63          	beq	s1,a5,800003e0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000328:	00011717          	auipc	a4,0x11
    8000032c:	50870713          	addi	a4,a4,1288 # 80011830 <cons>
    80000330:	0a072783          	lw	a5,160(a4)
    80000334:	09872703          	lw	a4,152(a4)
    80000338:	9f99                	subw	a5,a5,a4
    8000033a:	07f00713          	li	a4,127
    8000033e:	fcf763e3          	bltu	a4,a5,80000304 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000342:	47b5                	li	a5,13
    80000344:	0cf48763          	beq	s1,a5,80000412 <consoleintr+0x14a>
      consputc(c);
    80000348:	8526                	mv	a0,s1
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	f3c080e7          	jalr	-196(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000352:	00011797          	auipc	a5,0x11
    80000356:	4de78793          	addi	a5,a5,1246 # 80011830 <cons>
    8000035a:	0a07a703          	lw	a4,160(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a023          	sw	a3,160(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00011797          	auipc	a5,0x11
    80000384:	5487a783          	lw	a5,1352(a5) # 800118c8 <cons+0x98>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00011717          	auipc	a4,0x11
    80000398:	49c70713          	addi	a4,a4,1180 # 80011830 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00011497          	auipc	s1,0x11
    800003a8:	48c48493          	addi	s1,s1,1164 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003ac:	4929                	li	s2,10
    800003ae:	f4f70be3          	beq	a4,a5,80000304 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b2:	37fd                	addiw	a5,a5,-1
    800003b4:	07f7f713          	andi	a4,a5,127
    800003b8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ba:	01874703          	lbu	a4,24(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	ebc080e7          	jalr	-324(ra) # 80000286 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a04a783          	lw	a5,160(s1)
    800003d6:	09c4a703          	lw	a4,156(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00011717          	auipc	a4,0x11
    800003e4:	45070713          	addi	a4,a4,1104 # 80011830 <cons>
    800003e8:	0a072783          	lw	a5,160(a4)
    800003ec:	09c72703          	lw	a4,156(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00011717          	auipc	a4,0x11
    800003fa:	4cf72d23          	sw	a5,1242(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fe:	10000513          	li	a0,256
    80000402:	00000097          	auipc	ra,0x0
    80000406:	e84080e7          	jalr	-380(ra) # 80000286 <consputc>
    8000040a:	bded                	j	80000304 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040c:	ee048ce3          	beqz	s1,80000304 <consoleintr+0x3c>
    80000410:	bf21                	j	80000328 <consoleintr+0x60>
      consputc(c);
    80000412:	4529                	li	a0,10
    80000414:	00000097          	auipc	ra,0x0
    80000418:	e72080e7          	jalr	-398(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041c:	00011797          	auipc	a5,0x11
    80000420:	41478793          	addi	a5,a5,1044 # 80011830 <cons>
    80000424:	0a07a703          	lw	a4,160(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a023          	sw	a3,160(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000440:	00011797          	auipc	a5,0x11
    80000444:	48c7a623          	sw	a2,1164(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000448:	00011517          	auipc	a0,0x11
    8000044c:	48050513          	addi	a0,a0,1152 # 800118c8 <cons+0x98>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	1cc080e7          	jalr	460(ra) # 8000261c <wakeup>
    80000458:	b575                	j	80000304 <consoleintr+0x3c>

000000008000045a <consoleinit>:

void
consoleinit(void)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e406                	sd	ra,8(sp)
    8000045e:	e022                	sd	s0,0(sp)
    80000460:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000462:	00008597          	auipc	a1,0x8
    80000466:	bae58593          	addi	a1,a1,-1106 # 80008010 <etext+0x10>
    8000046a:	00011517          	auipc	a0,0x11
    8000046e:	3c650513          	addi	a0,a0,966 # 80011830 <cons>
    80000472:	00001097          	auipc	ra,0x1
    80000476:	898080e7          	jalr	-1896(ra) # 80000d0a <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	330080e7          	jalr	816(ra) # 800007aa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00041797          	auipc	a5,0x41
    80000486:	54678793          	addi	a5,a5,1350 # 800419c8 <devsw>
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	ce470713          	addi	a4,a4,-796 # 8000016e <consoleread>
    80000492:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000494:	00000717          	auipc	a4,0x0
    80000498:	c5870713          	addi	a4,a4,-936 # 800000ec <consolewrite>
    8000049c:	ef98                	sd	a4,24(a5)
}
    8000049e:	60a2                	ld	ra,8(sp)
    800004a0:	6402                	ld	s0,0(sp)
    800004a2:	0141                	addi	sp,sp,16
    800004a4:	8082                	ret

00000000800004a6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a6:	7179                	addi	sp,sp,-48
    800004a8:	f406                	sd	ra,40(sp)
    800004aa:	f022                	sd	s0,32(sp)
    800004ac:	ec26                	sd	s1,24(sp)
    800004ae:	e84a                	sd	s2,16(sp)
    800004b0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b2:	c219                	beqz	a2,800004b8 <printint+0x12>
    800004b4:	08054663          	bltz	a0,80000540 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b8:	2501                	sext.w	a0,a0
    800004ba:	4881                	li	a7,0
    800004bc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c2:	2581                	sext.w	a1,a1
    800004c4:	00008617          	auipc	a2,0x8
    800004c8:	b7c60613          	addi	a2,a2,-1156 # 80008040 <digits>
    800004cc:	883a                	mv	a6,a4
    800004ce:	2705                	addiw	a4,a4,1
    800004d0:	02b577bb          	remuw	a5,a0,a1
    800004d4:	1782                	slli	a5,a5,0x20
    800004d6:	9381                	srli	a5,a5,0x20
    800004d8:	97b2                	add	a5,a5,a2
    800004da:	0007c783          	lbu	a5,0(a5)
    800004de:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e2:	0005079b          	sext.w	a5,a0
    800004e6:	02b5553b          	divuw	a0,a0,a1
    800004ea:	0685                	addi	a3,a3,1
    800004ec:	feb7f0e3          	bgeu	a5,a1,800004cc <printint+0x26>

  if(sign)
    800004f0:	00088b63          	beqz	a7,80000506 <printint+0x60>
    buf[i++] = '-';
    800004f4:	fe040793          	addi	a5,s0,-32
    800004f8:	973e                	add	a4,a4,a5
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x8e>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	d60080e7          	jalr	-672(ra) # 80000286 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7c>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf9d                	j	800004bc <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00011797          	auipc	a5,0x11
    80000558:	3807ae23          	sw	zero,924(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	abc50513          	addi	a0,a0,-1348 # 80008018 <etext+0x18>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	b5a50513          	addi	a0,a0,-1190 # 800080d0 <digits+0x90>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000586:	4785                	li	a5,1
    80000588:	00009717          	auipc	a4,0x9
    8000058c:	a6f72c23          	sw	a5,-1416(a4) # 80009000 <panicked>
  for(;;)
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
{
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598:	f4a6                	sd	s1,104(sp)
    8000059a:	f0ca                	sd	s2,96(sp)
    8000059c:	ecce                	sd	s3,88(sp)
    8000059e:	e8d2                	sd	s4,80(sp)
    800005a0:	e4d6                	sd	s5,72(sp)
    800005a2:	e0da                	sd	s6,64(sp)
    800005a4:	fc5e                	sd	s7,56(sp)
    800005a6:	f862                	sd	s8,48(sp)
    800005a8:	f466                	sd	s9,40(sp)
    800005aa:	f06a                	sd	s10,32(sp)
    800005ac:	ec6e                	sd	s11,24(sp)
    800005ae:	0100                	addi	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d97          	auipc	s11,0x11
    800005c8:	32cdad83          	lw	s11,812(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005cc:	020d9b63          	bnez	s11,80000602 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0263          	beqz	s4,80000614 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	addi	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	16050263          	beqz	a0,80000744 <printf+0x1b2>
    800005e4:	4481                	li	s1,0
    if(c != '%'){
    800005e6:	02500a93          	li	s5,37
    switch(c){
    800005ea:	07000b13          	li	s6,112
  consputc('x');
    800005ee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f0:	00008b97          	auipc	s7,0x8
    800005f4:	a50b8b93          	addi	s7,s7,-1456 # 80008040 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00011517          	auipc	a0,0x11
    80000606:	2d650513          	addi	a0,a0,726 # 800118d8 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	790080e7          	jalr	1936(ra) # 80000d9a <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00008517          	auipc	a0,0x8
    80000618:	a1450513          	addi	a0,a0,-1516 # 80008028 <etext+0x28>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	f2c080e7          	jalr	-212(ra) # 80000548 <panic>
      consputc(c);
    80000624:	00000097          	auipc	ra,0x0
    80000628:	c62080e7          	jalr	-926(ra) # 80000286 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062c:	2485                	addiw	s1,s1,1
    8000062e:	009a07b3          	add	a5,s4,s1
    80000632:	0007c503          	lbu	a0,0(a5)
    80000636:	10050763          	beqz	a0,80000744 <printf+0x1b2>
    if(c != '%'){
    8000063a:	ff5515e3          	bne	a0,s5,80000624 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063e:	2485                	addiw	s1,s1,1
    80000640:	009a07b3          	add	a5,s4,s1
    80000644:	0007c783          	lbu	a5,0(a5)
    80000648:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000064c:	cfe5                	beqz	a5,80000744 <printf+0x1b2>
    switch(c){
    8000064e:	05678a63          	beq	a5,s6,800006a2 <printf+0x110>
    80000652:	02fb7663          	bgeu	s6,a5,8000067e <printf+0xec>
    80000656:	09978963          	beq	a5,s9,800006e8 <printf+0x156>
    8000065a:	07800713          	li	a4,120
    8000065e:	0ce79863          	bne	a5,a4,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4605                	li	a2,1
    80000670:	85ea                	mv	a1,s10
    80000672:	4388                	lw	a0,0(a5)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	e32080e7          	jalr	-462(ra) # 800004a6 <printint>
      break;
    8000067c:	bf45                	j	8000062c <printf+0x9a>
    switch(c){
    8000067e:	0b578263          	beq	a5,s5,80000722 <printf+0x190>
    80000682:	0b879663          	bne	a5,s8,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e0e080e7          	jalr	-498(ra) # 800004a6 <printint>
      break;
    800006a0:	b771                	j	8000062c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006b2:	03000513          	li	a0,48
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bd0080e7          	jalr	-1072(ra) # 80000286 <consputc>
  consputc('x');
    800006be:	07800513          	li	a0,120
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	bc4080e7          	jalr	-1084(ra) # 80000286 <consputc>
    800006ca:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006cc:	03c9d793          	srli	a5,s3,0x3c
    800006d0:	97de                	add	a5,a5,s7
    800006d2:	0007c503          	lbu	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	bb0080e7          	jalr	-1104(ra) # 80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006de:	0992                	slli	s3,s3,0x4
    800006e0:	397d                	addiw	s2,s2,-1
    800006e2:	fe0915e3          	bnez	s2,800006cc <printf+0x13a>
    800006e6:	b799                	j	8000062c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	0007b903          	ld	s2,0(a5)
    800006f8:	00090e63          	beqz	s2,80000714 <printf+0x182>
      for(; *s; s++)
    800006fc:	00094503          	lbu	a0,0(s2)
    80000700:	d515                	beqz	a0,8000062c <printf+0x9a>
        consputc(*s);
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b84080e7          	jalr	-1148(ra) # 80000286 <consputc>
      for(; *s; s++)
    8000070a:	0905                	addi	s2,s2,1
    8000070c:	00094503          	lbu	a0,0(s2)
    80000710:	f96d                	bnez	a0,80000702 <printf+0x170>
    80000712:	bf29                	j	8000062c <printf+0x9a>
        s = "(null)";
    80000714:	00008917          	auipc	s2,0x8
    80000718:	90c90913          	addi	s2,s2,-1780 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000071c:	02800513          	li	a0,40
    80000720:	b7cd                	j	80000702 <printf+0x170>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b62080e7          	jalr	-1182(ra) # 80000286 <consputc>
      break;
    8000072c:	b701                	j	8000062c <printf+0x9a>
      consputc('%');
    8000072e:	8556                	mv	a0,s5
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b56080e7          	jalr	-1194(ra) # 80000286 <consputc>
      consputc(c);
    80000738:	854a                	mv	a0,s2
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b4c080e7          	jalr	-1204(ra) # 80000286 <consputc>
      break;
    80000742:	b5ed                	j	8000062c <printf+0x9a>
  if(locking)
    80000744:	020d9163          	bnez	s11,80000766 <printf+0x1d4>
}
    80000748:	70e6                	ld	ra,120(sp)
    8000074a:	7446                	ld	s0,112(sp)
    8000074c:	74a6                	ld	s1,104(sp)
    8000074e:	7906                	ld	s2,96(sp)
    80000750:	69e6                	ld	s3,88(sp)
    80000752:	6a46                	ld	s4,80(sp)
    80000754:	6aa6                	ld	s5,72(sp)
    80000756:	6b06                	ld	s6,64(sp)
    80000758:	7be2                	ld	s7,56(sp)
    8000075a:	7c42                	ld	s8,48(sp)
    8000075c:	7ca2                	ld	s9,40(sp)
    8000075e:	7d02                	ld	s10,32(sp)
    80000760:	6de2                	ld	s11,24(sp)
    80000762:	6129                	addi	sp,sp,192
    80000764:	8082                	ret
    release(&pr.lock);
    80000766:	00011517          	auipc	a0,0x11
    8000076a:	17250513          	addi	a0,a0,370 # 800118d8 <pr>
    8000076e:	00000097          	auipc	ra,0x0
    80000772:	6e0080e7          	jalr	1760(ra) # 80000e4e <release>
}
    80000776:	bfc9                	j	80000748 <printf+0x1b6>

0000000080000778 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000778:	1101                	addi	sp,sp,-32
    8000077a:	ec06                	sd	ra,24(sp)
    8000077c:	e822                	sd	s0,16(sp)
    8000077e:	e426                	sd	s1,8(sp)
    80000780:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000782:	00011497          	auipc	s1,0x11
    80000786:	15648493          	addi	s1,s1,342 # 800118d8 <pr>
    8000078a:	00008597          	auipc	a1,0x8
    8000078e:	8ae58593          	addi	a1,a1,-1874 # 80008038 <etext+0x38>
    80000792:	8526                	mv	a0,s1
    80000794:	00000097          	auipc	ra,0x0
    80000798:	576080e7          	jalr	1398(ra) # 80000d0a <initlock>
  pr.locking = 1;
    8000079c:	4785                	li	a5,1
    8000079e:	cc9c                	sw	a5,24(s1)
}
    800007a0:	60e2                	ld	ra,24(sp)
    800007a2:	6442                	ld	s0,16(sp)
    800007a4:	64a2                	ld	s1,8(sp)
    800007a6:	6105                	addi	sp,sp,32
    800007a8:	8082                	ret

00000000800007aa <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007aa:	1141                	addi	sp,sp,-16
    800007ac:	e406                	sd	ra,8(sp)
    800007ae:	e022                	sd	s0,0(sp)
    800007b0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b2:	100007b7          	lui	a5,0x10000
    800007b6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ba:	f8000713          	li	a4,-128
    800007be:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c2:	470d                	li	a4,3
    800007c4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007cc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d0:	469d                	li	a3,7
    800007d2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007da:	00008597          	auipc	a1,0x8
    800007de:	87e58593          	addi	a1,a1,-1922 # 80008058 <digits+0x18>
    800007e2:	00011517          	auipc	a0,0x11
    800007e6:	11650513          	addi	a0,a0,278 # 800118f8 <uart_tx_lock>
    800007ea:	00000097          	auipc	ra,0x0
    800007ee:	520080e7          	jalr	1312(ra) # 80000d0a <initlock>
}
    800007f2:	60a2                	ld	ra,8(sp)
    800007f4:	6402                	ld	s0,0(sp)
    800007f6:	0141                	addi	sp,sp,16
    800007f8:	8082                	ret

00000000800007fa <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fa:	1101                	addi	sp,sp,-32
    800007fc:	ec06                	sd	ra,24(sp)
    800007fe:	e822                	sd	s0,16(sp)
    80000800:	e426                	sd	s1,8(sp)
    80000802:	1000                	addi	s0,sp,32
    80000804:	84aa                	mv	s1,a0
  push_off();
    80000806:	00000097          	auipc	ra,0x0
    8000080a:	548080e7          	jalr	1352(ra) # 80000d4e <push_off>

  if(panicked){
    8000080e:	00008797          	auipc	a5,0x8
    80000812:	7f27a783          	lw	a5,2034(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000816:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081a:	c391                	beqz	a5,8000081e <uartputc_sync+0x24>
    for(;;)
    8000081c:	a001                	j	8000081c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000822:	0ff7f793          	andi	a5,a5,255
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dbf5                	beqz	a5,8000081e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f793          	andi	a5,s1,255
    80000830:	10000737          	lui	a4,0x10000
    80000834:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	5b6080e7          	jalr	1462(ra) # 80000dee <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	7ba7a783          	lw	a5,1978(a5) # 80009004 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	7b672703          	lw	a4,1974(a4) # 80009008 <uart_tx_w>
    8000085a:	08f70263          	beq	a4,a5,800008de <uartstart+0x94>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000874:	00011a17          	auipc	s4,0x11
    80000878:	084a0a13          	addi	s4,s4,132 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	78848493          	addi	s1,s1,1928 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	78498993          	addi	s3,s3,1924 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	0ff77713          	andi	a4,a4,255
    80000894:	02077713          	andi	a4,a4,32
    80000898:	cb15                	beqz	a4,800008cc <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    8000089a:	00fa0733          	add	a4,s4,a5
    8000089e:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008a2:	2785                	addiw	a5,a5,1
    800008a4:	41f7d71b          	sraiw	a4,a5,0x1f
    800008a8:	01b7571b          	srliw	a4,a4,0x1b
    800008ac:	9fb9                	addw	a5,a5,a4
    800008ae:	8bfd                	andi	a5,a5,31
    800008b0:	9f99                	subw	a5,a5,a4
    800008b2:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008b4:	8526                	mv	a0,s1
    800008b6:	00002097          	auipc	ra,0x2
    800008ba:	d66080e7          	jalr	-666(ra) # 8000261c <wakeup>
    
    WriteReg(THR, c);
    800008be:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008c2:	409c                	lw	a5,0(s1)
    800008c4:	0009a703          	lw	a4,0(s3)
    800008c8:	fcf712e3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008cc:	70e2                	ld	ra,56(sp)
    800008ce:	7442                	ld	s0,48(sp)
    800008d0:	74a2                	ld	s1,40(sp)
    800008d2:	7902                	ld	s2,32(sp)
    800008d4:	69e2                	ld	s3,24(sp)
    800008d6:	6a42                	ld	s4,16(sp)
    800008d8:	6aa2                	ld	s5,8(sp)
    800008da:	6121                	addi	sp,sp,64
    800008dc:	8082                	ret
    800008de:	8082                	ret

00000000800008e0 <uartputc>:
{
    800008e0:	7179                	addi	sp,sp,-48
    800008e2:	f406                	sd	ra,40(sp)
    800008e4:	f022                	sd	s0,32(sp)
    800008e6:	ec26                	sd	s1,24(sp)
    800008e8:	e84a                	sd	s2,16(sp)
    800008ea:	e44e                	sd	s3,8(sp)
    800008ec:	e052                	sd	s4,0(sp)
    800008ee:	1800                	addi	s0,sp,48
    800008f0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008f2:	00011517          	auipc	a0,0x11
    800008f6:	00650513          	addi	a0,a0,6 # 800118f8 <uart_tx_lock>
    800008fa:	00000097          	auipc	ra,0x0
    800008fe:	4a0080e7          	jalr	1184(ra) # 80000d9a <acquire>
  if(panicked){
    80000902:	00008797          	auipc	a5,0x8
    80000906:	6fe7a783          	lw	a5,1790(a5) # 80009000 <panicked>
    8000090a:	c391                	beqz	a5,8000090e <uartputc+0x2e>
    for(;;)
    8000090c:	a001                	j	8000090c <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000090e:	00008717          	auipc	a4,0x8
    80000912:	6fa72703          	lw	a4,1786(a4) # 80009008 <uart_tx_w>
    80000916:	0017079b          	addiw	a5,a4,1
    8000091a:	41f7d69b          	sraiw	a3,a5,0x1f
    8000091e:	01b6d69b          	srliw	a3,a3,0x1b
    80000922:	9fb5                	addw	a5,a5,a3
    80000924:	8bfd                	andi	a5,a5,31
    80000926:	9f95                	subw	a5,a5,a3
    80000928:	00008697          	auipc	a3,0x8
    8000092c:	6dc6a683          	lw	a3,1756(a3) # 80009004 <uart_tx_r>
    80000930:	04f69263          	bne	a3,a5,80000974 <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000934:	00011a17          	auipc	s4,0x11
    80000938:	fc4a0a13          	addi	s4,s4,-60 # 800118f8 <uart_tx_lock>
    8000093c:	00008497          	auipc	s1,0x8
    80000940:	6c848493          	addi	s1,s1,1736 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	00008917          	auipc	s2,0x8
    80000948:	6c490913          	addi	s2,s2,1732 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000094c:	85d2                	mv	a1,s4
    8000094e:	8526                	mv	a0,s1
    80000950:	00002097          	auipc	ra,0x2
    80000954:	b46080e7          	jalr	-1210(ra) # 80002496 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000958:	00092703          	lw	a4,0(s2)
    8000095c:	0017079b          	addiw	a5,a4,1
    80000960:	41f7d69b          	sraiw	a3,a5,0x1f
    80000964:	01b6d69b          	srliw	a3,a3,0x1b
    80000968:	9fb5                	addw	a5,a5,a3
    8000096a:	8bfd                	andi	a5,a5,31
    8000096c:	9f95                	subw	a5,a5,a3
    8000096e:	4094                	lw	a3,0(s1)
    80000970:	fcf68ee3          	beq	a3,a5,8000094c <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000974:	00011497          	auipc	s1,0x11
    80000978:	f8448493          	addi	s1,s1,-124 # 800118f8 <uart_tx_lock>
    8000097c:	9726                	add	a4,a4,s1
    8000097e:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000982:	00008717          	auipc	a4,0x8
    80000986:	68f72323          	sw	a5,1670(a4) # 80009008 <uart_tx_w>
      uartstart();
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	ec0080e7          	jalr	-320(ra) # 8000084a <uartstart>
      release(&uart_tx_lock);
    80000992:	8526                	mv	a0,s1
    80000994:	00000097          	auipc	ra,0x0
    80000998:	4ba080e7          	jalr	1210(ra) # 80000e4e <release>
}
    8000099c:	70a2                	ld	ra,40(sp)
    8000099e:	7402                	ld	s0,32(sp)
    800009a0:	64e2                	ld	s1,24(sp)
    800009a2:	6942                	ld	s2,16(sp)
    800009a4:	69a2                	ld	s3,8(sp)
    800009a6:	6a02                	ld	s4,0(sp)
    800009a8:	6145                	addi	sp,sp,48
    800009aa:	8082                	ret

00000000800009ac <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009ac:	1141                	addi	sp,sp,-16
    800009ae:	e422                	sd	s0,8(sp)
    800009b0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009b2:	100007b7          	lui	a5,0x10000
    800009b6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ba:	8b85                	andi	a5,a5,1
    800009bc:	cb91                	beqz	a5,800009d0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009be:	100007b7          	lui	a5,0x10000
    800009c2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009c6:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009ca:	6422                	ld	s0,8(sp)
    800009cc:	0141                	addi	sp,sp,16
    800009ce:	8082                	ret
    return -1;
    800009d0:	557d                	li	a0,-1
    800009d2:	bfe5                	j	800009ca <uartgetc+0x1e>

00000000800009d4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009d4:	1101                	addi	sp,sp,-32
    800009d6:	ec06                	sd	ra,24(sp)
    800009d8:	e822                	sd	s0,16(sp)
    800009da:	e426                	sd	s1,8(sp)
    800009dc:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009de:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e0:	00000097          	auipc	ra,0x0
    800009e4:	fcc080e7          	jalr	-52(ra) # 800009ac <uartgetc>
    if(c == -1)
    800009e8:	00950763          	beq	a0,s1,800009f6 <uartintr+0x22>
      break;
    consoleintr(c);
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	8dc080e7          	jalr	-1828(ra) # 800002c8 <consoleintr>
  while(1){
    800009f4:	b7f5                	j	800009e0 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009f6:	00011497          	auipc	s1,0x11
    800009fa:	f0248493          	addi	s1,s1,-254 # 800118f8 <uart_tx_lock>
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	39a080e7          	jalr	922(ra) # 80000d9a <acquire>
  uartstart();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	e42080e7          	jalr	-446(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    80000a10:	8526                	mv	a0,s1
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	43c080e7          	jalr	1084(ra) # 80000e4e <release>
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6105                	addi	sp,sp,32
    80000a22:	8082                	ret

0000000080000a24 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a24:	7179                	addi	sp,sp,-48
    80000a26:	f406                	sd	ra,40(sp)
    80000a28:	f022                	sd	s0,32(sp)
    80000a2a:	ec26                	sd	s1,24(sp)
    80000a2c:	e84a                	sd	s2,16(sp)
    80000a2e:	e44e                	sd	s3,8(sp)
    80000a30:	1800                	addi	s0,sp,48
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a32:	03451793          	slli	a5,a0,0x34
    80000a36:	e7a5                	bnez	a5,80000a9e <kfree+0x7a>
    80000a38:	84aa                	mv	s1,a0
    80000a3a:	00045797          	auipc	a5,0x45
    80000a3e:	5c678793          	addi	a5,a5,1478 # 80046000 <end>
    80000a42:	04f56e63          	bltu	a0,a5,80000a9e <kfree+0x7a>
    80000a46:	47c5                	li	a5,17
    80000a48:	07ee                	slli	a5,a5,0x1b
    80000a4a:	04f57a63          	bgeu	a0,a5,80000a9e <kfree+0x7a>
    panic("kfree");

acquire(&pgreflock);
    80000a4e:	00011517          	auipc	a0,0x11
    80000a52:	ee250513          	addi	a0,a0,-286 # 80011930 <pgreflock>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	344080e7          	jalr	836(ra) # 80000d9a <acquire>
if(--PA2PGERF(pa)<=0){
    80000a5e:	800007b7          	lui	a5,0x80000
    80000a62:	97a6                	add	a5,a5,s1
    80000a64:	83b1                	srli	a5,a5,0xc
    80000a66:	078a                	slli	a5,a5,0x2
    80000a68:	00011717          	auipc	a4,0x11
    80000a6c:	f0070713          	addi	a4,a4,-256 # 80011968 <pageref>
    80000a70:	97ba                	add	a5,a5,a4
    80000a72:	4398                	lw	a4,0(a5)
    80000a74:	377d                	addiw	a4,a4,-1
    80000a76:	0007069b          	sext.w	a3,a4
    80000a7a:	c398                	sw	a4,0(a5)
    80000a7c:	02d05963          	blez	a3,80000aae <kfree+0x8a>
  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
release(&pgreflock);
    80000a80:	00011517          	auipc	a0,0x11
    80000a84:	eb050513          	addi	a0,a0,-336 # 80011930 <pgreflock>
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	3c6080e7          	jalr	966(ra) # 80000e4e <release>
}
    80000a90:	70a2                	ld	ra,40(sp)
    80000a92:	7402                	ld	s0,32(sp)
    80000a94:	64e2                	ld	s1,24(sp)
    80000a96:	6942                	ld	s2,16(sp)
    80000a98:	69a2                	ld	s3,8(sp)
    80000a9a:	6145                	addi	sp,sp,48
    80000a9c:	8082                	ret
    panic("kfree");
    80000a9e:	00007517          	auipc	a0,0x7
    80000aa2:	5c250513          	addi	a0,a0,1474 # 80008060 <digits+0x20>
    80000aa6:	00000097          	auipc	ra,0x0
    80000aaa:	aa2080e7          	jalr	-1374(ra) # 80000548 <panic>
  memset(pa, 1, PGSIZE);
    80000aae:	6605                	lui	a2,0x1
    80000ab0:	4585                	li	a1,1
    80000ab2:	8526                	mv	a0,s1
    80000ab4:	00000097          	auipc	ra,0x0
    80000ab8:	3e2080e7          	jalr	994(ra) # 80000e96 <memset>
  acquire(&kmem.lock);
    80000abc:	00011997          	auipc	s3,0x11
    80000ac0:	e7498993          	addi	s3,s3,-396 # 80011930 <pgreflock>
    80000ac4:	00011917          	auipc	s2,0x11
    80000ac8:	e8490913          	addi	s2,s2,-380 # 80011948 <kmem>
    80000acc:	854a                	mv	a0,s2
    80000ace:	00000097          	auipc	ra,0x0
    80000ad2:	2cc080e7          	jalr	716(ra) # 80000d9a <acquire>
  r->next = kmem.freelist;
    80000ad6:	0309b783          	ld	a5,48(s3)
    80000ada:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000adc:	0299b823          	sd	s1,48(s3)
  release(&kmem.lock);
    80000ae0:	854a                	mv	a0,s2
    80000ae2:	00000097          	auipc	ra,0x0
    80000ae6:	36c080e7          	jalr	876(ra) # 80000e4e <release>
    80000aea:	bf59                	j	80000a80 <kfree+0x5c>

0000000080000aec <freerange>:
{
    80000aec:	7179                	addi	sp,sp,-48
    80000aee:	f406                	sd	ra,40(sp)
    80000af0:	f022                	sd	s0,32(sp)
    80000af2:	ec26                	sd	s1,24(sp)
    80000af4:	e84a                	sd	s2,16(sp)
    80000af6:	e44e                	sd	s3,8(sp)
    80000af8:	e052                	sd	s4,0(sp)
    80000afa:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000afc:	6785                	lui	a5,0x1
    80000afe:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000b02:	94aa                	add	s1,s1,a0
    80000b04:	757d                	lui	a0,0xfffff
    80000b06:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b08:	94be                	add	s1,s1,a5
    80000b0a:	0095ee63          	bltu	a1,s1,80000b26 <freerange+0x3a>
    80000b0e:	892e                	mv	s2,a1
    kfree(p);
    80000b10:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b12:	6985                	lui	s3,0x1
    kfree(p);
    80000b14:	01448533          	add	a0,s1,s4
    80000b18:	00000097          	auipc	ra,0x0
    80000b1c:	f0c080e7          	jalr	-244(ra) # 80000a24 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b20:	94ce                	add	s1,s1,s3
    80000b22:	fe9979e3          	bgeu	s2,s1,80000b14 <freerange+0x28>
}
    80000b26:	70a2                	ld	ra,40(sp)
    80000b28:	7402                	ld	s0,32(sp)
    80000b2a:	64e2                	ld	s1,24(sp)
    80000b2c:	6942                	ld	s2,16(sp)
    80000b2e:	69a2                	ld	s3,8(sp)
    80000b30:	6a02                	ld	s4,0(sp)
    80000b32:	6145                	addi	sp,sp,48
    80000b34:	8082                	ret

0000000080000b36 <kinit>:
{
    80000b36:	1141                	addi	sp,sp,-16
    80000b38:	e406                	sd	ra,8(sp)
    80000b3a:	e022                	sd	s0,0(sp)
    80000b3c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b3e:	00007597          	auipc	a1,0x7
    80000b42:	52a58593          	addi	a1,a1,1322 # 80008068 <digits+0x28>
    80000b46:	00011517          	auipc	a0,0x11
    80000b4a:	e0250513          	addi	a0,a0,-510 # 80011948 <kmem>
    80000b4e:	00000097          	auipc	ra,0x0
    80000b52:	1bc080e7          	jalr	444(ra) # 80000d0a <initlock>
  initlock(&pgreflock, "pgref");
    80000b56:	00007597          	auipc	a1,0x7
    80000b5a:	51a58593          	addi	a1,a1,1306 # 80008070 <digits+0x30>
    80000b5e:	00011517          	auipc	a0,0x11
    80000b62:	dd250513          	addi	a0,a0,-558 # 80011930 <pgreflock>
    80000b66:	00000097          	auipc	ra,0x0
    80000b6a:	1a4080e7          	jalr	420(ra) # 80000d0a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b6e:	45c5                	li	a1,17
    80000b70:	05ee                	slli	a1,a1,0x1b
    80000b72:	00045517          	auipc	a0,0x45
    80000b76:	48e50513          	addi	a0,a0,1166 # 80046000 <end>
    80000b7a:	00000097          	auipc	ra,0x0
    80000b7e:	f72080e7          	jalr	-142(ra) # 80000aec <freerange>
}
    80000b82:	60a2                	ld	ra,8(sp)
    80000b84:	6402                	ld	s0,0(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b94:	00011517          	auipc	a0,0x11
    80000b98:	db450513          	addi	a0,a0,-588 # 80011948 <kmem>
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	1fe080e7          	jalr	510(ra) # 80000d9a <acquire>
  r = kmem.freelist;
    80000ba4:	00011497          	auipc	s1,0x11
    80000ba8:	dbc4b483          	ld	s1,-580(s1) # 80011960 <kmem+0x18>
  if(r)
    80000bac:	c4b9                	beqz	s1,80000bfa <kalloc+0x70>
    kmem.freelist = r->next;
    80000bae:	609c                	ld	a5,0(s1)
    80000bb0:	00011717          	auipc	a4,0x11
    80000bb4:	daf73823          	sd	a5,-592(a4) # 80011960 <kmem+0x18>
  release(&kmem.lock);
    80000bb8:	00011517          	auipc	a0,0x11
    80000bbc:	d9050513          	addi	a0,a0,-624 # 80011948 <kmem>
    80000bc0:	00000097          	auipc	ra,0x0
    80000bc4:	28e080e7          	jalr	654(ra) # 80000e4e <release>

  if(r){
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bc8:	6605                	lui	a2,0x1
    80000bca:	4595                	li	a1,5
    80000bcc:	8526                	mv	a0,s1
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	2c8080e7          	jalr	712(ra) # 80000e96 <memset>
    PA2PGERF(r)=1;
    80000bd6:	800007b7          	lui	a5,0x80000
    80000bda:	97a6                	add	a5,a5,s1
    80000bdc:	83b1                	srli	a5,a5,0xc
    80000bde:	078a                	slli	a5,a5,0x2
    80000be0:	00011717          	auipc	a4,0x11
    80000be4:	d8870713          	addi	a4,a4,-632 # 80011968 <pageref>
    80000be8:	97ba                	add	a5,a5,a4
    80000bea:	4705                	li	a4,1
    80000bec:	c398                	sw	a4,0(a5)
  }
  return (void*)r;
}
    80000bee:	8526                	mv	a0,s1
    80000bf0:	60e2                	ld	ra,24(sp)
    80000bf2:	6442                	ld	s0,16(sp)
    80000bf4:	64a2                	ld	s1,8(sp)
    80000bf6:	6105                	addi	sp,sp,32
    80000bf8:	8082                	ret
  release(&kmem.lock);
    80000bfa:	00011517          	auipc	a0,0x11
    80000bfe:	d4e50513          	addi	a0,a0,-690 # 80011948 <kmem>
    80000c02:	00000097          	auipc	ra,0x0
    80000c06:	24c080e7          	jalr	588(ra) # 80000e4e <release>
  if(r){
    80000c0a:	b7d5                	j	80000bee <kalloc+0x64>

0000000080000c0c <krefpage>:
//计数
void krefpage(void *pa)
{
    80000c0c:	1101                	addi	sp,sp,-32
    80000c0e:	ec06                	sd	ra,24(sp)
    80000c10:	e822                	sd	s0,16(sp)
    80000c12:	e426                	sd	s1,8(sp)
    80000c14:	e04a                	sd	s2,0(sp)
    80000c16:	1000                	addi	s0,sp,32
    80000c18:	84aa                	mv	s1,a0
    acquire(&pgreflock);
    80000c1a:	00011917          	auipc	s2,0x11
    80000c1e:	d1690913          	addi	s2,s2,-746 # 80011930 <pgreflock>
    80000c22:	854a                	mv	a0,s2
    80000c24:	00000097          	auipc	ra,0x0
    80000c28:	176080e7          	jalr	374(ra) # 80000d9a <acquire>
    PA2PGERF(pa)++;
    80000c2c:	80000537          	lui	a0,0x80000
    80000c30:	94aa                	add	s1,s1,a0
    80000c32:	80b1                	srli	s1,s1,0xc
    80000c34:	048a                	slli	s1,s1,0x2
    80000c36:	00011797          	auipc	a5,0x11
    80000c3a:	d3278793          	addi	a5,a5,-718 # 80011968 <pageref>
    80000c3e:	94be                	add	s1,s1,a5
    80000c40:	409c                	lw	a5,0(s1)
    80000c42:	2785                	addiw	a5,a5,1
    80000c44:	c09c                	sw	a5,0(s1)
    release(&pgreflock);
    80000c46:	854a                	mv	a0,s2
    80000c48:	00000097          	auipc	ra,0x0
    80000c4c:	206080e7          	jalr	518(ra) # 80000e4e <release>
}
    80000c50:	60e2                	ld	ra,24(sp)
    80000c52:	6442                	ld	s0,16(sp)
    80000c54:	64a2                	ld	s1,8(sp)
    80000c56:	6902                	ld	s2,0(sp)
    80000c58:	6105                	addi	sp,sp,32
    80000c5a:	8082                	ret

0000000080000c5c <kcopy_n_deref>:
void *kcopy_n_deref(void *pa)
{
    80000c5c:	7179                	addi	sp,sp,-48
    80000c5e:	f406                	sd	ra,40(sp)
    80000c60:	f022                	sd	s0,32(sp)
    80000c62:	ec26                	sd	s1,24(sp)
    80000c64:	e84a                	sd	s2,16(sp)
    80000c66:	e44e                	sd	s3,8(sp)
    80000c68:	1800                	addi	s0,sp,48
    80000c6a:	892a                	mv	s2,a0
    acquire(&pgreflock);
    80000c6c:	00011517          	auipc	a0,0x11
    80000c70:	cc450513          	addi	a0,a0,-828 # 80011930 <pgreflock>
    80000c74:	00000097          	auipc	ra,0x0
    80000c78:	126080e7          	jalr	294(ra) # 80000d9a <acquire>
    if(PA2PGERF(pa) <= 1)
    80000c7c:	800004b7          	lui	s1,0x80000
    80000c80:	94ca                	add	s1,s1,s2
    80000c82:	80b1                	srli	s1,s1,0xc
    80000c84:	00249713          	slli	a4,s1,0x2
    80000c88:	00011797          	auipc	a5,0x11
    80000c8c:	ce078793          	addi	a5,a5,-800 # 80011968 <pageref>
    80000c90:	97ba                	add	a5,a5,a4
    80000c92:	4398                	lw	a4,0(a5)
    80000c94:	4785                	li	a5,1
    80000c96:	04e7d763          	bge	a5,a4,80000ce4 <kcopy_n_deref+0x88>
    {
        release(&pgreflock);
        return pa;
    }
    // 分配新的内存页，并复制旧页中的数据到新页
    uint64 newpa = (uint64)kalloc();
    80000c9a:	00000097          	auipc	ra,0x0
    80000c9e:	ef0080e7          	jalr	-272(ra) # 80000b8a <kalloc>
    80000ca2:	89aa                	mv	s3,a0
    if(newpa == 0)
    80000ca4:	c931                	beqz	a0,80000cf8 <kcopy_n_deref+0x9c>
    {
        release(&pgreflock);
        return 0;
    }
    memmove((void *)newpa, (void *)pa, PGSIZE);
    80000ca6:	6605                	lui	a2,0x1
    80000ca8:	85ca                	mv	a1,s2
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	24c080e7          	jalr	588(ra) # 80000ef6 <memmove>
    PA2PGERF(pa)--;
    80000cb2:	048a                	slli	s1,s1,0x2
    80000cb4:	00011797          	auipc	a5,0x11
    80000cb8:	cb478793          	addi	a5,a5,-844 # 80011968 <pageref>
    80000cbc:	94be                	add	s1,s1,a5
    80000cbe:	409c                	lw	a5,0(s1)
    80000cc0:	37fd                	addiw	a5,a5,-1
    80000cc2:	c09c                	sw	a5,0(s1)
    release(&pgreflock);
    80000cc4:	00011517          	auipc	a0,0x11
    80000cc8:	c6c50513          	addi	a0,a0,-916 # 80011930 <pgreflock>
    80000ccc:	00000097          	auipc	ra,0x0
    80000cd0:	182080e7          	jalr	386(ra) # 80000e4e <release>
    return (void *)newpa;
}
    80000cd4:	854e                	mv	a0,s3
    80000cd6:	70a2                	ld	ra,40(sp)
    80000cd8:	7402                	ld	s0,32(sp)
    80000cda:	64e2                	ld	s1,24(sp)
    80000cdc:	6942                	ld	s2,16(sp)
    80000cde:	69a2                	ld	s3,8(sp)
    80000ce0:	6145                	addi	sp,sp,48
    80000ce2:	8082                	ret
        release(&pgreflock);
    80000ce4:	00011517          	auipc	a0,0x11
    80000ce8:	c4c50513          	addi	a0,a0,-948 # 80011930 <pgreflock>
    80000cec:	00000097          	auipc	ra,0x0
    80000cf0:	162080e7          	jalr	354(ra) # 80000e4e <release>
        return pa;
    80000cf4:	89ca                	mv	s3,s2
    80000cf6:	bff9                	j	80000cd4 <kcopy_n_deref+0x78>
        release(&pgreflock);
    80000cf8:	00011517          	auipc	a0,0x11
    80000cfc:	c3850513          	addi	a0,a0,-968 # 80011930 <pgreflock>
    80000d00:	00000097          	auipc	ra,0x0
    80000d04:	14e080e7          	jalr	334(ra) # 80000e4e <release>
        return 0;
    80000d08:	b7f1                	j	80000cd4 <kcopy_n_deref+0x78>

0000000080000d0a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000d0a:	1141                	addi	sp,sp,-16
    80000d0c:	e422                	sd	s0,8(sp)
    80000d0e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000d10:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d12:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d16:	00053823          	sd	zero,16(a0)
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret

0000000080000d20 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d20:	411c                	lw	a5,0(a0)
    80000d22:	e399                	bnez	a5,80000d28 <holding+0x8>
    80000d24:	4501                	li	a0,0
  return r;
}
    80000d26:	8082                	ret
{
    80000d28:	1101                	addi	sp,sp,-32
    80000d2a:	ec06                	sd	ra,24(sp)
    80000d2c:	e822                	sd	s0,16(sp)
    80000d2e:	e426                	sd	s1,8(sp)
    80000d30:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d32:	6904                	ld	s1,16(a0)
    80000d34:	00001097          	auipc	ra,0x1
    80000d38:	f36080e7          	jalr	-202(ra) # 80001c6a <mycpu>
    80000d3c:	40a48533          	sub	a0,s1,a0
    80000d40:	00153513          	seqz	a0,a0
}
    80000d44:	60e2                	ld	ra,24(sp)
    80000d46:	6442                	ld	s0,16(sp)
    80000d48:	64a2                	ld	s1,8(sp)
    80000d4a:	6105                	addi	sp,sp,32
    80000d4c:	8082                	ret

0000000080000d4e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d4e:	1101                	addi	sp,sp,-32
    80000d50:	ec06                	sd	ra,24(sp)
    80000d52:	e822                	sd	s0,16(sp)
    80000d54:	e426                	sd	s1,8(sp)
    80000d56:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d58:	100024f3          	csrr	s1,sstatus
    80000d5c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d60:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d62:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000d66:	00001097          	auipc	ra,0x1
    80000d6a:	f04080e7          	jalr	-252(ra) # 80001c6a <mycpu>
    80000d6e:	5d3c                	lw	a5,120(a0)
    80000d70:	cf89                	beqz	a5,80000d8a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d72:	00001097          	auipc	ra,0x1
    80000d76:	ef8080e7          	jalr	-264(ra) # 80001c6a <mycpu>
    80000d7a:	5d3c                	lw	a5,120(a0)
    80000d7c:	2785                	addiw	a5,a5,1
    80000d7e:	dd3c                	sw	a5,120(a0)
}
    80000d80:	60e2                	ld	ra,24(sp)
    80000d82:	6442                	ld	s0,16(sp)
    80000d84:	64a2                	ld	s1,8(sp)
    80000d86:	6105                	addi	sp,sp,32
    80000d88:	8082                	ret
    mycpu()->intena = old;
    80000d8a:	00001097          	auipc	ra,0x1
    80000d8e:	ee0080e7          	jalr	-288(ra) # 80001c6a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d92:	8085                	srli	s1,s1,0x1
    80000d94:	8885                	andi	s1,s1,1
    80000d96:	dd64                	sw	s1,124(a0)
    80000d98:	bfe9                	j	80000d72 <push_off+0x24>

0000000080000d9a <acquire>:
{
    80000d9a:	1101                	addi	sp,sp,-32
    80000d9c:	ec06                	sd	ra,24(sp)
    80000d9e:	e822                	sd	s0,16(sp)
    80000da0:	e426                	sd	s1,8(sp)
    80000da2:	1000                	addi	s0,sp,32
    80000da4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000da6:	00000097          	auipc	ra,0x0
    80000daa:	fa8080e7          	jalr	-88(ra) # 80000d4e <push_off>
  if(holding(lk))
    80000dae:	8526                	mv	a0,s1
    80000db0:	00000097          	auipc	ra,0x0
    80000db4:	f70080e7          	jalr	-144(ra) # 80000d20 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000db8:	4705                	li	a4,1
  if(holding(lk))
    80000dba:	e115                	bnez	a0,80000dde <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000dbc:	87ba                	mv	a5,a4
    80000dbe:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000dc2:	2781                	sext.w	a5,a5
    80000dc4:	ffe5                	bnez	a5,80000dbc <acquire+0x22>
  __sync_synchronize();
    80000dc6:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000dca:	00001097          	auipc	ra,0x1
    80000dce:	ea0080e7          	jalr	-352(ra) # 80001c6a <mycpu>
    80000dd2:	e888                	sd	a0,16(s1)
}
    80000dd4:	60e2                	ld	ra,24(sp)
    80000dd6:	6442                	ld	s0,16(sp)
    80000dd8:	64a2                	ld	s1,8(sp)
    80000dda:	6105                	addi	sp,sp,32
    80000ddc:	8082                	ret
    panic("acquire");
    80000dde:	00007517          	auipc	a0,0x7
    80000de2:	29a50513          	addi	a0,a0,666 # 80008078 <digits+0x38>
    80000de6:	fffff097          	auipc	ra,0xfffff
    80000dea:	762080e7          	jalr	1890(ra) # 80000548 <panic>

0000000080000dee <pop_off>:

void
pop_off(void)
{
    80000dee:	1141                	addi	sp,sp,-16
    80000df0:	e406                	sd	ra,8(sp)
    80000df2:	e022                	sd	s0,0(sp)
    80000df4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000df6:	00001097          	auipc	ra,0x1
    80000dfa:	e74080e7          	jalr	-396(ra) # 80001c6a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dfe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e02:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e04:	e78d                	bnez	a5,80000e2e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e06:	5d3c                	lw	a5,120(a0)
    80000e08:	02f05b63          	blez	a5,80000e3e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	0007871b          	sext.w	a4,a5
    80000e12:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e14:	eb09                	bnez	a4,80000e26 <pop_off+0x38>
    80000e16:	5d7c                	lw	a5,124(a0)
    80000e18:	c799                	beqz	a5,80000e26 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e1a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e1e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e22:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e26:	60a2                	ld	ra,8(sp)
    80000e28:	6402                	ld	s0,0(sp)
    80000e2a:	0141                	addi	sp,sp,16
    80000e2c:	8082                	ret
    panic("pop_off - interruptible");
    80000e2e:	00007517          	auipc	a0,0x7
    80000e32:	25250513          	addi	a0,a0,594 # 80008080 <digits+0x40>
    80000e36:	fffff097          	auipc	ra,0xfffff
    80000e3a:	712080e7          	jalr	1810(ra) # 80000548 <panic>
    panic("pop_off");
    80000e3e:	00007517          	auipc	a0,0x7
    80000e42:	25a50513          	addi	a0,a0,602 # 80008098 <digits+0x58>
    80000e46:	fffff097          	auipc	ra,0xfffff
    80000e4a:	702080e7          	jalr	1794(ra) # 80000548 <panic>

0000000080000e4e <release>:
{
    80000e4e:	1101                	addi	sp,sp,-32
    80000e50:	ec06                	sd	ra,24(sp)
    80000e52:	e822                	sd	s0,16(sp)
    80000e54:	e426                	sd	s1,8(sp)
    80000e56:	1000                	addi	s0,sp,32
    80000e58:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e5a:	00000097          	auipc	ra,0x0
    80000e5e:	ec6080e7          	jalr	-314(ra) # 80000d20 <holding>
    80000e62:	c115                	beqz	a0,80000e86 <release+0x38>
  lk->cpu = 0;
    80000e64:	0004b823          	sd	zero,16(s1) # ffffffff80000010 <end+0xfffffffefffba010>
  __sync_synchronize();
    80000e68:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e6c:	0f50000f          	fence	iorw,ow
    80000e70:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e74:	00000097          	auipc	ra,0x0
    80000e78:	f7a080e7          	jalr	-134(ra) # 80000dee <pop_off>
}
    80000e7c:	60e2                	ld	ra,24(sp)
    80000e7e:	6442                	ld	s0,16(sp)
    80000e80:	64a2                	ld	s1,8(sp)
    80000e82:	6105                	addi	sp,sp,32
    80000e84:	8082                	ret
    panic("release");
    80000e86:	00007517          	auipc	a0,0x7
    80000e8a:	21a50513          	addi	a0,a0,538 # 800080a0 <digits+0x60>
    80000e8e:	fffff097          	auipc	ra,0xfffff
    80000e92:	6ba080e7          	jalr	1722(ra) # 80000548 <panic>

0000000080000e96 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e96:	1141                	addi	sp,sp,-16
    80000e98:	e422                	sd	s0,8(sp)
    80000e9a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e9c:	ce09                	beqz	a2,80000eb6 <memset+0x20>
    80000e9e:	87aa                	mv	a5,a0
    80000ea0:	fff6071b          	addiw	a4,a2,-1
    80000ea4:	1702                	slli	a4,a4,0x20
    80000ea6:	9301                	srli	a4,a4,0x20
    80000ea8:	0705                	addi	a4,a4,1
    80000eaa:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000eac:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000eb0:	0785                	addi	a5,a5,1
    80000eb2:	fee79de3          	bne	a5,a4,80000eac <memset+0x16>
  }
  return dst;
}
    80000eb6:	6422                	ld	s0,8(sp)
    80000eb8:	0141                	addi	sp,sp,16
    80000eba:	8082                	ret

0000000080000ebc <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ebc:	1141                	addi	sp,sp,-16
    80000ebe:	e422                	sd	s0,8(sp)
    80000ec0:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ec2:	ca05                	beqz	a2,80000ef2 <memcmp+0x36>
    80000ec4:	fff6069b          	addiw	a3,a2,-1
    80000ec8:	1682                	slli	a3,a3,0x20
    80000eca:	9281                	srli	a3,a3,0x20
    80000ecc:	0685                	addi	a3,a3,1
    80000ece:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000ed0:	00054783          	lbu	a5,0(a0)
    80000ed4:	0005c703          	lbu	a4,0(a1)
    80000ed8:	00e79863          	bne	a5,a4,80000ee8 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000edc:	0505                	addi	a0,a0,1
    80000ede:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ee0:	fed518e3          	bne	a0,a3,80000ed0 <memcmp+0x14>
  }

  return 0;
    80000ee4:	4501                	li	a0,0
    80000ee6:	a019                	j	80000eec <memcmp+0x30>
      return *s1 - *s2;
    80000ee8:	40e7853b          	subw	a0,a5,a4
}
    80000eec:	6422                	ld	s0,8(sp)
    80000eee:	0141                	addi	sp,sp,16
    80000ef0:	8082                	ret
  return 0;
    80000ef2:	4501                	li	a0,0
    80000ef4:	bfe5                	j	80000eec <memcmp+0x30>

0000000080000ef6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000ef6:	1141                	addi	sp,sp,-16
    80000ef8:	e422                	sd	s0,8(sp)
    80000efa:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000efc:	00a5f963          	bgeu	a1,a0,80000f0e <memmove+0x18>
    80000f00:	02061713          	slli	a4,a2,0x20
    80000f04:	9301                	srli	a4,a4,0x20
    80000f06:	00e587b3          	add	a5,a1,a4
    80000f0a:	02f56563          	bltu	a0,a5,80000f34 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f0e:	fff6069b          	addiw	a3,a2,-1
    80000f12:	ce11                	beqz	a2,80000f2e <memmove+0x38>
    80000f14:	1682                	slli	a3,a3,0x20
    80000f16:	9281                	srli	a3,a3,0x20
    80000f18:	0685                	addi	a3,a3,1
    80000f1a:	96ae                	add	a3,a3,a1
    80000f1c:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000f1e:	0585                	addi	a1,a1,1
    80000f20:	0785                	addi	a5,a5,1
    80000f22:	fff5c703          	lbu	a4,-1(a1)
    80000f26:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000f2a:	fed59ae3          	bne	a1,a3,80000f1e <memmove+0x28>

  return dst;
}
    80000f2e:	6422                	ld	s0,8(sp)
    80000f30:	0141                	addi	sp,sp,16
    80000f32:	8082                	ret
    d += n;
    80000f34:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000f36:	fff6069b          	addiw	a3,a2,-1
    80000f3a:	da75                	beqz	a2,80000f2e <memmove+0x38>
    80000f3c:	02069613          	slli	a2,a3,0x20
    80000f40:	9201                	srli	a2,a2,0x20
    80000f42:	fff64613          	not	a2,a2
    80000f46:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000f48:	17fd                	addi	a5,a5,-1
    80000f4a:	177d                	addi	a4,a4,-1
    80000f4c:	0007c683          	lbu	a3,0(a5)
    80000f50:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000f54:	fec79ae3          	bne	a5,a2,80000f48 <memmove+0x52>
    80000f58:	bfd9                	j	80000f2e <memmove+0x38>

0000000080000f5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f5a:	1141                	addi	sp,sp,-16
    80000f5c:	e406                	sd	ra,8(sp)
    80000f5e:	e022                	sd	s0,0(sp)
    80000f60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f62:	00000097          	auipc	ra,0x0
    80000f66:	f94080e7          	jalr	-108(ra) # 80000ef6 <memmove>
}
    80000f6a:	60a2                	ld	ra,8(sp)
    80000f6c:	6402                	ld	s0,0(sp)
    80000f6e:	0141                	addi	sp,sp,16
    80000f70:	8082                	ret

0000000080000f72 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f72:	1141                	addi	sp,sp,-16
    80000f74:	e422                	sd	s0,8(sp)
    80000f76:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f78:	ce11                	beqz	a2,80000f94 <strncmp+0x22>
    80000f7a:	00054783          	lbu	a5,0(a0)
    80000f7e:	cf89                	beqz	a5,80000f98 <strncmp+0x26>
    80000f80:	0005c703          	lbu	a4,0(a1)
    80000f84:	00f71a63          	bne	a4,a5,80000f98 <strncmp+0x26>
    n--, p++, q++;
    80000f88:	367d                	addiw	a2,a2,-1
    80000f8a:	0505                	addi	a0,a0,1
    80000f8c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000f8e:	f675                	bnez	a2,80000f7a <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f90:	4501                	li	a0,0
    80000f92:	a809                	j	80000fa4 <strncmp+0x32>
    80000f94:	4501                	li	a0,0
    80000f96:	a039                	j	80000fa4 <strncmp+0x32>
  if(n == 0)
    80000f98:	ca09                	beqz	a2,80000faa <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f9a:	00054503          	lbu	a0,0(a0)
    80000f9e:	0005c783          	lbu	a5,0(a1)
    80000fa2:	9d1d                	subw	a0,a0,a5
}
    80000fa4:	6422                	ld	s0,8(sp)
    80000fa6:	0141                	addi	sp,sp,16
    80000fa8:	8082                	ret
    return 0;
    80000faa:	4501                	li	a0,0
    80000fac:	bfe5                	j	80000fa4 <strncmp+0x32>

0000000080000fae <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000fae:	1141                	addi	sp,sp,-16
    80000fb0:	e422                	sd	s0,8(sp)
    80000fb2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000fb4:	872a                	mv	a4,a0
    80000fb6:	8832                	mv	a6,a2
    80000fb8:	367d                	addiw	a2,a2,-1
    80000fba:	01005963          	blez	a6,80000fcc <strncpy+0x1e>
    80000fbe:	0705                	addi	a4,a4,1
    80000fc0:	0005c783          	lbu	a5,0(a1)
    80000fc4:	fef70fa3          	sb	a5,-1(a4)
    80000fc8:	0585                	addi	a1,a1,1
    80000fca:	f7f5                	bnez	a5,80000fb6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000fcc:	00c05d63          	blez	a2,80000fe6 <strncpy+0x38>
    80000fd0:	86ba                	mv	a3,a4
    *s++ = 0;
    80000fd2:	0685                	addi	a3,a3,1
    80000fd4:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000fd8:	fff6c793          	not	a5,a3
    80000fdc:	9fb9                	addw	a5,a5,a4
    80000fde:	010787bb          	addw	a5,a5,a6
    80000fe2:	fef048e3          	bgtz	a5,80000fd2 <strncpy+0x24>
  return os;
}
    80000fe6:	6422                	ld	s0,8(sp)
    80000fe8:	0141                	addi	sp,sp,16
    80000fea:	8082                	ret

0000000080000fec <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000fec:	1141                	addi	sp,sp,-16
    80000fee:	e422                	sd	s0,8(sp)
    80000ff0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ff2:	02c05363          	blez	a2,80001018 <safestrcpy+0x2c>
    80000ff6:	fff6069b          	addiw	a3,a2,-1
    80000ffa:	1682                	slli	a3,a3,0x20
    80000ffc:	9281                	srli	a3,a3,0x20
    80000ffe:	96ae                	add	a3,a3,a1
    80001000:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001002:	00d58963          	beq	a1,a3,80001014 <safestrcpy+0x28>
    80001006:	0585                	addi	a1,a1,1
    80001008:	0785                	addi	a5,a5,1
    8000100a:	fff5c703          	lbu	a4,-1(a1)
    8000100e:	fee78fa3          	sb	a4,-1(a5)
    80001012:	fb65                	bnez	a4,80001002 <safestrcpy+0x16>
    ;
  *s = 0;
    80001014:	00078023          	sb	zero,0(a5)
  return os;
}
    80001018:	6422                	ld	s0,8(sp)
    8000101a:	0141                	addi	sp,sp,16
    8000101c:	8082                	ret

000000008000101e <strlen>:

int
strlen(const char *s)
{
    8000101e:	1141                	addi	sp,sp,-16
    80001020:	e422                	sd	s0,8(sp)
    80001022:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001024:	00054783          	lbu	a5,0(a0)
    80001028:	cf91                	beqz	a5,80001044 <strlen+0x26>
    8000102a:	0505                	addi	a0,a0,1
    8000102c:	87aa                	mv	a5,a0
    8000102e:	4685                	li	a3,1
    80001030:	9e89                	subw	a3,a3,a0
    80001032:	00f6853b          	addw	a0,a3,a5
    80001036:	0785                	addi	a5,a5,1
    80001038:	fff7c703          	lbu	a4,-1(a5)
    8000103c:	fb7d                	bnez	a4,80001032 <strlen+0x14>
    ;
  return n;
}
    8000103e:	6422                	ld	s0,8(sp)
    80001040:	0141                	addi	sp,sp,16
    80001042:	8082                	ret
  for(n = 0; s[n]; n++)
    80001044:	4501                	li	a0,0
    80001046:	bfe5                	j	8000103e <strlen+0x20>

0000000080001048 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001048:	1141                	addi	sp,sp,-16
    8000104a:	e406                	sd	ra,8(sp)
    8000104c:	e022                	sd	s0,0(sp)
    8000104e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001050:	00001097          	auipc	ra,0x1
    80001054:	c0a080e7          	jalr	-1014(ra) # 80001c5a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001058:	00008717          	auipc	a4,0x8
    8000105c:	fb470713          	addi	a4,a4,-76 # 8000900c <started>
  if(cpuid() == 0){
    80001060:	c139                	beqz	a0,800010a6 <main+0x5e>
    while(started == 0)
    80001062:	431c                	lw	a5,0(a4)
    80001064:	2781                	sext.w	a5,a5
    80001066:	dff5                	beqz	a5,80001062 <main+0x1a>
      ;
    __sync_synchronize();
    80001068:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000106c:	00001097          	auipc	ra,0x1
    80001070:	bee080e7          	jalr	-1042(ra) # 80001c5a <cpuid>
    80001074:	85aa                	mv	a1,a0
    80001076:	00007517          	auipc	a0,0x7
    8000107a:	04a50513          	addi	a0,a0,74 # 800080c0 <digits+0x80>
    8000107e:	fffff097          	auipc	ra,0xfffff
    80001082:	514080e7          	jalr	1300(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80001086:	00000097          	auipc	ra,0x0
    8000108a:	0d8080e7          	jalr	216(ra) # 8000115e <kvminithart>
    trapinithart();   // install kernel trap vector
    8000108e:	00002097          	auipc	ra,0x2
    80001092:	856080e7          	jalr	-1962(ra) # 800028e4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001096:	00005097          	auipc	ra,0x5
    8000109a:	e2a080e7          	jalr	-470(ra) # 80005ec0 <plicinithart>
  }

  scheduler();        
    8000109e:	00001097          	auipc	ra,0x1
    800010a2:	118080e7          	jalr	280(ra) # 800021b6 <scheduler>
    consoleinit();
    800010a6:	fffff097          	auipc	ra,0xfffff
    800010aa:	3b4080e7          	jalr	948(ra) # 8000045a <consoleinit>
    printfinit();
    800010ae:	fffff097          	auipc	ra,0xfffff
    800010b2:	6ca080e7          	jalr	1738(ra) # 80000778 <printfinit>
    printf("\n");
    800010b6:	00007517          	auipc	a0,0x7
    800010ba:	01a50513          	addi	a0,a0,26 # 800080d0 <digits+0x90>
    800010be:	fffff097          	auipc	ra,0xfffff
    800010c2:	4d4080e7          	jalr	1236(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    800010c6:	00007517          	auipc	a0,0x7
    800010ca:	fe250513          	addi	a0,a0,-30 # 800080a8 <digits+0x68>
    800010ce:	fffff097          	auipc	ra,0xfffff
    800010d2:	4c4080e7          	jalr	1220(ra) # 80000592 <printf>
    printf("\n");
    800010d6:	00007517          	auipc	a0,0x7
    800010da:	ffa50513          	addi	a0,a0,-6 # 800080d0 <digits+0x90>
    800010de:	fffff097          	auipc	ra,0xfffff
    800010e2:	4b4080e7          	jalr	1204(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    800010e6:	00000097          	auipc	ra,0x0
    800010ea:	a50080e7          	jalr	-1456(ra) # 80000b36 <kinit>
    kvminit();       // create kernel page table
    800010ee:	00000097          	auipc	ra,0x0
    800010f2:	2a0080e7          	jalr	672(ra) # 8000138e <kvminit>
    kvminithart();   // turn on paging
    800010f6:	00000097          	auipc	ra,0x0
    800010fa:	068080e7          	jalr	104(ra) # 8000115e <kvminithart>
    procinit();      // process table
    800010fe:	00001097          	auipc	ra,0x1
    80001102:	a8c080e7          	jalr	-1396(ra) # 80001b8a <procinit>
    trapinit();      // trap vectors
    80001106:	00001097          	auipc	ra,0x1
    8000110a:	7b6080e7          	jalr	1974(ra) # 800028bc <trapinit>
    trapinithart();  // install kernel trap vector
    8000110e:	00001097          	auipc	ra,0x1
    80001112:	7d6080e7          	jalr	2006(ra) # 800028e4 <trapinithart>
    plicinit();      // set up interrupt controller
    80001116:	00005097          	auipc	ra,0x5
    8000111a:	d94080e7          	jalr	-620(ra) # 80005eaa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000111e:	00005097          	auipc	ra,0x5
    80001122:	da2080e7          	jalr	-606(ra) # 80005ec0 <plicinithart>
    binit();         // buffer cache
    80001126:	00002097          	auipc	ra,0x2
    8000112a:	f44080e7          	jalr	-188(ra) # 8000306a <binit>
    iinit();         // inode cache
    8000112e:	00002097          	auipc	ra,0x2
    80001132:	5d4080e7          	jalr	1492(ra) # 80003702 <iinit>
    fileinit();      // file table
    80001136:	00003097          	auipc	ra,0x3
    8000113a:	572080e7          	jalr	1394(ra) # 800046a8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000113e:	00005097          	auipc	ra,0x5
    80001142:	e8a080e7          	jalr	-374(ra) # 80005fc8 <virtio_disk_init>
    userinit();      // first user process
    80001146:	00001097          	auipc	ra,0x1
    8000114a:	e0a080e7          	jalr	-502(ra) # 80001f50 <userinit>
    __sync_synchronize();
    8000114e:	0ff0000f          	fence
    started = 1;
    80001152:	4785                	li	a5,1
    80001154:	00008717          	auipc	a4,0x8
    80001158:	eaf72c23          	sw	a5,-328(a4) # 8000900c <started>
    8000115c:	b789                	j	8000109e <main+0x56>

000000008000115e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000115e:	1141                	addi	sp,sp,-16
    80001160:	e422                	sd	s0,8(sp)
    80001162:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001164:	00008797          	auipc	a5,0x8
    80001168:	eac7b783          	ld	a5,-340(a5) # 80009010 <kernel_pagetable>
    8000116c:	83b1                	srli	a5,a5,0xc
    8000116e:	577d                	li	a4,-1
    80001170:	177e                	slli	a4,a4,0x3f
    80001172:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001174:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001178:	12000073          	sfence.vma
  sfence_vma();
}
    8000117c:	6422                	ld	s0,8(sp)
    8000117e:	0141                	addi	sp,sp,16
    80001180:	8082                	ret

0000000080001182 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001182:	7139                	addi	sp,sp,-64
    80001184:	fc06                	sd	ra,56(sp)
    80001186:	f822                	sd	s0,48(sp)
    80001188:	f426                	sd	s1,40(sp)
    8000118a:	f04a                	sd	s2,32(sp)
    8000118c:	ec4e                	sd	s3,24(sp)
    8000118e:	e852                	sd	s4,16(sp)
    80001190:	e456                	sd	s5,8(sp)
    80001192:	e05a                	sd	s6,0(sp)
    80001194:	0080                	addi	s0,sp,64
    80001196:	84aa                	mv	s1,a0
    80001198:	89ae                	mv	s3,a1
    8000119a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000119c:	57fd                	li	a5,-1
    8000119e:	83e9                	srli	a5,a5,0x1a
    800011a0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800011a2:	4b31                	li	s6,12
  if(va >= MAXVA)
    800011a4:	04b7f263          	bgeu	a5,a1,800011e8 <walk+0x66>
    panic("walk");
    800011a8:	00007517          	auipc	a0,0x7
    800011ac:	f3050513          	addi	a0,a0,-208 # 800080d8 <digits+0x98>
    800011b0:	fffff097          	auipc	ra,0xfffff
    800011b4:	398080e7          	jalr	920(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800011b8:	060a8663          	beqz	s5,80001224 <walk+0xa2>
    800011bc:	00000097          	auipc	ra,0x0
    800011c0:	9ce080e7          	jalr	-1586(ra) # 80000b8a <kalloc>
    800011c4:	84aa                	mv	s1,a0
    800011c6:	c529                	beqz	a0,80001210 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800011c8:	6605                	lui	a2,0x1
    800011ca:	4581                	li	a1,0
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	cca080e7          	jalr	-822(ra) # 80000e96 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800011d4:	00c4d793          	srli	a5,s1,0xc
    800011d8:	07aa                	slli	a5,a5,0xa
    800011da:	0017e793          	ori	a5,a5,1
    800011de:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800011e2:	3a5d                	addiw	s4,s4,-9
    800011e4:	036a0063          	beq	s4,s6,80001204 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800011e8:	0149d933          	srl	s2,s3,s4
    800011ec:	1ff97913          	andi	s2,s2,511
    800011f0:	090e                	slli	s2,s2,0x3
    800011f2:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800011f4:	00093483          	ld	s1,0(s2)
    800011f8:	0014f793          	andi	a5,s1,1
    800011fc:	dfd5                	beqz	a5,800011b8 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800011fe:	80a9                	srli	s1,s1,0xa
    80001200:	04b2                	slli	s1,s1,0xc
    80001202:	b7c5                	j	800011e2 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001204:	00c9d513          	srli	a0,s3,0xc
    80001208:	1ff57513          	andi	a0,a0,511
    8000120c:	050e                	slli	a0,a0,0x3
    8000120e:	9526                	add	a0,a0,s1
}
    80001210:	70e2                	ld	ra,56(sp)
    80001212:	7442                	ld	s0,48(sp)
    80001214:	74a2                	ld	s1,40(sp)
    80001216:	7902                	ld	s2,32(sp)
    80001218:	69e2                	ld	s3,24(sp)
    8000121a:	6a42                	ld	s4,16(sp)
    8000121c:	6aa2                	ld	s5,8(sp)
    8000121e:	6b02                	ld	s6,0(sp)
    80001220:	6121                	addi	sp,sp,64
    80001222:	8082                	ret
        return 0;
    80001224:	4501                	li	a0,0
    80001226:	b7ed                	j	80001210 <walk+0x8e>

0000000080001228 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001228:	57fd                	li	a5,-1
    8000122a:	83e9                	srli	a5,a5,0x1a
    8000122c:	00b7f463          	bgeu	a5,a1,80001234 <walkaddr+0xc>
    return 0;
    80001230:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001232:	8082                	ret
{
    80001234:	1141                	addi	sp,sp,-16
    80001236:	e406                	sd	ra,8(sp)
    80001238:	e022                	sd	s0,0(sp)
    8000123a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000123c:	4601                	li	a2,0
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	f44080e7          	jalr	-188(ra) # 80001182 <walk>
  if(pte == 0)
    80001246:	c105                	beqz	a0,80001266 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001248:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000124a:	0117f693          	andi	a3,a5,17
    8000124e:	4745                	li	a4,17
    return 0;
    80001250:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001252:	00e68663          	beq	a3,a4,8000125e <walkaddr+0x36>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	addi	sp,sp,16
    8000125c:	8082                	ret
  pa = PTE2PA(*pte);
    8000125e:	00a7d513          	srli	a0,a5,0xa
    80001262:	0532                	slli	a0,a0,0xc
  return pa;
    80001264:	bfcd                	j	80001256 <walkaddr+0x2e>
    return 0;
    80001266:	4501                	li	a0,0
    80001268:	b7fd                	j	80001256 <walkaddr+0x2e>

000000008000126a <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    8000126a:	1101                	addi	sp,sp,-32
    8000126c:	ec06                	sd	ra,24(sp)
    8000126e:	e822                	sd	s0,16(sp)
    80001270:	e426                	sd	s1,8(sp)
    80001272:	1000                	addi	s0,sp,32
    80001274:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001276:	1552                	slli	a0,a0,0x34
    80001278:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    8000127c:	4601                	li	a2,0
    8000127e:	00008517          	auipc	a0,0x8
    80001282:	d9253503          	ld	a0,-622(a0) # 80009010 <kernel_pagetable>
    80001286:	00000097          	auipc	ra,0x0
    8000128a:	efc080e7          	jalr	-260(ra) # 80001182 <walk>
  if(pte == 0)
    8000128e:	cd09                	beqz	a0,800012a8 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001290:	6108                	ld	a0,0(a0)
    80001292:	00157793          	andi	a5,a0,1
    80001296:	c38d                	beqz	a5,800012b8 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001298:	8129                	srli	a0,a0,0xa
    8000129a:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000129c:	9526                	add	a0,a0,s1
    8000129e:	60e2                	ld	ra,24(sp)
    800012a0:	6442                	ld	s0,16(sp)
    800012a2:	64a2                	ld	s1,8(sp)
    800012a4:	6105                	addi	sp,sp,32
    800012a6:	8082                	ret
    panic("kvmpa");
    800012a8:	00007517          	auipc	a0,0x7
    800012ac:	e3850513          	addi	a0,a0,-456 # 800080e0 <digits+0xa0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	298080e7          	jalr	664(ra) # 80000548 <panic>
    panic("kvmpa");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e2850513          	addi	a0,a0,-472 # 800080e0 <digits+0xa0>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	288080e7          	jalr	648(ra) # 80000548 <panic>

00000000800012c8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800012c8:	715d                	addi	sp,sp,-80
    800012ca:	e486                	sd	ra,72(sp)
    800012cc:	e0a2                	sd	s0,64(sp)
    800012ce:	fc26                	sd	s1,56(sp)
    800012d0:	f84a                	sd	s2,48(sp)
    800012d2:	f44e                	sd	s3,40(sp)
    800012d4:	f052                	sd	s4,32(sp)
    800012d6:	ec56                	sd	s5,24(sp)
    800012d8:	e85a                	sd	s6,16(sp)
    800012da:	e45e                	sd	s7,8(sp)
    800012dc:	0880                	addi	s0,sp,80
    800012de:	8aaa                	mv	s5,a0
    800012e0:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800012e2:	777d                	lui	a4,0xfffff
    800012e4:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800012e8:	167d                	addi	a2,a2,-1
    800012ea:	00b609b3          	add	s3,a2,a1
    800012ee:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800012f2:	893e                	mv	s2,a5
    800012f4:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800012f8:	6b85                	lui	s7,0x1
    800012fa:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800012fe:	4605                	li	a2,1
    80001300:	85ca                	mv	a1,s2
    80001302:	8556                	mv	a0,s5
    80001304:	00000097          	auipc	ra,0x0
    80001308:	e7e080e7          	jalr	-386(ra) # 80001182 <walk>
    8000130c:	c51d                	beqz	a0,8000133a <mappages+0x72>
    if(*pte & PTE_V)
    8000130e:	611c                	ld	a5,0(a0)
    80001310:	8b85                	andi	a5,a5,1
    80001312:	ef81                	bnez	a5,8000132a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001314:	80b1                	srli	s1,s1,0xc
    80001316:	04aa                	slli	s1,s1,0xa
    80001318:	0164e4b3          	or	s1,s1,s6
    8000131c:	0014e493          	ori	s1,s1,1
    80001320:	e104                	sd	s1,0(a0)
    if(a == last)
    80001322:	03390863          	beq	s2,s3,80001352 <mappages+0x8a>
    a += PGSIZE;
    80001326:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001328:	bfc9                	j	800012fa <mappages+0x32>
      panic("remap");
    8000132a:	00007517          	auipc	a0,0x7
    8000132e:	dbe50513          	addi	a0,a0,-578 # 800080e8 <digits+0xa8>
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	216080e7          	jalr	534(ra) # 80000548 <panic>
      return -1;
    8000133a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000133c:	60a6                	ld	ra,72(sp)
    8000133e:	6406                	ld	s0,64(sp)
    80001340:	74e2                	ld	s1,56(sp)
    80001342:	7942                	ld	s2,48(sp)
    80001344:	79a2                	ld	s3,40(sp)
    80001346:	7a02                	ld	s4,32(sp)
    80001348:	6ae2                	ld	s5,24(sp)
    8000134a:	6b42                	ld	s6,16(sp)
    8000134c:	6ba2                	ld	s7,8(sp)
    8000134e:	6161                	addi	sp,sp,80
    80001350:	8082                	ret
  return 0;
    80001352:	4501                	li	a0,0
    80001354:	b7e5                	j	8000133c <mappages+0x74>

0000000080001356 <kvmmap>:
{
    80001356:	1141                	addi	sp,sp,-16
    80001358:	e406                	sd	ra,8(sp)
    8000135a:	e022                	sd	s0,0(sp)
    8000135c:	0800                	addi	s0,sp,16
    8000135e:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001360:	86ae                	mv	a3,a1
    80001362:	85aa                	mv	a1,a0
    80001364:	00008517          	auipc	a0,0x8
    80001368:	cac53503          	ld	a0,-852(a0) # 80009010 <kernel_pagetable>
    8000136c:	00000097          	auipc	ra,0x0
    80001370:	f5c080e7          	jalr	-164(ra) # 800012c8 <mappages>
    80001374:	e509                	bnez	a0,8000137e <kvmmap+0x28>
}
    80001376:	60a2                	ld	ra,8(sp)
    80001378:	6402                	ld	s0,0(sp)
    8000137a:	0141                	addi	sp,sp,16
    8000137c:	8082                	ret
    panic("kvmmap");
    8000137e:	00007517          	auipc	a0,0x7
    80001382:	d7250513          	addi	a0,a0,-654 # 800080f0 <digits+0xb0>
    80001386:	fffff097          	auipc	ra,0xfffff
    8000138a:	1c2080e7          	jalr	450(ra) # 80000548 <panic>

000000008000138e <kvminit>:
{
    8000138e:	1101                	addi	sp,sp,-32
    80001390:	ec06                	sd	ra,24(sp)
    80001392:	e822                	sd	s0,16(sp)
    80001394:	e426                	sd	s1,8(sp)
    80001396:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001398:	fffff097          	auipc	ra,0xfffff
    8000139c:	7f2080e7          	jalr	2034(ra) # 80000b8a <kalloc>
    800013a0:	00008797          	auipc	a5,0x8
    800013a4:	c6a7b823          	sd	a0,-912(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	aea080e7          	jalr	-1302(ra) # 80000e96 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013b4:	4699                	li	a3,6
    800013b6:	6605                	lui	a2,0x1
    800013b8:	100005b7          	lui	a1,0x10000
    800013bc:	10000537          	lui	a0,0x10000
    800013c0:	00000097          	auipc	ra,0x0
    800013c4:	f96080e7          	jalr	-106(ra) # 80001356 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800013c8:	4699                	li	a3,6
    800013ca:	6605                	lui	a2,0x1
    800013cc:	100015b7          	lui	a1,0x10001
    800013d0:	10001537          	lui	a0,0x10001
    800013d4:	00000097          	auipc	ra,0x0
    800013d8:	f82080e7          	jalr	-126(ra) # 80001356 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800013dc:	4699                	li	a3,6
    800013de:	6641                	lui	a2,0x10
    800013e0:	020005b7          	lui	a1,0x2000
    800013e4:	02000537          	lui	a0,0x2000
    800013e8:	00000097          	auipc	ra,0x0
    800013ec:	f6e080e7          	jalr	-146(ra) # 80001356 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800013f0:	4699                	li	a3,6
    800013f2:	00400637          	lui	a2,0x400
    800013f6:	0c0005b7          	lui	a1,0xc000
    800013fa:	0c000537          	lui	a0,0xc000
    800013fe:	00000097          	auipc	ra,0x0
    80001402:	f58080e7          	jalr	-168(ra) # 80001356 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001406:	00007497          	auipc	s1,0x7
    8000140a:	bfa48493          	addi	s1,s1,-1030 # 80008000 <etext>
    8000140e:	46a9                	li	a3,10
    80001410:	80007617          	auipc	a2,0x80007
    80001414:	bf060613          	addi	a2,a2,-1040 # 8000 <_entry-0x7fff8000>
    80001418:	4585                	li	a1,1
    8000141a:	05fe                	slli	a1,a1,0x1f
    8000141c:	852e                	mv	a0,a1
    8000141e:	00000097          	auipc	ra,0x0
    80001422:	f38080e7          	jalr	-200(ra) # 80001356 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001426:	4699                	li	a3,6
    80001428:	4645                	li	a2,17
    8000142a:	066e                	slli	a2,a2,0x1b
    8000142c:	8e05                	sub	a2,a2,s1
    8000142e:	85a6                	mv	a1,s1
    80001430:	8526                	mv	a0,s1
    80001432:	00000097          	auipc	ra,0x0
    80001436:	f24080e7          	jalr	-220(ra) # 80001356 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000143a:	46a9                	li	a3,10
    8000143c:	6605                	lui	a2,0x1
    8000143e:	00006597          	auipc	a1,0x6
    80001442:	bc258593          	addi	a1,a1,-1086 # 80007000 <_trampoline>
    80001446:	04000537          	lui	a0,0x4000
    8000144a:	157d                	addi	a0,a0,-1
    8000144c:	0532                	slli	a0,a0,0xc
    8000144e:	00000097          	auipc	ra,0x0
    80001452:	f08080e7          	jalr	-248(ra) # 80001356 <kvmmap>
}
    80001456:	60e2                	ld	ra,24(sp)
    80001458:	6442                	ld	s0,16(sp)
    8000145a:	64a2                	ld	s1,8(sp)
    8000145c:	6105                	addi	sp,sp,32
    8000145e:	8082                	ret

0000000080001460 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001460:	715d                	addi	sp,sp,-80
    80001462:	e486                	sd	ra,72(sp)
    80001464:	e0a2                	sd	s0,64(sp)
    80001466:	fc26                	sd	s1,56(sp)
    80001468:	f84a                	sd	s2,48(sp)
    8000146a:	f44e                	sd	s3,40(sp)
    8000146c:	f052                	sd	s4,32(sp)
    8000146e:	ec56                	sd	s5,24(sp)
    80001470:	e85a                	sd	s6,16(sp)
    80001472:	e45e                	sd	s7,8(sp)
    80001474:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001476:	03459793          	slli	a5,a1,0x34
    8000147a:	e795                	bnez	a5,800014a6 <uvmunmap+0x46>
    8000147c:	8a2a                	mv	s4,a0
    8000147e:	892e                	mv	s2,a1
    80001480:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001482:	0632                	slli	a2,a2,0xc
    80001484:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001488:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000148a:	6b05                	lui	s6,0x1
    8000148c:	0735e863          	bltu	a1,s3,800014fc <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001490:	60a6                	ld	ra,72(sp)
    80001492:	6406                	ld	s0,64(sp)
    80001494:	74e2                	ld	s1,56(sp)
    80001496:	7942                	ld	s2,48(sp)
    80001498:	79a2                	ld	s3,40(sp)
    8000149a:	7a02                	ld	s4,32(sp)
    8000149c:	6ae2                	ld	s5,24(sp)
    8000149e:	6b42                	ld	s6,16(sp)
    800014a0:	6ba2                	ld	s7,8(sp)
    800014a2:	6161                	addi	sp,sp,80
    800014a4:	8082                	ret
    panic("uvmunmap: not aligned");
    800014a6:	00007517          	auipc	a0,0x7
    800014aa:	c5250513          	addi	a0,a0,-942 # 800080f8 <digits+0xb8>
    800014ae:	fffff097          	auipc	ra,0xfffff
    800014b2:	09a080e7          	jalr	154(ra) # 80000548 <panic>
      panic("uvmunmap: walk");
    800014b6:	00007517          	auipc	a0,0x7
    800014ba:	c5a50513          	addi	a0,a0,-934 # 80008110 <digits+0xd0>
    800014be:	fffff097          	auipc	ra,0xfffff
    800014c2:	08a080e7          	jalr	138(ra) # 80000548 <panic>
      panic("uvmunmap: not mapped");
    800014c6:	00007517          	auipc	a0,0x7
    800014ca:	c5a50513          	addi	a0,a0,-934 # 80008120 <digits+0xe0>
    800014ce:	fffff097          	auipc	ra,0xfffff
    800014d2:	07a080e7          	jalr	122(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    800014d6:	00007517          	auipc	a0,0x7
    800014da:	c6250513          	addi	a0,a0,-926 # 80008138 <digits+0xf8>
    800014de:	fffff097          	auipc	ra,0xfffff
    800014e2:	06a080e7          	jalr	106(ra) # 80000548 <panic>
      uint64 pa = PTE2PA(*pte);
    800014e6:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800014e8:	0532                	slli	a0,a0,0xc
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	53a080e7          	jalr	1338(ra) # 80000a24 <kfree>
    *pte = 0;
    800014f2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014f6:	995a                	add	s2,s2,s6
    800014f8:	f9397ce3          	bgeu	s2,s3,80001490 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800014fc:	4601                	li	a2,0
    800014fe:	85ca                	mv	a1,s2
    80001500:	8552                	mv	a0,s4
    80001502:	00000097          	auipc	ra,0x0
    80001506:	c80080e7          	jalr	-896(ra) # 80001182 <walk>
    8000150a:	84aa                	mv	s1,a0
    8000150c:	d54d                	beqz	a0,800014b6 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000150e:	6108                	ld	a0,0(a0)
    80001510:	00157793          	andi	a5,a0,1
    80001514:	dbcd                	beqz	a5,800014c6 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001516:	3ff57793          	andi	a5,a0,1023
    8000151a:	fb778ee3          	beq	a5,s7,800014d6 <uvmunmap+0x76>
    if(do_free){
    8000151e:	fc0a8ae3          	beqz	s5,800014f2 <uvmunmap+0x92>
    80001522:	b7d1                	j	800014e6 <uvmunmap+0x86>

0000000080001524 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001524:	1101                	addi	sp,sp,-32
    80001526:	ec06                	sd	ra,24(sp)
    80001528:	e822                	sd	s0,16(sp)
    8000152a:	e426                	sd	s1,8(sp)
    8000152c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000152e:	fffff097          	auipc	ra,0xfffff
    80001532:	65c080e7          	jalr	1628(ra) # 80000b8a <kalloc>
    80001536:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001538:	c519                	beqz	a0,80001546 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000153a:	6605                	lui	a2,0x1
    8000153c:	4581                	li	a1,0
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	958080e7          	jalr	-1704(ra) # 80000e96 <memset>
  return pagetable;
}
    80001546:	8526                	mv	a0,s1
    80001548:	60e2                	ld	ra,24(sp)
    8000154a:	6442                	ld	s0,16(sp)
    8000154c:	64a2                	ld	s1,8(sp)
    8000154e:	6105                	addi	sp,sp,32
    80001550:	8082                	ret

0000000080001552 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001552:	7179                	addi	sp,sp,-48
    80001554:	f406                	sd	ra,40(sp)
    80001556:	f022                	sd	s0,32(sp)
    80001558:	ec26                	sd	s1,24(sp)
    8000155a:	e84a                	sd	s2,16(sp)
    8000155c:	e44e                	sd	s3,8(sp)
    8000155e:	e052                	sd	s4,0(sp)
    80001560:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001562:	6785                	lui	a5,0x1
    80001564:	04f67863          	bgeu	a2,a5,800015b4 <uvminit+0x62>
    80001568:	8a2a                	mv	s4,a0
    8000156a:	89ae                	mv	s3,a1
    8000156c:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000156e:	fffff097          	auipc	ra,0xfffff
    80001572:	61c080e7          	jalr	1564(ra) # 80000b8a <kalloc>
    80001576:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001578:	6605                	lui	a2,0x1
    8000157a:	4581                	li	a1,0
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	91a080e7          	jalr	-1766(ra) # 80000e96 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001584:	4779                	li	a4,30
    80001586:	86ca                	mv	a3,s2
    80001588:	6605                	lui	a2,0x1
    8000158a:	4581                	li	a1,0
    8000158c:	8552                	mv	a0,s4
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	d3a080e7          	jalr	-710(ra) # 800012c8 <mappages>
  memmove(mem, src, sz);
    80001596:	8626                	mv	a2,s1
    80001598:	85ce                	mv	a1,s3
    8000159a:	854a                	mv	a0,s2
    8000159c:	00000097          	auipc	ra,0x0
    800015a0:	95a080e7          	jalr	-1702(ra) # 80000ef6 <memmove>
}
    800015a4:	70a2                	ld	ra,40(sp)
    800015a6:	7402                	ld	s0,32(sp)
    800015a8:	64e2                	ld	s1,24(sp)
    800015aa:	6942                	ld	s2,16(sp)
    800015ac:	69a2                	ld	s3,8(sp)
    800015ae:	6a02                	ld	s4,0(sp)
    800015b0:	6145                	addi	sp,sp,48
    800015b2:	8082                	ret
    panic("inituvm: more than a page");
    800015b4:	00007517          	auipc	a0,0x7
    800015b8:	b9c50513          	addi	a0,a0,-1124 # 80008150 <digits+0x110>
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	f8c080e7          	jalr	-116(ra) # 80000548 <panic>

00000000800015c4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800015c4:	1101                	addi	sp,sp,-32
    800015c6:	ec06                	sd	ra,24(sp)
    800015c8:	e822                	sd	s0,16(sp)
    800015ca:	e426                	sd	s1,8(sp)
    800015cc:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800015ce:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800015d0:	00b67d63          	bgeu	a2,a1,800015ea <uvmdealloc+0x26>
    800015d4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800015d6:	6785                	lui	a5,0x1
    800015d8:	17fd                	addi	a5,a5,-1
    800015da:	00f60733          	add	a4,a2,a5
    800015de:	767d                	lui	a2,0xfffff
    800015e0:	8f71                	and	a4,a4,a2
    800015e2:	97ae                	add	a5,a5,a1
    800015e4:	8ff1                	and	a5,a5,a2
    800015e6:	00f76863          	bltu	a4,a5,800015f6 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800015ea:	8526                	mv	a0,s1
    800015ec:	60e2                	ld	ra,24(sp)
    800015ee:	6442                	ld	s0,16(sp)
    800015f0:	64a2                	ld	s1,8(sp)
    800015f2:	6105                	addi	sp,sp,32
    800015f4:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800015f6:	8f99                	sub	a5,a5,a4
    800015f8:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800015fa:	4685                	li	a3,1
    800015fc:	0007861b          	sext.w	a2,a5
    80001600:	85ba                	mv	a1,a4
    80001602:	00000097          	auipc	ra,0x0
    80001606:	e5e080e7          	jalr	-418(ra) # 80001460 <uvmunmap>
    8000160a:	b7c5                	j	800015ea <uvmdealloc+0x26>

000000008000160c <uvmalloc>:
  if(newsz < oldsz)
    8000160c:	0ab66163          	bltu	a2,a1,800016ae <uvmalloc+0xa2>
{
    80001610:	7139                	addi	sp,sp,-64
    80001612:	fc06                	sd	ra,56(sp)
    80001614:	f822                	sd	s0,48(sp)
    80001616:	f426                	sd	s1,40(sp)
    80001618:	f04a                	sd	s2,32(sp)
    8000161a:	ec4e                	sd	s3,24(sp)
    8000161c:	e852                	sd	s4,16(sp)
    8000161e:	e456                	sd	s5,8(sp)
    80001620:	0080                	addi	s0,sp,64
    80001622:	8aaa                	mv	s5,a0
    80001624:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001626:	6985                	lui	s3,0x1
    80001628:	19fd                	addi	s3,s3,-1
    8000162a:	95ce                	add	a1,a1,s3
    8000162c:	79fd                	lui	s3,0xfffff
    8000162e:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001632:	08c9f063          	bgeu	s3,a2,800016b2 <uvmalloc+0xa6>
    80001636:	894e                	mv	s2,s3
    mem = kalloc();
    80001638:	fffff097          	auipc	ra,0xfffff
    8000163c:	552080e7          	jalr	1362(ra) # 80000b8a <kalloc>
    80001640:	84aa                	mv	s1,a0
    if(mem == 0){
    80001642:	c51d                	beqz	a0,80001670 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001644:	6605                	lui	a2,0x1
    80001646:	4581                	li	a1,0
    80001648:	00000097          	auipc	ra,0x0
    8000164c:	84e080e7          	jalr	-1970(ra) # 80000e96 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001650:	4779                	li	a4,30
    80001652:	86a6                	mv	a3,s1
    80001654:	6605                	lui	a2,0x1
    80001656:	85ca                	mv	a1,s2
    80001658:	8556                	mv	a0,s5
    8000165a:	00000097          	auipc	ra,0x0
    8000165e:	c6e080e7          	jalr	-914(ra) # 800012c8 <mappages>
    80001662:	e905                	bnez	a0,80001692 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001664:	6785                	lui	a5,0x1
    80001666:	993e                	add	s2,s2,a5
    80001668:	fd4968e3          	bltu	s2,s4,80001638 <uvmalloc+0x2c>
  return newsz;
    8000166c:	8552                	mv	a0,s4
    8000166e:	a809                	j	80001680 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001670:	864e                	mv	a2,s3
    80001672:	85ca                	mv	a1,s2
    80001674:	8556                	mv	a0,s5
    80001676:	00000097          	auipc	ra,0x0
    8000167a:	f4e080e7          	jalr	-178(ra) # 800015c4 <uvmdealloc>
      return 0;
    8000167e:	4501                	li	a0,0
}
    80001680:	70e2                	ld	ra,56(sp)
    80001682:	7442                	ld	s0,48(sp)
    80001684:	74a2                	ld	s1,40(sp)
    80001686:	7902                	ld	s2,32(sp)
    80001688:	69e2                	ld	s3,24(sp)
    8000168a:	6a42                	ld	s4,16(sp)
    8000168c:	6aa2                	ld	s5,8(sp)
    8000168e:	6121                	addi	sp,sp,64
    80001690:	8082                	ret
      kfree(mem);
    80001692:	8526                	mv	a0,s1
    80001694:	fffff097          	auipc	ra,0xfffff
    80001698:	390080e7          	jalr	912(ra) # 80000a24 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000169c:	864e                	mv	a2,s3
    8000169e:	85ca                	mv	a1,s2
    800016a0:	8556                	mv	a0,s5
    800016a2:	00000097          	auipc	ra,0x0
    800016a6:	f22080e7          	jalr	-222(ra) # 800015c4 <uvmdealloc>
      return 0;
    800016aa:	4501                	li	a0,0
    800016ac:	bfd1                	j	80001680 <uvmalloc+0x74>
    return oldsz;
    800016ae:	852e                	mv	a0,a1
}
    800016b0:	8082                	ret
  return newsz;
    800016b2:	8532                	mv	a0,a2
    800016b4:	b7f1                	j	80001680 <uvmalloc+0x74>

00000000800016b6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800016b6:	7179                	addi	sp,sp,-48
    800016b8:	f406                	sd	ra,40(sp)
    800016ba:	f022                	sd	s0,32(sp)
    800016bc:	ec26                	sd	s1,24(sp)
    800016be:	e84a                	sd	s2,16(sp)
    800016c0:	e44e                	sd	s3,8(sp)
    800016c2:	e052                	sd	s4,0(sp)
    800016c4:	1800                	addi	s0,sp,48
    800016c6:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800016c8:	84aa                	mv	s1,a0
    800016ca:	6905                	lui	s2,0x1
    800016cc:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016ce:	4985                	li	s3,1
    800016d0:	a821                	j	800016e8 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800016d2:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800016d4:	0532                	slli	a0,a0,0xc
    800016d6:	00000097          	auipc	ra,0x0
    800016da:	fe0080e7          	jalr	-32(ra) # 800016b6 <freewalk>
      pagetable[i] = 0;
    800016de:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800016e2:	04a1                	addi	s1,s1,8
    800016e4:	03248163          	beq	s1,s2,80001706 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800016e8:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016ea:	00f57793          	andi	a5,a0,15
    800016ee:	ff3782e3          	beq	a5,s3,800016d2 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800016f2:	8905                	andi	a0,a0,1
    800016f4:	d57d                	beqz	a0,800016e2 <freewalk+0x2c>
      panic("freewalk: leaf");
    800016f6:	00007517          	auipc	a0,0x7
    800016fa:	a7a50513          	addi	a0,a0,-1414 # 80008170 <digits+0x130>
    800016fe:	fffff097          	auipc	ra,0xfffff
    80001702:	e4a080e7          	jalr	-438(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    80001706:	8552                	mv	a0,s4
    80001708:	fffff097          	auipc	ra,0xfffff
    8000170c:	31c080e7          	jalr	796(ra) # 80000a24 <kfree>
}
    80001710:	70a2                	ld	ra,40(sp)
    80001712:	7402                	ld	s0,32(sp)
    80001714:	64e2                	ld	s1,24(sp)
    80001716:	6942                	ld	s2,16(sp)
    80001718:	69a2                	ld	s3,8(sp)
    8000171a:	6a02                	ld	s4,0(sp)
    8000171c:	6145                	addi	sp,sp,48
    8000171e:	8082                	ret

0000000080001720 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001720:	1101                	addi	sp,sp,-32
    80001722:	ec06                	sd	ra,24(sp)
    80001724:	e822                	sd	s0,16(sp)
    80001726:	e426                	sd	s1,8(sp)
    80001728:	1000                	addi	s0,sp,32
    8000172a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000172c:	e999                	bnez	a1,80001742 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000172e:	8526                	mv	a0,s1
    80001730:	00000097          	auipc	ra,0x0
    80001734:	f86080e7          	jalr	-122(ra) # 800016b6 <freewalk>
}
    80001738:	60e2                	ld	ra,24(sp)
    8000173a:	6442                	ld	s0,16(sp)
    8000173c:	64a2                	ld	s1,8(sp)
    8000173e:	6105                	addi	sp,sp,32
    80001740:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001742:	6605                	lui	a2,0x1
    80001744:	167d                	addi	a2,a2,-1
    80001746:	962e                	add	a2,a2,a1
    80001748:	4685                	li	a3,1
    8000174a:	8231                	srli	a2,a2,0xc
    8000174c:	4581                	li	a1,0
    8000174e:	00000097          	auipc	ra,0x0
    80001752:	d12080e7          	jalr	-750(ra) # 80001460 <uvmunmap>
    80001756:	bfe1                	j	8000172e <uvmfree+0xe>

0000000080001758 <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    80001758:	715d                	addi	sp,sp,-80
    8000175a:	e486                	sd	ra,72(sp)
    8000175c:	e0a2                	sd	s0,64(sp)
    8000175e:	fc26                	sd	s1,56(sp)
    80001760:	f84a                	sd	s2,48(sp)
    80001762:	f44e                	sd	s3,40(sp)
    80001764:	f052                	sd	s4,32(sp)
    80001766:	ec56                	sd	s5,24(sp)
    80001768:	e85a                	sd	s6,16(sp)
    8000176a:	e45e                	sd	s7,8(sp)
    8000176c:	0880                	addi	s0,sp,80
  pte_t *pte;
  uint64 pa, i;
  uint flags;
//   char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000176e:	c269                	beqz	a2,80001830 <uvmcopy+0xd8>
    80001770:	8a2a                	mv	s4,a0
    80001772:	89ae                	mv	s3,a1
    80001774:	8932                	mv	s2,a2
    80001776:	4481                	li	s1,0
    //   goto err;
    // memmove(mem, (char*)pa, PGSIZE);
    if(flags & PTE_W)
    {
        flags = (flags | PTE_COW) & (~PTE_W);
        *pte = PA2PTE(pa) | flags;
    80001778:	7afd                	lui	s5,0xfffff
    8000177a:	002ada93          	srli	s5,s5,0x2
    8000177e:	a8a1                	j	800017d6 <uvmcopy+0x7e>
      panic("uvmcopy: pte should exist");
    80001780:	00007517          	auipc	a0,0x7
    80001784:	a0050513          	addi	a0,a0,-1536 # 80008180 <digits+0x140>
    80001788:	fffff097          	auipc	ra,0xfffff
    8000178c:	dc0080e7          	jalr	-576(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    80001790:	00007517          	auipc	a0,0x7
    80001794:	a1050513          	addi	a0,a0,-1520 # 800081a0 <digits+0x160>
    80001798:	fffff097          	auipc	ra,0xfffff
    8000179c:	db0080e7          	jalr	-592(ra) # 80000548 <panic>
        flags = (flags | PTE_COW) & (~PTE_W);
    800017a0:	3fb77693          	andi	a3,a4,1019
    800017a4:	1006e713          	ori	a4,a3,256
        *pte = PA2PTE(pa) | flags;
    800017a8:	0157f7b3          	and	a5,a5,s5
    800017ac:	8fd9                	or	a5,a5,a4
    800017ae:	e11c                	sd	a5,0(a0)
    }
    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){
    800017b0:	86da                	mv	a3,s6
    800017b2:	6605                	lui	a2,0x1
    800017b4:	85a6                	mv	a1,s1
    800017b6:	854e                	mv	a0,s3
    800017b8:	00000097          	auipc	ra,0x0
    800017bc:	b10080e7          	jalr	-1264(ra) # 800012c8 <mappages>
    800017c0:	8baa                	mv	s7,a0
    800017c2:	e129                	bnez	a0,80001804 <uvmcopy+0xac>
      goto err;
    }
    krefpage((void *)pa);
    800017c4:	855a                	mv	a0,s6
    800017c6:	fffff097          	auipc	ra,0xfffff
    800017ca:	446080e7          	jalr	1094(ra) # 80000c0c <krefpage>
  for(i = 0; i < sz; i += PGSIZE){
    800017ce:	6785                	lui	a5,0x1
    800017d0:	94be                	add	s1,s1,a5
    800017d2:	0524f363          	bgeu	s1,s2,80001818 <uvmcopy+0xc0>
    if((pte = walk(old, i, 0)) == 0)
    800017d6:	4601                	li	a2,0
    800017d8:	85a6                	mv	a1,s1
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	9a6080e7          	jalr	-1626(ra) # 80001182 <walk>
    800017e4:	dd51                	beqz	a0,80001780 <uvmcopy+0x28>
    if((*pte & PTE_V) == 0)
    800017e6:	611c                	ld	a5,0(a0)
    800017e8:	0017f713          	andi	a4,a5,1
    800017ec:	d355                	beqz	a4,80001790 <uvmcopy+0x38>
    pa = PTE2PA(*pte);
    800017ee:	00a7db13          	srli	s6,a5,0xa
    800017f2:	0b32                	slli	s6,s6,0xc
    flags = PTE_FLAGS(*pte);
    800017f4:	0007871b          	sext.w	a4,a5
    if(flags & PTE_W)
    800017f8:	00477693          	andi	a3,a4,4
    800017fc:	f2d5                	bnez	a3,800017a0 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    800017fe:	3ff77713          	andi	a4,a4,1023
    80001802:	b77d                	j	800017b0 <uvmcopy+0x58>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001804:	4685                	li	a3,1
    80001806:	00c4d613          	srli	a2,s1,0xc
    8000180a:	4581                	li	a1,0
    8000180c:	854e                	mv	a0,s3
    8000180e:	00000097          	auipc	ra,0x0
    80001812:	c52080e7          	jalr	-942(ra) # 80001460 <uvmunmap>
  return -1;
    80001816:	5bfd                	li	s7,-1
}
    80001818:	855e                	mv	a0,s7
    8000181a:	60a6                	ld	ra,72(sp)
    8000181c:	6406                	ld	s0,64(sp)
    8000181e:	74e2                	ld	s1,56(sp)
    80001820:	7942                	ld	s2,48(sp)
    80001822:	79a2                	ld	s3,40(sp)
    80001824:	7a02                	ld	s4,32(sp)
    80001826:	6ae2                	ld	s5,24(sp)
    80001828:	6b42                	ld	s6,16(sp)
    8000182a:	6ba2                	ld	s7,8(sp)
    8000182c:	6161                	addi	sp,sp,80
    8000182e:	8082                	ret
  return 0;
    80001830:	4b81                	li	s7,0
    80001832:	b7dd                	j	80001818 <uvmcopy+0xc0>

0000000080001834 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001834:	1141                	addi	sp,sp,-16
    80001836:	e406                	sd	ra,8(sp)
    80001838:	e022                	sd	s0,0(sp)
    8000183a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000183c:	4601                	li	a2,0
    8000183e:	00000097          	auipc	ra,0x0
    80001842:	944080e7          	jalr	-1724(ra) # 80001182 <walk>
  if(pte == 0)
    80001846:	c901                	beqz	a0,80001856 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001848:	611c                	ld	a5,0(a0)
    8000184a:	9bbd                	andi	a5,a5,-17
    8000184c:	e11c                	sd	a5,0(a0)
}
    8000184e:	60a2                	ld	ra,8(sp)
    80001850:	6402                	ld	s0,0(sp)
    80001852:	0141                	addi	sp,sp,16
    80001854:	8082                	ret
    panic("uvmclear");
    80001856:	00007517          	auipc	a0,0x7
    8000185a:	96a50513          	addi	a0,a0,-1686 # 800081c0 <digits+0x180>
    8000185e:	fffff097          	auipc	ra,0xfffff
    80001862:	cea080e7          	jalr	-790(ra) # 80000548 <panic>

0000000080001866 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001866:	c6bd                	beqz	a3,800018d4 <copyin+0x6e>
{
    80001868:	715d                	addi	sp,sp,-80
    8000186a:	e486                	sd	ra,72(sp)
    8000186c:	e0a2                	sd	s0,64(sp)
    8000186e:	fc26                	sd	s1,56(sp)
    80001870:	f84a                	sd	s2,48(sp)
    80001872:	f44e                	sd	s3,40(sp)
    80001874:	f052                	sd	s4,32(sp)
    80001876:	ec56                	sd	s5,24(sp)
    80001878:	e85a                	sd	s6,16(sp)
    8000187a:	e45e                	sd	s7,8(sp)
    8000187c:	e062                	sd	s8,0(sp)
    8000187e:	0880                	addi	s0,sp,80
    80001880:	8b2a                	mv	s6,a0
    80001882:	8a2e                	mv	s4,a1
    80001884:	8c32                	mv	s8,a2
    80001886:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001888:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000188a:	6a85                	lui	s5,0x1
    8000188c:	a015                	j	800018b0 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000188e:	9562                	add	a0,a0,s8
    80001890:	0004861b          	sext.w	a2,s1
    80001894:	412505b3          	sub	a1,a0,s2
    80001898:	8552                	mv	a0,s4
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	65c080e7          	jalr	1628(ra) # 80000ef6 <memmove>

    len -= n;
    800018a2:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018a6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018ac:	02098263          	beqz	s3,800018d0 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    800018b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018b4:	85ca                	mv	a1,s2
    800018b6:	855a                	mv	a0,s6
    800018b8:	00000097          	auipc	ra,0x0
    800018bc:	970080e7          	jalr	-1680(ra) # 80001228 <walkaddr>
    if(pa0 == 0)
    800018c0:	cd01                	beqz	a0,800018d8 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    800018c2:	418904b3          	sub	s1,s2,s8
    800018c6:	94d6                	add	s1,s1,s5
    if(n > len)
    800018c8:	fc99f3e3          	bgeu	s3,s1,8000188e <copyin+0x28>
    800018cc:	84ce                	mv	s1,s3
    800018ce:	b7c1                	j	8000188e <copyin+0x28>
  }
  return 0;
    800018d0:	4501                	li	a0,0
    800018d2:	a021                	j	800018da <copyin+0x74>
    800018d4:	4501                	li	a0,0
}
    800018d6:	8082                	ret
      return -1;
    800018d8:	557d                	li	a0,-1
}
    800018da:	60a6                	ld	ra,72(sp)
    800018dc:	6406                	ld	s0,64(sp)
    800018de:	74e2                	ld	s1,56(sp)
    800018e0:	7942                	ld	s2,48(sp)
    800018e2:	79a2                	ld	s3,40(sp)
    800018e4:	7a02                	ld	s4,32(sp)
    800018e6:	6ae2                	ld	s5,24(sp)
    800018e8:	6b42                	ld	s6,16(sp)
    800018ea:	6ba2                	ld	s7,8(sp)
    800018ec:	6c02                	ld	s8,0(sp)
    800018ee:	6161                	addi	sp,sp,80
    800018f0:	8082                	ret

00000000800018f2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018f2:	c6c5                	beqz	a3,8000199a <copyinstr+0xa8>
{
    800018f4:	715d                	addi	sp,sp,-80
    800018f6:	e486                	sd	ra,72(sp)
    800018f8:	e0a2                	sd	s0,64(sp)
    800018fa:	fc26                	sd	s1,56(sp)
    800018fc:	f84a                	sd	s2,48(sp)
    800018fe:	f44e                	sd	s3,40(sp)
    80001900:	f052                	sd	s4,32(sp)
    80001902:	ec56                	sd	s5,24(sp)
    80001904:	e85a                	sd	s6,16(sp)
    80001906:	e45e                	sd	s7,8(sp)
    80001908:	0880                	addi	s0,sp,80
    8000190a:	8a2a                	mv	s4,a0
    8000190c:	8b2e                	mv	s6,a1
    8000190e:	8bb2                	mv	s7,a2
    80001910:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001912:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001914:	6985                	lui	s3,0x1
    80001916:	a035                	j	80001942 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001918:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000191c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000191e:	0017b793          	seqz	a5,a5
    80001922:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001926:	60a6                	ld	ra,72(sp)
    80001928:	6406                	ld	s0,64(sp)
    8000192a:	74e2                	ld	s1,56(sp)
    8000192c:	7942                	ld	s2,48(sp)
    8000192e:	79a2                	ld	s3,40(sp)
    80001930:	7a02                	ld	s4,32(sp)
    80001932:	6ae2                	ld	s5,24(sp)
    80001934:	6b42                	ld	s6,16(sp)
    80001936:	6ba2                	ld	s7,8(sp)
    80001938:	6161                	addi	sp,sp,80
    8000193a:	8082                	ret
    srcva = va0 + PGSIZE;
    8000193c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001940:	c8a9                	beqz	s1,80001992 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001942:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001946:	85ca                	mv	a1,s2
    80001948:	8552                	mv	a0,s4
    8000194a:	00000097          	auipc	ra,0x0
    8000194e:	8de080e7          	jalr	-1826(ra) # 80001228 <walkaddr>
    if(pa0 == 0)
    80001952:	c131                	beqz	a0,80001996 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001954:	41790833          	sub	a6,s2,s7
    80001958:	984e                	add	a6,a6,s3
    if(n > max)
    8000195a:	0104f363          	bgeu	s1,a6,80001960 <copyinstr+0x6e>
    8000195e:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001960:	955e                	add	a0,a0,s7
    80001962:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001966:	fc080be3          	beqz	a6,8000193c <copyinstr+0x4a>
    8000196a:	985a                	add	a6,a6,s6
    8000196c:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000196e:	41650633          	sub	a2,a0,s6
    80001972:	14fd                	addi	s1,s1,-1
    80001974:	9b26                	add	s6,s6,s1
    80001976:	00f60733          	add	a4,a2,a5
    8000197a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffb9000>
    8000197e:	df49                	beqz	a4,80001918 <copyinstr+0x26>
        *dst = *p;
    80001980:	00e78023          	sb	a4,0(a5)
      --max;
    80001984:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001988:	0785                	addi	a5,a5,1
    while(n > 0){
    8000198a:	ff0796e3          	bne	a5,a6,80001976 <copyinstr+0x84>
      dst++;
    8000198e:	8b42                	mv	s6,a6
    80001990:	b775                	j	8000193c <copyinstr+0x4a>
    80001992:	4781                	li	a5,0
    80001994:	b769                	j	8000191e <copyinstr+0x2c>
      return -1;
    80001996:	557d                	li	a0,-1
    80001998:	b779                	j	80001926 <copyinstr+0x34>
  int got_null = 0;
    8000199a:	4781                	li	a5,0
  if(got_null){
    8000199c:	0017b793          	seqz	a5,a5
    800019a0:	40f00533          	neg	a0,a5
}
    800019a4:	8082                	ret

00000000800019a6 <iscowpage>:

int iscowpage(uint64 va)
{
    800019a6:	1101                	addi	sp,sp,-32
    800019a8:	ec06                	sd	ra,24(sp)
    800019aa:	e822                	sd	s0,16(sp)
    800019ac:	e426                	sd	s1,8(sp)
    800019ae:	1000                	addi	s0,sp,32
    800019b0:	84aa                	mv	s1,a0
    pte_t* pte;
    struct proc* p = myproc();
    800019b2:	00000097          	auipc	ra,0x0
    800019b6:	2d4080e7          	jalr	724(ra) # 80001c86 <myproc>
    return va < p->sz
            && ((pte =walk(p->pagetable, va,0))!=0 && (*pte & PTE_V))
            && (*pte & PTE_COW);
    800019ba:	653c                	ld	a5,72(a0)
    800019bc:	00f4e863          	bltu	s1,a5,800019cc <iscowpage+0x26>
    800019c0:	4501                	li	a0,0
}
    800019c2:	60e2                	ld	ra,24(sp)
    800019c4:	6442                	ld	s0,16(sp)
    800019c6:	64a2                	ld	s1,8(sp)
    800019c8:	6105                	addi	sp,sp,32
    800019ca:	8082                	ret
            && ((pte =walk(p->pagetable, va,0))!=0 && (*pte & PTE_V))
    800019cc:	4601                	li	a2,0
    800019ce:	85a6                	mv	a1,s1
    800019d0:	6928                	ld	a0,80(a0)
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	7b0080e7          	jalr	1968(ra) # 80001182 <walk>
    800019da:	87aa                	mv	a5,a0
            && (*pte & PTE_COW);
    800019dc:	4501                	li	a0,0
            && ((pte =walk(p->pagetable, va,0))!=0 && (*pte & PTE_V))
    800019de:	d3f5                	beqz	a5,800019c2 <iscowpage+0x1c>
            && (*pte & PTE_COW);
    800019e0:	6388                	ld	a0,0(a5)
    800019e2:	10157513          	andi	a0,a0,257
    800019e6:	eff50513          	addi	a0,a0,-257
    800019ea:	00153513          	seqz	a0,a0
    800019ee:	bfd1                	j	800019c2 <iscowpage+0x1c>

00000000800019f0 <uvmcowcopy>:

int uvmcowcopy(uint64 va)
{
    800019f0:	7179                	addi	sp,sp,-48
    800019f2:	f406                	sd	ra,40(sp)
    800019f4:	f022                	sd	s0,32(sp)
    800019f6:	ec26                	sd	s1,24(sp)
    800019f8:	e84a                	sd	s2,16(sp)
    800019fa:	e44e                	sd	s3,8(sp)
    800019fc:	e052                	sd	s4,0(sp)
    800019fe:	1800                	addi	s0,sp,48
    80001a00:	89aa                	mv	s3,a0
    pte_t* pte;
    struct proc* p = myproc();
    80001a02:	00000097          	auipc	ra,0x0
    80001a06:	284080e7          	jalr	644(ra) # 80001c86 <myproc>
    80001a0a:	892a                	mv	s2,a0
    if((pte = walk(p->pagetable, va, 0))==0)
    80001a0c:	4601                	li	a2,0
    80001a0e:	85ce                	mv	a1,s3
    80001a10:	6928                	ld	a0,80(a0)
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	770080e7          	jalr	1904(ra) # 80001182 <walk>
    80001a1a:	c135                	beqz	a0,80001a7e <uvmcowcopy+0x8e>
    80001a1c:	84aa                	mv	s1,a0
    {
        panic("uvmcowcopy: walk\n");
    }
    uint64 pa = PTE2PA(*pte);
    80001a1e:	6108                	ld	a0,0(a0)
    80001a20:	8129                	srli	a0,a0,0xa
    uint64 new = (uint64)kcopy_n_deref((void *)pa);
    80001a22:	0532                	slli	a0,a0,0xc
    80001a24:	fffff097          	auipc	ra,0xfffff
    80001a28:	238080e7          	jalr	568(ra) # 80000c5c <kcopy_n_deref>
    80001a2c:	8a2a                	mv	s4,a0
    if(new == 0)
    80001a2e:	c925                	beqz	a0,80001a9e <uvmcowcopy+0xae>
        return -1;
    // 重新映射为可写，并清除 PTE_COW 标记
    uint64 flags = (PTE_FLAGS(*pte) | PTE_W) & ~PTE_COW;
    80001a30:	6084                	ld	s1,0(s1)
    80001a32:	2fb4f493          	andi	s1,s1,763
    80001a36:	0044e493          	ori	s1,s1,4
    uvmunmap(p->pagetable, PGROUNDDOWN(va), 1, 0); //取消映射
    80001a3a:	4681                	li	a3,0
    80001a3c:	4605                	li	a2,1
    80001a3e:	75fd                	lui	a1,0xfffff
    80001a40:	00b9f5b3          	and	a1,s3,a1
    80001a44:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001a48:	00000097          	auipc	ra,0x0
    80001a4c:	a18080e7          	jalr	-1512(ra) # 80001460 <uvmunmap>
    if(mappages(p->pagetable, va, 1, new, flags)==-1)  //chong映射
    80001a50:	8726                	mv	a4,s1
    80001a52:	86d2                	mv	a3,s4
    80001a54:	4605                	li	a2,1
    80001a56:	85ce                	mv	a1,s3
    80001a58:	05093503          	ld	a0,80(s2)
    80001a5c:	00000097          	auipc	ra,0x0
    80001a60:	86c080e7          	jalr	-1940(ra) # 800012c8 <mappages>
    80001a64:	872a                	mv	a4,a0
    80001a66:	57fd                	li	a5,-1
        panic("uvmcowcopy: mappages\n");
    return 0;
    80001a68:	4501                	li	a0,0
    if(mappages(p->pagetable, va, 1, new, flags)==-1)  //chong映射
    80001a6a:	02f70263          	beq	a4,a5,80001a8e <uvmcowcopy+0x9e>

    80001a6e:	70a2                	ld	ra,40(sp)
    80001a70:	7402                	ld	s0,32(sp)
    80001a72:	64e2                	ld	s1,24(sp)
    80001a74:	6942                	ld	s2,16(sp)
    80001a76:	69a2                	ld	s3,8(sp)
    80001a78:	6a02                	ld	s4,0(sp)
    80001a7a:	6145                	addi	sp,sp,48
    80001a7c:	8082                	ret
        panic("uvmcowcopy: walk\n");
    80001a7e:	00006517          	auipc	a0,0x6
    80001a82:	75250513          	addi	a0,a0,1874 # 800081d0 <digits+0x190>
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	ac2080e7          	jalr	-1342(ra) # 80000548 <panic>
        panic("uvmcowcopy: mappages\n");
    80001a8e:	00006517          	auipc	a0,0x6
    80001a92:	75a50513          	addi	a0,a0,1882 # 800081e8 <digits+0x1a8>
    80001a96:	fffff097          	auipc	ra,0xfffff
    80001a9a:	ab2080e7          	jalr	-1358(ra) # 80000548 <panic>
        return -1;
    80001a9e:	557d                	li	a0,-1
    80001aa0:	b7f9                	j	80001a6e <uvmcowcopy+0x7e>

0000000080001aa2 <copyout>:
  while(len > 0){
    80001aa2:	c2d9                	beqz	a3,80001b28 <copyout+0x86>
{
    80001aa4:	715d                	addi	sp,sp,-80
    80001aa6:	e486                	sd	ra,72(sp)
    80001aa8:	e0a2                	sd	s0,64(sp)
    80001aaa:	fc26                	sd	s1,56(sp)
    80001aac:	f84a                	sd	s2,48(sp)
    80001aae:	f44e                	sd	s3,40(sp)
    80001ab0:	f052                	sd	s4,32(sp)
    80001ab2:	ec56                	sd	s5,24(sp)
    80001ab4:	e85a                	sd	s6,16(sp)
    80001ab6:	e45e                	sd	s7,8(sp)
    80001ab8:	e062                	sd	s8,0(sp)
    80001aba:	0880                	addi	s0,sp,80
    80001abc:	8baa                	mv	s7,a0
    80001abe:	84ae                	mv	s1,a1
    80001ac0:	8ab2                	mv	s5,a2
    80001ac2:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001ac4:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (dstva - va0);
    80001ac6:	6b05                	lui	s6,0x1
    80001ac8:	a805                	j	80001af8 <copyout+0x56>
        uvmcowcopy(dstva);
    80001aca:	8526                	mv	a0,s1
    80001acc:	00000097          	auipc	ra,0x0
    80001ad0:	f24080e7          	jalr	-220(ra) # 800019f0 <uvmcowcopy>
    80001ad4:	a805                	j	80001b04 <copyout+0x62>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001ad6:	413484b3          	sub	s1,s1,s3
    80001ada:	0009061b          	sext.w	a2,s2
    80001ade:	85d6                	mv	a1,s5
    80001ae0:	9526                	add	a0,a0,s1
    80001ae2:	fffff097          	auipc	ra,0xfffff
    80001ae6:	414080e7          	jalr	1044(ra) # 80000ef6 <memmove>
    len -= n;
    80001aea:	412a0a33          	sub	s4,s4,s2
    src += n;
    80001aee:	9aca                	add	s5,s5,s2
    dstva = va0 + PGSIZE;
    80001af0:	016984b3          	add	s1,s3,s6
  while(len > 0){
    80001af4:	020a0863          	beqz	s4,80001b24 <copyout+0x82>
    if(iscowpage(dstva)) // 检查每一个被写的页是否是 COW 页
    80001af8:	8526                	mv	a0,s1
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	eac080e7          	jalr	-340(ra) # 800019a6 <iscowpage>
    80001b02:	f561                	bnez	a0,80001aca <copyout+0x28>
    va0 = PGROUNDDOWN(dstva);
    80001b04:	0184f9b3          	and	s3,s1,s8
    pa0 = walkaddr(pagetable, va0);
    80001b08:	85ce                	mv	a1,s3
    80001b0a:	855e                	mv	a0,s7
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	71c080e7          	jalr	1820(ra) # 80001228 <walkaddr>
    if(pa0 == 0)
    80001b14:	cd01                	beqz	a0,80001b2c <copyout+0x8a>
    n = PGSIZE - (dstva - va0);
    80001b16:	40998933          	sub	s2,s3,s1
    80001b1a:	995a                	add	s2,s2,s6
    if(n > len)
    80001b1c:	fb2a7de3          	bgeu	s4,s2,80001ad6 <copyout+0x34>
    80001b20:	8952                	mv	s2,s4
    80001b22:	bf55                	j	80001ad6 <copyout+0x34>
  return 0;
    80001b24:	4501                	li	a0,0
    80001b26:	a021                	j	80001b2e <copyout+0x8c>
    80001b28:	4501                	li	a0,0
}
    80001b2a:	8082                	ret
      return -1;
    80001b2c:	557d                	li	a0,-1
}
    80001b2e:	60a6                	ld	ra,72(sp)
    80001b30:	6406                	ld	s0,64(sp)
    80001b32:	74e2                	ld	s1,56(sp)
    80001b34:	7942                	ld	s2,48(sp)
    80001b36:	79a2                	ld	s3,40(sp)
    80001b38:	7a02                	ld	s4,32(sp)
    80001b3a:	6ae2                	ld	s5,24(sp)
    80001b3c:	6b42                	ld	s6,16(sp)
    80001b3e:	6ba2                	ld	s7,8(sp)
    80001b40:	6c02                	ld	s8,0(sp)
    80001b42:	6161                	addi	sp,sp,80
    80001b44:	8082                	ret

0000000080001b46 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001b46:	1101                	addi	sp,sp,-32
    80001b48:	ec06                	sd	ra,24(sp)
    80001b4a:	e822                	sd	s0,16(sp)
    80001b4c:	e426                	sd	s1,8(sp)
    80001b4e:	1000                	addi	s0,sp,32
    80001b50:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	1ce080e7          	jalr	462(ra) # 80000d20 <holding>
    80001b5a:	c909                	beqz	a0,80001b6c <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001b5c:	749c                	ld	a5,40(s1)
    80001b5e:	00978f63          	beq	a5,s1,80001b7c <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001b62:	60e2                	ld	ra,24(sp)
    80001b64:	6442                	ld	s0,16(sp)
    80001b66:	64a2                	ld	s1,8(sp)
    80001b68:	6105                	addi	sp,sp,32
    80001b6a:	8082                	ret
    panic("wakeup1");
    80001b6c:	00006517          	auipc	a0,0x6
    80001b70:	69450513          	addi	a0,a0,1684 # 80008200 <digits+0x1c0>
    80001b74:	fffff097          	auipc	ra,0xfffff
    80001b78:	9d4080e7          	jalr	-1580(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001b7c:	4c98                	lw	a4,24(s1)
    80001b7e:	4785                	li	a5,1
    80001b80:	fef711e3          	bne	a4,a5,80001b62 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001b84:	4789                	li	a5,2
    80001b86:	cc9c                	sw	a5,24(s1)
}
    80001b88:	bfe9                	j	80001b62 <wakeup1+0x1c>

0000000080001b8a <procinit>:
{
    80001b8a:	715d                	addi	sp,sp,-80
    80001b8c:	e486                	sd	ra,72(sp)
    80001b8e:	e0a2                	sd	s0,64(sp)
    80001b90:	fc26                	sd	s1,56(sp)
    80001b92:	f84a                	sd	s2,48(sp)
    80001b94:	f44e                	sd	s3,40(sp)
    80001b96:	f052                	sd	s4,32(sp)
    80001b98:	ec56                	sd	s5,24(sp)
    80001b9a:	e85a                	sd	s6,16(sp)
    80001b9c:	e45e                	sd	s7,8(sp)
    80001b9e:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001ba0:	00006597          	auipc	a1,0x6
    80001ba4:	66858593          	addi	a1,a1,1640 # 80008208 <digits+0x1c8>
    80001ba8:	00030517          	auipc	a0,0x30
    80001bac:	dc050513          	addi	a0,a0,-576 # 80031968 <pid_lock>
    80001bb0:	fffff097          	auipc	ra,0xfffff
    80001bb4:	15a080e7          	jalr	346(ra) # 80000d0a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bb8:	00030917          	auipc	s2,0x30
    80001bbc:	1c890913          	addi	s2,s2,456 # 80031d80 <proc>
      initlock(&p->lock, "proc");
    80001bc0:	00006b97          	auipc	s7,0x6
    80001bc4:	650b8b93          	addi	s7,s7,1616 # 80008210 <digits+0x1d0>
      uint64 va = KSTACK((int) (p - proc));
    80001bc8:	8b4a                	mv	s6,s2
    80001bca:	00006a97          	auipc	s5,0x6
    80001bce:	436a8a93          	addi	s5,s5,1078 # 80008000 <etext>
    80001bd2:	040009b7          	lui	s3,0x4000
    80001bd6:	19fd                	addi	s3,s3,-1
    80001bd8:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bda:	00036a17          	auipc	s4,0x36
    80001bde:	ba6a0a13          	addi	s4,s4,-1114 # 80037780 <tickslock>
      initlock(&p->lock, "proc");
    80001be2:	85de                	mv	a1,s7
    80001be4:	854a                	mv	a0,s2
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	124080e7          	jalr	292(ra) # 80000d0a <initlock>
      char *pa = kalloc();
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	f9c080e7          	jalr	-100(ra) # 80000b8a <kalloc>
    80001bf6:	85aa                	mv	a1,a0
      if(pa == 0)
    80001bf8:	c929                	beqz	a0,80001c4a <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001bfa:	416904b3          	sub	s1,s2,s6
    80001bfe:	848d                	srai	s1,s1,0x3
    80001c00:	000ab783          	ld	a5,0(s5)
    80001c04:	02f484b3          	mul	s1,s1,a5
    80001c08:	2485                	addiw	s1,s1,1
    80001c0a:	00d4949b          	slliw	s1,s1,0xd
    80001c0e:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c12:	4699                	li	a3,6
    80001c14:	6605                	lui	a2,0x1
    80001c16:	8526                	mv	a0,s1
    80001c18:	fffff097          	auipc	ra,0xfffff
    80001c1c:	73e080e7          	jalr	1854(ra) # 80001356 <kvmmap>
      p->kstack = va;
    80001c20:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c24:	16890913          	addi	s2,s2,360
    80001c28:	fb491de3          	bne	s2,s4,80001be2 <procinit+0x58>
  kvminithart();
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	532080e7          	jalr	1330(ra) # 8000115e <kvminithart>
}
    80001c34:	60a6                	ld	ra,72(sp)
    80001c36:	6406                	ld	s0,64(sp)
    80001c38:	74e2                	ld	s1,56(sp)
    80001c3a:	7942                	ld	s2,48(sp)
    80001c3c:	79a2                	ld	s3,40(sp)
    80001c3e:	7a02                	ld	s4,32(sp)
    80001c40:	6ae2                	ld	s5,24(sp)
    80001c42:	6b42                	ld	s6,16(sp)
    80001c44:	6ba2                	ld	s7,8(sp)
    80001c46:	6161                	addi	sp,sp,80
    80001c48:	8082                	ret
        panic("kalloc");
    80001c4a:	00006517          	auipc	a0,0x6
    80001c4e:	5ce50513          	addi	a0,a0,1486 # 80008218 <digits+0x1d8>
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	8f6080e7          	jalr	-1802(ra) # 80000548 <panic>

0000000080001c5a <cpuid>:
{
    80001c5a:	1141                	addi	sp,sp,-16
    80001c5c:	e422                	sd	s0,8(sp)
    80001c5e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c60:	8512                	mv	a0,tp
}
    80001c62:	2501                	sext.w	a0,a0
    80001c64:	6422                	ld	s0,8(sp)
    80001c66:	0141                	addi	sp,sp,16
    80001c68:	8082                	ret

0000000080001c6a <mycpu>:
mycpu(void) {
    80001c6a:	1141                	addi	sp,sp,-16
    80001c6c:	e422                	sd	s0,8(sp)
    80001c6e:	0800                	addi	s0,sp,16
    80001c70:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001c72:	2781                	sext.w	a5,a5
    80001c74:	079e                	slli	a5,a5,0x7
}
    80001c76:	00030517          	auipc	a0,0x30
    80001c7a:	d0a50513          	addi	a0,a0,-758 # 80031980 <cpus>
    80001c7e:	953e                	add	a0,a0,a5
    80001c80:	6422                	ld	s0,8(sp)
    80001c82:	0141                	addi	sp,sp,16
    80001c84:	8082                	ret

0000000080001c86 <myproc>:
myproc(void) {
    80001c86:	1101                	addi	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	1000                	addi	s0,sp,32
  push_off();
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	0be080e7          	jalr	190(ra) # 80000d4e <push_off>
    80001c98:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001c9a:	2781                	sext.w	a5,a5
    80001c9c:	079e                	slli	a5,a5,0x7
    80001c9e:	00030717          	auipc	a4,0x30
    80001ca2:	cca70713          	addi	a4,a4,-822 # 80031968 <pid_lock>
    80001ca6:	97ba                	add	a5,a5,a4
    80001ca8:	6f84                	ld	s1,24(a5)
  pop_off();
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	144080e7          	jalr	324(ra) # 80000dee <pop_off>
}
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	60e2                	ld	ra,24(sp)
    80001cb6:	6442                	ld	s0,16(sp)
    80001cb8:	64a2                	ld	s1,8(sp)
    80001cba:	6105                	addi	sp,sp,32
    80001cbc:	8082                	ret

0000000080001cbe <forkret>:
{
    80001cbe:	1141                	addi	sp,sp,-16
    80001cc0:	e406                	sd	ra,8(sp)
    80001cc2:	e022                	sd	s0,0(sp)
    80001cc4:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001cc6:	00000097          	auipc	ra,0x0
    80001cca:	fc0080e7          	jalr	-64(ra) # 80001c86 <myproc>
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	180080e7          	jalr	384(ra) # 80000e4e <release>
  if (first) {
    80001cd6:	00007797          	auipc	a5,0x7
    80001cda:	b7a7a783          	lw	a5,-1158(a5) # 80008850 <first.1670>
    80001cde:	eb89                	bnez	a5,80001cf0 <forkret+0x32>
  usertrapret();
    80001ce0:	00001097          	auipc	ra,0x1
    80001ce4:	c1c080e7          	jalr	-996(ra) # 800028fc <usertrapret>
}
    80001ce8:	60a2                	ld	ra,8(sp)
    80001cea:	6402                	ld	s0,0(sp)
    80001cec:	0141                	addi	sp,sp,16
    80001cee:	8082                	ret
    first = 0;
    80001cf0:	00007797          	auipc	a5,0x7
    80001cf4:	b607a023          	sw	zero,-1184(a5) # 80008850 <first.1670>
    fsinit(ROOTDEV);
    80001cf8:	4505                	li	a0,1
    80001cfa:	00002097          	auipc	ra,0x2
    80001cfe:	988080e7          	jalr	-1656(ra) # 80003682 <fsinit>
    80001d02:	bff9                	j	80001ce0 <forkret+0x22>

0000000080001d04 <allocpid>:
allocpid() {
    80001d04:	1101                	addi	sp,sp,-32
    80001d06:	ec06                	sd	ra,24(sp)
    80001d08:	e822                	sd	s0,16(sp)
    80001d0a:	e426                	sd	s1,8(sp)
    80001d0c:	e04a                	sd	s2,0(sp)
    80001d0e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d10:	00030917          	auipc	s2,0x30
    80001d14:	c5890913          	addi	s2,s2,-936 # 80031968 <pid_lock>
    80001d18:	854a                	mv	a0,s2
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	080080e7          	jalr	128(ra) # 80000d9a <acquire>
  pid = nextpid;
    80001d22:	00007797          	auipc	a5,0x7
    80001d26:	b3278793          	addi	a5,a5,-1230 # 80008854 <nextpid>
    80001d2a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d2c:	0014871b          	addiw	a4,s1,1
    80001d30:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d32:	854a                	mv	a0,s2
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	11a080e7          	jalr	282(ra) # 80000e4e <release>
}
    80001d3c:	8526                	mv	a0,s1
    80001d3e:	60e2                	ld	ra,24(sp)
    80001d40:	6442                	ld	s0,16(sp)
    80001d42:	64a2                	ld	s1,8(sp)
    80001d44:	6902                	ld	s2,0(sp)
    80001d46:	6105                	addi	sp,sp,32
    80001d48:	8082                	ret

0000000080001d4a <proc_pagetable>:
{
    80001d4a:	1101                	addi	sp,sp,-32
    80001d4c:	ec06                	sd	ra,24(sp)
    80001d4e:	e822                	sd	s0,16(sp)
    80001d50:	e426                	sd	s1,8(sp)
    80001d52:	e04a                	sd	s2,0(sp)
    80001d54:	1000                	addi	s0,sp,32
    80001d56:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	7cc080e7          	jalr	1996(ra) # 80001524 <uvmcreate>
    80001d60:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001d62:	c121                	beqz	a0,80001da2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d64:	4729                	li	a4,10
    80001d66:	00005697          	auipc	a3,0x5
    80001d6a:	29a68693          	addi	a3,a3,666 # 80007000 <_trampoline>
    80001d6e:	6605                	lui	a2,0x1
    80001d70:	040005b7          	lui	a1,0x4000
    80001d74:	15fd                	addi	a1,a1,-1
    80001d76:	05b2                	slli	a1,a1,0xc
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	550080e7          	jalr	1360(ra) # 800012c8 <mappages>
    80001d80:	02054863          	bltz	a0,80001db0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d84:	4719                	li	a4,6
    80001d86:	05893683          	ld	a3,88(s2)
    80001d8a:	6605                	lui	a2,0x1
    80001d8c:	020005b7          	lui	a1,0x2000
    80001d90:	15fd                	addi	a1,a1,-1
    80001d92:	05b6                	slli	a1,a1,0xd
    80001d94:	8526                	mv	a0,s1
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	532080e7          	jalr	1330(ra) # 800012c8 <mappages>
    80001d9e:	02054163          	bltz	a0,80001dc0 <proc_pagetable+0x76>
}
    80001da2:	8526                	mv	a0,s1
    80001da4:	60e2                	ld	ra,24(sp)
    80001da6:	6442                	ld	s0,16(sp)
    80001da8:	64a2                	ld	s1,8(sp)
    80001daa:	6902                	ld	s2,0(sp)
    80001dac:	6105                	addi	sp,sp,32
    80001dae:	8082                	ret
    uvmfree(pagetable, 0);
    80001db0:	4581                	li	a1,0
    80001db2:	8526                	mv	a0,s1
    80001db4:	00000097          	auipc	ra,0x0
    80001db8:	96c080e7          	jalr	-1684(ra) # 80001720 <uvmfree>
    return 0;
    80001dbc:	4481                	li	s1,0
    80001dbe:	b7d5                	j	80001da2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dc0:	4681                	li	a3,0
    80001dc2:	4605                	li	a2,1
    80001dc4:	040005b7          	lui	a1,0x4000
    80001dc8:	15fd                	addi	a1,a1,-1
    80001dca:	05b2                	slli	a1,a1,0xc
    80001dcc:	8526                	mv	a0,s1
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	692080e7          	jalr	1682(ra) # 80001460 <uvmunmap>
    uvmfree(pagetable, 0);
    80001dd6:	4581                	li	a1,0
    80001dd8:	8526                	mv	a0,s1
    80001dda:	00000097          	auipc	ra,0x0
    80001dde:	946080e7          	jalr	-1722(ra) # 80001720 <uvmfree>
    return 0;
    80001de2:	4481                	li	s1,0
    80001de4:	bf7d                	j	80001da2 <proc_pagetable+0x58>

0000000080001de6 <proc_freepagetable>:
{
    80001de6:	1101                	addi	sp,sp,-32
    80001de8:	ec06                	sd	ra,24(sp)
    80001dea:	e822                	sd	s0,16(sp)
    80001dec:	e426                	sd	s1,8(sp)
    80001dee:	e04a                	sd	s2,0(sp)
    80001df0:	1000                	addi	s0,sp,32
    80001df2:	84aa                	mv	s1,a0
    80001df4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001df6:	4681                	li	a3,0
    80001df8:	4605                	li	a2,1
    80001dfa:	040005b7          	lui	a1,0x4000
    80001dfe:	15fd                	addi	a1,a1,-1
    80001e00:	05b2                	slli	a1,a1,0xc
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	65e080e7          	jalr	1630(ra) # 80001460 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e0a:	4681                	li	a3,0
    80001e0c:	4605                	li	a2,1
    80001e0e:	020005b7          	lui	a1,0x2000
    80001e12:	15fd                	addi	a1,a1,-1
    80001e14:	05b6                	slli	a1,a1,0xd
    80001e16:	8526                	mv	a0,s1
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	648080e7          	jalr	1608(ra) # 80001460 <uvmunmap>
  uvmfree(pagetable, sz);
    80001e20:	85ca                	mv	a1,s2
    80001e22:	8526                	mv	a0,s1
    80001e24:	00000097          	auipc	ra,0x0
    80001e28:	8fc080e7          	jalr	-1796(ra) # 80001720 <uvmfree>
}
    80001e2c:	60e2                	ld	ra,24(sp)
    80001e2e:	6442                	ld	s0,16(sp)
    80001e30:	64a2                	ld	s1,8(sp)
    80001e32:	6902                	ld	s2,0(sp)
    80001e34:	6105                	addi	sp,sp,32
    80001e36:	8082                	ret

0000000080001e38 <freeproc>:
{
    80001e38:	1101                	addi	sp,sp,-32
    80001e3a:	ec06                	sd	ra,24(sp)
    80001e3c:	e822                	sd	s0,16(sp)
    80001e3e:	e426                	sd	s1,8(sp)
    80001e40:	1000                	addi	s0,sp,32
    80001e42:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001e44:	6d28                	ld	a0,88(a0)
    80001e46:	c509                	beqz	a0,80001e50 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	bdc080e7          	jalr	-1060(ra) # 80000a24 <kfree>
  p->trapframe = 0;
    80001e50:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001e54:	68a8                	ld	a0,80(s1)
    80001e56:	c511                	beqz	a0,80001e62 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001e58:	64ac                	ld	a1,72(s1)
    80001e5a:	00000097          	auipc	ra,0x0
    80001e5e:	f8c080e7          	jalr	-116(ra) # 80001de6 <proc_freepagetable>
  p->pagetable = 0;
    80001e62:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e66:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e6a:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001e6e:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001e72:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e76:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001e7a:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001e7e:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001e82:	0004ac23          	sw	zero,24(s1)
}
    80001e86:	60e2                	ld	ra,24(sp)
    80001e88:	6442                	ld	s0,16(sp)
    80001e8a:	64a2                	ld	s1,8(sp)
    80001e8c:	6105                	addi	sp,sp,32
    80001e8e:	8082                	ret

0000000080001e90 <allocproc>:
{
    80001e90:	1101                	addi	sp,sp,-32
    80001e92:	ec06                	sd	ra,24(sp)
    80001e94:	e822                	sd	s0,16(sp)
    80001e96:	e426                	sd	s1,8(sp)
    80001e98:	e04a                	sd	s2,0(sp)
    80001e9a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e9c:	00030497          	auipc	s1,0x30
    80001ea0:	ee448493          	addi	s1,s1,-284 # 80031d80 <proc>
    80001ea4:	00036917          	auipc	s2,0x36
    80001ea8:	8dc90913          	addi	s2,s2,-1828 # 80037780 <tickslock>
    acquire(&p->lock);
    80001eac:	8526                	mv	a0,s1
    80001eae:	fffff097          	auipc	ra,0xfffff
    80001eb2:	eec080e7          	jalr	-276(ra) # 80000d9a <acquire>
    if(p->state == UNUSED) {
    80001eb6:	4c9c                	lw	a5,24(s1)
    80001eb8:	cf81                	beqz	a5,80001ed0 <allocproc+0x40>
      release(&p->lock);
    80001eba:	8526                	mv	a0,s1
    80001ebc:	fffff097          	auipc	ra,0xfffff
    80001ec0:	f92080e7          	jalr	-110(ra) # 80000e4e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ec4:	16848493          	addi	s1,s1,360
    80001ec8:	ff2492e3          	bne	s1,s2,80001eac <allocproc+0x1c>
  return 0;
    80001ecc:	4481                	li	s1,0
    80001ece:	a0b9                	j	80001f1c <allocproc+0x8c>
  p->pid = allocpid();
    80001ed0:	00000097          	auipc	ra,0x0
    80001ed4:	e34080e7          	jalr	-460(ra) # 80001d04 <allocpid>
    80001ed8:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	cb0080e7          	jalr	-848(ra) # 80000b8a <kalloc>
    80001ee2:	892a                	mv	s2,a0
    80001ee4:	eca8                	sd	a0,88(s1)
    80001ee6:	c131                	beqz	a0,80001f2a <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	00000097          	auipc	ra,0x0
    80001eee:	e60080e7          	jalr	-416(ra) # 80001d4a <proc_pagetable>
    80001ef2:	892a                	mv	s2,a0
    80001ef4:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001ef6:	c129                	beqz	a0,80001f38 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001ef8:	07000613          	li	a2,112
    80001efc:	4581                	li	a1,0
    80001efe:	06048513          	addi	a0,s1,96
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	f94080e7          	jalr	-108(ra) # 80000e96 <memset>
  p->context.ra = (uint64)forkret;
    80001f0a:	00000797          	auipc	a5,0x0
    80001f0e:	db478793          	addi	a5,a5,-588 # 80001cbe <forkret>
    80001f12:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f14:	60bc                	ld	a5,64(s1)
    80001f16:	6705                	lui	a4,0x1
    80001f18:	97ba                	add	a5,a5,a4
    80001f1a:	f4bc                	sd	a5,104(s1)
}
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	60e2                	ld	ra,24(sp)
    80001f20:	6442                	ld	s0,16(sp)
    80001f22:	64a2                	ld	s1,8(sp)
    80001f24:	6902                	ld	s2,0(sp)
    80001f26:	6105                	addi	sp,sp,32
    80001f28:	8082                	ret
    release(&p->lock);
    80001f2a:	8526                	mv	a0,s1
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	f22080e7          	jalr	-222(ra) # 80000e4e <release>
    return 0;
    80001f34:	84ca                	mv	s1,s2
    80001f36:	b7dd                	j	80001f1c <allocproc+0x8c>
    freeproc(p);
    80001f38:	8526                	mv	a0,s1
    80001f3a:	00000097          	auipc	ra,0x0
    80001f3e:	efe080e7          	jalr	-258(ra) # 80001e38 <freeproc>
    release(&p->lock);
    80001f42:	8526                	mv	a0,s1
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	f0a080e7          	jalr	-246(ra) # 80000e4e <release>
    return 0;
    80001f4c:	84ca                	mv	s1,s2
    80001f4e:	b7f9                	j	80001f1c <allocproc+0x8c>

0000000080001f50 <userinit>:
{
    80001f50:	1101                	addi	sp,sp,-32
    80001f52:	ec06                	sd	ra,24(sp)
    80001f54:	e822                	sd	s0,16(sp)
    80001f56:	e426                	sd	s1,8(sp)
    80001f58:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f5a:	00000097          	auipc	ra,0x0
    80001f5e:	f36080e7          	jalr	-202(ra) # 80001e90 <allocproc>
    80001f62:	84aa                	mv	s1,a0
  initproc = p;
    80001f64:	00007797          	auipc	a5,0x7
    80001f68:	0aa7ba23          	sd	a0,180(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f6c:	03400613          	li	a2,52
    80001f70:	00007597          	auipc	a1,0x7
    80001f74:	8f058593          	addi	a1,a1,-1808 # 80008860 <initcode>
    80001f78:	6928                	ld	a0,80(a0)
    80001f7a:	fffff097          	auipc	ra,0xfffff
    80001f7e:	5d8080e7          	jalr	1496(ra) # 80001552 <uvminit>
  p->sz = PGSIZE;
    80001f82:	6785                	lui	a5,0x1
    80001f84:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001f86:	6cb8                	ld	a4,88(s1)
    80001f88:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001f8c:	6cb8                	ld	a4,88(s1)
    80001f8e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f90:	4641                	li	a2,16
    80001f92:	00006597          	auipc	a1,0x6
    80001f96:	28e58593          	addi	a1,a1,654 # 80008220 <digits+0x1e0>
    80001f9a:	15848513          	addi	a0,s1,344
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	04e080e7          	jalr	78(ra) # 80000fec <safestrcpy>
  p->cwd = namei("/");
    80001fa6:	00006517          	auipc	a0,0x6
    80001faa:	28a50513          	addi	a0,a0,650 # 80008230 <digits+0x1f0>
    80001fae:	00002097          	auipc	ra,0x2
    80001fb2:	100080e7          	jalr	256(ra) # 800040ae <namei>
    80001fb6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001fba:	4789                	li	a5,2
    80001fbc:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	e8e080e7          	jalr	-370(ra) # 80000e4e <release>
}
    80001fc8:	60e2                	ld	ra,24(sp)
    80001fca:	6442                	ld	s0,16(sp)
    80001fcc:	64a2                	ld	s1,8(sp)
    80001fce:	6105                	addi	sp,sp,32
    80001fd0:	8082                	ret

0000000080001fd2 <growproc>:
{
    80001fd2:	1101                	addi	sp,sp,-32
    80001fd4:	ec06                	sd	ra,24(sp)
    80001fd6:	e822                	sd	s0,16(sp)
    80001fd8:	e426                	sd	s1,8(sp)
    80001fda:	e04a                	sd	s2,0(sp)
    80001fdc:	1000                	addi	s0,sp,32
    80001fde:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fe0:	00000097          	auipc	ra,0x0
    80001fe4:	ca6080e7          	jalr	-858(ra) # 80001c86 <myproc>
    80001fe8:	892a                	mv	s2,a0
  sz = p->sz;
    80001fea:	652c                	ld	a1,72(a0)
    80001fec:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001ff0:	00904f63          	bgtz	s1,8000200e <growproc+0x3c>
  } else if(n < 0){
    80001ff4:	0204cc63          	bltz	s1,8000202c <growproc+0x5a>
  p->sz = sz;
    80001ff8:	1602                	slli	a2,a2,0x20
    80001ffa:	9201                	srli	a2,a2,0x20
    80001ffc:	04c93423          	sd	a2,72(s2)
  return 0;
    80002000:	4501                	li	a0,0
}
    80002002:	60e2                	ld	ra,24(sp)
    80002004:	6442                	ld	s0,16(sp)
    80002006:	64a2                	ld	s1,8(sp)
    80002008:	6902                	ld	s2,0(sp)
    8000200a:	6105                	addi	sp,sp,32
    8000200c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    8000200e:	9e25                	addw	a2,a2,s1
    80002010:	1602                	slli	a2,a2,0x20
    80002012:	9201                	srli	a2,a2,0x20
    80002014:	1582                	slli	a1,a1,0x20
    80002016:	9181                	srli	a1,a1,0x20
    80002018:	6928                	ld	a0,80(a0)
    8000201a:	fffff097          	auipc	ra,0xfffff
    8000201e:	5f2080e7          	jalr	1522(ra) # 8000160c <uvmalloc>
    80002022:	0005061b          	sext.w	a2,a0
    80002026:	fa69                	bnez	a2,80001ff8 <growproc+0x26>
      return -1;
    80002028:	557d                	li	a0,-1
    8000202a:	bfe1                	j	80002002 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000202c:	9e25                	addw	a2,a2,s1
    8000202e:	1602                	slli	a2,a2,0x20
    80002030:	9201                	srli	a2,a2,0x20
    80002032:	1582                	slli	a1,a1,0x20
    80002034:	9181                	srli	a1,a1,0x20
    80002036:	6928                	ld	a0,80(a0)
    80002038:	fffff097          	auipc	ra,0xfffff
    8000203c:	58c080e7          	jalr	1420(ra) # 800015c4 <uvmdealloc>
    80002040:	0005061b          	sext.w	a2,a0
    80002044:	bf55                	j	80001ff8 <growproc+0x26>

0000000080002046 <fork>:
{
    80002046:	7179                	addi	sp,sp,-48
    80002048:	f406                	sd	ra,40(sp)
    8000204a:	f022                	sd	s0,32(sp)
    8000204c:	ec26                	sd	s1,24(sp)
    8000204e:	e84a                	sd	s2,16(sp)
    80002050:	e44e                	sd	s3,8(sp)
    80002052:	e052                	sd	s4,0(sp)
    80002054:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002056:	00000097          	auipc	ra,0x0
    8000205a:	c30080e7          	jalr	-976(ra) # 80001c86 <myproc>
    8000205e:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80002060:	00000097          	auipc	ra,0x0
    80002064:	e30080e7          	jalr	-464(ra) # 80001e90 <allocproc>
    80002068:	c175                	beqz	a0,8000214c <fork+0x106>
    8000206a:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000206c:	04893603          	ld	a2,72(s2)
    80002070:	692c                	ld	a1,80(a0)
    80002072:	05093503          	ld	a0,80(s2)
    80002076:	fffff097          	auipc	ra,0xfffff
    8000207a:	6e2080e7          	jalr	1762(ra) # 80001758 <uvmcopy>
    8000207e:	04054863          	bltz	a0,800020ce <fork+0x88>
  np->sz = p->sz;
    80002082:	04893783          	ld	a5,72(s2)
    80002086:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    8000208a:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    8000208e:	05893683          	ld	a3,88(s2)
    80002092:	87b6                	mv	a5,a3
    80002094:	0589b703          	ld	a4,88(s3)
    80002098:	12068693          	addi	a3,a3,288
    8000209c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800020a0:	6788                	ld	a0,8(a5)
    800020a2:	6b8c                	ld	a1,16(a5)
    800020a4:	6f90                	ld	a2,24(a5)
    800020a6:	01073023          	sd	a6,0(a4)
    800020aa:	e708                	sd	a0,8(a4)
    800020ac:	eb0c                	sd	a1,16(a4)
    800020ae:	ef10                	sd	a2,24(a4)
    800020b0:	02078793          	addi	a5,a5,32
    800020b4:	02070713          	addi	a4,a4,32
    800020b8:	fed792e3          	bne	a5,a3,8000209c <fork+0x56>
  np->trapframe->a0 = 0;
    800020bc:	0589b783          	ld	a5,88(s3)
    800020c0:	0607b823          	sd	zero,112(a5)
    800020c4:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    800020c8:	15000a13          	li	s4,336
    800020cc:	a03d                	j	800020fa <fork+0xb4>
    freeproc(np);
    800020ce:	854e                	mv	a0,s3
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	d68080e7          	jalr	-664(ra) # 80001e38 <freeproc>
    release(&np->lock);
    800020d8:	854e                	mv	a0,s3
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	d74080e7          	jalr	-652(ra) # 80000e4e <release>
    return -1;
    800020e2:	54fd                	li	s1,-1
    800020e4:	a899                	j	8000213a <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    800020e6:	00002097          	auipc	ra,0x2
    800020ea:	654080e7          	jalr	1620(ra) # 8000473a <filedup>
    800020ee:	009987b3          	add	a5,s3,s1
    800020f2:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    800020f4:	04a1                	addi	s1,s1,8
    800020f6:	01448763          	beq	s1,s4,80002104 <fork+0xbe>
    if(p->ofile[i])
    800020fa:	009907b3          	add	a5,s2,s1
    800020fe:	6388                	ld	a0,0(a5)
    80002100:	f17d                	bnez	a0,800020e6 <fork+0xa0>
    80002102:	bfcd                	j	800020f4 <fork+0xae>
  np->cwd = idup(p->cwd);
    80002104:	15093503          	ld	a0,336(s2)
    80002108:	00001097          	auipc	ra,0x1
    8000210c:	7b4080e7          	jalr	1972(ra) # 800038bc <idup>
    80002110:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002114:	4641                	li	a2,16
    80002116:	15890593          	addi	a1,s2,344
    8000211a:	15898513          	addi	a0,s3,344
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	ece080e7          	jalr	-306(ra) # 80000fec <safestrcpy>
  pid = np->pid;
    80002126:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    8000212a:	4789                	li	a5,2
    8000212c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002130:	854e                	mv	a0,s3
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	d1c080e7          	jalr	-740(ra) # 80000e4e <release>
}
    8000213a:	8526                	mv	a0,s1
    8000213c:	70a2                	ld	ra,40(sp)
    8000213e:	7402                	ld	s0,32(sp)
    80002140:	64e2                	ld	s1,24(sp)
    80002142:	6942                	ld	s2,16(sp)
    80002144:	69a2                	ld	s3,8(sp)
    80002146:	6a02                	ld	s4,0(sp)
    80002148:	6145                	addi	sp,sp,48
    8000214a:	8082                	ret
    return -1;
    8000214c:	54fd                	li	s1,-1
    8000214e:	b7f5                	j	8000213a <fork+0xf4>

0000000080002150 <reparent>:
{
    80002150:	7179                	addi	sp,sp,-48
    80002152:	f406                	sd	ra,40(sp)
    80002154:	f022                	sd	s0,32(sp)
    80002156:	ec26                	sd	s1,24(sp)
    80002158:	e84a                	sd	s2,16(sp)
    8000215a:	e44e                	sd	s3,8(sp)
    8000215c:	e052                	sd	s4,0(sp)
    8000215e:	1800                	addi	s0,sp,48
    80002160:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002162:	00030497          	auipc	s1,0x30
    80002166:	c1e48493          	addi	s1,s1,-994 # 80031d80 <proc>
      pp->parent = initproc;
    8000216a:	00007a17          	auipc	s4,0x7
    8000216e:	eaea0a13          	addi	s4,s4,-338 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002172:	00035997          	auipc	s3,0x35
    80002176:	60e98993          	addi	s3,s3,1550 # 80037780 <tickslock>
    8000217a:	a029                	j	80002184 <reparent+0x34>
    8000217c:	16848493          	addi	s1,s1,360
    80002180:	03348363          	beq	s1,s3,800021a6 <reparent+0x56>
    if(pp->parent == p){
    80002184:	709c                	ld	a5,32(s1)
    80002186:	ff279be3          	bne	a5,s2,8000217c <reparent+0x2c>
      acquire(&pp->lock);
    8000218a:	8526                	mv	a0,s1
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	c0e080e7          	jalr	-1010(ra) # 80000d9a <acquire>
      pp->parent = initproc;
    80002194:	000a3783          	ld	a5,0(s4)
    80002198:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    8000219a:	8526                	mv	a0,s1
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	cb2080e7          	jalr	-846(ra) # 80000e4e <release>
    800021a4:	bfe1                	j	8000217c <reparent+0x2c>
}
    800021a6:	70a2                	ld	ra,40(sp)
    800021a8:	7402                	ld	s0,32(sp)
    800021aa:	64e2                	ld	s1,24(sp)
    800021ac:	6942                	ld	s2,16(sp)
    800021ae:	69a2                	ld	s3,8(sp)
    800021b0:	6a02                	ld	s4,0(sp)
    800021b2:	6145                	addi	sp,sp,48
    800021b4:	8082                	ret

00000000800021b6 <scheduler>:
{
    800021b6:	711d                	addi	sp,sp,-96
    800021b8:	ec86                	sd	ra,88(sp)
    800021ba:	e8a2                	sd	s0,80(sp)
    800021bc:	e4a6                	sd	s1,72(sp)
    800021be:	e0ca                	sd	s2,64(sp)
    800021c0:	fc4e                	sd	s3,56(sp)
    800021c2:	f852                	sd	s4,48(sp)
    800021c4:	f456                	sd	s5,40(sp)
    800021c6:	f05a                	sd	s6,32(sp)
    800021c8:	ec5e                	sd	s7,24(sp)
    800021ca:	e862                	sd	s8,16(sp)
    800021cc:	e466                	sd	s9,8(sp)
    800021ce:	1080                	addi	s0,sp,96
    800021d0:	8792                	mv	a5,tp
  int id = r_tp();
    800021d2:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021d4:	00779c13          	slli	s8,a5,0x7
    800021d8:	0002f717          	auipc	a4,0x2f
    800021dc:	79070713          	addi	a4,a4,1936 # 80031968 <pid_lock>
    800021e0:	9762                	add	a4,a4,s8
    800021e2:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    800021e6:	0002f717          	auipc	a4,0x2f
    800021ea:	7a270713          	addi	a4,a4,1954 # 80031988 <cpus+0x8>
    800021ee:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    800021f0:	4a89                	li	s5,2
        c->proc = p;
    800021f2:	079e                	slli	a5,a5,0x7
    800021f4:	0002fb17          	auipc	s6,0x2f
    800021f8:	774b0b13          	addi	s6,s6,1908 # 80031968 <pid_lock>
    800021fc:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800021fe:	00035a17          	auipc	s4,0x35
    80002202:	582a0a13          	addi	s4,s4,1410 # 80037780 <tickslock>
    int nproc = 0;
    80002206:	4c81                	li	s9,0
    80002208:	a8a1                	j	80002260 <scheduler+0xaa>
        p->state = RUNNING;
    8000220a:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    8000220e:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80002212:	06048593          	addi	a1,s1,96
    80002216:	8562                	mv	a0,s8
    80002218:	00000097          	auipc	ra,0x0
    8000221c:	63a080e7          	jalr	1594(ra) # 80002852 <swtch>
        c->proc = 0;
    80002220:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    80002224:	8526                	mv	a0,s1
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	c28080e7          	jalr	-984(ra) # 80000e4e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000222e:	16848493          	addi	s1,s1,360
    80002232:	01448d63          	beq	s1,s4,8000224c <scheduler+0x96>
      acquire(&p->lock);
    80002236:	8526                	mv	a0,s1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	b62080e7          	jalr	-1182(ra) # 80000d9a <acquire>
      if(p->state != UNUSED) {
    80002240:	4c9c                	lw	a5,24(s1)
    80002242:	d3ed                	beqz	a5,80002224 <scheduler+0x6e>
        nproc++;
    80002244:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    80002246:	fd579fe3          	bne	a5,s5,80002224 <scheduler+0x6e>
    8000224a:	b7c1                	j	8000220a <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    8000224c:	013aca63          	blt	s5,s3,80002260 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002250:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002254:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002258:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000225c:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002260:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002264:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002268:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    8000226c:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    8000226e:	00030497          	auipc	s1,0x30
    80002272:	b1248493          	addi	s1,s1,-1262 # 80031d80 <proc>
        p->state = RUNNING;
    80002276:	4b8d                	li	s7,3
    80002278:	bf7d                	j	80002236 <scheduler+0x80>

000000008000227a <sched>:
{
    8000227a:	7179                	addi	sp,sp,-48
    8000227c:	f406                	sd	ra,40(sp)
    8000227e:	f022                	sd	s0,32(sp)
    80002280:	ec26                	sd	s1,24(sp)
    80002282:	e84a                	sd	s2,16(sp)
    80002284:	e44e                	sd	s3,8(sp)
    80002286:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002288:	00000097          	auipc	ra,0x0
    8000228c:	9fe080e7          	jalr	-1538(ra) # 80001c86 <myproc>
    80002290:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	a8e080e7          	jalr	-1394(ra) # 80000d20 <holding>
    8000229a:	c93d                	beqz	a0,80002310 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000229c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000229e:	2781                	sext.w	a5,a5
    800022a0:	079e                	slli	a5,a5,0x7
    800022a2:	0002f717          	auipc	a4,0x2f
    800022a6:	6c670713          	addi	a4,a4,1734 # 80031968 <pid_lock>
    800022aa:	97ba                	add	a5,a5,a4
    800022ac:	0907a703          	lw	a4,144(a5)
    800022b0:	4785                	li	a5,1
    800022b2:	06f71763          	bne	a4,a5,80002320 <sched+0xa6>
  if(p->state == RUNNING)
    800022b6:	4c98                	lw	a4,24(s1)
    800022b8:	478d                	li	a5,3
    800022ba:	06f70b63          	beq	a4,a5,80002330 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022be:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022c2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800022c4:	efb5                	bnez	a5,80002340 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022c6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022c8:	0002f917          	auipc	s2,0x2f
    800022cc:	6a090913          	addi	s2,s2,1696 # 80031968 <pid_lock>
    800022d0:	2781                	sext.w	a5,a5
    800022d2:	079e                	slli	a5,a5,0x7
    800022d4:	97ca                	add	a5,a5,s2
    800022d6:	0947a983          	lw	s3,148(a5)
    800022da:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800022dc:	2781                	sext.w	a5,a5
    800022de:	079e                	slli	a5,a5,0x7
    800022e0:	0002f597          	auipc	a1,0x2f
    800022e4:	6a858593          	addi	a1,a1,1704 # 80031988 <cpus+0x8>
    800022e8:	95be                	add	a1,a1,a5
    800022ea:	06048513          	addi	a0,s1,96
    800022ee:	00000097          	auipc	ra,0x0
    800022f2:	564080e7          	jalr	1380(ra) # 80002852 <swtch>
    800022f6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800022f8:	2781                	sext.w	a5,a5
    800022fa:	079e                	slli	a5,a5,0x7
    800022fc:	97ca                	add	a5,a5,s2
    800022fe:	0937aa23          	sw	s3,148(a5)
}
    80002302:	70a2                	ld	ra,40(sp)
    80002304:	7402                	ld	s0,32(sp)
    80002306:	64e2                	ld	s1,24(sp)
    80002308:	6942                	ld	s2,16(sp)
    8000230a:	69a2                	ld	s3,8(sp)
    8000230c:	6145                	addi	sp,sp,48
    8000230e:	8082                	ret
    panic("sched p->lock");
    80002310:	00006517          	auipc	a0,0x6
    80002314:	f2850513          	addi	a0,a0,-216 # 80008238 <digits+0x1f8>
    80002318:	ffffe097          	auipc	ra,0xffffe
    8000231c:	230080e7          	jalr	560(ra) # 80000548 <panic>
    panic("sched locks");
    80002320:	00006517          	auipc	a0,0x6
    80002324:	f2850513          	addi	a0,a0,-216 # 80008248 <digits+0x208>
    80002328:	ffffe097          	auipc	ra,0xffffe
    8000232c:	220080e7          	jalr	544(ra) # 80000548 <panic>
    panic("sched running");
    80002330:	00006517          	auipc	a0,0x6
    80002334:	f2850513          	addi	a0,a0,-216 # 80008258 <digits+0x218>
    80002338:	ffffe097          	auipc	ra,0xffffe
    8000233c:	210080e7          	jalr	528(ra) # 80000548 <panic>
    panic("sched interruptible");
    80002340:	00006517          	auipc	a0,0x6
    80002344:	f2850513          	addi	a0,a0,-216 # 80008268 <digits+0x228>
    80002348:	ffffe097          	auipc	ra,0xffffe
    8000234c:	200080e7          	jalr	512(ra) # 80000548 <panic>

0000000080002350 <exit>:
{
    80002350:	7179                	addi	sp,sp,-48
    80002352:	f406                	sd	ra,40(sp)
    80002354:	f022                	sd	s0,32(sp)
    80002356:	ec26                	sd	s1,24(sp)
    80002358:	e84a                	sd	s2,16(sp)
    8000235a:	e44e                	sd	s3,8(sp)
    8000235c:	e052                	sd	s4,0(sp)
    8000235e:	1800                	addi	s0,sp,48
    80002360:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002362:	00000097          	auipc	ra,0x0
    80002366:	924080e7          	jalr	-1756(ra) # 80001c86 <myproc>
    8000236a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000236c:	00007797          	auipc	a5,0x7
    80002370:	cac7b783          	ld	a5,-852(a5) # 80009018 <initproc>
    80002374:	0d050493          	addi	s1,a0,208
    80002378:	15050913          	addi	s2,a0,336
    8000237c:	02a79363          	bne	a5,a0,800023a2 <exit+0x52>
    panic("init exiting");
    80002380:	00006517          	auipc	a0,0x6
    80002384:	f0050513          	addi	a0,a0,-256 # 80008280 <digits+0x240>
    80002388:	ffffe097          	auipc	ra,0xffffe
    8000238c:	1c0080e7          	jalr	448(ra) # 80000548 <panic>
      fileclose(f);
    80002390:	00002097          	auipc	ra,0x2
    80002394:	3fc080e7          	jalr	1020(ra) # 8000478c <fileclose>
      p->ofile[fd] = 0;
    80002398:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000239c:	04a1                	addi	s1,s1,8
    8000239e:	01248563          	beq	s1,s2,800023a8 <exit+0x58>
    if(p->ofile[fd]){
    800023a2:	6088                	ld	a0,0(s1)
    800023a4:	f575                	bnez	a0,80002390 <exit+0x40>
    800023a6:	bfdd                	j	8000239c <exit+0x4c>
  begin_op();
    800023a8:	00002097          	auipc	ra,0x2
    800023ac:	f12080e7          	jalr	-238(ra) # 800042ba <begin_op>
  iput(p->cwd);
    800023b0:	1509b503          	ld	a0,336(s3)
    800023b4:	00001097          	auipc	ra,0x1
    800023b8:	700080e7          	jalr	1792(ra) # 80003ab4 <iput>
  end_op();
    800023bc:	00002097          	auipc	ra,0x2
    800023c0:	f7e080e7          	jalr	-130(ra) # 8000433a <end_op>
  p->cwd = 0;
    800023c4:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800023c8:	00007497          	auipc	s1,0x7
    800023cc:	c5048493          	addi	s1,s1,-944 # 80009018 <initproc>
    800023d0:	6088                	ld	a0,0(s1)
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	9c8080e7          	jalr	-1592(ra) # 80000d9a <acquire>
  wakeup1(initproc);
    800023da:	6088                	ld	a0,0(s1)
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	76a080e7          	jalr	1898(ra) # 80001b46 <wakeup1>
  release(&initproc->lock);
    800023e4:	6088                	ld	a0,0(s1)
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	a68080e7          	jalr	-1432(ra) # 80000e4e <release>
  acquire(&p->lock);
    800023ee:	854e                	mv	a0,s3
    800023f0:	fffff097          	auipc	ra,0xfffff
    800023f4:	9aa080e7          	jalr	-1622(ra) # 80000d9a <acquire>
  struct proc *original_parent = p->parent;
    800023f8:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800023fc:	854e                	mv	a0,s3
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	a50080e7          	jalr	-1456(ra) # 80000e4e <release>
  acquire(&original_parent->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	992080e7          	jalr	-1646(ra) # 80000d9a <acquire>
  acquire(&p->lock);
    80002410:	854e                	mv	a0,s3
    80002412:	fffff097          	auipc	ra,0xfffff
    80002416:	988080e7          	jalr	-1656(ra) # 80000d9a <acquire>
  reparent(p);
    8000241a:	854e                	mv	a0,s3
    8000241c:	00000097          	auipc	ra,0x0
    80002420:	d34080e7          	jalr	-716(ra) # 80002150 <reparent>
  wakeup1(original_parent);
    80002424:	8526                	mv	a0,s1
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	720080e7          	jalr	1824(ra) # 80001b46 <wakeup1>
  p->xstate = status;
    8000242e:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002432:	4791                	li	a5,4
    80002434:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002438:	8526                	mv	a0,s1
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	a14080e7          	jalr	-1516(ra) # 80000e4e <release>
  sched();
    80002442:	00000097          	auipc	ra,0x0
    80002446:	e38080e7          	jalr	-456(ra) # 8000227a <sched>
  panic("zombie exit");
    8000244a:	00006517          	auipc	a0,0x6
    8000244e:	e4650513          	addi	a0,a0,-442 # 80008290 <digits+0x250>
    80002452:	ffffe097          	auipc	ra,0xffffe
    80002456:	0f6080e7          	jalr	246(ra) # 80000548 <panic>

000000008000245a <yield>:
{
    8000245a:	1101                	addi	sp,sp,-32
    8000245c:	ec06                	sd	ra,24(sp)
    8000245e:	e822                	sd	s0,16(sp)
    80002460:	e426                	sd	s1,8(sp)
    80002462:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002464:	00000097          	auipc	ra,0x0
    80002468:	822080e7          	jalr	-2014(ra) # 80001c86 <myproc>
    8000246c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	92c080e7          	jalr	-1748(ra) # 80000d9a <acquire>
  p->state = RUNNABLE;
    80002476:	4789                	li	a5,2
    80002478:	cc9c                	sw	a5,24(s1)
  sched();
    8000247a:	00000097          	auipc	ra,0x0
    8000247e:	e00080e7          	jalr	-512(ra) # 8000227a <sched>
  release(&p->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	9ca080e7          	jalr	-1590(ra) # 80000e4e <release>
}
    8000248c:	60e2                	ld	ra,24(sp)
    8000248e:	6442                	ld	s0,16(sp)
    80002490:	64a2                	ld	s1,8(sp)
    80002492:	6105                	addi	sp,sp,32
    80002494:	8082                	ret

0000000080002496 <sleep>:
{
    80002496:	7179                	addi	sp,sp,-48
    80002498:	f406                	sd	ra,40(sp)
    8000249a:	f022                	sd	s0,32(sp)
    8000249c:	ec26                	sd	s1,24(sp)
    8000249e:	e84a                	sd	s2,16(sp)
    800024a0:	e44e                	sd	s3,8(sp)
    800024a2:	1800                	addi	s0,sp,48
    800024a4:	89aa                	mv	s3,a0
    800024a6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024a8:	fffff097          	auipc	ra,0xfffff
    800024ac:	7de080e7          	jalr	2014(ra) # 80001c86 <myproc>
    800024b0:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800024b2:	05250663          	beq	a0,s2,800024fe <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800024b6:	fffff097          	auipc	ra,0xfffff
    800024ba:	8e4080e7          	jalr	-1820(ra) # 80000d9a <acquire>
    release(lk);
    800024be:	854a                	mv	a0,s2
    800024c0:	fffff097          	auipc	ra,0xfffff
    800024c4:	98e080e7          	jalr	-1650(ra) # 80000e4e <release>
  p->chan = chan;
    800024c8:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800024cc:	4785                	li	a5,1
    800024ce:	cc9c                	sw	a5,24(s1)
  sched();
    800024d0:	00000097          	auipc	ra,0x0
    800024d4:	daa080e7          	jalr	-598(ra) # 8000227a <sched>
  p->chan = 0;
    800024d8:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800024dc:	8526                	mv	a0,s1
    800024de:	fffff097          	auipc	ra,0xfffff
    800024e2:	970080e7          	jalr	-1680(ra) # 80000e4e <release>
    acquire(lk);
    800024e6:	854a                	mv	a0,s2
    800024e8:	fffff097          	auipc	ra,0xfffff
    800024ec:	8b2080e7          	jalr	-1870(ra) # 80000d9a <acquire>
}
    800024f0:	70a2                	ld	ra,40(sp)
    800024f2:	7402                	ld	s0,32(sp)
    800024f4:	64e2                	ld	s1,24(sp)
    800024f6:	6942                	ld	s2,16(sp)
    800024f8:	69a2                	ld	s3,8(sp)
    800024fa:	6145                	addi	sp,sp,48
    800024fc:	8082                	ret
  p->chan = chan;
    800024fe:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002502:	4785                	li	a5,1
    80002504:	cd1c                	sw	a5,24(a0)
  sched();
    80002506:	00000097          	auipc	ra,0x0
    8000250a:	d74080e7          	jalr	-652(ra) # 8000227a <sched>
  p->chan = 0;
    8000250e:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002512:	bff9                	j	800024f0 <sleep+0x5a>

0000000080002514 <wait>:
{
    80002514:	715d                	addi	sp,sp,-80
    80002516:	e486                	sd	ra,72(sp)
    80002518:	e0a2                	sd	s0,64(sp)
    8000251a:	fc26                	sd	s1,56(sp)
    8000251c:	f84a                	sd	s2,48(sp)
    8000251e:	f44e                	sd	s3,40(sp)
    80002520:	f052                	sd	s4,32(sp)
    80002522:	ec56                	sd	s5,24(sp)
    80002524:	e85a                	sd	s6,16(sp)
    80002526:	e45e                	sd	s7,8(sp)
    80002528:	e062                	sd	s8,0(sp)
    8000252a:	0880                	addi	s0,sp,80
    8000252c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	758080e7          	jalr	1880(ra) # 80001c86 <myproc>
    80002536:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002538:	8c2a                	mv	s8,a0
    8000253a:	fffff097          	auipc	ra,0xfffff
    8000253e:	860080e7          	jalr	-1952(ra) # 80000d9a <acquire>
    havekids = 0;
    80002542:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002544:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002546:	00035997          	auipc	s3,0x35
    8000254a:	23a98993          	addi	s3,s3,570 # 80037780 <tickslock>
        havekids = 1;
    8000254e:	4a85                	li	s5,1
    havekids = 0;
    80002550:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002552:	00030497          	auipc	s1,0x30
    80002556:	82e48493          	addi	s1,s1,-2002 # 80031d80 <proc>
    8000255a:	a08d                	j	800025bc <wait+0xa8>
          pid = np->pid;
    8000255c:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002560:	000b0e63          	beqz	s6,8000257c <wait+0x68>
    80002564:	4691                	li	a3,4
    80002566:	03448613          	addi	a2,s1,52
    8000256a:	85da                	mv	a1,s6
    8000256c:	05093503          	ld	a0,80(s2)
    80002570:	fffff097          	auipc	ra,0xfffff
    80002574:	532080e7          	jalr	1330(ra) # 80001aa2 <copyout>
    80002578:	02054263          	bltz	a0,8000259c <wait+0x88>
          freeproc(np);
    8000257c:	8526                	mv	a0,s1
    8000257e:	00000097          	auipc	ra,0x0
    80002582:	8ba080e7          	jalr	-1862(ra) # 80001e38 <freeproc>
          release(&np->lock);
    80002586:	8526                	mv	a0,s1
    80002588:	fffff097          	auipc	ra,0xfffff
    8000258c:	8c6080e7          	jalr	-1850(ra) # 80000e4e <release>
          release(&p->lock);
    80002590:	854a                	mv	a0,s2
    80002592:	fffff097          	auipc	ra,0xfffff
    80002596:	8bc080e7          	jalr	-1860(ra) # 80000e4e <release>
          return pid;
    8000259a:	a8a9                	j	800025f4 <wait+0xe0>
            release(&np->lock);
    8000259c:	8526                	mv	a0,s1
    8000259e:	fffff097          	auipc	ra,0xfffff
    800025a2:	8b0080e7          	jalr	-1872(ra) # 80000e4e <release>
            release(&p->lock);
    800025a6:	854a                	mv	a0,s2
    800025a8:	fffff097          	auipc	ra,0xfffff
    800025ac:	8a6080e7          	jalr	-1882(ra) # 80000e4e <release>
            return -1;
    800025b0:	59fd                	li	s3,-1
    800025b2:	a089                	j	800025f4 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    800025b4:	16848493          	addi	s1,s1,360
    800025b8:	03348463          	beq	s1,s3,800025e0 <wait+0xcc>
      if(np->parent == p){
    800025bc:	709c                	ld	a5,32(s1)
    800025be:	ff279be3          	bne	a5,s2,800025b4 <wait+0xa0>
        acquire(&np->lock);
    800025c2:	8526                	mv	a0,s1
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	7d6080e7          	jalr	2006(ra) # 80000d9a <acquire>
        if(np->state == ZOMBIE){
    800025cc:	4c9c                	lw	a5,24(s1)
    800025ce:	f94787e3          	beq	a5,s4,8000255c <wait+0x48>
        release(&np->lock);
    800025d2:	8526                	mv	a0,s1
    800025d4:	fffff097          	auipc	ra,0xfffff
    800025d8:	87a080e7          	jalr	-1926(ra) # 80000e4e <release>
        havekids = 1;
    800025dc:	8756                	mv	a4,s5
    800025de:	bfd9                	j	800025b4 <wait+0xa0>
    if(!havekids || p->killed){
    800025e0:	c701                	beqz	a4,800025e8 <wait+0xd4>
    800025e2:	03092783          	lw	a5,48(s2)
    800025e6:	c785                	beqz	a5,8000260e <wait+0xfa>
      release(&p->lock);
    800025e8:	854a                	mv	a0,s2
    800025ea:	fffff097          	auipc	ra,0xfffff
    800025ee:	864080e7          	jalr	-1948(ra) # 80000e4e <release>
      return -1;
    800025f2:	59fd                	li	s3,-1
}
    800025f4:	854e                	mv	a0,s3
    800025f6:	60a6                	ld	ra,72(sp)
    800025f8:	6406                	ld	s0,64(sp)
    800025fa:	74e2                	ld	s1,56(sp)
    800025fc:	7942                	ld	s2,48(sp)
    800025fe:	79a2                	ld	s3,40(sp)
    80002600:	7a02                	ld	s4,32(sp)
    80002602:	6ae2                	ld	s5,24(sp)
    80002604:	6b42                	ld	s6,16(sp)
    80002606:	6ba2                	ld	s7,8(sp)
    80002608:	6c02                	ld	s8,0(sp)
    8000260a:	6161                	addi	sp,sp,80
    8000260c:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000260e:	85e2                	mv	a1,s8
    80002610:	854a                	mv	a0,s2
    80002612:	00000097          	auipc	ra,0x0
    80002616:	e84080e7          	jalr	-380(ra) # 80002496 <sleep>
    havekids = 0;
    8000261a:	bf1d                	j	80002550 <wait+0x3c>

000000008000261c <wakeup>:
{
    8000261c:	7139                	addi	sp,sp,-64
    8000261e:	fc06                	sd	ra,56(sp)
    80002620:	f822                	sd	s0,48(sp)
    80002622:	f426                	sd	s1,40(sp)
    80002624:	f04a                	sd	s2,32(sp)
    80002626:	ec4e                	sd	s3,24(sp)
    80002628:	e852                	sd	s4,16(sp)
    8000262a:	e456                	sd	s5,8(sp)
    8000262c:	0080                	addi	s0,sp,64
    8000262e:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002630:	0002f497          	auipc	s1,0x2f
    80002634:	75048493          	addi	s1,s1,1872 # 80031d80 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002638:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000263a:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000263c:	00035917          	auipc	s2,0x35
    80002640:	14490913          	addi	s2,s2,324 # 80037780 <tickslock>
    80002644:	a821                	j	8000265c <wakeup+0x40>
      p->state = RUNNABLE;
    80002646:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    8000264a:	8526                	mv	a0,s1
    8000264c:	fffff097          	auipc	ra,0xfffff
    80002650:	802080e7          	jalr	-2046(ra) # 80000e4e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002654:	16848493          	addi	s1,s1,360
    80002658:	01248e63          	beq	s1,s2,80002674 <wakeup+0x58>
    acquire(&p->lock);
    8000265c:	8526                	mv	a0,s1
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	73c080e7          	jalr	1852(ra) # 80000d9a <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002666:	4c9c                	lw	a5,24(s1)
    80002668:	ff3791e3          	bne	a5,s3,8000264a <wakeup+0x2e>
    8000266c:	749c                	ld	a5,40(s1)
    8000266e:	fd479ee3          	bne	a5,s4,8000264a <wakeup+0x2e>
    80002672:	bfd1                	j	80002646 <wakeup+0x2a>
}
    80002674:	70e2                	ld	ra,56(sp)
    80002676:	7442                	ld	s0,48(sp)
    80002678:	74a2                	ld	s1,40(sp)
    8000267a:	7902                	ld	s2,32(sp)
    8000267c:	69e2                	ld	s3,24(sp)
    8000267e:	6a42                	ld	s4,16(sp)
    80002680:	6aa2                	ld	s5,8(sp)
    80002682:	6121                	addi	sp,sp,64
    80002684:	8082                	ret

0000000080002686 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002686:	7179                	addi	sp,sp,-48
    80002688:	f406                	sd	ra,40(sp)
    8000268a:	f022                	sd	s0,32(sp)
    8000268c:	ec26                	sd	s1,24(sp)
    8000268e:	e84a                	sd	s2,16(sp)
    80002690:	e44e                	sd	s3,8(sp)
    80002692:	1800                	addi	s0,sp,48
    80002694:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002696:	0002f497          	auipc	s1,0x2f
    8000269a:	6ea48493          	addi	s1,s1,1770 # 80031d80 <proc>
    8000269e:	00035997          	auipc	s3,0x35
    800026a2:	0e298993          	addi	s3,s3,226 # 80037780 <tickslock>
    acquire(&p->lock);
    800026a6:	8526                	mv	a0,s1
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	6f2080e7          	jalr	1778(ra) # 80000d9a <acquire>
    if(p->pid == pid){
    800026b0:	5c9c                	lw	a5,56(s1)
    800026b2:	01278d63          	beq	a5,s2,800026cc <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800026b6:	8526                	mv	a0,s1
    800026b8:	ffffe097          	auipc	ra,0xffffe
    800026bc:	796080e7          	jalr	1942(ra) # 80000e4e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800026c0:	16848493          	addi	s1,s1,360
    800026c4:	ff3491e3          	bne	s1,s3,800026a6 <kill+0x20>
  }
  return -1;
    800026c8:	557d                	li	a0,-1
    800026ca:	a829                	j	800026e4 <kill+0x5e>
      p->killed = 1;
    800026cc:	4785                	li	a5,1
    800026ce:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800026d0:	4c98                	lw	a4,24(s1)
    800026d2:	4785                	li	a5,1
    800026d4:	00f70f63          	beq	a4,a5,800026f2 <kill+0x6c>
      release(&p->lock);
    800026d8:	8526                	mv	a0,s1
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	774080e7          	jalr	1908(ra) # 80000e4e <release>
      return 0;
    800026e2:	4501                	li	a0,0
}
    800026e4:	70a2                	ld	ra,40(sp)
    800026e6:	7402                	ld	s0,32(sp)
    800026e8:	64e2                	ld	s1,24(sp)
    800026ea:	6942                	ld	s2,16(sp)
    800026ec:	69a2                	ld	s3,8(sp)
    800026ee:	6145                	addi	sp,sp,48
    800026f0:	8082                	ret
        p->state = RUNNABLE;
    800026f2:	4789                	li	a5,2
    800026f4:	cc9c                	sw	a5,24(s1)
    800026f6:	b7cd                	j	800026d8 <kill+0x52>

00000000800026f8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026f8:	7179                	addi	sp,sp,-48
    800026fa:	f406                	sd	ra,40(sp)
    800026fc:	f022                	sd	s0,32(sp)
    800026fe:	ec26                	sd	s1,24(sp)
    80002700:	e84a                	sd	s2,16(sp)
    80002702:	e44e                	sd	s3,8(sp)
    80002704:	e052                	sd	s4,0(sp)
    80002706:	1800                	addi	s0,sp,48
    80002708:	84aa                	mv	s1,a0
    8000270a:	892e                	mv	s2,a1
    8000270c:	89b2                	mv	s3,a2
    8000270e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002710:	fffff097          	auipc	ra,0xfffff
    80002714:	576080e7          	jalr	1398(ra) # 80001c86 <myproc>
  if(user_dst){
    80002718:	c08d                	beqz	s1,8000273a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000271a:	86d2                	mv	a3,s4
    8000271c:	864e                	mv	a2,s3
    8000271e:	85ca                	mv	a1,s2
    80002720:	6928                	ld	a0,80(a0)
    80002722:	fffff097          	auipc	ra,0xfffff
    80002726:	380080e7          	jalr	896(ra) # 80001aa2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000272a:	70a2                	ld	ra,40(sp)
    8000272c:	7402                	ld	s0,32(sp)
    8000272e:	64e2                	ld	s1,24(sp)
    80002730:	6942                	ld	s2,16(sp)
    80002732:	69a2                	ld	s3,8(sp)
    80002734:	6a02                	ld	s4,0(sp)
    80002736:	6145                	addi	sp,sp,48
    80002738:	8082                	ret
    memmove((char *)dst, src, len);
    8000273a:	000a061b          	sext.w	a2,s4
    8000273e:	85ce                	mv	a1,s3
    80002740:	854a                	mv	a0,s2
    80002742:	ffffe097          	auipc	ra,0xffffe
    80002746:	7b4080e7          	jalr	1972(ra) # 80000ef6 <memmove>
    return 0;
    8000274a:	8526                	mv	a0,s1
    8000274c:	bff9                	j	8000272a <either_copyout+0x32>

000000008000274e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000274e:	7179                	addi	sp,sp,-48
    80002750:	f406                	sd	ra,40(sp)
    80002752:	f022                	sd	s0,32(sp)
    80002754:	ec26                	sd	s1,24(sp)
    80002756:	e84a                	sd	s2,16(sp)
    80002758:	e44e                	sd	s3,8(sp)
    8000275a:	e052                	sd	s4,0(sp)
    8000275c:	1800                	addi	s0,sp,48
    8000275e:	892a                	mv	s2,a0
    80002760:	84ae                	mv	s1,a1
    80002762:	89b2                	mv	s3,a2
    80002764:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002766:	fffff097          	auipc	ra,0xfffff
    8000276a:	520080e7          	jalr	1312(ra) # 80001c86 <myproc>
  if(user_src){
    8000276e:	c08d                	beqz	s1,80002790 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002770:	86d2                	mv	a3,s4
    80002772:	864e                	mv	a2,s3
    80002774:	85ca                	mv	a1,s2
    80002776:	6928                	ld	a0,80(a0)
    80002778:	fffff097          	auipc	ra,0xfffff
    8000277c:	0ee080e7          	jalr	238(ra) # 80001866 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002780:	70a2                	ld	ra,40(sp)
    80002782:	7402                	ld	s0,32(sp)
    80002784:	64e2                	ld	s1,24(sp)
    80002786:	6942                	ld	s2,16(sp)
    80002788:	69a2                	ld	s3,8(sp)
    8000278a:	6a02                	ld	s4,0(sp)
    8000278c:	6145                	addi	sp,sp,48
    8000278e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002790:	000a061b          	sext.w	a2,s4
    80002794:	85ce                	mv	a1,s3
    80002796:	854a                	mv	a0,s2
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	75e080e7          	jalr	1886(ra) # 80000ef6 <memmove>
    return 0;
    800027a0:	8526                	mv	a0,s1
    800027a2:	bff9                	j	80002780 <either_copyin+0x32>

00000000800027a4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800027a4:	715d                	addi	sp,sp,-80
    800027a6:	e486                	sd	ra,72(sp)
    800027a8:	e0a2                	sd	s0,64(sp)
    800027aa:	fc26                	sd	s1,56(sp)
    800027ac:	f84a                	sd	s2,48(sp)
    800027ae:	f44e                	sd	s3,40(sp)
    800027b0:	f052                	sd	s4,32(sp)
    800027b2:	ec56                	sd	s5,24(sp)
    800027b4:	e85a                	sd	s6,16(sp)
    800027b6:	e45e                	sd	s7,8(sp)
    800027b8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027ba:	00006517          	auipc	a0,0x6
    800027be:	91650513          	addi	a0,a0,-1770 # 800080d0 <digits+0x90>
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	dd0080e7          	jalr	-560(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ca:	0002f497          	auipc	s1,0x2f
    800027ce:	70e48493          	addi	s1,s1,1806 # 80031ed8 <proc+0x158>
    800027d2:	00035917          	auipc	s2,0x35
    800027d6:	10690913          	addi	s2,s2,262 # 800378d8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027da:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800027dc:	00006997          	auipc	s3,0x6
    800027e0:	ac498993          	addi	s3,s3,-1340 # 800082a0 <digits+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    800027e4:	00006a97          	auipc	s5,0x6
    800027e8:	ac4a8a93          	addi	s5,s5,-1340 # 800082a8 <digits+0x268>
    printf("\n");
    800027ec:	00006a17          	auipc	s4,0x6
    800027f0:	8e4a0a13          	addi	s4,s4,-1820 # 800080d0 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027f4:	00006b97          	auipc	s7,0x6
    800027f8:	aecb8b93          	addi	s7,s7,-1300 # 800082e0 <states.1710>
    800027fc:	a00d                	j	8000281e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027fe:	ee06a583          	lw	a1,-288(a3)
    80002802:	8556                	mv	a0,s5
    80002804:	ffffe097          	auipc	ra,0xffffe
    80002808:	d8e080e7          	jalr	-626(ra) # 80000592 <printf>
    printf("\n");
    8000280c:	8552                	mv	a0,s4
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	d84080e7          	jalr	-636(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002816:	16848493          	addi	s1,s1,360
    8000281a:	03248163          	beq	s1,s2,8000283c <procdump+0x98>
    if(p->state == UNUSED)
    8000281e:	86a6                	mv	a3,s1
    80002820:	ec04a783          	lw	a5,-320(s1)
    80002824:	dbed                	beqz	a5,80002816 <procdump+0x72>
      state = "???";
    80002826:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002828:	fcfb6be3          	bltu	s6,a5,800027fe <procdump+0x5a>
    8000282c:	1782                	slli	a5,a5,0x20
    8000282e:	9381                	srli	a5,a5,0x20
    80002830:	078e                	slli	a5,a5,0x3
    80002832:	97de                	add	a5,a5,s7
    80002834:	6390                	ld	a2,0(a5)
    80002836:	f661                	bnez	a2,800027fe <procdump+0x5a>
      state = "???";
    80002838:	864e                	mv	a2,s3
    8000283a:	b7d1                	j	800027fe <procdump+0x5a>
  }
}
    8000283c:	60a6                	ld	ra,72(sp)
    8000283e:	6406                	ld	s0,64(sp)
    80002840:	74e2                	ld	s1,56(sp)
    80002842:	7942                	ld	s2,48(sp)
    80002844:	79a2                	ld	s3,40(sp)
    80002846:	7a02                	ld	s4,32(sp)
    80002848:	6ae2                	ld	s5,24(sp)
    8000284a:	6b42                	ld	s6,16(sp)
    8000284c:	6ba2                	ld	s7,8(sp)
    8000284e:	6161                	addi	sp,sp,80
    80002850:	8082                	ret

0000000080002852 <swtch>:
    80002852:	00153023          	sd	ra,0(a0)
    80002856:	00253423          	sd	sp,8(a0)
    8000285a:	e900                	sd	s0,16(a0)
    8000285c:	ed04                	sd	s1,24(a0)
    8000285e:	03253023          	sd	s2,32(a0)
    80002862:	03353423          	sd	s3,40(a0)
    80002866:	03453823          	sd	s4,48(a0)
    8000286a:	03553c23          	sd	s5,56(a0)
    8000286e:	05653023          	sd	s6,64(a0)
    80002872:	05753423          	sd	s7,72(a0)
    80002876:	05853823          	sd	s8,80(a0)
    8000287a:	05953c23          	sd	s9,88(a0)
    8000287e:	07a53023          	sd	s10,96(a0)
    80002882:	07b53423          	sd	s11,104(a0)
    80002886:	0005b083          	ld	ra,0(a1)
    8000288a:	0085b103          	ld	sp,8(a1)
    8000288e:	6980                	ld	s0,16(a1)
    80002890:	6d84                	ld	s1,24(a1)
    80002892:	0205b903          	ld	s2,32(a1)
    80002896:	0285b983          	ld	s3,40(a1)
    8000289a:	0305ba03          	ld	s4,48(a1)
    8000289e:	0385ba83          	ld	s5,56(a1)
    800028a2:	0405bb03          	ld	s6,64(a1)
    800028a6:	0485bb83          	ld	s7,72(a1)
    800028aa:	0505bc03          	ld	s8,80(a1)
    800028ae:	0585bc83          	ld	s9,88(a1)
    800028b2:	0605bd03          	ld	s10,96(a1)
    800028b6:	0685bd83          	ld	s11,104(a1)
    800028ba:	8082                	ret

00000000800028bc <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028bc:	1141                	addi	sp,sp,-16
    800028be:	e406                	sd	ra,8(sp)
    800028c0:	e022                	sd	s0,0(sp)
    800028c2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028c4:	00006597          	auipc	a1,0x6
    800028c8:	a4458593          	addi	a1,a1,-1468 # 80008308 <states.1710+0x28>
    800028cc:	00035517          	auipc	a0,0x35
    800028d0:	eb450513          	addi	a0,a0,-332 # 80037780 <tickslock>
    800028d4:	ffffe097          	auipc	ra,0xffffe
    800028d8:	436080e7          	jalr	1078(ra) # 80000d0a <initlock>
}
    800028dc:	60a2                	ld	ra,8(sp)
    800028de:	6402                	ld	s0,0(sp)
    800028e0:	0141                	addi	sp,sp,16
    800028e2:	8082                	ret

00000000800028e4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028e4:	1141                	addi	sp,sp,-16
    800028e6:	e422                	sd	s0,8(sp)
    800028e8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028ea:	00003797          	auipc	a5,0x3
    800028ee:	50678793          	addi	a5,a5,1286 # 80005df0 <kernelvec>
    800028f2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028f6:	6422                	ld	s0,8(sp)
    800028f8:	0141                	addi	sp,sp,16
    800028fa:	8082                	ret

00000000800028fc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028fc:	1141                	addi	sp,sp,-16
    800028fe:	e406                	sd	ra,8(sp)
    80002900:	e022                	sd	s0,0(sp)
    80002902:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002904:	fffff097          	auipc	ra,0xfffff
    80002908:	382080e7          	jalr	898(ra) # 80001c86 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000290c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002910:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002912:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002916:	00004617          	auipc	a2,0x4
    8000291a:	6ea60613          	addi	a2,a2,1770 # 80007000 <_trampoline>
    8000291e:	00004697          	auipc	a3,0x4
    80002922:	6e268693          	addi	a3,a3,1762 # 80007000 <_trampoline>
    80002926:	8e91                	sub	a3,a3,a2
    80002928:	040007b7          	lui	a5,0x4000
    8000292c:	17fd                	addi	a5,a5,-1
    8000292e:	07b2                	slli	a5,a5,0xc
    80002930:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002932:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002936:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002938:	180026f3          	csrr	a3,satp
    8000293c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000293e:	6d38                	ld	a4,88(a0)
    80002940:	6134                	ld	a3,64(a0)
    80002942:	6585                	lui	a1,0x1
    80002944:	96ae                	add	a3,a3,a1
    80002946:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002948:	6d38                	ld	a4,88(a0)
    8000294a:	00000697          	auipc	a3,0x0
    8000294e:	13868693          	addi	a3,a3,312 # 80002a82 <usertrap>
    80002952:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002954:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002956:	8692                	mv	a3,tp
    80002958:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000295a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000295e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002962:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002966:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000296a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000296c:	6f18                	ld	a4,24(a4)
    8000296e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002972:	692c                	ld	a1,80(a0)
    80002974:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002976:	00004717          	auipc	a4,0x4
    8000297a:	71a70713          	addi	a4,a4,1818 # 80007090 <userret>
    8000297e:	8f11                	sub	a4,a4,a2
    80002980:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002982:	577d                	li	a4,-1
    80002984:	177e                	slli	a4,a4,0x3f
    80002986:	8dd9                	or	a1,a1,a4
    80002988:	02000537          	lui	a0,0x2000
    8000298c:	157d                	addi	a0,a0,-1
    8000298e:	0536                	slli	a0,a0,0xd
    80002990:	9782                	jalr	a5
}
    80002992:	60a2                	ld	ra,8(sp)
    80002994:	6402                	ld	s0,0(sp)
    80002996:	0141                	addi	sp,sp,16
    80002998:	8082                	ret

000000008000299a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000299a:	1101                	addi	sp,sp,-32
    8000299c:	ec06                	sd	ra,24(sp)
    8000299e:	e822                	sd	s0,16(sp)
    800029a0:	e426                	sd	s1,8(sp)
    800029a2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029a4:	00035497          	auipc	s1,0x35
    800029a8:	ddc48493          	addi	s1,s1,-548 # 80037780 <tickslock>
    800029ac:	8526                	mv	a0,s1
    800029ae:	ffffe097          	auipc	ra,0xffffe
    800029b2:	3ec080e7          	jalr	1004(ra) # 80000d9a <acquire>
  ticks++;
    800029b6:	00006517          	auipc	a0,0x6
    800029ba:	66a50513          	addi	a0,a0,1642 # 80009020 <ticks>
    800029be:	411c                	lw	a5,0(a0)
    800029c0:	2785                	addiw	a5,a5,1
    800029c2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800029c4:	00000097          	auipc	ra,0x0
    800029c8:	c58080e7          	jalr	-936(ra) # 8000261c <wakeup>
  release(&tickslock);
    800029cc:	8526                	mv	a0,s1
    800029ce:	ffffe097          	auipc	ra,0xffffe
    800029d2:	480080e7          	jalr	1152(ra) # 80000e4e <release>
}
    800029d6:	60e2                	ld	ra,24(sp)
    800029d8:	6442                	ld	s0,16(sp)
    800029da:	64a2                	ld	s1,8(sp)
    800029dc:	6105                	addi	sp,sp,32
    800029de:	8082                	ret

00000000800029e0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029e0:	1101                	addi	sp,sp,-32
    800029e2:	ec06                	sd	ra,24(sp)
    800029e4:	e822                	sd	s0,16(sp)
    800029e6:	e426                	sd	s1,8(sp)
    800029e8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ea:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800029ee:	00074d63          	bltz	a4,80002a08 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800029f2:	57fd                	li	a5,-1
    800029f4:	17fe                	slli	a5,a5,0x3f
    800029f6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029f8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029fa:	06f70363          	beq	a4,a5,80002a60 <devintr+0x80>
  }
}
    800029fe:	60e2                	ld	ra,24(sp)
    80002a00:	6442                	ld	s0,16(sp)
    80002a02:	64a2                	ld	s1,8(sp)
    80002a04:	6105                	addi	sp,sp,32
    80002a06:	8082                	ret
     (scause & 0xff) == 9){
    80002a08:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a0c:	46a5                	li	a3,9
    80002a0e:	fed792e3          	bne	a5,a3,800029f2 <devintr+0x12>
    int irq = plic_claim();
    80002a12:	00003097          	auipc	ra,0x3
    80002a16:	4e6080e7          	jalr	1254(ra) # 80005ef8 <plic_claim>
    80002a1a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a1c:	47a9                	li	a5,10
    80002a1e:	02f50763          	beq	a0,a5,80002a4c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a22:	4785                	li	a5,1
    80002a24:	02f50963          	beq	a0,a5,80002a56 <devintr+0x76>
    return 1;
    80002a28:	4505                	li	a0,1
    } else if(irq){
    80002a2a:	d8f1                	beqz	s1,800029fe <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a2c:	85a6                	mv	a1,s1
    80002a2e:	00006517          	auipc	a0,0x6
    80002a32:	8e250513          	addi	a0,a0,-1822 # 80008310 <states.1710+0x30>
    80002a36:	ffffe097          	auipc	ra,0xffffe
    80002a3a:	b5c080e7          	jalr	-1188(ra) # 80000592 <printf>
      plic_complete(irq);
    80002a3e:	8526                	mv	a0,s1
    80002a40:	00003097          	auipc	ra,0x3
    80002a44:	4dc080e7          	jalr	1244(ra) # 80005f1c <plic_complete>
    return 1;
    80002a48:	4505                	li	a0,1
    80002a4a:	bf55                	j	800029fe <devintr+0x1e>
      uartintr();
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	f88080e7          	jalr	-120(ra) # 800009d4 <uartintr>
    80002a54:	b7ed                	j	80002a3e <devintr+0x5e>
      virtio_disk_intr();
    80002a56:	00004097          	auipc	ra,0x4
    80002a5a:	960080e7          	jalr	-1696(ra) # 800063b6 <virtio_disk_intr>
    80002a5e:	b7c5                	j	80002a3e <devintr+0x5e>
    if(cpuid() == 0){
    80002a60:	fffff097          	auipc	ra,0xfffff
    80002a64:	1fa080e7          	jalr	506(ra) # 80001c5a <cpuid>
    80002a68:	c901                	beqz	a0,80002a78 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a6a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a6e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a70:	14479073          	csrw	sip,a5
    return 2;
    80002a74:	4509                	li	a0,2
    80002a76:	b761                	j	800029fe <devintr+0x1e>
      clockintr();
    80002a78:	00000097          	auipc	ra,0x0
    80002a7c:	f22080e7          	jalr	-222(ra) # 8000299a <clockintr>
    80002a80:	b7ed                	j	80002a6a <devintr+0x8a>

0000000080002a82 <usertrap>:
{
    80002a82:	7179                	addi	sp,sp,-48
    80002a84:	f406                	sd	ra,40(sp)
    80002a86:	f022                	sd	s0,32(sp)
    80002a88:	ec26                	sd	s1,24(sp)
    80002a8a:	e84a                	sd	s2,16(sp)
    80002a8c:	e44e                	sd	s3,8(sp)
    80002a8e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a90:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a94:	1007f793          	andi	a5,a5,256
    80002a98:	e3b5                	bnez	a5,80002afc <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a9a:	00003797          	auipc	a5,0x3
    80002a9e:	35678793          	addi	a5,a5,854 # 80005df0 <kernelvec>
    80002aa2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002aa6:	fffff097          	auipc	ra,0xfffff
    80002aaa:	1e0080e7          	jalr	480(ra) # 80001c86 <myproc>
    80002aae:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ab0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ab2:	14102773          	csrr	a4,sepc
    80002ab6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ab8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002abc:	47a1                	li	a5,8
    80002abe:	04f71d63          	bne	a4,a5,80002b18 <usertrap+0x96>
    if(p->killed)
    80002ac2:	591c                	lw	a5,48(a0)
    80002ac4:	e7a1                	bnez	a5,80002b0c <usertrap+0x8a>
    p->trapframe->epc += 4;
    80002ac6:	6cb8                	ld	a4,88(s1)
    80002ac8:	6f1c                	ld	a5,24(a4)
    80002aca:	0791                	addi	a5,a5,4
    80002acc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ace:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ad2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ad6:	10079073          	csrw	sstatus,a5
    syscall();
    80002ada:	00000097          	auipc	ra,0x0
    80002ade:	322080e7          	jalr	802(ra) # 80002dfc <syscall>
  if(p->killed)
    80002ae2:	589c                	lw	a5,48(s1)
    80002ae4:	ebe9                	bnez	a5,80002bb6 <usertrap+0x134>
  usertrapret();
    80002ae6:	00000097          	auipc	ra,0x0
    80002aea:	e16080e7          	jalr	-490(ra) # 800028fc <usertrapret>
}
    80002aee:	70a2                	ld	ra,40(sp)
    80002af0:	7402                	ld	s0,32(sp)
    80002af2:	64e2                	ld	s1,24(sp)
    80002af4:	6942                	ld	s2,16(sp)
    80002af6:	69a2                	ld	s3,8(sp)
    80002af8:	6145                	addi	sp,sp,48
    80002afa:	8082                	ret
    panic("usertrap: not from user mode");
    80002afc:	00006517          	auipc	a0,0x6
    80002b00:	83450513          	addi	a0,a0,-1996 # 80008330 <states.1710+0x50>
    80002b04:	ffffe097          	auipc	ra,0xffffe
    80002b08:	a44080e7          	jalr	-1468(ra) # 80000548 <panic>
      exit(-1);
    80002b0c:	557d                	li	a0,-1
    80002b0e:	00000097          	auipc	ra,0x0
    80002b12:	842080e7          	jalr	-1982(ra) # 80002350 <exit>
    80002b16:	bf45                	j	80002ac6 <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002b18:	00000097          	auipc	ra,0x0
    80002b1c:	ec8080e7          	jalr	-312(ra) # 800029e0 <devintr>
    80002b20:	892a                	mv	s2,a0
    80002b22:	e559                	bnez	a0,80002bb0 <usertrap+0x12e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b24:	14202773          	csrr	a4,scause
  }else if(r_scause() == 15 || r_scause() == 13){
    80002b28:	47bd                	li	a5,15
    80002b2a:	00f70763          	beq	a4,a5,80002b38 <usertrap+0xb6>
    80002b2e:	14202773          	csrr	a4,scause
    80002b32:	47b5                	li	a5,13
    80002b34:	04f71463          	bne	a4,a5,80002b7c <usertrap+0xfa>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b38:	143029f3          	csrr	s3,stval
          if(!iscowpage(va))
    80002b3c:	854e                	mv	a0,s3
    80002b3e:	fffff097          	auipc	ra,0xfffff
    80002b42:	e68080e7          	jalr	-408(ra) # 800019a6 <iscowpage>
    80002b46:	e105                	bnez	a0,80002b66 <usertrap+0xe4>
            p->killed = 1;
    80002b48:	4785                	li	a5,1
    80002b4a:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002b4c:	557d                	li	a0,-1
    80002b4e:	00000097          	auipc	ra,0x0
    80002b52:	802080e7          	jalr	-2046(ra) # 80002350 <exit>
  if(which_dev == 2)
    80002b56:	4789                	li	a5,2
    80002b58:	f8f917e3          	bne	s2,a5,80002ae6 <usertrap+0x64>
    yield();
    80002b5c:	00000097          	auipc	ra,0x0
    80002b60:	8fe080e7          	jalr	-1794(ra) # 8000245a <yield>
    80002b64:	b749                	j	80002ae6 <usertrap+0x64>
          else if(uvmcowcopy(va)==-1)
    80002b66:	854e                	mv	a0,s3
    80002b68:	fffff097          	auipc	ra,0xfffff
    80002b6c:	e88080e7          	jalr	-376(ra) # 800019f0 <uvmcowcopy>
    80002b70:	57fd                	li	a5,-1
    80002b72:	f6f518e3          	bne	a0,a5,80002ae2 <usertrap+0x60>
            p->killed =1;
    80002b76:	4785                	li	a5,1
    80002b78:	d89c                	sw	a5,48(s1)
    80002b7a:	bfc9                	j	80002b4c <usertrap+0xca>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b7c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b80:	5c90                	lw	a2,56(s1)
    80002b82:	00005517          	auipc	a0,0x5
    80002b86:	7ce50513          	addi	a0,a0,1998 # 80008350 <states.1710+0x70>
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	a08080e7          	jalr	-1528(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b92:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b96:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b9a:	00005517          	auipc	a0,0x5
    80002b9e:	7e650513          	addi	a0,a0,2022 # 80008380 <states.1710+0xa0>
    80002ba2:	ffffe097          	auipc	ra,0xffffe
    80002ba6:	9f0080e7          	jalr	-1552(ra) # 80000592 <printf>
    p->killed = 1;
    80002baa:	4785                	li	a5,1
    80002bac:	d89c                	sw	a5,48(s1)
    80002bae:	bf79                	j	80002b4c <usertrap+0xca>
  if(p->killed)
    80002bb0:	589c                	lw	a5,48(s1)
    80002bb2:	d3d5                	beqz	a5,80002b56 <usertrap+0xd4>
    80002bb4:	bf61                	j	80002b4c <usertrap+0xca>
    80002bb6:	4901                	li	s2,0
    80002bb8:	bf51                	j	80002b4c <usertrap+0xca>

0000000080002bba <kerneltrap>:
{
    80002bba:	7179                	addi	sp,sp,-48
    80002bbc:	f406                	sd	ra,40(sp)
    80002bbe:	f022                	sd	s0,32(sp)
    80002bc0:	ec26                	sd	s1,24(sp)
    80002bc2:	e84a                	sd	s2,16(sp)
    80002bc4:	e44e                	sd	s3,8(sp)
    80002bc6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bc8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bcc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bd0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bd4:	1004f793          	andi	a5,s1,256
    80002bd8:	cb85                	beqz	a5,80002c08 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bda:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bde:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002be0:	ef85                	bnez	a5,80002c18 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002be2:	00000097          	auipc	ra,0x0
    80002be6:	dfe080e7          	jalr	-514(ra) # 800029e0 <devintr>
    80002bea:	cd1d                	beqz	a0,80002c28 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bec:	4789                	li	a5,2
    80002bee:	06f50a63          	beq	a0,a5,80002c62 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bf2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bf6:	10049073          	csrw	sstatus,s1
}
    80002bfa:	70a2                	ld	ra,40(sp)
    80002bfc:	7402                	ld	s0,32(sp)
    80002bfe:	64e2                	ld	s1,24(sp)
    80002c00:	6942                	ld	s2,16(sp)
    80002c02:	69a2                	ld	s3,8(sp)
    80002c04:	6145                	addi	sp,sp,48
    80002c06:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c08:	00005517          	auipc	a0,0x5
    80002c0c:	79850513          	addi	a0,a0,1944 # 800083a0 <states.1710+0xc0>
    80002c10:	ffffe097          	auipc	ra,0xffffe
    80002c14:	938080e7          	jalr	-1736(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c18:	00005517          	auipc	a0,0x5
    80002c1c:	7b050513          	addi	a0,a0,1968 # 800083c8 <states.1710+0xe8>
    80002c20:	ffffe097          	auipc	ra,0xffffe
    80002c24:	928080e7          	jalr	-1752(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002c28:	85ce                	mv	a1,s3
    80002c2a:	00005517          	auipc	a0,0x5
    80002c2e:	7be50513          	addi	a0,a0,1982 # 800083e8 <states.1710+0x108>
    80002c32:	ffffe097          	auipc	ra,0xffffe
    80002c36:	960080e7          	jalr	-1696(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c3a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c3e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c42:	00005517          	auipc	a0,0x5
    80002c46:	7b650513          	addi	a0,a0,1974 # 800083f8 <states.1710+0x118>
    80002c4a:	ffffe097          	auipc	ra,0xffffe
    80002c4e:	948080e7          	jalr	-1720(ra) # 80000592 <printf>
    panic("kerneltrap");
    80002c52:	00005517          	auipc	a0,0x5
    80002c56:	7be50513          	addi	a0,a0,1982 # 80008410 <states.1710+0x130>
    80002c5a:	ffffe097          	auipc	ra,0xffffe
    80002c5e:	8ee080e7          	jalr	-1810(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c62:	fffff097          	auipc	ra,0xfffff
    80002c66:	024080e7          	jalr	36(ra) # 80001c86 <myproc>
    80002c6a:	d541                	beqz	a0,80002bf2 <kerneltrap+0x38>
    80002c6c:	fffff097          	auipc	ra,0xfffff
    80002c70:	01a080e7          	jalr	26(ra) # 80001c86 <myproc>
    80002c74:	4d18                	lw	a4,24(a0)
    80002c76:	478d                	li	a5,3
    80002c78:	f6f71de3          	bne	a4,a5,80002bf2 <kerneltrap+0x38>
    yield();
    80002c7c:	fffff097          	auipc	ra,0xfffff
    80002c80:	7de080e7          	jalr	2014(ra) # 8000245a <yield>
    80002c84:	b7bd                	j	80002bf2 <kerneltrap+0x38>

0000000080002c86 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c86:	1101                	addi	sp,sp,-32
    80002c88:	ec06                	sd	ra,24(sp)
    80002c8a:	e822                	sd	s0,16(sp)
    80002c8c:	e426                	sd	s1,8(sp)
    80002c8e:	1000                	addi	s0,sp,32
    80002c90:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	ff4080e7          	jalr	-12(ra) # 80001c86 <myproc>
  switch (n) {
    80002c9a:	4795                	li	a5,5
    80002c9c:	0497e163          	bltu	a5,s1,80002cde <argraw+0x58>
    80002ca0:	048a                	slli	s1,s1,0x2
    80002ca2:	00005717          	auipc	a4,0x5
    80002ca6:	7a670713          	addi	a4,a4,1958 # 80008448 <states.1710+0x168>
    80002caa:	94ba                	add	s1,s1,a4
    80002cac:	409c                	lw	a5,0(s1)
    80002cae:	97ba                	add	a5,a5,a4
    80002cb0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cb2:	6d3c                	ld	a5,88(a0)
    80002cb4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cb6:	60e2                	ld	ra,24(sp)
    80002cb8:	6442                	ld	s0,16(sp)
    80002cba:	64a2                	ld	s1,8(sp)
    80002cbc:	6105                	addi	sp,sp,32
    80002cbe:	8082                	ret
    return p->trapframe->a1;
    80002cc0:	6d3c                	ld	a5,88(a0)
    80002cc2:	7fa8                	ld	a0,120(a5)
    80002cc4:	bfcd                	j	80002cb6 <argraw+0x30>
    return p->trapframe->a2;
    80002cc6:	6d3c                	ld	a5,88(a0)
    80002cc8:	63c8                	ld	a0,128(a5)
    80002cca:	b7f5                	j	80002cb6 <argraw+0x30>
    return p->trapframe->a3;
    80002ccc:	6d3c                	ld	a5,88(a0)
    80002cce:	67c8                	ld	a0,136(a5)
    80002cd0:	b7dd                	j	80002cb6 <argraw+0x30>
    return p->trapframe->a4;
    80002cd2:	6d3c                	ld	a5,88(a0)
    80002cd4:	6bc8                	ld	a0,144(a5)
    80002cd6:	b7c5                	j	80002cb6 <argraw+0x30>
    return p->trapframe->a5;
    80002cd8:	6d3c                	ld	a5,88(a0)
    80002cda:	6fc8                	ld	a0,152(a5)
    80002cdc:	bfe9                	j	80002cb6 <argraw+0x30>
  panic("argraw");
    80002cde:	00005517          	auipc	a0,0x5
    80002ce2:	74250513          	addi	a0,a0,1858 # 80008420 <states.1710+0x140>
    80002ce6:	ffffe097          	auipc	ra,0xffffe
    80002cea:	862080e7          	jalr	-1950(ra) # 80000548 <panic>

0000000080002cee <fetchaddr>:
{
    80002cee:	1101                	addi	sp,sp,-32
    80002cf0:	ec06                	sd	ra,24(sp)
    80002cf2:	e822                	sd	s0,16(sp)
    80002cf4:	e426                	sd	s1,8(sp)
    80002cf6:	e04a                	sd	s2,0(sp)
    80002cf8:	1000                	addi	s0,sp,32
    80002cfa:	84aa                	mv	s1,a0
    80002cfc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	f88080e7          	jalr	-120(ra) # 80001c86 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d06:	653c                	ld	a5,72(a0)
    80002d08:	02f4f863          	bgeu	s1,a5,80002d38 <fetchaddr+0x4a>
    80002d0c:	00848713          	addi	a4,s1,8
    80002d10:	02e7e663          	bltu	a5,a4,80002d3c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d14:	46a1                	li	a3,8
    80002d16:	8626                	mv	a2,s1
    80002d18:	85ca                	mv	a1,s2
    80002d1a:	6928                	ld	a0,80(a0)
    80002d1c:	fffff097          	auipc	ra,0xfffff
    80002d20:	b4a080e7          	jalr	-1206(ra) # 80001866 <copyin>
    80002d24:	00a03533          	snez	a0,a0
    80002d28:	40a00533          	neg	a0,a0
}
    80002d2c:	60e2                	ld	ra,24(sp)
    80002d2e:	6442                	ld	s0,16(sp)
    80002d30:	64a2                	ld	s1,8(sp)
    80002d32:	6902                	ld	s2,0(sp)
    80002d34:	6105                	addi	sp,sp,32
    80002d36:	8082                	ret
    return -1;
    80002d38:	557d                	li	a0,-1
    80002d3a:	bfcd                	j	80002d2c <fetchaddr+0x3e>
    80002d3c:	557d                	li	a0,-1
    80002d3e:	b7fd                	j	80002d2c <fetchaddr+0x3e>

0000000080002d40 <fetchstr>:
{
    80002d40:	7179                	addi	sp,sp,-48
    80002d42:	f406                	sd	ra,40(sp)
    80002d44:	f022                	sd	s0,32(sp)
    80002d46:	ec26                	sd	s1,24(sp)
    80002d48:	e84a                	sd	s2,16(sp)
    80002d4a:	e44e                	sd	s3,8(sp)
    80002d4c:	1800                	addi	s0,sp,48
    80002d4e:	892a                	mv	s2,a0
    80002d50:	84ae                	mv	s1,a1
    80002d52:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d54:	fffff097          	auipc	ra,0xfffff
    80002d58:	f32080e7          	jalr	-206(ra) # 80001c86 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002d5c:	86ce                	mv	a3,s3
    80002d5e:	864a                	mv	a2,s2
    80002d60:	85a6                	mv	a1,s1
    80002d62:	6928                	ld	a0,80(a0)
    80002d64:	fffff097          	auipc	ra,0xfffff
    80002d68:	b8e080e7          	jalr	-1138(ra) # 800018f2 <copyinstr>
  if(err < 0)
    80002d6c:	00054763          	bltz	a0,80002d7a <fetchstr+0x3a>
  return strlen(buf);
    80002d70:	8526                	mv	a0,s1
    80002d72:	ffffe097          	auipc	ra,0xffffe
    80002d76:	2ac080e7          	jalr	684(ra) # 8000101e <strlen>
}
    80002d7a:	70a2                	ld	ra,40(sp)
    80002d7c:	7402                	ld	s0,32(sp)
    80002d7e:	64e2                	ld	s1,24(sp)
    80002d80:	6942                	ld	s2,16(sp)
    80002d82:	69a2                	ld	s3,8(sp)
    80002d84:	6145                	addi	sp,sp,48
    80002d86:	8082                	ret

0000000080002d88 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d88:	1101                	addi	sp,sp,-32
    80002d8a:	ec06                	sd	ra,24(sp)
    80002d8c:	e822                	sd	s0,16(sp)
    80002d8e:	e426                	sd	s1,8(sp)
    80002d90:	1000                	addi	s0,sp,32
    80002d92:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d94:	00000097          	auipc	ra,0x0
    80002d98:	ef2080e7          	jalr	-270(ra) # 80002c86 <argraw>
    80002d9c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d9e:	4501                	li	a0,0
    80002da0:	60e2                	ld	ra,24(sp)
    80002da2:	6442                	ld	s0,16(sp)
    80002da4:	64a2                	ld	s1,8(sp)
    80002da6:	6105                	addi	sp,sp,32
    80002da8:	8082                	ret

0000000080002daa <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002daa:	1101                	addi	sp,sp,-32
    80002dac:	ec06                	sd	ra,24(sp)
    80002dae:	e822                	sd	s0,16(sp)
    80002db0:	e426                	sd	s1,8(sp)
    80002db2:	1000                	addi	s0,sp,32
    80002db4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002db6:	00000097          	auipc	ra,0x0
    80002dba:	ed0080e7          	jalr	-304(ra) # 80002c86 <argraw>
    80002dbe:	e088                	sd	a0,0(s1)
  return 0;
}
    80002dc0:	4501                	li	a0,0
    80002dc2:	60e2                	ld	ra,24(sp)
    80002dc4:	6442                	ld	s0,16(sp)
    80002dc6:	64a2                	ld	s1,8(sp)
    80002dc8:	6105                	addi	sp,sp,32
    80002dca:	8082                	ret

0000000080002dcc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002dcc:	1101                	addi	sp,sp,-32
    80002dce:	ec06                	sd	ra,24(sp)
    80002dd0:	e822                	sd	s0,16(sp)
    80002dd2:	e426                	sd	s1,8(sp)
    80002dd4:	e04a                	sd	s2,0(sp)
    80002dd6:	1000                	addi	s0,sp,32
    80002dd8:	84ae                	mv	s1,a1
    80002dda:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002ddc:	00000097          	auipc	ra,0x0
    80002de0:	eaa080e7          	jalr	-342(ra) # 80002c86 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002de4:	864a                	mv	a2,s2
    80002de6:	85a6                	mv	a1,s1
    80002de8:	00000097          	auipc	ra,0x0
    80002dec:	f58080e7          	jalr	-168(ra) # 80002d40 <fetchstr>
}
    80002df0:	60e2                	ld	ra,24(sp)
    80002df2:	6442                	ld	s0,16(sp)
    80002df4:	64a2                	ld	s1,8(sp)
    80002df6:	6902                	ld	s2,0(sp)
    80002df8:	6105                	addi	sp,sp,32
    80002dfa:	8082                	ret

0000000080002dfc <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002dfc:	1101                	addi	sp,sp,-32
    80002dfe:	ec06                	sd	ra,24(sp)
    80002e00:	e822                	sd	s0,16(sp)
    80002e02:	e426                	sd	s1,8(sp)
    80002e04:	e04a                	sd	s2,0(sp)
    80002e06:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e08:	fffff097          	auipc	ra,0xfffff
    80002e0c:	e7e080e7          	jalr	-386(ra) # 80001c86 <myproc>
    80002e10:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e12:	05853903          	ld	s2,88(a0)
    80002e16:	0a893783          	ld	a5,168(s2)
    80002e1a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e1e:	37fd                	addiw	a5,a5,-1
    80002e20:	4751                	li	a4,20
    80002e22:	00f76f63          	bltu	a4,a5,80002e40 <syscall+0x44>
    80002e26:	00369713          	slli	a4,a3,0x3
    80002e2a:	00005797          	auipc	a5,0x5
    80002e2e:	63678793          	addi	a5,a5,1590 # 80008460 <syscalls>
    80002e32:	97ba                	add	a5,a5,a4
    80002e34:	639c                	ld	a5,0(a5)
    80002e36:	c789                	beqz	a5,80002e40 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002e38:	9782                	jalr	a5
    80002e3a:	06a93823          	sd	a0,112(s2)
    80002e3e:	a839                	j	80002e5c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e40:	15848613          	addi	a2,s1,344
    80002e44:	5c8c                	lw	a1,56(s1)
    80002e46:	00005517          	auipc	a0,0x5
    80002e4a:	5e250513          	addi	a0,a0,1506 # 80008428 <states.1710+0x148>
    80002e4e:	ffffd097          	auipc	ra,0xffffd
    80002e52:	744080e7          	jalr	1860(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e56:	6cbc                	ld	a5,88(s1)
    80002e58:	577d                	li	a4,-1
    80002e5a:	fbb8                	sd	a4,112(a5)
  }
}
    80002e5c:	60e2                	ld	ra,24(sp)
    80002e5e:	6442                	ld	s0,16(sp)
    80002e60:	64a2                	ld	s1,8(sp)
    80002e62:	6902                	ld	s2,0(sp)
    80002e64:	6105                	addi	sp,sp,32
    80002e66:	8082                	ret

0000000080002e68 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e68:	1101                	addi	sp,sp,-32
    80002e6a:	ec06                	sd	ra,24(sp)
    80002e6c:	e822                	sd	s0,16(sp)
    80002e6e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e70:	fec40593          	addi	a1,s0,-20
    80002e74:	4501                	li	a0,0
    80002e76:	00000097          	auipc	ra,0x0
    80002e7a:	f12080e7          	jalr	-238(ra) # 80002d88 <argint>
    return -1;
    80002e7e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e80:	00054963          	bltz	a0,80002e92 <sys_exit+0x2a>
  exit(n);
    80002e84:	fec42503          	lw	a0,-20(s0)
    80002e88:	fffff097          	auipc	ra,0xfffff
    80002e8c:	4c8080e7          	jalr	1224(ra) # 80002350 <exit>
  return 0;  // not reached
    80002e90:	4781                	li	a5,0
}
    80002e92:	853e                	mv	a0,a5
    80002e94:	60e2                	ld	ra,24(sp)
    80002e96:	6442                	ld	s0,16(sp)
    80002e98:	6105                	addi	sp,sp,32
    80002e9a:	8082                	ret

0000000080002e9c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e9c:	1141                	addi	sp,sp,-16
    80002e9e:	e406                	sd	ra,8(sp)
    80002ea0:	e022                	sd	s0,0(sp)
    80002ea2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ea4:	fffff097          	auipc	ra,0xfffff
    80002ea8:	de2080e7          	jalr	-542(ra) # 80001c86 <myproc>
}
    80002eac:	5d08                	lw	a0,56(a0)
    80002eae:	60a2                	ld	ra,8(sp)
    80002eb0:	6402                	ld	s0,0(sp)
    80002eb2:	0141                	addi	sp,sp,16
    80002eb4:	8082                	ret

0000000080002eb6 <sys_fork>:

uint64
sys_fork(void)
{
    80002eb6:	1141                	addi	sp,sp,-16
    80002eb8:	e406                	sd	ra,8(sp)
    80002eba:	e022                	sd	s0,0(sp)
    80002ebc:	0800                	addi	s0,sp,16
  return fork();
    80002ebe:	fffff097          	auipc	ra,0xfffff
    80002ec2:	188080e7          	jalr	392(ra) # 80002046 <fork>
}
    80002ec6:	60a2                	ld	ra,8(sp)
    80002ec8:	6402                	ld	s0,0(sp)
    80002eca:	0141                	addi	sp,sp,16
    80002ecc:	8082                	ret

0000000080002ece <sys_wait>:

uint64
sys_wait(void)
{
    80002ece:	1101                	addi	sp,sp,-32
    80002ed0:	ec06                	sd	ra,24(sp)
    80002ed2:	e822                	sd	s0,16(sp)
    80002ed4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002ed6:	fe840593          	addi	a1,s0,-24
    80002eda:	4501                	li	a0,0
    80002edc:	00000097          	auipc	ra,0x0
    80002ee0:	ece080e7          	jalr	-306(ra) # 80002daa <argaddr>
    80002ee4:	87aa                	mv	a5,a0
    return -1;
    80002ee6:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002ee8:	0007c863          	bltz	a5,80002ef8 <sys_wait+0x2a>
  return wait(p);
    80002eec:	fe843503          	ld	a0,-24(s0)
    80002ef0:	fffff097          	auipc	ra,0xfffff
    80002ef4:	624080e7          	jalr	1572(ra) # 80002514 <wait>
}
    80002ef8:	60e2                	ld	ra,24(sp)
    80002efa:	6442                	ld	s0,16(sp)
    80002efc:	6105                	addi	sp,sp,32
    80002efe:	8082                	ret

0000000080002f00 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f00:	7179                	addi	sp,sp,-48
    80002f02:	f406                	sd	ra,40(sp)
    80002f04:	f022                	sd	s0,32(sp)
    80002f06:	ec26                	sd	s1,24(sp)
    80002f08:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f0a:	fdc40593          	addi	a1,s0,-36
    80002f0e:	4501                	li	a0,0
    80002f10:	00000097          	auipc	ra,0x0
    80002f14:	e78080e7          	jalr	-392(ra) # 80002d88 <argint>
    80002f18:	87aa                	mv	a5,a0
    return -1;
    80002f1a:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002f1c:	0207c063          	bltz	a5,80002f3c <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002f20:	fffff097          	auipc	ra,0xfffff
    80002f24:	d66080e7          	jalr	-666(ra) # 80001c86 <myproc>
    80002f28:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002f2a:	fdc42503          	lw	a0,-36(s0)
    80002f2e:	fffff097          	auipc	ra,0xfffff
    80002f32:	0a4080e7          	jalr	164(ra) # 80001fd2 <growproc>
    80002f36:	00054863          	bltz	a0,80002f46 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002f3a:	8526                	mv	a0,s1
}
    80002f3c:	70a2                	ld	ra,40(sp)
    80002f3e:	7402                	ld	s0,32(sp)
    80002f40:	64e2                	ld	s1,24(sp)
    80002f42:	6145                	addi	sp,sp,48
    80002f44:	8082                	ret
    return -1;
    80002f46:	557d                	li	a0,-1
    80002f48:	bfd5                	j	80002f3c <sys_sbrk+0x3c>

0000000080002f4a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f4a:	7139                	addi	sp,sp,-64
    80002f4c:	fc06                	sd	ra,56(sp)
    80002f4e:	f822                	sd	s0,48(sp)
    80002f50:	f426                	sd	s1,40(sp)
    80002f52:	f04a                	sd	s2,32(sp)
    80002f54:	ec4e                	sd	s3,24(sp)
    80002f56:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002f58:	fcc40593          	addi	a1,s0,-52
    80002f5c:	4501                	li	a0,0
    80002f5e:	00000097          	auipc	ra,0x0
    80002f62:	e2a080e7          	jalr	-470(ra) # 80002d88 <argint>
    return -1;
    80002f66:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f68:	06054563          	bltz	a0,80002fd2 <sys_sleep+0x88>
  acquire(&tickslock);
    80002f6c:	00035517          	auipc	a0,0x35
    80002f70:	81450513          	addi	a0,a0,-2028 # 80037780 <tickslock>
    80002f74:	ffffe097          	auipc	ra,0xffffe
    80002f78:	e26080e7          	jalr	-474(ra) # 80000d9a <acquire>
  ticks0 = ticks;
    80002f7c:	00006917          	auipc	s2,0x6
    80002f80:	0a492903          	lw	s2,164(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002f84:	fcc42783          	lw	a5,-52(s0)
    80002f88:	cf85                	beqz	a5,80002fc0 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f8a:	00034997          	auipc	s3,0x34
    80002f8e:	7f698993          	addi	s3,s3,2038 # 80037780 <tickslock>
    80002f92:	00006497          	auipc	s1,0x6
    80002f96:	08e48493          	addi	s1,s1,142 # 80009020 <ticks>
    if(myproc()->killed){
    80002f9a:	fffff097          	auipc	ra,0xfffff
    80002f9e:	cec080e7          	jalr	-788(ra) # 80001c86 <myproc>
    80002fa2:	591c                	lw	a5,48(a0)
    80002fa4:	ef9d                	bnez	a5,80002fe2 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002fa6:	85ce                	mv	a1,s3
    80002fa8:	8526                	mv	a0,s1
    80002faa:	fffff097          	auipc	ra,0xfffff
    80002fae:	4ec080e7          	jalr	1260(ra) # 80002496 <sleep>
  while(ticks - ticks0 < n){
    80002fb2:	409c                	lw	a5,0(s1)
    80002fb4:	412787bb          	subw	a5,a5,s2
    80002fb8:	fcc42703          	lw	a4,-52(s0)
    80002fbc:	fce7efe3          	bltu	a5,a4,80002f9a <sys_sleep+0x50>
  }
  release(&tickslock);
    80002fc0:	00034517          	auipc	a0,0x34
    80002fc4:	7c050513          	addi	a0,a0,1984 # 80037780 <tickslock>
    80002fc8:	ffffe097          	auipc	ra,0xffffe
    80002fcc:	e86080e7          	jalr	-378(ra) # 80000e4e <release>
  return 0;
    80002fd0:	4781                	li	a5,0
}
    80002fd2:	853e                	mv	a0,a5
    80002fd4:	70e2                	ld	ra,56(sp)
    80002fd6:	7442                	ld	s0,48(sp)
    80002fd8:	74a2                	ld	s1,40(sp)
    80002fda:	7902                	ld	s2,32(sp)
    80002fdc:	69e2                	ld	s3,24(sp)
    80002fde:	6121                	addi	sp,sp,64
    80002fe0:	8082                	ret
      release(&tickslock);
    80002fe2:	00034517          	auipc	a0,0x34
    80002fe6:	79e50513          	addi	a0,a0,1950 # 80037780 <tickslock>
    80002fea:	ffffe097          	auipc	ra,0xffffe
    80002fee:	e64080e7          	jalr	-412(ra) # 80000e4e <release>
      return -1;
    80002ff2:	57fd                	li	a5,-1
    80002ff4:	bff9                	j	80002fd2 <sys_sleep+0x88>

0000000080002ff6 <sys_kill>:

uint64
sys_kill(void)
{
    80002ff6:	1101                	addi	sp,sp,-32
    80002ff8:	ec06                	sd	ra,24(sp)
    80002ffa:	e822                	sd	s0,16(sp)
    80002ffc:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002ffe:	fec40593          	addi	a1,s0,-20
    80003002:	4501                	li	a0,0
    80003004:	00000097          	auipc	ra,0x0
    80003008:	d84080e7          	jalr	-636(ra) # 80002d88 <argint>
    8000300c:	87aa                	mv	a5,a0
    return -1;
    8000300e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003010:	0007c863          	bltz	a5,80003020 <sys_kill+0x2a>
  return kill(pid);
    80003014:	fec42503          	lw	a0,-20(s0)
    80003018:	fffff097          	auipc	ra,0xfffff
    8000301c:	66e080e7          	jalr	1646(ra) # 80002686 <kill>
}
    80003020:	60e2                	ld	ra,24(sp)
    80003022:	6442                	ld	s0,16(sp)
    80003024:	6105                	addi	sp,sp,32
    80003026:	8082                	ret

0000000080003028 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003028:	1101                	addi	sp,sp,-32
    8000302a:	ec06                	sd	ra,24(sp)
    8000302c:	e822                	sd	s0,16(sp)
    8000302e:	e426                	sd	s1,8(sp)
    80003030:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003032:	00034517          	auipc	a0,0x34
    80003036:	74e50513          	addi	a0,a0,1870 # 80037780 <tickslock>
    8000303a:	ffffe097          	auipc	ra,0xffffe
    8000303e:	d60080e7          	jalr	-672(ra) # 80000d9a <acquire>
  xticks = ticks;
    80003042:	00006497          	auipc	s1,0x6
    80003046:	fde4a483          	lw	s1,-34(s1) # 80009020 <ticks>
  release(&tickslock);
    8000304a:	00034517          	auipc	a0,0x34
    8000304e:	73650513          	addi	a0,a0,1846 # 80037780 <tickslock>
    80003052:	ffffe097          	auipc	ra,0xffffe
    80003056:	dfc080e7          	jalr	-516(ra) # 80000e4e <release>
  return xticks;
}
    8000305a:	02049513          	slli	a0,s1,0x20
    8000305e:	9101                	srli	a0,a0,0x20
    80003060:	60e2                	ld	ra,24(sp)
    80003062:	6442                	ld	s0,16(sp)
    80003064:	64a2                	ld	s1,8(sp)
    80003066:	6105                	addi	sp,sp,32
    80003068:	8082                	ret

000000008000306a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000306a:	7179                	addi	sp,sp,-48
    8000306c:	f406                	sd	ra,40(sp)
    8000306e:	f022                	sd	s0,32(sp)
    80003070:	ec26                	sd	s1,24(sp)
    80003072:	e84a                	sd	s2,16(sp)
    80003074:	e44e                	sd	s3,8(sp)
    80003076:	e052                	sd	s4,0(sp)
    80003078:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000307a:	00005597          	auipc	a1,0x5
    8000307e:	49658593          	addi	a1,a1,1174 # 80008510 <syscalls+0xb0>
    80003082:	00034517          	auipc	a0,0x34
    80003086:	71650513          	addi	a0,a0,1814 # 80037798 <bcache>
    8000308a:	ffffe097          	auipc	ra,0xffffe
    8000308e:	c80080e7          	jalr	-896(ra) # 80000d0a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003092:	0003c797          	auipc	a5,0x3c
    80003096:	70678793          	addi	a5,a5,1798 # 8003f798 <bcache+0x8000>
    8000309a:	0003d717          	auipc	a4,0x3d
    8000309e:	96670713          	addi	a4,a4,-1690 # 8003fa00 <bcache+0x8268>
    800030a2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030a6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030aa:	00034497          	auipc	s1,0x34
    800030ae:	70648493          	addi	s1,s1,1798 # 800377b0 <bcache+0x18>
    b->next = bcache.head.next;
    800030b2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030b4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030b6:	00005a17          	auipc	s4,0x5
    800030ba:	462a0a13          	addi	s4,s4,1122 # 80008518 <syscalls+0xb8>
    b->next = bcache.head.next;
    800030be:	2b893783          	ld	a5,696(s2)
    800030c2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030c4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030c8:	85d2                	mv	a1,s4
    800030ca:	01048513          	addi	a0,s1,16
    800030ce:	00001097          	auipc	ra,0x1
    800030d2:	4b0080e7          	jalr	1200(ra) # 8000457e <initsleeplock>
    bcache.head.next->prev = b;
    800030d6:	2b893783          	ld	a5,696(s2)
    800030da:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030dc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030e0:	45848493          	addi	s1,s1,1112
    800030e4:	fd349de3          	bne	s1,s3,800030be <binit+0x54>
  }
}
    800030e8:	70a2                	ld	ra,40(sp)
    800030ea:	7402                	ld	s0,32(sp)
    800030ec:	64e2                	ld	s1,24(sp)
    800030ee:	6942                	ld	s2,16(sp)
    800030f0:	69a2                	ld	s3,8(sp)
    800030f2:	6a02                	ld	s4,0(sp)
    800030f4:	6145                	addi	sp,sp,48
    800030f6:	8082                	ret

00000000800030f8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030f8:	7179                	addi	sp,sp,-48
    800030fa:	f406                	sd	ra,40(sp)
    800030fc:	f022                	sd	s0,32(sp)
    800030fe:	ec26                	sd	s1,24(sp)
    80003100:	e84a                	sd	s2,16(sp)
    80003102:	e44e                	sd	s3,8(sp)
    80003104:	1800                	addi	s0,sp,48
    80003106:	89aa                	mv	s3,a0
    80003108:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000310a:	00034517          	auipc	a0,0x34
    8000310e:	68e50513          	addi	a0,a0,1678 # 80037798 <bcache>
    80003112:	ffffe097          	auipc	ra,0xffffe
    80003116:	c88080e7          	jalr	-888(ra) # 80000d9a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000311a:	0003d497          	auipc	s1,0x3d
    8000311e:	9364b483          	ld	s1,-1738(s1) # 8003fa50 <bcache+0x82b8>
    80003122:	0003d797          	auipc	a5,0x3d
    80003126:	8de78793          	addi	a5,a5,-1826 # 8003fa00 <bcache+0x8268>
    8000312a:	02f48f63          	beq	s1,a5,80003168 <bread+0x70>
    8000312e:	873e                	mv	a4,a5
    80003130:	a021                	j	80003138 <bread+0x40>
    80003132:	68a4                	ld	s1,80(s1)
    80003134:	02e48a63          	beq	s1,a4,80003168 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003138:	449c                	lw	a5,8(s1)
    8000313a:	ff379ce3          	bne	a5,s3,80003132 <bread+0x3a>
    8000313e:	44dc                	lw	a5,12(s1)
    80003140:	ff2799e3          	bne	a5,s2,80003132 <bread+0x3a>
      b->refcnt++;
    80003144:	40bc                	lw	a5,64(s1)
    80003146:	2785                	addiw	a5,a5,1
    80003148:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000314a:	00034517          	auipc	a0,0x34
    8000314e:	64e50513          	addi	a0,a0,1614 # 80037798 <bcache>
    80003152:	ffffe097          	auipc	ra,0xffffe
    80003156:	cfc080e7          	jalr	-772(ra) # 80000e4e <release>
      acquiresleep(&b->lock);
    8000315a:	01048513          	addi	a0,s1,16
    8000315e:	00001097          	auipc	ra,0x1
    80003162:	45a080e7          	jalr	1114(ra) # 800045b8 <acquiresleep>
      return b;
    80003166:	a8b9                	j	800031c4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003168:	0003d497          	auipc	s1,0x3d
    8000316c:	8e04b483          	ld	s1,-1824(s1) # 8003fa48 <bcache+0x82b0>
    80003170:	0003d797          	auipc	a5,0x3d
    80003174:	89078793          	addi	a5,a5,-1904 # 8003fa00 <bcache+0x8268>
    80003178:	00f48863          	beq	s1,a5,80003188 <bread+0x90>
    8000317c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000317e:	40bc                	lw	a5,64(s1)
    80003180:	cf81                	beqz	a5,80003198 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003182:	64a4                	ld	s1,72(s1)
    80003184:	fee49de3          	bne	s1,a4,8000317e <bread+0x86>
  panic("bget: no buffers");
    80003188:	00005517          	auipc	a0,0x5
    8000318c:	39850513          	addi	a0,a0,920 # 80008520 <syscalls+0xc0>
    80003190:	ffffd097          	auipc	ra,0xffffd
    80003194:	3b8080e7          	jalr	952(ra) # 80000548 <panic>
      b->dev = dev;
    80003198:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000319c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800031a0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031a4:	4785                	li	a5,1
    800031a6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031a8:	00034517          	auipc	a0,0x34
    800031ac:	5f050513          	addi	a0,a0,1520 # 80037798 <bcache>
    800031b0:	ffffe097          	auipc	ra,0xffffe
    800031b4:	c9e080e7          	jalr	-866(ra) # 80000e4e <release>
      acquiresleep(&b->lock);
    800031b8:	01048513          	addi	a0,s1,16
    800031bc:	00001097          	auipc	ra,0x1
    800031c0:	3fc080e7          	jalr	1020(ra) # 800045b8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031c4:	409c                	lw	a5,0(s1)
    800031c6:	cb89                	beqz	a5,800031d8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031c8:	8526                	mv	a0,s1
    800031ca:	70a2                	ld	ra,40(sp)
    800031cc:	7402                	ld	s0,32(sp)
    800031ce:	64e2                	ld	s1,24(sp)
    800031d0:	6942                	ld	s2,16(sp)
    800031d2:	69a2                	ld	s3,8(sp)
    800031d4:	6145                	addi	sp,sp,48
    800031d6:	8082                	ret
    virtio_disk_rw(b, 0);
    800031d8:	4581                	li	a1,0
    800031da:	8526                	mv	a0,s1
    800031dc:	00003097          	auipc	ra,0x3
    800031e0:	f30080e7          	jalr	-208(ra) # 8000610c <virtio_disk_rw>
    b->valid = 1;
    800031e4:	4785                	li	a5,1
    800031e6:	c09c                	sw	a5,0(s1)
  return b;
    800031e8:	b7c5                	j	800031c8 <bread+0xd0>

00000000800031ea <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031ea:	1101                	addi	sp,sp,-32
    800031ec:	ec06                	sd	ra,24(sp)
    800031ee:	e822                	sd	s0,16(sp)
    800031f0:	e426                	sd	s1,8(sp)
    800031f2:	1000                	addi	s0,sp,32
    800031f4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031f6:	0541                	addi	a0,a0,16
    800031f8:	00001097          	auipc	ra,0x1
    800031fc:	45a080e7          	jalr	1114(ra) # 80004652 <holdingsleep>
    80003200:	cd01                	beqz	a0,80003218 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003202:	4585                	li	a1,1
    80003204:	8526                	mv	a0,s1
    80003206:	00003097          	auipc	ra,0x3
    8000320a:	f06080e7          	jalr	-250(ra) # 8000610c <virtio_disk_rw>
}
    8000320e:	60e2                	ld	ra,24(sp)
    80003210:	6442                	ld	s0,16(sp)
    80003212:	64a2                	ld	s1,8(sp)
    80003214:	6105                	addi	sp,sp,32
    80003216:	8082                	ret
    panic("bwrite");
    80003218:	00005517          	auipc	a0,0x5
    8000321c:	32050513          	addi	a0,a0,800 # 80008538 <syscalls+0xd8>
    80003220:	ffffd097          	auipc	ra,0xffffd
    80003224:	328080e7          	jalr	808(ra) # 80000548 <panic>

0000000080003228 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003228:	1101                	addi	sp,sp,-32
    8000322a:	ec06                	sd	ra,24(sp)
    8000322c:	e822                	sd	s0,16(sp)
    8000322e:	e426                	sd	s1,8(sp)
    80003230:	e04a                	sd	s2,0(sp)
    80003232:	1000                	addi	s0,sp,32
    80003234:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003236:	01050913          	addi	s2,a0,16
    8000323a:	854a                	mv	a0,s2
    8000323c:	00001097          	auipc	ra,0x1
    80003240:	416080e7          	jalr	1046(ra) # 80004652 <holdingsleep>
    80003244:	c92d                	beqz	a0,800032b6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003246:	854a                	mv	a0,s2
    80003248:	00001097          	auipc	ra,0x1
    8000324c:	3c6080e7          	jalr	966(ra) # 8000460e <releasesleep>

  acquire(&bcache.lock);
    80003250:	00034517          	auipc	a0,0x34
    80003254:	54850513          	addi	a0,a0,1352 # 80037798 <bcache>
    80003258:	ffffe097          	auipc	ra,0xffffe
    8000325c:	b42080e7          	jalr	-1214(ra) # 80000d9a <acquire>
  b->refcnt--;
    80003260:	40bc                	lw	a5,64(s1)
    80003262:	37fd                	addiw	a5,a5,-1
    80003264:	0007871b          	sext.w	a4,a5
    80003268:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000326a:	eb05                	bnez	a4,8000329a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000326c:	68bc                	ld	a5,80(s1)
    8000326e:	64b8                	ld	a4,72(s1)
    80003270:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003272:	64bc                	ld	a5,72(s1)
    80003274:	68b8                	ld	a4,80(s1)
    80003276:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003278:	0003c797          	auipc	a5,0x3c
    8000327c:	52078793          	addi	a5,a5,1312 # 8003f798 <bcache+0x8000>
    80003280:	2b87b703          	ld	a4,696(a5)
    80003284:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003286:	0003c717          	auipc	a4,0x3c
    8000328a:	77a70713          	addi	a4,a4,1914 # 8003fa00 <bcache+0x8268>
    8000328e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003290:	2b87b703          	ld	a4,696(a5)
    80003294:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003296:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000329a:	00034517          	auipc	a0,0x34
    8000329e:	4fe50513          	addi	a0,a0,1278 # 80037798 <bcache>
    800032a2:	ffffe097          	auipc	ra,0xffffe
    800032a6:	bac080e7          	jalr	-1108(ra) # 80000e4e <release>
}
    800032aa:	60e2                	ld	ra,24(sp)
    800032ac:	6442                	ld	s0,16(sp)
    800032ae:	64a2                	ld	s1,8(sp)
    800032b0:	6902                	ld	s2,0(sp)
    800032b2:	6105                	addi	sp,sp,32
    800032b4:	8082                	ret
    panic("brelse");
    800032b6:	00005517          	auipc	a0,0x5
    800032ba:	28a50513          	addi	a0,a0,650 # 80008540 <syscalls+0xe0>
    800032be:	ffffd097          	auipc	ra,0xffffd
    800032c2:	28a080e7          	jalr	650(ra) # 80000548 <panic>

00000000800032c6 <bpin>:

void
bpin(struct buf *b) {
    800032c6:	1101                	addi	sp,sp,-32
    800032c8:	ec06                	sd	ra,24(sp)
    800032ca:	e822                	sd	s0,16(sp)
    800032cc:	e426                	sd	s1,8(sp)
    800032ce:	1000                	addi	s0,sp,32
    800032d0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032d2:	00034517          	auipc	a0,0x34
    800032d6:	4c650513          	addi	a0,a0,1222 # 80037798 <bcache>
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	ac0080e7          	jalr	-1344(ra) # 80000d9a <acquire>
  b->refcnt++;
    800032e2:	40bc                	lw	a5,64(s1)
    800032e4:	2785                	addiw	a5,a5,1
    800032e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032e8:	00034517          	auipc	a0,0x34
    800032ec:	4b050513          	addi	a0,a0,1200 # 80037798 <bcache>
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	b5e080e7          	jalr	-1186(ra) # 80000e4e <release>
}
    800032f8:	60e2                	ld	ra,24(sp)
    800032fa:	6442                	ld	s0,16(sp)
    800032fc:	64a2                	ld	s1,8(sp)
    800032fe:	6105                	addi	sp,sp,32
    80003300:	8082                	ret

0000000080003302 <bunpin>:

void
bunpin(struct buf *b) {
    80003302:	1101                	addi	sp,sp,-32
    80003304:	ec06                	sd	ra,24(sp)
    80003306:	e822                	sd	s0,16(sp)
    80003308:	e426                	sd	s1,8(sp)
    8000330a:	1000                	addi	s0,sp,32
    8000330c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000330e:	00034517          	auipc	a0,0x34
    80003312:	48a50513          	addi	a0,a0,1162 # 80037798 <bcache>
    80003316:	ffffe097          	auipc	ra,0xffffe
    8000331a:	a84080e7          	jalr	-1404(ra) # 80000d9a <acquire>
  b->refcnt--;
    8000331e:	40bc                	lw	a5,64(s1)
    80003320:	37fd                	addiw	a5,a5,-1
    80003322:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003324:	00034517          	auipc	a0,0x34
    80003328:	47450513          	addi	a0,a0,1140 # 80037798 <bcache>
    8000332c:	ffffe097          	auipc	ra,0xffffe
    80003330:	b22080e7          	jalr	-1246(ra) # 80000e4e <release>
}
    80003334:	60e2                	ld	ra,24(sp)
    80003336:	6442                	ld	s0,16(sp)
    80003338:	64a2                	ld	s1,8(sp)
    8000333a:	6105                	addi	sp,sp,32
    8000333c:	8082                	ret

000000008000333e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000333e:	1101                	addi	sp,sp,-32
    80003340:	ec06                	sd	ra,24(sp)
    80003342:	e822                	sd	s0,16(sp)
    80003344:	e426                	sd	s1,8(sp)
    80003346:	e04a                	sd	s2,0(sp)
    80003348:	1000                	addi	s0,sp,32
    8000334a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000334c:	00d5d59b          	srliw	a1,a1,0xd
    80003350:	0003d797          	auipc	a5,0x3d
    80003354:	b247a783          	lw	a5,-1244(a5) # 8003fe74 <sb+0x1c>
    80003358:	9dbd                	addw	a1,a1,a5
    8000335a:	00000097          	auipc	ra,0x0
    8000335e:	d9e080e7          	jalr	-610(ra) # 800030f8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003362:	0074f713          	andi	a4,s1,7
    80003366:	4785                	li	a5,1
    80003368:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000336c:	14ce                	slli	s1,s1,0x33
    8000336e:	90d9                	srli	s1,s1,0x36
    80003370:	00950733          	add	a4,a0,s1
    80003374:	05874703          	lbu	a4,88(a4)
    80003378:	00e7f6b3          	and	a3,a5,a4
    8000337c:	c69d                	beqz	a3,800033aa <bfree+0x6c>
    8000337e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003380:	94aa                	add	s1,s1,a0
    80003382:	fff7c793          	not	a5,a5
    80003386:	8ff9                	and	a5,a5,a4
    80003388:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000338c:	00001097          	auipc	ra,0x1
    80003390:	104080e7          	jalr	260(ra) # 80004490 <log_write>
  brelse(bp);
    80003394:	854a                	mv	a0,s2
    80003396:	00000097          	auipc	ra,0x0
    8000339a:	e92080e7          	jalr	-366(ra) # 80003228 <brelse>
}
    8000339e:	60e2                	ld	ra,24(sp)
    800033a0:	6442                	ld	s0,16(sp)
    800033a2:	64a2                	ld	s1,8(sp)
    800033a4:	6902                	ld	s2,0(sp)
    800033a6:	6105                	addi	sp,sp,32
    800033a8:	8082                	ret
    panic("freeing free block");
    800033aa:	00005517          	auipc	a0,0x5
    800033ae:	19e50513          	addi	a0,a0,414 # 80008548 <syscalls+0xe8>
    800033b2:	ffffd097          	auipc	ra,0xffffd
    800033b6:	196080e7          	jalr	406(ra) # 80000548 <panic>

00000000800033ba <balloc>:
{
    800033ba:	711d                	addi	sp,sp,-96
    800033bc:	ec86                	sd	ra,88(sp)
    800033be:	e8a2                	sd	s0,80(sp)
    800033c0:	e4a6                	sd	s1,72(sp)
    800033c2:	e0ca                	sd	s2,64(sp)
    800033c4:	fc4e                	sd	s3,56(sp)
    800033c6:	f852                	sd	s4,48(sp)
    800033c8:	f456                	sd	s5,40(sp)
    800033ca:	f05a                	sd	s6,32(sp)
    800033cc:	ec5e                	sd	s7,24(sp)
    800033ce:	e862                	sd	s8,16(sp)
    800033d0:	e466                	sd	s9,8(sp)
    800033d2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033d4:	0003d797          	auipc	a5,0x3d
    800033d8:	a887a783          	lw	a5,-1400(a5) # 8003fe5c <sb+0x4>
    800033dc:	cbd1                	beqz	a5,80003470 <balloc+0xb6>
    800033de:	8baa                	mv	s7,a0
    800033e0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033e2:	0003db17          	auipc	s6,0x3d
    800033e6:	a76b0b13          	addi	s6,s6,-1418 # 8003fe58 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033ea:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033ec:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033ee:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033f0:	6c89                	lui	s9,0x2
    800033f2:	a831                	j	8000340e <balloc+0x54>
    brelse(bp);
    800033f4:	854a                	mv	a0,s2
    800033f6:	00000097          	auipc	ra,0x0
    800033fa:	e32080e7          	jalr	-462(ra) # 80003228 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033fe:	015c87bb          	addw	a5,s9,s5
    80003402:	00078a9b          	sext.w	s5,a5
    80003406:	004b2703          	lw	a4,4(s6)
    8000340a:	06eaf363          	bgeu	s5,a4,80003470 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000340e:	41fad79b          	sraiw	a5,s5,0x1f
    80003412:	0137d79b          	srliw	a5,a5,0x13
    80003416:	015787bb          	addw	a5,a5,s5
    8000341a:	40d7d79b          	sraiw	a5,a5,0xd
    8000341e:	01cb2583          	lw	a1,28(s6)
    80003422:	9dbd                	addw	a1,a1,a5
    80003424:	855e                	mv	a0,s7
    80003426:	00000097          	auipc	ra,0x0
    8000342a:	cd2080e7          	jalr	-814(ra) # 800030f8 <bread>
    8000342e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003430:	004b2503          	lw	a0,4(s6)
    80003434:	000a849b          	sext.w	s1,s5
    80003438:	8662                	mv	a2,s8
    8000343a:	faa4fde3          	bgeu	s1,a0,800033f4 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000343e:	41f6579b          	sraiw	a5,a2,0x1f
    80003442:	01d7d69b          	srliw	a3,a5,0x1d
    80003446:	00c6873b          	addw	a4,a3,a2
    8000344a:	00777793          	andi	a5,a4,7
    8000344e:	9f95                	subw	a5,a5,a3
    80003450:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003454:	4037571b          	sraiw	a4,a4,0x3
    80003458:	00e906b3          	add	a3,s2,a4
    8000345c:	0586c683          	lbu	a3,88(a3)
    80003460:	00d7f5b3          	and	a1,a5,a3
    80003464:	cd91                	beqz	a1,80003480 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003466:	2605                	addiw	a2,a2,1
    80003468:	2485                	addiw	s1,s1,1
    8000346a:	fd4618e3          	bne	a2,s4,8000343a <balloc+0x80>
    8000346e:	b759                	j	800033f4 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003470:	00005517          	auipc	a0,0x5
    80003474:	0f050513          	addi	a0,a0,240 # 80008560 <syscalls+0x100>
    80003478:	ffffd097          	auipc	ra,0xffffd
    8000347c:	0d0080e7          	jalr	208(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003480:	974a                	add	a4,a4,s2
    80003482:	8fd5                	or	a5,a5,a3
    80003484:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003488:	854a                	mv	a0,s2
    8000348a:	00001097          	auipc	ra,0x1
    8000348e:	006080e7          	jalr	6(ra) # 80004490 <log_write>
        brelse(bp);
    80003492:	854a                	mv	a0,s2
    80003494:	00000097          	auipc	ra,0x0
    80003498:	d94080e7          	jalr	-620(ra) # 80003228 <brelse>
  bp = bread(dev, bno);
    8000349c:	85a6                	mv	a1,s1
    8000349e:	855e                	mv	a0,s7
    800034a0:	00000097          	auipc	ra,0x0
    800034a4:	c58080e7          	jalr	-936(ra) # 800030f8 <bread>
    800034a8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034aa:	40000613          	li	a2,1024
    800034ae:	4581                	li	a1,0
    800034b0:	05850513          	addi	a0,a0,88
    800034b4:	ffffe097          	auipc	ra,0xffffe
    800034b8:	9e2080e7          	jalr	-1566(ra) # 80000e96 <memset>
  log_write(bp);
    800034bc:	854a                	mv	a0,s2
    800034be:	00001097          	auipc	ra,0x1
    800034c2:	fd2080e7          	jalr	-46(ra) # 80004490 <log_write>
  brelse(bp);
    800034c6:	854a                	mv	a0,s2
    800034c8:	00000097          	auipc	ra,0x0
    800034cc:	d60080e7          	jalr	-672(ra) # 80003228 <brelse>
}
    800034d0:	8526                	mv	a0,s1
    800034d2:	60e6                	ld	ra,88(sp)
    800034d4:	6446                	ld	s0,80(sp)
    800034d6:	64a6                	ld	s1,72(sp)
    800034d8:	6906                	ld	s2,64(sp)
    800034da:	79e2                	ld	s3,56(sp)
    800034dc:	7a42                	ld	s4,48(sp)
    800034de:	7aa2                	ld	s5,40(sp)
    800034e0:	7b02                	ld	s6,32(sp)
    800034e2:	6be2                	ld	s7,24(sp)
    800034e4:	6c42                	ld	s8,16(sp)
    800034e6:	6ca2                	ld	s9,8(sp)
    800034e8:	6125                	addi	sp,sp,96
    800034ea:	8082                	ret

00000000800034ec <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800034ec:	7179                	addi	sp,sp,-48
    800034ee:	f406                	sd	ra,40(sp)
    800034f0:	f022                	sd	s0,32(sp)
    800034f2:	ec26                	sd	s1,24(sp)
    800034f4:	e84a                	sd	s2,16(sp)
    800034f6:	e44e                	sd	s3,8(sp)
    800034f8:	e052                	sd	s4,0(sp)
    800034fa:	1800                	addi	s0,sp,48
    800034fc:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034fe:	47ad                	li	a5,11
    80003500:	04b7fe63          	bgeu	a5,a1,8000355c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003504:	ff45849b          	addiw	s1,a1,-12
    80003508:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000350c:	0ff00793          	li	a5,255
    80003510:	0ae7e363          	bltu	a5,a4,800035b6 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003514:	08052583          	lw	a1,128(a0)
    80003518:	c5ad                	beqz	a1,80003582 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000351a:	00092503          	lw	a0,0(s2)
    8000351e:	00000097          	auipc	ra,0x0
    80003522:	bda080e7          	jalr	-1062(ra) # 800030f8 <bread>
    80003526:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003528:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000352c:	02049593          	slli	a1,s1,0x20
    80003530:	9181                	srli	a1,a1,0x20
    80003532:	058a                	slli	a1,a1,0x2
    80003534:	00b784b3          	add	s1,a5,a1
    80003538:	0004a983          	lw	s3,0(s1)
    8000353c:	04098d63          	beqz	s3,80003596 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003540:	8552                	mv	a0,s4
    80003542:	00000097          	auipc	ra,0x0
    80003546:	ce6080e7          	jalr	-794(ra) # 80003228 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000354a:	854e                	mv	a0,s3
    8000354c:	70a2                	ld	ra,40(sp)
    8000354e:	7402                	ld	s0,32(sp)
    80003550:	64e2                	ld	s1,24(sp)
    80003552:	6942                	ld	s2,16(sp)
    80003554:	69a2                	ld	s3,8(sp)
    80003556:	6a02                	ld	s4,0(sp)
    80003558:	6145                	addi	sp,sp,48
    8000355a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000355c:	02059493          	slli	s1,a1,0x20
    80003560:	9081                	srli	s1,s1,0x20
    80003562:	048a                	slli	s1,s1,0x2
    80003564:	94aa                	add	s1,s1,a0
    80003566:	0504a983          	lw	s3,80(s1)
    8000356a:	fe0990e3          	bnez	s3,8000354a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000356e:	4108                	lw	a0,0(a0)
    80003570:	00000097          	auipc	ra,0x0
    80003574:	e4a080e7          	jalr	-438(ra) # 800033ba <balloc>
    80003578:	0005099b          	sext.w	s3,a0
    8000357c:	0534a823          	sw	s3,80(s1)
    80003580:	b7e9                	j	8000354a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003582:	4108                	lw	a0,0(a0)
    80003584:	00000097          	auipc	ra,0x0
    80003588:	e36080e7          	jalr	-458(ra) # 800033ba <balloc>
    8000358c:	0005059b          	sext.w	a1,a0
    80003590:	08b92023          	sw	a1,128(s2)
    80003594:	b759                	j	8000351a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003596:	00092503          	lw	a0,0(s2)
    8000359a:	00000097          	auipc	ra,0x0
    8000359e:	e20080e7          	jalr	-480(ra) # 800033ba <balloc>
    800035a2:	0005099b          	sext.w	s3,a0
    800035a6:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800035aa:	8552                	mv	a0,s4
    800035ac:	00001097          	auipc	ra,0x1
    800035b0:	ee4080e7          	jalr	-284(ra) # 80004490 <log_write>
    800035b4:	b771                	j	80003540 <bmap+0x54>
  panic("bmap: out of range");
    800035b6:	00005517          	auipc	a0,0x5
    800035ba:	fc250513          	addi	a0,a0,-62 # 80008578 <syscalls+0x118>
    800035be:	ffffd097          	auipc	ra,0xffffd
    800035c2:	f8a080e7          	jalr	-118(ra) # 80000548 <panic>

00000000800035c6 <iget>:
{
    800035c6:	7179                	addi	sp,sp,-48
    800035c8:	f406                	sd	ra,40(sp)
    800035ca:	f022                	sd	s0,32(sp)
    800035cc:	ec26                	sd	s1,24(sp)
    800035ce:	e84a                	sd	s2,16(sp)
    800035d0:	e44e                	sd	s3,8(sp)
    800035d2:	e052                	sd	s4,0(sp)
    800035d4:	1800                	addi	s0,sp,48
    800035d6:	89aa                	mv	s3,a0
    800035d8:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800035da:	0003d517          	auipc	a0,0x3d
    800035de:	89e50513          	addi	a0,a0,-1890 # 8003fe78 <icache>
    800035e2:	ffffd097          	auipc	ra,0xffffd
    800035e6:	7b8080e7          	jalr	1976(ra) # 80000d9a <acquire>
  empty = 0;
    800035ea:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800035ec:	0003d497          	auipc	s1,0x3d
    800035f0:	8a448493          	addi	s1,s1,-1884 # 8003fe90 <icache+0x18>
    800035f4:	0003e697          	auipc	a3,0x3e
    800035f8:	32c68693          	addi	a3,a3,812 # 80041920 <log>
    800035fc:	a039                	j	8000360a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035fe:	02090b63          	beqz	s2,80003634 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003602:	08848493          	addi	s1,s1,136
    80003606:	02d48a63          	beq	s1,a3,8000363a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000360a:	449c                	lw	a5,8(s1)
    8000360c:	fef059e3          	blez	a5,800035fe <iget+0x38>
    80003610:	4098                	lw	a4,0(s1)
    80003612:	ff3716e3          	bne	a4,s3,800035fe <iget+0x38>
    80003616:	40d8                	lw	a4,4(s1)
    80003618:	ff4713e3          	bne	a4,s4,800035fe <iget+0x38>
      ip->ref++;
    8000361c:	2785                	addiw	a5,a5,1
    8000361e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003620:	0003d517          	auipc	a0,0x3d
    80003624:	85850513          	addi	a0,a0,-1960 # 8003fe78 <icache>
    80003628:	ffffe097          	auipc	ra,0xffffe
    8000362c:	826080e7          	jalr	-2010(ra) # 80000e4e <release>
      return ip;
    80003630:	8926                	mv	s2,s1
    80003632:	a03d                	j	80003660 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003634:	f7f9                	bnez	a5,80003602 <iget+0x3c>
    80003636:	8926                	mv	s2,s1
    80003638:	b7e9                	j	80003602 <iget+0x3c>
  if(empty == 0)
    8000363a:	02090c63          	beqz	s2,80003672 <iget+0xac>
  ip->dev = dev;
    8000363e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003642:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003646:	4785                	li	a5,1
    80003648:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000364c:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003650:	0003d517          	auipc	a0,0x3d
    80003654:	82850513          	addi	a0,a0,-2008 # 8003fe78 <icache>
    80003658:	ffffd097          	auipc	ra,0xffffd
    8000365c:	7f6080e7          	jalr	2038(ra) # 80000e4e <release>
}
    80003660:	854a                	mv	a0,s2
    80003662:	70a2                	ld	ra,40(sp)
    80003664:	7402                	ld	s0,32(sp)
    80003666:	64e2                	ld	s1,24(sp)
    80003668:	6942                	ld	s2,16(sp)
    8000366a:	69a2                	ld	s3,8(sp)
    8000366c:	6a02                	ld	s4,0(sp)
    8000366e:	6145                	addi	sp,sp,48
    80003670:	8082                	ret
    panic("iget: no inodes");
    80003672:	00005517          	auipc	a0,0x5
    80003676:	f1e50513          	addi	a0,a0,-226 # 80008590 <syscalls+0x130>
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	ece080e7          	jalr	-306(ra) # 80000548 <panic>

0000000080003682 <fsinit>:
fsinit(int dev) {
    80003682:	7179                	addi	sp,sp,-48
    80003684:	f406                	sd	ra,40(sp)
    80003686:	f022                	sd	s0,32(sp)
    80003688:	ec26                	sd	s1,24(sp)
    8000368a:	e84a                	sd	s2,16(sp)
    8000368c:	e44e                	sd	s3,8(sp)
    8000368e:	1800                	addi	s0,sp,48
    80003690:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003692:	4585                	li	a1,1
    80003694:	00000097          	auipc	ra,0x0
    80003698:	a64080e7          	jalr	-1436(ra) # 800030f8 <bread>
    8000369c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000369e:	0003c997          	auipc	s3,0x3c
    800036a2:	7ba98993          	addi	s3,s3,1978 # 8003fe58 <sb>
    800036a6:	02000613          	li	a2,32
    800036aa:	05850593          	addi	a1,a0,88
    800036ae:	854e                	mv	a0,s3
    800036b0:	ffffe097          	auipc	ra,0xffffe
    800036b4:	846080e7          	jalr	-1978(ra) # 80000ef6 <memmove>
  brelse(bp);
    800036b8:	8526                	mv	a0,s1
    800036ba:	00000097          	auipc	ra,0x0
    800036be:	b6e080e7          	jalr	-1170(ra) # 80003228 <brelse>
  if(sb.magic != FSMAGIC)
    800036c2:	0009a703          	lw	a4,0(s3)
    800036c6:	102037b7          	lui	a5,0x10203
    800036ca:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036ce:	02f71263          	bne	a4,a5,800036f2 <fsinit+0x70>
  initlog(dev, &sb);
    800036d2:	0003c597          	auipc	a1,0x3c
    800036d6:	78658593          	addi	a1,a1,1926 # 8003fe58 <sb>
    800036da:	854a                	mv	a0,s2
    800036dc:	00001097          	auipc	ra,0x1
    800036e0:	b3c080e7          	jalr	-1220(ra) # 80004218 <initlog>
}
    800036e4:	70a2                	ld	ra,40(sp)
    800036e6:	7402                	ld	s0,32(sp)
    800036e8:	64e2                	ld	s1,24(sp)
    800036ea:	6942                	ld	s2,16(sp)
    800036ec:	69a2                	ld	s3,8(sp)
    800036ee:	6145                	addi	sp,sp,48
    800036f0:	8082                	ret
    panic("invalid file system");
    800036f2:	00005517          	auipc	a0,0x5
    800036f6:	eae50513          	addi	a0,a0,-338 # 800085a0 <syscalls+0x140>
    800036fa:	ffffd097          	auipc	ra,0xffffd
    800036fe:	e4e080e7          	jalr	-434(ra) # 80000548 <panic>

0000000080003702 <iinit>:
{
    80003702:	7179                	addi	sp,sp,-48
    80003704:	f406                	sd	ra,40(sp)
    80003706:	f022                	sd	s0,32(sp)
    80003708:	ec26                	sd	s1,24(sp)
    8000370a:	e84a                	sd	s2,16(sp)
    8000370c:	e44e                	sd	s3,8(sp)
    8000370e:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003710:	00005597          	auipc	a1,0x5
    80003714:	ea858593          	addi	a1,a1,-344 # 800085b8 <syscalls+0x158>
    80003718:	0003c517          	auipc	a0,0x3c
    8000371c:	76050513          	addi	a0,a0,1888 # 8003fe78 <icache>
    80003720:	ffffd097          	auipc	ra,0xffffd
    80003724:	5ea080e7          	jalr	1514(ra) # 80000d0a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003728:	0003c497          	auipc	s1,0x3c
    8000372c:	77848493          	addi	s1,s1,1912 # 8003fea0 <icache+0x28>
    80003730:	0003e997          	auipc	s3,0x3e
    80003734:	20098993          	addi	s3,s3,512 # 80041930 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003738:	00005917          	auipc	s2,0x5
    8000373c:	e8890913          	addi	s2,s2,-376 # 800085c0 <syscalls+0x160>
    80003740:	85ca                	mv	a1,s2
    80003742:	8526                	mv	a0,s1
    80003744:	00001097          	auipc	ra,0x1
    80003748:	e3a080e7          	jalr	-454(ra) # 8000457e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000374c:	08848493          	addi	s1,s1,136
    80003750:	ff3498e3          	bne	s1,s3,80003740 <iinit+0x3e>
}
    80003754:	70a2                	ld	ra,40(sp)
    80003756:	7402                	ld	s0,32(sp)
    80003758:	64e2                	ld	s1,24(sp)
    8000375a:	6942                	ld	s2,16(sp)
    8000375c:	69a2                	ld	s3,8(sp)
    8000375e:	6145                	addi	sp,sp,48
    80003760:	8082                	ret

0000000080003762 <ialloc>:
{
    80003762:	715d                	addi	sp,sp,-80
    80003764:	e486                	sd	ra,72(sp)
    80003766:	e0a2                	sd	s0,64(sp)
    80003768:	fc26                	sd	s1,56(sp)
    8000376a:	f84a                	sd	s2,48(sp)
    8000376c:	f44e                	sd	s3,40(sp)
    8000376e:	f052                	sd	s4,32(sp)
    80003770:	ec56                	sd	s5,24(sp)
    80003772:	e85a                	sd	s6,16(sp)
    80003774:	e45e                	sd	s7,8(sp)
    80003776:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003778:	0003c717          	auipc	a4,0x3c
    8000377c:	6ec72703          	lw	a4,1772(a4) # 8003fe64 <sb+0xc>
    80003780:	4785                	li	a5,1
    80003782:	04e7fa63          	bgeu	a5,a4,800037d6 <ialloc+0x74>
    80003786:	8aaa                	mv	s5,a0
    80003788:	8bae                	mv	s7,a1
    8000378a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000378c:	0003ca17          	auipc	s4,0x3c
    80003790:	6cca0a13          	addi	s4,s4,1740 # 8003fe58 <sb>
    80003794:	00048b1b          	sext.w	s6,s1
    80003798:	0044d593          	srli	a1,s1,0x4
    8000379c:	018a2783          	lw	a5,24(s4)
    800037a0:	9dbd                	addw	a1,a1,a5
    800037a2:	8556                	mv	a0,s5
    800037a4:	00000097          	auipc	ra,0x0
    800037a8:	954080e7          	jalr	-1708(ra) # 800030f8 <bread>
    800037ac:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037ae:	05850993          	addi	s3,a0,88
    800037b2:	00f4f793          	andi	a5,s1,15
    800037b6:	079a                	slli	a5,a5,0x6
    800037b8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037ba:	00099783          	lh	a5,0(s3)
    800037be:	c785                	beqz	a5,800037e6 <ialloc+0x84>
    brelse(bp);
    800037c0:	00000097          	auipc	ra,0x0
    800037c4:	a68080e7          	jalr	-1432(ra) # 80003228 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037c8:	0485                	addi	s1,s1,1
    800037ca:	00ca2703          	lw	a4,12(s4)
    800037ce:	0004879b          	sext.w	a5,s1
    800037d2:	fce7e1e3          	bltu	a5,a4,80003794 <ialloc+0x32>
  panic("ialloc: no inodes");
    800037d6:	00005517          	auipc	a0,0x5
    800037da:	df250513          	addi	a0,a0,-526 # 800085c8 <syscalls+0x168>
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	d6a080e7          	jalr	-662(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    800037e6:	04000613          	li	a2,64
    800037ea:	4581                	li	a1,0
    800037ec:	854e                	mv	a0,s3
    800037ee:	ffffd097          	auipc	ra,0xffffd
    800037f2:	6a8080e7          	jalr	1704(ra) # 80000e96 <memset>
      dip->type = type;
    800037f6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037fa:	854a                	mv	a0,s2
    800037fc:	00001097          	auipc	ra,0x1
    80003800:	c94080e7          	jalr	-876(ra) # 80004490 <log_write>
      brelse(bp);
    80003804:	854a                	mv	a0,s2
    80003806:	00000097          	auipc	ra,0x0
    8000380a:	a22080e7          	jalr	-1502(ra) # 80003228 <brelse>
      return iget(dev, inum);
    8000380e:	85da                	mv	a1,s6
    80003810:	8556                	mv	a0,s5
    80003812:	00000097          	auipc	ra,0x0
    80003816:	db4080e7          	jalr	-588(ra) # 800035c6 <iget>
}
    8000381a:	60a6                	ld	ra,72(sp)
    8000381c:	6406                	ld	s0,64(sp)
    8000381e:	74e2                	ld	s1,56(sp)
    80003820:	7942                	ld	s2,48(sp)
    80003822:	79a2                	ld	s3,40(sp)
    80003824:	7a02                	ld	s4,32(sp)
    80003826:	6ae2                	ld	s5,24(sp)
    80003828:	6b42                	ld	s6,16(sp)
    8000382a:	6ba2                	ld	s7,8(sp)
    8000382c:	6161                	addi	sp,sp,80
    8000382e:	8082                	ret

0000000080003830 <iupdate>:
{
    80003830:	1101                	addi	sp,sp,-32
    80003832:	ec06                	sd	ra,24(sp)
    80003834:	e822                	sd	s0,16(sp)
    80003836:	e426                	sd	s1,8(sp)
    80003838:	e04a                	sd	s2,0(sp)
    8000383a:	1000                	addi	s0,sp,32
    8000383c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000383e:	415c                	lw	a5,4(a0)
    80003840:	0047d79b          	srliw	a5,a5,0x4
    80003844:	0003c597          	auipc	a1,0x3c
    80003848:	62c5a583          	lw	a1,1580(a1) # 8003fe70 <sb+0x18>
    8000384c:	9dbd                	addw	a1,a1,a5
    8000384e:	4108                	lw	a0,0(a0)
    80003850:	00000097          	auipc	ra,0x0
    80003854:	8a8080e7          	jalr	-1880(ra) # 800030f8 <bread>
    80003858:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000385a:	05850793          	addi	a5,a0,88
    8000385e:	40c8                	lw	a0,4(s1)
    80003860:	893d                	andi	a0,a0,15
    80003862:	051a                	slli	a0,a0,0x6
    80003864:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003866:	04449703          	lh	a4,68(s1)
    8000386a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000386e:	04649703          	lh	a4,70(s1)
    80003872:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003876:	04849703          	lh	a4,72(s1)
    8000387a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000387e:	04a49703          	lh	a4,74(s1)
    80003882:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003886:	44f8                	lw	a4,76(s1)
    80003888:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000388a:	03400613          	li	a2,52
    8000388e:	05048593          	addi	a1,s1,80
    80003892:	0531                	addi	a0,a0,12
    80003894:	ffffd097          	auipc	ra,0xffffd
    80003898:	662080e7          	jalr	1634(ra) # 80000ef6 <memmove>
  log_write(bp);
    8000389c:	854a                	mv	a0,s2
    8000389e:	00001097          	auipc	ra,0x1
    800038a2:	bf2080e7          	jalr	-1038(ra) # 80004490 <log_write>
  brelse(bp);
    800038a6:	854a                	mv	a0,s2
    800038a8:	00000097          	auipc	ra,0x0
    800038ac:	980080e7          	jalr	-1664(ra) # 80003228 <brelse>
}
    800038b0:	60e2                	ld	ra,24(sp)
    800038b2:	6442                	ld	s0,16(sp)
    800038b4:	64a2                	ld	s1,8(sp)
    800038b6:	6902                	ld	s2,0(sp)
    800038b8:	6105                	addi	sp,sp,32
    800038ba:	8082                	ret

00000000800038bc <idup>:
{
    800038bc:	1101                	addi	sp,sp,-32
    800038be:	ec06                	sd	ra,24(sp)
    800038c0:	e822                	sd	s0,16(sp)
    800038c2:	e426                	sd	s1,8(sp)
    800038c4:	1000                	addi	s0,sp,32
    800038c6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800038c8:	0003c517          	auipc	a0,0x3c
    800038cc:	5b050513          	addi	a0,a0,1456 # 8003fe78 <icache>
    800038d0:	ffffd097          	auipc	ra,0xffffd
    800038d4:	4ca080e7          	jalr	1226(ra) # 80000d9a <acquire>
  ip->ref++;
    800038d8:	449c                	lw	a5,8(s1)
    800038da:	2785                	addiw	a5,a5,1
    800038dc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800038de:	0003c517          	auipc	a0,0x3c
    800038e2:	59a50513          	addi	a0,a0,1434 # 8003fe78 <icache>
    800038e6:	ffffd097          	auipc	ra,0xffffd
    800038ea:	568080e7          	jalr	1384(ra) # 80000e4e <release>
}
    800038ee:	8526                	mv	a0,s1
    800038f0:	60e2                	ld	ra,24(sp)
    800038f2:	6442                	ld	s0,16(sp)
    800038f4:	64a2                	ld	s1,8(sp)
    800038f6:	6105                	addi	sp,sp,32
    800038f8:	8082                	ret

00000000800038fa <ilock>:
{
    800038fa:	1101                	addi	sp,sp,-32
    800038fc:	ec06                	sd	ra,24(sp)
    800038fe:	e822                	sd	s0,16(sp)
    80003900:	e426                	sd	s1,8(sp)
    80003902:	e04a                	sd	s2,0(sp)
    80003904:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003906:	c115                	beqz	a0,8000392a <ilock+0x30>
    80003908:	84aa                	mv	s1,a0
    8000390a:	451c                	lw	a5,8(a0)
    8000390c:	00f05f63          	blez	a5,8000392a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003910:	0541                	addi	a0,a0,16
    80003912:	00001097          	auipc	ra,0x1
    80003916:	ca6080e7          	jalr	-858(ra) # 800045b8 <acquiresleep>
  if(ip->valid == 0){
    8000391a:	40bc                	lw	a5,64(s1)
    8000391c:	cf99                	beqz	a5,8000393a <ilock+0x40>
}
    8000391e:	60e2                	ld	ra,24(sp)
    80003920:	6442                	ld	s0,16(sp)
    80003922:	64a2                	ld	s1,8(sp)
    80003924:	6902                	ld	s2,0(sp)
    80003926:	6105                	addi	sp,sp,32
    80003928:	8082                	ret
    panic("ilock");
    8000392a:	00005517          	auipc	a0,0x5
    8000392e:	cb650513          	addi	a0,a0,-842 # 800085e0 <syscalls+0x180>
    80003932:	ffffd097          	auipc	ra,0xffffd
    80003936:	c16080e7          	jalr	-1002(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000393a:	40dc                	lw	a5,4(s1)
    8000393c:	0047d79b          	srliw	a5,a5,0x4
    80003940:	0003c597          	auipc	a1,0x3c
    80003944:	5305a583          	lw	a1,1328(a1) # 8003fe70 <sb+0x18>
    80003948:	9dbd                	addw	a1,a1,a5
    8000394a:	4088                	lw	a0,0(s1)
    8000394c:	fffff097          	auipc	ra,0xfffff
    80003950:	7ac080e7          	jalr	1964(ra) # 800030f8 <bread>
    80003954:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003956:	05850593          	addi	a1,a0,88
    8000395a:	40dc                	lw	a5,4(s1)
    8000395c:	8bbd                	andi	a5,a5,15
    8000395e:	079a                	slli	a5,a5,0x6
    80003960:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003962:	00059783          	lh	a5,0(a1)
    80003966:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000396a:	00259783          	lh	a5,2(a1)
    8000396e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003972:	00459783          	lh	a5,4(a1)
    80003976:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000397a:	00659783          	lh	a5,6(a1)
    8000397e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003982:	459c                	lw	a5,8(a1)
    80003984:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003986:	03400613          	li	a2,52
    8000398a:	05b1                	addi	a1,a1,12
    8000398c:	05048513          	addi	a0,s1,80
    80003990:	ffffd097          	auipc	ra,0xffffd
    80003994:	566080e7          	jalr	1382(ra) # 80000ef6 <memmove>
    brelse(bp);
    80003998:	854a                	mv	a0,s2
    8000399a:	00000097          	auipc	ra,0x0
    8000399e:	88e080e7          	jalr	-1906(ra) # 80003228 <brelse>
    ip->valid = 1;
    800039a2:	4785                	li	a5,1
    800039a4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039a6:	04449783          	lh	a5,68(s1)
    800039aa:	fbb5                	bnez	a5,8000391e <ilock+0x24>
      panic("ilock: no type");
    800039ac:	00005517          	auipc	a0,0x5
    800039b0:	c3c50513          	addi	a0,a0,-964 # 800085e8 <syscalls+0x188>
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	b94080e7          	jalr	-1132(ra) # 80000548 <panic>

00000000800039bc <iunlock>:
{
    800039bc:	1101                	addi	sp,sp,-32
    800039be:	ec06                	sd	ra,24(sp)
    800039c0:	e822                	sd	s0,16(sp)
    800039c2:	e426                	sd	s1,8(sp)
    800039c4:	e04a                	sd	s2,0(sp)
    800039c6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039c8:	c905                	beqz	a0,800039f8 <iunlock+0x3c>
    800039ca:	84aa                	mv	s1,a0
    800039cc:	01050913          	addi	s2,a0,16
    800039d0:	854a                	mv	a0,s2
    800039d2:	00001097          	auipc	ra,0x1
    800039d6:	c80080e7          	jalr	-896(ra) # 80004652 <holdingsleep>
    800039da:	cd19                	beqz	a0,800039f8 <iunlock+0x3c>
    800039dc:	449c                	lw	a5,8(s1)
    800039de:	00f05d63          	blez	a5,800039f8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039e2:	854a                	mv	a0,s2
    800039e4:	00001097          	auipc	ra,0x1
    800039e8:	c2a080e7          	jalr	-982(ra) # 8000460e <releasesleep>
}
    800039ec:	60e2                	ld	ra,24(sp)
    800039ee:	6442                	ld	s0,16(sp)
    800039f0:	64a2                	ld	s1,8(sp)
    800039f2:	6902                	ld	s2,0(sp)
    800039f4:	6105                	addi	sp,sp,32
    800039f6:	8082                	ret
    panic("iunlock");
    800039f8:	00005517          	auipc	a0,0x5
    800039fc:	c0050513          	addi	a0,a0,-1024 # 800085f8 <syscalls+0x198>
    80003a00:	ffffd097          	auipc	ra,0xffffd
    80003a04:	b48080e7          	jalr	-1208(ra) # 80000548 <panic>

0000000080003a08 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a08:	7179                	addi	sp,sp,-48
    80003a0a:	f406                	sd	ra,40(sp)
    80003a0c:	f022                	sd	s0,32(sp)
    80003a0e:	ec26                	sd	s1,24(sp)
    80003a10:	e84a                	sd	s2,16(sp)
    80003a12:	e44e                	sd	s3,8(sp)
    80003a14:	e052                	sd	s4,0(sp)
    80003a16:	1800                	addi	s0,sp,48
    80003a18:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a1a:	05050493          	addi	s1,a0,80
    80003a1e:	08050913          	addi	s2,a0,128
    80003a22:	a021                	j	80003a2a <itrunc+0x22>
    80003a24:	0491                	addi	s1,s1,4
    80003a26:	01248d63          	beq	s1,s2,80003a40 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a2a:	408c                	lw	a1,0(s1)
    80003a2c:	dde5                	beqz	a1,80003a24 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a2e:	0009a503          	lw	a0,0(s3)
    80003a32:	00000097          	auipc	ra,0x0
    80003a36:	90c080e7          	jalr	-1780(ra) # 8000333e <bfree>
      ip->addrs[i] = 0;
    80003a3a:	0004a023          	sw	zero,0(s1)
    80003a3e:	b7dd                	j	80003a24 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a40:	0809a583          	lw	a1,128(s3)
    80003a44:	e185                	bnez	a1,80003a64 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a46:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a4a:	854e                	mv	a0,s3
    80003a4c:	00000097          	auipc	ra,0x0
    80003a50:	de4080e7          	jalr	-540(ra) # 80003830 <iupdate>
}
    80003a54:	70a2                	ld	ra,40(sp)
    80003a56:	7402                	ld	s0,32(sp)
    80003a58:	64e2                	ld	s1,24(sp)
    80003a5a:	6942                	ld	s2,16(sp)
    80003a5c:	69a2                	ld	s3,8(sp)
    80003a5e:	6a02                	ld	s4,0(sp)
    80003a60:	6145                	addi	sp,sp,48
    80003a62:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a64:	0009a503          	lw	a0,0(s3)
    80003a68:	fffff097          	auipc	ra,0xfffff
    80003a6c:	690080e7          	jalr	1680(ra) # 800030f8 <bread>
    80003a70:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a72:	05850493          	addi	s1,a0,88
    80003a76:	45850913          	addi	s2,a0,1112
    80003a7a:	a811                	j	80003a8e <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003a7c:	0009a503          	lw	a0,0(s3)
    80003a80:	00000097          	auipc	ra,0x0
    80003a84:	8be080e7          	jalr	-1858(ra) # 8000333e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003a88:	0491                	addi	s1,s1,4
    80003a8a:	01248563          	beq	s1,s2,80003a94 <itrunc+0x8c>
      if(a[j])
    80003a8e:	408c                	lw	a1,0(s1)
    80003a90:	dde5                	beqz	a1,80003a88 <itrunc+0x80>
    80003a92:	b7ed                	j	80003a7c <itrunc+0x74>
    brelse(bp);
    80003a94:	8552                	mv	a0,s4
    80003a96:	fffff097          	auipc	ra,0xfffff
    80003a9a:	792080e7          	jalr	1938(ra) # 80003228 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a9e:	0809a583          	lw	a1,128(s3)
    80003aa2:	0009a503          	lw	a0,0(s3)
    80003aa6:	00000097          	auipc	ra,0x0
    80003aaa:	898080e7          	jalr	-1896(ra) # 8000333e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003aae:	0809a023          	sw	zero,128(s3)
    80003ab2:	bf51                	j	80003a46 <itrunc+0x3e>

0000000080003ab4 <iput>:
{
    80003ab4:	1101                	addi	sp,sp,-32
    80003ab6:	ec06                	sd	ra,24(sp)
    80003ab8:	e822                	sd	s0,16(sp)
    80003aba:	e426                	sd	s1,8(sp)
    80003abc:	e04a                	sd	s2,0(sp)
    80003abe:	1000                	addi	s0,sp,32
    80003ac0:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003ac2:	0003c517          	auipc	a0,0x3c
    80003ac6:	3b650513          	addi	a0,a0,950 # 8003fe78 <icache>
    80003aca:	ffffd097          	auipc	ra,0xffffd
    80003ace:	2d0080e7          	jalr	720(ra) # 80000d9a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ad2:	4498                	lw	a4,8(s1)
    80003ad4:	4785                	li	a5,1
    80003ad6:	02f70363          	beq	a4,a5,80003afc <iput+0x48>
  ip->ref--;
    80003ada:	449c                	lw	a5,8(s1)
    80003adc:	37fd                	addiw	a5,a5,-1
    80003ade:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003ae0:	0003c517          	auipc	a0,0x3c
    80003ae4:	39850513          	addi	a0,a0,920 # 8003fe78 <icache>
    80003ae8:	ffffd097          	auipc	ra,0xffffd
    80003aec:	366080e7          	jalr	870(ra) # 80000e4e <release>
}
    80003af0:	60e2                	ld	ra,24(sp)
    80003af2:	6442                	ld	s0,16(sp)
    80003af4:	64a2                	ld	s1,8(sp)
    80003af6:	6902                	ld	s2,0(sp)
    80003af8:	6105                	addi	sp,sp,32
    80003afa:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003afc:	40bc                	lw	a5,64(s1)
    80003afe:	dff1                	beqz	a5,80003ada <iput+0x26>
    80003b00:	04a49783          	lh	a5,74(s1)
    80003b04:	fbf9                	bnez	a5,80003ada <iput+0x26>
    acquiresleep(&ip->lock);
    80003b06:	01048913          	addi	s2,s1,16
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	00001097          	auipc	ra,0x1
    80003b10:	aac080e7          	jalr	-1364(ra) # 800045b8 <acquiresleep>
    release(&icache.lock);
    80003b14:	0003c517          	auipc	a0,0x3c
    80003b18:	36450513          	addi	a0,a0,868 # 8003fe78 <icache>
    80003b1c:	ffffd097          	auipc	ra,0xffffd
    80003b20:	332080e7          	jalr	818(ra) # 80000e4e <release>
    itrunc(ip);
    80003b24:	8526                	mv	a0,s1
    80003b26:	00000097          	auipc	ra,0x0
    80003b2a:	ee2080e7          	jalr	-286(ra) # 80003a08 <itrunc>
    ip->type = 0;
    80003b2e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b32:	8526                	mv	a0,s1
    80003b34:	00000097          	auipc	ra,0x0
    80003b38:	cfc080e7          	jalr	-772(ra) # 80003830 <iupdate>
    ip->valid = 0;
    80003b3c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b40:	854a                	mv	a0,s2
    80003b42:	00001097          	auipc	ra,0x1
    80003b46:	acc080e7          	jalr	-1332(ra) # 8000460e <releasesleep>
    acquire(&icache.lock);
    80003b4a:	0003c517          	auipc	a0,0x3c
    80003b4e:	32e50513          	addi	a0,a0,814 # 8003fe78 <icache>
    80003b52:	ffffd097          	auipc	ra,0xffffd
    80003b56:	248080e7          	jalr	584(ra) # 80000d9a <acquire>
    80003b5a:	b741                	j	80003ada <iput+0x26>

0000000080003b5c <iunlockput>:
{
    80003b5c:	1101                	addi	sp,sp,-32
    80003b5e:	ec06                	sd	ra,24(sp)
    80003b60:	e822                	sd	s0,16(sp)
    80003b62:	e426                	sd	s1,8(sp)
    80003b64:	1000                	addi	s0,sp,32
    80003b66:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	e54080e7          	jalr	-428(ra) # 800039bc <iunlock>
  iput(ip);
    80003b70:	8526                	mv	a0,s1
    80003b72:	00000097          	auipc	ra,0x0
    80003b76:	f42080e7          	jalr	-190(ra) # 80003ab4 <iput>
}
    80003b7a:	60e2                	ld	ra,24(sp)
    80003b7c:	6442                	ld	s0,16(sp)
    80003b7e:	64a2                	ld	s1,8(sp)
    80003b80:	6105                	addi	sp,sp,32
    80003b82:	8082                	ret

0000000080003b84 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b84:	1141                	addi	sp,sp,-16
    80003b86:	e422                	sd	s0,8(sp)
    80003b88:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b8a:	411c                	lw	a5,0(a0)
    80003b8c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b8e:	415c                	lw	a5,4(a0)
    80003b90:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b92:	04451783          	lh	a5,68(a0)
    80003b96:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b9a:	04a51783          	lh	a5,74(a0)
    80003b9e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ba2:	04c56783          	lwu	a5,76(a0)
    80003ba6:	e99c                	sd	a5,16(a1)
}
    80003ba8:	6422                	ld	s0,8(sp)
    80003baa:	0141                	addi	sp,sp,16
    80003bac:	8082                	ret

0000000080003bae <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bae:	457c                	lw	a5,76(a0)
    80003bb0:	0ed7e963          	bltu	a5,a3,80003ca2 <readi+0xf4>
{
    80003bb4:	7159                	addi	sp,sp,-112
    80003bb6:	f486                	sd	ra,104(sp)
    80003bb8:	f0a2                	sd	s0,96(sp)
    80003bba:	eca6                	sd	s1,88(sp)
    80003bbc:	e8ca                	sd	s2,80(sp)
    80003bbe:	e4ce                	sd	s3,72(sp)
    80003bc0:	e0d2                	sd	s4,64(sp)
    80003bc2:	fc56                	sd	s5,56(sp)
    80003bc4:	f85a                	sd	s6,48(sp)
    80003bc6:	f45e                	sd	s7,40(sp)
    80003bc8:	f062                	sd	s8,32(sp)
    80003bca:	ec66                	sd	s9,24(sp)
    80003bcc:	e86a                	sd	s10,16(sp)
    80003bce:	e46e                	sd	s11,8(sp)
    80003bd0:	1880                	addi	s0,sp,112
    80003bd2:	8baa                	mv	s7,a0
    80003bd4:	8c2e                	mv	s8,a1
    80003bd6:	8ab2                	mv	s5,a2
    80003bd8:	84b6                	mv	s1,a3
    80003bda:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bdc:	9f35                	addw	a4,a4,a3
    return 0;
    80003bde:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003be0:	0ad76063          	bltu	a4,a3,80003c80 <readi+0xd2>
  if(off + n > ip->size)
    80003be4:	00e7f463          	bgeu	a5,a4,80003bec <readi+0x3e>
    n = ip->size - off;
    80003be8:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bec:	0a0b0963          	beqz	s6,80003c9e <readi+0xf0>
    80003bf0:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bf2:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003bf6:	5cfd                	li	s9,-1
    80003bf8:	a82d                	j	80003c32 <readi+0x84>
    80003bfa:	020a1d93          	slli	s11,s4,0x20
    80003bfe:	020ddd93          	srli	s11,s11,0x20
    80003c02:	05890613          	addi	a2,s2,88
    80003c06:	86ee                	mv	a3,s11
    80003c08:	963a                	add	a2,a2,a4
    80003c0a:	85d6                	mv	a1,s5
    80003c0c:	8562                	mv	a0,s8
    80003c0e:	fffff097          	auipc	ra,0xfffff
    80003c12:	aea080e7          	jalr	-1302(ra) # 800026f8 <either_copyout>
    80003c16:	05950d63          	beq	a0,s9,80003c70 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c1a:	854a                	mv	a0,s2
    80003c1c:	fffff097          	auipc	ra,0xfffff
    80003c20:	60c080e7          	jalr	1548(ra) # 80003228 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c24:	013a09bb          	addw	s3,s4,s3
    80003c28:	009a04bb          	addw	s1,s4,s1
    80003c2c:	9aee                	add	s5,s5,s11
    80003c2e:	0569f763          	bgeu	s3,s6,80003c7c <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c32:	000ba903          	lw	s2,0(s7)
    80003c36:	00a4d59b          	srliw	a1,s1,0xa
    80003c3a:	855e                	mv	a0,s7
    80003c3c:	00000097          	auipc	ra,0x0
    80003c40:	8b0080e7          	jalr	-1872(ra) # 800034ec <bmap>
    80003c44:	0005059b          	sext.w	a1,a0
    80003c48:	854a                	mv	a0,s2
    80003c4a:	fffff097          	auipc	ra,0xfffff
    80003c4e:	4ae080e7          	jalr	1198(ra) # 800030f8 <bread>
    80003c52:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c54:	3ff4f713          	andi	a4,s1,1023
    80003c58:	40ed07bb          	subw	a5,s10,a4
    80003c5c:	413b06bb          	subw	a3,s6,s3
    80003c60:	8a3e                	mv	s4,a5
    80003c62:	2781                	sext.w	a5,a5
    80003c64:	0006861b          	sext.w	a2,a3
    80003c68:	f8f679e3          	bgeu	a2,a5,80003bfa <readi+0x4c>
    80003c6c:	8a36                	mv	s4,a3
    80003c6e:	b771                	j	80003bfa <readi+0x4c>
      brelse(bp);
    80003c70:	854a                	mv	a0,s2
    80003c72:	fffff097          	auipc	ra,0xfffff
    80003c76:	5b6080e7          	jalr	1462(ra) # 80003228 <brelse>
      tot = -1;
    80003c7a:	59fd                	li	s3,-1
  }
  return tot;
    80003c7c:	0009851b          	sext.w	a0,s3
}
    80003c80:	70a6                	ld	ra,104(sp)
    80003c82:	7406                	ld	s0,96(sp)
    80003c84:	64e6                	ld	s1,88(sp)
    80003c86:	6946                	ld	s2,80(sp)
    80003c88:	69a6                	ld	s3,72(sp)
    80003c8a:	6a06                	ld	s4,64(sp)
    80003c8c:	7ae2                	ld	s5,56(sp)
    80003c8e:	7b42                	ld	s6,48(sp)
    80003c90:	7ba2                	ld	s7,40(sp)
    80003c92:	7c02                	ld	s8,32(sp)
    80003c94:	6ce2                	ld	s9,24(sp)
    80003c96:	6d42                	ld	s10,16(sp)
    80003c98:	6da2                	ld	s11,8(sp)
    80003c9a:	6165                	addi	sp,sp,112
    80003c9c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c9e:	89da                	mv	s3,s6
    80003ca0:	bff1                	j	80003c7c <readi+0xce>
    return 0;
    80003ca2:	4501                	li	a0,0
}
    80003ca4:	8082                	ret

0000000080003ca6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ca6:	457c                	lw	a5,76(a0)
    80003ca8:	10d7e763          	bltu	a5,a3,80003db6 <writei+0x110>
{
    80003cac:	7159                	addi	sp,sp,-112
    80003cae:	f486                	sd	ra,104(sp)
    80003cb0:	f0a2                	sd	s0,96(sp)
    80003cb2:	eca6                	sd	s1,88(sp)
    80003cb4:	e8ca                	sd	s2,80(sp)
    80003cb6:	e4ce                	sd	s3,72(sp)
    80003cb8:	e0d2                	sd	s4,64(sp)
    80003cba:	fc56                	sd	s5,56(sp)
    80003cbc:	f85a                	sd	s6,48(sp)
    80003cbe:	f45e                	sd	s7,40(sp)
    80003cc0:	f062                	sd	s8,32(sp)
    80003cc2:	ec66                	sd	s9,24(sp)
    80003cc4:	e86a                	sd	s10,16(sp)
    80003cc6:	e46e                	sd	s11,8(sp)
    80003cc8:	1880                	addi	s0,sp,112
    80003cca:	8baa                	mv	s7,a0
    80003ccc:	8c2e                	mv	s8,a1
    80003cce:	8ab2                	mv	s5,a2
    80003cd0:	8936                	mv	s2,a3
    80003cd2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cd4:	00e687bb          	addw	a5,a3,a4
    80003cd8:	0ed7e163          	bltu	a5,a3,80003dba <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cdc:	00043737          	lui	a4,0x43
    80003ce0:	0cf76f63          	bltu	a4,a5,80003dbe <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ce4:	0a0b0863          	beqz	s6,80003d94 <writei+0xee>
    80003ce8:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cea:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cee:	5cfd                	li	s9,-1
    80003cf0:	a091                	j	80003d34 <writei+0x8e>
    80003cf2:	02099d93          	slli	s11,s3,0x20
    80003cf6:	020ddd93          	srli	s11,s11,0x20
    80003cfa:	05848513          	addi	a0,s1,88
    80003cfe:	86ee                	mv	a3,s11
    80003d00:	8656                	mv	a2,s5
    80003d02:	85e2                	mv	a1,s8
    80003d04:	953a                	add	a0,a0,a4
    80003d06:	fffff097          	auipc	ra,0xfffff
    80003d0a:	a48080e7          	jalr	-1464(ra) # 8000274e <either_copyin>
    80003d0e:	07950263          	beq	a0,s9,80003d72 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003d12:	8526                	mv	a0,s1
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	77c080e7          	jalr	1916(ra) # 80004490 <log_write>
    brelse(bp);
    80003d1c:	8526                	mv	a0,s1
    80003d1e:	fffff097          	auipc	ra,0xfffff
    80003d22:	50a080e7          	jalr	1290(ra) # 80003228 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d26:	01498a3b          	addw	s4,s3,s4
    80003d2a:	0129893b          	addw	s2,s3,s2
    80003d2e:	9aee                	add	s5,s5,s11
    80003d30:	056a7763          	bgeu	s4,s6,80003d7e <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d34:	000ba483          	lw	s1,0(s7)
    80003d38:	00a9559b          	srliw	a1,s2,0xa
    80003d3c:	855e                	mv	a0,s7
    80003d3e:	fffff097          	auipc	ra,0xfffff
    80003d42:	7ae080e7          	jalr	1966(ra) # 800034ec <bmap>
    80003d46:	0005059b          	sext.w	a1,a0
    80003d4a:	8526                	mv	a0,s1
    80003d4c:	fffff097          	auipc	ra,0xfffff
    80003d50:	3ac080e7          	jalr	940(ra) # 800030f8 <bread>
    80003d54:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d56:	3ff97713          	andi	a4,s2,1023
    80003d5a:	40ed07bb          	subw	a5,s10,a4
    80003d5e:	414b06bb          	subw	a3,s6,s4
    80003d62:	89be                	mv	s3,a5
    80003d64:	2781                	sext.w	a5,a5
    80003d66:	0006861b          	sext.w	a2,a3
    80003d6a:	f8f674e3          	bgeu	a2,a5,80003cf2 <writei+0x4c>
    80003d6e:	89b6                	mv	s3,a3
    80003d70:	b749                	j	80003cf2 <writei+0x4c>
      brelse(bp);
    80003d72:	8526                	mv	a0,s1
    80003d74:	fffff097          	auipc	ra,0xfffff
    80003d78:	4b4080e7          	jalr	1204(ra) # 80003228 <brelse>
      n = -1;
    80003d7c:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003d7e:	04cba783          	lw	a5,76(s7)
    80003d82:	0127f463          	bgeu	a5,s2,80003d8a <writei+0xe4>
      ip->size = off;
    80003d86:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003d8a:	855e                	mv	a0,s7
    80003d8c:	00000097          	auipc	ra,0x0
    80003d90:	aa4080e7          	jalr	-1372(ra) # 80003830 <iupdate>
  }

  return n;
    80003d94:	000b051b          	sext.w	a0,s6
}
    80003d98:	70a6                	ld	ra,104(sp)
    80003d9a:	7406                	ld	s0,96(sp)
    80003d9c:	64e6                	ld	s1,88(sp)
    80003d9e:	6946                	ld	s2,80(sp)
    80003da0:	69a6                	ld	s3,72(sp)
    80003da2:	6a06                	ld	s4,64(sp)
    80003da4:	7ae2                	ld	s5,56(sp)
    80003da6:	7b42                	ld	s6,48(sp)
    80003da8:	7ba2                	ld	s7,40(sp)
    80003daa:	7c02                	ld	s8,32(sp)
    80003dac:	6ce2                	ld	s9,24(sp)
    80003dae:	6d42                	ld	s10,16(sp)
    80003db0:	6da2                	ld	s11,8(sp)
    80003db2:	6165                	addi	sp,sp,112
    80003db4:	8082                	ret
    return -1;
    80003db6:	557d                	li	a0,-1
}
    80003db8:	8082                	ret
    return -1;
    80003dba:	557d                	li	a0,-1
    80003dbc:	bff1                	j	80003d98 <writei+0xf2>
    return -1;
    80003dbe:	557d                	li	a0,-1
    80003dc0:	bfe1                	j	80003d98 <writei+0xf2>

0000000080003dc2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003dc2:	1141                	addi	sp,sp,-16
    80003dc4:	e406                	sd	ra,8(sp)
    80003dc6:	e022                	sd	s0,0(sp)
    80003dc8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003dca:	4639                	li	a2,14
    80003dcc:	ffffd097          	auipc	ra,0xffffd
    80003dd0:	1a6080e7          	jalr	422(ra) # 80000f72 <strncmp>
}
    80003dd4:	60a2                	ld	ra,8(sp)
    80003dd6:	6402                	ld	s0,0(sp)
    80003dd8:	0141                	addi	sp,sp,16
    80003dda:	8082                	ret

0000000080003ddc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ddc:	7139                	addi	sp,sp,-64
    80003dde:	fc06                	sd	ra,56(sp)
    80003de0:	f822                	sd	s0,48(sp)
    80003de2:	f426                	sd	s1,40(sp)
    80003de4:	f04a                	sd	s2,32(sp)
    80003de6:	ec4e                	sd	s3,24(sp)
    80003de8:	e852                	sd	s4,16(sp)
    80003dea:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dec:	04451703          	lh	a4,68(a0)
    80003df0:	4785                	li	a5,1
    80003df2:	00f71a63          	bne	a4,a5,80003e06 <dirlookup+0x2a>
    80003df6:	892a                	mv	s2,a0
    80003df8:	89ae                	mv	s3,a1
    80003dfa:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dfc:	457c                	lw	a5,76(a0)
    80003dfe:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e00:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e02:	e79d                	bnez	a5,80003e30 <dirlookup+0x54>
    80003e04:	a8a5                	j	80003e7c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e06:	00004517          	auipc	a0,0x4
    80003e0a:	7fa50513          	addi	a0,a0,2042 # 80008600 <syscalls+0x1a0>
    80003e0e:	ffffc097          	auipc	ra,0xffffc
    80003e12:	73a080e7          	jalr	1850(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003e16:	00005517          	auipc	a0,0x5
    80003e1a:	80250513          	addi	a0,a0,-2046 # 80008618 <syscalls+0x1b8>
    80003e1e:	ffffc097          	auipc	ra,0xffffc
    80003e22:	72a080e7          	jalr	1834(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e26:	24c1                	addiw	s1,s1,16
    80003e28:	04c92783          	lw	a5,76(s2)
    80003e2c:	04f4f763          	bgeu	s1,a5,80003e7a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e30:	4741                	li	a4,16
    80003e32:	86a6                	mv	a3,s1
    80003e34:	fc040613          	addi	a2,s0,-64
    80003e38:	4581                	li	a1,0
    80003e3a:	854a                	mv	a0,s2
    80003e3c:	00000097          	auipc	ra,0x0
    80003e40:	d72080e7          	jalr	-654(ra) # 80003bae <readi>
    80003e44:	47c1                	li	a5,16
    80003e46:	fcf518e3          	bne	a0,a5,80003e16 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e4a:	fc045783          	lhu	a5,-64(s0)
    80003e4e:	dfe1                	beqz	a5,80003e26 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e50:	fc240593          	addi	a1,s0,-62
    80003e54:	854e                	mv	a0,s3
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	f6c080e7          	jalr	-148(ra) # 80003dc2 <namecmp>
    80003e5e:	f561                	bnez	a0,80003e26 <dirlookup+0x4a>
      if(poff)
    80003e60:	000a0463          	beqz	s4,80003e68 <dirlookup+0x8c>
        *poff = off;
    80003e64:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e68:	fc045583          	lhu	a1,-64(s0)
    80003e6c:	00092503          	lw	a0,0(s2)
    80003e70:	fffff097          	auipc	ra,0xfffff
    80003e74:	756080e7          	jalr	1878(ra) # 800035c6 <iget>
    80003e78:	a011                	j	80003e7c <dirlookup+0xa0>
  return 0;
    80003e7a:	4501                	li	a0,0
}
    80003e7c:	70e2                	ld	ra,56(sp)
    80003e7e:	7442                	ld	s0,48(sp)
    80003e80:	74a2                	ld	s1,40(sp)
    80003e82:	7902                	ld	s2,32(sp)
    80003e84:	69e2                	ld	s3,24(sp)
    80003e86:	6a42                	ld	s4,16(sp)
    80003e88:	6121                	addi	sp,sp,64
    80003e8a:	8082                	ret

0000000080003e8c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e8c:	711d                	addi	sp,sp,-96
    80003e8e:	ec86                	sd	ra,88(sp)
    80003e90:	e8a2                	sd	s0,80(sp)
    80003e92:	e4a6                	sd	s1,72(sp)
    80003e94:	e0ca                	sd	s2,64(sp)
    80003e96:	fc4e                	sd	s3,56(sp)
    80003e98:	f852                	sd	s4,48(sp)
    80003e9a:	f456                	sd	s5,40(sp)
    80003e9c:	f05a                	sd	s6,32(sp)
    80003e9e:	ec5e                	sd	s7,24(sp)
    80003ea0:	e862                	sd	s8,16(sp)
    80003ea2:	e466                	sd	s9,8(sp)
    80003ea4:	1080                	addi	s0,sp,96
    80003ea6:	84aa                	mv	s1,a0
    80003ea8:	8b2e                	mv	s6,a1
    80003eaa:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003eac:	00054703          	lbu	a4,0(a0)
    80003eb0:	02f00793          	li	a5,47
    80003eb4:	02f70363          	beq	a4,a5,80003eda <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003eb8:	ffffe097          	auipc	ra,0xffffe
    80003ebc:	dce080e7          	jalr	-562(ra) # 80001c86 <myproc>
    80003ec0:	15053503          	ld	a0,336(a0)
    80003ec4:	00000097          	auipc	ra,0x0
    80003ec8:	9f8080e7          	jalr	-1544(ra) # 800038bc <idup>
    80003ecc:	89aa                	mv	s3,a0
  while(*path == '/')
    80003ece:	02f00913          	li	s2,47
  len = path - s;
    80003ed2:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003ed4:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ed6:	4c05                	li	s8,1
    80003ed8:	a865                	j	80003f90 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003eda:	4585                	li	a1,1
    80003edc:	4505                	li	a0,1
    80003ede:	fffff097          	auipc	ra,0xfffff
    80003ee2:	6e8080e7          	jalr	1768(ra) # 800035c6 <iget>
    80003ee6:	89aa                	mv	s3,a0
    80003ee8:	b7dd                	j	80003ece <namex+0x42>
      iunlockput(ip);
    80003eea:	854e                	mv	a0,s3
    80003eec:	00000097          	auipc	ra,0x0
    80003ef0:	c70080e7          	jalr	-912(ra) # 80003b5c <iunlockput>
      return 0;
    80003ef4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ef6:	854e                	mv	a0,s3
    80003ef8:	60e6                	ld	ra,88(sp)
    80003efa:	6446                	ld	s0,80(sp)
    80003efc:	64a6                	ld	s1,72(sp)
    80003efe:	6906                	ld	s2,64(sp)
    80003f00:	79e2                	ld	s3,56(sp)
    80003f02:	7a42                	ld	s4,48(sp)
    80003f04:	7aa2                	ld	s5,40(sp)
    80003f06:	7b02                	ld	s6,32(sp)
    80003f08:	6be2                	ld	s7,24(sp)
    80003f0a:	6c42                	ld	s8,16(sp)
    80003f0c:	6ca2                	ld	s9,8(sp)
    80003f0e:	6125                	addi	sp,sp,96
    80003f10:	8082                	ret
      iunlock(ip);
    80003f12:	854e                	mv	a0,s3
    80003f14:	00000097          	auipc	ra,0x0
    80003f18:	aa8080e7          	jalr	-1368(ra) # 800039bc <iunlock>
      return ip;
    80003f1c:	bfe9                	j	80003ef6 <namex+0x6a>
      iunlockput(ip);
    80003f1e:	854e                	mv	a0,s3
    80003f20:	00000097          	auipc	ra,0x0
    80003f24:	c3c080e7          	jalr	-964(ra) # 80003b5c <iunlockput>
      return 0;
    80003f28:	89d2                	mv	s3,s4
    80003f2a:	b7f1                	j	80003ef6 <namex+0x6a>
  len = path - s;
    80003f2c:	40b48633          	sub	a2,s1,a1
    80003f30:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003f34:	094cd463          	bge	s9,s4,80003fbc <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f38:	4639                	li	a2,14
    80003f3a:	8556                	mv	a0,s5
    80003f3c:	ffffd097          	auipc	ra,0xffffd
    80003f40:	fba080e7          	jalr	-70(ra) # 80000ef6 <memmove>
  while(*path == '/')
    80003f44:	0004c783          	lbu	a5,0(s1)
    80003f48:	01279763          	bne	a5,s2,80003f56 <namex+0xca>
    path++;
    80003f4c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f4e:	0004c783          	lbu	a5,0(s1)
    80003f52:	ff278de3          	beq	a5,s2,80003f4c <namex+0xc0>
    ilock(ip);
    80003f56:	854e                	mv	a0,s3
    80003f58:	00000097          	auipc	ra,0x0
    80003f5c:	9a2080e7          	jalr	-1630(ra) # 800038fa <ilock>
    if(ip->type != T_DIR){
    80003f60:	04499783          	lh	a5,68(s3)
    80003f64:	f98793e3          	bne	a5,s8,80003eea <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f68:	000b0563          	beqz	s6,80003f72 <namex+0xe6>
    80003f6c:	0004c783          	lbu	a5,0(s1)
    80003f70:	d3cd                	beqz	a5,80003f12 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f72:	865e                	mv	a2,s7
    80003f74:	85d6                	mv	a1,s5
    80003f76:	854e                	mv	a0,s3
    80003f78:	00000097          	auipc	ra,0x0
    80003f7c:	e64080e7          	jalr	-412(ra) # 80003ddc <dirlookup>
    80003f80:	8a2a                	mv	s4,a0
    80003f82:	dd51                	beqz	a0,80003f1e <namex+0x92>
    iunlockput(ip);
    80003f84:	854e                	mv	a0,s3
    80003f86:	00000097          	auipc	ra,0x0
    80003f8a:	bd6080e7          	jalr	-1066(ra) # 80003b5c <iunlockput>
    ip = next;
    80003f8e:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f90:	0004c783          	lbu	a5,0(s1)
    80003f94:	05279763          	bne	a5,s2,80003fe2 <namex+0x156>
    path++;
    80003f98:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f9a:	0004c783          	lbu	a5,0(s1)
    80003f9e:	ff278de3          	beq	a5,s2,80003f98 <namex+0x10c>
  if(*path == 0)
    80003fa2:	c79d                	beqz	a5,80003fd0 <namex+0x144>
    path++;
    80003fa4:	85a6                	mv	a1,s1
  len = path - s;
    80003fa6:	8a5e                	mv	s4,s7
    80003fa8:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003faa:	01278963          	beq	a5,s2,80003fbc <namex+0x130>
    80003fae:	dfbd                	beqz	a5,80003f2c <namex+0xa0>
    path++;
    80003fb0:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fb2:	0004c783          	lbu	a5,0(s1)
    80003fb6:	ff279ce3          	bne	a5,s2,80003fae <namex+0x122>
    80003fba:	bf8d                	j	80003f2c <namex+0xa0>
    memmove(name, s, len);
    80003fbc:	2601                	sext.w	a2,a2
    80003fbe:	8556                	mv	a0,s5
    80003fc0:	ffffd097          	auipc	ra,0xffffd
    80003fc4:	f36080e7          	jalr	-202(ra) # 80000ef6 <memmove>
    name[len] = 0;
    80003fc8:	9a56                	add	s4,s4,s5
    80003fca:	000a0023          	sb	zero,0(s4)
    80003fce:	bf9d                	j	80003f44 <namex+0xb8>
  if(nameiparent){
    80003fd0:	f20b03e3          	beqz	s6,80003ef6 <namex+0x6a>
    iput(ip);
    80003fd4:	854e                	mv	a0,s3
    80003fd6:	00000097          	auipc	ra,0x0
    80003fda:	ade080e7          	jalr	-1314(ra) # 80003ab4 <iput>
    return 0;
    80003fde:	4981                	li	s3,0
    80003fe0:	bf19                	j	80003ef6 <namex+0x6a>
  if(*path == 0)
    80003fe2:	d7fd                	beqz	a5,80003fd0 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003fe4:	0004c783          	lbu	a5,0(s1)
    80003fe8:	85a6                	mv	a1,s1
    80003fea:	b7d1                	j	80003fae <namex+0x122>

0000000080003fec <dirlink>:
{
    80003fec:	7139                	addi	sp,sp,-64
    80003fee:	fc06                	sd	ra,56(sp)
    80003ff0:	f822                	sd	s0,48(sp)
    80003ff2:	f426                	sd	s1,40(sp)
    80003ff4:	f04a                	sd	s2,32(sp)
    80003ff6:	ec4e                	sd	s3,24(sp)
    80003ff8:	e852                	sd	s4,16(sp)
    80003ffa:	0080                	addi	s0,sp,64
    80003ffc:	892a                	mv	s2,a0
    80003ffe:	8a2e                	mv	s4,a1
    80004000:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004002:	4601                	li	a2,0
    80004004:	00000097          	auipc	ra,0x0
    80004008:	dd8080e7          	jalr	-552(ra) # 80003ddc <dirlookup>
    8000400c:	e93d                	bnez	a0,80004082 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000400e:	04c92483          	lw	s1,76(s2)
    80004012:	c49d                	beqz	s1,80004040 <dirlink+0x54>
    80004014:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004016:	4741                	li	a4,16
    80004018:	86a6                	mv	a3,s1
    8000401a:	fc040613          	addi	a2,s0,-64
    8000401e:	4581                	li	a1,0
    80004020:	854a                	mv	a0,s2
    80004022:	00000097          	auipc	ra,0x0
    80004026:	b8c080e7          	jalr	-1140(ra) # 80003bae <readi>
    8000402a:	47c1                	li	a5,16
    8000402c:	06f51163          	bne	a0,a5,8000408e <dirlink+0xa2>
    if(de.inum == 0)
    80004030:	fc045783          	lhu	a5,-64(s0)
    80004034:	c791                	beqz	a5,80004040 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004036:	24c1                	addiw	s1,s1,16
    80004038:	04c92783          	lw	a5,76(s2)
    8000403c:	fcf4ede3          	bltu	s1,a5,80004016 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004040:	4639                	li	a2,14
    80004042:	85d2                	mv	a1,s4
    80004044:	fc240513          	addi	a0,s0,-62
    80004048:	ffffd097          	auipc	ra,0xffffd
    8000404c:	f66080e7          	jalr	-154(ra) # 80000fae <strncpy>
  de.inum = inum;
    80004050:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004054:	4741                	li	a4,16
    80004056:	86a6                	mv	a3,s1
    80004058:	fc040613          	addi	a2,s0,-64
    8000405c:	4581                	li	a1,0
    8000405e:	854a                	mv	a0,s2
    80004060:	00000097          	auipc	ra,0x0
    80004064:	c46080e7          	jalr	-954(ra) # 80003ca6 <writei>
    80004068:	872a                	mv	a4,a0
    8000406a:	47c1                	li	a5,16
  return 0;
    8000406c:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000406e:	02f71863          	bne	a4,a5,8000409e <dirlink+0xb2>
}
    80004072:	70e2                	ld	ra,56(sp)
    80004074:	7442                	ld	s0,48(sp)
    80004076:	74a2                	ld	s1,40(sp)
    80004078:	7902                	ld	s2,32(sp)
    8000407a:	69e2                	ld	s3,24(sp)
    8000407c:	6a42                	ld	s4,16(sp)
    8000407e:	6121                	addi	sp,sp,64
    80004080:	8082                	ret
    iput(ip);
    80004082:	00000097          	auipc	ra,0x0
    80004086:	a32080e7          	jalr	-1486(ra) # 80003ab4 <iput>
    return -1;
    8000408a:	557d                	li	a0,-1
    8000408c:	b7dd                	j	80004072 <dirlink+0x86>
      panic("dirlink read");
    8000408e:	00004517          	auipc	a0,0x4
    80004092:	59a50513          	addi	a0,a0,1434 # 80008628 <syscalls+0x1c8>
    80004096:	ffffc097          	auipc	ra,0xffffc
    8000409a:	4b2080e7          	jalr	1202(ra) # 80000548 <panic>
    panic("dirlink");
    8000409e:	00004517          	auipc	a0,0x4
    800040a2:	6aa50513          	addi	a0,a0,1706 # 80008748 <syscalls+0x2e8>
    800040a6:	ffffc097          	auipc	ra,0xffffc
    800040aa:	4a2080e7          	jalr	1186(ra) # 80000548 <panic>

00000000800040ae <namei>:

struct inode*
namei(char *path)
{
    800040ae:	1101                	addi	sp,sp,-32
    800040b0:	ec06                	sd	ra,24(sp)
    800040b2:	e822                	sd	s0,16(sp)
    800040b4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040b6:	fe040613          	addi	a2,s0,-32
    800040ba:	4581                	li	a1,0
    800040bc:	00000097          	auipc	ra,0x0
    800040c0:	dd0080e7          	jalr	-560(ra) # 80003e8c <namex>
}
    800040c4:	60e2                	ld	ra,24(sp)
    800040c6:	6442                	ld	s0,16(sp)
    800040c8:	6105                	addi	sp,sp,32
    800040ca:	8082                	ret

00000000800040cc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040cc:	1141                	addi	sp,sp,-16
    800040ce:	e406                	sd	ra,8(sp)
    800040d0:	e022                	sd	s0,0(sp)
    800040d2:	0800                	addi	s0,sp,16
    800040d4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040d6:	4585                	li	a1,1
    800040d8:	00000097          	auipc	ra,0x0
    800040dc:	db4080e7          	jalr	-588(ra) # 80003e8c <namex>
}
    800040e0:	60a2                	ld	ra,8(sp)
    800040e2:	6402                	ld	s0,0(sp)
    800040e4:	0141                	addi	sp,sp,16
    800040e6:	8082                	ret

00000000800040e8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040e8:	1101                	addi	sp,sp,-32
    800040ea:	ec06                	sd	ra,24(sp)
    800040ec:	e822                	sd	s0,16(sp)
    800040ee:	e426                	sd	s1,8(sp)
    800040f0:	e04a                	sd	s2,0(sp)
    800040f2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040f4:	0003e917          	auipc	s2,0x3e
    800040f8:	82c90913          	addi	s2,s2,-2004 # 80041920 <log>
    800040fc:	01892583          	lw	a1,24(s2)
    80004100:	02892503          	lw	a0,40(s2)
    80004104:	fffff097          	auipc	ra,0xfffff
    80004108:	ff4080e7          	jalr	-12(ra) # 800030f8 <bread>
    8000410c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000410e:	02c92683          	lw	a3,44(s2)
    80004112:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004114:	02d05763          	blez	a3,80004142 <write_head+0x5a>
    80004118:	0003e797          	auipc	a5,0x3e
    8000411c:	83878793          	addi	a5,a5,-1992 # 80041950 <log+0x30>
    80004120:	05c50713          	addi	a4,a0,92
    80004124:	36fd                	addiw	a3,a3,-1
    80004126:	1682                	slli	a3,a3,0x20
    80004128:	9281                	srli	a3,a3,0x20
    8000412a:	068a                	slli	a3,a3,0x2
    8000412c:	0003e617          	auipc	a2,0x3e
    80004130:	82860613          	addi	a2,a2,-2008 # 80041954 <log+0x34>
    80004134:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004136:	4390                	lw	a2,0(a5)
    80004138:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000413a:	0791                	addi	a5,a5,4
    8000413c:	0711                	addi	a4,a4,4
    8000413e:	fed79ce3          	bne	a5,a3,80004136 <write_head+0x4e>
  }
  bwrite(buf);
    80004142:	8526                	mv	a0,s1
    80004144:	fffff097          	auipc	ra,0xfffff
    80004148:	0a6080e7          	jalr	166(ra) # 800031ea <bwrite>
  brelse(buf);
    8000414c:	8526                	mv	a0,s1
    8000414e:	fffff097          	auipc	ra,0xfffff
    80004152:	0da080e7          	jalr	218(ra) # 80003228 <brelse>
}
    80004156:	60e2                	ld	ra,24(sp)
    80004158:	6442                	ld	s0,16(sp)
    8000415a:	64a2                	ld	s1,8(sp)
    8000415c:	6902                	ld	s2,0(sp)
    8000415e:	6105                	addi	sp,sp,32
    80004160:	8082                	ret

0000000080004162 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004162:	0003d797          	auipc	a5,0x3d
    80004166:	7ea7a783          	lw	a5,2026(a5) # 8004194c <log+0x2c>
    8000416a:	0af05663          	blez	a5,80004216 <install_trans+0xb4>
{
    8000416e:	7139                	addi	sp,sp,-64
    80004170:	fc06                	sd	ra,56(sp)
    80004172:	f822                	sd	s0,48(sp)
    80004174:	f426                	sd	s1,40(sp)
    80004176:	f04a                	sd	s2,32(sp)
    80004178:	ec4e                	sd	s3,24(sp)
    8000417a:	e852                	sd	s4,16(sp)
    8000417c:	e456                	sd	s5,8(sp)
    8000417e:	0080                	addi	s0,sp,64
    80004180:	0003da97          	auipc	s5,0x3d
    80004184:	7d0a8a93          	addi	s5,s5,2000 # 80041950 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004188:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000418a:	0003d997          	auipc	s3,0x3d
    8000418e:	79698993          	addi	s3,s3,1942 # 80041920 <log>
    80004192:	0189a583          	lw	a1,24(s3)
    80004196:	014585bb          	addw	a1,a1,s4
    8000419a:	2585                	addiw	a1,a1,1
    8000419c:	0289a503          	lw	a0,40(s3)
    800041a0:	fffff097          	auipc	ra,0xfffff
    800041a4:	f58080e7          	jalr	-168(ra) # 800030f8 <bread>
    800041a8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041aa:	000aa583          	lw	a1,0(s5)
    800041ae:	0289a503          	lw	a0,40(s3)
    800041b2:	fffff097          	auipc	ra,0xfffff
    800041b6:	f46080e7          	jalr	-186(ra) # 800030f8 <bread>
    800041ba:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041bc:	40000613          	li	a2,1024
    800041c0:	05890593          	addi	a1,s2,88
    800041c4:	05850513          	addi	a0,a0,88
    800041c8:	ffffd097          	auipc	ra,0xffffd
    800041cc:	d2e080e7          	jalr	-722(ra) # 80000ef6 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041d0:	8526                	mv	a0,s1
    800041d2:	fffff097          	auipc	ra,0xfffff
    800041d6:	018080e7          	jalr	24(ra) # 800031ea <bwrite>
    bunpin(dbuf);
    800041da:	8526                	mv	a0,s1
    800041dc:	fffff097          	auipc	ra,0xfffff
    800041e0:	126080e7          	jalr	294(ra) # 80003302 <bunpin>
    brelse(lbuf);
    800041e4:	854a                	mv	a0,s2
    800041e6:	fffff097          	auipc	ra,0xfffff
    800041ea:	042080e7          	jalr	66(ra) # 80003228 <brelse>
    brelse(dbuf);
    800041ee:	8526                	mv	a0,s1
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	038080e7          	jalr	56(ra) # 80003228 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f8:	2a05                	addiw	s4,s4,1
    800041fa:	0a91                	addi	s5,s5,4
    800041fc:	02c9a783          	lw	a5,44(s3)
    80004200:	f8fa49e3          	blt	s4,a5,80004192 <install_trans+0x30>
}
    80004204:	70e2                	ld	ra,56(sp)
    80004206:	7442                	ld	s0,48(sp)
    80004208:	74a2                	ld	s1,40(sp)
    8000420a:	7902                	ld	s2,32(sp)
    8000420c:	69e2                	ld	s3,24(sp)
    8000420e:	6a42                	ld	s4,16(sp)
    80004210:	6aa2                	ld	s5,8(sp)
    80004212:	6121                	addi	sp,sp,64
    80004214:	8082                	ret
    80004216:	8082                	ret

0000000080004218 <initlog>:
{
    80004218:	7179                	addi	sp,sp,-48
    8000421a:	f406                	sd	ra,40(sp)
    8000421c:	f022                	sd	s0,32(sp)
    8000421e:	ec26                	sd	s1,24(sp)
    80004220:	e84a                	sd	s2,16(sp)
    80004222:	e44e                	sd	s3,8(sp)
    80004224:	1800                	addi	s0,sp,48
    80004226:	892a                	mv	s2,a0
    80004228:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000422a:	0003d497          	auipc	s1,0x3d
    8000422e:	6f648493          	addi	s1,s1,1782 # 80041920 <log>
    80004232:	00004597          	auipc	a1,0x4
    80004236:	40658593          	addi	a1,a1,1030 # 80008638 <syscalls+0x1d8>
    8000423a:	8526                	mv	a0,s1
    8000423c:	ffffd097          	auipc	ra,0xffffd
    80004240:	ace080e7          	jalr	-1330(ra) # 80000d0a <initlock>
  log.start = sb->logstart;
    80004244:	0149a583          	lw	a1,20(s3)
    80004248:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000424a:	0109a783          	lw	a5,16(s3)
    8000424e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004250:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004254:	854a                	mv	a0,s2
    80004256:	fffff097          	auipc	ra,0xfffff
    8000425a:	ea2080e7          	jalr	-350(ra) # 800030f8 <bread>
  log.lh.n = lh->n;
    8000425e:	4d3c                	lw	a5,88(a0)
    80004260:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004262:	02f05563          	blez	a5,8000428c <initlog+0x74>
    80004266:	05c50713          	addi	a4,a0,92
    8000426a:	0003d697          	auipc	a3,0x3d
    8000426e:	6e668693          	addi	a3,a3,1766 # 80041950 <log+0x30>
    80004272:	37fd                	addiw	a5,a5,-1
    80004274:	1782                	slli	a5,a5,0x20
    80004276:	9381                	srli	a5,a5,0x20
    80004278:	078a                	slli	a5,a5,0x2
    8000427a:	06050613          	addi	a2,a0,96
    8000427e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004280:	4310                	lw	a2,0(a4)
    80004282:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004284:	0711                	addi	a4,a4,4
    80004286:	0691                	addi	a3,a3,4
    80004288:	fef71ce3          	bne	a4,a5,80004280 <initlog+0x68>
  brelse(buf);
    8000428c:	fffff097          	auipc	ra,0xfffff
    80004290:	f9c080e7          	jalr	-100(ra) # 80003228 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004294:	00000097          	auipc	ra,0x0
    80004298:	ece080e7          	jalr	-306(ra) # 80004162 <install_trans>
  log.lh.n = 0;
    8000429c:	0003d797          	auipc	a5,0x3d
    800042a0:	6a07a823          	sw	zero,1712(a5) # 8004194c <log+0x2c>
  write_head(); // clear the log
    800042a4:	00000097          	auipc	ra,0x0
    800042a8:	e44080e7          	jalr	-444(ra) # 800040e8 <write_head>
}
    800042ac:	70a2                	ld	ra,40(sp)
    800042ae:	7402                	ld	s0,32(sp)
    800042b0:	64e2                	ld	s1,24(sp)
    800042b2:	6942                	ld	s2,16(sp)
    800042b4:	69a2                	ld	s3,8(sp)
    800042b6:	6145                	addi	sp,sp,48
    800042b8:	8082                	ret

00000000800042ba <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042ba:	1101                	addi	sp,sp,-32
    800042bc:	ec06                	sd	ra,24(sp)
    800042be:	e822                	sd	s0,16(sp)
    800042c0:	e426                	sd	s1,8(sp)
    800042c2:	e04a                	sd	s2,0(sp)
    800042c4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042c6:	0003d517          	auipc	a0,0x3d
    800042ca:	65a50513          	addi	a0,a0,1626 # 80041920 <log>
    800042ce:	ffffd097          	auipc	ra,0xffffd
    800042d2:	acc080e7          	jalr	-1332(ra) # 80000d9a <acquire>
  while(1){
    if(log.committing){
    800042d6:	0003d497          	auipc	s1,0x3d
    800042da:	64a48493          	addi	s1,s1,1610 # 80041920 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042de:	4979                	li	s2,30
    800042e0:	a039                	j	800042ee <begin_op+0x34>
      sleep(&log, &log.lock);
    800042e2:	85a6                	mv	a1,s1
    800042e4:	8526                	mv	a0,s1
    800042e6:	ffffe097          	auipc	ra,0xffffe
    800042ea:	1b0080e7          	jalr	432(ra) # 80002496 <sleep>
    if(log.committing){
    800042ee:	50dc                	lw	a5,36(s1)
    800042f0:	fbed                	bnez	a5,800042e2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042f2:	509c                	lw	a5,32(s1)
    800042f4:	0017871b          	addiw	a4,a5,1
    800042f8:	0007069b          	sext.w	a3,a4
    800042fc:	0027179b          	slliw	a5,a4,0x2
    80004300:	9fb9                	addw	a5,a5,a4
    80004302:	0017979b          	slliw	a5,a5,0x1
    80004306:	54d8                	lw	a4,44(s1)
    80004308:	9fb9                	addw	a5,a5,a4
    8000430a:	00f95963          	bge	s2,a5,8000431c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000430e:	85a6                	mv	a1,s1
    80004310:	8526                	mv	a0,s1
    80004312:	ffffe097          	auipc	ra,0xffffe
    80004316:	184080e7          	jalr	388(ra) # 80002496 <sleep>
    8000431a:	bfd1                	j	800042ee <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000431c:	0003d517          	auipc	a0,0x3d
    80004320:	60450513          	addi	a0,a0,1540 # 80041920 <log>
    80004324:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004326:	ffffd097          	auipc	ra,0xffffd
    8000432a:	b28080e7          	jalr	-1240(ra) # 80000e4e <release>
      break;
    }
  }
}
    8000432e:	60e2                	ld	ra,24(sp)
    80004330:	6442                	ld	s0,16(sp)
    80004332:	64a2                	ld	s1,8(sp)
    80004334:	6902                	ld	s2,0(sp)
    80004336:	6105                	addi	sp,sp,32
    80004338:	8082                	ret

000000008000433a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000433a:	7139                	addi	sp,sp,-64
    8000433c:	fc06                	sd	ra,56(sp)
    8000433e:	f822                	sd	s0,48(sp)
    80004340:	f426                	sd	s1,40(sp)
    80004342:	f04a                	sd	s2,32(sp)
    80004344:	ec4e                	sd	s3,24(sp)
    80004346:	e852                	sd	s4,16(sp)
    80004348:	e456                	sd	s5,8(sp)
    8000434a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000434c:	0003d497          	auipc	s1,0x3d
    80004350:	5d448493          	addi	s1,s1,1492 # 80041920 <log>
    80004354:	8526                	mv	a0,s1
    80004356:	ffffd097          	auipc	ra,0xffffd
    8000435a:	a44080e7          	jalr	-1468(ra) # 80000d9a <acquire>
  log.outstanding -= 1;
    8000435e:	509c                	lw	a5,32(s1)
    80004360:	37fd                	addiw	a5,a5,-1
    80004362:	0007891b          	sext.w	s2,a5
    80004366:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004368:	50dc                	lw	a5,36(s1)
    8000436a:	efb9                	bnez	a5,800043c8 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000436c:	06091663          	bnez	s2,800043d8 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004370:	0003d497          	auipc	s1,0x3d
    80004374:	5b048493          	addi	s1,s1,1456 # 80041920 <log>
    80004378:	4785                	li	a5,1
    8000437a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000437c:	8526                	mv	a0,s1
    8000437e:	ffffd097          	auipc	ra,0xffffd
    80004382:	ad0080e7          	jalr	-1328(ra) # 80000e4e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004386:	54dc                	lw	a5,44(s1)
    80004388:	06f04763          	bgtz	a5,800043f6 <end_op+0xbc>
    acquire(&log.lock);
    8000438c:	0003d497          	auipc	s1,0x3d
    80004390:	59448493          	addi	s1,s1,1428 # 80041920 <log>
    80004394:	8526                	mv	a0,s1
    80004396:	ffffd097          	auipc	ra,0xffffd
    8000439a:	a04080e7          	jalr	-1532(ra) # 80000d9a <acquire>
    log.committing = 0;
    8000439e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043a2:	8526                	mv	a0,s1
    800043a4:	ffffe097          	auipc	ra,0xffffe
    800043a8:	278080e7          	jalr	632(ra) # 8000261c <wakeup>
    release(&log.lock);
    800043ac:	8526                	mv	a0,s1
    800043ae:	ffffd097          	auipc	ra,0xffffd
    800043b2:	aa0080e7          	jalr	-1376(ra) # 80000e4e <release>
}
    800043b6:	70e2                	ld	ra,56(sp)
    800043b8:	7442                	ld	s0,48(sp)
    800043ba:	74a2                	ld	s1,40(sp)
    800043bc:	7902                	ld	s2,32(sp)
    800043be:	69e2                	ld	s3,24(sp)
    800043c0:	6a42                	ld	s4,16(sp)
    800043c2:	6aa2                	ld	s5,8(sp)
    800043c4:	6121                	addi	sp,sp,64
    800043c6:	8082                	ret
    panic("log.committing");
    800043c8:	00004517          	auipc	a0,0x4
    800043cc:	27850513          	addi	a0,a0,632 # 80008640 <syscalls+0x1e0>
    800043d0:	ffffc097          	auipc	ra,0xffffc
    800043d4:	178080e7          	jalr	376(ra) # 80000548 <panic>
    wakeup(&log);
    800043d8:	0003d497          	auipc	s1,0x3d
    800043dc:	54848493          	addi	s1,s1,1352 # 80041920 <log>
    800043e0:	8526                	mv	a0,s1
    800043e2:	ffffe097          	auipc	ra,0xffffe
    800043e6:	23a080e7          	jalr	570(ra) # 8000261c <wakeup>
  release(&log.lock);
    800043ea:	8526                	mv	a0,s1
    800043ec:	ffffd097          	auipc	ra,0xffffd
    800043f0:	a62080e7          	jalr	-1438(ra) # 80000e4e <release>
  if(do_commit){
    800043f4:	b7c9                	j	800043b6 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043f6:	0003da97          	auipc	s5,0x3d
    800043fa:	55aa8a93          	addi	s5,s5,1370 # 80041950 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043fe:	0003da17          	auipc	s4,0x3d
    80004402:	522a0a13          	addi	s4,s4,1314 # 80041920 <log>
    80004406:	018a2583          	lw	a1,24(s4)
    8000440a:	012585bb          	addw	a1,a1,s2
    8000440e:	2585                	addiw	a1,a1,1
    80004410:	028a2503          	lw	a0,40(s4)
    80004414:	fffff097          	auipc	ra,0xfffff
    80004418:	ce4080e7          	jalr	-796(ra) # 800030f8 <bread>
    8000441c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000441e:	000aa583          	lw	a1,0(s5)
    80004422:	028a2503          	lw	a0,40(s4)
    80004426:	fffff097          	auipc	ra,0xfffff
    8000442a:	cd2080e7          	jalr	-814(ra) # 800030f8 <bread>
    8000442e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004430:	40000613          	li	a2,1024
    80004434:	05850593          	addi	a1,a0,88
    80004438:	05848513          	addi	a0,s1,88
    8000443c:	ffffd097          	auipc	ra,0xffffd
    80004440:	aba080e7          	jalr	-1350(ra) # 80000ef6 <memmove>
    bwrite(to);  // write the log
    80004444:	8526                	mv	a0,s1
    80004446:	fffff097          	auipc	ra,0xfffff
    8000444a:	da4080e7          	jalr	-604(ra) # 800031ea <bwrite>
    brelse(from);
    8000444e:	854e                	mv	a0,s3
    80004450:	fffff097          	auipc	ra,0xfffff
    80004454:	dd8080e7          	jalr	-552(ra) # 80003228 <brelse>
    brelse(to);
    80004458:	8526                	mv	a0,s1
    8000445a:	fffff097          	auipc	ra,0xfffff
    8000445e:	dce080e7          	jalr	-562(ra) # 80003228 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004462:	2905                	addiw	s2,s2,1
    80004464:	0a91                	addi	s5,s5,4
    80004466:	02ca2783          	lw	a5,44(s4)
    8000446a:	f8f94ee3          	blt	s2,a5,80004406 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000446e:	00000097          	auipc	ra,0x0
    80004472:	c7a080e7          	jalr	-902(ra) # 800040e8 <write_head>
    install_trans(); // Now install writes to home locations
    80004476:	00000097          	auipc	ra,0x0
    8000447a:	cec080e7          	jalr	-788(ra) # 80004162 <install_trans>
    log.lh.n = 0;
    8000447e:	0003d797          	auipc	a5,0x3d
    80004482:	4c07a723          	sw	zero,1230(a5) # 8004194c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004486:	00000097          	auipc	ra,0x0
    8000448a:	c62080e7          	jalr	-926(ra) # 800040e8 <write_head>
    8000448e:	bdfd                	j	8000438c <end_op+0x52>

0000000080004490 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004490:	1101                	addi	sp,sp,-32
    80004492:	ec06                	sd	ra,24(sp)
    80004494:	e822                	sd	s0,16(sp)
    80004496:	e426                	sd	s1,8(sp)
    80004498:	e04a                	sd	s2,0(sp)
    8000449a:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000449c:	0003d717          	auipc	a4,0x3d
    800044a0:	4b072703          	lw	a4,1200(a4) # 8004194c <log+0x2c>
    800044a4:	47f5                	li	a5,29
    800044a6:	08e7c063          	blt	a5,a4,80004526 <log_write+0x96>
    800044aa:	84aa                	mv	s1,a0
    800044ac:	0003d797          	auipc	a5,0x3d
    800044b0:	4907a783          	lw	a5,1168(a5) # 8004193c <log+0x1c>
    800044b4:	37fd                	addiw	a5,a5,-1
    800044b6:	06f75863          	bge	a4,a5,80004526 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044ba:	0003d797          	auipc	a5,0x3d
    800044be:	4867a783          	lw	a5,1158(a5) # 80041940 <log+0x20>
    800044c2:	06f05a63          	blez	a5,80004536 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800044c6:	0003d917          	auipc	s2,0x3d
    800044ca:	45a90913          	addi	s2,s2,1114 # 80041920 <log>
    800044ce:	854a                	mv	a0,s2
    800044d0:	ffffd097          	auipc	ra,0xffffd
    800044d4:	8ca080e7          	jalr	-1846(ra) # 80000d9a <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800044d8:	02c92603          	lw	a2,44(s2)
    800044dc:	06c05563          	blez	a2,80004546 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800044e0:	44cc                	lw	a1,12(s1)
    800044e2:	0003d717          	auipc	a4,0x3d
    800044e6:	46e70713          	addi	a4,a4,1134 # 80041950 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044ea:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800044ec:	4314                	lw	a3,0(a4)
    800044ee:	04b68d63          	beq	a3,a1,80004548 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800044f2:	2785                	addiw	a5,a5,1
    800044f4:	0711                	addi	a4,a4,4
    800044f6:	fec79be3          	bne	a5,a2,800044ec <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044fa:	0621                	addi	a2,a2,8
    800044fc:	060a                	slli	a2,a2,0x2
    800044fe:	0003d797          	auipc	a5,0x3d
    80004502:	42278793          	addi	a5,a5,1058 # 80041920 <log>
    80004506:	963e                	add	a2,a2,a5
    80004508:	44dc                	lw	a5,12(s1)
    8000450a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000450c:	8526                	mv	a0,s1
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	db8080e7          	jalr	-584(ra) # 800032c6 <bpin>
    log.lh.n++;
    80004516:	0003d717          	auipc	a4,0x3d
    8000451a:	40a70713          	addi	a4,a4,1034 # 80041920 <log>
    8000451e:	575c                	lw	a5,44(a4)
    80004520:	2785                	addiw	a5,a5,1
    80004522:	d75c                	sw	a5,44(a4)
    80004524:	a83d                	j	80004562 <log_write+0xd2>
    panic("too big a transaction");
    80004526:	00004517          	auipc	a0,0x4
    8000452a:	12a50513          	addi	a0,a0,298 # 80008650 <syscalls+0x1f0>
    8000452e:	ffffc097          	auipc	ra,0xffffc
    80004532:	01a080e7          	jalr	26(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    80004536:	00004517          	auipc	a0,0x4
    8000453a:	13250513          	addi	a0,a0,306 # 80008668 <syscalls+0x208>
    8000453e:	ffffc097          	auipc	ra,0xffffc
    80004542:	00a080e7          	jalr	10(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004546:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004548:	00878713          	addi	a4,a5,8
    8000454c:	00271693          	slli	a3,a4,0x2
    80004550:	0003d717          	auipc	a4,0x3d
    80004554:	3d070713          	addi	a4,a4,976 # 80041920 <log>
    80004558:	9736                	add	a4,a4,a3
    8000455a:	44d4                	lw	a3,12(s1)
    8000455c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000455e:	faf607e3          	beq	a2,a5,8000450c <log_write+0x7c>
  }
  release(&log.lock);
    80004562:	0003d517          	auipc	a0,0x3d
    80004566:	3be50513          	addi	a0,a0,958 # 80041920 <log>
    8000456a:	ffffd097          	auipc	ra,0xffffd
    8000456e:	8e4080e7          	jalr	-1820(ra) # 80000e4e <release>
}
    80004572:	60e2                	ld	ra,24(sp)
    80004574:	6442                	ld	s0,16(sp)
    80004576:	64a2                	ld	s1,8(sp)
    80004578:	6902                	ld	s2,0(sp)
    8000457a:	6105                	addi	sp,sp,32
    8000457c:	8082                	ret

000000008000457e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000457e:	1101                	addi	sp,sp,-32
    80004580:	ec06                	sd	ra,24(sp)
    80004582:	e822                	sd	s0,16(sp)
    80004584:	e426                	sd	s1,8(sp)
    80004586:	e04a                	sd	s2,0(sp)
    80004588:	1000                	addi	s0,sp,32
    8000458a:	84aa                	mv	s1,a0
    8000458c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000458e:	00004597          	auipc	a1,0x4
    80004592:	0fa58593          	addi	a1,a1,250 # 80008688 <syscalls+0x228>
    80004596:	0521                	addi	a0,a0,8
    80004598:	ffffc097          	auipc	ra,0xffffc
    8000459c:	772080e7          	jalr	1906(ra) # 80000d0a <initlock>
  lk->name = name;
    800045a0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045a8:	0204a423          	sw	zero,40(s1)
}
    800045ac:	60e2                	ld	ra,24(sp)
    800045ae:	6442                	ld	s0,16(sp)
    800045b0:	64a2                	ld	s1,8(sp)
    800045b2:	6902                	ld	s2,0(sp)
    800045b4:	6105                	addi	sp,sp,32
    800045b6:	8082                	ret

00000000800045b8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045b8:	1101                	addi	sp,sp,-32
    800045ba:	ec06                	sd	ra,24(sp)
    800045bc:	e822                	sd	s0,16(sp)
    800045be:	e426                	sd	s1,8(sp)
    800045c0:	e04a                	sd	s2,0(sp)
    800045c2:	1000                	addi	s0,sp,32
    800045c4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045c6:	00850913          	addi	s2,a0,8
    800045ca:	854a                	mv	a0,s2
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	7ce080e7          	jalr	1998(ra) # 80000d9a <acquire>
  while (lk->locked) {
    800045d4:	409c                	lw	a5,0(s1)
    800045d6:	cb89                	beqz	a5,800045e8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045d8:	85ca                	mv	a1,s2
    800045da:	8526                	mv	a0,s1
    800045dc:	ffffe097          	auipc	ra,0xffffe
    800045e0:	eba080e7          	jalr	-326(ra) # 80002496 <sleep>
  while (lk->locked) {
    800045e4:	409c                	lw	a5,0(s1)
    800045e6:	fbed                	bnez	a5,800045d8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045e8:	4785                	li	a5,1
    800045ea:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045ec:	ffffd097          	auipc	ra,0xffffd
    800045f0:	69a080e7          	jalr	1690(ra) # 80001c86 <myproc>
    800045f4:	5d1c                	lw	a5,56(a0)
    800045f6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045f8:	854a                	mv	a0,s2
    800045fa:	ffffd097          	auipc	ra,0xffffd
    800045fe:	854080e7          	jalr	-1964(ra) # 80000e4e <release>
}
    80004602:	60e2                	ld	ra,24(sp)
    80004604:	6442                	ld	s0,16(sp)
    80004606:	64a2                	ld	s1,8(sp)
    80004608:	6902                	ld	s2,0(sp)
    8000460a:	6105                	addi	sp,sp,32
    8000460c:	8082                	ret

000000008000460e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000460e:	1101                	addi	sp,sp,-32
    80004610:	ec06                	sd	ra,24(sp)
    80004612:	e822                	sd	s0,16(sp)
    80004614:	e426                	sd	s1,8(sp)
    80004616:	e04a                	sd	s2,0(sp)
    80004618:	1000                	addi	s0,sp,32
    8000461a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000461c:	00850913          	addi	s2,a0,8
    80004620:	854a                	mv	a0,s2
    80004622:	ffffc097          	auipc	ra,0xffffc
    80004626:	778080e7          	jalr	1912(ra) # 80000d9a <acquire>
  lk->locked = 0;
    8000462a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000462e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004632:	8526                	mv	a0,s1
    80004634:	ffffe097          	auipc	ra,0xffffe
    80004638:	fe8080e7          	jalr	-24(ra) # 8000261c <wakeup>
  release(&lk->lk);
    8000463c:	854a                	mv	a0,s2
    8000463e:	ffffd097          	auipc	ra,0xffffd
    80004642:	810080e7          	jalr	-2032(ra) # 80000e4e <release>
}
    80004646:	60e2                	ld	ra,24(sp)
    80004648:	6442                	ld	s0,16(sp)
    8000464a:	64a2                	ld	s1,8(sp)
    8000464c:	6902                	ld	s2,0(sp)
    8000464e:	6105                	addi	sp,sp,32
    80004650:	8082                	ret

0000000080004652 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004652:	7179                	addi	sp,sp,-48
    80004654:	f406                	sd	ra,40(sp)
    80004656:	f022                	sd	s0,32(sp)
    80004658:	ec26                	sd	s1,24(sp)
    8000465a:	e84a                	sd	s2,16(sp)
    8000465c:	e44e                	sd	s3,8(sp)
    8000465e:	1800                	addi	s0,sp,48
    80004660:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004662:	00850913          	addi	s2,a0,8
    80004666:	854a                	mv	a0,s2
    80004668:	ffffc097          	auipc	ra,0xffffc
    8000466c:	732080e7          	jalr	1842(ra) # 80000d9a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004670:	409c                	lw	a5,0(s1)
    80004672:	ef99                	bnez	a5,80004690 <holdingsleep+0x3e>
    80004674:	4481                	li	s1,0
  release(&lk->lk);
    80004676:	854a                	mv	a0,s2
    80004678:	ffffc097          	auipc	ra,0xffffc
    8000467c:	7d6080e7          	jalr	2006(ra) # 80000e4e <release>
  return r;
}
    80004680:	8526                	mv	a0,s1
    80004682:	70a2                	ld	ra,40(sp)
    80004684:	7402                	ld	s0,32(sp)
    80004686:	64e2                	ld	s1,24(sp)
    80004688:	6942                	ld	s2,16(sp)
    8000468a:	69a2                	ld	s3,8(sp)
    8000468c:	6145                	addi	sp,sp,48
    8000468e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004690:	0284a983          	lw	s3,40(s1)
    80004694:	ffffd097          	auipc	ra,0xffffd
    80004698:	5f2080e7          	jalr	1522(ra) # 80001c86 <myproc>
    8000469c:	5d04                	lw	s1,56(a0)
    8000469e:	413484b3          	sub	s1,s1,s3
    800046a2:	0014b493          	seqz	s1,s1
    800046a6:	bfc1                	j	80004676 <holdingsleep+0x24>

00000000800046a8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046a8:	1141                	addi	sp,sp,-16
    800046aa:	e406                	sd	ra,8(sp)
    800046ac:	e022                	sd	s0,0(sp)
    800046ae:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046b0:	00004597          	auipc	a1,0x4
    800046b4:	fe858593          	addi	a1,a1,-24 # 80008698 <syscalls+0x238>
    800046b8:	0003d517          	auipc	a0,0x3d
    800046bc:	3b050513          	addi	a0,a0,944 # 80041a68 <ftable>
    800046c0:	ffffc097          	auipc	ra,0xffffc
    800046c4:	64a080e7          	jalr	1610(ra) # 80000d0a <initlock>
}
    800046c8:	60a2                	ld	ra,8(sp)
    800046ca:	6402                	ld	s0,0(sp)
    800046cc:	0141                	addi	sp,sp,16
    800046ce:	8082                	ret

00000000800046d0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046d0:	1101                	addi	sp,sp,-32
    800046d2:	ec06                	sd	ra,24(sp)
    800046d4:	e822                	sd	s0,16(sp)
    800046d6:	e426                	sd	s1,8(sp)
    800046d8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046da:	0003d517          	auipc	a0,0x3d
    800046de:	38e50513          	addi	a0,a0,910 # 80041a68 <ftable>
    800046e2:	ffffc097          	auipc	ra,0xffffc
    800046e6:	6b8080e7          	jalr	1720(ra) # 80000d9a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046ea:	0003d497          	auipc	s1,0x3d
    800046ee:	39648493          	addi	s1,s1,918 # 80041a80 <ftable+0x18>
    800046f2:	0003e717          	auipc	a4,0x3e
    800046f6:	32e70713          	addi	a4,a4,814 # 80042a20 <ftable+0xfb8>
    if(f->ref == 0){
    800046fa:	40dc                	lw	a5,4(s1)
    800046fc:	cf99                	beqz	a5,8000471a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046fe:	02848493          	addi	s1,s1,40
    80004702:	fee49ce3          	bne	s1,a4,800046fa <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004706:	0003d517          	auipc	a0,0x3d
    8000470a:	36250513          	addi	a0,a0,866 # 80041a68 <ftable>
    8000470e:	ffffc097          	auipc	ra,0xffffc
    80004712:	740080e7          	jalr	1856(ra) # 80000e4e <release>
  return 0;
    80004716:	4481                	li	s1,0
    80004718:	a819                	j	8000472e <filealloc+0x5e>
      f->ref = 1;
    8000471a:	4785                	li	a5,1
    8000471c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000471e:	0003d517          	auipc	a0,0x3d
    80004722:	34a50513          	addi	a0,a0,842 # 80041a68 <ftable>
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	728080e7          	jalr	1832(ra) # 80000e4e <release>
}
    8000472e:	8526                	mv	a0,s1
    80004730:	60e2                	ld	ra,24(sp)
    80004732:	6442                	ld	s0,16(sp)
    80004734:	64a2                	ld	s1,8(sp)
    80004736:	6105                	addi	sp,sp,32
    80004738:	8082                	ret

000000008000473a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000473a:	1101                	addi	sp,sp,-32
    8000473c:	ec06                	sd	ra,24(sp)
    8000473e:	e822                	sd	s0,16(sp)
    80004740:	e426                	sd	s1,8(sp)
    80004742:	1000                	addi	s0,sp,32
    80004744:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004746:	0003d517          	auipc	a0,0x3d
    8000474a:	32250513          	addi	a0,a0,802 # 80041a68 <ftable>
    8000474e:	ffffc097          	auipc	ra,0xffffc
    80004752:	64c080e7          	jalr	1612(ra) # 80000d9a <acquire>
  if(f->ref < 1)
    80004756:	40dc                	lw	a5,4(s1)
    80004758:	02f05263          	blez	a5,8000477c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000475c:	2785                	addiw	a5,a5,1
    8000475e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004760:	0003d517          	auipc	a0,0x3d
    80004764:	30850513          	addi	a0,a0,776 # 80041a68 <ftable>
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	6e6080e7          	jalr	1766(ra) # 80000e4e <release>
  return f;
}
    80004770:	8526                	mv	a0,s1
    80004772:	60e2                	ld	ra,24(sp)
    80004774:	6442                	ld	s0,16(sp)
    80004776:	64a2                	ld	s1,8(sp)
    80004778:	6105                	addi	sp,sp,32
    8000477a:	8082                	ret
    panic("filedup");
    8000477c:	00004517          	auipc	a0,0x4
    80004780:	f2450513          	addi	a0,a0,-220 # 800086a0 <syscalls+0x240>
    80004784:	ffffc097          	auipc	ra,0xffffc
    80004788:	dc4080e7          	jalr	-572(ra) # 80000548 <panic>

000000008000478c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000478c:	7139                	addi	sp,sp,-64
    8000478e:	fc06                	sd	ra,56(sp)
    80004790:	f822                	sd	s0,48(sp)
    80004792:	f426                	sd	s1,40(sp)
    80004794:	f04a                	sd	s2,32(sp)
    80004796:	ec4e                	sd	s3,24(sp)
    80004798:	e852                	sd	s4,16(sp)
    8000479a:	e456                	sd	s5,8(sp)
    8000479c:	0080                	addi	s0,sp,64
    8000479e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047a0:	0003d517          	auipc	a0,0x3d
    800047a4:	2c850513          	addi	a0,a0,712 # 80041a68 <ftable>
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	5f2080e7          	jalr	1522(ra) # 80000d9a <acquire>
  if(f->ref < 1)
    800047b0:	40dc                	lw	a5,4(s1)
    800047b2:	06f05163          	blez	a5,80004814 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047b6:	37fd                	addiw	a5,a5,-1
    800047b8:	0007871b          	sext.w	a4,a5
    800047bc:	c0dc                	sw	a5,4(s1)
    800047be:	06e04363          	bgtz	a4,80004824 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047c2:	0004a903          	lw	s2,0(s1)
    800047c6:	0094ca83          	lbu	s5,9(s1)
    800047ca:	0104ba03          	ld	s4,16(s1)
    800047ce:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047d2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047d6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047da:	0003d517          	auipc	a0,0x3d
    800047de:	28e50513          	addi	a0,a0,654 # 80041a68 <ftable>
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	66c080e7          	jalr	1644(ra) # 80000e4e <release>

  if(ff.type == FD_PIPE){
    800047ea:	4785                	li	a5,1
    800047ec:	04f90d63          	beq	s2,a5,80004846 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047f0:	3979                	addiw	s2,s2,-2
    800047f2:	4785                	li	a5,1
    800047f4:	0527e063          	bltu	a5,s2,80004834 <fileclose+0xa8>
    begin_op();
    800047f8:	00000097          	auipc	ra,0x0
    800047fc:	ac2080e7          	jalr	-1342(ra) # 800042ba <begin_op>
    iput(ff.ip);
    80004800:	854e                	mv	a0,s3
    80004802:	fffff097          	auipc	ra,0xfffff
    80004806:	2b2080e7          	jalr	690(ra) # 80003ab4 <iput>
    end_op();
    8000480a:	00000097          	auipc	ra,0x0
    8000480e:	b30080e7          	jalr	-1232(ra) # 8000433a <end_op>
    80004812:	a00d                	j	80004834 <fileclose+0xa8>
    panic("fileclose");
    80004814:	00004517          	auipc	a0,0x4
    80004818:	e9450513          	addi	a0,a0,-364 # 800086a8 <syscalls+0x248>
    8000481c:	ffffc097          	auipc	ra,0xffffc
    80004820:	d2c080e7          	jalr	-724(ra) # 80000548 <panic>
    release(&ftable.lock);
    80004824:	0003d517          	auipc	a0,0x3d
    80004828:	24450513          	addi	a0,a0,580 # 80041a68 <ftable>
    8000482c:	ffffc097          	auipc	ra,0xffffc
    80004830:	622080e7          	jalr	1570(ra) # 80000e4e <release>
  }
}
    80004834:	70e2                	ld	ra,56(sp)
    80004836:	7442                	ld	s0,48(sp)
    80004838:	74a2                	ld	s1,40(sp)
    8000483a:	7902                	ld	s2,32(sp)
    8000483c:	69e2                	ld	s3,24(sp)
    8000483e:	6a42                	ld	s4,16(sp)
    80004840:	6aa2                	ld	s5,8(sp)
    80004842:	6121                	addi	sp,sp,64
    80004844:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004846:	85d6                	mv	a1,s5
    80004848:	8552                	mv	a0,s4
    8000484a:	00000097          	auipc	ra,0x0
    8000484e:	372080e7          	jalr	882(ra) # 80004bbc <pipeclose>
    80004852:	b7cd                	j	80004834 <fileclose+0xa8>

0000000080004854 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004854:	715d                	addi	sp,sp,-80
    80004856:	e486                	sd	ra,72(sp)
    80004858:	e0a2                	sd	s0,64(sp)
    8000485a:	fc26                	sd	s1,56(sp)
    8000485c:	f84a                	sd	s2,48(sp)
    8000485e:	f44e                	sd	s3,40(sp)
    80004860:	0880                	addi	s0,sp,80
    80004862:	84aa                	mv	s1,a0
    80004864:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004866:	ffffd097          	auipc	ra,0xffffd
    8000486a:	420080e7          	jalr	1056(ra) # 80001c86 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000486e:	409c                	lw	a5,0(s1)
    80004870:	37f9                	addiw	a5,a5,-2
    80004872:	4705                	li	a4,1
    80004874:	04f76763          	bltu	a4,a5,800048c2 <filestat+0x6e>
    80004878:	892a                	mv	s2,a0
    ilock(f->ip);
    8000487a:	6c88                	ld	a0,24(s1)
    8000487c:	fffff097          	auipc	ra,0xfffff
    80004880:	07e080e7          	jalr	126(ra) # 800038fa <ilock>
    stati(f->ip, &st);
    80004884:	fb840593          	addi	a1,s0,-72
    80004888:	6c88                	ld	a0,24(s1)
    8000488a:	fffff097          	auipc	ra,0xfffff
    8000488e:	2fa080e7          	jalr	762(ra) # 80003b84 <stati>
    iunlock(f->ip);
    80004892:	6c88                	ld	a0,24(s1)
    80004894:	fffff097          	auipc	ra,0xfffff
    80004898:	128080e7          	jalr	296(ra) # 800039bc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000489c:	46e1                	li	a3,24
    8000489e:	fb840613          	addi	a2,s0,-72
    800048a2:	85ce                	mv	a1,s3
    800048a4:	05093503          	ld	a0,80(s2)
    800048a8:	ffffd097          	auipc	ra,0xffffd
    800048ac:	1fa080e7          	jalr	506(ra) # 80001aa2 <copyout>
    800048b0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048b4:	60a6                	ld	ra,72(sp)
    800048b6:	6406                	ld	s0,64(sp)
    800048b8:	74e2                	ld	s1,56(sp)
    800048ba:	7942                	ld	s2,48(sp)
    800048bc:	79a2                	ld	s3,40(sp)
    800048be:	6161                	addi	sp,sp,80
    800048c0:	8082                	ret
  return -1;
    800048c2:	557d                	li	a0,-1
    800048c4:	bfc5                	j	800048b4 <filestat+0x60>

00000000800048c6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048c6:	7179                	addi	sp,sp,-48
    800048c8:	f406                	sd	ra,40(sp)
    800048ca:	f022                	sd	s0,32(sp)
    800048cc:	ec26                	sd	s1,24(sp)
    800048ce:	e84a                	sd	s2,16(sp)
    800048d0:	e44e                	sd	s3,8(sp)
    800048d2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048d4:	00854783          	lbu	a5,8(a0)
    800048d8:	c3d5                	beqz	a5,8000497c <fileread+0xb6>
    800048da:	84aa                	mv	s1,a0
    800048dc:	89ae                	mv	s3,a1
    800048de:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048e0:	411c                	lw	a5,0(a0)
    800048e2:	4705                	li	a4,1
    800048e4:	04e78963          	beq	a5,a4,80004936 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048e8:	470d                	li	a4,3
    800048ea:	04e78d63          	beq	a5,a4,80004944 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048ee:	4709                	li	a4,2
    800048f0:	06e79e63          	bne	a5,a4,8000496c <fileread+0xa6>
    ilock(f->ip);
    800048f4:	6d08                	ld	a0,24(a0)
    800048f6:	fffff097          	auipc	ra,0xfffff
    800048fa:	004080e7          	jalr	4(ra) # 800038fa <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048fe:	874a                	mv	a4,s2
    80004900:	5094                	lw	a3,32(s1)
    80004902:	864e                	mv	a2,s3
    80004904:	4585                	li	a1,1
    80004906:	6c88                	ld	a0,24(s1)
    80004908:	fffff097          	auipc	ra,0xfffff
    8000490c:	2a6080e7          	jalr	678(ra) # 80003bae <readi>
    80004910:	892a                	mv	s2,a0
    80004912:	00a05563          	blez	a0,8000491c <fileread+0x56>
      f->off += r;
    80004916:	509c                	lw	a5,32(s1)
    80004918:	9fa9                	addw	a5,a5,a0
    8000491a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000491c:	6c88                	ld	a0,24(s1)
    8000491e:	fffff097          	auipc	ra,0xfffff
    80004922:	09e080e7          	jalr	158(ra) # 800039bc <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004926:	854a                	mv	a0,s2
    80004928:	70a2                	ld	ra,40(sp)
    8000492a:	7402                	ld	s0,32(sp)
    8000492c:	64e2                	ld	s1,24(sp)
    8000492e:	6942                	ld	s2,16(sp)
    80004930:	69a2                	ld	s3,8(sp)
    80004932:	6145                	addi	sp,sp,48
    80004934:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004936:	6908                	ld	a0,16(a0)
    80004938:	00000097          	auipc	ra,0x0
    8000493c:	418080e7          	jalr	1048(ra) # 80004d50 <piperead>
    80004940:	892a                	mv	s2,a0
    80004942:	b7d5                	j	80004926 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004944:	02451783          	lh	a5,36(a0)
    80004948:	03079693          	slli	a3,a5,0x30
    8000494c:	92c1                	srli	a3,a3,0x30
    8000494e:	4725                	li	a4,9
    80004950:	02d76863          	bltu	a4,a3,80004980 <fileread+0xba>
    80004954:	0792                	slli	a5,a5,0x4
    80004956:	0003d717          	auipc	a4,0x3d
    8000495a:	07270713          	addi	a4,a4,114 # 800419c8 <devsw>
    8000495e:	97ba                	add	a5,a5,a4
    80004960:	639c                	ld	a5,0(a5)
    80004962:	c38d                	beqz	a5,80004984 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004964:	4505                	li	a0,1
    80004966:	9782                	jalr	a5
    80004968:	892a                	mv	s2,a0
    8000496a:	bf75                	j	80004926 <fileread+0x60>
    panic("fileread");
    8000496c:	00004517          	auipc	a0,0x4
    80004970:	d4c50513          	addi	a0,a0,-692 # 800086b8 <syscalls+0x258>
    80004974:	ffffc097          	auipc	ra,0xffffc
    80004978:	bd4080e7          	jalr	-1068(ra) # 80000548 <panic>
    return -1;
    8000497c:	597d                	li	s2,-1
    8000497e:	b765                	j	80004926 <fileread+0x60>
      return -1;
    80004980:	597d                	li	s2,-1
    80004982:	b755                	j	80004926 <fileread+0x60>
    80004984:	597d                	li	s2,-1
    80004986:	b745                	j	80004926 <fileread+0x60>

0000000080004988 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004988:	00954783          	lbu	a5,9(a0)
    8000498c:	14078563          	beqz	a5,80004ad6 <filewrite+0x14e>
{
    80004990:	715d                	addi	sp,sp,-80
    80004992:	e486                	sd	ra,72(sp)
    80004994:	e0a2                	sd	s0,64(sp)
    80004996:	fc26                	sd	s1,56(sp)
    80004998:	f84a                	sd	s2,48(sp)
    8000499a:	f44e                	sd	s3,40(sp)
    8000499c:	f052                	sd	s4,32(sp)
    8000499e:	ec56                	sd	s5,24(sp)
    800049a0:	e85a                	sd	s6,16(sp)
    800049a2:	e45e                	sd	s7,8(sp)
    800049a4:	e062                	sd	s8,0(sp)
    800049a6:	0880                	addi	s0,sp,80
    800049a8:	892a                	mv	s2,a0
    800049aa:	8aae                	mv	s5,a1
    800049ac:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049ae:	411c                	lw	a5,0(a0)
    800049b0:	4705                	li	a4,1
    800049b2:	02e78263          	beq	a5,a4,800049d6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049b6:	470d                	li	a4,3
    800049b8:	02e78563          	beq	a5,a4,800049e2 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049bc:	4709                	li	a4,2
    800049be:	10e79463          	bne	a5,a4,80004ac6 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049c2:	0ec05e63          	blez	a2,80004abe <filewrite+0x136>
    int i = 0;
    800049c6:	4981                	li	s3,0
    800049c8:	6b05                	lui	s6,0x1
    800049ca:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049ce:	6b85                	lui	s7,0x1
    800049d0:	c00b8b9b          	addiw	s7,s7,-1024
    800049d4:	a851                	j	80004a68 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049d6:	6908                	ld	a0,16(a0)
    800049d8:	00000097          	auipc	ra,0x0
    800049dc:	254080e7          	jalr	596(ra) # 80004c2c <pipewrite>
    800049e0:	a85d                	j	80004a96 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049e2:	02451783          	lh	a5,36(a0)
    800049e6:	03079693          	slli	a3,a5,0x30
    800049ea:	92c1                	srli	a3,a3,0x30
    800049ec:	4725                	li	a4,9
    800049ee:	0ed76663          	bltu	a4,a3,80004ada <filewrite+0x152>
    800049f2:	0792                	slli	a5,a5,0x4
    800049f4:	0003d717          	auipc	a4,0x3d
    800049f8:	fd470713          	addi	a4,a4,-44 # 800419c8 <devsw>
    800049fc:	97ba                	add	a5,a5,a4
    800049fe:	679c                	ld	a5,8(a5)
    80004a00:	cff9                	beqz	a5,80004ade <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004a02:	4505                	li	a0,1
    80004a04:	9782                	jalr	a5
    80004a06:	a841                	j	80004a96 <filewrite+0x10e>
    80004a08:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a0c:	00000097          	auipc	ra,0x0
    80004a10:	8ae080e7          	jalr	-1874(ra) # 800042ba <begin_op>
      ilock(f->ip);
    80004a14:	01893503          	ld	a0,24(s2)
    80004a18:	fffff097          	auipc	ra,0xfffff
    80004a1c:	ee2080e7          	jalr	-286(ra) # 800038fa <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a20:	8762                	mv	a4,s8
    80004a22:	02092683          	lw	a3,32(s2)
    80004a26:	01598633          	add	a2,s3,s5
    80004a2a:	4585                	li	a1,1
    80004a2c:	01893503          	ld	a0,24(s2)
    80004a30:	fffff097          	auipc	ra,0xfffff
    80004a34:	276080e7          	jalr	630(ra) # 80003ca6 <writei>
    80004a38:	84aa                	mv	s1,a0
    80004a3a:	02a05f63          	blez	a0,80004a78 <filewrite+0xf0>
        f->off += r;
    80004a3e:	02092783          	lw	a5,32(s2)
    80004a42:	9fa9                	addw	a5,a5,a0
    80004a44:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a48:	01893503          	ld	a0,24(s2)
    80004a4c:	fffff097          	auipc	ra,0xfffff
    80004a50:	f70080e7          	jalr	-144(ra) # 800039bc <iunlock>
      end_op();
    80004a54:	00000097          	auipc	ra,0x0
    80004a58:	8e6080e7          	jalr	-1818(ra) # 8000433a <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a5c:	049c1963          	bne	s8,s1,80004aae <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004a60:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a64:	0349d663          	bge	s3,s4,80004a90 <filewrite+0x108>
      int n1 = n - i;
    80004a68:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a6c:	84be                	mv	s1,a5
    80004a6e:	2781                	sext.w	a5,a5
    80004a70:	f8fb5ce3          	bge	s6,a5,80004a08 <filewrite+0x80>
    80004a74:	84de                	mv	s1,s7
    80004a76:	bf49                	j	80004a08 <filewrite+0x80>
      iunlock(f->ip);
    80004a78:	01893503          	ld	a0,24(s2)
    80004a7c:	fffff097          	auipc	ra,0xfffff
    80004a80:	f40080e7          	jalr	-192(ra) # 800039bc <iunlock>
      end_op();
    80004a84:	00000097          	auipc	ra,0x0
    80004a88:	8b6080e7          	jalr	-1866(ra) # 8000433a <end_op>
      if(r < 0)
    80004a8c:	fc04d8e3          	bgez	s1,80004a5c <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004a90:	8552                	mv	a0,s4
    80004a92:	033a1863          	bne	s4,s3,80004ac2 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a96:	60a6                	ld	ra,72(sp)
    80004a98:	6406                	ld	s0,64(sp)
    80004a9a:	74e2                	ld	s1,56(sp)
    80004a9c:	7942                	ld	s2,48(sp)
    80004a9e:	79a2                	ld	s3,40(sp)
    80004aa0:	7a02                	ld	s4,32(sp)
    80004aa2:	6ae2                	ld	s5,24(sp)
    80004aa4:	6b42                	ld	s6,16(sp)
    80004aa6:	6ba2                	ld	s7,8(sp)
    80004aa8:	6c02                	ld	s8,0(sp)
    80004aaa:	6161                	addi	sp,sp,80
    80004aac:	8082                	ret
        panic("short filewrite");
    80004aae:	00004517          	auipc	a0,0x4
    80004ab2:	c1a50513          	addi	a0,a0,-998 # 800086c8 <syscalls+0x268>
    80004ab6:	ffffc097          	auipc	ra,0xffffc
    80004aba:	a92080e7          	jalr	-1390(ra) # 80000548 <panic>
    int i = 0;
    80004abe:	4981                	li	s3,0
    80004ac0:	bfc1                	j	80004a90 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004ac2:	557d                	li	a0,-1
    80004ac4:	bfc9                	j	80004a96 <filewrite+0x10e>
    panic("filewrite");
    80004ac6:	00004517          	auipc	a0,0x4
    80004aca:	c1250513          	addi	a0,a0,-1006 # 800086d8 <syscalls+0x278>
    80004ace:	ffffc097          	auipc	ra,0xffffc
    80004ad2:	a7a080e7          	jalr	-1414(ra) # 80000548 <panic>
    return -1;
    80004ad6:	557d                	li	a0,-1
}
    80004ad8:	8082                	ret
      return -1;
    80004ada:	557d                	li	a0,-1
    80004adc:	bf6d                	j	80004a96 <filewrite+0x10e>
    80004ade:	557d                	li	a0,-1
    80004ae0:	bf5d                	j	80004a96 <filewrite+0x10e>

0000000080004ae2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ae2:	7179                	addi	sp,sp,-48
    80004ae4:	f406                	sd	ra,40(sp)
    80004ae6:	f022                	sd	s0,32(sp)
    80004ae8:	ec26                	sd	s1,24(sp)
    80004aea:	e84a                	sd	s2,16(sp)
    80004aec:	e44e                	sd	s3,8(sp)
    80004aee:	e052                	sd	s4,0(sp)
    80004af0:	1800                	addi	s0,sp,48
    80004af2:	84aa                	mv	s1,a0
    80004af4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004af6:	0005b023          	sd	zero,0(a1)
    80004afa:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004afe:	00000097          	auipc	ra,0x0
    80004b02:	bd2080e7          	jalr	-1070(ra) # 800046d0 <filealloc>
    80004b06:	e088                	sd	a0,0(s1)
    80004b08:	c551                	beqz	a0,80004b94 <pipealloc+0xb2>
    80004b0a:	00000097          	auipc	ra,0x0
    80004b0e:	bc6080e7          	jalr	-1082(ra) # 800046d0 <filealloc>
    80004b12:	00aa3023          	sd	a0,0(s4)
    80004b16:	c92d                	beqz	a0,80004b88 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	072080e7          	jalr	114(ra) # 80000b8a <kalloc>
    80004b20:	892a                	mv	s2,a0
    80004b22:	c125                	beqz	a0,80004b82 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b24:	4985                	li	s3,1
    80004b26:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b2a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b2e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b32:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b36:	00004597          	auipc	a1,0x4
    80004b3a:	bb258593          	addi	a1,a1,-1102 # 800086e8 <syscalls+0x288>
    80004b3e:	ffffc097          	auipc	ra,0xffffc
    80004b42:	1cc080e7          	jalr	460(ra) # 80000d0a <initlock>
  (*f0)->type = FD_PIPE;
    80004b46:	609c                	ld	a5,0(s1)
    80004b48:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b4c:	609c                	ld	a5,0(s1)
    80004b4e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b52:	609c                	ld	a5,0(s1)
    80004b54:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b58:	609c                	ld	a5,0(s1)
    80004b5a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b5e:	000a3783          	ld	a5,0(s4)
    80004b62:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b66:	000a3783          	ld	a5,0(s4)
    80004b6a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b6e:	000a3783          	ld	a5,0(s4)
    80004b72:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b76:	000a3783          	ld	a5,0(s4)
    80004b7a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b7e:	4501                	li	a0,0
    80004b80:	a025                	j	80004ba8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b82:	6088                	ld	a0,0(s1)
    80004b84:	e501                	bnez	a0,80004b8c <pipealloc+0xaa>
    80004b86:	a039                	j	80004b94 <pipealloc+0xb2>
    80004b88:	6088                	ld	a0,0(s1)
    80004b8a:	c51d                	beqz	a0,80004bb8 <pipealloc+0xd6>
    fileclose(*f0);
    80004b8c:	00000097          	auipc	ra,0x0
    80004b90:	c00080e7          	jalr	-1024(ra) # 8000478c <fileclose>
  if(*f1)
    80004b94:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b98:	557d                	li	a0,-1
  if(*f1)
    80004b9a:	c799                	beqz	a5,80004ba8 <pipealloc+0xc6>
    fileclose(*f1);
    80004b9c:	853e                	mv	a0,a5
    80004b9e:	00000097          	auipc	ra,0x0
    80004ba2:	bee080e7          	jalr	-1042(ra) # 8000478c <fileclose>
  return -1;
    80004ba6:	557d                	li	a0,-1
}
    80004ba8:	70a2                	ld	ra,40(sp)
    80004baa:	7402                	ld	s0,32(sp)
    80004bac:	64e2                	ld	s1,24(sp)
    80004bae:	6942                	ld	s2,16(sp)
    80004bb0:	69a2                	ld	s3,8(sp)
    80004bb2:	6a02                	ld	s4,0(sp)
    80004bb4:	6145                	addi	sp,sp,48
    80004bb6:	8082                	ret
  return -1;
    80004bb8:	557d                	li	a0,-1
    80004bba:	b7fd                	j	80004ba8 <pipealloc+0xc6>

0000000080004bbc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bbc:	1101                	addi	sp,sp,-32
    80004bbe:	ec06                	sd	ra,24(sp)
    80004bc0:	e822                	sd	s0,16(sp)
    80004bc2:	e426                	sd	s1,8(sp)
    80004bc4:	e04a                	sd	s2,0(sp)
    80004bc6:	1000                	addi	s0,sp,32
    80004bc8:	84aa                	mv	s1,a0
    80004bca:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bcc:	ffffc097          	auipc	ra,0xffffc
    80004bd0:	1ce080e7          	jalr	462(ra) # 80000d9a <acquire>
  if(writable){
    80004bd4:	02090d63          	beqz	s2,80004c0e <pipeclose+0x52>
    pi->writeopen = 0;
    80004bd8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bdc:	21848513          	addi	a0,s1,536
    80004be0:	ffffe097          	auipc	ra,0xffffe
    80004be4:	a3c080e7          	jalr	-1476(ra) # 8000261c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004be8:	2204b783          	ld	a5,544(s1)
    80004bec:	eb95                	bnez	a5,80004c20 <pipeclose+0x64>
    release(&pi->lock);
    80004bee:	8526                	mv	a0,s1
    80004bf0:	ffffc097          	auipc	ra,0xffffc
    80004bf4:	25e080e7          	jalr	606(ra) # 80000e4e <release>
    kfree((char*)pi);
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	ffffc097          	auipc	ra,0xffffc
    80004bfe:	e2a080e7          	jalr	-470(ra) # 80000a24 <kfree>
  } else
    release(&pi->lock);
}
    80004c02:	60e2                	ld	ra,24(sp)
    80004c04:	6442                	ld	s0,16(sp)
    80004c06:	64a2                	ld	s1,8(sp)
    80004c08:	6902                	ld	s2,0(sp)
    80004c0a:	6105                	addi	sp,sp,32
    80004c0c:	8082                	ret
    pi->readopen = 0;
    80004c0e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c12:	21c48513          	addi	a0,s1,540
    80004c16:	ffffe097          	auipc	ra,0xffffe
    80004c1a:	a06080e7          	jalr	-1530(ra) # 8000261c <wakeup>
    80004c1e:	b7e9                	j	80004be8 <pipeclose+0x2c>
    release(&pi->lock);
    80004c20:	8526                	mv	a0,s1
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	22c080e7          	jalr	556(ra) # 80000e4e <release>
}
    80004c2a:	bfe1                	j	80004c02 <pipeclose+0x46>

0000000080004c2c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c2c:	7119                	addi	sp,sp,-128
    80004c2e:	fc86                	sd	ra,120(sp)
    80004c30:	f8a2                	sd	s0,112(sp)
    80004c32:	f4a6                	sd	s1,104(sp)
    80004c34:	f0ca                	sd	s2,96(sp)
    80004c36:	ecce                	sd	s3,88(sp)
    80004c38:	e8d2                	sd	s4,80(sp)
    80004c3a:	e4d6                	sd	s5,72(sp)
    80004c3c:	e0da                	sd	s6,64(sp)
    80004c3e:	fc5e                	sd	s7,56(sp)
    80004c40:	f862                	sd	s8,48(sp)
    80004c42:	f466                	sd	s9,40(sp)
    80004c44:	f06a                	sd	s10,32(sp)
    80004c46:	ec6e                	sd	s11,24(sp)
    80004c48:	0100                	addi	s0,sp,128
    80004c4a:	84aa                	mv	s1,a0
    80004c4c:	8cae                	mv	s9,a1
    80004c4e:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c50:	ffffd097          	auipc	ra,0xffffd
    80004c54:	036080e7          	jalr	54(ra) # 80001c86 <myproc>
    80004c58:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004c5a:	8526                	mv	a0,s1
    80004c5c:	ffffc097          	auipc	ra,0xffffc
    80004c60:	13e080e7          	jalr	318(ra) # 80000d9a <acquire>
  for(i = 0; i < n; i++){
    80004c64:	0d605963          	blez	s6,80004d36 <pipewrite+0x10a>
    80004c68:	89a6                	mv	s3,s1
    80004c6a:	3b7d                	addiw	s6,s6,-1
    80004c6c:	1b02                	slli	s6,s6,0x20
    80004c6e:	020b5b13          	srli	s6,s6,0x20
    80004c72:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c74:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c78:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c7c:	5dfd                	li	s11,-1
    80004c7e:	000b8d1b          	sext.w	s10,s7
    80004c82:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c84:	2184a783          	lw	a5,536(s1)
    80004c88:	21c4a703          	lw	a4,540(s1)
    80004c8c:	2007879b          	addiw	a5,a5,512
    80004c90:	02f71b63          	bne	a4,a5,80004cc6 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004c94:	2204a783          	lw	a5,544(s1)
    80004c98:	cbad                	beqz	a5,80004d0a <pipewrite+0xde>
    80004c9a:	03092783          	lw	a5,48(s2)
    80004c9e:	e7b5                	bnez	a5,80004d0a <pipewrite+0xde>
      wakeup(&pi->nread);
    80004ca0:	8556                	mv	a0,s5
    80004ca2:	ffffe097          	auipc	ra,0xffffe
    80004ca6:	97a080e7          	jalr	-1670(ra) # 8000261c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004caa:	85ce                	mv	a1,s3
    80004cac:	8552                	mv	a0,s4
    80004cae:	ffffd097          	auipc	ra,0xffffd
    80004cb2:	7e8080e7          	jalr	2024(ra) # 80002496 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004cb6:	2184a783          	lw	a5,536(s1)
    80004cba:	21c4a703          	lw	a4,540(s1)
    80004cbe:	2007879b          	addiw	a5,a5,512
    80004cc2:	fcf709e3          	beq	a4,a5,80004c94 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cc6:	4685                	li	a3,1
    80004cc8:	019b8633          	add	a2,s7,s9
    80004ccc:	f8f40593          	addi	a1,s0,-113
    80004cd0:	05093503          	ld	a0,80(s2)
    80004cd4:	ffffd097          	auipc	ra,0xffffd
    80004cd8:	b92080e7          	jalr	-1134(ra) # 80001866 <copyin>
    80004cdc:	05b50e63          	beq	a0,s11,80004d38 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ce0:	21c4a783          	lw	a5,540(s1)
    80004ce4:	0017871b          	addiw	a4,a5,1
    80004ce8:	20e4ae23          	sw	a4,540(s1)
    80004cec:	1ff7f793          	andi	a5,a5,511
    80004cf0:	97a6                	add	a5,a5,s1
    80004cf2:	f8f44703          	lbu	a4,-113(s0)
    80004cf6:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004cfa:	001d0c1b          	addiw	s8,s10,1
    80004cfe:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004d02:	036b8b63          	beq	s7,s6,80004d38 <pipewrite+0x10c>
    80004d06:	8bbe                	mv	s7,a5
    80004d08:	bf9d                	j	80004c7e <pipewrite+0x52>
        release(&pi->lock);
    80004d0a:	8526                	mv	a0,s1
    80004d0c:	ffffc097          	auipc	ra,0xffffc
    80004d10:	142080e7          	jalr	322(ra) # 80000e4e <release>
        return -1;
    80004d14:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004d16:	8562                	mv	a0,s8
    80004d18:	70e6                	ld	ra,120(sp)
    80004d1a:	7446                	ld	s0,112(sp)
    80004d1c:	74a6                	ld	s1,104(sp)
    80004d1e:	7906                	ld	s2,96(sp)
    80004d20:	69e6                	ld	s3,88(sp)
    80004d22:	6a46                	ld	s4,80(sp)
    80004d24:	6aa6                	ld	s5,72(sp)
    80004d26:	6b06                	ld	s6,64(sp)
    80004d28:	7be2                	ld	s7,56(sp)
    80004d2a:	7c42                	ld	s8,48(sp)
    80004d2c:	7ca2                	ld	s9,40(sp)
    80004d2e:	7d02                	ld	s10,32(sp)
    80004d30:	6de2                	ld	s11,24(sp)
    80004d32:	6109                	addi	sp,sp,128
    80004d34:	8082                	ret
  for(i = 0; i < n; i++){
    80004d36:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004d38:	21848513          	addi	a0,s1,536
    80004d3c:	ffffe097          	auipc	ra,0xffffe
    80004d40:	8e0080e7          	jalr	-1824(ra) # 8000261c <wakeup>
  release(&pi->lock);
    80004d44:	8526                	mv	a0,s1
    80004d46:	ffffc097          	auipc	ra,0xffffc
    80004d4a:	108080e7          	jalr	264(ra) # 80000e4e <release>
  return i;
    80004d4e:	b7e1                	j	80004d16 <pipewrite+0xea>

0000000080004d50 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d50:	715d                	addi	sp,sp,-80
    80004d52:	e486                	sd	ra,72(sp)
    80004d54:	e0a2                	sd	s0,64(sp)
    80004d56:	fc26                	sd	s1,56(sp)
    80004d58:	f84a                	sd	s2,48(sp)
    80004d5a:	f44e                	sd	s3,40(sp)
    80004d5c:	f052                	sd	s4,32(sp)
    80004d5e:	ec56                	sd	s5,24(sp)
    80004d60:	e85a                	sd	s6,16(sp)
    80004d62:	0880                	addi	s0,sp,80
    80004d64:	84aa                	mv	s1,a0
    80004d66:	892e                	mv	s2,a1
    80004d68:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d6a:	ffffd097          	auipc	ra,0xffffd
    80004d6e:	f1c080e7          	jalr	-228(ra) # 80001c86 <myproc>
    80004d72:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d74:	8b26                	mv	s6,s1
    80004d76:	8526                	mv	a0,s1
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	022080e7          	jalr	34(ra) # 80000d9a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d80:	2184a703          	lw	a4,536(s1)
    80004d84:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d88:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d8c:	02f71463          	bne	a4,a5,80004db4 <piperead+0x64>
    80004d90:	2244a783          	lw	a5,548(s1)
    80004d94:	c385                	beqz	a5,80004db4 <piperead+0x64>
    if(pr->killed){
    80004d96:	030a2783          	lw	a5,48(s4)
    80004d9a:	ebc1                	bnez	a5,80004e2a <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d9c:	85da                	mv	a1,s6
    80004d9e:	854e                	mv	a0,s3
    80004da0:	ffffd097          	auipc	ra,0xffffd
    80004da4:	6f6080e7          	jalr	1782(ra) # 80002496 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004da8:	2184a703          	lw	a4,536(s1)
    80004dac:	21c4a783          	lw	a5,540(s1)
    80004db0:	fef700e3          	beq	a4,a5,80004d90 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004db4:	09505263          	blez	s5,80004e38 <piperead+0xe8>
    80004db8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dba:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004dbc:	2184a783          	lw	a5,536(s1)
    80004dc0:	21c4a703          	lw	a4,540(s1)
    80004dc4:	02f70d63          	beq	a4,a5,80004dfe <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dc8:	0017871b          	addiw	a4,a5,1
    80004dcc:	20e4ac23          	sw	a4,536(s1)
    80004dd0:	1ff7f793          	andi	a5,a5,511
    80004dd4:	97a6                	add	a5,a5,s1
    80004dd6:	0187c783          	lbu	a5,24(a5)
    80004dda:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dde:	4685                	li	a3,1
    80004de0:	fbf40613          	addi	a2,s0,-65
    80004de4:	85ca                	mv	a1,s2
    80004de6:	050a3503          	ld	a0,80(s4)
    80004dea:	ffffd097          	auipc	ra,0xffffd
    80004dee:	cb8080e7          	jalr	-840(ra) # 80001aa2 <copyout>
    80004df2:	01650663          	beq	a0,s6,80004dfe <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004df6:	2985                	addiw	s3,s3,1
    80004df8:	0905                	addi	s2,s2,1
    80004dfa:	fd3a91e3          	bne	s5,s3,80004dbc <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dfe:	21c48513          	addi	a0,s1,540
    80004e02:	ffffe097          	auipc	ra,0xffffe
    80004e06:	81a080e7          	jalr	-2022(ra) # 8000261c <wakeup>
  release(&pi->lock);
    80004e0a:	8526                	mv	a0,s1
    80004e0c:	ffffc097          	auipc	ra,0xffffc
    80004e10:	042080e7          	jalr	66(ra) # 80000e4e <release>
  return i;
}
    80004e14:	854e                	mv	a0,s3
    80004e16:	60a6                	ld	ra,72(sp)
    80004e18:	6406                	ld	s0,64(sp)
    80004e1a:	74e2                	ld	s1,56(sp)
    80004e1c:	7942                	ld	s2,48(sp)
    80004e1e:	79a2                	ld	s3,40(sp)
    80004e20:	7a02                	ld	s4,32(sp)
    80004e22:	6ae2                	ld	s5,24(sp)
    80004e24:	6b42                	ld	s6,16(sp)
    80004e26:	6161                	addi	sp,sp,80
    80004e28:	8082                	ret
      release(&pi->lock);
    80004e2a:	8526                	mv	a0,s1
    80004e2c:	ffffc097          	auipc	ra,0xffffc
    80004e30:	022080e7          	jalr	34(ra) # 80000e4e <release>
      return -1;
    80004e34:	59fd                	li	s3,-1
    80004e36:	bff9                	j	80004e14 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e38:	4981                	li	s3,0
    80004e3a:	b7d1                	j	80004dfe <piperead+0xae>

0000000080004e3c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e3c:	df010113          	addi	sp,sp,-528
    80004e40:	20113423          	sd	ra,520(sp)
    80004e44:	20813023          	sd	s0,512(sp)
    80004e48:	ffa6                	sd	s1,504(sp)
    80004e4a:	fbca                	sd	s2,496(sp)
    80004e4c:	f7ce                	sd	s3,488(sp)
    80004e4e:	f3d2                	sd	s4,480(sp)
    80004e50:	efd6                	sd	s5,472(sp)
    80004e52:	ebda                	sd	s6,464(sp)
    80004e54:	e7de                	sd	s7,456(sp)
    80004e56:	e3e2                	sd	s8,448(sp)
    80004e58:	ff66                	sd	s9,440(sp)
    80004e5a:	fb6a                	sd	s10,432(sp)
    80004e5c:	f76e                	sd	s11,424(sp)
    80004e5e:	0c00                	addi	s0,sp,528
    80004e60:	84aa                	mv	s1,a0
    80004e62:	dea43c23          	sd	a0,-520(s0)
    80004e66:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e6a:	ffffd097          	auipc	ra,0xffffd
    80004e6e:	e1c080e7          	jalr	-484(ra) # 80001c86 <myproc>
    80004e72:	892a                	mv	s2,a0

  begin_op();
    80004e74:	fffff097          	auipc	ra,0xfffff
    80004e78:	446080e7          	jalr	1094(ra) # 800042ba <begin_op>

  if((ip = namei(path)) == 0){
    80004e7c:	8526                	mv	a0,s1
    80004e7e:	fffff097          	auipc	ra,0xfffff
    80004e82:	230080e7          	jalr	560(ra) # 800040ae <namei>
    80004e86:	c92d                	beqz	a0,80004ef8 <exec+0xbc>
    80004e88:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e8a:	fffff097          	auipc	ra,0xfffff
    80004e8e:	a70080e7          	jalr	-1424(ra) # 800038fa <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e92:	04000713          	li	a4,64
    80004e96:	4681                	li	a3,0
    80004e98:	e4840613          	addi	a2,s0,-440
    80004e9c:	4581                	li	a1,0
    80004e9e:	8526                	mv	a0,s1
    80004ea0:	fffff097          	auipc	ra,0xfffff
    80004ea4:	d0e080e7          	jalr	-754(ra) # 80003bae <readi>
    80004ea8:	04000793          	li	a5,64
    80004eac:	00f51a63          	bne	a0,a5,80004ec0 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004eb0:	e4842703          	lw	a4,-440(s0)
    80004eb4:	464c47b7          	lui	a5,0x464c4
    80004eb8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ebc:	04f70463          	beq	a4,a5,80004f04 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	fffff097          	auipc	ra,0xfffff
    80004ec6:	c9a080e7          	jalr	-870(ra) # 80003b5c <iunlockput>
    end_op();
    80004eca:	fffff097          	auipc	ra,0xfffff
    80004ece:	470080e7          	jalr	1136(ra) # 8000433a <end_op>
  }
  return -1;
    80004ed2:	557d                	li	a0,-1
}
    80004ed4:	20813083          	ld	ra,520(sp)
    80004ed8:	20013403          	ld	s0,512(sp)
    80004edc:	74fe                	ld	s1,504(sp)
    80004ede:	795e                	ld	s2,496(sp)
    80004ee0:	79be                	ld	s3,488(sp)
    80004ee2:	7a1e                	ld	s4,480(sp)
    80004ee4:	6afe                	ld	s5,472(sp)
    80004ee6:	6b5e                	ld	s6,464(sp)
    80004ee8:	6bbe                	ld	s7,456(sp)
    80004eea:	6c1e                	ld	s8,448(sp)
    80004eec:	7cfa                	ld	s9,440(sp)
    80004eee:	7d5a                	ld	s10,432(sp)
    80004ef0:	7dba                	ld	s11,424(sp)
    80004ef2:	21010113          	addi	sp,sp,528
    80004ef6:	8082                	ret
    end_op();
    80004ef8:	fffff097          	auipc	ra,0xfffff
    80004efc:	442080e7          	jalr	1090(ra) # 8000433a <end_op>
    return -1;
    80004f00:	557d                	li	a0,-1
    80004f02:	bfc9                	j	80004ed4 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f04:	854a                	mv	a0,s2
    80004f06:	ffffd097          	auipc	ra,0xffffd
    80004f0a:	e44080e7          	jalr	-444(ra) # 80001d4a <proc_pagetable>
    80004f0e:	8baa                	mv	s7,a0
    80004f10:	d945                	beqz	a0,80004ec0 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f12:	e6842983          	lw	s3,-408(s0)
    80004f16:	e8045783          	lhu	a5,-384(s0)
    80004f1a:	c7ad                	beqz	a5,80004f84 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f1c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f1e:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004f20:	6c85                	lui	s9,0x1
    80004f22:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f26:	def43823          	sd	a5,-528(s0)
    80004f2a:	a42d                	j	80005154 <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f2c:	00003517          	auipc	a0,0x3
    80004f30:	7c450513          	addi	a0,a0,1988 # 800086f0 <syscalls+0x290>
    80004f34:	ffffb097          	auipc	ra,0xffffb
    80004f38:	614080e7          	jalr	1556(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f3c:	8756                	mv	a4,s5
    80004f3e:	012d86bb          	addw	a3,s11,s2
    80004f42:	4581                	li	a1,0
    80004f44:	8526                	mv	a0,s1
    80004f46:	fffff097          	auipc	ra,0xfffff
    80004f4a:	c68080e7          	jalr	-920(ra) # 80003bae <readi>
    80004f4e:	2501                	sext.w	a0,a0
    80004f50:	1aaa9963          	bne	s5,a0,80005102 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004f54:	6785                	lui	a5,0x1
    80004f56:	0127893b          	addw	s2,a5,s2
    80004f5a:	77fd                	lui	a5,0xfffff
    80004f5c:	01478a3b          	addw	s4,a5,s4
    80004f60:	1f897163          	bgeu	s2,s8,80005142 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004f64:	02091593          	slli	a1,s2,0x20
    80004f68:	9181                	srli	a1,a1,0x20
    80004f6a:	95ea                	add	a1,a1,s10
    80004f6c:	855e                	mv	a0,s7
    80004f6e:	ffffc097          	auipc	ra,0xffffc
    80004f72:	2ba080e7          	jalr	698(ra) # 80001228 <walkaddr>
    80004f76:	862a                	mv	a2,a0
    if(pa == 0)
    80004f78:	d955                	beqz	a0,80004f2c <exec+0xf0>
      n = PGSIZE;
    80004f7a:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004f7c:	fd9a70e3          	bgeu	s4,s9,80004f3c <exec+0x100>
      n = sz - i;
    80004f80:	8ad2                	mv	s5,s4
    80004f82:	bf6d                	j	80004f3c <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f84:	4901                	li	s2,0
  iunlockput(ip);
    80004f86:	8526                	mv	a0,s1
    80004f88:	fffff097          	auipc	ra,0xfffff
    80004f8c:	bd4080e7          	jalr	-1068(ra) # 80003b5c <iunlockput>
  end_op();
    80004f90:	fffff097          	auipc	ra,0xfffff
    80004f94:	3aa080e7          	jalr	938(ra) # 8000433a <end_op>
  p = myproc();
    80004f98:	ffffd097          	auipc	ra,0xffffd
    80004f9c:	cee080e7          	jalr	-786(ra) # 80001c86 <myproc>
    80004fa0:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004fa2:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004fa6:	6785                	lui	a5,0x1
    80004fa8:	17fd                	addi	a5,a5,-1
    80004faa:	993e                	add	s2,s2,a5
    80004fac:	757d                	lui	a0,0xfffff
    80004fae:	00a977b3          	and	a5,s2,a0
    80004fb2:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fb6:	6609                	lui	a2,0x2
    80004fb8:	963e                	add	a2,a2,a5
    80004fba:	85be                	mv	a1,a5
    80004fbc:	855e                	mv	a0,s7
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	64e080e7          	jalr	1614(ra) # 8000160c <uvmalloc>
    80004fc6:	8b2a                	mv	s6,a0
  ip = 0;
    80004fc8:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fca:	12050c63          	beqz	a0,80005102 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fce:	75f9                	lui	a1,0xffffe
    80004fd0:	95aa                	add	a1,a1,a0
    80004fd2:	855e                	mv	a0,s7
    80004fd4:	ffffd097          	auipc	ra,0xffffd
    80004fd8:	860080e7          	jalr	-1952(ra) # 80001834 <uvmclear>
  stackbase = sp - PGSIZE;
    80004fdc:	7c7d                	lui	s8,0xfffff
    80004fde:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fe0:	e0043783          	ld	a5,-512(s0)
    80004fe4:	6388                	ld	a0,0(a5)
    80004fe6:	c535                	beqz	a0,80005052 <exec+0x216>
    80004fe8:	e8840993          	addi	s3,s0,-376
    80004fec:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004ff0:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004ff2:	ffffc097          	auipc	ra,0xffffc
    80004ff6:	02c080e7          	jalr	44(ra) # 8000101e <strlen>
    80004ffa:	2505                	addiw	a0,a0,1
    80004ffc:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005000:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005004:	13896363          	bltu	s2,s8,8000512a <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005008:	e0043d83          	ld	s11,-512(s0)
    8000500c:	000dba03          	ld	s4,0(s11)
    80005010:	8552                	mv	a0,s4
    80005012:	ffffc097          	auipc	ra,0xffffc
    80005016:	00c080e7          	jalr	12(ra) # 8000101e <strlen>
    8000501a:	0015069b          	addiw	a3,a0,1
    8000501e:	8652                	mv	a2,s4
    80005020:	85ca                	mv	a1,s2
    80005022:	855e                	mv	a0,s7
    80005024:	ffffd097          	auipc	ra,0xffffd
    80005028:	a7e080e7          	jalr	-1410(ra) # 80001aa2 <copyout>
    8000502c:	10054363          	bltz	a0,80005132 <exec+0x2f6>
    ustack[argc] = sp;
    80005030:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005034:	0485                	addi	s1,s1,1
    80005036:	008d8793          	addi	a5,s11,8
    8000503a:	e0f43023          	sd	a5,-512(s0)
    8000503e:	008db503          	ld	a0,8(s11)
    80005042:	c911                	beqz	a0,80005056 <exec+0x21a>
    if(argc >= MAXARG)
    80005044:	09a1                	addi	s3,s3,8
    80005046:	fb3c96e3          	bne	s9,s3,80004ff2 <exec+0x1b6>
  sz = sz1;
    8000504a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000504e:	4481                	li	s1,0
    80005050:	a84d                	j	80005102 <exec+0x2c6>
  sp = sz;
    80005052:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005054:	4481                	li	s1,0
  ustack[argc] = 0;
    80005056:	00349793          	slli	a5,s1,0x3
    8000505a:	f9040713          	addi	a4,s0,-112
    8000505e:	97ba                	add	a5,a5,a4
    80005060:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80005064:	00148693          	addi	a3,s1,1
    80005068:	068e                	slli	a3,a3,0x3
    8000506a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000506e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005072:	01897663          	bgeu	s2,s8,8000507e <exec+0x242>
  sz = sz1;
    80005076:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000507a:	4481                	li	s1,0
    8000507c:	a059                	j	80005102 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000507e:	e8840613          	addi	a2,s0,-376
    80005082:	85ca                	mv	a1,s2
    80005084:	855e                	mv	a0,s7
    80005086:	ffffd097          	auipc	ra,0xffffd
    8000508a:	a1c080e7          	jalr	-1508(ra) # 80001aa2 <copyout>
    8000508e:	0a054663          	bltz	a0,8000513a <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005092:	058ab783          	ld	a5,88(s5)
    80005096:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000509a:	df843783          	ld	a5,-520(s0)
    8000509e:	0007c703          	lbu	a4,0(a5)
    800050a2:	cf11                	beqz	a4,800050be <exec+0x282>
    800050a4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050a6:	02f00693          	li	a3,47
    800050aa:	a029                	j	800050b4 <exec+0x278>
  for(last=s=path; *s; s++)
    800050ac:	0785                	addi	a5,a5,1
    800050ae:	fff7c703          	lbu	a4,-1(a5)
    800050b2:	c711                	beqz	a4,800050be <exec+0x282>
    if(*s == '/')
    800050b4:	fed71ce3          	bne	a4,a3,800050ac <exec+0x270>
      last = s+1;
    800050b8:	def43c23          	sd	a5,-520(s0)
    800050bc:	bfc5                	j	800050ac <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    800050be:	4641                	li	a2,16
    800050c0:	df843583          	ld	a1,-520(s0)
    800050c4:	158a8513          	addi	a0,s5,344
    800050c8:	ffffc097          	auipc	ra,0xffffc
    800050cc:	f24080e7          	jalr	-220(ra) # 80000fec <safestrcpy>
  oldpagetable = p->pagetable;
    800050d0:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800050d4:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800050d8:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050dc:	058ab783          	ld	a5,88(s5)
    800050e0:	e6043703          	ld	a4,-416(s0)
    800050e4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050e6:	058ab783          	ld	a5,88(s5)
    800050ea:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050ee:	85ea                	mv	a1,s10
    800050f0:	ffffd097          	auipc	ra,0xffffd
    800050f4:	cf6080e7          	jalr	-778(ra) # 80001de6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050f8:	0004851b          	sext.w	a0,s1
    800050fc:	bbe1                	j	80004ed4 <exec+0x98>
    800050fe:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005102:	e0843583          	ld	a1,-504(s0)
    80005106:	855e                	mv	a0,s7
    80005108:	ffffd097          	auipc	ra,0xffffd
    8000510c:	cde080e7          	jalr	-802(ra) # 80001de6 <proc_freepagetable>
  if(ip){
    80005110:	da0498e3          	bnez	s1,80004ec0 <exec+0x84>
  return -1;
    80005114:	557d                	li	a0,-1
    80005116:	bb7d                	j	80004ed4 <exec+0x98>
    80005118:	e1243423          	sd	s2,-504(s0)
    8000511c:	b7dd                	j	80005102 <exec+0x2c6>
    8000511e:	e1243423          	sd	s2,-504(s0)
    80005122:	b7c5                	j	80005102 <exec+0x2c6>
    80005124:	e1243423          	sd	s2,-504(s0)
    80005128:	bfe9                	j	80005102 <exec+0x2c6>
  sz = sz1;
    8000512a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000512e:	4481                	li	s1,0
    80005130:	bfc9                	j	80005102 <exec+0x2c6>
  sz = sz1;
    80005132:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005136:	4481                	li	s1,0
    80005138:	b7e9                	j	80005102 <exec+0x2c6>
  sz = sz1;
    8000513a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000513e:	4481                	li	s1,0
    80005140:	b7c9                	j	80005102 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005142:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005146:	2b05                	addiw	s6,s6,1
    80005148:	0389899b          	addiw	s3,s3,56
    8000514c:	e8045783          	lhu	a5,-384(s0)
    80005150:	e2fb5be3          	bge	s6,a5,80004f86 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005154:	2981                	sext.w	s3,s3
    80005156:	03800713          	li	a4,56
    8000515a:	86ce                	mv	a3,s3
    8000515c:	e1040613          	addi	a2,s0,-496
    80005160:	4581                	li	a1,0
    80005162:	8526                	mv	a0,s1
    80005164:	fffff097          	auipc	ra,0xfffff
    80005168:	a4a080e7          	jalr	-1462(ra) # 80003bae <readi>
    8000516c:	03800793          	li	a5,56
    80005170:	f8f517e3          	bne	a0,a5,800050fe <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80005174:	e1042783          	lw	a5,-496(s0)
    80005178:	4705                	li	a4,1
    8000517a:	fce796e3          	bne	a5,a4,80005146 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    8000517e:	e3843603          	ld	a2,-456(s0)
    80005182:	e3043783          	ld	a5,-464(s0)
    80005186:	f8f669e3          	bltu	a2,a5,80005118 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000518a:	e2043783          	ld	a5,-480(s0)
    8000518e:	963e                	add	a2,a2,a5
    80005190:	f8f667e3          	bltu	a2,a5,8000511e <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005194:	85ca                	mv	a1,s2
    80005196:	855e                	mv	a0,s7
    80005198:	ffffc097          	auipc	ra,0xffffc
    8000519c:	474080e7          	jalr	1140(ra) # 8000160c <uvmalloc>
    800051a0:	e0a43423          	sd	a0,-504(s0)
    800051a4:	d141                	beqz	a0,80005124 <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    800051a6:	e2043d03          	ld	s10,-480(s0)
    800051aa:	df043783          	ld	a5,-528(s0)
    800051ae:	00fd77b3          	and	a5,s10,a5
    800051b2:	fba1                	bnez	a5,80005102 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051b4:	e1842d83          	lw	s11,-488(s0)
    800051b8:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051bc:	f80c03e3          	beqz	s8,80005142 <exec+0x306>
    800051c0:	8a62                	mv	s4,s8
    800051c2:	4901                	li	s2,0
    800051c4:	b345                	j	80004f64 <exec+0x128>

00000000800051c6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051c6:	7179                	addi	sp,sp,-48
    800051c8:	f406                	sd	ra,40(sp)
    800051ca:	f022                	sd	s0,32(sp)
    800051cc:	ec26                	sd	s1,24(sp)
    800051ce:	e84a                	sd	s2,16(sp)
    800051d0:	1800                	addi	s0,sp,48
    800051d2:	892e                	mv	s2,a1
    800051d4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051d6:	fdc40593          	addi	a1,s0,-36
    800051da:	ffffe097          	auipc	ra,0xffffe
    800051de:	bae080e7          	jalr	-1106(ra) # 80002d88 <argint>
    800051e2:	04054063          	bltz	a0,80005222 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051e6:	fdc42703          	lw	a4,-36(s0)
    800051ea:	47bd                	li	a5,15
    800051ec:	02e7ed63          	bltu	a5,a4,80005226 <argfd+0x60>
    800051f0:	ffffd097          	auipc	ra,0xffffd
    800051f4:	a96080e7          	jalr	-1386(ra) # 80001c86 <myproc>
    800051f8:	fdc42703          	lw	a4,-36(s0)
    800051fc:	01a70793          	addi	a5,a4,26
    80005200:	078e                	slli	a5,a5,0x3
    80005202:	953e                	add	a0,a0,a5
    80005204:	611c                	ld	a5,0(a0)
    80005206:	c395                	beqz	a5,8000522a <argfd+0x64>
    return -1;
  if(pfd)
    80005208:	00090463          	beqz	s2,80005210 <argfd+0x4a>
    *pfd = fd;
    8000520c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005210:	4501                	li	a0,0
  if(pf)
    80005212:	c091                	beqz	s1,80005216 <argfd+0x50>
    *pf = f;
    80005214:	e09c                	sd	a5,0(s1)
}
    80005216:	70a2                	ld	ra,40(sp)
    80005218:	7402                	ld	s0,32(sp)
    8000521a:	64e2                	ld	s1,24(sp)
    8000521c:	6942                	ld	s2,16(sp)
    8000521e:	6145                	addi	sp,sp,48
    80005220:	8082                	ret
    return -1;
    80005222:	557d                	li	a0,-1
    80005224:	bfcd                	j	80005216 <argfd+0x50>
    return -1;
    80005226:	557d                	li	a0,-1
    80005228:	b7fd                	j	80005216 <argfd+0x50>
    8000522a:	557d                	li	a0,-1
    8000522c:	b7ed                	j	80005216 <argfd+0x50>

000000008000522e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000522e:	1101                	addi	sp,sp,-32
    80005230:	ec06                	sd	ra,24(sp)
    80005232:	e822                	sd	s0,16(sp)
    80005234:	e426                	sd	s1,8(sp)
    80005236:	1000                	addi	s0,sp,32
    80005238:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000523a:	ffffd097          	auipc	ra,0xffffd
    8000523e:	a4c080e7          	jalr	-1460(ra) # 80001c86 <myproc>
    80005242:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005244:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffb90d0>
    80005248:	4501                	li	a0,0
    8000524a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000524c:	6398                	ld	a4,0(a5)
    8000524e:	cb19                	beqz	a4,80005264 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005250:	2505                	addiw	a0,a0,1
    80005252:	07a1                	addi	a5,a5,8
    80005254:	fed51ce3          	bne	a0,a3,8000524c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005258:	557d                	li	a0,-1
}
    8000525a:	60e2                	ld	ra,24(sp)
    8000525c:	6442                	ld	s0,16(sp)
    8000525e:	64a2                	ld	s1,8(sp)
    80005260:	6105                	addi	sp,sp,32
    80005262:	8082                	ret
      p->ofile[fd] = f;
    80005264:	01a50793          	addi	a5,a0,26
    80005268:	078e                	slli	a5,a5,0x3
    8000526a:	963e                	add	a2,a2,a5
    8000526c:	e204                	sd	s1,0(a2)
      return fd;
    8000526e:	b7f5                	j	8000525a <fdalloc+0x2c>

0000000080005270 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005270:	715d                	addi	sp,sp,-80
    80005272:	e486                	sd	ra,72(sp)
    80005274:	e0a2                	sd	s0,64(sp)
    80005276:	fc26                	sd	s1,56(sp)
    80005278:	f84a                	sd	s2,48(sp)
    8000527a:	f44e                	sd	s3,40(sp)
    8000527c:	f052                	sd	s4,32(sp)
    8000527e:	ec56                	sd	s5,24(sp)
    80005280:	0880                	addi	s0,sp,80
    80005282:	89ae                	mv	s3,a1
    80005284:	8ab2                	mv	s5,a2
    80005286:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005288:	fb040593          	addi	a1,s0,-80
    8000528c:	fffff097          	auipc	ra,0xfffff
    80005290:	e40080e7          	jalr	-448(ra) # 800040cc <nameiparent>
    80005294:	892a                	mv	s2,a0
    80005296:	12050f63          	beqz	a0,800053d4 <create+0x164>
    return 0;

  ilock(dp);
    8000529a:	ffffe097          	auipc	ra,0xffffe
    8000529e:	660080e7          	jalr	1632(ra) # 800038fa <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052a2:	4601                	li	a2,0
    800052a4:	fb040593          	addi	a1,s0,-80
    800052a8:	854a                	mv	a0,s2
    800052aa:	fffff097          	auipc	ra,0xfffff
    800052ae:	b32080e7          	jalr	-1230(ra) # 80003ddc <dirlookup>
    800052b2:	84aa                	mv	s1,a0
    800052b4:	c921                	beqz	a0,80005304 <create+0x94>
    iunlockput(dp);
    800052b6:	854a                	mv	a0,s2
    800052b8:	fffff097          	auipc	ra,0xfffff
    800052bc:	8a4080e7          	jalr	-1884(ra) # 80003b5c <iunlockput>
    ilock(ip);
    800052c0:	8526                	mv	a0,s1
    800052c2:	ffffe097          	auipc	ra,0xffffe
    800052c6:	638080e7          	jalr	1592(ra) # 800038fa <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052ca:	2981                	sext.w	s3,s3
    800052cc:	4789                	li	a5,2
    800052ce:	02f99463          	bne	s3,a5,800052f6 <create+0x86>
    800052d2:	0444d783          	lhu	a5,68(s1)
    800052d6:	37f9                	addiw	a5,a5,-2
    800052d8:	17c2                	slli	a5,a5,0x30
    800052da:	93c1                	srli	a5,a5,0x30
    800052dc:	4705                	li	a4,1
    800052de:	00f76c63          	bltu	a4,a5,800052f6 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052e2:	8526                	mv	a0,s1
    800052e4:	60a6                	ld	ra,72(sp)
    800052e6:	6406                	ld	s0,64(sp)
    800052e8:	74e2                	ld	s1,56(sp)
    800052ea:	7942                	ld	s2,48(sp)
    800052ec:	79a2                	ld	s3,40(sp)
    800052ee:	7a02                	ld	s4,32(sp)
    800052f0:	6ae2                	ld	s5,24(sp)
    800052f2:	6161                	addi	sp,sp,80
    800052f4:	8082                	ret
    iunlockput(ip);
    800052f6:	8526                	mv	a0,s1
    800052f8:	fffff097          	auipc	ra,0xfffff
    800052fc:	864080e7          	jalr	-1948(ra) # 80003b5c <iunlockput>
    return 0;
    80005300:	4481                	li	s1,0
    80005302:	b7c5                	j	800052e2 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005304:	85ce                	mv	a1,s3
    80005306:	00092503          	lw	a0,0(s2)
    8000530a:	ffffe097          	auipc	ra,0xffffe
    8000530e:	458080e7          	jalr	1112(ra) # 80003762 <ialloc>
    80005312:	84aa                	mv	s1,a0
    80005314:	c529                	beqz	a0,8000535e <create+0xee>
  ilock(ip);
    80005316:	ffffe097          	auipc	ra,0xffffe
    8000531a:	5e4080e7          	jalr	1508(ra) # 800038fa <ilock>
  ip->major = major;
    8000531e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005322:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005326:	4785                	li	a5,1
    80005328:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000532c:	8526                	mv	a0,s1
    8000532e:	ffffe097          	auipc	ra,0xffffe
    80005332:	502080e7          	jalr	1282(ra) # 80003830 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005336:	2981                	sext.w	s3,s3
    80005338:	4785                	li	a5,1
    8000533a:	02f98a63          	beq	s3,a5,8000536e <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000533e:	40d0                	lw	a2,4(s1)
    80005340:	fb040593          	addi	a1,s0,-80
    80005344:	854a                	mv	a0,s2
    80005346:	fffff097          	auipc	ra,0xfffff
    8000534a:	ca6080e7          	jalr	-858(ra) # 80003fec <dirlink>
    8000534e:	06054b63          	bltz	a0,800053c4 <create+0x154>
  iunlockput(dp);
    80005352:	854a                	mv	a0,s2
    80005354:	fffff097          	auipc	ra,0xfffff
    80005358:	808080e7          	jalr	-2040(ra) # 80003b5c <iunlockput>
  return ip;
    8000535c:	b759                	j	800052e2 <create+0x72>
    panic("create: ialloc");
    8000535e:	00003517          	auipc	a0,0x3
    80005362:	3b250513          	addi	a0,a0,946 # 80008710 <syscalls+0x2b0>
    80005366:	ffffb097          	auipc	ra,0xffffb
    8000536a:	1e2080e7          	jalr	482(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    8000536e:	04a95783          	lhu	a5,74(s2)
    80005372:	2785                	addiw	a5,a5,1
    80005374:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005378:	854a                	mv	a0,s2
    8000537a:	ffffe097          	auipc	ra,0xffffe
    8000537e:	4b6080e7          	jalr	1206(ra) # 80003830 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005382:	40d0                	lw	a2,4(s1)
    80005384:	00003597          	auipc	a1,0x3
    80005388:	39c58593          	addi	a1,a1,924 # 80008720 <syscalls+0x2c0>
    8000538c:	8526                	mv	a0,s1
    8000538e:	fffff097          	auipc	ra,0xfffff
    80005392:	c5e080e7          	jalr	-930(ra) # 80003fec <dirlink>
    80005396:	00054f63          	bltz	a0,800053b4 <create+0x144>
    8000539a:	00492603          	lw	a2,4(s2)
    8000539e:	00003597          	auipc	a1,0x3
    800053a2:	38a58593          	addi	a1,a1,906 # 80008728 <syscalls+0x2c8>
    800053a6:	8526                	mv	a0,s1
    800053a8:	fffff097          	auipc	ra,0xfffff
    800053ac:	c44080e7          	jalr	-956(ra) # 80003fec <dirlink>
    800053b0:	f80557e3          	bgez	a0,8000533e <create+0xce>
      panic("create dots");
    800053b4:	00003517          	auipc	a0,0x3
    800053b8:	37c50513          	addi	a0,a0,892 # 80008730 <syscalls+0x2d0>
    800053bc:	ffffb097          	auipc	ra,0xffffb
    800053c0:	18c080e7          	jalr	396(ra) # 80000548 <panic>
    panic("create: dirlink");
    800053c4:	00003517          	auipc	a0,0x3
    800053c8:	37c50513          	addi	a0,a0,892 # 80008740 <syscalls+0x2e0>
    800053cc:	ffffb097          	auipc	ra,0xffffb
    800053d0:	17c080e7          	jalr	380(ra) # 80000548 <panic>
    return 0;
    800053d4:	84aa                	mv	s1,a0
    800053d6:	b731                	j	800052e2 <create+0x72>

00000000800053d8 <sys_dup>:
{
    800053d8:	7179                	addi	sp,sp,-48
    800053da:	f406                	sd	ra,40(sp)
    800053dc:	f022                	sd	s0,32(sp)
    800053de:	ec26                	sd	s1,24(sp)
    800053e0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053e2:	fd840613          	addi	a2,s0,-40
    800053e6:	4581                	li	a1,0
    800053e8:	4501                	li	a0,0
    800053ea:	00000097          	auipc	ra,0x0
    800053ee:	ddc080e7          	jalr	-548(ra) # 800051c6 <argfd>
    return -1;
    800053f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053f4:	02054363          	bltz	a0,8000541a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053f8:	fd843503          	ld	a0,-40(s0)
    800053fc:	00000097          	auipc	ra,0x0
    80005400:	e32080e7          	jalr	-462(ra) # 8000522e <fdalloc>
    80005404:	84aa                	mv	s1,a0
    return -1;
    80005406:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005408:	00054963          	bltz	a0,8000541a <sys_dup+0x42>
  filedup(f);
    8000540c:	fd843503          	ld	a0,-40(s0)
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	32a080e7          	jalr	810(ra) # 8000473a <filedup>
  return fd;
    80005418:	87a6                	mv	a5,s1
}
    8000541a:	853e                	mv	a0,a5
    8000541c:	70a2                	ld	ra,40(sp)
    8000541e:	7402                	ld	s0,32(sp)
    80005420:	64e2                	ld	s1,24(sp)
    80005422:	6145                	addi	sp,sp,48
    80005424:	8082                	ret

0000000080005426 <sys_read>:
{
    80005426:	7179                	addi	sp,sp,-48
    80005428:	f406                	sd	ra,40(sp)
    8000542a:	f022                	sd	s0,32(sp)
    8000542c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000542e:	fe840613          	addi	a2,s0,-24
    80005432:	4581                	li	a1,0
    80005434:	4501                	li	a0,0
    80005436:	00000097          	auipc	ra,0x0
    8000543a:	d90080e7          	jalr	-624(ra) # 800051c6 <argfd>
    return -1;
    8000543e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005440:	04054163          	bltz	a0,80005482 <sys_read+0x5c>
    80005444:	fe440593          	addi	a1,s0,-28
    80005448:	4509                	li	a0,2
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	93e080e7          	jalr	-1730(ra) # 80002d88 <argint>
    return -1;
    80005452:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005454:	02054763          	bltz	a0,80005482 <sys_read+0x5c>
    80005458:	fd840593          	addi	a1,s0,-40
    8000545c:	4505                	li	a0,1
    8000545e:	ffffe097          	auipc	ra,0xffffe
    80005462:	94c080e7          	jalr	-1716(ra) # 80002daa <argaddr>
    return -1;
    80005466:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005468:	00054d63          	bltz	a0,80005482 <sys_read+0x5c>
  return fileread(f, p, n);
    8000546c:	fe442603          	lw	a2,-28(s0)
    80005470:	fd843583          	ld	a1,-40(s0)
    80005474:	fe843503          	ld	a0,-24(s0)
    80005478:	fffff097          	auipc	ra,0xfffff
    8000547c:	44e080e7          	jalr	1102(ra) # 800048c6 <fileread>
    80005480:	87aa                	mv	a5,a0
}
    80005482:	853e                	mv	a0,a5
    80005484:	70a2                	ld	ra,40(sp)
    80005486:	7402                	ld	s0,32(sp)
    80005488:	6145                	addi	sp,sp,48
    8000548a:	8082                	ret

000000008000548c <sys_write>:
{
    8000548c:	7179                	addi	sp,sp,-48
    8000548e:	f406                	sd	ra,40(sp)
    80005490:	f022                	sd	s0,32(sp)
    80005492:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005494:	fe840613          	addi	a2,s0,-24
    80005498:	4581                	li	a1,0
    8000549a:	4501                	li	a0,0
    8000549c:	00000097          	auipc	ra,0x0
    800054a0:	d2a080e7          	jalr	-726(ra) # 800051c6 <argfd>
    return -1;
    800054a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054a6:	04054163          	bltz	a0,800054e8 <sys_write+0x5c>
    800054aa:	fe440593          	addi	a1,s0,-28
    800054ae:	4509                	li	a0,2
    800054b0:	ffffe097          	auipc	ra,0xffffe
    800054b4:	8d8080e7          	jalr	-1832(ra) # 80002d88 <argint>
    return -1;
    800054b8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ba:	02054763          	bltz	a0,800054e8 <sys_write+0x5c>
    800054be:	fd840593          	addi	a1,s0,-40
    800054c2:	4505                	li	a0,1
    800054c4:	ffffe097          	auipc	ra,0xffffe
    800054c8:	8e6080e7          	jalr	-1818(ra) # 80002daa <argaddr>
    return -1;
    800054cc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ce:	00054d63          	bltz	a0,800054e8 <sys_write+0x5c>
  return filewrite(f, p, n);
    800054d2:	fe442603          	lw	a2,-28(s0)
    800054d6:	fd843583          	ld	a1,-40(s0)
    800054da:	fe843503          	ld	a0,-24(s0)
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	4aa080e7          	jalr	1194(ra) # 80004988 <filewrite>
    800054e6:	87aa                	mv	a5,a0
}
    800054e8:	853e                	mv	a0,a5
    800054ea:	70a2                	ld	ra,40(sp)
    800054ec:	7402                	ld	s0,32(sp)
    800054ee:	6145                	addi	sp,sp,48
    800054f0:	8082                	ret

00000000800054f2 <sys_close>:
{
    800054f2:	1101                	addi	sp,sp,-32
    800054f4:	ec06                	sd	ra,24(sp)
    800054f6:	e822                	sd	s0,16(sp)
    800054f8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054fa:	fe040613          	addi	a2,s0,-32
    800054fe:	fec40593          	addi	a1,s0,-20
    80005502:	4501                	li	a0,0
    80005504:	00000097          	auipc	ra,0x0
    80005508:	cc2080e7          	jalr	-830(ra) # 800051c6 <argfd>
    return -1;
    8000550c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000550e:	02054463          	bltz	a0,80005536 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005512:	ffffc097          	auipc	ra,0xffffc
    80005516:	774080e7          	jalr	1908(ra) # 80001c86 <myproc>
    8000551a:	fec42783          	lw	a5,-20(s0)
    8000551e:	07e9                	addi	a5,a5,26
    80005520:	078e                	slli	a5,a5,0x3
    80005522:	97aa                	add	a5,a5,a0
    80005524:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005528:	fe043503          	ld	a0,-32(s0)
    8000552c:	fffff097          	auipc	ra,0xfffff
    80005530:	260080e7          	jalr	608(ra) # 8000478c <fileclose>
  return 0;
    80005534:	4781                	li	a5,0
}
    80005536:	853e                	mv	a0,a5
    80005538:	60e2                	ld	ra,24(sp)
    8000553a:	6442                	ld	s0,16(sp)
    8000553c:	6105                	addi	sp,sp,32
    8000553e:	8082                	ret

0000000080005540 <sys_fstat>:
{
    80005540:	1101                	addi	sp,sp,-32
    80005542:	ec06                	sd	ra,24(sp)
    80005544:	e822                	sd	s0,16(sp)
    80005546:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005548:	fe840613          	addi	a2,s0,-24
    8000554c:	4581                	li	a1,0
    8000554e:	4501                	li	a0,0
    80005550:	00000097          	auipc	ra,0x0
    80005554:	c76080e7          	jalr	-906(ra) # 800051c6 <argfd>
    return -1;
    80005558:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000555a:	02054563          	bltz	a0,80005584 <sys_fstat+0x44>
    8000555e:	fe040593          	addi	a1,s0,-32
    80005562:	4505                	li	a0,1
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	846080e7          	jalr	-1978(ra) # 80002daa <argaddr>
    return -1;
    8000556c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000556e:	00054b63          	bltz	a0,80005584 <sys_fstat+0x44>
  return filestat(f, st);
    80005572:	fe043583          	ld	a1,-32(s0)
    80005576:	fe843503          	ld	a0,-24(s0)
    8000557a:	fffff097          	auipc	ra,0xfffff
    8000557e:	2da080e7          	jalr	730(ra) # 80004854 <filestat>
    80005582:	87aa                	mv	a5,a0
}
    80005584:	853e                	mv	a0,a5
    80005586:	60e2                	ld	ra,24(sp)
    80005588:	6442                	ld	s0,16(sp)
    8000558a:	6105                	addi	sp,sp,32
    8000558c:	8082                	ret

000000008000558e <sys_link>:
{
    8000558e:	7169                	addi	sp,sp,-304
    80005590:	f606                	sd	ra,296(sp)
    80005592:	f222                	sd	s0,288(sp)
    80005594:	ee26                	sd	s1,280(sp)
    80005596:	ea4a                	sd	s2,272(sp)
    80005598:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000559a:	08000613          	li	a2,128
    8000559e:	ed040593          	addi	a1,s0,-304
    800055a2:	4501                	li	a0,0
    800055a4:	ffffe097          	auipc	ra,0xffffe
    800055a8:	828080e7          	jalr	-2008(ra) # 80002dcc <argstr>
    return -1;
    800055ac:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055ae:	10054e63          	bltz	a0,800056ca <sys_link+0x13c>
    800055b2:	08000613          	li	a2,128
    800055b6:	f5040593          	addi	a1,s0,-176
    800055ba:	4505                	li	a0,1
    800055bc:	ffffe097          	auipc	ra,0xffffe
    800055c0:	810080e7          	jalr	-2032(ra) # 80002dcc <argstr>
    return -1;
    800055c4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055c6:	10054263          	bltz	a0,800056ca <sys_link+0x13c>
  begin_op();
    800055ca:	fffff097          	auipc	ra,0xfffff
    800055ce:	cf0080e7          	jalr	-784(ra) # 800042ba <begin_op>
  if((ip = namei(old)) == 0){
    800055d2:	ed040513          	addi	a0,s0,-304
    800055d6:	fffff097          	auipc	ra,0xfffff
    800055da:	ad8080e7          	jalr	-1320(ra) # 800040ae <namei>
    800055de:	84aa                	mv	s1,a0
    800055e0:	c551                	beqz	a0,8000566c <sys_link+0xde>
  ilock(ip);
    800055e2:	ffffe097          	auipc	ra,0xffffe
    800055e6:	318080e7          	jalr	792(ra) # 800038fa <ilock>
  if(ip->type == T_DIR){
    800055ea:	04449703          	lh	a4,68(s1)
    800055ee:	4785                	li	a5,1
    800055f0:	08f70463          	beq	a4,a5,80005678 <sys_link+0xea>
  ip->nlink++;
    800055f4:	04a4d783          	lhu	a5,74(s1)
    800055f8:	2785                	addiw	a5,a5,1
    800055fa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055fe:	8526                	mv	a0,s1
    80005600:	ffffe097          	auipc	ra,0xffffe
    80005604:	230080e7          	jalr	560(ra) # 80003830 <iupdate>
  iunlock(ip);
    80005608:	8526                	mv	a0,s1
    8000560a:	ffffe097          	auipc	ra,0xffffe
    8000560e:	3b2080e7          	jalr	946(ra) # 800039bc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005612:	fd040593          	addi	a1,s0,-48
    80005616:	f5040513          	addi	a0,s0,-176
    8000561a:	fffff097          	auipc	ra,0xfffff
    8000561e:	ab2080e7          	jalr	-1358(ra) # 800040cc <nameiparent>
    80005622:	892a                	mv	s2,a0
    80005624:	c935                	beqz	a0,80005698 <sys_link+0x10a>
  ilock(dp);
    80005626:	ffffe097          	auipc	ra,0xffffe
    8000562a:	2d4080e7          	jalr	724(ra) # 800038fa <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000562e:	00092703          	lw	a4,0(s2)
    80005632:	409c                	lw	a5,0(s1)
    80005634:	04f71d63          	bne	a4,a5,8000568e <sys_link+0x100>
    80005638:	40d0                	lw	a2,4(s1)
    8000563a:	fd040593          	addi	a1,s0,-48
    8000563e:	854a                	mv	a0,s2
    80005640:	fffff097          	auipc	ra,0xfffff
    80005644:	9ac080e7          	jalr	-1620(ra) # 80003fec <dirlink>
    80005648:	04054363          	bltz	a0,8000568e <sys_link+0x100>
  iunlockput(dp);
    8000564c:	854a                	mv	a0,s2
    8000564e:	ffffe097          	auipc	ra,0xffffe
    80005652:	50e080e7          	jalr	1294(ra) # 80003b5c <iunlockput>
  iput(ip);
    80005656:	8526                	mv	a0,s1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	45c080e7          	jalr	1116(ra) # 80003ab4 <iput>
  end_op();
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	cda080e7          	jalr	-806(ra) # 8000433a <end_op>
  return 0;
    80005668:	4781                	li	a5,0
    8000566a:	a085                	j	800056ca <sys_link+0x13c>
    end_op();
    8000566c:	fffff097          	auipc	ra,0xfffff
    80005670:	cce080e7          	jalr	-818(ra) # 8000433a <end_op>
    return -1;
    80005674:	57fd                	li	a5,-1
    80005676:	a891                	j	800056ca <sys_link+0x13c>
    iunlockput(ip);
    80005678:	8526                	mv	a0,s1
    8000567a:	ffffe097          	auipc	ra,0xffffe
    8000567e:	4e2080e7          	jalr	1250(ra) # 80003b5c <iunlockput>
    end_op();
    80005682:	fffff097          	auipc	ra,0xfffff
    80005686:	cb8080e7          	jalr	-840(ra) # 8000433a <end_op>
    return -1;
    8000568a:	57fd                	li	a5,-1
    8000568c:	a83d                	j	800056ca <sys_link+0x13c>
    iunlockput(dp);
    8000568e:	854a                	mv	a0,s2
    80005690:	ffffe097          	auipc	ra,0xffffe
    80005694:	4cc080e7          	jalr	1228(ra) # 80003b5c <iunlockput>
  ilock(ip);
    80005698:	8526                	mv	a0,s1
    8000569a:	ffffe097          	auipc	ra,0xffffe
    8000569e:	260080e7          	jalr	608(ra) # 800038fa <ilock>
  ip->nlink--;
    800056a2:	04a4d783          	lhu	a5,74(s1)
    800056a6:	37fd                	addiw	a5,a5,-1
    800056a8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056ac:	8526                	mv	a0,s1
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	182080e7          	jalr	386(ra) # 80003830 <iupdate>
  iunlockput(ip);
    800056b6:	8526                	mv	a0,s1
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	4a4080e7          	jalr	1188(ra) # 80003b5c <iunlockput>
  end_op();
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	c7a080e7          	jalr	-902(ra) # 8000433a <end_op>
  return -1;
    800056c8:	57fd                	li	a5,-1
}
    800056ca:	853e                	mv	a0,a5
    800056cc:	70b2                	ld	ra,296(sp)
    800056ce:	7412                	ld	s0,288(sp)
    800056d0:	64f2                	ld	s1,280(sp)
    800056d2:	6952                	ld	s2,272(sp)
    800056d4:	6155                	addi	sp,sp,304
    800056d6:	8082                	ret

00000000800056d8 <sys_unlink>:
{
    800056d8:	7151                	addi	sp,sp,-240
    800056da:	f586                	sd	ra,232(sp)
    800056dc:	f1a2                	sd	s0,224(sp)
    800056de:	eda6                	sd	s1,216(sp)
    800056e0:	e9ca                	sd	s2,208(sp)
    800056e2:	e5ce                	sd	s3,200(sp)
    800056e4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056e6:	08000613          	li	a2,128
    800056ea:	f3040593          	addi	a1,s0,-208
    800056ee:	4501                	li	a0,0
    800056f0:	ffffd097          	auipc	ra,0xffffd
    800056f4:	6dc080e7          	jalr	1756(ra) # 80002dcc <argstr>
    800056f8:	18054163          	bltz	a0,8000587a <sys_unlink+0x1a2>
  begin_op();
    800056fc:	fffff097          	auipc	ra,0xfffff
    80005700:	bbe080e7          	jalr	-1090(ra) # 800042ba <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005704:	fb040593          	addi	a1,s0,-80
    80005708:	f3040513          	addi	a0,s0,-208
    8000570c:	fffff097          	auipc	ra,0xfffff
    80005710:	9c0080e7          	jalr	-1600(ra) # 800040cc <nameiparent>
    80005714:	84aa                	mv	s1,a0
    80005716:	c979                	beqz	a0,800057ec <sys_unlink+0x114>
  ilock(dp);
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	1e2080e7          	jalr	482(ra) # 800038fa <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005720:	00003597          	auipc	a1,0x3
    80005724:	00058593          	mv	a1,a1
    80005728:	fb040513          	addi	a0,s0,-80
    8000572c:	ffffe097          	auipc	ra,0xffffe
    80005730:	696080e7          	jalr	1686(ra) # 80003dc2 <namecmp>
    80005734:	14050a63          	beqz	a0,80005888 <sys_unlink+0x1b0>
    80005738:	00003597          	auipc	a1,0x3
    8000573c:	ff058593          	addi	a1,a1,-16 # 80008728 <syscalls+0x2c8>
    80005740:	fb040513          	addi	a0,s0,-80
    80005744:	ffffe097          	auipc	ra,0xffffe
    80005748:	67e080e7          	jalr	1662(ra) # 80003dc2 <namecmp>
    8000574c:	12050e63          	beqz	a0,80005888 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005750:	f2c40613          	addi	a2,s0,-212
    80005754:	fb040593          	addi	a1,s0,-80
    80005758:	8526                	mv	a0,s1
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	682080e7          	jalr	1666(ra) # 80003ddc <dirlookup>
    80005762:	892a                	mv	s2,a0
    80005764:	12050263          	beqz	a0,80005888 <sys_unlink+0x1b0>
  ilock(ip);
    80005768:	ffffe097          	auipc	ra,0xffffe
    8000576c:	192080e7          	jalr	402(ra) # 800038fa <ilock>
  if(ip->nlink < 1)
    80005770:	04a91783          	lh	a5,74(s2)
    80005774:	08f05263          	blez	a5,800057f8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005778:	04491703          	lh	a4,68(s2)
    8000577c:	4785                	li	a5,1
    8000577e:	08f70563          	beq	a4,a5,80005808 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005782:	4641                	li	a2,16
    80005784:	4581                	li	a1,0
    80005786:	fc040513          	addi	a0,s0,-64
    8000578a:	ffffb097          	auipc	ra,0xffffb
    8000578e:	70c080e7          	jalr	1804(ra) # 80000e96 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005792:	4741                	li	a4,16
    80005794:	f2c42683          	lw	a3,-212(s0)
    80005798:	fc040613          	addi	a2,s0,-64
    8000579c:	4581                	li	a1,0
    8000579e:	8526                	mv	a0,s1
    800057a0:	ffffe097          	auipc	ra,0xffffe
    800057a4:	506080e7          	jalr	1286(ra) # 80003ca6 <writei>
    800057a8:	47c1                	li	a5,16
    800057aa:	0af51563          	bne	a0,a5,80005854 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057ae:	04491703          	lh	a4,68(s2)
    800057b2:	4785                	li	a5,1
    800057b4:	0af70863          	beq	a4,a5,80005864 <sys_unlink+0x18c>
  iunlockput(dp);
    800057b8:	8526                	mv	a0,s1
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	3a2080e7          	jalr	930(ra) # 80003b5c <iunlockput>
  ip->nlink--;
    800057c2:	04a95783          	lhu	a5,74(s2)
    800057c6:	37fd                	addiw	a5,a5,-1
    800057c8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057cc:	854a                	mv	a0,s2
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	062080e7          	jalr	98(ra) # 80003830 <iupdate>
  iunlockput(ip);
    800057d6:	854a                	mv	a0,s2
    800057d8:	ffffe097          	auipc	ra,0xffffe
    800057dc:	384080e7          	jalr	900(ra) # 80003b5c <iunlockput>
  end_op();
    800057e0:	fffff097          	auipc	ra,0xfffff
    800057e4:	b5a080e7          	jalr	-1190(ra) # 8000433a <end_op>
  return 0;
    800057e8:	4501                	li	a0,0
    800057ea:	a84d                	j	8000589c <sys_unlink+0x1c4>
    end_op();
    800057ec:	fffff097          	auipc	ra,0xfffff
    800057f0:	b4e080e7          	jalr	-1202(ra) # 8000433a <end_op>
    return -1;
    800057f4:	557d                	li	a0,-1
    800057f6:	a05d                	j	8000589c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800057f8:	00003517          	auipc	a0,0x3
    800057fc:	f5850513          	addi	a0,a0,-168 # 80008750 <syscalls+0x2f0>
    80005800:	ffffb097          	auipc	ra,0xffffb
    80005804:	d48080e7          	jalr	-696(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005808:	04c92703          	lw	a4,76(s2)
    8000580c:	02000793          	li	a5,32
    80005810:	f6e7f9e3          	bgeu	a5,a4,80005782 <sys_unlink+0xaa>
    80005814:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005818:	4741                	li	a4,16
    8000581a:	86ce                	mv	a3,s3
    8000581c:	f1840613          	addi	a2,s0,-232
    80005820:	4581                	li	a1,0
    80005822:	854a                	mv	a0,s2
    80005824:	ffffe097          	auipc	ra,0xffffe
    80005828:	38a080e7          	jalr	906(ra) # 80003bae <readi>
    8000582c:	47c1                	li	a5,16
    8000582e:	00f51b63          	bne	a0,a5,80005844 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005832:	f1845783          	lhu	a5,-232(s0)
    80005836:	e7a1                	bnez	a5,8000587e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005838:	29c1                	addiw	s3,s3,16
    8000583a:	04c92783          	lw	a5,76(s2)
    8000583e:	fcf9ede3          	bltu	s3,a5,80005818 <sys_unlink+0x140>
    80005842:	b781                	j	80005782 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005844:	00003517          	auipc	a0,0x3
    80005848:	f2450513          	addi	a0,a0,-220 # 80008768 <syscalls+0x308>
    8000584c:	ffffb097          	auipc	ra,0xffffb
    80005850:	cfc080e7          	jalr	-772(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005854:	00003517          	auipc	a0,0x3
    80005858:	f2c50513          	addi	a0,a0,-212 # 80008780 <syscalls+0x320>
    8000585c:	ffffb097          	auipc	ra,0xffffb
    80005860:	cec080e7          	jalr	-788(ra) # 80000548 <panic>
    dp->nlink--;
    80005864:	04a4d783          	lhu	a5,74(s1)
    80005868:	37fd                	addiw	a5,a5,-1
    8000586a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000586e:	8526                	mv	a0,s1
    80005870:	ffffe097          	auipc	ra,0xffffe
    80005874:	fc0080e7          	jalr	-64(ra) # 80003830 <iupdate>
    80005878:	b781                	j	800057b8 <sys_unlink+0xe0>
    return -1;
    8000587a:	557d                	li	a0,-1
    8000587c:	a005                	j	8000589c <sys_unlink+0x1c4>
    iunlockput(ip);
    8000587e:	854a                	mv	a0,s2
    80005880:	ffffe097          	auipc	ra,0xffffe
    80005884:	2dc080e7          	jalr	732(ra) # 80003b5c <iunlockput>
  iunlockput(dp);
    80005888:	8526                	mv	a0,s1
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	2d2080e7          	jalr	722(ra) # 80003b5c <iunlockput>
  end_op();
    80005892:	fffff097          	auipc	ra,0xfffff
    80005896:	aa8080e7          	jalr	-1368(ra) # 8000433a <end_op>
  return -1;
    8000589a:	557d                	li	a0,-1
}
    8000589c:	70ae                	ld	ra,232(sp)
    8000589e:	740e                	ld	s0,224(sp)
    800058a0:	64ee                	ld	s1,216(sp)
    800058a2:	694e                	ld	s2,208(sp)
    800058a4:	69ae                	ld	s3,200(sp)
    800058a6:	616d                	addi	sp,sp,240
    800058a8:	8082                	ret

00000000800058aa <sys_open>:

uint64
sys_open(void)
{
    800058aa:	7131                	addi	sp,sp,-192
    800058ac:	fd06                	sd	ra,184(sp)
    800058ae:	f922                	sd	s0,176(sp)
    800058b0:	f526                	sd	s1,168(sp)
    800058b2:	f14a                	sd	s2,160(sp)
    800058b4:	ed4e                	sd	s3,152(sp)
    800058b6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058b8:	08000613          	li	a2,128
    800058bc:	f5040593          	addi	a1,s0,-176
    800058c0:	4501                	li	a0,0
    800058c2:	ffffd097          	auipc	ra,0xffffd
    800058c6:	50a080e7          	jalr	1290(ra) # 80002dcc <argstr>
    return -1;
    800058ca:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058cc:	0c054163          	bltz	a0,8000598e <sys_open+0xe4>
    800058d0:	f4c40593          	addi	a1,s0,-180
    800058d4:	4505                	li	a0,1
    800058d6:	ffffd097          	auipc	ra,0xffffd
    800058da:	4b2080e7          	jalr	1202(ra) # 80002d88 <argint>
    800058de:	0a054863          	bltz	a0,8000598e <sys_open+0xe4>

  begin_op();
    800058e2:	fffff097          	auipc	ra,0xfffff
    800058e6:	9d8080e7          	jalr	-1576(ra) # 800042ba <begin_op>

  if(omode & O_CREATE){
    800058ea:	f4c42783          	lw	a5,-180(s0)
    800058ee:	2007f793          	andi	a5,a5,512
    800058f2:	cbdd                	beqz	a5,800059a8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058f4:	4681                	li	a3,0
    800058f6:	4601                	li	a2,0
    800058f8:	4589                	li	a1,2
    800058fa:	f5040513          	addi	a0,s0,-176
    800058fe:	00000097          	auipc	ra,0x0
    80005902:	972080e7          	jalr	-1678(ra) # 80005270 <create>
    80005906:	892a                	mv	s2,a0
    if(ip == 0){
    80005908:	c959                	beqz	a0,8000599e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000590a:	04491703          	lh	a4,68(s2)
    8000590e:	478d                	li	a5,3
    80005910:	00f71763          	bne	a4,a5,8000591e <sys_open+0x74>
    80005914:	04695703          	lhu	a4,70(s2)
    80005918:	47a5                	li	a5,9
    8000591a:	0ce7ec63          	bltu	a5,a4,800059f2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	db2080e7          	jalr	-590(ra) # 800046d0 <filealloc>
    80005926:	89aa                	mv	s3,a0
    80005928:	10050263          	beqz	a0,80005a2c <sys_open+0x182>
    8000592c:	00000097          	auipc	ra,0x0
    80005930:	902080e7          	jalr	-1790(ra) # 8000522e <fdalloc>
    80005934:	84aa                	mv	s1,a0
    80005936:	0e054663          	bltz	a0,80005a22 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000593a:	04491703          	lh	a4,68(s2)
    8000593e:	478d                	li	a5,3
    80005940:	0cf70463          	beq	a4,a5,80005a08 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005944:	4789                	li	a5,2
    80005946:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000594a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000594e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005952:	f4c42783          	lw	a5,-180(s0)
    80005956:	0017c713          	xori	a4,a5,1
    8000595a:	8b05                	andi	a4,a4,1
    8000595c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005960:	0037f713          	andi	a4,a5,3
    80005964:	00e03733          	snez	a4,a4
    80005968:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000596c:	4007f793          	andi	a5,a5,1024
    80005970:	c791                	beqz	a5,8000597c <sys_open+0xd2>
    80005972:	04491703          	lh	a4,68(s2)
    80005976:	4789                	li	a5,2
    80005978:	08f70f63          	beq	a4,a5,80005a16 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000597c:	854a                	mv	a0,s2
    8000597e:	ffffe097          	auipc	ra,0xffffe
    80005982:	03e080e7          	jalr	62(ra) # 800039bc <iunlock>
  end_op();
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	9b4080e7          	jalr	-1612(ra) # 8000433a <end_op>

  return fd;
}
    8000598e:	8526                	mv	a0,s1
    80005990:	70ea                	ld	ra,184(sp)
    80005992:	744a                	ld	s0,176(sp)
    80005994:	74aa                	ld	s1,168(sp)
    80005996:	790a                	ld	s2,160(sp)
    80005998:	69ea                	ld	s3,152(sp)
    8000599a:	6129                	addi	sp,sp,192
    8000599c:	8082                	ret
      end_op();
    8000599e:	fffff097          	auipc	ra,0xfffff
    800059a2:	99c080e7          	jalr	-1636(ra) # 8000433a <end_op>
      return -1;
    800059a6:	b7e5                	j	8000598e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059a8:	f5040513          	addi	a0,s0,-176
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	702080e7          	jalr	1794(ra) # 800040ae <namei>
    800059b4:	892a                	mv	s2,a0
    800059b6:	c905                	beqz	a0,800059e6 <sys_open+0x13c>
    ilock(ip);
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	f42080e7          	jalr	-190(ra) # 800038fa <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059c0:	04491703          	lh	a4,68(s2)
    800059c4:	4785                	li	a5,1
    800059c6:	f4f712e3          	bne	a4,a5,8000590a <sys_open+0x60>
    800059ca:	f4c42783          	lw	a5,-180(s0)
    800059ce:	dba1                	beqz	a5,8000591e <sys_open+0x74>
      iunlockput(ip);
    800059d0:	854a                	mv	a0,s2
    800059d2:	ffffe097          	auipc	ra,0xffffe
    800059d6:	18a080e7          	jalr	394(ra) # 80003b5c <iunlockput>
      end_op();
    800059da:	fffff097          	auipc	ra,0xfffff
    800059de:	960080e7          	jalr	-1696(ra) # 8000433a <end_op>
      return -1;
    800059e2:	54fd                	li	s1,-1
    800059e4:	b76d                	j	8000598e <sys_open+0xe4>
      end_op();
    800059e6:	fffff097          	auipc	ra,0xfffff
    800059ea:	954080e7          	jalr	-1708(ra) # 8000433a <end_op>
      return -1;
    800059ee:	54fd                	li	s1,-1
    800059f0:	bf79                	j	8000598e <sys_open+0xe4>
    iunlockput(ip);
    800059f2:	854a                	mv	a0,s2
    800059f4:	ffffe097          	auipc	ra,0xffffe
    800059f8:	168080e7          	jalr	360(ra) # 80003b5c <iunlockput>
    end_op();
    800059fc:	fffff097          	auipc	ra,0xfffff
    80005a00:	93e080e7          	jalr	-1730(ra) # 8000433a <end_op>
    return -1;
    80005a04:	54fd                	li	s1,-1
    80005a06:	b761                	j	8000598e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a08:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a0c:	04691783          	lh	a5,70(s2)
    80005a10:	02f99223          	sh	a5,36(s3)
    80005a14:	bf2d                	j	8000594e <sys_open+0xa4>
    itrunc(ip);
    80005a16:	854a                	mv	a0,s2
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	ff0080e7          	jalr	-16(ra) # 80003a08 <itrunc>
    80005a20:	bfb1                	j	8000597c <sys_open+0xd2>
      fileclose(f);
    80005a22:	854e                	mv	a0,s3
    80005a24:	fffff097          	auipc	ra,0xfffff
    80005a28:	d68080e7          	jalr	-664(ra) # 8000478c <fileclose>
    iunlockput(ip);
    80005a2c:	854a                	mv	a0,s2
    80005a2e:	ffffe097          	auipc	ra,0xffffe
    80005a32:	12e080e7          	jalr	302(ra) # 80003b5c <iunlockput>
    end_op();
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	904080e7          	jalr	-1788(ra) # 8000433a <end_op>
    return -1;
    80005a3e:	54fd                	li	s1,-1
    80005a40:	b7b9                	j	8000598e <sys_open+0xe4>

0000000080005a42 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a42:	7175                	addi	sp,sp,-144
    80005a44:	e506                	sd	ra,136(sp)
    80005a46:	e122                	sd	s0,128(sp)
    80005a48:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a4a:	fffff097          	auipc	ra,0xfffff
    80005a4e:	870080e7          	jalr	-1936(ra) # 800042ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a52:	08000613          	li	a2,128
    80005a56:	f7040593          	addi	a1,s0,-144
    80005a5a:	4501                	li	a0,0
    80005a5c:	ffffd097          	auipc	ra,0xffffd
    80005a60:	370080e7          	jalr	880(ra) # 80002dcc <argstr>
    80005a64:	02054963          	bltz	a0,80005a96 <sys_mkdir+0x54>
    80005a68:	4681                	li	a3,0
    80005a6a:	4601                	li	a2,0
    80005a6c:	4585                	li	a1,1
    80005a6e:	f7040513          	addi	a0,s0,-144
    80005a72:	fffff097          	auipc	ra,0xfffff
    80005a76:	7fe080e7          	jalr	2046(ra) # 80005270 <create>
    80005a7a:	cd11                	beqz	a0,80005a96 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	0e0080e7          	jalr	224(ra) # 80003b5c <iunlockput>
  end_op();
    80005a84:	fffff097          	auipc	ra,0xfffff
    80005a88:	8b6080e7          	jalr	-1866(ra) # 8000433a <end_op>
  return 0;
    80005a8c:	4501                	li	a0,0
}
    80005a8e:	60aa                	ld	ra,136(sp)
    80005a90:	640a                	ld	s0,128(sp)
    80005a92:	6149                	addi	sp,sp,144
    80005a94:	8082                	ret
    end_op();
    80005a96:	fffff097          	auipc	ra,0xfffff
    80005a9a:	8a4080e7          	jalr	-1884(ra) # 8000433a <end_op>
    return -1;
    80005a9e:	557d                	li	a0,-1
    80005aa0:	b7fd                	j	80005a8e <sys_mkdir+0x4c>

0000000080005aa2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005aa2:	7135                	addi	sp,sp,-160
    80005aa4:	ed06                	sd	ra,152(sp)
    80005aa6:	e922                	sd	s0,144(sp)
    80005aa8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	810080e7          	jalr	-2032(ra) # 800042ba <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ab2:	08000613          	li	a2,128
    80005ab6:	f7040593          	addi	a1,s0,-144
    80005aba:	4501                	li	a0,0
    80005abc:	ffffd097          	auipc	ra,0xffffd
    80005ac0:	310080e7          	jalr	784(ra) # 80002dcc <argstr>
    80005ac4:	04054a63          	bltz	a0,80005b18 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005ac8:	f6c40593          	addi	a1,s0,-148
    80005acc:	4505                	li	a0,1
    80005ace:	ffffd097          	auipc	ra,0xffffd
    80005ad2:	2ba080e7          	jalr	698(ra) # 80002d88 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ad6:	04054163          	bltz	a0,80005b18 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ada:	f6840593          	addi	a1,s0,-152
    80005ade:	4509                	li	a0,2
    80005ae0:	ffffd097          	auipc	ra,0xffffd
    80005ae4:	2a8080e7          	jalr	680(ra) # 80002d88 <argint>
     argint(1, &major) < 0 ||
    80005ae8:	02054863          	bltz	a0,80005b18 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005aec:	f6841683          	lh	a3,-152(s0)
    80005af0:	f6c41603          	lh	a2,-148(s0)
    80005af4:	458d                	li	a1,3
    80005af6:	f7040513          	addi	a0,s0,-144
    80005afa:	fffff097          	auipc	ra,0xfffff
    80005afe:	776080e7          	jalr	1910(ra) # 80005270 <create>
     argint(2, &minor) < 0 ||
    80005b02:	c919                	beqz	a0,80005b18 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b04:	ffffe097          	auipc	ra,0xffffe
    80005b08:	058080e7          	jalr	88(ra) # 80003b5c <iunlockput>
  end_op();
    80005b0c:	fffff097          	auipc	ra,0xfffff
    80005b10:	82e080e7          	jalr	-2002(ra) # 8000433a <end_op>
  return 0;
    80005b14:	4501                	li	a0,0
    80005b16:	a031                	j	80005b22 <sys_mknod+0x80>
    end_op();
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	822080e7          	jalr	-2014(ra) # 8000433a <end_op>
    return -1;
    80005b20:	557d                	li	a0,-1
}
    80005b22:	60ea                	ld	ra,152(sp)
    80005b24:	644a                	ld	s0,144(sp)
    80005b26:	610d                	addi	sp,sp,160
    80005b28:	8082                	ret

0000000080005b2a <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b2a:	7135                	addi	sp,sp,-160
    80005b2c:	ed06                	sd	ra,152(sp)
    80005b2e:	e922                	sd	s0,144(sp)
    80005b30:	e526                	sd	s1,136(sp)
    80005b32:	e14a                	sd	s2,128(sp)
    80005b34:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b36:	ffffc097          	auipc	ra,0xffffc
    80005b3a:	150080e7          	jalr	336(ra) # 80001c86 <myproc>
    80005b3e:	892a                	mv	s2,a0
  
  begin_op();
    80005b40:	ffffe097          	auipc	ra,0xffffe
    80005b44:	77a080e7          	jalr	1914(ra) # 800042ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b48:	08000613          	li	a2,128
    80005b4c:	f6040593          	addi	a1,s0,-160
    80005b50:	4501                	li	a0,0
    80005b52:	ffffd097          	auipc	ra,0xffffd
    80005b56:	27a080e7          	jalr	634(ra) # 80002dcc <argstr>
    80005b5a:	04054b63          	bltz	a0,80005bb0 <sys_chdir+0x86>
    80005b5e:	f6040513          	addi	a0,s0,-160
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	54c080e7          	jalr	1356(ra) # 800040ae <namei>
    80005b6a:	84aa                	mv	s1,a0
    80005b6c:	c131                	beqz	a0,80005bb0 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	d8c080e7          	jalr	-628(ra) # 800038fa <ilock>
  if(ip->type != T_DIR){
    80005b76:	04449703          	lh	a4,68(s1)
    80005b7a:	4785                	li	a5,1
    80005b7c:	04f71063          	bne	a4,a5,80005bbc <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b80:	8526                	mv	a0,s1
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	e3a080e7          	jalr	-454(ra) # 800039bc <iunlock>
  iput(p->cwd);
    80005b8a:	15093503          	ld	a0,336(s2)
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	f26080e7          	jalr	-218(ra) # 80003ab4 <iput>
  end_op();
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	7a4080e7          	jalr	1956(ra) # 8000433a <end_op>
  p->cwd = ip;
    80005b9e:	14993823          	sd	s1,336(s2)
  return 0;
    80005ba2:	4501                	li	a0,0
}
    80005ba4:	60ea                	ld	ra,152(sp)
    80005ba6:	644a                	ld	s0,144(sp)
    80005ba8:	64aa                	ld	s1,136(sp)
    80005baa:	690a                	ld	s2,128(sp)
    80005bac:	610d                	addi	sp,sp,160
    80005bae:	8082                	ret
    end_op();
    80005bb0:	ffffe097          	auipc	ra,0xffffe
    80005bb4:	78a080e7          	jalr	1930(ra) # 8000433a <end_op>
    return -1;
    80005bb8:	557d                	li	a0,-1
    80005bba:	b7ed                	j	80005ba4 <sys_chdir+0x7a>
    iunlockput(ip);
    80005bbc:	8526                	mv	a0,s1
    80005bbe:	ffffe097          	auipc	ra,0xffffe
    80005bc2:	f9e080e7          	jalr	-98(ra) # 80003b5c <iunlockput>
    end_op();
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	774080e7          	jalr	1908(ra) # 8000433a <end_op>
    return -1;
    80005bce:	557d                	li	a0,-1
    80005bd0:	bfd1                	j	80005ba4 <sys_chdir+0x7a>

0000000080005bd2 <sys_exec>:

uint64
sys_exec(void)
{
    80005bd2:	7145                	addi	sp,sp,-464
    80005bd4:	e786                	sd	ra,456(sp)
    80005bd6:	e3a2                	sd	s0,448(sp)
    80005bd8:	ff26                	sd	s1,440(sp)
    80005bda:	fb4a                	sd	s2,432(sp)
    80005bdc:	f74e                	sd	s3,424(sp)
    80005bde:	f352                	sd	s4,416(sp)
    80005be0:	ef56                	sd	s5,408(sp)
    80005be2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005be4:	08000613          	li	a2,128
    80005be8:	f4040593          	addi	a1,s0,-192
    80005bec:	4501                	li	a0,0
    80005bee:	ffffd097          	auipc	ra,0xffffd
    80005bf2:	1de080e7          	jalr	478(ra) # 80002dcc <argstr>
    return -1;
    80005bf6:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bf8:	0c054a63          	bltz	a0,80005ccc <sys_exec+0xfa>
    80005bfc:	e3840593          	addi	a1,s0,-456
    80005c00:	4505                	li	a0,1
    80005c02:	ffffd097          	auipc	ra,0xffffd
    80005c06:	1a8080e7          	jalr	424(ra) # 80002daa <argaddr>
    80005c0a:	0c054163          	bltz	a0,80005ccc <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c0e:	10000613          	li	a2,256
    80005c12:	4581                	li	a1,0
    80005c14:	e4040513          	addi	a0,s0,-448
    80005c18:	ffffb097          	auipc	ra,0xffffb
    80005c1c:	27e080e7          	jalr	638(ra) # 80000e96 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c20:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c24:	89a6                	mv	s3,s1
    80005c26:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c28:	02000a13          	li	s4,32
    80005c2c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c30:	00391513          	slli	a0,s2,0x3
    80005c34:	e3040593          	addi	a1,s0,-464
    80005c38:	e3843783          	ld	a5,-456(s0)
    80005c3c:	953e                	add	a0,a0,a5
    80005c3e:	ffffd097          	auipc	ra,0xffffd
    80005c42:	0b0080e7          	jalr	176(ra) # 80002cee <fetchaddr>
    80005c46:	02054a63          	bltz	a0,80005c7a <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005c4a:	e3043783          	ld	a5,-464(s0)
    80005c4e:	c3b9                	beqz	a5,80005c94 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c50:	ffffb097          	auipc	ra,0xffffb
    80005c54:	f3a080e7          	jalr	-198(ra) # 80000b8a <kalloc>
    80005c58:	85aa                	mv	a1,a0
    80005c5a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c5e:	cd11                	beqz	a0,80005c7a <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c60:	6605                	lui	a2,0x1
    80005c62:	e3043503          	ld	a0,-464(s0)
    80005c66:	ffffd097          	auipc	ra,0xffffd
    80005c6a:	0da080e7          	jalr	218(ra) # 80002d40 <fetchstr>
    80005c6e:	00054663          	bltz	a0,80005c7a <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005c72:	0905                	addi	s2,s2,1
    80005c74:	09a1                	addi	s3,s3,8
    80005c76:	fb491be3          	bne	s2,s4,80005c2c <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c7a:	10048913          	addi	s2,s1,256
    80005c7e:	6088                	ld	a0,0(s1)
    80005c80:	c529                	beqz	a0,80005cca <sys_exec+0xf8>
    kfree(argv[i]);
    80005c82:	ffffb097          	auipc	ra,0xffffb
    80005c86:	da2080e7          	jalr	-606(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c8a:	04a1                	addi	s1,s1,8
    80005c8c:	ff2499e3          	bne	s1,s2,80005c7e <sys_exec+0xac>
  return -1;
    80005c90:	597d                	li	s2,-1
    80005c92:	a82d                	j	80005ccc <sys_exec+0xfa>
      argv[i] = 0;
    80005c94:	0a8e                	slli	s5,s5,0x3
    80005c96:	fc040793          	addi	a5,s0,-64
    80005c9a:	9abe                	add	s5,s5,a5
    80005c9c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ca0:	e4040593          	addi	a1,s0,-448
    80005ca4:	f4040513          	addi	a0,s0,-192
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	194080e7          	jalr	404(ra) # 80004e3c <exec>
    80005cb0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cb2:	10048993          	addi	s3,s1,256
    80005cb6:	6088                	ld	a0,0(s1)
    80005cb8:	c911                	beqz	a0,80005ccc <sys_exec+0xfa>
    kfree(argv[i]);
    80005cba:	ffffb097          	auipc	ra,0xffffb
    80005cbe:	d6a080e7          	jalr	-662(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cc2:	04a1                	addi	s1,s1,8
    80005cc4:	ff3499e3          	bne	s1,s3,80005cb6 <sys_exec+0xe4>
    80005cc8:	a011                	j	80005ccc <sys_exec+0xfa>
  return -1;
    80005cca:	597d                	li	s2,-1
}
    80005ccc:	854a                	mv	a0,s2
    80005cce:	60be                	ld	ra,456(sp)
    80005cd0:	641e                	ld	s0,448(sp)
    80005cd2:	74fa                	ld	s1,440(sp)
    80005cd4:	795a                	ld	s2,432(sp)
    80005cd6:	79ba                	ld	s3,424(sp)
    80005cd8:	7a1a                	ld	s4,416(sp)
    80005cda:	6afa                	ld	s5,408(sp)
    80005cdc:	6179                	addi	sp,sp,464
    80005cde:	8082                	ret

0000000080005ce0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ce0:	7139                	addi	sp,sp,-64
    80005ce2:	fc06                	sd	ra,56(sp)
    80005ce4:	f822                	sd	s0,48(sp)
    80005ce6:	f426                	sd	s1,40(sp)
    80005ce8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cea:	ffffc097          	auipc	ra,0xffffc
    80005cee:	f9c080e7          	jalr	-100(ra) # 80001c86 <myproc>
    80005cf2:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005cf4:	fd840593          	addi	a1,s0,-40
    80005cf8:	4501                	li	a0,0
    80005cfa:	ffffd097          	auipc	ra,0xffffd
    80005cfe:	0b0080e7          	jalr	176(ra) # 80002daa <argaddr>
    return -1;
    80005d02:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d04:	0e054063          	bltz	a0,80005de4 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d08:	fc840593          	addi	a1,s0,-56
    80005d0c:	fd040513          	addi	a0,s0,-48
    80005d10:	fffff097          	auipc	ra,0xfffff
    80005d14:	dd2080e7          	jalr	-558(ra) # 80004ae2 <pipealloc>
    return -1;
    80005d18:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d1a:	0c054563          	bltz	a0,80005de4 <sys_pipe+0x104>
  fd0 = -1;
    80005d1e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d22:	fd043503          	ld	a0,-48(s0)
    80005d26:	fffff097          	auipc	ra,0xfffff
    80005d2a:	508080e7          	jalr	1288(ra) # 8000522e <fdalloc>
    80005d2e:	fca42223          	sw	a0,-60(s0)
    80005d32:	08054c63          	bltz	a0,80005dca <sys_pipe+0xea>
    80005d36:	fc843503          	ld	a0,-56(s0)
    80005d3a:	fffff097          	auipc	ra,0xfffff
    80005d3e:	4f4080e7          	jalr	1268(ra) # 8000522e <fdalloc>
    80005d42:	fca42023          	sw	a0,-64(s0)
    80005d46:	06054863          	bltz	a0,80005db6 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d4a:	4691                	li	a3,4
    80005d4c:	fc440613          	addi	a2,s0,-60
    80005d50:	fd843583          	ld	a1,-40(s0)
    80005d54:	68a8                	ld	a0,80(s1)
    80005d56:	ffffc097          	auipc	ra,0xffffc
    80005d5a:	d4c080e7          	jalr	-692(ra) # 80001aa2 <copyout>
    80005d5e:	02054063          	bltz	a0,80005d7e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d62:	4691                	li	a3,4
    80005d64:	fc040613          	addi	a2,s0,-64
    80005d68:	fd843583          	ld	a1,-40(s0)
    80005d6c:	0591                	addi	a1,a1,4
    80005d6e:	68a8                	ld	a0,80(s1)
    80005d70:	ffffc097          	auipc	ra,0xffffc
    80005d74:	d32080e7          	jalr	-718(ra) # 80001aa2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d78:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d7a:	06055563          	bgez	a0,80005de4 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d7e:	fc442783          	lw	a5,-60(s0)
    80005d82:	07e9                	addi	a5,a5,26
    80005d84:	078e                	slli	a5,a5,0x3
    80005d86:	97a6                	add	a5,a5,s1
    80005d88:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d8c:	fc042503          	lw	a0,-64(s0)
    80005d90:	0569                	addi	a0,a0,26
    80005d92:	050e                	slli	a0,a0,0x3
    80005d94:	9526                	add	a0,a0,s1
    80005d96:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005d9a:	fd043503          	ld	a0,-48(s0)
    80005d9e:	fffff097          	auipc	ra,0xfffff
    80005da2:	9ee080e7          	jalr	-1554(ra) # 8000478c <fileclose>
    fileclose(wf);
    80005da6:	fc843503          	ld	a0,-56(s0)
    80005daa:	fffff097          	auipc	ra,0xfffff
    80005dae:	9e2080e7          	jalr	-1566(ra) # 8000478c <fileclose>
    return -1;
    80005db2:	57fd                	li	a5,-1
    80005db4:	a805                	j	80005de4 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005db6:	fc442783          	lw	a5,-60(s0)
    80005dba:	0007c863          	bltz	a5,80005dca <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005dbe:	01a78513          	addi	a0,a5,26
    80005dc2:	050e                	slli	a0,a0,0x3
    80005dc4:	9526                	add	a0,a0,s1
    80005dc6:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005dca:	fd043503          	ld	a0,-48(s0)
    80005dce:	fffff097          	auipc	ra,0xfffff
    80005dd2:	9be080e7          	jalr	-1602(ra) # 8000478c <fileclose>
    fileclose(wf);
    80005dd6:	fc843503          	ld	a0,-56(s0)
    80005dda:	fffff097          	auipc	ra,0xfffff
    80005dde:	9b2080e7          	jalr	-1614(ra) # 8000478c <fileclose>
    return -1;
    80005de2:	57fd                	li	a5,-1
}
    80005de4:	853e                	mv	a0,a5
    80005de6:	70e2                	ld	ra,56(sp)
    80005de8:	7442                	ld	s0,48(sp)
    80005dea:	74a2                	ld	s1,40(sp)
    80005dec:	6121                	addi	sp,sp,64
    80005dee:	8082                	ret

0000000080005df0 <kernelvec>:
    80005df0:	7111                	addi	sp,sp,-256
    80005df2:	e006                	sd	ra,0(sp)
    80005df4:	e40a                	sd	sp,8(sp)
    80005df6:	e80e                	sd	gp,16(sp)
    80005df8:	ec12                	sd	tp,24(sp)
    80005dfa:	f016                	sd	t0,32(sp)
    80005dfc:	f41a                	sd	t1,40(sp)
    80005dfe:	f81e                	sd	t2,48(sp)
    80005e00:	fc22                	sd	s0,56(sp)
    80005e02:	e0a6                	sd	s1,64(sp)
    80005e04:	e4aa                	sd	a0,72(sp)
    80005e06:	e8ae                	sd	a1,80(sp)
    80005e08:	ecb2                	sd	a2,88(sp)
    80005e0a:	f0b6                	sd	a3,96(sp)
    80005e0c:	f4ba                	sd	a4,104(sp)
    80005e0e:	f8be                	sd	a5,112(sp)
    80005e10:	fcc2                	sd	a6,120(sp)
    80005e12:	e146                	sd	a7,128(sp)
    80005e14:	e54a                	sd	s2,136(sp)
    80005e16:	e94e                	sd	s3,144(sp)
    80005e18:	ed52                	sd	s4,152(sp)
    80005e1a:	f156                	sd	s5,160(sp)
    80005e1c:	f55a                	sd	s6,168(sp)
    80005e1e:	f95e                	sd	s7,176(sp)
    80005e20:	fd62                	sd	s8,184(sp)
    80005e22:	e1e6                	sd	s9,192(sp)
    80005e24:	e5ea                	sd	s10,200(sp)
    80005e26:	e9ee                	sd	s11,208(sp)
    80005e28:	edf2                	sd	t3,216(sp)
    80005e2a:	f1f6                	sd	t4,224(sp)
    80005e2c:	f5fa                	sd	t5,232(sp)
    80005e2e:	f9fe                	sd	t6,240(sp)
    80005e30:	d8bfc0ef          	jal	ra,80002bba <kerneltrap>
    80005e34:	6082                	ld	ra,0(sp)
    80005e36:	6122                	ld	sp,8(sp)
    80005e38:	61c2                	ld	gp,16(sp)
    80005e3a:	7282                	ld	t0,32(sp)
    80005e3c:	7322                	ld	t1,40(sp)
    80005e3e:	73c2                	ld	t2,48(sp)
    80005e40:	7462                	ld	s0,56(sp)
    80005e42:	6486                	ld	s1,64(sp)
    80005e44:	6526                	ld	a0,72(sp)
    80005e46:	65c6                	ld	a1,80(sp)
    80005e48:	6666                	ld	a2,88(sp)
    80005e4a:	7686                	ld	a3,96(sp)
    80005e4c:	7726                	ld	a4,104(sp)
    80005e4e:	77c6                	ld	a5,112(sp)
    80005e50:	7866                	ld	a6,120(sp)
    80005e52:	688a                	ld	a7,128(sp)
    80005e54:	692a                	ld	s2,136(sp)
    80005e56:	69ca                	ld	s3,144(sp)
    80005e58:	6a6a                	ld	s4,152(sp)
    80005e5a:	7a8a                	ld	s5,160(sp)
    80005e5c:	7b2a                	ld	s6,168(sp)
    80005e5e:	7bca                	ld	s7,176(sp)
    80005e60:	7c6a                	ld	s8,184(sp)
    80005e62:	6c8e                	ld	s9,192(sp)
    80005e64:	6d2e                	ld	s10,200(sp)
    80005e66:	6dce                	ld	s11,208(sp)
    80005e68:	6e6e                	ld	t3,216(sp)
    80005e6a:	7e8e                	ld	t4,224(sp)
    80005e6c:	7f2e                	ld	t5,232(sp)
    80005e6e:	7fce                	ld	t6,240(sp)
    80005e70:	6111                	addi	sp,sp,256
    80005e72:	10200073          	sret
    80005e76:	00000013          	nop
    80005e7a:	00000013          	nop
    80005e7e:	0001                	nop

0000000080005e80 <timervec>:
    80005e80:	34051573          	csrrw	a0,mscratch,a0
    80005e84:	e10c                	sd	a1,0(a0)
    80005e86:	e510                	sd	a2,8(a0)
    80005e88:	e914                	sd	a3,16(a0)
    80005e8a:	710c                	ld	a1,32(a0)
    80005e8c:	7510                	ld	a2,40(a0)
    80005e8e:	6194                	ld	a3,0(a1)
    80005e90:	96b2                	add	a3,a3,a2
    80005e92:	e194                	sd	a3,0(a1)
    80005e94:	4589                	li	a1,2
    80005e96:	14459073          	csrw	sip,a1
    80005e9a:	6914                	ld	a3,16(a0)
    80005e9c:	6510                	ld	a2,8(a0)
    80005e9e:	610c                	ld	a1,0(a0)
    80005ea0:	34051573          	csrrw	a0,mscratch,a0
    80005ea4:	30200073          	mret
	...

0000000080005eaa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eaa:	1141                	addi	sp,sp,-16
    80005eac:	e422                	sd	s0,8(sp)
    80005eae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005eb0:	0c0007b7          	lui	a5,0xc000
    80005eb4:	4705                	li	a4,1
    80005eb6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005eb8:	c3d8                	sw	a4,4(a5)
}
    80005eba:	6422                	ld	s0,8(sp)
    80005ebc:	0141                	addi	sp,sp,16
    80005ebe:	8082                	ret

0000000080005ec0 <plicinithart>:

void
plicinithart(void)
{
    80005ec0:	1141                	addi	sp,sp,-16
    80005ec2:	e406                	sd	ra,8(sp)
    80005ec4:	e022                	sd	s0,0(sp)
    80005ec6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ec8:	ffffc097          	auipc	ra,0xffffc
    80005ecc:	d92080e7          	jalr	-622(ra) # 80001c5a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ed0:	0085171b          	slliw	a4,a0,0x8
    80005ed4:	0c0027b7          	lui	a5,0xc002
    80005ed8:	97ba                	add	a5,a5,a4
    80005eda:	40200713          	li	a4,1026
    80005ede:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ee2:	00d5151b          	slliw	a0,a0,0xd
    80005ee6:	0c2017b7          	lui	a5,0xc201
    80005eea:	953e                	add	a0,a0,a5
    80005eec:	00052023          	sw	zero,0(a0)
}
    80005ef0:	60a2                	ld	ra,8(sp)
    80005ef2:	6402                	ld	s0,0(sp)
    80005ef4:	0141                	addi	sp,sp,16
    80005ef6:	8082                	ret

0000000080005ef8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ef8:	1141                	addi	sp,sp,-16
    80005efa:	e406                	sd	ra,8(sp)
    80005efc:	e022                	sd	s0,0(sp)
    80005efe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f00:	ffffc097          	auipc	ra,0xffffc
    80005f04:	d5a080e7          	jalr	-678(ra) # 80001c5a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f08:	00d5179b          	slliw	a5,a0,0xd
    80005f0c:	0c201537          	lui	a0,0xc201
    80005f10:	953e                	add	a0,a0,a5
  return irq;
}
    80005f12:	4148                	lw	a0,4(a0)
    80005f14:	60a2                	ld	ra,8(sp)
    80005f16:	6402                	ld	s0,0(sp)
    80005f18:	0141                	addi	sp,sp,16
    80005f1a:	8082                	ret

0000000080005f1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f1c:	1101                	addi	sp,sp,-32
    80005f1e:	ec06                	sd	ra,24(sp)
    80005f20:	e822                	sd	s0,16(sp)
    80005f22:	e426                	sd	s1,8(sp)
    80005f24:	1000                	addi	s0,sp,32
    80005f26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f28:	ffffc097          	auipc	ra,0xffffc
    80005f2c:	d32080e7          	jalr	-718(ra) # 80001c5a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f30:	00d5151b          	slliw	a0,a0,0xd
    80005f34:	0c2017b7          	lui	a5,0xc201
    80005f38:	97aa                	add	a5,a5,a0
    80005f3a:	c3c4                	sw	s1,4(a5)
}
    80005f3c:	60e2                	ld	ra,24(sp)
    80005f3e:	6442                	ld	s0,16(sp)
    80005f40:	64a2                	ld	s1,8(sp)
    80005f42:	6105                	addi	sp,sp,32
    80005f44:	8082                	ret

0000000080005f46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f46:	1141                	addi	sp,sp,-16
    80005f48:	e406                	sd	ra,8(sp)
    80005f4a:	e022                	sd	s0,0(sp)
    80005f4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f4e:	479d                	li	a5,7
    80005f50:	04a7cc63          	blt	a5,a0,80005fa8 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005f54:	0003d797          	auipc	a5,0x3d
    80005f58:	0ac78793          	addi	a5,a5,172 # 80043000 <disk>
    80005f5c:	00a78733          	add	a4,a5,a0
    80005f60:	6789                	lui	a5,0x2
    80005f62:	97ba                	add	a5,a5,a4
    80005f64:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f68:	eba1                	bnez	a5,80005fb8 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f6a:	00451713          	slli	a4,a0,0x4
    80005f6e:	0003f797          	auipc	a5,0x3f
    80005f72:	0927b783          	ld	a5,146(a5) # 80045000 <disk+0x2000>
    80005f76:	97ba                	add	a5,a5,a4
    80005f78:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f7c:	0003d797          	auipc	a5,0x3d
    80005f80:	08478793          	addi	a5,a5,132 # 80043000 <disk>
    80005f84:	97aa                	add	a5,a5,a0
    80005f86:	6509                	lui	a0,0x2
    80005f88:	953e                	add	a0,a0,a5
    80005f8a:	4785                	li	a5,1
    80005f8c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005f90:	0003f517          	auipc	a0,0x3f
    80005f94:	08850513          	addi	a0,a0,136 # 80045018 <disk+0x2018>
    80005f98:	ffffc097          	auipc	ra,0xffffc
    80005f9c:	684080e7          	jalr	1668(ra) # 8000261c <wakeup>
}
    80005fa0:	60a2                	ld	ra,8(sp)
    80005fa2:	6402                	ld	s0,0(sp)
    80005fa4:	0141                	addi	sp,sp,16
    80005fa6:	8082                	ret
    panic("virtio_disk_intr 1");
    80005fa8:	00002517          	auipc	a0,0x2
    80005fac:	7e850513          	addi	a0,a0,2024 # 80008790 <syscalls+0x330>
    80005fb0:	ffffa097          	auipc	ra,0xffffa
    80005fb4:	598080e7          	jalr	1432(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80005fb8:	00002517          	auipc	a0,0x2
    80005fbc:	7f050513          	addi	a0,a0,2032 # 800087a8 <syscalls+0x348>
    80005fc0:	ffffa097          	auipc	ra,0xffffa
    80005fc4:	588080e7          	jalr	1416(ra) # 80000548 <panic>

0000000080005fc8 <virtio_disk_init>:
{
    80005fc8:	1101                	addi	sp,sp,-32
    80005fca:	ec06                	sd	ra,24(sp)
    80005fcc:	e822                	sd	s0,16(sp)
    80005fce:	e426                	sd	s1,8(sp)
    80005fd0:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fd2:	00002597          	auipc	a1,0x2
    80005fd6:	7ee58593          	addi	a1,a1,2030 # 800087c0 <syscalls+0x360>
    80005fda:	0003f517          	auipc	a0,0x3f
    80005fde:	0ce50513          	addi	a0,a0,206 # 800450a8 <disk+0x20a8>
    80005fe2:	ffffb097          	auipc	ra,0xffffb
    80005fe6:	d28080e7          	jalr	-728(ra) # 80000d0a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fea:	100017b7          	lui	a5,0x10001
    80005fee:	4398                	lw	a4,0(a5)
    80005ff0:	2701                	sext.w	a4,a4
    80005ff2:	747277b7          	lui	a5,0x74727
    80005ff6:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ffa:	0ef71163          	bne	a4,a5,800060dc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005ffe:	100017b7          	lui	a5,0x10001
    80006002:	43dc                	lw	a5,4(a5)
    80006004:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006006:	4705                	li	a4,1
    80006008:	0ce79a63          	bne	a5,a4,800060dc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000600c:	100017b7          	lui	a5,0x10001
    80006010:	479c                	lw	a5,8(a5)
    80006012:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006014:	4709                	li	a4,2
    80006016:	0ce79363          	bne	a5,a4,800060dc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000601a:	100017b7          	lui	a5,0x10001
    8000601e:	47d8                	lw	a4,12(a5)
    80006020:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006022:	554d47b7          	lui	a5,0x554d4
    80006026:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000602a:	0af71963          	bne	a4,a5,800060dc <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000602e:	100017b7          	lui	a5,0x10001
    80006032:	4705                	li	a4,1
    80006034:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006036:	470d                	li	a4,3
    80006038:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000603a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000603c:	c7ffe737          	lui	a4,0xc7ffe
    80006040:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fb875f>
    80006044:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006046:	2701                	sext.w	a4,a4
    80006048:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000604a:	472d                	li	a4,11
    8000604c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000604e:	473d                	li	a4,15
    80006050:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006052:	6705                	lui	a4,0x1
    80006054:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006056:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000605a:	5bdc                	lw	a5,52(a5)
    8000605c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000605e:	c7d9                	beqz	a5,800060ec <virtio_disk_init+0x124>
  if(max < NUM)
    80006060:	471d                	li	a4,7
    80006062:	08f77d63          	bgeu	a4,a5,800060fc <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006066:	100014b7          	lui	s1,0x10001
    8000606a:	47a1                	li	a5,8
    8000606c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    8000606e:	6609                	lui	a2,0x2
    80006070:	4581                	li	a1,0
    80006072:	0003d517          	auipc	a0,0x3d
    80006076:	f8e50513          	addi	a0,a0,-114 # 80043000 <disk>
    8000607a:	ffffb097          	auipc	ra,0xffffb
    8000607e:	e1c080e7          	jalr	-484(ra) # 80000e96 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006082:	0003d717          	auipc	a4,0x3d
    80006086:	f7e70713          	addi	a4,a4,-130 # 80043000 <disk>
    8000608a:	00c75793          	srli	a5,a4,0xc
    8000608e:	2781                	sext.w	a5,a5
    80006090:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006092:	0003f797          	auipc	a5,0x3f
    80006096:	f6e78793          	addi	a5,a5,-146 # 80045000 <disk+0x2000>
    8000609a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000609c:	0003d717          	auipc	a4,0x3d
    800060a0:	fe470713          	addi	a4,a4,-28 # 80043080 <disk+0x80>
    800060a4:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    800060a6:	0003e717          	auipc	a4,0x3e
    800060aa:	f5a70713          	addi	a4,a4,-166 # 80044000 <disk+0x1000>
    800060ae:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800060b0:	4705                	li	a4,1
    800060b2:	00e78c23          	sb	a4,24(a5)
    800060b6:	00e78ca3          	sb	a4,25(a5)
    800060ba:	00e78d23          	sb	a4,26(a5)
    800060be:	00e78da3          	sb	a4,27(a5)
    800060c2:	00e78e23          	sb	a4,28(a5)
    800060c6:	00e78ea3          	sb	a4,29(a5)
    800060ca:	00e78f23          	sb	a4,30(a5)
    800060ce:	00e78fa3          	sb	a4,31(a5)
}
    800060d2:	60e2                	ld	ra,24(sp)
    800060d4:	6442                	ld	s0,16(sp)
    800060d6:	64a2                	ld	s1,8(sp)
    800060d8:	6105                	addi	sp,sp,32
    800060da:	8082                	ret
    panic("could not find virtio disk");
    800060dc:	00002517          	auipc	a0,0x2
    800060e0:	6f450513          	addi	a0,a0,1780 # 800087d0 <syscalls+0x370>
    800060e4:	ffffa097          	auipc	ra,0xffffa
    800060e8:	464080e7          	jalr	1124(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    800060ec:	00002517          	auipc	a0,0x2
    800060f0:	70450513          	addi	a0,a0,1796 # 800087f0 <syscalls+0x390>
    800060f4:	ffffa097          	auipc	ra,0xffffa
    800060f8:	454080e7          	jalr	1108(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    800060fc:	00002517          	auipc	a0,0x2
    80006100:	71450513          	addi	a0,a0,1812 # 80008810 <syscalls+0x3b0>
    80006104:	ffffa097          	auipc	ra,0xffffa
    80006108:	444080e7          	jalr	1092(ra) # 80000548 <panic>

000000008000610c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000610c:	7119                	addi	sp,sp,-128
    8000610e:	fc86                	sd	ra,120(sp)
    80006110:	f8a2                	sd	s0,112(sp)
    80006112:	f4a6                	sd	s1,104(sp)
    80006114:	f0ca                	sd	s2,96(sp)
    80006116:	ecce                	sd	s3,88(sp)
    80006118:	e8d2                	sd	s4,80(sp)
    8000611a:	e4d6                	sd	s5,72(sp)
    8000611c:	e0da                	sd	s6,64(sp)
    8000611e:	fc5e                	sd	s7,56(sp)
    80006120:	f862                	sd	s8,48(sp)
    80006122:	f466                	sd	s9,40(sp)
    80006124:	f06a                	sd	s10,32(sp)
    80006126:	0100                	addi	s0,sp,128
    80006128:	892a                	mv	s2,a0
    8000612a:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000612c:	00c52c83          	lw	s9,12(a0)
    80006130:	001c9c9b          	slliw	s9,s9,0x1
    80006134:	1c82                	slli	s9,s9,0x20
    80006136:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000613a:	0003f517          	auipc	a0,0x3f
    8000613e:	f6e50513          	addi	a0,a0,-146 # 800450a8 <disk+0x20a8>
    80006142:	ffffb097          	auipc	ra,0xffffb
    80006146:	c58080e7          	jalr	-936(ra) # 80000d9a <acquire>
  for(int i = 0; i < 3; i++){
    8000614a:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000614c:	4c21                	li	s8,8
      disk.free[i] = 0;
    8000614e:	0003db97          	auipc	s7,0x3d
    80006152:	eb2b8b93          	addi	s7,s7,-334 # 80043000 <disk>
    80006156:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006158:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    8000615a:	8a4e                	mv	s4,s3
    8000615c:	a051                	j	800061e0 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    8000615e:	00fb86b3          	add	a3,s7,a5
    80006162:	96da                	add	a3,a3,s6
    80006164:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006168:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000616a:	0207c563          	bltz	a5,80006194 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000616e:	2485                	addiw	s1,s1,1
    80006170:	0711                	addi	a4,a4,4
    80006172:	23548d63          	beq	s1,s5,800063ac <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80006176:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006178:	0003f697          	auipc	a3,0x3f
    8000617c:	ea068693          	addi	a3,a3,-352 # 80045018 <disk+0x2018>
    80006180:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006182:	0006c583          	lbu	a1,0(a3)
    80006186:	fde1                	bnez	a1,8000615e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006188:	2785                	addiw	a5,a5,1
    8000618a:	0685                	addi	a3,a3,1
    8000618c:	ff879be3          	bne	a5,s8,80006182 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006190:	57fd                	li	a5,-1
    80006192:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006194:	02905a63          	blez	s1,800061c8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006198:	f9042503          	lw	a0,-112(s0)
    8000619c:	00000097          	auipc	ra,0x0
    800061a0:	daa080e7          	jalr	-598(ra) # 80005f46 <free_desc>
      for(int j = 0; j < i; j++)
    800061a4:	4785                	li	a5,1
    800061a6:	0297d163          	bge	a5,s1,800061c8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800061aa:	f9442503          	lw	a0,-108(s0)
    800061ae:	00000097          	auipc	ra,0x0
    800061b2:	d98080e7          	jalr	-616(ra) # 80005f46 <free_desc>
      for(int j = 0; j < i; j++)
    800061b6:	4789                	li	a5,2
    800061b8:	0097d863          	bge	a5,s1,800061c8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800061bc:	f9842503          	lw	a0,-104(s0)
    800061c0:	00000097          	auipc	ra,0x0
    800061c4:	d86080e7          	jalr	-634(ra) # 80005f46 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061c8:	0003f597          	auipc	a1,0x3f
    800061cc:	ee058593          	addi	a1,a1,-288 # 800450a8 <disk+0x20a8>
    800061d0:	0003f517          	auipc	a0,0x3f
    800061d4:	e4850513          	addi	a0,a0,-440 # 80045018 <disk+0x2018>
    800061d8:	ffffc097          	auipc	ra,0xffffc
    800061dc:	2be080e7          	jalr	702(ra) # 80002496 <sleep>
  for(int i = 0; i < 3; i++){
    800061e0:	f9040713          	addi	a4,s0,-112
    800061e4:	84ce                	mv	s1,s3
    800061e6:	bf41                	j	80006176 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    800061e8:	4785                	li	a5,1
    800061ea:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    800061ee:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    800061f2:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800061f6:	f9042983          	lw	s3,-112(s0)
    800061fa:	00499493          	slli	s1,s3,0x4
    800061fe:	0003fa17          	auipc	s4,0x3f
    80006202:	e02a0a13          	addi	s4,s4,-510 # 80045000 <disk+0x2000>
    80006206:	000a3a83          	ld	s5,0(s4)
    8000620a:	9aa6                	add	s5,s5,s1
    8000620c:	f8040513          	addi	a0,s0,-128
    80006210:	ffffb097          	auipc	ra,0xffffb
    80006214:	05a080e7          	jalr	90(ra) # 8000126a <kvmpa>
    80006218:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    8000621c:	000a3783          	ld	a5,0(s4)
    80006220:	97a6                	add	a5,a5,s1
    80006222:	4741                	li	a4,16
    80006224:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006226:	000a3783          	ld	a5,0(s4)
    8000622a:	97a6                	add	a5,a5,s1
    8000622c:	4705                	li	a4,1
    8000622e:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006232:	f9442703          	lw	a4,-108(s0)
    80006236:	000a3783          	ld	a5,0(s4)
    8000623a:	97a6                	add	a5,a5,s1
    8000623c:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006240:	0712                	slli	a4,a4,0x4
    80006242:	000a3783          	ld	a5,0(s4)
    80006246:	97ba                	add	a5,a5,a4
    80006248:	05890693          	addi	a3,s2,88
    8000624c:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    8000624e:	000a3783          	ld	a5,0(s4)
    80006252:	97ba                	add	a5,a5,a4
    80006254:	40000693          	li	a3,1024
    80006258:	c794                	sw	a3,8(a5)
  if(write)
    8000625a:	100d0a63          	beqz	s10,8000636e <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000625e:	0003f797          	auipc	a5,0x3f
    80006262:	da27b783          	ld	a5,-606(a5) # 80045000 <disk+0x2000>
    80006266:	97ba                	add	a5,a5,a4
    80006268:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000626c:	0003d517          	auipc	a0,0x3d
    80006270:	d9450513          	addi	a0,a0,-620 # 80043000 <disk>
    80006274:	0003f797          	auipc	a5,0x3f
    80006278:	d8c78793          	addi	a5,a5,-628 # 80045000 <disk+0x2000>
    8000627c:	6394                	ld	a3,0(a5)
    8000627e:	96ba                	add	a3,a3,a4
    80006280:	00c6d603          	lhu	a2,12(a3)
    80006284:	00166613          	ori	a2,a2,1
    80006288:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000628c:	f9842683          	lw	a3,-104(s0)
    80006290:	6390                	ld	a2,0(a5)
    80006292:	9732                	add	a4,a4,a2
    80006294:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006298:	20098613          	addi	a2,s3,512
    8000629c:	0612                	slli	a2,a2,0x4
    8000629e:	962a                	add	a2,a2,a0
    800062a0:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062a4:	00469713          	slli	a4,a3,0x4
    800062a8:	6394                	ld	a3,0(a5)
    800062aa:	96ba                	add	a3,a3,a4
    800062ac:	6589                	lui	a1,0x2
    800062ae:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    800062b2:	94ae                	add	s1,s1,a1
    800062b4:	94aa                	add	s1,s1,a0
    800062b6:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    800062b8:	6394                	ld	a3,0(a5)
    800062ba:	96ba                	add	a3,a3,a4
    800062bc:	4585                	li	a1,1
    800062be:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062c0:	6394                	ld	a3,0(a5)
    800062c2:	96ba                	add	a3,a3,a4
    800062c4:	4509                	li	a0,2
    800062c6:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800062ca:	6394                	ld	a3,0(a5)
    800062cc:	9736                	add	a4,a4,a3
    800062ce:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062d2:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800062d6:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800062da:	6794                	ld	a3,8(a5)
    800062dc:	0026d703          	lhu	a4,2(a3)
    800062e0:	8b1d                	andi	a4,a4,7
    800062e2:	2709                	addiw	a4,a4,2
    800062e4:	0706                	slli	a4,a4,0x1
    800062e6:	9736                	add	a4,a4,a3
    800062e8:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    800062ec:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800062f0:	6798                	ld	a4,8(a5)
    800062f2:	00275783          	lhu	a5,2(a4)
    800062f6:	2785                	addiw	a5,a5,1
    800062f8:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062fc:	100017b7          	lui	a5,0x10001
    80006300:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006304:	00492703          	lw	a4,4(s2)
    80006308:	4785                	li	a5,1
    8000630a:	02f71163          	bne	a4,a5,8000632c <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    8000630e:	0003f997          	auipc	s3,0x3f
    80006312:	d9a98993          	addi	s3,s3,-614 # 800450a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006316:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006318:	85ce                	mv	a1,s3
    8000631a:	854a                	mv	a0,s2
    8000631c:	ffffc097          	auipc	ra,0xffffc
    80006320:	17a080e7          	jalr	378(ra) # 80002496 <sleep>
  while(b->disk == 1) {
    80006324:	00492783          	lw	a5,4(s2)
    80006328:	fe9788e3          	beq	a5,s1,80006318 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    8000632c:	f9042483          	lw	s1,-112(s0)
    80006330:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    80006334:	00479713          	slli	a4,a5,0x4
    80006338:	0003d797          	auipc	a5,0x3d
    8000633c:	cc878793          	addi	a5,a5,-824 # 80043000 <disk>
    80006340:	97ba                	add	a5,a5,a4
    80006342:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006346:	0003f917          	auipc	s2,0x3f
    8000634a:	cba90913          	addi	s2,s2,-838 # 80045000 <disk+0x2000>
    free_desc(i);
    8000634e:	8526                	mv	a0,s1
    80006350:	00000097          	auipc	ra,0x0
    80006354:	bf6080e7          	jalr	-1034(ra) # 80005f46 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006358:	0492                	slli	s1,s1,0x4
    8000635a:	00093783          	ld	a5,0(s2)
    8000635e:	94be                	add	s1,s1,a5
    80006360:	00c4d783          	lhu	a5,12(s1)
    80006364:	8b85                	andi	a5,a5,1
    80006366:	cf89                	beqz	a5,80006380 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    80006368:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000636c:	b7cd                	j	8000634e <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000636e:	0003f797          	auipc	a5,0x3f
    80006372:	c927b783          	ld	a5,-878(a5) # 80045000 <disk+0x2000>
    80006376:	97ba                	add	a5,a5,a4
    80006378:	4689                	li	a3,2
    8000637a:	00d79623          	sh	a3,12(a5)
    8000637e:	b5fd                	j	8000626c <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006380:	0003f517          	auipc	a0,0x3f
    80006384:	d2850513          	addi	a0,a0,-728 # 800450a8 <disk+0x20a8>
    80006388:	ffffb097          	auipc	ra,0xffffb
    8000638c:	ac6080e7          	jalr	-1338(ra) # 80000e4e <release>
}
    80006390:	70e6                	ld	ra,120(sp)
    80006392:	7446                	ld	s0,112(sp)
    80006394:	74a6                	ld	s1,104(sp)
    80006396:	7906                	ld	s2,96(sp)
    80006398:	69e6                	ld	s3,88(sp)
    8000639a:	6a46                	ld	s4,80(sp)
    8000639c:	6aa6                	ld	s5,72(sp)
    8000639e:	6b06                	ld	s6,64(sp)
    800063a0:	7be2                	ld	s7,56(sp)
    800063a2:	7c42                	ld	s8,48(sp)
    800063a4:	7ca2                	ld	s9,40(sp)
    800063a6:	7d02                	ld	s10,32(sp)
    800063a8:	6109                	addi	sp,sp,128
    800063aa:	8082                	ret
  if(write)
    800063ac:	e20d1ee3          	bnez	s10,800061e8 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    800063b0:	f8042023          	sw	zero,-128(s0)
    800063b4:	bd2d                	j	800061ee <virtio_disk_rw+0xe2>

00000000800063b6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063b6:	1101                	addi	sp,sp,-32
    800063b8:	ec06                	sd	ra,24(sp)
    800063ba:	e822                	sd	s0,16(sp)
    800063bc:	e426                	sd	s1,8(sp)
    800063be:	e04a                	sd	s2,0(sp)
    800063c0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063c2:	0003f517          	auipc	a0,0x3f
    800063c6:	ce650513          	addi	a0,a0,-794 # 800450a8 <disk+0x20a8>
    800063ca:	ffffb097          	auipc	ra,0xffffb
    800063ce:	9d0080e7          	jalr	-1584(ra) # 80000d9a <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800063d2:	0003f717          	auipc	a4,0x3f
    800063d6:	c2e70713          	addi	a4,a4,-978 # 80045000 <disk+0x2000>
    800063da:	02075783          	lhu	a5,32(a4)
    800063de:	6b18                	ld	a4,16(a4)
    800063e0:	00275683          	lhu	a3,2(a4)
    800063e4:	8ebd                	xor	a3,a3,a5
    800063e6:	8a9d                	andi	a3,a3,7
    800063e8:	cab9                	beqz	a3,8000643e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800063ea:	0003d917          	auipc	s2,0x3d
    800063ee:	c1690913          	addi	s2,s2,-1002 # 80043000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800063f2:	0003f497          	auipc	s1,0x3f
    800063f6:	c0e48493          	addi	s1,s1,-1010 # 80045000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    800063fa:	078e                	slli	a5,a5,0x3
    800063fc:	97ba                	add	a5,a5,a4
    800063fe:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006400:	20078713          	addi	a4,a5,512
    80006404:	0712                	slli	a4,a4,0x4
    80006406:	974a                	add	a4,a4,s2
    80006408:	03074703          	lbu	a4,48(a4)
    8000640c:	ef21                	bnez	a4,80006464 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000640e:	20078793          	addi	a5,a5,512
    80006412:	0792                	slli	a5,a5,0x4
    80006414:	97ca                	add	a5,a5,s2
    80006416:	7798                	ld	a4,40(a5)
    80006418:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000641c:	7788                	ld	a0,40(a5)
    8000641e:	ffffc097          	auipc	ra,0xffffc
    80006422:	1fe080e7          	jalr	510(ra) # 8000261c <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006426:	0204d783          	lhu	a5,32(s1)
    8000642a:	2785                	addiw	a5,a5,1
    8000642c:	8b9d                	andi	a5,a5,7
    8000642e:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006432:	6898                	ld	a4,16(s1)
    80006434:	00275683          	lhu	a3,2(a4)
    80006438:	8a9d                	andi	a3,a3,7
    8000643a:	fcf690e3          	bne	a3,a5,800063fa <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000643e:	10001737          	lui	a4,0x10001
    80006442:	533c                	lw	a5,96(a4)
    80006444:	8b8d                	andi	a5,a5,3
    80006446:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006448:	0003f517          	auipc	a0,0x3f
    8000644c:	c6050513          	addi	a0,a0,-928 # 800450a8 <disk+0x20a8>
    80006450:	ffffb097          	auipc	ra,0xffffb
    80006454:	9fe080e7          	jalr	-1538(ra) # 80000e4e <release>
}
    80006458:	60e2                	ld	ra,24(sp)
    8000645a:	6442                	ld	s0,16(sp)
    8000645c:	64a2                	ld	s1,8(sp)
    8000645e:	6902                	ld	s2,0(sp)
    80006460:	6105                	addi	sp,sp,32
    80006462:	8082                	ret
      panic("virtio_disk_intr status");
    80006464:	00002517          	auipc	a0,0x2
    80006468:	3cc50513          	addi	a0,a0,972 # 80008830 <syscalls+0x3d0>
    8000646c:	ffffa097          	auipc	ra,0xffffa
    80006470:	0dc080e7          	jalr	220(ra) # 80000548 <panic>
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
