
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 89 3c 10 80       	mov    $0x80103c89,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 04 8e 10 80       	push   $0x80108e04
80100042:	68 60 d6 10 80       	push   $0x8010d660
80100047:	e8 ca 53 00 00       	call   80105416 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 15 11 80 64 	movl   $0x80111564,0x80111570
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 15 11 80 64 	movl   $0x80111564,0x80111574
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 15 11 80       	mov    0x80111574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 15 11 80       	mov    %eax,0x80111574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 15 11 80       	mov    $0x80111564,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 d6 10 80       	push   $0x8010d660
801000c1:	e8 72 53 00 00       	call   80105438 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 15 11 80       	mov    0x80111574,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 d6 10 80       	push   $0x8010d660
8010010c:	e8 8e 53 00 00       	call   8010549f <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 d6 10 80       	push   $0x8010d660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 0a 50 00 00       	call   80105136 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 15 11 80       	mov    0x80111570,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 d6 10 80       	push   $0x8010d660
80100188:	e8 12 53 00 00       	call   8010549f <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 0b 8e 10 80       	push   $0x80108e0b
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 20 2b 00 00       	call   80102d07 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 1c 8e 10 80       	push   $0x80108e1c
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 df 2a 00 00       	call   80102d07 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 23 8e 10 80       	push   $0x80108e23
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 d6 10 80       	push   $0x8010d660
80100255:	e8 de 51 00 00       	call   80105438 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 15 11 80       	mov    0x80111574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 15 11 80       	mov    %eax,0x80111574

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 66 4f 00 00       	call   80105224 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 d6 10 80       	push   $0x8010d660
801002c9:	e8 d1 51 00 00       	call   8010549f <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 c5 10 80       	push   $0x8010c5c0
801003e2:	e8 51 50 00 00       	call   80105438 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 2a 8e 10 80       	push   $0x80108e2a
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 33 8e 10 80 	movl   $0x80108e33,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 c5 10 80       	push   $0x8010c5c0
8010055b:	e8 3f 4f 00 00       	call   8010549f <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 3a 8e 10 80       	push   $0x80108e3a
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 49 8e 10 80       	push   $0x80108e49
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 2a 4f 00 00       	call   801054f1 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 4b 8e 10 80       	push   $0x80108e4b
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 4f 8e 10 80       	push   $0x80108e4f
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 5e 50 00 00       	call   8010575a <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 75 4f 00 00       	call   8010569b <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 a7 68 00 00       	call   80107062 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 9a 68 00 00       	call   80107062 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 8d 68 00 00       	call   80107062 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 7d 68 00 00       	call   80107062 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 c0 c5 10 80       	push   $0x8010c5c0
8010080e:	e8 25 4c 00 00       	call   80105438 <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100816:	e9 44 01 00 00       	jmp    8010095f <consoleintr+0x166>
    switch(c){
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 10             	cmp    $0x10,%eax
80100821:	74 1e                	je     80100841 <consoleintr+0x48>
80100823:	83 f8 10             	cmp    $0x10,%eax
80100826:	7f 0a                	jg     80100832 <consoleintr+0x39>
80100828:	83 f8 08             	cmp    $0x8,%eax
8010082b:	74 6b                	je     80100898 <consoleintr+0x9f>
8010082d:	e9 9b 00 00 00       	jmp    801008cd <consoleintr+0xd4>
80100832:	83 f8 15             	cmp    $0x15,%eax
80100835:	74 33                	je     8010086a <consoleintr+0x71>
80100837:	83 f8 7f             	cmp    $0x7f,%eax
8010083a:	74 5c                	je     80100898 <consoleintr+0x9f>
8010083c:	e9 8c 00 00 00       	jmp    801008cd <consoleintr+0xd4>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100841:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100848:	e9 12 01 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010084d:	a1 08 18 11 80       	mov    0x80111808,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 08 18 11 80       	mov    %eax,0x80111808
        consputc(BACKSPACE);
8010085a:	83 ec 0c             	sub    $0xc,%esp
8010085d:	68 00 01 00 00       	push   $0x100
80100862:	e8 2b ff ff ff       	call   80100792 <consputc>
80100867:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	8b 15 08 18 11 80    	mov    0x80111808,%edx
80100870:	a1 04 18 11 80       	mov    0x80111804,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 08 18 11 80       	mov    0x80111808,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 80 17 11 80 	movzbl -0x7feee880(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010088f:	3c 0a                	cmp    $0xa,%al
80100891:	75 ba                	jne    8010084d <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100893:	e9 c7 00 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100898:	8b 15 08 18 11 80    	mov    0x80111808,%edx
8010089e:	a1 04 18 11 80       	mov    0x80111804,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 08 18 11 80       	mov    0x80111808,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 08 18 11 80       	mov    %eax,0x80111808
        consputc(BACKSPACE);
801008b8:	83 ec 0c             	sub    $0xc,%esp
801008bb:	68 00 01 00 00       	push   $0x100
801008c0:	e8 cd fe ff ff       	call   80100792 <consputc>
801008c5:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008c8:	e9 92 00 00 00       	jmp    8010095f <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d1:	0f 84 87 00 00 00    	je     8010095e <consoleintr+0x165>
801008d7:	8b 15 08 18 11 80    	mov    0x80111808,%edx
801008dd:	a1 00 18 11 80       	mov    0x80111800,%eax
801008e2:	29 c2                	sub    %eax,%edx
801008e4:	89 d0                	mov    %edx,%eax
801008e6:	83 f8 7f             	cmp    $0x7f,%eax
801008e9:	77 73                	ja     8010095e <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
801008eb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ef:	74 05                	je     801008f6 <consoleintr+0xfd>
801008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f4:	eb 05                	jmp    801008fb <consoleintr+0x102>
801008f6:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008fe:	a1 08 18 11 80       	mov    0x80111808,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 08 18 11 80    	mov    %edx,0x80111808
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 80 17 11 80    	mov    %dl,-0x7feee880(%eax)
        consputc(c);
80100918:	83 ec 0c             	sub    $0xc,%esp
8010091b:	ff 75 f0             	pushl  -0x10(%ebp)
8010091e:	e8 6f fe ff ff       	call   80100792 <consputc>
80100923:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100926:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092a:	74 18                	je     80100944 <consoleintr+0x14b>
8010092c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100930:	74 12                	je     80100944 <consoleintr+0x14b>
80100932:	a1 08 18 11 80       	mov    0x80111808,%eax
80100937:	8b 15 00 18 11 80    	mov    0x80111800,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 08 18 11 80       	mov    0x80111808,%eax
80100949:	a3 04 18 11 80       	mov    %eax,0x80111804
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 00 18 11 80       	push   $0x80111800
80100956:	e8 c9 48 00 00       	call   80105224 <wakeup>
8010095b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010095f:	8b 45 08             	mov    0x8(%ebp),%eax
80100962:	ff d0                	call   *%eax
80100964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096b:	0f 89 aa fe ff ff    	jns    8010081b <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100971:	83 ec 0c             	sub    $0xc,%esp
80100974:	68 c0 c5 10 80       	push   $0x8010c5c0
80100979:	e8 21 4b 00 00       	call   8010549f <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 56 49 00 00       	call   801052e2 <procdump>
  }
}
8010098c:	90                   	nop
8010098d:	c9                   	leave  
8010098e:	c3                   	ret    

8010098f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010098f:	55                   	push   %ebp
80100990:	89 e5                	mov    %esp,%ebp
80100992:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 28 11 00 00       	call   80101ac8 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 c5 10 80       	push   $0x8010c5c0
801009b1:	e8 82 4a 00 00       	call   80105438 <acquire>
801009b6:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009b9:	e9 ac 00 00 00       	jmp    80100a6a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x64>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 c0 c5 10 80       	push   $0x8010c5c0
801009d3:	e8 c7 4a 00 00       	call   8010549f <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 84 0f 00 00       	call   8010196a <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 c5 10 80       	push   $0x8010c5c0
801009fb:	68 00 18 11 80       	push   $0x80111800
80100a00:	e8 31 47 00 00       	call   80105136 <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 00 18 11 80    	mov    0x80111800,%edx
80100a0e:	a1 04 18 11 80       	mov    0x80111804,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 00 18 11 80       	mov    0x80111800,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 00 18 11 80    	mov    %edx,0x80111800
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 80 17 11 80 	movzbl -0x7feee880(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc3>
      if(n < target){
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a41:	73 2f                	jae    80100a72 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a43:	a1 00 18 11 80       	mov    0x80111800,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 00 18 11 80       	mov    %eax,0x80111800
      }
      break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe3>
    }
    *dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
    --n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x79>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a75:	90                   	nop
  }
  release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a7e:	e8 1c 4a 00 00       	call   8010549f <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 d9 0e 00 00       	call   8010196a <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a94:	8b 45 10             	mov    0x10(%ebp),%eax
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	29 c2                	sub    %eax,%edx
80100a9c:	89 d0                	mov    %edx,%eax
}
80100a9e:	c9                   	leave  
80100a9f:	c3                   	ret    

80100aa0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa0:	55                   	push   %ebp
80100aa1:	89 e5                	mov    %esp,%ebp
80100aa3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 17 10 00 00       	call   80101ac8 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abc:	e8 77 49 00 00       	call   80105438 <acquire>
80100ac1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100acb:	eb 21                	jmp    80100aee <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad3:	01 d0                	add    %edx,%eax
80100ad5:	0f b6 00             	movzbl (%eax),%eax
80100ad8:	0f be c0             	movsbl %al,%eax
80100adb:	0f b6 c0             	movzbl %al,%eax
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ab fc ff ff       	call   80100792 <consputc>
80100ae7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af4:	7c d7                	jl     80100acd <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	68 c0 c5 10 80       	push   $0x8010c5c0
80100afe:	e8 9c 49 00 00       	call   8010549f <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 59 0e 00 00       	call   8010196a <ilock>
80100b11:	83 c4 10             	add    $0x10,%esp

  return n;
80100b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b17:	c9                   	leave  
80100b18:	c3                   	ret    

80100b19 <consoleinit>:

void
consoleinit(void)
{
80100b19:	55                   	push   %ebp
80100b1a:	89 e5                	mov    %esp,%ebp
80100b1c:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b1f:	83 ec 08             	sub    $0x8,%esp
80100b22:	68 62 8e 10 80       	push   $0x80108e62
80100b27:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b2c:	e8 e5 48 00 00       	call   80105416 <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 cc 21 11 80 a0 	movl   $0x80100aa0,0x801121cc
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 c8 21 11 80 8f 	movl   $0x8010098f,0x801121c8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 c9 37 00 00       	call   80104325 <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 69 23 00 00       	call   80102ed4 <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b71:	55                   	push   %ebp
80100b72:	89 e5                	mov    %esp,%ebp
80100b74:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b7a:	e8 c8 2d 00 00       	call   80103947 <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 9e 19 00 00       	call   80102528 <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 38 2e 00 00       	call   801039d3 <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 ce 03 00 00       	jmp    80100f73 <exec+0x402>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 ba 0d 00 00       	call   8010196a <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bba:	6a 34                	push   $0x34
80100bbc:	6a 00                	push   $0x0
80100bbe:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bc4:	50                   	push   %eax
80100bc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100bc8:	e8 0b 13 00 00       	call   80101ed8 <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 49 03 00 00    	jbe    80100f22 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bd9:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 3b 03 00 00    	jne    80100f25 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bea:	e8 d2 75 00 00       	call   801081c1 <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 2c 03 00 00    	je     80100f28 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100bfc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c03:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c0a:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c13:	e9 ab 00 00 00       	jmp    80100cc3 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c1b:	6a 20                	push   $0x20
80100c1d:	50                   	push   %eax
80100c1e:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c24:	50                   	push   %eax
80100c25:	ff 75 d8             	pushl  -0x28(%ebp)
80100c28:	e8 ab 12 00 00       	call   80101ed8 <readi>
80100c2d:	83 c4 10             	add    $0x10,%esp
80100c30:	83 f8 20             	cmp    $0x20,%eax
80100c33:	0f 85 f2 02 00 00    	jne    80100f2b <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c39:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c3f:	83 f8 01             	cmp    $0x1,%eax
80100c42:	75 71                	jne    80100cb5 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c44:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c4a:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c50:	39 c2                	cmp    %eax,%edx
80100c52:	0f 82 d6 02 00 00    	jb     80100f2e <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c58:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c5e:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c64:	01 d0                	add    %edx,%eax
80100c66:	83 ec 04             	sub    $0x4,%esp
80100c69:	50                   	push   %eax
80100c6a:	ff 75 e0             	pushl  -0x20(%ebp)
80100c6d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c70:	e8 f3 78 00 00       	call   80108568 <allocuvm>
80100c75:	83 c4 10             	add    $0x10,%esp
80100c78:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c7f:	0f 84 ac 02 00 00    	je     80100f31 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c91:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c97:	83 ec 0c             	sub    $0xc,%esp
80100c9a:	52                   	push   %edx
80100c9b:	50                   	push   %eax
80100c9c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c9f:	51                   	push   %ecx
80100ca0:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ca3:	e8 e9 77 00 00       	call   80108491 <loaduvm>
80100ca8:	83 c4 20             	add    $0x20,%esp
80100cab:	85 c0                	test   %eax,%eax
80100cad:	0f 88 81 02 00 00    	js     80100f34 <exec+0x3c3>
80100cb3:	eb 01                	jmp    80100cb6 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100cb5:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cb6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cbd:	83 c0 20             	add    $0x20,%eax
80100cc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cc3:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cca:	0f b7 c0             	movzwl %ax,%eax
80100ccd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cd0:	0f 8f 42 ff ff ff    	jg     80100c18 <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cd6:	83 ec 0c             	sub    $0xc,%esp
80100cd9:	ff 75 d8             	pushl  -0x28(%ebp)
80100cdc:	e8 49 0f 00 00       	call   80101c2a <iunlockput>
80100ce1:	83 c4 10             	add    $0x10,%esp
  end_op();
80100ce4:	e8 ea 2c 00 00       	call   801039d3 <end_op>
  ip = 0;
80100ce9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf3:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d03:	05 00 20 00 00       	add    $0x2000,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d12:	e8 51 78 00 00       	call   80108568 <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 10 02 00 00    	je     80100f37 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d2f:	83 ec 08             	sub    $0x8,%esp
80100d32:	50                   	push   %eax
80100d33:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d36:	e8 7d 7c 00 00       	call   801089b8 <clearpteu>
80100d3b:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d41:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d4b:	e9 96 00 00 00       	jmp    80100de6 <exec+0x275>
    if(argc >= MAXARG)
80100d50:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d54:	0f 87 e0 01 00 00    	ja     80100f3a <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d67:	01 d0                	add    %edx,%eax
80100d69:	8b 00                	mov    (%eax),%eax
80100d6b:	83 ec 0c             	sub    $0xc,%esp
80100d6e:	50                   	push   %eax
80100d6f:	e8 74 4b 00 00       	call   801058e8 <strlen>
80100d74:	83 c4 10             	add    $0x10,%esp
80100d77:	89 c2                	mov    %eax,%edx
80100d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d7c:	29 d0                	sub    %edx,%eax
80100d7e:	83 e8 01             	sub    $0x1,%eax
80100d81:	83 e0 fc             	and    $0xfffffffc,%eax
80100d84:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	50                   	push   %eax
80100d9c:	e8 47 4b 00 00       	call   801058e8 <strlen>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	83 c0 01             	add    $0x1,%eax
80100da7:	89 c1                	mov    %eax,%ecx
80100da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db6:	01 d0                	add    %edx,%eax
80100db8:	8b 00                	mov    (%eax),%eax
80100dba:	51                   	push   %ecx
80100dbb:	50                   	push   %eax
80100dbc:	ff 75 dc             	pushl  -0x24(%ebp)
80100dbf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc2:	e8 a8 7d 00 00       	call   80108b6f <copyout>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	85 c0                	test   %eax,%eax
80100dcc:	0f 88 6b 01 00 00    	js     80100f3d <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd5:	8d 50 03             	lea    0x3(%eax),%edx
80100dd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddb:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df3:	01 d0                	add    %edx,%eax
80100df5:	8b 00                	mov    (%eax),%eax
80100df7:	85 c0                	test   %eax,%eax
80100df9:	0f 85 51 ff ff ff    	jne    80100d50 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	83 c0 03             	add    $0x3,%eax
80100e05:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e0c:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e10:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e17:	ff ff ff 
  ustack[1] = argc;
80100e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1d:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 01             	add    $0x1,%eax
80100e29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e33:	29 d0                	sub    %edx,%eax
80100e35:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3e:	83 c0 04             	add    $0x4,%eax
80100e41:	c1 e0 02             	shl    $0x2,%eax
80100e44:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	83 c0 04             	add    $0x4,%eax
80100e4d:	c1 e0 02             	shl    $0x2,%eax
80100e50:	50                   	push   %eax
80100e51:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 0c 7d 00 00       	call   80108b6f <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 d2 00 00 00    	js     80100f40 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80100e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e7a:	eb 17                	jmp    80100e93 <exec+0x322>
    if(*s == '/')
80100e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7f:	0f b6 00             	movzbl (%eax),%eax
80100e82:	3c 2f                	cmp    $0x2f,%al
80100e84:	75 09                	jne    80100e8f <exec+0x31e>
      last = s+1;
80100e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e89:	83 c0 01             	add    $0x1,%eax
80100e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e96:	0f b6 00             	movzbl (%eax),%eax
80100e99:	84 c0                	test   %al,%al
80100e9b:	75 df                	jne    80100e7c <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea3:	83 c0 6c             	add    $0x6c,%eax
80100ea6:	83 ec 04             	sub    $0x4,%esp
80100ea9:	6a 10                	push   $0x10
80100eab:	ff 75 f0             	pushl  -0x10(%ebp)
80100eae:	50                   	push   %eax
80100eaf:	e8 ea 49 00 00       	call   8010589e <safestrcpy>
80100eb4:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 04             	mov    0x4(%eax),%eax
80100ec0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ec3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ecc:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ed8:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee0:	8b 40 18             	mov    0x18(%eax),%eax
80100ee3:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ee9:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100eec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef2:	8b 40 18             	mov    0x18(%eax),%eax
80100ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ef8:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100efb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f01:	83 ec 0c             	sub    $0xc,%esp
80100f04:	50                   	push   %eax
80100f05:	e8 9e 73 00 00       	call   801082a8 <switchuvm>
80100f0a:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	ff 75 d0             	pushl  -0x30(%ebp)
80100f13:	e8 00 7a 00 00       	call   80108918 <freevm>
80100f18:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f1b:	b8 00 00 00 00       	mov    $0x0,%eax
80100f20:	eb 51                	jmp    80100f73 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f22:	90                   	nop
80100f23:	eb 1c                	jmp    80100f41 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f25:	90                   	nop
80100f26:	eb 19                	jmp    80100f41 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f28:	90                   	nop
80100f29:	eb 16                	jmp    80100f41 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f2b:	90                   	nop
80100f2c:	eb 13                	jmp    80100f41 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f2e:	90                   	nop
80100f2f:	eb 10                	jmp    80100f41 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f31:	90                   	nop
80100f32:	eb 0d                	jmp    80100f41 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f34:	90                   	nop
80100f35:	eb 0a                	jmp    80100f41 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f37:	90                   	nop
80100f38:	eb 07                	jmp    80100f41 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f3a:	90                   	nop
80100f3b:	eb 04                	jmp    80100f41 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f3d:	90                   	nop
80100f3e:	eb 01                	jmp    80100f41 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f40:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f41:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f45:	74 0e                	je     80100f55 <exec+0x3e4>
    freevm(pgdir);
80100f47:	83 ec 0c             	sub    $0xc,%esp
80100f4a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f4d:	e8 c6 79 00 00       	call   80108918 <freevm>
80100f52:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f55:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f59:	74 13                	je     80100f6e <exec+0x3fd>
    iunlockput(ip);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 d8             	pushl  -0x28(%ebp)
80100f61:	e8 c4 0c 00 00       	call   80101c2a <iunlockput>
80100f66:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f69:	e8 65 2a 00 00       	call   801039d3 <end_op>
  }
  return -1;
80100f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f73:	c9                   	leave  
80100f74:	c3                   	ret    

80100f75 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f75:	55                   	push   %ebp
80100f76:	89 e5                	mov    %esp,%ebp
80100f78:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f7b:	83 ec 08             	sub    $0x8,%esp
80100f7e:	68 6a 8e 10 80       	push   $0x80108e6a
80100f83:	68 20 18 11 80       	push   $0x80111820
80100f88:	e8 89 44 00 00       	call   80105416 <initlock>
80100f8d:	83 c4 10             	add    $0x10,%esp
}
80100f90:	90                   	nop
80100f91:	c9                   	leave  
80100f92:	c3                   	ret    

80100f93 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f93:	55                   	push   %ebp
80100f94:	89 e5                	mov    %esp,%ebp
80100f96:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f99:	83 ec 0c             	sub    $0xc,%esp
80100f9c:	68 20 18 11 80       	push   $0x80111820
80100fa1:	e8 92 44 00 00       	call   80105438 <acquire>
80100fa6:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fa9:	c7 45 f4 54 18 11 80 	movl   $0x80111854,-0xc(%ebp)
80100fb0:	eb 2d                	jmp    80100fdf <filealloc+0x4c>
    if(f->ref == 0){
80100fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb5:	8b 40 04             	mov    0x4(%eax),%eax
80100fb8:	85 c0                	test   %eax,%eax
80100fba:	75 1f                	jne    80100fdb <filealloc+0x48>
      f->ref = 1;
80100fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbf:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fc6:	83 ec 0c             	sub    $0xc,%esp
80100fc9:	68 20 18 11 80       	push   $0x80111820
80100fce:	e8 cc 44 00 00       	call   8010549f <release>
80100fd3:	83 c4 10             	add    $0x10,%esp
      return f;
80100fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd9:	eb 23                	jmp    80100ffe <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fdb:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fdf:	b8 b4 21 11 80       	mov    $0x801121b4,%eax
80100fe4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fe7:	72 c9                	jb     80100fb2 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fe9:	83 ec 0c             	sub    $0xc,%esp
80100fec:	68 20 18 11 80       	push   $0x80111820
80100ff1:	e8 a9 44 00 00       	call   8010549f <release>
80100ff6:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ff9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100ffe:	c9                   	leave  
80100fff:	c3                   	ret    

80101000 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101000:	55                   	push   %ebp
80101001:	89 e5                	mov    %esp,%ebp
80101003:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101006:	83 ec 0c             	sub    $0xc,%esp
80101009:	68 20 18 11 80       	push   $0x80111820
8010100e:	e8 25 44 00 00       	call   80105438 <acquire>
80101013:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101016:	8b 45 08             	mov    0x8(%ebp),%eax
80101019:	8b 40 04             	mov    0x4(%eax),%eax
8010101c:	85 c0                	test   %eax,%eax
8010101e:	7f 0d                	jg     8010102d <filedup+0x2d>
    panic("filedup");
80101020:	83 ec 0c             	sub    $0xc,%esp
80101023:	68 71 8e 10 80       	push   $0x80108e71
80101028:	e8 39 f5 ff ff       	call   80100566 <panic>
  f->ref++;
8010102d:	8b 45 08             	mov    0x8(%ebp),%eax
80101030:	8b 40 04             	mov    0x4(%eax),%eax
80101033:	8d 50 01             	lea    0x1(%eax),%edx
80101036:	8b 45 08             	mov    0x8(%ebp),%eax
80101039:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010103c:	83 ec 0c             	sub    $0xc,%esp
8010103f:	68 20 18 11 80       	push   $0x80111820
80101044:	e8 56 44 00 00       	call   8010549f <release>
80101049:	83 c4 10             	add    $0x10,%esp
  return f;
8010104c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010104f:	c9                   	leave  
80101050:	c3                   	ret    

80101051 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101051:	55                   	push   %ebp
80101052:	89 e5                	mov    %esp,%ebp
80101054:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101057:	83 ec 0c             	sub    $0xc,%esp
8010105a:	68 20 18 11 80       	push   $0x80111820
8010105f:	e8 d4 43 00 00       	call   80105438 <acquire>
80101064:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101067:	8b 45 08             	mov    0x8(%ebp),%eax
8010106a:	8b 40 04             	mov    0x4(%eax),%eax
8010106d:	85 c0                	test   %eax,%eax
8010106f:	7f 0d                	jg     8010107e <fileclose+0x2d>
    panic("fileclose");
80101071:	83 ec 0c             	sub    $0xc,%esp
80101074:	68 79 8e 10 80       	push   $0x80108e79
80101079:	e8 e8 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010107e:	8b 45 08             	mov    0x8(%ebp),%eax
80101081:	8b 40 04             	mov    0x4(%eax),%eax
80101084:	8d 50 ff             	lea    -0x1(%eax),%edx
80101087:	8b 45 08             	mov    0x8(%ebp),%eax
8010108a:	89 50 04             	mov    %edx,0x4(%eax)
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	8b 40 04             	mov    0x4(%eax),%eax
80101093:	85 c0                	test   %eax,%eax
80101095:	7e 15                	jle    801010ac <fileclose+0x5b>
    release(&ftable.lock);
80101097:	83 ec 0c             	sub    $0xc,%esp
8010109a:	68 20 18 11 80       	push   $0x80111820
8010109f:	e8 fb 43 00 00       	call   8010549f <release>
801010a4:	83 c4 10             	add    $0x10,%esp
801010a7:	e9 8b 00 00 00       	jmp    80101137 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010ac:	8b 45 08             	mov    0x8(%ebp),%eax
801010af:	8b 10                	mov    (%eax),%edx
801010b1:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010b4:	8b 50 04             	mov    0x4(%eax),%edx
801010b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010ba:	8b 50 08             	mov    0x8(%eax),%edx
801010bd:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010c0:	8b 50 0c             	mov    0xc(%eax),%edx
801010c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010c6:	8b 50 10             	mov    0x10(%eax),%edx
801010c9:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010cc:	8b 40 14             	mov    0x14(%eax),%eax
801010cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010dc:	8b 45 08             	mov    0x8(%ebp),%eax
801010df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010e5:	83 ec 0c             	sub    $0xc,%esp
801010e8:	68 20 18 11 80       	push   $0x80111820
801010ed:	e8 ad 43 00 00       	call   8010549f <release>
801010f2:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010f8:	83 f8 01             	cmp    $0x1,%eax
801010fb:	75 19                	jne    80101116 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010fd:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101101:	0f be d0             	movsbl %al,%edx
80101104:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101107:	83 ec 08             	sub    $0x8,%esp
8010110a:	52                   	push   %edx
8010110b:	50                   	push   %eax
8010110c:	e8 7d 34 00 00       	call   8010458e <pipeclose>
80101111:	83 c4 10             	add    $0x10,%esp
80101114:	eb 21                	jmp    80101137 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101116:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101119:	83 f8 02             	cmp    $0x2,%eax
8010111c:	75 19                	jne    80101137 <fileclose+0xe6>
    begin_op();
8010111e:	e8 24 28 00 00       	call   80103947 <begin_op>
    iput(ff.ip);
80101123:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101126:	83 ec 0c             	sub    $0xc,%esp
80101129:	50                   	push   %eax
8010112a:	e8 0b 0a 00 00       	call   80101b3a <iput>
8010112f:	83 c4 10             	add    $0x10,%esp
    end_op();
80101132:	e8 9c 28 00 00       	call   801039d3 <end_op>
  }
}
80101137:	c9                   	leave  
80101138:	c3                   	ret    

80101139 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101139:	55                   	push   %ebp
8010113a:	89 e5                	mov    %esp,%ebp
8010113c:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010113f:	8b 45 08             	mov    0x8(%ebp),%eax
80101142:	8b 00                	mov    (%eax),%eax
80101144:	83 f8 02             	cmp    $0x2,%eax
80101147:	75 40                	jne    80101189 <filestat+0x50>
    ilock(f->ip);
80101149:	8b 45 08             	mov    0x8(%ebp),%eax
8010114c:	8b 40 10             	mov    0x10(%eax),%eax
8010114f:	83 ec 0c             	sub    $0xc,%esp
80101152:	50                   	push   %eax
80101153:	e8 12 08 00 00       	call   8010196a <ilock>
80101158:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010115b:	8b 45 08             	mov    0x8(%ebp),%eax
8010115e:	8b 40 10             	mov    0x10(%eax),%eax
80101161:	83 ec 08             	sub    $0x8,%esp
80101164:	ff 75 0c             	pushl  0xc(%ebp)
80101167:	50                   	push   %eax
80101168:	e8 25 0d 00 00       	call   80101e92 <stati>
8010116d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 40 10             	mov    0x10(%eax),%eax
80101176:	83 ec 0c             	sub    $0xc,%esp
80101179:	50                   	push   %eax
8010117a:	e8 49 09 00 00       	call   80101ac8 <iunlock>
8010117f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101182:	b8 00 00 00 00       	mov    $0x0,%eax
80101187:	eb 05                	jmp    8010118e <filestat+0x55>
  }
  return -1;
80101189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010118e:	c9                   	leave  
8010118f:	c3                   	ret    

80101190 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101190:	55                   	push   %ebp
80101191:	89 e5                	mov    %esp,%ebp
80101193:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101196:	8b 45 08             	mov    0x8(%ebp),%eax
80101199:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010119d:	84 c0                	test   %al,%al
8010119f:	75 0a                	jne    801011ab <fileread+0x1b>
    return -1;
801011a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011a6:	e9 9b 00 00 00       	jmp    80101246 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ab:	8b 45 08             	mov    0x8(%ebp),%eax
801011ae:	8b 00                	mov    (%eax),%eax
801011b0:	83 f8 01             	cmp    $0x1,%eax
801011b3:	75 1a                	jne    801011cf <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011b5:	8b 45 08             	mov    0x8(%ebp),%eax
801011b8:	8b 40 0c             	mov    0xc(%eax),%eax
801011bb:	83 ec 04             	sub    $0x4,%esp
801011be:	ff 75 10             	pushl  0x10(%ebp)
801011c1:	ff 75 0c             	pushl  0xc(%ebp)
801011c4:	50                   	push   %eax
801011c5:	e8 6c 35 00 00       	call   80104736 <piperead>
801011ca:	83 c4 10             	add    $0x10,%esp
801011cd:	eb 77                	jmp    80101246 <fileread+0xb6>
  if(f->type == FD_INODE){
801011cf:	8b 45 08             	mov    0x8(%ebp),%eax
801011d2:	8b 00                	mov    (%eax),%eax
801011d4:	83 f8 02             	cmp    $0x2,%eax
801011d7:	75 60                	jne    80101239 <fileread+0xa9>
    ilock(f->ip);
801011d9:	8b 45 08             	mov    0x8(%ebp),%eax
801011dc:	8b 40 10             	mov    0x10(%eax),%eax
801011df:	83 ec 0c             	sub    $0xc,%esp
801011e2:	50                   	push   %eax
801011e3:	e8 82 07 00 00       	call   8010196a <ilock>
801011e8:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011ee:	8b 45 08             	mov    0x8(%ebp),%eax
801011f1:	8b 50 14             	mov    0x14(%eax),%edx
801011f4:	8b 45 08             	mov    0x8(%ebp),%eax
801011f7:	8b 40 10             	mov    0x10(%eax),%eax
801011fa:	51                   	push   %ecx
801011fb:	52                   	push   %edx
801011fc:	ff 75 0c             	pushl  0xc(%ebp)
801011ff:	50                   	push   %eax
80101200:	e8 d3 0c 00 00       	call   80101ed8 <readi>
80101205:	83 c4 10             	add    $0x10,%esp
80101208:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010120b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010120f:	7e 11                	jle    80101222 <fileread+0x92>
      f->off += r;
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	8b 50 14             	mov    0x14(%eax),%edx
80101217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121a:	01 c2                	add    %eax,%edx
8010121c:	8b 45 08             	mov    0x8(%ebp),%eax
8010121f:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101222:	8b 45 08             	mov    0x8(%ebp),%eax
80101225:	8b 40 10             	mov    0x10(%eax),%eax
80101228:	83 ec 0c             	sub    $0xc,%esp
8010122b:	50                   	push   %eax
8010122c:	e8 97 08 00 00       	call   80101ac8 <iunlock>
80101231:	83 c4 10             	add    $0x10,%esp
    return r;
80101234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101237:	eb 0d                	jmp    80101246 <fileread+0xb6>
  }
  panic("fileread");
80101239:	83 ec 0c             	sub    $0xc,%esp
8010123c:	68 83 8e 10 80       	push   $0x80108e83
80101241:	e8 20 f3 ff ff       	call   80100566 <panic>
}
80101246:	c9                   	leave  
80101247:	c3                   	ret    

80101248 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101248:	55                   	push   %ebp
80101249:	89 e5                	mov    %esp,%ebp
8010124b:	53                   	push   %ebx
8010124c:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101256:	84 c0                	test   %al,%al
80101258:	75 0a                	jne    80101264 <filewrite+0x1c>
    return -1;
8010125a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010125f:	e9 1b 01 00 00       	jmp    8010137f <filewrite+0x137>
  if(f->type == FD_PIPE)
80101264:	8b 45 08             	mov    0x8(%ebp),%eax
80101267:	8b 00                	mov    (%eax),%eax
80101269:	83 f8 01             	cmp    $0x1,%eax
8010126c:	75 1d                	jne    8010128b <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	8b 40 0c             	mov    0xc(%eax),%eax
80101274:	83 ec 04             	sub    $0x4,%esp
80101277:	ff 75 10             	pushl  0x10(%ebp)
8010127a:	ff 75 0c             	pushl  0xc(%ebp)
8010127d:	50                   	push   %eax
8010127e:	e8 b5 33 00 00       	call   80104638 <pipewrite>
80101283:	83 c4 10             	add    $0x10,%esp
80101286:	e9 f4 00 00 00       	jmp    8010137f <filewrite+0x137>
  if(f->type == FD_INODE){
8010128b:	8b 45 08             	mov    0x8(%ebp),%eax
8010128e:	8b 00                	mov    (%eax),%eax
80101290:	83 f8 02             	cmp    $0x2,%eax
80101293:	0f 85 d9 00 00 00    	jne    80101372 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101299:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012a7:	e9 a3 00 00 00       	jmp    8010134f <filewrite+0x107>
      int n1 = n - i;
801012ac:	8b 45 10             	mov    0x10(%ebp),%eax
801012af:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012b8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012bb:	7e 06                	jle    801012c3 <filewrite+0x7b>
        n1 = max;
801012bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012c0:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012c3:	e8 7f 26 00 00       	call   80103947 <begin_op>
      ilock(f->ip);
801012c8:	8b 45 08             	mov    0x8(%ebp),%eax
801012cb:	8b 40 10             	mov    0x10(%eax),%eax
801012ce:	83 ec 0c             	sub    $0xc,%esp
801012d1:	50                   	push   %eax
801012d2:	e8 93 06 00 00       	call   8010196a <ilock>
801012d7:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012da:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012dd:	8b 45 08             	mov    0x8(%ebp),%eax
801012e0:	8b 50 14             	mov    0x14(%eax),%edx
801012e3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801012e9:	01 c3                	add    %eax,%ebx
801012eb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ee:	8b 40 10             	mov    0x10(%eax),%eax
801012f1:	51                   	push   %ecx
801012f2:	52                   	push   %edx
801012f3:	53                   	push   %ebx
801012f4:	50                   	push   %eax
801012f5:	e8 35 0d 00 00       	call   8010202f <writei>
801012fa:	83 c4 10             	add    $0x10,%esp
801012fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101300:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101304:	7e 11                	jle    80101317 <filewrite+0xcf>
        f->off += r;
80101306:	8b 45 08             	mov    0x8(%ebp),%eax
80101309:	8b 50 14             	mov    0x14(%eax),%edx
8010130c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010130f:	01 c2                	add    %eax,%edx
80101311:	8b 45 08             	mov    0x8(%ebp),%eax
80101314:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101317:	8b 45 08             	mov    0x8(%ebp),%eax
8010131a:	8b 40 10             	mov    0x10(%eax),%eax
8010131d:	83 ec 0c             	sub    $0xc,%esp
80101320:	50                   	push   %eax
80101321:	e8 a2 07 00 00       	call   80101ac8 <iunlock>
80101326:	83 c4 10             	add    $0x10,%esp
      end_op();
80101329:	e8 a5 26 00 00       	call   801039d3 <end_op>

      if(r < 0)
8010132e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101332:	78 29                	js     8010135d <filewrite+0x115>
        break;
      if(r != n1)
80101334:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101337:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010133a:	74 0d                	je     80101349 <filewrite+0x101>
        panic("short filewrite");
8010133c:	83 ec 0c             	sub    $0xc,%esp
8010133f:	68 8c 8e 10 80       	push   $0x80108e8c
80101344:	e8 1d f2 ff ff       	call   80100566 <panic>
      i += r;
80101349:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010134c:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101352:	3b 45 10             	cmp    0x10(%ebp),%eax
80101355:	0f 8c 51 ff ff ff    	jl     801012ac <filewrite+0x64>
8010135b:	eb 01                	jmp    8010135e <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010135d:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010135e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101361:	3b 45 10             	cmp    0x10(%ebp),%eax
80101364:	75 05                	jne    8010136b <filewrite+0x123>
80101366:	8b 45 10             	mov    0x10(%ebp),%eax
80101369:	eb 14                	jmp    8010137f <filewrite+0x137>
8010136b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101370:	eb 0d                	jmp    8010137f <filewrite+0x137>
  }
  panic("filewrite");
80101372:	83 ec 0c             	sub    $0xc,%esp
80101375:	68 9c 8e 10 80       	push   $0x80108e9c
8010137a:	e8 e7 f1 ff ff       	call   80100566 <panic>
}
8010137f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101382:	c9                   	leave  
80101383:	c3                   	ret    

80101384 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101384:	55                   	push   %ebp
80101385:	89 e5                	mov    %esp,%ebp
80101387:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010138a:	8b 45 08             	mov    0x8(%ebp),%eax
8010138d:	83 ec 08             	sub    $0x8,%esp
80101390:	6a 01                	push   $0x1
80101392:	50                   	push   %eax
80101393:	e8 1e ee ff ff       	call   801001b6 <bread>
80101398:	83 c4 10             	add    $0x10,%esp
8010139b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010139e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a1:	83 c0 18             	add    $0x18,%eax
801013a4:	83 ec 04             	sub    $0x4,%esp
801013a7:	6a 1c                	push   $0x1c
801013a9:	50                   	push   %eax
801013aa:	ff 75 0c             	pushl  0xc(%ebp)
801013ad:	e8 a8 43 00 00       	call   8010575a <memmove>
801013b2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013b5:	83 ec 0c             	sub    $0xc,%esp
801013b8:	ff 75 f4             	pushl  -0xc(%ebp)
801013bb:	e8 6e ee ff ff       	call   8010022e <brelse>
801013c0:	83 c4 10             	add    $0x10,%esp
}
801013c3:	90                   	nop
801013c4:	c9                   	leave  
801013c5:	c3                   	ret    

801013c6 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013c6:	55                   	push   %ebp
801013c7:	89 e5                	mov    %esp,%ebp
801013c9:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801013cf:	8b 45 08             	mov    0x8(%ebp),%eax
801013d2:	83 ec 08             	sub    $0x8,%esp
801013d5:	52                   	push   %edx
801013d6:	50                   	push   %eax
801013d7:	e8 da ed ff ff       	call   801001b6 <bread>
801013dc:	83 c4 10             	add    $0x10,%esp
801013df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e5:	83 c0 18             	add    $0x18,%eax
801013e8:	83 ec 04             	sub    $0x4,%esp
801013eb:	68 00 02 00 00       	push   $0x200
801013f0:	6a 00                	push   $0x0
801013f2:	50                   	push   %eax
801013f3:	e8 a3 42 00 00       	call   8010569b <memset>
801013f8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013fb:	83 ec 0c             	sub    $0xc,%esp
801013fe:	ff 75 f4             	pushl  -0xc(%ebp)
80101401:	e8 79 27 00 00       	call   80103b7f <log_write>
80101406:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	ff 75 f4             	pushl  -0xc(%ebp)
8010140f:	e8 1a ee ff ff       	call   8010022e <brelse>
80101414:	83 c4 10             	add    $0x10,%esp
}
80101417:	90                   	nop
80101418:	c9                   	leave  
80101419:	c3                   	ret    

8010141a <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010141a:	55                   	push   %ebp
8010141b:	89 e5                	mov    %esp,%ebp
8010141d:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101420:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101427:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010142e:	e9 13 01 00 00       	jmp    80101546 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101436:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010143c:	85 c0                	test   %eax,%eax
8010143e:	0f 48 c2             	cmovs  %edx,%eax
80101441:	c1 f8 0c             	sar    $0xc,%eax
80101444:	89 c2                	mov    %eax,%edx
80101446:	a1 38 22 11 80       	mov    0x80112238,%eax
8010144b:	01 d0                	add    %edx,%eax
8010144d:	83 ec 08             	sub    $0x8,%esp
80101450:	50                   	push   %eax
80101451:	ff 75 08             	pushl  0x8(%ebp)
80101454:	e8 5d ed ff ff       	call   801001b6 <bread>
80101459:	83 c4 10             	add    $0x10,%esp
8010145c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010145f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101466:	e9 a6 00 00 00       	jmp    80101511 <balloc+0xf7>
      m = 1 << (bi % 8);
8010146b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146e:	99                   	cltd   
8010146f:	c1 ea 1d             	shr    $0x1d,%edx
80101472:	01 d0                	add    %edx,%eax
80101474:	83 e0 07             	and    $0x7,%eax
80101477:	29 d0                	sub    %edx,%eax
80101479:	ba 01 00 00 00       	mov    $0x1,%edx
8010147e:	89 c1                	mov    %eax,%ecx
80101480:	d3 e2                	shl    %cl,%edx
80101482:	89 d0                	mov    %edx,%eax
80101484:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148a:	8d 50 07             	lea    0x7(%eax),%edx
8010148d:	85 c0                	test   %eax,%eax
8010148f:	0f 48 c2             	cmovs  %edx,%eax
80101492:	c1 f8 03             	sar    $0x3,%eax
80101495:	89 c2                	mov    %eax,%edx
80101497:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010149a:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010149f:	0f b6 c0             	movzbl %al,%eax
801014a2:	23 45 e8             	and    -0x18(%ebp),%eax
801014a5:	85 c0                	test   %eax,%eax
801014a7:	75 64                	jne    8010150d <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801014a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ac:	8d 50 07             	lea    0x7(%eax),%edx
801014af:	85 c0                	test   %eax,%eax
801014b1:	0f 48 c2             	cmovs  %edx,%eax
801014b4:	c1 f8 03             	sar    $0x3,%eax
801014b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ba:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014bf:	89 d1                	mov    %edx,%ecx
801014c1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014c4:	09 ca                	or     %ecx,%edx
801014c6:	89 d1                	mov    %edx,%ecx
801014c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014cb:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014cf:	83 ec 0c             	sub    $0xc,%esp
801014d2:	ff 75 ec             	pushl  -0x14(%ebp)
801014d5:	e8 a5 26 00 00       	call   80103b7f <log_write>
801014da:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014dd:	83 ec 0c             	sub    $0xc,%esp
801014e0:	ff 75 ec             	pushl  -0x14(%ebp)
801014e3:	e8 46 ed ff ff       	call   8010022e <brelse>
801014e8:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f1:	01 c2                	add    %eax,%edx
801014f3:	8b 45 08             	mov    0x8(%ebp),%eax
801014f6:	83 ec 08             	sub    $0x8,%esp
801014f9:	52                   	push   %edx
801014fa:	50                   	push   %eax
801014fb:	e8 c6 fe ff ff       	call   801013c6 <bzero>
80101500:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101503:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101506:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101509:	01 d0                	add    %edx,%eax
8010150b:	eb 57                	jmp    80101564 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010150d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101511:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101518:	7f 17                	jg     80101531 <balloc+0x117>
8010151a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101520:	01 d0                	add    %edx,%eax
80101522:	89 c2                	mov    %eax,%edx
80101524:	a1 20 22 11 80       	mov    0x80112220,%eax
80101529:	39 c2                	cmp    %eax,%edx
8010152b:	0f 82 3a ff ff ff    	jb     8010146b <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101531:	83 ec 0c             	sub    $0xc,%esp
80101534:	ff 75 ec             	pushl  -0x14(%ebp)
80101537:	e8 f2 ec ff ff       	call   8010022e <brelse>
8010153c:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010153f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101546:	8b 15 20 22 11 80    	mov    0x80112220,%edx
8010154c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154f:	39 c2                	cmp    %eax,%edx
80101551:	0f 87 dc fe ff ff    	ja     80101433 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101557:	83 ec 0c             	sub    $0xc,%esp
8010155a:	68 a8 8e 10 80       	push   $0x80108ea8
8010155f:	e8 02 f0 ff ff       	call   80100566 <panic>
}
80101564:	c9                   	leave  
80101565:	c3                   	ret    

80101566 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101566:	55                   	push   %ebp
80101567:	89 e5                	mov    %esp,%ebp
80101569:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010156c:	83 ec 08             	sub    $0x8,%esp
8010156f:	68 20 22 11 80       	push   $0x80112220
80101574:	ff 75 08             	pushl  0x8(%ebp)
80101577:	e8 08 fe ff ff       	call   80101384 <readsb>
8010157c:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
8010157f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101582:	c1 e8 0c             	shr    $0xc,%eax
80101585:	89 c2                	mov    %eax,%edx
80101587:	a1 38 22 11 80       	mov    0x80112238,%eax
8010158c:	01 c2                	add    %eax,%edx
8010158e:	8b 45 08             	mov    0x8(%ebp),%eax
80101591:	83 ec 08             	sub    $0x8,%esp
80101594:	52                   	push   %edx
80101595:	50                   	push   %eax
80101596:	e8 1b ec ff ff       	call   801001b6 <bread>
8010159b:	83 c4 10             	add    $0x10,%esp
8010159e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015a4:	25 ff 0f 00 00       	and    $0xfff,%eax
801015a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015af:	99                   	cltd   
801015b0:	c1 ea 1d             	shr    $0x1d,%edx
801015b3:	01 d0                	add    %edx,%eax
801015b5:	83 e0 07             	and    $0x7,%eax
801015b8:	29 d0                	sub    %edx,%eax
801015ba:	ba 01 00 00 00       	mov    $0x1,%edx
801015bf:	89 c1                	mov    %eax,%ecx
801015c1:	d3 e2                	shl    %cl,%edx
801015c3:	89 d0                	mov    %edx,%eax
801015c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cb:	8d 50 07             	lea    0x7(%eax),%edx
801015ce:	85 c0                	test   %eax,%eax
801015d0:	0f 48 c2             	cmovs  %edx,%eax
801015d3:	c1 f8 03             	sar    $0x3,%eax
801015d6:	89 c2                	mov    %eax,%edx
801015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015db:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015e0:	0f b6 c0             	movzbl %al,%eax
801015e3:	23 45 ec             	and    -0x14(%ebp),%eax
801015e6:	85 c0                	test   %eax,%eax
801015e8:	75 0d                	jne    801015f7 <bfree+0x91>
    panic("freeing free block");
801015ea:	83 ec 0c             	sub    $0xc,%esp
801015ed:	68 be 8e 10 80       	push   $0x80108ebe
801015f2:	e8 6f ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	8d 50 07             	lea    0x7(%eax),%edx
801015fd:	85 c0                	test   %eax,%eax
801015ff:	0f 48 c2             	cmovs  %edx,%eax
80101602:	c1 f8 03             	sar    $0x3,%eax
80101605:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101608:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010160d:	89 d1                	mov    %edx,%ecx
8010160f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101612:	f7 d2                	not    %edx
80101614:	21 ca                	and    %ecx,%edx
80101616:	89 d1                	mov    %edx,%ecx
80101618:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010161f:	83 ec 0c             	sub    $0xc,%esp
80101622:	ff 75 f4             	pushl  -0xc(%ebp)
80101625:	e8 55 25 00 00       	call   80103b7f <log_write>
8010162a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010162d:	83 ec 0c             	sub    $0xc,%esp
80101630:	ff 75 f4             	pushl  -0xc(%ebp)
80101633:	e8 f6 eb ff ff       	call   8010022e <brelse>
80101638:	83 c4 10             	add    $0x10,%esp
}
8010163b:	90                   	nop
8010163c:	c9                   	leave  
8010163d:	c3                   	ret    

8010163e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010163e:	55                   	push   %ebp
8010163f:	89 e5                	mov    %esp,%ebp
80101641:	57                   	push   %edi
80101642:	56                   	push   %esi
80101643:	53                   	push   %ebx
80101644:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101647:	83 ec 08             	sub    $0x8,%esp
8010164a:	68 d1 8e 10 80       	push   $0x80108ed1
8010164f:	68 40 22 11 80       	push   $0x80112240
80101654:	e8 bd 3d 00 00       	call   80105416 <initlock>
80101659:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010165c:	83 ec 08             	sub    $0x8,%esp
8010165f:	68 20 22 11 80       	push   $0x80112220
80101664:	ff 75 08             	pushl  0x8(%ebp)
80101667:	e8 18 fd ff ff       	call   80101384 <readsb>
8010166c:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010166f:	a1 38 22 11 80       	mov    0x80112238,%eax
80101674:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101677:	8b 3d 34 22 11 80    	mov    0x80112234,%edi
8010167d:	8b 35 30 22 11 80    	mov    0x80112230,%esi
80101683:	8b 1d 2c 22 11 80    	mov    0x8011222c,%ebx
80101689:	8b 0d 28 22 11 80    	mov    0x80112228,%ecx
8010168f:	8b 15 24 22 11 80    	mov    0x80112224,%edx
80101695:	a1 20 22 11 80       	mov    0x80112220,%eax
8010169a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010169d:	57                   	push   %edi
8010169e:	56                   	push   %esi
8010169f:	53                   	push   %ebx
801016a0:	51                   	push   %ecx
801016a1:	52                   	push   %edx
801016a2:	50                   	push   %eax
801016a3:	68 d8 8e 10 80       	push   $0x80108ed8
801016a8:	e8 19 ed ff ff       	call   801003c6 <cprintf>
801016ad:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016b0:	90                   	nop
801016b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016b4:	5b                   	pop    %ebx
801016b5:	5e                   	pop    %esi
801016b6:	5f                   	pop    %edi
801016b7:	5d                   	pop    %ebp
801016b8:	c3                   	ret    

801016b9 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016b9:	55                   	push   %ebp
801016ba:	89 e5                	mov    %esp,%ebp
801016bc:	83 ec 28             	sub    $0x28,%esp
801016bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801016c2:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016c6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016cd:	e9 9e 00 00 00       	jmp    80101770 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d5:	c1 e8 03             	shr    $0x3,%eax
801016d8:	89 c2                	mov    %eax,%edx
801016da:	a1 34 22 11 80       	mov    0x80112234,%eax
801016df:	01 d0                	add    %edx,%eax
801016e1:	83 ec 08             	sub    $0x8,%esp
801016e4:	50                   	push   %eax
801016e5:	ff 75 08             	pushl  0x8(%ebp)
801016e8:	e8 c9 ea ff ff       	call   801001b6 <bread>
801016ed:	83 c4 10             	add    $0x10,%esp
801016f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f6:	8d 50 18             	lea    0x18(%eax),%edx
801016f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016fc:	83 e0 07             	and    $0x7,%eax
801016ff:	c1 e0 06             	shl    $0x6,%eax
80101702:	01 d0                	add    %edx,%eax
80101704:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101707:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010170a:	0f b7 00             	movzwl (%eax),%eax
8010170d:	66 85 c0             	test   %ax,%ax
80101710:	75 4c                	jne    8010175e <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101712:	83 ec 04             	sub    $0x4,%esp
80101715:	6a 40                	push   $0x40
80101717:	6a 00                	push   $0x0
80101719:	ff 75 ec             	pushl  -0x14(%ebp)
8010171c:	e8 7a 3f 00 00       	call   8010569b <memset>
80101721:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101724:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101727:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010172b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010172e:	83 ec 0c             	sub    $0xc,%esp
80101731:	ff 75 f0             	pushl  -0x10(%ebp)
80101734:	e8 46 24 00 00       	call   80103b7f <log_write>
80101739:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010173c:	83 ec 0c             	sub    $0xc,%esp
8010173f:	ff 75 f0             	pushl  -0x10(%ebp)
80101742:	e8 e7 ea ff ff       	call   8010022e <brelse>
80101747:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	83 ec 08             	sub    $0x8,%esp
80101750:	50                   	push   %eax
80101751:	ff 75 08             	pushl  0x8(%ebp)
80101754:	e8 f8 00 00 00       	call   80101851 <iget>
80101759:	83 c4 10             	add    $0x10,%esp
8010175c:	eb 30                	jmp    8010178e <ialloc+0xd5>
    }
    brelse(bp);
8010175e:	83 ec 0c             	sub    $0xc,%esp
80101761:	ff 75 f0             	pushl  -0x10(%ebp)
80101764:	e8 c5 ea ff ff       	call   8010022e <brelse>
80101769:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010176c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101770:	8b 15 28 22 11 80    	mov    0x80112228,%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	39 c2                	cmp    %eax,%edx
8010177b:	0f 87 51 ff ff ff    	ja     801016d2 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101781:	83 ec 0c             	sub    $0xc,%esp
80101784:	68 2b 8f 10 80       	push   $0x80108f2b
80101789:	e8 d8 ed ff ff       	call   80100566 <panic>
}
8010178e:	c9                   	leave  
8010178f:	c3                   	ret    

80101790 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101790:	55                   	push   %ebp
80101791:	89 e5                	mov    %esp,%ebp
80101793:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101796:	8b 45 08             	mov    0x8(%ebp),%eax
80101799:	8b 40 04             	mov    0x4(%eax),%eax
8010179c:	c1 e8 03             	shr    $0x3,%eax
8010179f:	89 c2                	mov    %eax,%edx
801017a1:	a1 34 22 11 80       	mov    0x80112234,%eax
801017a6:	01 c2                	add    %eax,%edx
801017a8:	8b 45 08             	mov    0x8(%ebp),%eax
801017ab:	8b 00                	mov    (%eax),%eax
801017ad:	83 ec 08             	sub    $0x8,%esp
801017b0:	52                   	push   %edx
801017b1:	50                   	push   %eax
801017b2:	e8 ff e9 ff ff       	call   801001b6 <bread>
801017b7:	83 c4 10             	add    $0x10,%esp
801017ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c0:	8d 50 18             	lea    0x18(%eax),%edx
801017c3:	8b 45 08             	mov    0x8(%ebp),%eax
801017c6:	8b 40 04             	mov    0x4(%eax),%eax
801017c9:	83 e0 07             	and    $0x7,%eax
801017cc:	c1 e0 06             	shl    $0x6,%eax
801017cf:	01 d0                	add    %edx,%eax
801017d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017d4:	8b 45 08             	mov    0x8(%ebp),%eax
801017d7:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017de:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017e1:	8b 45 08             	mov    0x8(%ebp),%eax
801017e4:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017eb:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017ef:	8b 45 08             	mov    0x8(%ebp),%eax
801017f2:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101800:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101807:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010180b:	8b 45 08             	mov    0x8(%ebp),%eax
8010180e:	8b 50 18             	mov    0x18(%eax),%edx
80101811:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101814:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101817:	8b 45 08             	mov    0x8(%ebp),%eax
8010181a:	8d 50 1c             	lea    0x1c(%eax),%edx
8010181d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101820:	83 c0 0c             	add    $0xc,%eax
80101823:	83 ec 04             	sub    $0x4,%esp
80101826:	6a 34                	push   $0x34
80101828:	52                   	push   %edx
80101829:	50                   	push   %eax
8010182a:	e8 2b 3f 00 00       	call   8010575a <memmove>
8010182f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101832:	83 ec 0c             	sub    $0xc,%esp
80101835:	ff 75 f4             	pushl  -0xc(%ebp)
80101838:	e8 42 23 00 00       	call   80103b7f <log_write>
8010183d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101840:	83 ec 0c             	sub    $0xc,%esp
80101843:	ff 75 f4             	pushl  -0xc(%ebp)
80101846:	e8 e3 e9 ff ff       	call   8010022e <brelse>
8010184b:	83 c4 10             	add    $0x10,%esp
}
8010184e:	90                   	nop
8010184f:	c9                   	leave  
80101850:	c3                   	ret    

80101851 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101851:	55                   	push   %ebp
80101852:	89 e5                	mov    %esp,%ebp
80101854:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101857:	83 ec 0c             	sub    $0xc,%esp
8010185a:	68 40 22 11 80       	push   $0x80112240
8010185f:	e8 d4 3b 00 00       	call   80105438 <acquire>
80101864:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101867:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010186e:	c7 45 f4 74 22 11 80 	movl   $0x80112274,-0xc(%ebp)
80101875:	eb 5d                	jmp    801018d4 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187a:	8b 40 08             	mov    0x8(%eax),%eax
8010187d:	85 c0                	test   %eax,%eax
8010187f:	7e 39                	jle    801018ba <iget+0x69>
80101881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101884:	8b 00                	mov    (%eax),%eax
80101886:	3b 45 08             	cmp    0x8(%ebp),%eax
80101889:	75 2f                	jne    801018ba <iget+0x69>
8010188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188e:	8b 40 04             	mov    0x4(%eax),%eax
80101891:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101894:	75 24                	jne    801018ba <iget+0x69>
      ip->ref++;
80101896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101899:	8b 40 08             	mov    0x8(%eax),%eax
8010189c:	8d 50 01             	lea    0x1(%eax),%edx
8010189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a2:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018a5:	83 ec 0c             	sub    $0xc,%esp
801018a8:	68 40 22 11 80       	push   $0x80112240
801018ad:	e8 ed 3b 00 00       	call   8010549f <release>
801018b2:	83 c4 10             	add    $0x10,%esp
      return ip;
801018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b8:	eb 74                	jmp    8010192e <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018be:	75 10                	jne    801018d0 <iget+0x7f>
801018c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c3:	8b 40 08             	mov    0x8(%eax),%eax
801018c6:	85 c0                	test   %eax,%eax
801018c8:	75 06                	jne    801018d0 <iget+0x7f>
      empty = ip;
801018ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018cd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018d0:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018d4:	81 7d f4 14 32 11 80 	cmpl   $0x80113214,-0xc(%ebp)
801018db:	72 9a                	jb     80101877 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018e1:	75 0d                	jne    801018f0 <iget+0x9f>
    panic("iget: no inodes");
801018e3:	83 ec 0c             	sub    $0xc,%esp
801018e6:	68 3d 8f 10 80       	push   $0x80108f3d
801018eb:	e8 76 ec ff ff       	call   80100566 <panic>

  ip = empty;
801018f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f9:	8b 55 08             	mov    0x8(%ebp),%edx
801018fc:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 55 0c             	mov    0xc(%ebp),%edx
80101904:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101914:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010191b:	83 ec 0c             	sub    $0xc,%esp
8010191e:	68 40 22 11 80       	push   $0x80112240
80101923:	e8 77 3b 00 00       	call   8010549f <release>
80101928:	83 c4 10             	add    $0x10,%esp

  return ip;
8010192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010192e:	c9                   	leave  
8010192f:	c3                   	ret    

80101930 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101930:	55                   	push   %ebp
80101931:	89 e5                	mov    %esp,%ebp
80101933:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101936:	83 ec 0c             	sub    $0xc,%esp
80101939:	68 40 22 11 80       	push   $0x80112240
8010193e:	e8 f5 3a 00 00       	call   80105438 <acquire>
80101943:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101946:	8b 45 08             	mov    0x8(%ebp),%eax
80101949:	8b 40 08             	mov    0x8(%eax),%eax
8010194c:	8d 50 01             	lea    0x1(%eax),%edx
8010194f:	8b 45 08             	mov    0x8(%ebp),%eax
80101952:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101955:	83 ec 0c             	sub    $0xc,%esp
80101958:	68 40 22 11 80       	push   $0x80112240
8010195d:	e8 3d 3b 00 00       	call   8010549f <release>
80101962:	83 c4 10             	add    $0x10,%esp
  return ip;
80101965:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101968:	c9                   	leave  
80101969:	c3                   	ret    

8010196a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010196a:	55                   	push   %ebp
8010196b:	89 e5                	mov    %esp,%ebp
8010196d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101970:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101974:	74 0a                	je     80101980 <ilock+0x16>
80101976:	8b 45 08             	mov    0x8(%ebp),%eax
80101979:	8b 40 08             	mov    0x8(%eax),%eax
8010197c:	85 c0                	test   %eax,%eax
8010197e:	7f 0d                	jg     8010198d <ilock+0x23>
    panic("ilock");
80101980:	83 ec 0c             	sub    $0xc,%esp
80101983:	68 4d 8f 10 80       	push   $0x80108f4d
80101988:	e8 d9 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010198d:	83 ec 0c             	sub    $0xc,%esp
80101990:	68 40 22 11 80       	push   $0x80112240
80101995:	e8 9e 3a 00 00       	call   80105438 <acquire>
8010199a:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010199d:	eb 13                	jmp    801019b2 <ilock+0x48>
    sleep(ip, &icache.lock);
8010199f:	83 ec 08             	sub    $0x8,%esp
801019a2:	68 40 22 11 80       	push   $0x80112240
801019a7:	ff 75 08             	pushl  0x8(%ebp)
801019aa:	e8 87 37 00 00       	call   80105136 <sleep>
801019af:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801019b2:	8b 45 08             	mov    0x8(%ebp),%eax
801019b5:	8b 40 0c             	mov    0xc(%eax),%eax
801019b8:	83 e0 01             	and    $0x1,%eax
801019bb:	85 c0                	test   %eax,%eax
801019bd:	75 e0                	jne    8010199f <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019bf:	8b 45 08             	mov    0x8(%ebp),%eax
801019c2:	8b 40 0c             	mov    0xc(%eax),%eax
801019c5:	83 c8 01             	or     $0x1,%eax
801019c8:	89 c2                	mov    %eax,%edx
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019d0:	83 ec 0c             	sub    $0xc,%esp
801019d3:	68 40 22 11 80       	push   $0x80112240
801019d8:	e8 c2 3a 00 00       	call   8010549f <release>
801019dd:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019e0:	8b 45 08             	mov    0x8(%ebp),%eax
801019e3:	8b 40 0c             	mov    0xc(%eax),%eax
801019e6:	83 e0 02             	and    $0x2,%eax
801019e9:	85 c0                	test   %eax,%eax
801019eb:	0f 85 d4 00 00 00    	jne    80101ac5 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	8b 40 04             	mov    0x4(%eax),%eax
801019f7:	c1 e8 03             	shr    $0x3,%eax
801019fa:	89 c2                	mov    %eax,%edx
801019fc:	a1 34 22 11 80       	mov    0x80112234,%eax
80101a01:	01 c2                	add    %eax,%edx
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
80101a06:	8b 00                	mov    (%eax),%eax
80101a08:	83 ec 08             	sub    $0x8,%esp
80101a0b:	52                   	push   %edx
80101a0c:	50                   	push   %eax
80101a0d:	e8 a4 e7 ff ff       	call   801001b6 <bread>
80101a12:	83 c4 10             	add    $0x10,%esp
80101a15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1b:	8d 50 18             	lea    0x18(%eax),%edx
80101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a21:	8b 40 04             	mov    0x4(%eax),%eax
80101a24:	83 e0 07             	and    $0x7,%eax
80101a27:	c1 e0 06             	shl    $0x6,%eax
80101a2a:	01 d0                	add    %edx,%eax
80101a2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a32:	0f b7 10             	movzwl (%eax),%edx
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a43:	8b 45 08             	mov    0x8(%ebp),%eax
80101a46:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a62:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a69:	8b 50 08             	mov    0x8(%eax),%edx
80101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6f:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a75:	8d 50 0c             	lea    0xc(%eax),%edx
80101a78:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7b:	83 c0 1c             	add    $0x1c,%eax
80101a7e:	83 ec 04             	sub    $0x4,%esp
80101a81:	6a 34                	push   $0x34
80101a83:	52                   	push   %edx
80101a84:	50                   	push   %eax
80101a85:	e8 d0 3c 00 00       	call   8010575a <memmove>
80101a8a:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a8d:	83 ec 0c             	sub    $0xc,%esp
80101a90:	ff 75 f4             	pushl  -0xc(%ebp)
80101a93:	e8 96 e7 ff ff       	call   8010022e <brelse>
80101a98:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa1:	83 c8 02             	or     $0x2,%eax
80101aa4:	89 c2                	mov    %eax,%edx
80101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa9:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101aac:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ab3:	66 85 c0             	test   %ax,%ax
80101ab6:	75 0d                	jne    80101ac5 <ilock+0x15b>
      panic("ilock: no type");
80101ab8:	83 ec 0c             	sub    $0xc,%esp
80101abb:	68 53 8f 10 80       	push   $0x80108f53
80101ac0:	e8 a1 ea ff ff       	call   80100566 <panic>
  }
}
80101ac5:	90                   	nop
80101ac6:	c9                   	leave  
80101ac7:	c3                   	ret    

80101ac8 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ac8:	55                   	push   %ebp
80101ac9:	89 e5                	mov    %esp,%ebp
80101acb:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ace:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ad2:	74 17                	je     80101aeb <iunlock+0x23>
80101ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad7:	8b 40 0c             	mov    0xc(%eax),%eax
80101ada:	83 e0 01             	and    $0x1,%eax
80101add:	85 c0                	test   %eax,%eax
80101adf:	74 0a                	je     80101aeb <iunlock+0x23>
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	8b 40 08             	mov    0x8(%eax),%eax
80101ae7:	85 c0                	test   %eax,%eax
80101ae9:	7f 0d                	jg     80101af8 <iunlock+0x30>
    panic("iunlock");
80101aeb:	83 ec 0c             	sub    $0xc,%esp
80101aee:	68 62 8f 10 80       	push   $0x80108f62
80101af3:	e8 6e ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101af8:	83 ec 0c             	sub    $0xc,%esp
80101afb:	68 40 22 11 80       	push   $0x80112240
80101b00:	e8 33 39 00 00       	call   80105438 <acquire>
80101b05:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b08:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0e:	83 e0 fe             	and    $0xfffffffe,%eax
80101b11:	89 c2                	mov    %eax,%edx
80101b13:	8b 45 08             	mov    0x8(%ebp),%eax
80101b16:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b19:	83 ec 0c             	sub    $0xc,%esp
80101b1c:	ff 75 08             	pushl  0x8(%ebp)
80101b1f:	e8 00 37 00 00       	call   80105224 <wakeup>
80101b24:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b27:	83 ec 0c             	sub    $0xc,%esp
80101b2a:	68 40 22 11 80       	push   $0x80112240
80101b2f:	e8 6b 39 00 00       	call   8010549f <release>
80101b34:	83 c4 10             	add    $0x10,%esp
}
80101b37:	90                   	nop
80101b38:	c9                   	leave  
80101b39:	c3                   	ret    

80101b3a <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b3a:	55                   	push   %ebp
80101b3b:	89 e5                	mov    %esp,%ebp
80101b3d:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b40:	83 ec 0c             	sub    $0xc,%esp
80101b43:	68 40 22 11 80       	push   $0x80112240
80101b48:	e8 eb 38 00 00       	call   80105438 <acquire>
80101b4d:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	8b 40 08             	mov    0x8(%eax),%eax
80101b56:	83 f8 01             	cmp    $0x1,%eax
80101b59:	0f 85 a9 00 00 00    	jne    80101c08 <iput+0xce>
80101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b62:	8b 40 0c             	mov    0xc(%eax),%eax
80101b65:	83 e0 02             	and    $0x2,%eax
80101b68:	85 c0                	test   %eax,%eax
80101b6a:	0f 84 98 00 00 00    	je     80101c08 <iput+0xce>
80101b70:	8b 45 08             	mov    0x8(%ebp),%eax
80101b73:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b77:	66 85 c0             	test   %ax,%ax
80101b7a:	0f 85 88 00 00 00    	jne    80101c08 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b80:	8b 45 08             	mov    0x8(%ebp),%eax
80101b83:	8b 40 0c             	mov    0xc(%eax),%eax
80101b86:	83 e0 01             	and    $0x1,%eax
80101b89:	85 c0                	test   %eax,%eax
80101b8b:	74 0d                	je     80101b9a <iput+0x60>
      panic("iput busy");
80101b8d:	83 ec 0c             	sub    $0xc,%esp
80101b90:	68 6a 8f 10 80       	push   $0x80108f6a
80101b95:	e8 cc e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9d:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba0:	83 c8 01             	or     $0x1,%eax
80101ba3:	89 c2                	mov    %eax,%edx
80101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba8:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bab:	83 ec 0c             	sub    $0xc,%esp
80101bae:	68 40 22 11 80       	push   $0x80112240
80101bb3:	e8 e7 38 00 00       	call   8010549f <release>
80101bb8:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bbb:	83 ec 0c             	sub    $0xc,%esp
80101bbe:	ff 75 08             	pushl  0x8(%ebp)
80101bc1:	e8 a8 01 00 00       	call   80101d6e <itrunc>
80101bc6:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bd2:	83 ec 0c             	sub    $0xc,%esp
80101bd5:	ff 75 08             	pushl  0x8(%ebp)
80101bd8:	e8 b3 fb ff ff       	call   80101790 <iupdate>
80101bdd:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101be0:	83 ec 0c             	sub    $0xc,%esp
80101be3:	68 40 22 11 80       	push   $0x80112240
80101be8:	e8 4b 38 00 00       	call   80105438 <acquire>
80101bed:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bfa:	83 ec 0c             	sub    $0xc,%esp
80101bfd:	ff 75 08             	pushl  0x8(%ebp)
80101c00:	e8 1f 36 00 00       	call   80105224 <wakeup>
80101c05:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	8b 40 08             	mov    0x8(%eax),%eax
80101c0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	68 40 22 11 80       	push   $0x80112240
80101c1f:	e8 7b 38 00 00       	call   8010549f <release>
80101c24:	83 c4 10             	add    $0x10,%esp
}
80101c27:	90                   	nop
80101c28:	c9                   	leave  
80101c29:	c3                   	ret    

80101c2a <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c2a:	55                   	push   %ebp
80101c2b:	89 e5                	mov    %esp,%ebp
80101c2d:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	ff 75 08             	pushl  0x8(%ebp)
80101c36:	e8 8d fe ff ff       	call   80101ac8 <iunlock>
80101c3b:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c3e:	83 ec 0c             	sub    $0xc,%esp
80101c41:	ff 75 08             	pushl  0x8(%ebp)
80101c44:	e8 f1 fe ff ff       	call   80101b3a <iput>
80101c49:	83 c4 10             	add    $0x10,%esp
}
80101c4c:	90                   	nop
80101c4d:	c9                   	leave  
80101c4e:	c3                   	ret    

80101c4f <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c4f:	55                   	push   %ebp
80101c50:	89 e5                	mov    %esp,%ebp
80101c52:	53                   	push   %ebx
80101c53:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c56:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c5a:	77 42                	ja     80101c9e <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c62:	83 c2 04             	add    $0x4,%edx
80101c65:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c70:	75 24                	jne    80101c96 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c72:	8b 45 08             	mov    0x8(%ebp),%eax
80101c75:	8b 00                	mov    (%eax),%eax
80101c77:	83 ec 0c             	sub    $0xc,%esp
80101c7a:	50                   	push   %eax
80101c7b:	e8 9a f7 ff ff       	call   8010141a <balloc>
80101c80:	83 c4 10             	add    $0x10,%esp
80101c83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c8c:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c92:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c99:	e9 cb 00 00 00       	jmp    80101d69 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c9e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ca2:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ca6:	0f 87 b0 00 00 00    	ja     80101d5c <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cac:	8b 45 08             	mov    0x8(%ebp),%eax
80101caf:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb9:	75 1d                	jne    80101cd8 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	8b 00                	mov    (%eax),%eax
80101cc0:	83 ec 0c             	sub    $0xc,%esp
80101cc3:	50                   	push   %eax
80101cc4:	e8 51 f7 ff ff       	call   8010141a <balloc>
80101cc9:	83 c4 10             	add    $0x10,%esp
80101ccc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd5:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	8b 00                	mov    (%eax),%eax
80101cdd:	83 ec 08             	sub    $0x8,%esp
80101ce0:	ff 75 f4             	pushl  -0xc(%ebp)
80101ce3:	50                   	push   %eax
80101ce4:	e8 cd e4 ff ff       	call   801001b6 <bread>
80101ce9:	83 c4 10             	add    $0x10,%esp
80101cec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf2:	83 c0 18             	add    $0x18,%eax
80101cf5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d05:	01 d0                	add    %edx,%eax
80101d07:	8b 00                	mov    (%eax),%eax
80101d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d10:	75 37                	jne    80101d49 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101d12:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d1f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d22:	8b 45 08             	mov    0x8(%ebp),%eax
80101d25:	8b 00                	mov    (%eax),%eax
80101d27:	83 ec 0c             	sub    $0xc,%esp
80101d2a:	50                   	push   %eax
80101d2b:	e8 ea f6 ff ff       	call   8010141a <balloc>
80101d30:	83 c4 10             	add    $0x10,%esp
80101d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d39:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d3b:	83 ec 0c             	sub    $0xc,%esp
80101d3e:	ff 75 f0             	pushl  -0x10(%ebp)
80101d41:	e8 39 1e 00 00       	call   80103b7f <log_write>
80101d46:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d49:	83 ec 0c             	sub    $0xc,%esp
80101d4c:	ff 75 f0             	pushl  -0x10(%ebp)
80101d4f:	e8 da e4 ff ff       	call   8010022e <brelse>
80101d54:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5a:	eb 0d                	jmp    80101d69 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d5c:	83 ec 0c             	sub    $0xc,%esp
80101d5f:	68 74 8f 10 80       	push   $0x80108f74
80101d64:	e8 fd e7 ff ff       	call   80100566 <panic>
}
80101d69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d6c:	c9                   	leave  
80101d6d:	c3                   	ret    

80101d6e <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d6e:	55                   	push   %ebp
80101d6f:	89 e5                	mov    %esp,%ebp
80101d71:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d7b:	eb 45                	jmp    80101dc2 <itrunc+0x54>
    if(ip->addrs[i]){
80101d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d83:	83 c2 04             	add    $0x4,%edx
80101d86:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8a:	85 c0                	test   %eax,%eax
80101d8c:	74 30                	je     80101dbe <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d94:	83 c2 04             	add    $0x4,%edx
80101d97:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d9b:	8b 55 08             	mov    0x8(%ebp),%edx
80101d9e:	8b 12                	mov    (%edx),%edx
80101da0:	83 ec 08             	sub    $0x8,%esp
80101da3:	50                   	push   %eax
80101da4:	52                   	push   %edx
80101da5:	e8 bc f7 ff ff       	call   80101566 <bfree>
80101daa:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db3:	83 c2 04             	add    $0x4,%edx
80101db6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dbd:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dbe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dc2:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc6:	7e b5                	jle    80101d7d <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcb:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dce:	85 c0                	test   %eax,%eax
80101dd0:	0f 84 a1 00 00 00    	je     80101e77 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd9:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	83 ec 08             	sub    $0x8,%esp
80101de4:	52                   	push   %edx
80101de5:	50                   	push   %eax
80101de6:	e8 cb e3 ff ff       	call   801001b6 <bread>
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df4:	83 c0 18             	add    $0x18,%eax
80101df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e01:	eb 3c                	jmp    80101e3f <itrunc+0xd1>
      if(a[j])
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 23                	je     80101e3b <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e25:	01 d0                	add    %edx,%eax
80101e27:	8b 00                	mov    (%eax),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 2e f7 ff ff       	call   80101566 <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e42:	83 f8 7f             	cmp    $0x7f,%eax
80101e45:	76 bc                	jbe    80101e03 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	ff 75 ec             	pushl  -0x14(%ebp)
80101e4d:	e8 dc e3 ff ff       	call   8010022e <brelse>
80101e52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e5b:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5e:	8b 12                	mov    (%edx),%edx
80101e60:	83 ec 08             	sub    $0x8,%esp
80101e63:	50                   	push   %eax
80101e64:	52                   	push   %edx
80101e65:	e8 fc f6 ff ff       	call   80101566 <bfree>
80101e6a:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e70:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e81:	83 ec 0c             	sub    $0xc,%esp
80101e84:	ff 75 08             	pushl  0x8(%ebp)
80101e87:	e8 04 f9 ff ff       	call   80101790 <iupdate>
80101e8c:	83 c4 10             	add    $0x10,%esp
}
80101e8f:	90                   	nop
80101e90:	c9                   	leave  
80101e91:	c3                   	ret    

80101e92 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e92:	55                   	push   %ebp
80101e93:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 00                	mov    (%eax),%eax
80101e9a:	89 c2                	mov    %eax,%edx
80101e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9f:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea5:	8b 50 04             	mov    0x4(%eax),%edx
80101ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eab:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eae:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb1:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb8:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebe:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec5:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecc:	8b 50 18             	mov    0x18(%eax),%edx
80101ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed2:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed5:	90                   	nop
80101ed6:	5d                   	pop    %ebp
80101ed7:	c3                   	ret    

80101ed8 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed8:	55                   	push   %ebp
80101ed9:	89 e5                	mov    %esp,%ebp
80101edb:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ede:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee5:	66 83 f8 03          	cmp    $0x3,%ax
80101ee9:	75 5c                	jne    80101f47 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef2:	66 85 c0             	test   %ax,%ax
80101ef5:	78 20                	js     80101f17 <readi+0x3f>
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101efe:	66 83 f8 09          	cmp    $0x9,%ax
80101f02:	7f 13                	jg     80101f17 <readi+0x3f>
80101f04:	8b 45 08             	mov    0x8(%ebp),%eax
80101f07:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0b:	98                   	cwtl   
80101f0c:	8b 04 c5 c0 21 11 80 	mov    -0x7feede40(,%eax,8),%eax
80101f13:	85 c0                	test   %eax,%eax
80101f15:	75 0a                	jne    80101f21 <readi+0x49>
      return -1;
80101f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1c:	e9 0c 01 00 00       	jmp    8010202d <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f21:	8b 45 08             	mov    0x8(%ebp),%eax
80101f24:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f28:	98                   	cwtl   
80101f29:	8b 04 c5 c0 21 11 80 	mov    -0x7feede40(,%eax,8),%eax
80101f30:	8b 55 14             	mov    0x14(%ebp),%edx
80101f33:	83 ec 04             	sub    $0x4,%esp
80101f36:	52                   	push   %edx
80101f37:	ff 75 0c             	pushl  0xc(%ebp)
80101f3a:	ff 75 08             	pushl  0x8(%ebp)
80101f3d:	ff d0                	call   *%eax
80101f3f:	83 c4 10             	add    $0x10,%esp
80101f42:	e9 e6 00 00 00       	jmp    8010202d <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	8b 40 18             	mov    0x18(%eax),%eax
80101f4d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f50:	72 0d                	jb     80101f5f <readi+0x87>
80101f52:	8b 55 10             	mov    0x10(%ebp),%edx
80101f55:	8b 45 14             	mov    0x14(%ebp),%eax
80101f58:	01 d0                	add    %edx,%eax
80101f5a:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f5d:	73 0a                	jae    80101f69 <readi+0x91>
    return -1;
80101f5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f64:	e9 c4 00 00 00       	jmp    8010202d <readi+0x155>
  if(off + n > ip->size)
80101f69:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6c:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6f:	01 c2                	add    %eax,%edx
80101f71:	8b 45 08             	mov    0x8(%ebp),%eax
80101f74:	8b 40 18             	mov    0x18(%eax),%eax
80101f77:	39 c2                	cmp    %eax,%edx
80101f79:	76 0c                	jbe    80101f87 <readi+0xaf>
    n = ip->size - off;
80101f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7e:	8b 40 18             	mov    0x18(%eax),%eax
80101f81:	2b 45 10             	sub    0x10(%ebp),%eax
80101f84:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8e:	e9 8b 00 00 00       	jmp    8010201e <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f93:	8b 45 10             	mov    0x10(%ebp),%eax
80101f96:	c1 e8 09             	shr    $0x9,%eax
80101f99:	83 ec 08             	sub    $0x8,%esp
80101f9c:	50                   	push   %eax
80101f9d:	ff 75 08             	pushl  0x8(%ebp)
80101fa0:	e8 aa fc ff ff       	call   80101c4f <bmap>
80101fa5:	83 c4 10             	add    $0x10,%esp
80101fa8:	89 c2                	mov    %eax,%edx
80101faa:	8b 45 08             	mov    0x8(%ebp),%eax
80101fad:	8b 00                	mov    (%eax),%eax
80101faf:	83 ec 08             	sub    $0x8,%esp
80101fb2:	52                   	push   %edx
80101fb3:	50                   	push   %eax
80101fb4:	e8 fd e1 ff ff       	call   801001b6 <bread>
80101fb9:	83 c4 10             	add    $0x10,%esp
80101fbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc7:	ba 00 02 00 00       	mov    $0x200,%edx
80101fcc:	29 c2                	sub    %eax,%edx
80101fce:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd1:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd4:	39 c2                	cmp    %eax,%edx
80101fd6:	0f 46 c2             	cmovbe %edx,%eax
80101fd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdf:	8d 50 18             	lea    0x18(%eax),%edx
80101fe2:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe5:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fea:	01 d0                	add    %edx,%eax
80101fec:	83 ec 04             	sub    $0x4,%esp
80101fef:	ff 75 ec             	pushl  -0x14(%ebp)
80101ff2:	50                   	push   %eax
80101ff3:	ff 75 0c             	pushl  0xc(%ebp)
80101ff6:	e8 5f 37 00 00       	call   8010575a <memmove>
80101ffb:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffe:	83 ec 0c             	sub    $0xc,%esp
80102001:	ff 75 f0             	pushl  -0x10(%ebp)
80102004:	e8 25 e2 ff ff       	call   8010022e <brelse>
80102009:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010200c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102012:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102015:	01 45 10             	add    %eax,0x10(%ebp)
80102018:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201b:	01 45 0c             	add    %eax,0xc(%ebp)
8010201e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102021:	3b 45 14             	cmp    0x14(%ebp),%eax
80102024:	0f 82 69 ff ff ff    	jb     80101f93 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010202a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010202d:	c9                   	leave  
8010202e:	c3                   	ret    

8010202f <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202f:	55                   	push   %ebp
80102030:	89 e5                	mov    %esp,%ebp
80102032:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102035:	8b 45 08             	mov    0x8(%ebp),%eax
80102038:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010203c:	66 83 f8 03          	cmp    $0x3,%ax
80102040:	75 5c                	jne    8010209e <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102049:	66 85 c0             	test   %ax,%ax
8010204c:	78 20                	js     8010206e <writei+0x3f>
8010204e:	8b 45 08             	mov    0x8(%ebp),%eax
80102051:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102055:	66 83 f8 09          	cmp    $0x9,%ax
80102059:	7f 13                	jg     8010206e <writei+0x3f>
8010205b:	8b 45 08             	mov    0x8(%ebp),%eax
8010205e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102062:	98                   	cwtl   
80102063:	8b 04 c5 c4 21 11 80 	mov    -0x7feede3c(,%eax,8),%eax
8010206a:	85 c0                	test   %eax,%eax
8010206c:	75 0a                	jne    80102078 <writei+0x49>
      return -1;
8010206e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102073:	e9 3d 01 00 00       	jmp    801021b5 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102078:	8b 45 08             	mov    0x8(%ebp),%eax
8010207b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010207f:	98                   	cwtl   
80102080:	8b 04 c5 c4 21 11 80 	mov    -0x7feede3c(,%eax,8),%eax
80102087:	8b 55 14             	mov    0x14(%ebp),%edx
8010208a:	83 ec 04             	sub    $0x4,%esp
8010208d:	52                   	push   %edx
8010208e:	ff 75 0c             	pushl  0xc(%ebp)
80102091:	ff 75 08             	pushl  0x8(%ebp)
80102094:	ff d0                	call   *%eax
80102096:	83 c4 10             	add    $0x10,%esp
80102099:	e9 17 01 00 00       	jmp    801021b5 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
8010209e:	8b 45 08             	mov    0x8(%ebp),%eax
801020a1:	8b 40 18             	mov    0x18(%eax),%eax
801020a4:	3b 45 10             	cmp    0x10(%ebp),%eax
801020a7:	72 0d                	jb     801020b6 <writei+0x87>
801020a9:	8b 55 10             	mov    0x10(%ebp),%edx
801020ac:	8b 45 14             	mov    0x14(%ebp),%eax
801020af:	01 d0                	add    %edx,%eax
801020b1:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b4:	73 0a                	jae    801020c0 <writei+0x91>
    return -1;
801020b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bb:	e9 f5 00 00 00       	jmp    801021b5 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020c0:	8b 55 10             	mov    0x10(%ebp),%edx
801020c3:	8b 45 14             	mov    0x14(%ebp),%eax
801020c6:	01 d0                	add    %edx,%eax
801020c8:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020cd:	76 0a                	jbe    801020d9 <writei+0xaa>
    return -1;
801020cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d4:	e9 dc 00 00 00       	jmp    801021b5 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e0:	e9 99 00 00 00       	jmp    8010217e <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e5:	8b 45 10             	mov    0x10(%ebp),%eax
801020e8:	c1 e8 09             	shr    $0x9,%eax
801020eb:	83 ec 08             	sub    $0x8,%esp
801020ee:	50                   	push   %eax
801020ef:	ff 75 08             	pushl  0x8(%ebp)
801020f2:	e8 58 fb ff ff       	call   80101c4f <bmap>
801020f7:	83 c4 10             	add    $0x10,%esp
801020fa:	89 c2                	mov    %eax,%edx
801020fc:	8b 45 08             	mov    0x8(%ebp),%eax
801020ff:	8b 00                	mov    (%eax),%eax
80102101:	83 ec 08             	sub    $0x8,%esp
80102104:	52                   	push   %edx
80102105:	50                   	push   %eax
80102106:	e8 ab e0 ff ff       	call   801001b6 <bread>
8010210b:	83 c4 10             	add    $0x10,%esp
8010210e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102111:	8b 45 10             	mov    0x10(%ebp),%eax
80102114:	25 ff 01 00 00       	and    $0x1ff,%eax
80102119:	ba 00 02 00 00       	mov    $0x200,%edx
8010211e:	29 c2                	sub    %eax,%edx
80102120:	8b 45 14             	mov    0x14(%ebp),%eax
80102123:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102126:	39 c2                	cmp    %eax,%edx
80102128:	0f 46 c2             	cmovbe %edx,%eax
8010212b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010212e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102131:	8d 50 18             	lea    0x18(%eax),%edx
80102134:	8b 45 10             	mov    0x10(%ebp),%eax
80102137:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213c:	01 d0                	add    %edx,%eax
8010213e:	83 ec 04             	sub    $0x4,%esp
80102141:	ff 75 ec             	pushl  -0x14(%ebp)
80102144:	ff 75 0c             	pushl  0xc(%ebp)
80102147:	50                   	push   %eax
80102148:	e8 0d 36 00 00       	call   8010575a <memmove>
8010214d:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102150:	83 ec 0c             	sub    $0xc,%esp
80102153:	ff 75 f0             	pushl  -0x10(%ebp)
80102156:	e8 24 1a 00 00       	call   80103b7f <log_write>
8010215b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010215e:	83 ec 0c             	sub    $0xc,%esp
80102161:	ff 75 f0             	pushl  -0x10(%ebp)
80102164:	e8 c5 e0 ff ff       	call   8010022e <brelse>
80102169:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 10             	add    %eax,0x10(%ebp)
80102178:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217b:	01 45 0c             	add    %eax,0xc(%ebp)
8010217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102181:	3b 45 14             	cmp    0x14(%ebp),%eax
80102184:	0f 82 5b ff ff ff    	jb     801020e5 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010218a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010218e:	74 22                	je     801021b2 <writei+0x183>
80102190:	8b 45 08             	mov    0x8(%ebp),%eax
80102193:	8b 40 18             	mov    0x18(%eax),%eax
80102196:	3b 45 10             	cmp    0x10(%ebp),%eax
80102199:	73 17                	jae    801021b2 <writei+0x183>
    ip->size = off;
8010219b:	8b 45 08             	mov    0x8(%ebp),%eax
8010219e:	8b 55 10             	mov    0x10(%ebp),%edx
801021a1:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021a4:	83 ec 0c             	sub    $0xc,%esp
801021a7:	ff 75 08             	pushl  0x8(%ebp)
801021aa:	e8 e1 f5 ff ff       	call   80101790 <iupdate>
801021af:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b2:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b5:	c9                   	leave  
801021b6:	c3                   	ret    

801021b7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b7:	55                   	push   %ebp
801021b8:	89 e5                	mov    %esp,%ebp
801021ba:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bd:	83 ec 04             	sub    $0x4,%esp
801021c0:	6a 0e                	push   $0xe
801021c2:	ff 75 0c             	pushl  0xc(%ebp)
801021c5:	ff 75 08             	pushl  0x8(%ebp)
801021c8:	e8 23 36 00 00       	call   801057f0 <strncmp>
801021cd:	83 c4 10             	add    $0x10,%esp
}
801021d0:	c9                   	leave  
801021d1:	c3                   	ret    

801021d2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d2:	55                   	push   %ebp
801021d3:	89 e5                	mov    %esp,%ebp
801021d5:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021df:	66 83 f8 01          	cmp    $0x1,%ax
801021e3:	74 0d                	je     801021f2 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e5:	83 ec 0c             	sub    $0xc,%esp
801021e8:	68 87 8f 10 80       	push   $0x80108f87
801021ed:	e8 74 e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f9:	eb 7b                	jmp    80102276 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fb:	6a 10                	push   $0x10
801021fd:	ff 75 f4             	pushl  -0xc(%ebp)
80102200:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102203:	50                   	push   %eax
80102204:	ff 75 08             	pushl  0x8(%ebp)
80102207:	e8 cc fc ff ff       	call   80101ed8 <readi>
8010220c:	83 c4 10             	add    $0x10,%esp
8010220f:	83 f8 10             	cmp    $0x10,%eax
80102212:	74 0d                	je     80102221 <dirlookup+0x4f>
      panic("dirlink read");
80102214:	83 ec 0c             	sub    $0xc,%esp
80102217:	68 99 8f 10 80       	push   $0x80108f99
8010221c:	e8 45 e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102221:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102225:	66 85 c0             	test   %ax,%ax
80102228:	74 47                	je     80102271 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222a:	83 ec 08             	sub    $0x8,%esp
8010222d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102230:	83 c0 02             	add    $0x2,%eax
80102233:	50                   	push   %eax
80102234:	ff 75 0c             	pushl  0xc(%ebp)
80102237:	e8 7b ff ff ff       	call   801021b7 <namecmp>
8010223c:	83 c4 10             	add    $0x10,%esp
8010223f:	85 c0                	test   %eax,%eax
80102241:	75 2f                	jne    80102272 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102243:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102247:	74 08                	je     80102251 <dirlookup+0x7f>
        *poff = off;
80102249:	8b 45 10             	mov    0x10(%ebp),%eax
8010224c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010224f:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102251:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102255:	0f b7 c0             	movzwl %ax,%eax
80102258:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225b:	8b 45 08             	mov    0x8(%ebp),%eax
8010225e:	8b 00                	mov    (%eax),%eax
80102260:	83 ec 08             	sub    $0x8,%esp
80102263:	ff 75 f0             	pushl  -0x10(%ebp)
80102266:	50                   	push   %eax
80102267:	e8 e5 f5 ff ff       	call   80101851 <iget>
8010226c:	83 c4 10             	add    $0x10,%esp
8010226f:	eb 19                	jmp    8010228a <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102271:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102272:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102276:	8b 45 08             	mov    0x8(%ebp),%eax
80102279:	8b 40 18             	mov    0x18(%eax),%eax
8010227c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010227f:	0f 87 76 ff ff ff    	ja     801021fb <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102285:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228a:	c9                   	leave  
8010228b:	c3                   	ret    

8010228c <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228c:	55                   	push   %ebp
8010228d:	89 e5                	mov    %esp,%ebp
8010228f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102292:	83 ec 04             	sub    $0x4,%esp
80102295:	6a 00                	push   $0x0
80102297:	ff 75 0c             	pushl  0xc(%ebp)
8010229a:	ff 75 08             	pushl  0x8(%ebp)
8010229d:	e8 30 ff ff ff       	call   801021d2 <dirlookup>
801022a2:	83 c4 10             	add    $0x10,%esp
801022a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ac:	74 18                	je     801022c6 <dirlink+0x3a>
    iput(ip);
801022ae:	83 ec 0c             	sub    $0xc,%esp
801022b1:	ff 75 f0             	pushl  -0x10(%ebp)
801022b4:	e8 81 f8 ff ff       	call   80101b3a <iput>
801022b9:	83 c4 10             	add    $0x10,%esp
    return -1;
801022bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c1:	e9 9c 00 00 00       	jmp    80102362 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cd:	eb 39                	jmp    80102308 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d2:	6a 10                	push   $0x10
801022d4:	50                   	push   %eax
801022d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d8:	50                   	push   %eax
801022d9:	ff 75 08             	pushl  0x8(%ebp)
801022dc:	e8 f7 fb ff ff       	call   80101ed8 <readi>
801022e1:	83 c4 10             	add    $0x10,%esp
801022e4:	83 f8 10             	cmp    $0x10,%eax
801022e7:	74 0d                	je     801022f6 <dirlink+0x6a>
      panic("dirlink read");
801022e9:	83 ec 0c             	sub    $0xc,%esp
801022ec:	68 99 8f 10 80       	push   $0x80108f99
801022f1:	e8 70 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fa:	66 85 c0             	test   %ax,%ax
801022fd:	74 18                	je     80102317 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102302:	83 c0 10             	add    $0x10,%eax
80102305:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102308:	8b 45 08             	mov    0x8(%ebp),%eax
8010230b:	8b 50 18             	mov    0x18(%eax),%edx
8010230e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102311:	39 c2                	cmp    %eax,%edx
80102313:	77 ba                	ja     801022cf <dirlink+0x43>
80102315:	eb 01                	jmp    80102318 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102317:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102318:	83 ec 04             	sub    $0x4,%esp
8010231b:	6a 0e                	push   $0xe
8010231d:	ff 75 0c             	pushl  0xc(%ebp)
80102320:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102323:	83 c0 02             	add    $0x2,%eax
80102326:	50                   	push   %eax
80102327:	e8 1a 35 00 00       	call   80105846 <strncpy>
8010232c:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010232f:	8b 45 10             	mov    0x10(%ebp),%eax
80102332:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102339:	6a 10                	push   $0x10
8010233b:	50                   	push   %eax
8010233c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010233f:	50                   	push   %eax
80102340:	ff 75 08             	pushl  0x8(%ebp)
80102343:	e8 e7 fc ff ff       	call   8010202f <writei>
80102348:	83 c4 10             	add    $0x10,%esp
8010234b:	83 f8 10             	cmp    $0x10,%eax
8010234e:	74 0d                	je     8010235d <dirlink+0xd1>
    panic("dirlink");
80102350:	83 ec 0c             	sub    $0xc,%esp
80102353:	68 a6 8f 10 80       	push   $0x80108fa6
80102358:	e8 09 e2 ff ff       	call   80100566 <panic>
  
  return 0;
8010235d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102362:	c9                   	leave  
80102363:	c3                   	ret    

80102364 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102364:	55                   	push   %ebp
80102365:	89 e5                	mov    %esp,%ebp
80102367:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236a:	eb 04                	jmp    80102370 <skipelem+0xc>
    path++;
8010236c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102370:	8b 45 08             	mov    0x8(%ebp),%eax
80102373:	0f b6 00             	movzbl (%eax),%eax
80102376:	3c 2f                	cmp    $0x2f,%al
80102378:	74 f2                	je     8010236c <skipelem+0x8>
    path++;
  if(*path == 0)
8010237a:	8b 45 08             	mov    0x8(%ebp),%eax
8010237d:	0f b6 00             	movzbl (%eax),%eax
80102380:	84 c0                	test   %al,%al
80102382:	75 07                	jne    8010238b <skipelem+0x27>
    return 0;
80102384:	b8 00 00 00 00       	mov    $0x0,%eax
80102389:	eb 7b                	jmp    80102406 <skipelem+0xa2>
  s = path;
8010238b:	8b 45 08             	mov    0x8(%ebp),%eax
8010238e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102391:	eb 04                	jmp    80102397 <skipelem+0x33>
    path++;
80102393:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102397:	8b 45 08             	mov    0x8(%ebp),%eax
8010239a:	0f b6 00             	movzbl (%eax),%eax
8010239d:	3c 2f                	cmp    $0x2f,%al
8010239f:	74 0a                	je     801023ab <skipelem+0x47>
801023a1:	8b 45 08             	mov    0x8(%ebp),%eax
801023a4:	0f b6 00             	movzbl (%eax),%eax
801023a7:	84 c0                	test   %al,%al
801023a9:	75 e8                	jne    80102393 <skipelem+0x2f>
    path++;
  len = path - s;
801023ab:	8b 55 08             	mov    0x8(%ebp),%edx
801023ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b1:	29 c2                	sub    %eax,%edx
801023b3:	89 d0                	mov    %edx,%eax
801023b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b8:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023bc:	7e 15                	jle    801023d3 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023be:	83 ec 04             	sub    $0x4,%esp
801023c1:	6a 0e                	push   $0xe
801023c3:	ff 75 f4             	pushl  -0xc(%ebp)
801023c6:	ff 75 0c             	pushl  0xc(%ebp)
801023c9:	e8 8c 33 00 00       	call   8010575a <memmove>
801023ce:	83 c4 10             	add    $0x10,%esp
801023d1:	eb 26                	jmp    801023f9 <skipelem+0x95>
  else {
    memmove(name, s, len);
801023d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d6:	83 ec 04             	sub    $0x4,%esp
801023d9:	50                   	push   %eax
801023da:	ff 75 f4             	pushl  -0xc(%ebp)
801023dd:	ff 75 0c             	pushl  0xc(%ebp)
801023e0:	e8 75 33 00 00       	call   8010575a <memmove>
801023e5:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ee:	01 d0                	add    %edx,%eax
801023f0:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f3:	eb 04                	jmp    801023f9 <skipelem+0x95>
    path++;
801023f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
801023fc:	0f b6 00             	movzbl (%eax),%eax
801023ff:	3c 2f                	cmp    $0x2f,%al
80102401:	74 f2                	je     801023f5 <skipelem+0x91>
    path++;
  return path;
80102403:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102406:	c9                   	leave  
80102407:	c3                   	ret    

80102408 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102408:	55                   	push   %ebp
80102409:	89 e5                	mov    %esp,%ebp
8010240b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240e:	8b 45 08             	mov    0x8(%ebp),%eax
80102411:	0f b6 00             	movzbl (%eax),%eax
80102414:	3c 2f                	cmp    $0x2f,%al
80102416:	75 17                	jne    8010242f <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102418:	83 ec 08             	sub    $0x8,%esp
8010241b:	6a 01                	push   $0x1
8010241d:	6a 01                	push   $0x1
8010241f:	e8 2d f4 ff ff       	call   80101851 <iget>
80102424:	83 c4 10             	add    $0x10,%esp
80102427:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010242a:	e9 bb 00 00 00       	jmp    801024ea <namex+0xe2>
  else
    ip = idup(proc->cwd);
8010242f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102435:	8b 40 68             	mov    0x68(%eax),%eax
80102438:	83 ec 0c             	sub    $0xc,%esp
8010243b:	50                   	push   %eax
8010243c:	e8 ef f4 ff ff       	call   80101930 <idup>
80102441:	83 c4 10             	add    $0x10,%esp
80102444:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102447:	e9 9e 00 00 00       	jmp    801024ea <namex+0xe2>
    ilock(ip);
8010244c:	83 ec 0c             	sub    $0xc,%esp
8010244f:	ff 75 f4             	pushl  -0xc(%ebp)
80102452:	e8 13 f5 ff ff       	call   8010196a <ilock>
80102457:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010245a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102461:	66 83 f8 01          	cmp    $0x1,%ax
80102465:	74 18                	je     8010247f <namex+0x77>
      iunlockput(ip);
80102467:	83 ec 0c             	sub    $0xc,%esp
8010246a:	ff 75 f4             	pushl  -0xc(%ebp)
8010246d:	e8 b8 f7 ff ff       	call   80101c2a <iunlockput>
80102472:	83 c4 10             	add    $0x10,%esp
      return 0;
80102475:	b8 00 00 00 00       	mov    $0x0,%eax
8010247a:	e9 a7 00 00 00       	jmp    80102526 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010247f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102483:	74 20                	je     801024a5 <namex+0x9d>
80102485:	8b 45 08             	mov    0x8(%ebp),%eax
80102488:	0f b6 00             	movzbl (%eax),%eax
8010248b:	84 c0                	test   %al,%al
8010248d:	75 16                	jne    801024a5 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010248f:	83 ec 0c             	sub    $0xc,%esp
80102492:	ff 75 f4             	pushl  -0xc(%ebp)
80102495:	e8 2e f6 ff ff       	call   80101ac8 <iunlock>
8010249a:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a0:	e9 81 00 00 00       	jmp    80102526 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a5:	83 ec 04             	sub    $0x4,%esp
801024a8:	6a 00                	push   $0x0
801024aa:	ff 75 10             	pushl  0x10(%ebp)
801024ad:	ff 75 f4             	pushl  -0xc(%ebp)
801024b0:	e8 1d fd ff ff       	call   801021d2 <dirlookup>
801024b5:	83 c4 10             	add    $0x10,%esp
801024b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bf:	75 15                	jne    801024d6 <namex+0xce>
      iunlockput(ip);
801024c1:	83 ec 0c             	sub    $0xc,%esp
801024c4:	ff 75 f4             	pushl  -0xc(%ebp)
801024c7:	e8 5e f7 ff ff       	call   80101c2a <iunlockput>
801024cc:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cf:	b8 00 00 00 00       	mov    $0x0,%eax
801024d4:	eb 50                	jmp    80102526 <namex+0x11e>
    }
    iunlockput(ip);
801024d6:	83 ec 0c             	sub    $0xc,%esp
801024d9:	ff 75 f4             	pushl  -0xc(%ebp)
801024dc:	e8 49 f7 ff ff       	call   80101c2a <iunlockput>
801024e1:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024ea:	83 ec 08             	sub    $0x8,%esp
801024ed:	ff 75 10             	pushl  0x10(%ebp)
801024f0:	ff 75 08             	pushl  0x8(%ebp)
801024f3:	e8 6c fe ff ff       	call   80102364 <skipelem>
801024f8:	83 c4 10             	add    $0x10,%esp
801024fb:	89 45 08             	mov    %eax,0x8(%ebp)
801024fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102502:	0f 85 44 ff ff ff    	jne    8010244c <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102508:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010250c:	74 15                	je     80102523 <namex+0x11b>
    iput(ip);
8010250e:	83 ec 0c             	sub    $0xc,%esp
80102511:	ff 75 f4             	pushl  -0xc(%ebp)
80102514:	e8 21 f6 ff ff       	call   80101b3a <iput>
80102519:	83 c4 10             	add    $0x10,%esp
    return 0;
8010251c:	b8 00 00 00 00       	mov    $0x0,%eax
80102521:	eb 03                	jmp    80102526 <namex+0x11e>
  }
  return ip;
80102523:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102526:	c9                   	leave  
80102527:	c3                   	ret    

80102528 <namei>:

struct inode*
namei(char *path)
{
80102528:	55                   	push   %ebp
80102529:	89 e5                	mov    %esp,%ebp
8010252b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252e:	83 ec 04             	sub    $0x4,%esp
80102531:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102534:	50                   	push   %eax
80102535:	6a 00                	push   $0x0
80102537:	ff 75 08             	pushl  0x8(%ebp)
8010253a:	e8 c9 fe ff ff       	call   80102408 <namex>
8010253f:	83 c4 10             	add    $0x10,%esp
}
80102542:	c9                   	leave  
80102543:	c3                   	ret    

80102544 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102544:	55                   	push   %ebp
80102545:	89 e5                	mov    %esp,%ebp
80102547:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010254a:	83 ec 04             	sub    $0x4,%esp
8010254d:	ff 75 0c             	pushl  0xc(%ebp)
80102550:	6a 01                	push   $0x1
80102552:	ff 75 08             	pushl  0x8(%ebp)
80102555:	e8 ae fe ff ff       	call   80102408 <namex>
8010255a:	83 c4 10             	add    $0x10,%esp
}
8010255d:	c9                   	leave  
8010255e:	c3                   	ret    

8010255f <itoa>:

#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
8010255f:	55                   	push   %ebp
80102560:	89 e5                	mov    %esp,%ebp
80102562:	83 ec 20             	sub    $0x20,%esp
    char const digit[] = "0123456789";
80102565:	c7 45 ed 30 31 32 33 	movl   $0x33323130,-0x13(%ebp)
8010256c:	c7 45 f1 34 35 36 37 	movl   $0x37363534,-0xf(%ebp)
80102573:	66 c7 45 f5 38 39    	movw   $0x3938,-0xb(%ebp)
80102579:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
    char* p = b;
8010257d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102580:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if(i<0){
80102583:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102587:	79 0f                	jns    80102598 <itoa+0x39>
        *p++ = '-';
80102589:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010258c:	8d 50 01             	lea    0x1(%eax),%edx
8010258f:	89 55 fc             	mov    %edx,-0x4(%ebp)
80102592:	c6 00 2d             	movb   $0x2d,(%eax)
        i *= -1;
80102595:	f7 5d 08             	negl   0x8(%ebp)
    }
    int shifter = i;
80102598:	8b 45 08             	mov    0x8(%ebp),%eax
8010259b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    do{ //Move to where representation ends
        ++p;
8010259e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
        shifter = shifter/10;
801025a2:	8b 4d f8             	mov    -0x8(%ebp),%ecx
801025a5:	ba 67 66 66 66       	mov    $0x66666667,%edx
801025aa:	89 c8                	mov    %ecx,%eax
801025ac:	f7 ea                	imul   %edx
801025ae:	c1 fa 02             	sar    $0x2,%edx
801025b1:	89 c8                	mov    %ecx,%eax
801025b3:	c1 f8 1f             	sar    $0x1f,%eax
801025b6:	29 c2                	sub    %eax,%edx
801025b8:	89 d0                	mov    %edx,%eax
801025ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
    }while(shifter);
801025bd:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801025c1:	75 db                	jne    8010259e <itoa+0x3f>
    *p = '\0';
801025c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025c6:	c6 00 00             	movb   $0x0,(%eax)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
801025c9:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801025cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
801025d0:	ba 67 66 66 66       	mov    $0x66666667,%edx
801025d5:	89 c8                	mov    %ecx,%eax
801025d7:	f7 ea                	imul   %edx
801025d9:	c1 fa 02             	sar    $0x2,%edx
801025dc:	89 c8                	mov    %ecx,%eax
801025de:	c1 f8 1f             	sar    $0x1f,%eax
801025e1:	29 c2                	sub    %eax,%edx
801025e3:	89 d0                	mov    %edx,%eax
801025e5:	c1 e0 02             	shl    $0x2,%eax
801025e8:	01 d0                	add    %edx,%eax
801025ea:	01 c0                	add    %eax,%eax
801025ec:	29 c1                	sub    %eax,%ecx
801025ee:	89 ca                	mov    %ecx,%edx
801025f0:	0f b6 54 15 ed       	movzbl -0x13(%ebp,%edx,1),%edx
801025f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025f8:	88 10                	mov    %dl,(%eax)
        i = i/10;
801025fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
801025fd:	ba 67 66 66 66       	mov    $0x66666667,%edx
80102602:	89 c8                	mov    %ecx,%eax
80102604:	f7 ea                	imul   %edx
80102606:	c1 fa 02             	sar    $0x2,%edx
80102609:	89 c8                	mov    %ecx,%eax
8010260b:	c1 f8 1f             	sar    $0x1f,%eax
8010260e:	29 c2                	sub    %eax,%edx
80102610:	89 d0                	mov    %edx,%eax
80102612:	89 45 08             	mov    %eax,0x8(%ebp)
    }while(i);
80102615:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102619:	75 ae                	jne    801025c9 <itoa+0x6a>
    return b;
8010261b:	8b 45 0c             	mov    0xc(%ebp),%eax
}
8010261e:	c9                   	leave  
8010261f:	c3                   	ret    

80102620 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
80102620:	55                   	push   %ebp
80102621:	89 e5                	mov    %esp,%ebp
80102623:	83 ec 48             	sub    $0x48,%esp
	//path of proccess
	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102626:	83 ec 04             	sub    $0x4,%esp
80102629:	6a 06                	push   $0x6
8010262b:	68 ae 8f 10 80       	push   $0x80108fae
80102630:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102633:	50                   	push   %eax
80102634:	e8 21 31 00 00       	call   8010575a <memmove>
80102639:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
8010263c:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010263f:	83 c0 06             	add    $0x6,%eax
80102642:	8b 55 08             	mov    0x8(%ebp),%edx
80102645:	8b 52 10             	mov    0x10(%edx),%edx
80102648:	83 ec 08             	sub    $0x8,%esp
8010264b:	50                   	push   %eax
8010264c:	52                   	push   %edx
8010264d:	e8 0d ff ff ff       	call   8010255f <itoa>
80102652:	83 c4 10             	add    $0x10,%esp
	struct inode *ip, *dp;
	struct dirent de;
	char name[DIRSIZ];
	uint off;

	if(0 == p->swapFile)
80102655:	8b 45 08             	mov    0x8(%ebp),%eax
80102658:	8b 40 7c             	mov    0x7c(%eax),%eax
8010265b:	85 c0                	test   %eax,%eax
8010265d:	75 0a                	jne    80102669 <removeSwapFile+0x49>
	{
		return -1;
8010265f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102664:	e9 ce 01 00 00       	jmp    80102837 <removeSwapFile+0x217>
	}
	fileclose(p->swapFile);
80102669:	8b 45 08             	mov    0x8(%ebp),%eax
8010266c:	8b 40 7c             	mov    0x7c(%eax),%eax
8010266f:	83 ec 0c             	sub    $0xc,%esp
80102672:	50                   	push   %eax
80102673:	e8 d9 e9 ff ff       	call   80101051 <fileclose>
80102678:	83 c4 10             	add    $0x10,%esp

	begin_op();
8010267b:	e8 c7 12 00 00       	call   80103947 <begin_op>
	if((dp = nameiparent(path, name)) == 0)
80102680:	83 ec 08             	sub    $0x8,%esp
80102683:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80102686:	50                   	push   %eax
80102687:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010268a:	50                   	push   %eax
8010268b:	e8 b4 fe ff ff       	call   80102544 <nameiparent>
80102690:	83 c4 10             	add    $0x10,%esp
80102693:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102696:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010269a:	75 0f                	jne    801026ab <removeSwapFile+0x8b>
	{
		end_op();
8010269c:	e8 32 13 00 00       	call   801039d3 <end_op>
		return -1;
801026a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026a6:	e9 8c 01 00 00       	jmp    80102837 <removeSwapFile+0x217>
	}

	ilock(dp);
801026ab:	83 ec 0c             	sub    $0xc,%esp
801026ae:	ff 75 f4             	pushl  -0xc(%ebp)
801026b1:	e8 b4 f2 ff ff       	call   8010196a <ilock>
801026b6:	83 c4 10             	add    $0x10,%esp

	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801026b9:	83 ec 08             	sub    $0x8,%esp
801026bc:	68 b5 8f 10 80       	push   $0x80108fb5
801026c1:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801026c4:	50                   	push   %eax
801026c5:	e8 ed fa ff ff       	call   801021b7 <namecmp>
801026ca:	83 c4 10             	add    $0x10,%esp
801026cd:	85 c0                	test   %eax,%eax
801026cf:	0f 84 4a 01 00 00    	je     8010281f <removeSwapFile+0x1ff>
801026d5:	83 ec 08             	sub    $0x8,%esp
801026d8:	68 b7 8f 10 80       	push   $0x80108fb7
801026dd:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801026e0:	50                   	push   %eax
801026e1:	e8 d1 fa ff ff       	call   801021b7 <namecmp>
801026e6:	83 c4 10             	add    $0x10,%esp
801026e9:	85 c0                	test   %eax,%eax
801026eb:	0f 84 2e 01 00 00    	je     8010281f <removeSwapFile+0x1ff>
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
801026f1:	83 ec 04             	sub    $0x4,%esp
801026f4:	8d 45 c0             	lea    -0x40(%ebp),%eax
801026f7:	50                   	push   %eax
801026f8:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801026fb:	50                   	push   %eax
801026fc:	ff 75 f4             	pushl  -0xc(%ebp)
801026ff:	e8 ce fa ff ff       	call   801021d2 <dirlookup>
80102704:	83 c4 10             	add    $0x10,%esp
80102707:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010270a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010270e:	0f 84 0a 01 00 00    	je     8010281e <removeSwapFile+0x1fe>
		goto bad;
	ilock(ip);
80102714:	83 ec 0c             	sub    $0xc,%esp
80102717:	ff 75 f0             	pushl  -0x10(%ebp)
8010271a:	e8 4b f2 ff ff       	call   8010196a <ilock>
8010271f:	83 c4 10             	add    $0x10,%esp

	if(ip->nlink < 1)
80102722:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102725:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102729:	66 85 c0             	test   %ax,%ax
8010272c:	7f 0d                	jg     8010273b <removeSwapFile+0x11b>
		panic("unlink: nlink < 1");
8010272e:	83 ec 0c             	sub    $0xc,%esp
80102731:	68 ba 8f 10 80       	push   $0x80108fba
80102736:	e8 2b de ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR && !isdirempty(ip)){
8010273b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010273e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102742:	66 83 f8 01          	cmp    $0x1,%ax
80102746:	75 25                	jne    8010276d <removeSwapFile+0x14d>
80102748:	83 ec 0c             	sub    $0xc,%esp
8010274b:	ff 75 f0             	pushl  -0x10(%ebp)
8010274e:	e8 db 37 00 00       	call   80105f2e <isdirempty>
80102753:	83 c4 10             	add    $0x10,%esp
80102756:	85 c0                	test   %eax,%eax
80102758:	75 13                	jne    8010276d <removeSwapFile+0x14d>
		iunlockput(ip);
8010275a:	83 ec 0c             	sub    $0xc,%esp
8010275d:	ff 75 f0             	pushl  -0x10(%ebp)
80102760:	e8 c5 f4 ff ff       	call   80101c2a <iunlockput>
80102765:	83 c4 10             	add    $0x10,%esp
		goto bad;
80102768:	e9 b2 00 00 00       	jmp    8010281f <removeSwapFile+0x1ff>
	}

	memset(&de, 0, sizeof(de));
8010276d:	83 ec 04             	sub    $0x4,%esp
80102770:	6a 10                	push   $0x10
80102772:	6a 00                	push   $0x0
80102774:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102777:	50                   	push   %eax
80102778:	e8 1e 2f 00 00       	call   8010569b <memset>
8010277d:	83 c4 10             	add    $0x10,%esp
	if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102780:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102783:	6a 10                	push   $0x10
80102785:	50                   	push   %eax
80102786:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102789:	50                   	push   %eax
8010278a:	ff 75 f4             	pushl  -0xc(%ebp)
8010278d:	e8 9d f8 ff ff       	call   8010202f <writei>
80102792:	83 c4 10             	add    $0x10,%esp
80102795:	83 f8 10             	cmp    $0x10,%eax
80102798:	74 0d                	je     801027a7 <removeSwapFile+0x187>
		panic("unlink: writei");
8010279a:	83 ec 0c             	sub    $0xc,%esp
8010279d:	68 cc 8f 10 80       	push   $0x80108fcc
801027a2:	e8 bf dd ff ff       	call   80100566 <panic>
	if(ip->type == T_DIR){
801027a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027aa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801027ae:	66 83 f8 01          	cmp    $0x1,%ax
801027b2:	75 21                	jne    801027d5 <removeSwapFile+0x1b5>
		dp->nlink--;
801027b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801027bb:	83 e8 01             	sub    $0x1,%eax
801027be:	89 c2                	mov    %eax,%edx
801027c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c3:	66 89 50 16          	mov    %dx,0x16(%eax)
		iupdate(dp);
801027c7:	83 ec 0c             	sub    $0xc,%esp
801027ca:	ff 75 f4             	pushl  -0xc(%ebp)
801027cd:	e8 be ef ff ff       	call   80101790 <iupdate>
801027d2:	83 c4 10             	add    $0x10,%esp
	}
	iunlockput(dp);
801027d5:	83 ec 0c             	sub    $0xc,%esp
801027d8:	ff 75 f4             	pushl  -0xc(%ebp)
801027db:	e8 4a f4 ff ff       	call   80101c2a <iunlockput>
801027e0:	83 c4 10             	add    $0x10,%esp

	ip->nlink--;
801027e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027e6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801027ea:	83 e8 01             	sub    $0x1,%eax
801027ed:	89 c2                	mov    %eax,%edx
801027ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027f2:	66 89 50 16          	mov    %dx,0x16(%eax)
	iupdate(ip);
801027f6:	83 ec 0c             	sub    $0xc,%esp
801027f9:	ff 75 f0             	pushl  -0x10(%ebp)
801027fc:	e8 8f ef ff ff       	call   80101790 <iupdate>
80102801:	83 c4 10             	add    $0x10,%esp
	iunlockput(ip);
80102804:	83 ec 0c             	sub    $0xc,%esp
80102807:	ff 75 f0             	pushl  -0x10(%ebp)
8010280a:	e8 1b f4 ff ff       	call   80101c2a <iunlockput>
8010280f:	83 c4 10             	add    $0x10,%esp

	end_op();
80102812:	e8 bc 11 00 00       	call   801039d3 <end_op>

	return 0;
80102817:	b8 00 00 00 00       	mov    $0x0,%eax
8010281c:	eb 19                	jmp    80102837 <removeSwapFile+0x217>
	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
		goto bad;
8010281e:	90                   	nop
	end_op();

	return 0;

	bad:
		iunlockput(dp);
8010281f:	83 ec 0c             	sub    $0xc,%esp
80102822:	ff 75 f4             	pushl  -0xc(%ebp)
80102825:	e8 00 f4 ff ff       	call   80101c2a <iunlockput>
8010282a:	83 c4 10             	add    $0x10,%esp
		end_op();
8010282d:	e8 a1 11 00 00       	call   801039d3 <end_op>
		return -1;
80102832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
80102837:	c9                   	leave  
80102838:	c3                   	ret    

80102839 <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
80102839:	55                   	push   %ebp
8010283a:	89 e5                	mov    %esp,%ebp
8010283c:	83 ec 28             	sub    $0x28,%esp

	char path[DIGITS];
	memmove(path,"/.swap", 6);
8010283f:	83 ec 04             	sub    $0x4,%esp
80102842:	6a 06                	push   $0x6
80102844:	68 ae 8f 10 80       	push   $0x80108fae
80102849:	8d 45 e6             	lea    -0x1a(%ebp),%eax
8010284c:	50                   	push   %eax
8010284d:	e8 08 2f 00 00       	call   8010575a <memmove>
80102852:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
80102855:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102858:	83 c0 06             	add    $0x6,%eax
8010285b:	8b 55 08             	mov    0x8(%ebp),%edx
8010285e:	8b 52 10             	mov    0x10(%edx),%edx
80102861:	83 ec 08             	sub    $0x8,%esp
80102864:	50                   	push   %eax
80102865:	52                   	push   %edx
80102866:	e8 f4 fc ff ff       	call   8010255f <itoa>
8010286b:	83 c4 10             	add    $0x10,%esp

    begin_op();
8010286e:	e8 d4 10 00 00       	call   80103947 <begin_op>
    struct inode * in = create(path, T_FILE, 0, 0);
80102873:	6a 00                	push   $0x0
80102875:	6a 00                	push   $0x0
80102877:	6a 02                	push   $0x2
80102879:	8d 45 e6             	lea    -0x1a(%ebp),%eax
8010287c:	50                   	push   %eax
8010287d:	e8 f2 38 00 00       	call   80106174 <create>
80102882:	83 c4 10             	add    $0x10,%esp
80102885:	89 45 f4             	mov    %eax,-0xc(%ebp)
	iunlock(in);
80102888:	83 ec 0c             	sub    $0xc,%esp
8010288b:	ff 75 f4             	pushl  -0xc(%ebp)
8010288e:	e8 35 f2 ff ff       	call   80101ac8 <iunlock>
80102893:	83 c4 10             	add    $0x10,%esp

	p->swapFile = filealloc();
80102896:	e8 f8 e6 ff ff       	call   80100f93 <filealloc>
8010289b:	89 c2                	mov    %eax,%edx
8010289d:	8b 45 08             	mov    0x8(%ebp),%eax
801028a0:	89 50 7c             	mov    %edx,0x7c(%eax)
	if (p->swapFile == 0)
801028a3:	8b 45 08             	mov    0x8(%ebp),%eax
801028a6:	8b 40 7c             	mov    0x7c(%eax),%eax
801028a9:	85 c0                	test   %eax,%eax
801028ab:	75 0d                	jne    801028ba <createSwapFile+0x81>
		panic("no slot for files on /store");
801028ad:	83 ec 0c             	sub    $0xc,%esp
801028b0:	68 db 8f 10 80       	push   $0x80108fdb
801028b5:	e8 ac dc ff ff       	call   80100566 <panic>

	p->swapFile->ip = in;
801028ba:	8b 45 08             	mov    0x8(%ebp),%eax
801028bd:	8b 40 7c             	mov    0x7c(%eax),%eax
801028c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801028c3:	89 50 10             	mov    %edx,0x10(%eax)
	p->swapFile->type = FD_INODE;
801028c6:	8b 45 08             	mov    0x8(%ebp),%eax
801028c9:	8b 40 7c             	mov    0x7c(%eax),%eax
801028cc:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
	p->swapFile->off = 0;
801028d2:	8b 45 08             	mov    0x8(%ebp),%eax
801028d5:	8b 40 7c             	mov    0x7c(%eax),%eax
801028d8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	p->swapFile->readable = O_WRONLY;
801028df:	8b 45 08             	mov    0x8(%ebp),%eax
801028e2:	8b 40 7c             	mov    0x7c(%eax),%eax
801028e5:	c6 40 08 01          	movb   $0x1,0x8(%eax)
	p->swapFile->writable = O_RDWR;
801028e9:	8b 45 08             	mov    0x8(%ebp),%eax
801028ec:	8b 40 7c             	mov    0x7c(%eax),%eax
801028ef:	c6 40 09 02          	movb   $0x2,0x9(%eax)
    end_op();
801028f3:	e8 db 10 00 00       	call   801039d3 <end_op>

    return 0;
801028f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801028fd:	c9                   	leave  
801028fe:	c3                   	ret    

801028ff <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
801028ff:	55                   	push   %ebp
80102900:	89 e5                	mov    %esp,%ebp
80102902:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102905:	8b 45 08             	mov    0x8(%ebp),%eax
80102908:	8b 40 7c             	mov    0x7c(%eax),%eax
8010290b:	8b 55 10             	mov    0x10(%ebp),%edx
8010290e:	89 50 14             	mov    %edx,0x14(%eax)

	return filewrite(p->swapFile, buffer, size);
80102911:	8b 55 14             	mov    0x14(%ebp),%edx
80102914:	8b 45 08             	mov    0x8(%ebp),%eax
80102917:	8b 40 7c             	mov    0x7c(%eax),%eax
8010291a:	83 ec 04             	sub    $0x4,%esp
8010291d:	52                   	push   %edx
8010291e:	ff 75 0c             	pushl  0xc(%ebp)
80102921:	50                   	push   %eax
80102922:	e8 21 e9 ff ff       	call   80101248 <filewrite>
80102927:	83 c4 10             	add    $0x10,%esp

}
8010292a:	c9                   	leave  
8010292b:	c3                   	ret    

8010292c <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
8010292c:	55                   	push   %ebp
8010292d:	89 e5                	mov    %esp,%ebp
8010292f:	83 ec 08             	sub    $0x8,%esp
	p->swapFile->off = placeOnFile;
80102932:	8b 45 08             	mov    0x8(%ebp),%eax
80102935:	8b 40 7c             	mov    0x7c(%eax),%eax
80102938:	8b 55 10             	mov    0x10(%ebp),%edx
8010293b:	89 50 14             	mov    %edx,0x14(%eax)

	return fileread(p->swapFile, buffer,  size);
8010293e:	8b 55 14             	mov    0x14(%ebp),%edx
80102941:	8b 45 08             	mov    0x8(%ebp),%eax
80102944:	8b 40 7c             	mov    0x7c(%eax),%eax
80102947:	83 ec 04             	sub    $0x4,%esp
8010294a:	52                   	push   %edx
8010294b:	ff 75 0c             	pushl  0xc(%ebp)
8010294e:	50                   	push   %eax
8010294f:	e8 3c e8 ff ff       	call   80101190 <fileread>
80102954:	83 c4 10             	add    $0x10,%esp
}
80102957:	c9                   	leave  
80102958:	c3                   	ret    

80102959 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102959:	55                   	push   %ebp
8010295a:	89 e5                	mov    %esp,%ebp
8010295c:	83 ec 14             	sub    $0x14,%esp
8010295f:	8b 45 08             	mov    0x8(%ebp),%eax
80102962:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102966:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010296a:	89 c2                	mov    %eax,%edx
8010296c:	ec                   	in     (%dx),%al
8010296d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102970:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102974:	c9                   	leave  
80102975:	c3                   	ret    

80102976 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102976:	55                   	push   %ebp
80102977:	89 e5                	mov    %esp,%ebp
80102979:	57                   	push   %edi
8010297a:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010297b:	8b 55 08             	mov    0x8(%ebp),%edx
8010297e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102981:	8b 45 10             	mov    0x10(%ebp),%eax
80102984:	89 cb                	mov    %ecx,%ebx
80102986:	89 df                	mov    %ebx,%edi
80102988:	89 c1                	mov    %eax,%ecx
8010298a:	fc                   	cld    
8010298b:	f3 6d                	rep insl (%dx),%es:(%edi)
8010298d:	89 c8                	mov    %ecx,%eax
8010298f:	89 fb                	mov    %edi,%ebx
80102991:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102994:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102997:	90                   	nop
80102998:	5b                   	pop    %ebx
80102999:	5f                   	pop    %edi
8010299a:	5d                   	pop    %ebp
8010299b:	c3                   	ret    

8010299c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010299c:	55                   	push   %ebp
8010299d:	89 e5                	mov    %esp,%ebp
8010299f:	83 ec 08             	sub    $0x8,%esp
801029a2:	8b 55 08             	mov    0x8(%ebp),%edx
801029a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801029a8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801029ac:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029af:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b7:	ee                   	out    %al,(%dx)
}
801029b8:	90                   	nop
801029b9:	c9                   	leave  
801029ba:	c3                   	ret    

801029bb <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801029bb:	55                   	push   %ebp
801029bc:	89 e5                	mov    %esp,%ebp
801029be:	56                   	push   %esi
801029bf:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801029c0:	8b 55 08             	mov    0x8(%ebp),%edx
801029c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801029c6:	8b 45 10             	mov    0x10(%ebp),%eax
801029c9:	89 cb                	mov    %ecx,%ebx
801029cb:	89 de                	mov    %ebx,%esi
801029cd:	89 c1                	mov    %eax,%ecx
801029cf:	fc                   	cld    
801029d0:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801029d2:	89 c8                	mov    %ecx,%eax
801029d4:	89 f3                	mov    %esi,%ebx
801029d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801029d9:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801029dc:	90                   	nop
801029dd:	5b                   	pop    %ebx
801029de:	5e                   	pop    %esi
801029df:	5d                   	pop    %ebp
801029e0:	c3                   	ret    

801029e1 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801029e1:	55                   	push   %ebp
801029e2:	89 e5                	mov    %esp,%ebp
801029e4:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801029e7:	90                   	nop
801029e8:	68 f7 01 00 00       	push   $0x1f7
801029ed:	e8 67 ff ff ff       	call   80102959 <inb>
801029f2:	83 c4 04             	add    $0x4,%esp
801029f5:	0f b6 c0             	movzbl %al,%eax
801029f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801029fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029fe:	25 c0 00 00 00       	and    $0xc0,%eax
80102a03:	83 f8 40             	cmp    $0x40,%eax
80102a06:	75 e0                	jne    801029e8 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102a08:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102a0c:	74 11                	je     80102a1f <idewait+0x3e>
80102a0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a11:	83 e0 21             	and    $0x21,%eax
80102a14:	85 c0                	test   %eax,%eax
80102a16:	74 07                	je     80102a1f <idewait+0x3e>
    return -1;
80102a18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102a1d:	eb 05                	jmp    80102a24 <idewait+0x43>
  return 0;
80102a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102a24:	c9                   	leave  
80102a25:	c3                   	ret    

80102a26 <ideinit>:

void
ideinit(void)
{
80102a26:	55                   	push   %ebp
80102a27:	89 e5                	mov    %esp,%ebp
80102a29:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102a2c:	83 ec 08             	sub    $0x8,%esp
80102a2f:	68 f7 8f 10 80       	push   $0x80108ff7
80102a34:	68 00 c6 10 80       	push   $0x8010c600
80102a39:	e8 d8 29 00 00       	call   80105416 <initlock>
80102a3e:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102a41:	83 ec 0c             	sub    $0xc,%esp
80102a44:	6a 0e                	push   $0xe
80102a46:	e8 da 18 00 00       	call   80104325 <picenable>
80102a4b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102a4e:	a1 40 39 11 80       	mov    0x80113940,%eax
80102a53:	83 e8 01             	sub    $0x1,%eax
80102a56:	83 ec 08             	sub    $0x8,%esp
80102a59:	50                   	push   %eax
80102a5a:	6a 0e                	push   $0xe
80102a5c:	e8 73 04 00 00       	call   80102ed4 <ioapicenable>
80102a61:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102a64:	83 ec 0c             	sub    $0xc,%esp
80102a67:	6a 00                	push   $0x0
80102a69:	e8 73 ff ff ff       	call   801029e1 <idewait>
80102a6e:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102a71:	83 ec 08             	sub    $0x8,%esp
80102a74:	68 f0 00 00 00       	push   $0xf0
80102a79:	68 f6 01 00 00       	push   $0x1f6
80102a7e:	e8 19 ff ff ff       	call   8010299c <outb>
80102a83:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102a86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a8d:	eb 24                	jmp    80102ab3 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102a8f:	83 ec 0c             	sub    $0xc,%esp
80102a92:	68 f7 01 00 00       	push   $0x1f7
80102a97:	e8 bd fe ff ff       	call   80102959 <inb>
80102a9c:	83 c4 10             	add    $0x10,%esp
80102a9f:	84 c0                	test   %al,%al
80102aa1:	74 0c                	je     80102aaf <ideinit+0x89>
      havedisk1 = 1;
80102aa3:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102aaa:	00 00 00 
      break;
80102aad:	eb 0d                	jmp    80102abc <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102aaf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ab3:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102aba:	7e d3                	jle    80102a8f <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102abc:	83 ec 08             	sub    $0x8,%esp
80102abf:	68 e0 00 00 00       	push   $0xe0
80102ac4:	68 f6 01 00 00       	push   $0x1f6
80102ac9:	e8 ce fe ff ff       	call   8010299c <outb>
80102ace:	83 c4 10             	add    $0x10,%esp
}
80102ad1:	90                   	nop
80102ad2:	c9                   	leave  
80102ad3:	c3                   	ret    

80102ad4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102ad4:	55                   	push   %ebp
80102ad5:	89 e5                	mov    %esp,%ebp
80102ad7:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102ada:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102ade:	75 0d                	jne    80102aed <idestart+0x19>
    panic("idestart");
80102ae0:	83 ec 0c             	sub    $0xc,%esp
80102ae3:	68 fb 8f 10 80       	push   $0x80108ffb
80102ae8:	e8 79 da ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102aed:	8b 45 08             	mov    0x8(%ebp),%eax
80102af0:	8b 40 08             	mov    0x8(%eax),%eax
80102af3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102af8:	76 0d                	jbe    80102b07 <idestart+0x33>
    panic("incorrect blockno");
80102afa:	83 ec 0c             	sub    $0xc,%esp
80102afd:	68 04 90 10 80       	push   $0x80109004
80102b02:	e8 5f da ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102b07:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b11:	8b 50 08             	mov    0x8(%eax),%edx
80102b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b17:	0f af c2             	imul   %edx,%eax
80102b1a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102b1d:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102b21:	7e 0d                	jle    80102b30 <idestart+0x5c>
80102b23:	83 ec 0c             	sub    $0xc,%esp
80102b26:	68 fb 8f 10 80       	push   $0x80108ffb
80102b2b:	e8 36 da ff ff       	call   80100566 <panic>
  
  idewait(0);
80102b30:	83 ec 0c             	sub    $0xc,%esp
80102b33:	6a 00                	push   $0x0
80102b35:	e8 a7 fe ff ff       	call   801029e1 <idewait>
80102b3a:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102b3d:	83 ec 08             	sub    $0x8,%esp
80102b40:	6a 00                	push   $0x0
80102b42:	68 f6 03 00 00       	push   $0x3f6
80102b47:	e8 50 fe ff ff       	call   8010299c <outb>
80102b4c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b52:	0f b6 c0             	movzbl %al,%eax
80102b55:	83 ec 08             	sub    $0x8,%esp
80102b58:	50                   	push   %eax
80102b59:	68 f2 01 00 00       	push   $0x1f2
80102b5e:	e8 39 fe ff ff       	call   8010299c <outb>
80102b63:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b69:	0f b6 c0             	movzbl %al,%eax
80102b6c:	83 ec 08             	sub    $0x8,%esp
80102b6f:	50                   	push   %eax
80102b70:	68 f3 01 00 00       	push   $0x1f3
80102b75:	e8 22 fe ff ff       	call   8010299c <outb>
80102b7a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b80:	c1 f8 08             	sar    $0x8,%eax
80102b83:	0f b6 c0             	movzbl %al,%eax
80102b86:	83 ec 08             	sub    $0x8,%esp
80102b89:	50                   	push   %eax
80102b8a:	68 f4 01 00 00       	push   $0x1f4
80102b8f:	e8 08 fe ff ff       	call   8010299c <outb>
80102b94:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b9a:	c1 f8 10             	sar    $0x10,%eax
80102b9d:	0f b6 c0             	movzbl %al,%eax
80102ba0:	83 ec 08             	sub    $0x8,%esp
80102ba3:	50                   	push   %eax
80102ba4:	68 f5 01 00 00       	push   $0x1f5
80102ba9:	e8 ee fd ff ff       	call   8010299c <outb>
80102bae:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb4:	8b 40 04             	mov    0x4(%eax),%eax
80102bb7:	83 e0 01             	and    $0x1,%eax
80102bba:	c1 e0 04             	shl    $0x4,%eax
80102bbd:	89 c2                	mov    %eax,%edx
80102bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102bc2:	c1 f8 18             	sar    $0x18,%eax
80102bc5:	83 e0 0f             	and    $0xf,%eax
80102bc8:	09 d0                	or     %edx,%eax
80102bca:	83 c8 e0             	or     $0xffffffe0,%eax
80102bcd:	0f b6 c0             	movzbl %al,%eax
80102bd0:	83 ec 08             	sub    $0x8,%esp
80102bd3:	50                   	push   %eax
80102bd4:	68 f6 01 00 00       	push   $0x1f6
80102bd9:	e8 be fd ff ff       	call   8010299c <outb>
80102bde:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102be1:	8b 45 08             	mov    0x8(%ebp),%eax
80102be4:	8b 00                	mov    (%eax),%eax
80102be6:	83 e0 04             	and    $0x4,%eax
80102be9:	85 c0                	test   %eax,%eax
80102beb:	74 30                	je     80102c1d <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102bed:	83 ec 08             	sub    $0x8,%esp
80102bf0:	6a 30                	push   $0x30
80102bf2:	68 f7 01 00 00       	push   $0x1f7
80102bf7:	e8 a0 fd ff ff       	call   8010299c <outb>
80102bfc:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102bff:	8b 45 08             	mov    0x8(%ebp),%eax
80102c02:	83 c0 18             	add    $0x18,%eax
80102c05:	83 ec 04             	sub    $0x4,%esp
80102c08:	68 80 00 00 00       	push   $0x80
80102c0d:	50                   	push   %eax
80102c0e:	68 f0 01 00 00       	push   $0x1f0
80102c13:	e8 a3 fd ff ff       	call   801029bb <outsl>
80102c18:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102c1b:	eb 12                	jmp    80102c2f <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102c1d:	83 ec 08             	sub    $0x8,%esp
80102c20:	6a 20                	push   $0x20
80102c22:	68 f7 01 00 00       	push   $0x1f7
80102c27:	e8 70 fd ff ff       	call   8010299c <outb>
80102c2c:	83 c4 10             	add    $0x10,%esp
  }
}
80102c2f:	90                   	nop
80102c30:	c9                   	leave  
80102c31:	c3                   	ret    

80102c32 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102c32:	55                   	push   %ebp
80102c33:	89 e5                	mov    %esp,%ebp
80102c35:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102c38:	83 ec 0c             	sub    $0xc,%esp
80102c3b:	68 00 c6 10 80       	push   $0x8010c600
80102c40:	e8 f3 27 00 00       	call   80105438 <acquire>
80102c45:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102c48:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102c4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102c50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c54:	75 15                	jne    80102c6b <ideintr+0x39>
    release(&idelock);
80102c56:	83 ec 0c             	sub    $0xc,%esp
80102c59:	68 00 c6 10 80       	push   $0x8010c600
80102c5e:	e8 3c 28 00 00       	call   8010549f <release>
80102c63:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102c66:	e9 9a 00 00 00       	jmp    80102d05 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c6e:	8b 40 14             	mov    0x14(%eax),%eax
80102c71:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c79:	8b 00                	mov    (%eax),%eax
80102c7b:	83 e0 04             	and    $0x4,%eax
80102c7e:	85 c0                	test   %eax,%eax
80102c80:	75 2d                	jne    80102caf <ideintr+0x7d>
80102c82:	83 ec 0c             	sub    $0xc,%esp
80102c85:	6a 01                	push   $0x1
80102c87:	e8 55 fd ff ff       	call   801029e1 <idewait>
80102c8c:	83 c4 10             	add    $0x10,%esp
80102c8f:	85 c0                	test   %eax,%eax
80102c91:	78 1c                	js     80102caf <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c96:	83 c0 18             	add    $0x18,%eax
80102c99:	83 ec 04             	sub    $0x4,%esp
80102c9c:	68 80 00 00 00       	push   $0x80
80102ca1:	50                   	push   %eax
80102ca2:	68 f0 01 00 00       	push   $0x1f0
80102ca7:	e8 ca fc ff ff       	call   80102976 <insl>
80102cac:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb2:	8b 00                	mov    (%eax),%eax
80102cb4:	83 c8 02             	or     $0x2,%eax
80102cb7:	89 c2                	mov    %eax,%edx
80102cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cbc:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc1:	8b 00                	mov    (%eax),%eax
80102cc3:	83 e0 fb             	and    $0xfffffffb,%eax
80102cc6:	89 c2                	mov    %eax,%edx
80102cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccb:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ccd:	83 ec 0c             	sub    $0xc,%esp
80102cd0:	ff 75 f4             	pushl  -0xc(%ebp)
80102cd3:	e8 4c 25 00 00       	call   80105224 <wakeup>
80102cd8:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102cdb:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102ce0:	85 c0                	test   %eax,%eax
80102ce2:	74 11                	je     80102cf5 <ideintr+0xc3>
    idestart(idequeue);
80102ce4:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102ce9:	83 ec 0c             	sub    $0xc,%esp
80102cec:	50                   	push   %eax
80102ced:	e8 e2 fd ff ff       	call   80102ad4 <idestart>
80102cf2:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102cf5:	83 ec 0c             	sub    $0xc,%esp
80102cf8:	68 00 c6 10 80       	push   $0x8010c600
80102cfd:	e8 9d 27 00 00       	call   8010549f <release>
80102d02:	83 c4 10             	add    $0x10,%esp
}
80102d05:	c9                   	leave  
80102d06:	c3                   	ret    

80102d07 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102d07:	55                   	push   %ebp
80102d08:	89 e5                	mov    %esp,%ebp
80102d0a:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102d0d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d10:	8b 00                	mov    (%eax),%eax
80102d12:	83 e0 01             	and    $0x1,%eax
80102d15:	85 c0                	test   %eax,%eax
80102d17:	75 0d                	jne    80102d26 <iderw+0x1f>
    panic("iderw: buf not busy");
80102d19:	83 ec 0c             	sub    $0xc,%esp
80102d1c:	68 16 90 10 80       	push   $0x80109016
80102d21:	e8 40 d8 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102d26:	8b 45 08             	mov    0x8(%ebp),%eax
80102d29:	8b 00                	mov    (%eax),%eax
80102d2b:	83 e0 06             	and    $0x6,%eax
80102d2e:	83 f8 02             	cmp    $0x2,%eax
80102d31:	75 0d                	jne    80102d40 <iderw+0x39>
    panic("iderw: nothing to do");
80102d33:	83 ec 0c             	sub    $0xc,%esp
80102d36:	68 2a 90 10 80       	push   $0x8010902a
80102d3b:	e8 26 d8 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102d40:	8b 45 08             	mov    0x8(%ebp),%eax
80102d43:	8b 40 04             	mov    0x4(%eax),%eax
80102d46:	85 c0                	test   %eax,%eax
80102d48:	74 16                	je     80102d60 <iderw+0x59>
80102d4a:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102d4f:	85 c0                	test   %eax,%eax
80102d51:	75 0d                	jne    80102d60 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102d53:	83 ec 0c             	sub    $0xc,%esp
80102d56:	68 3f 90 10 80       	push   $0x8010903f
80102d5b:	e8 06 d8 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102d60:	83 ec 0c             	sub    $0xc,%esp
80102d63:	68 00 c6 10 80       	push   $0x8010c600
80102d68:	e8 cb 26 00 00       	call   80105438 <acquire>
80102d6d:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102d70:	8b 45 08             	mov    0x8(%ebp),%eax
80102d73:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102d7a:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102d81:	eb 0b                	jmp    80102d8e <iderw+0x87>
80102d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d86:	8b 00                	mov    (%eax),%eax
80102d88:	83 c0 14             	add    $0x14,%eax
80102d8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d91:	8b 00                	mov    (%eax),%eax
80102d93:	85 c0                	test   %eax,%eax
80102d95:	75 ec                	jne    80102d83 <iderw+0x7c>
    ;
  *pp = b;
80102d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d9a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9d:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102d9f:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102da4:	3b 45 08             	cmp    0x8(%ebp),%eax
80102da7:	75 23                	jne    80102dcc <iderw+0xc5>
    idestart(b);
80102da9:	83 ec 0c             	sub    $0xc,%esp
80102dac:	ff 75 08             	pushl  0x8(%ebp)
80102daf:	e8 20 fd ff ff       	call   80102ad4 <idestart>
80102db4:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102db7:	eb 13                	jmp    80102dcc <iderw+0xc5>
    sleep(b, &idelock);
80102db9:	83 ec 08             	sub    $0x8,%esp
80102dbc:	68 00 c6 10 80       	push   $0x8010c600
80102dc1:	ff 75 08             	pushl  0x8(%ebp)
80102dc4:	e8 6d 23 00 00       	call   80105136 <sleep>
80102dc9:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80102dcf:	8b 00                	mov    (%eax),%eax
80102dd1:	83 e0 06             	and    $0x6,%eax
80102dd4:	83 f8 02             	cmp    $0x2,%eax
80102dd7:	75 e0                	jne    80102db9 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102dd9:	83 ec 0c             	sub    $0xc,%esp
80102ddc:	68 00 c6 10 80       	push   $0x8010c600
80102de1:	e8 b9 26 00 00       	call   8010549f <release>
80102de6:	83 c4 10             	add    $0x10,%esp
}
80102de9:	90                   	nop
80102dea:	c9                   	leave  
80102deb:	c3                   	ret    

80102dec <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102dec:	55                   	push   %ebp
80102ded:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102def:	a1 14 32 11 80       	mov    0x80113214,%eax
80102df4:	8b 55 08             	mov    0x8(%ebp),%edx
80102df7:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102df9:	a1 14 32 11 80       	mov    0x80113214,%eax
80102dfe:	8b 40 10             	mov    0x10(%eax),%eax
}
80102e01:	5d                   	pop    %ebp
80102e02:	c3                   	ret    

80102e03 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102e03:	55                   	push   %ebp
80102e04:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102e06:	a1 14 32 11 80       	mov    0x80113214,%eax
80102e0b:	8b 55 08             	mov    0x8(%ebp),%edx
80102e0e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102e10:	a1 14 32 11 80       	mov    0x80113214,%eax
80102e15:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e18:	89 50 10             	mov    %edx,0x10(%eax)
}
80102e1b:	90                   	nop
80102e1c:	5d                   	pop    %ebp
80102e1d:	c3                   	ret    

80102e1e <ioapicinit>:

void
ioapicinit(void)
{
80102e1e:	55                   	push   %ebp
80102e1f:	89 e5                	mov    %esp,%ebp
80102e21:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102e24:	a1 44 33 11 80       	mov    0x80113344,%eax
80102e29:	85 c0                	test   %eax,%eax
80102e2b:	0f 84 a0 00 00 00    	je     80102ed1 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102e31:	c7 05 14 32 11 80 00 	movl   $0xfec00000,0x80113214
80102e38:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102e3b:	6a 01                	push   $0x1
80102e3d:	e8 aa ff ff ff       	call   80102dec <ioapicread>
80102e42:	83 c4 04             	add    $0x4,%esp
80102e45:	c1 e8 10             	shr    $0x10,%eax
80102e48:	25 ff 00 00 00       	and    $0xff,%eax
80102e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102e50:	6a 00                	push   $0x0
80102e52:	e8 95 ff ff ff       	call   80102dec <ioapicread>
80102e57:	83 c4 04             	add    $0x4,%esp
80102e5a:	c1 e8 18             	shr    $0x18,%eax
80102e5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102e60:	0f b6 05 40 33 11 80 	movzbl 0x80113340,%eax
80102e67:	0f b6 c0             	movzbl %al,%eax
80102e6a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102e6d:	74 10                	je     80102e7f <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102e6f:	83 ec 0c             	sub    $0xc,%esp
80102e72:	68 60 90 10 80       	push   $0x80109060
80102e77:	e8 4a d5 ff ff       	call   801003c6 <cprintf>
80102e7c:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102e7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e86:	eb 3f                	jmp    80102ec7 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e8b:	83 c0 20             	add    $0x20,%eax
80102e8e:	0d 00 00 01 00       	or     $0x10000,%eax
80102e93:	89 c2                	mov    %eax,%edx
80102e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e98:	83 c0 08             	add    $0x8,%eax
80102e9b:	01 c0                	add    %eax,%eax
80102e9d:	83 ec 08             	sub    $0x8,%esp
80102ea0:	52                   	push   %edx
80102ea1:	50                   	push   %eax
80102ea2:	e8 5c ff ff ff       	call   80102e03 <ioapicwrite>
80102ea7:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ead:	83 c0 08             	add    $0x8,%eax
80102eb0:	01 c0                	add    %eax,%eax
80102eb2:	83 c0 01             	add    $0x1,%eax
80102eb5:	83 ec 08             	sub    $0x8,%esp
80102eb8:	6a 00                	push   $0x0
80102eba:	50                   	push   %eax
80102ebb:	e8 43 ff ff ff       	call   80102e03 <ioapicwrite>
80102ec0:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ec3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eca:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ecd:	7e b9                	jle    80102e88 <ioapicinit+0x6a>
80102ecf:	eb 01                	jmp    80102ed2 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102ed1:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ed2:	c9                   	leave  
80102ed3:	c3                   	ret    

80102ed4 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ed4:	55                   	push   %ebp
80102ed5:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102ed7:	a1 44 33 11 80       	mov    0x80113344,%eax
80102edc:	85 c0                	test   %eax,%eax
80102ede:	74 39                	je     80102f19 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ee3:	83 c0 20             	add    $0x20,%eax
80102ee6:	89 c2                	mov    %eax,%edx
80102ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80102eeb:	83 c0 08             	add    $0x8,%eax
80102eee:	01 c0                	add    %eax,%eax
80102ef0:	52                   	push   %edx
80102ef1:	50                   	push   %eax
80102ef2:	e8 0c ff ff ff       	call   80102e03 <ioapicwrite>
80102ef7:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102efa:	8b 45 0c             	mov    0xc(%ebp),%eax
80102efd:	c1 e0 18             	shl    $0x18,%eax
80102f00:	89 c2                	mov    %eax,%edx
80102f02:	8b 45 08             	mov    0x8(%ebp),%eax
80102f05:	83 c0 08             	add    $0x8,%eax
80102f08:	01 c0                	add    %eax,%eax
80102f0a:	83 c0 01             	add    $0x1,%eax
80102f0d:	52                   	push   %edx
80102f0e:	50                   	push   %eax
80102f0f:	e8 ef fe ff ff       	call   80102e03 <ioapicwrite>
80102f14:	83 c4 08             	add    $0x8,%esp
80102f17:	eb 01                	jmp    80102f1a <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102f19:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102f1a:	c9                   	leave  
80102f1b:	c3                   	ret    

80102f1c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102f1c:	55                   	push   %ebp
80102f1d:	89 e5                	mov    %esp,%ebp
80102f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f22:	05 00 00 00 80       	add    $0x80000000,%eax
80102f27:	5d                   	pop    %ebp
80102f28:	c3                   	ret    

80102f29 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102f29:	55                   	push   %ebp
80102f2a:	89 e5                	mov    %esp,%ebp
80102f2c:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102f2f:	83 ec 08             	sub    $0x8,%esp
80102f32:	68 92 90 10 80       	push   $0x80109092
80102f37:	68 20 32 11 80       	push   $0x80113220
80102f3c:	e8 d5 24 00 00       	call   80105416 <initlock>
80102f41:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102f44:	c7 05 54 32 11 80 00 	movl   $0x0,0x80113254
80102f4b:	00 00 00 
  freerange(vstart, vend);
80102f4e:	83 ec 08             	sub    $0x8,%esp
80102f51:	ff 75 0c             	pushl  0xc(%ebp)
80102f54:	ff 75 08             	pushl  0x8(%ebp)
80102f57:	e8 2a 00 00 00       	call   80102f86 <freerange>
80102f5c:	83 c4 10             	add    $0x10,%esp
}
80102f5f:	90                   	nop
80102f60:	c9                   	leave  
80102f61:	c3                   	ret    

80102f62 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102f62:	55                   	push   %ebp
80102f63:	89 e5                	mov    %esp,%ebp
80102f65:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102f68:	83 ec 08             	sub    $0x8,%esp
80102f6b:	ff 75 0c             	pushl  0xc(%ebp)
80102f6e:	ff 75 08             	pushl  0x8(%ebp)
80102f71:	e8 10 00 00 00       	call   80102f86 <freerange>
80102f76:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102f79:	c7 05 54 32 11 80 01 	movl   $0x1,0x80113254
80102f80:	00 00 00 
}
80102f83:	90                   	nop
80102f84:	c9                   	leave  
80102f85:	c3                   	ret    

80102f86 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102f86:	55                   	push   %ebp
80102f87:	89 e5                	mov    %esp,%ebp
80102f89:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102f8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102f8f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102f94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102f99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102f9c:	eb 15                	jmp    80102fb3 <freerange+0x2d>
    kfree(p);
80102f9e:	83 ec 0c             	sub    $0xc,%esp
80102fa1:	ff 75 f4             	pushl  -0xc(%ebp)
80102fa4:	e8 1a 00 00 00       	call   80102fc3 <kfree>
80102fa9:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102fac:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fb6:	05 00 10 00 00       	add    $0x1000,%eax
80102fbb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102fbe:	76 de                	jbe    80102f9e <freerange+0x18>
    kfree(p);
}
80102fc0:	90                   	nop
80102fc1:	c9                   	leave  
80102fc2:	c3                   	ret    

80102fc3 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102fc3:	55                   	push   %ebp
80102fc4:	89 e5                	mov    %esp,%ebp
80102fc6:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80102fcc:	25 ff 0f 00 00       	and    $0xfff,%eax
80102fd1:	85 c0                	test   %eax,%eax
80102fd3:	75 1b                	jne    80102ff0 <kfree+0x2d>
80102fd5:	81 7d 08 3c 83 11 80 	cmpl   $0x8011833c,0x8(%ebp)
80102fdc:	72 12                	jb     80102ff0 <kfree+0x2d>
80102fde:	ff 75 08             	pushl  0x8(%ebp)
80102fe1:	e8 36 ff ff ff       	call   80102f1c <v2p>
80102fe6:	83 c4 04             	add    $0x4,%esp
80102fe9:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102fee:	76 0d                	jbe    80102ffd <kfree+0x3a>
    panic("kfree");
80102ff0:	83 ec 0c             	sub    $0xc,%esp
80102ff3:	68 97 90 10 80       	push   $0x80109097
80102ff8:	e8 69 d5 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ffd:	83 ec 04             	sub    $0x4,%esp
80103000:	68 00 10 00 00       	push   $0x1000
80103005:	6a 01                	push   $0x1
80103007:	ff 75 08             	pushl  0x8(%ebp)
8010300a:	e8 8c 26 00 00       	call   8010569b <memset>
8010300f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80103012:	a1 54 32 11 80       	mov    0x80113254,%eax
80103017:	85 c0                	test   %eax,%eax
80103019:	74 10                	je     8010302b <kfree+0x68>
    acquire(&kmem.lock);
8010301b:	83 ec 0c             	sub    $0xc,%esp
8010301e:	68 20 32 11 80       	push   $0x80113220
80103023:	e8 10 24 00 00       	call   80105438 <acquire>
80103028:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010302b:	8b 45 08             	mov    0x8(%ebp),%eax
8010302e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80103031:	8b 15 58 32 11 80    	mov    0x80113258,%edx
80103037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010303a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010303c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010303f:	a3 58 32 11 80       	mov    %eax,0x80113258
  if(kmem.use_lock)
80103044:	a1 54 32 11 80       	mov    0x80113254,%eax
80103049:	85 c0                	test   %eax,%eax
8010304b:	74 10                	je     8010305d <kfree+0x9a>
    release(&kmem.lock);
8010304d:	83 ec 0c             	sub    $0xc,%esp
80103050:	68 20 32 11 80       	push   $0x80113220
80103055:	e8 45 24 00 00       	call   8010549f <release>
8010305a:	83 c4 10             	add    $0x10,%esp
}
8010305d:	90                   	nop
8010305e:	c9                   	leave  
8010305f:	c3                   	ret    

80103060 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80103060:	55                   	push   %ebp
80103061:	89 e5                	mov    %esp,%ebp
80103063:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103066:	a1 54 32 11 80       	mov    0x80113254,%eax
8010306b:	85 c0                	test   %eax,%eax
8010306d:	74 10                	je     8010307f <kalloc+0x1f>
    acquire(&kmem.lock);
8010306f:	83 ec 0c             	sub    $0xc,%esp
80103072:	68 20 32 11 80       	push   $0x80113220
80103077:	e8 bc 23 00 00       	call   80105438 <acquire>
8010307c:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
8010307f:	a1 58 32 11 80       	mov    0x80113258,%eax
80103084:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103087:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010308b:	74 0a                	je     80103097 <kalloc+0x37>
    kmem.freelist = r->next;
8010308d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103090:	8b 00                	mov    (%eax),%eax
80103092:	a3 58 32 11 80       	mov    %eax,0x80113258
  if(kmem.use_lock)
80103097:	a1 54 32 11 80       	mov    0x80113254,%eax
8010309c:	85 c0                	test   %eax,%eax
8010309e:	74 10                	je     801030b0 <kalloc+0x50>
    release(&kmem.lock);
801030a0:	83 ec 0c             	sub    $0xc,%esp
801030a3:	68 20 32 11 80       	push   $0x80113220
801030a8:	e8 f2 23 00 00       	call   8010549f <release>
801030ad:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801030b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801030b3:	c9                   	leave  
801030b4:	c3                   	ret    

801030b5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801030b5:	55                   	push   %ebp
801030b6:	89 e5                	mov    %esp,%ebp
801030b8:	83 ec 14             	sub    $0x14,%esp
801030bb:	8b 45 08             	mov    0x8(%ebp),%eax
801030be:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801030c2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801030c6:	89 c2                	mov    %eax,%edx
801030c8:	ec                   	in     (%dx),%al
801030c9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801030cc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801030d0:	c9                   	leave  
801030d1:	c3                   	ret    

801030d2 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801030d2:	55                   	push   %ebp
801030d3:	89 e5                	mov    %esp,%ebp
801030d5:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801030d8:	6a 64                	push   $0x64
801030da:	e8 d6 ff ff ff       	call   801030b5 <inb>
801030df:	83 c4 04             	add    $0x4,%esp
801030e2:	0f b6 c0             	movzbl %al,%eax
801030e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801030e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030eb:	83 e0 01             	and    $0x1,%eax
801030ee:	85 c0                	test   %eax,%eax
801030f0:	75 0a                	jne    801030fc <kbdgetc+0x2a>
    return -1;
801030f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801030f7:	e9 23 01 00 00       	jmp    8010321f <kbdgetc+0x14d>
  data = inb(KBDATAP);
801030fc:	6a 60                	push   $0x60
801030fe:	e8 b2 ff ff ff       	call   801030b5 <inb>
80103103:	83 c4 04             	add    $0x4,%esp
80103106:	0f b6 c0             	movzbl %al,%eax
80103109:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010310c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80103113:	75 17                	jne    8010312c <kbdgetc+0x5a>
    shift |= E0ESC;
80103115:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010311a:	83 c8 40             	or     $0x40,%eax
8010311d:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80103122:	b8 00 00 00 00       	mov    $0x0,%eax
80103127:	e9 f3 00 00 00       	jmp    8010321f <kbdgetc+0x14d>
  } else if(data & 0x80){
8010312c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010312f:	25 80 00 00 00       	and    $0x80,%eax
80103134:	85 c0                	test   %eax,%eax
80103136:	74 45                	je     8010317d <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103138:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010313d:	83 e0 40             	and    $0x40,%eax
80103140:	85 c0                	test   %eax,%eax
80103142:	75 08                	jne    8010314c <kbdgetc+0x7a>
80103144:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103147:	83 e0 7f             	and    $0x7f,%eax
8010314a:	eb 03                	jmp    8010314f <kbdgetc+0x7d>
8010314c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010314f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80103152:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103155:	05 20 a0 10 80       	add    $0x8010a020,%eax
8010315a:	0f b6 00             	movzbl (%eax),%eax
8010315d:	83 c8 40             	or     $0x40,%eax
80103160:	0f b6 c0             	movzbl %al,%eax
80103163:	f7 d0                	not    %eax
80103165:	89 c2                	mov    %eax,%edx
80103167:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010316c:	21 d0                	and    %edx,%eax
8010316e:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80103173:	b8 00 00 00 00       	mov    $0x0,%eax
80103178:	e9 a2 00 00 00       	jmp    8010321f <kbdgetc+0x14d>
  } else if(shift & E0ESC){
8010317d:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103182:	83 e0 40             	and    $0x40,%eax
80103185:	85 c0                	test   %eax,%eax
80103187:	74 14                	je     8010319d <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103189:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80103190:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103195:	83 e0 bf             	and    $0xffffffbf,%eax
80103198:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
8010319d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801031a0:	05 20 a0 10 80       	add    $0x8010a020,%eax
801031a5:	0f b6 00             	movzbl (%eax),%eax
801031a8:	0f b6 d0             	movzbl %al,%edx
801031ab:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801031b0:	09 d0                	or     %edx,%eax
801031b2:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
801031b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801031ba:	05 20 a1 10 80       	add    $0x8010a120,%eax
801031bf:	0f b6 00             	movzbl (%eax),%eax
801031c2:	0f b6 d0             	movzbl %al,%edx
801031c5:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801031ca:	31 d0                	xor    %edx,%eax
801031cc:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
801031d1:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801031d6:	83 e0 03             	and    $0x3,%eax
801031d9:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
801031e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801031e3:	01 d0                	add    %edx,%eax
801031e5:	0f b6 00             	movzbl (%eax),%eax
801031e8:	0f b6 c0             	movzbl %al,%eax
801031eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801031ee:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801031f3:	83 e0 08             	and    $0x8,%eax
801031f6:	85 c0                	test   %eax,%eax
801031f8:	74 22                	je     8010321c <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
801031fa:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801031fe:	76 0c                	jbe    8010320c <kbdgetc+0x13a>
80103200:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103204:	77 06                	ja     8010320c <kbdgetc+0x13a>
      c += 'A' - 'a';
80103206:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010320a:	eb 10                	jmp    8010321c <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010320c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103210:	76 0a                	jbe    8010321c <kbdgetc+0x14a>
80103212:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103216:	77 04                	ja     8010321c <kbdgetc+0x14a>
      c += 'a' - 'A';
80103218:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010321c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010321f:	c9                   	leave  
80103220:	c3                   	ret    

80103221 <kbdintr>:

void
kbdintr(void)
{
80103221:	55                   	push   %ebp
80103222:	89 e5                	mov    %esp,%ebp
80103224:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103227:	83 ec 0c             	sub    $0xc,%esp
8010322a:	68 d2 30 10 80       	push   $0x801030d2
8010322f:	e8 c5 d5 ff ff       	call   801007f9 <consoleintr>
80103234:	83 c4 10             	add    $0x10,%esp
}
80103237:	90                   	nop
80103238:	c9                   	leave  
80103239:	c3                   	ret    

8010323a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010323a:	55                   	push   %ebp
8010323b:	89 e5                	mov    %esp,%ebp
8010323d:	83 ec 14             	sub    $0x14,%esp
80103240:	8b 45 08             	mov    0x8(%ebp),%eax
80103243:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103247:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010324b:	89 c2                	mov    %eax,%edx
8010324d:	ec                   	in     (%dx),%al
8010324e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103251:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103255:	c9                   	leave  
80103256:	c3                   	ret    

80103257 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103257:	55                   	push   %ebp
80103258:	89 e5                	mov    %esp,%ebp
8010325a:	83 ec 08             	sub    $0x8,%esp
8010325d:	8b 55 08             	mov    0x8(%ebp),%edx
80103260:	8b 45 0c             	mov    0xc(%ebp),%eax
80103263:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103267:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010326a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010326e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103272:	ee                   	out    %al,(%dx)
}
80103273:	90                   	nop
80103274:	c9                   	leave  
80103275:	c3                   	ret    

80103276 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103276:	55                   	push   %ebp
80103277:	89 e5                	mov    %esp,%ebp
80103279:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010327c:	9c                   	pushf  
8010327d:	58                   	pop    %eax
8010327e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103281:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103284:	c9                   	leave  
80103285:	c3                   	ret    

80103286 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103286:	55                   	push   %ebp
80103287:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103289:	a1 5c 32 11 80       	mov    0x8011325c,%eax
8010328e:	8b 55 08             	mov    0x8(%ebp),%edx
80103291:	c1 e2 02             	shl    $0x2,%edx
80103294:	01 c2                	add    %eax,%edx
80103296:	8b 45 0c             	mov    0xc(%ebp),%eax
80103299:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010329b:	a1 5c 32 11 80       	mov    0x8011325c,%eax
801032a0:	83 c0 20             	add    $0x20,%eax
801032a3:	8b 00                	mov    (%eax),%eax
}
801032a5:	90                   	nop
801032a6:	5d                   	pop    %ebp
801032a7:	c3                   	ret    

801032a8 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801032a8:	55                   	push   %ebp
801032a9:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801032ab:	a1 5c 32 11 80       	mov    0x8011325c,%eax
801032b0:	85 c0                	test   %eax,%eax
801032b2:	0f 84 0b 01 00 00    	je     801033c3 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801032b8:	68 3f 01 00 00       	push   $0x13f
801032bd:	6a 3c                	push   $0x3c
801032bf:	e8 c2 ff ff ff       	call   80103286 <lapicw>
801032c4:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801032c7:	6a 0b                	push   $0xb
801032c9:	68 f8 00 00 00       	push   $0xf8
801032ce:	e8 b3 ff ff ff       	call   80103286 <lapicw>
801032d3:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801032d6:	68 20 00 02 00       	push   $0x20020
801032db:	68 c8 00 00 00       	push   $0xc8
801032e0:	e8 a1 ff ff ff       	call   80103286 <lapicw>
801032e5:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
801032e8:	68 80 96 98 00       	push   $0x989680
801032ed:	68 e0 00 00 00       	push   $0xe0
801032f2:	e8 8f ff ff ff       	call   80103286 <lapicw>
801032f7:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801032fa:	68 00 00 01 00       	push   $0x10000
801032ff:	68 d4 00 00 00       	push   $0xd4
80103304:	e8 7d ff ff ff       	call   80103286 <lapicw>
80103309:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
8010330c:	68 00 00 01 00       	push   $0x10000
80103311:	68 d8 00 00 00       	push   $0xd8
80103316:	e8 6b ff ff ff       	call   80103286 <lapicw>
8010331b:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010331e:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80103323:	83 c0 30             	add    $0x30,%eax
80103326:	8b 00                	mov    (%eax),%eax
80103328:	c1 e8 10             	shr    $0x10,%eax
8010332b:	0f b6 c0             	movzbl %al,%eax
8010332e:	83 f8 03             	cmp    $0x3,%eax
80103331:	76 12                	jbe    80103345 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80103333:	68 00 00 01 00       	push   $0x10000
80103338:	68 d0 00 00 00       	push   $0xd0
8010333d:	e8 44 ff ff ff       	call   80103286 <lapicw>
80103342:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103345:	6a 33                	push   $0x33
80103347:	68 dc 00 00 00       	push   $0xdc
8010334c:	e8 35 ff ff ff       	call   80103286 <lapicw>
80103351:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103354:	6a 00                	push   $0x0
80103356:	68 a0 00 00 00       	push   $0xa0
8010335b:	e8 26 ff ff ff       	call   80103286 <lapicw>
80103360:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103363:	6a 00                	push   $0x0
80103365:	68 a0 00 00 00       	push   $0xa0
8010336a:	e8 17 ff ff ff       	call   80103286 <lapicw>
8010336f:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103372:	6a 00                	push   $0x0
80103374:	6a 2c                	push   $0x2c
80103376:	e8 0b ff ff ff       	call   80103286 <lapicw>
8010337b:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010337e:	6a 00                	push   $0x0
80103380:	68 c4 00 00 00       	push   $0xc4
80103385:	e8 fc fe ff ff       	call   80103286 <lapicw>
8010338a:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010338d:	68 00 85 08 00       	push   $0x88500
80103392:	68 c0 00 00 00       	push   $0xc0
80103397:	e8 ea fe ff ff       	call   80103286 <lapicw>
8010339c:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010339f:	90                   	nop
801033a0:	a1 5c 32 11 80       	mov    0x8011325c,%eax
801033a5:	05 00 03 00 00       	add    $0x300,%eax
801033aa:	8b 00                	mov    (%eax),%eax
801033ac:	25 00 10 00 00       	and    $0x1000,%eax
801033b1:	85 c0                	test   %eax,%eax
801033b3:	75 eb                	jne    801033a0 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801033b5:	6a 00                	push   $0x0
801033b7:	6a 20                	push   $0x20
801033b9:	e8 c8 fe ff ff       	call   80103286 <lapicw>
801033be:	83 c4 08             	add    $0x8,%esp
801033c1:	eb 01                	jmp    801033c4 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801033c3:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801033c4:	c9                   	leave  
801033c5:	c3                   	ret    

801033c6 <cpunum>:

int
cpunum(void)
{
801033c6:	55                   	push   %ebp
801033c7:	89 e5                	mov    %esp,%ebp
801033c9:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801033cc:	e8 a5 fe ff ff       	call   80103276 <readeflags>
801033d1:	25 00 02 00 00       	and    $0x200,%eax
801033d6:	85 c0                	test   %eax,%eax
801033d8:	74 26                	je     80103400 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801033da:	a1 40 c6 10 80       	mov    0x8010c640,%eax
801033df:	8d 50 01             	lea    0x1(%eax),%edx
801033e2:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
801033e8:	85 c0                	test   %eax,%eax
801033ea:	75 14                	jne    80103400 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
801033ec:	8b 45 04             	mov    0x4(%ebp),%eax
801033ef:	83 ec 08             	sub    $0x8,%esp
801033f2:	50                   	push   %eax
801033f3:	68 a0 90 10 80       	push   $0x801090a0
801033f8:	e8 c9 cf ff ff       	call   801003c6 <cprintf>
801033fd:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103400:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80103405:	85 c0                	test   %eax,%eax
80103407:	74 0f                	je     80103418 <cpunum+0x52>
    return lapic[ID]>>24;
80103409:	a1 5c 32 11 80       	mov    0x8011325c,%eax
8010340e:	83 c0 20             	add    $0x20,%eax
80103411:	8b 00                	mov    (%eax),%eax
80103413:	c1 e8 18             	shr    $0x18,%eax
80103416:	eb 05                	jmp    8010341d <cpunum+0x57>
  return 0;
80103418:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010341d:	c9                   	leave  
8010341e:	c3                   	ret    

8010341f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010341f:	55                   	push   %ebp
80103420:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103422:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80103427:	85 c0                	test   %eax,%eax
80103429:	74 0c                	je     80103437 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010342b:	6a 00                	push   $0x0
8010342d:	6a 2c                	push   $0x2c
8010342f:	e8 52 fe ff ff       	call   80103286 <lapicw>
80103434:	83 c4 08             	add    $0x8,%esp
}
80103437:	90                   	nop
80103438:	c9                   	leave  
80103439:	c3                   	ret    

8010343a <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010343a:	55                   	push   %ebp
8010343b:	89 e5                	mov    %esp,%ebp
}
8010343d:	90                   	nop
8010343e:	5d                   	pop    %ebp
8010343f:	c3                   	ret    

80103440 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103440:	55                   	push   %ebp
80103441:	89 e5                	mov    %esp,%ebp
80103443:	83 ec 14             	sub    $0x14,%esp
80103446:	8b 45 08             	mov    0x8(%ebp),%eax
80103449:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010344c:	6a 0f                	push   $0xf
8010344e:	6a 70                	push   $0x70
80103450:	e8 02 fe ff ff       	call   80103257 <outb>
80103455:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103458:	6a 0a                	push   $0xa
8010345a:	6a 71                	push   $0x71
8010345c:	e8 f6 fd ff ff       	call   80103257 <outb>
80103461:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103464:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010346b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010346e:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103473:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103476:	83 c0 02             	add    $0x2,%eax
80103479:	8b 55 0c             	mov    0xc(%ebp),%edx
8010347c:	c1 ea 04             	shr    $0x4,%edx
8010347f:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103482:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103486:	c1 e0 18             	shl    $0x18,%eax
80103489:	50                   	push   %eax
8010348a:	68 c4 00 00 00       	push   $0xc4
8010348f:	e8 f2 fd ff ff       	call   80103286 <lapicw>
80103494:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103497:	68 00 c5 00 00       	push   $0xc500
8010349c:	68 c0 00 00 00       	push   $0xc0
801034a1:	e8 e0 fd ff ff       	call   80103286 <lapicw>
801034a6:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801034a9:	68 c8 00 00 00       	push   $0xc8
801034ae:	e8 87 ff ff ff       	call   8010343a <microdelay>
801034b3:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801034b6:	68 00 85 00 00       	push   $0x8500
801034bb:	68 c0 00 00 00       	push   $0xc0
801034c0:	e8 c1 fd ff ff       	call   80103286 <lapicw>
801034c5:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801034c8:	6a 64                	push   $0x64
801034ca:	e8 6b ff ff ff       	call   8010343a <microdelay>
801034cf:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801034d2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801034d9:	eb 3d                	jmp    80103518 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801034db:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801034df:	c1 e0 18             	shl    $0x18,%eax
801034e2:	50                   	push   %eax
801034e3:	68 c4 00 00 00       	push   $0xc4
801034e8:	e8 99 fd ff ff       	call   80103286 <lapicw>
801034ed:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801034f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801034f3:	c1 e8 0c             	shr    $0xc,%eax
801034f6:	80 cc 06             	or     $0x6,%ah
801034f9:	50                   	push   %eax
801034fa:	68 c0 00 00 00       	push   $0xc0
801034ff:	e8 82 fd ff ff       	call   80103286 <lapicw>
80103504:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103507:	68 c8 00 00 00       	push   $0xc8
8010350c:	e8 29 ff ff ff       	call   8010343a <microdelay>
80103511:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103514:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103518:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010351c:	7e bd                	jle    801034db <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010351e:	90                   	nop
8010351f:	c9                   	leave  
80103520:	c3                   	ret    

80103521 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103521:	55                   	push   %ebp
80103522:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103524:	8b 45 08             	mov    0x8(%ebp),%eax
80103527:	0f b6 c0             	movzbl %al,%eax
8010352a:	50                   	push   %eax
8010352b:	6a 70                	push   $0x70
8010352d:	e8 25 fd ff ff       	call   80103257 <outb>
80103532:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103535:	68 c8 00 00 00       	push   $0xc8
8010353a:	e8 fb fe ff ff       	call   8010343a <microdelay>
8010353f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103542:	6a 71                	push   $0x71
80103544:	e8 f1 fc ff ff       	call   8010323a <inb>
80103549:	83 c4 04             	add    $0x4,%esp
8010354c:	0f b6 c0             	movzbl %al,%eax
}
8010354f:	c9                   	leave  
80103550:	c3                   	ret    

80103551 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103551:	55                   	push   %ebp
80103552:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103554:	6a 00                	push   $0x0
80103556:	e8 c6 ff ff ff       	call   80103521 <cmos_read>
8010355b:	83 c4 04             	add    $0x4,%esp
8010355e:	89 c2                	mov    %eax,%edx
80103560:	8b 45 08             	mov    0x8(%ebp),%eax
80103563:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103565:	6a 02                	push   $0x2
80103567:	e8 b5 ff ff ff       	call   80103521 <cmos_read>
8010356c:	83 c4 04             	add    $0x4,%esp
8010356f:	89 c2                	mov    %eax,%edx
80103571:	8b 45 08             	mov    0x8(%ebp),%eax
80103574:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103577:	6a 04                	push   $0x4
80103579:	e8 a3 ff ff ff       	call   80103521 <cmos_read>
8010357e:	83 c4 04             	add    $0x4,%esp
80103581:	89 c2                	mov    %eax,%edx
80103583:	8b 45 08             	mov    0x8(%ebp),%eax
80103586:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103589:	6a 07                	push   $0x7
8010358b:	e8 91 ff ff ff       	call   80103521 <cmos_read>
80103590:	83 c4 04             	add    $0x4,%esp
80103593:	89 c2                	mov    %eax,%edx
80103595:	8b 45 08             	mov    0x8(%ebp),%eax
80103598:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
8010359b:	6a 08                	push   $0x8
8010359d:	e8 7f ff ff ff       	call   80103521 <cmos_read>
801035a2:	83 c4 04             	add    $0x4,%esp
801035a5:	89 c2                	mov    %eax,%edx
801035a7:	8b 45 08             	mov    0x8(%ebp),%eax
801035aa:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801035ad:	6a 09                	push   $0x9
801035af:	e8 6d ff ff ff       	call   80103521 <cmos_read>
801035b4:	83 c4 04             	add    $0x4,%esp
801035b7:	89 c2                	mov    %eax,%edx
801035b9:	8b 45 08             	mov    0x8(%ebp),%eax
801035bc:	89 50 14             	mov    %edx,0x14(%eax)
}
801035bf:	90                   	nop
801035c0:	c9                   	leave  
801035c1:	c3                   	ret    

801035c2 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801035c2:	55                   	push   %ebp
801035c3:	89 e5                	mov    %esp,%ebp
801035c5:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801035c8:	6a 0b                	push   $0xb
801035ca:	e8 52 ff ff ff       	call   80103521 <cmos_read>
801035cf:	83 c4 04             	add    $0x4,%esp
801035d2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801035d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d8:	83 e0 04             	and    $0x4,%eax
801035db:	85 c0                	test   %eax,%eax
801035dd:	0f 94 c0             	sete   %al
801035e0:	0f b6 c0             	movzbl %al,%eax
801035e3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801035e6:	8d 45 d8             	lea    -0x28(%ebp),%eax
801035e9:	50                   	push   %eax
801035ea:	e8 62 ff ff ff       	call   80103551 <fill_rtcdate>
801035ef:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801035f2:	6a 0a                	push   $0xa
801035f4:	e8 28 ff ff ff       	call   80103521 <cmos_read>
801035f9:	83 c4 04             	add    $0x4,%esp
801035fc:	25 80 00 00 00       	and    $0x80,%eax
80103601:	85 c0                	test   %eax,%eax
80103603:	75 27                	jne    8010362c <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103605:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103608:	50                   	push   %eax
80103609:	e8 43 ff ff ff       	call   80103551 <fill_rtcdate>
8010360e:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103611:	83 ec 04             	sub    $0x4,%esp
80103614:	6a 18                	push   $0x18
80103616:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103619:	50                   	push   %eax
8010361a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010361d:	50                   	push   %eax
8010361e:	e8 df 20 00 00       	call   80105702 <memcmp>
80103623:	83 c4 10             	add    $0x10,%esp
80103626:	85 c0                	test   %eax,%eax
80103628:	74 05                	je     8010362f <cmostime+0x6d>
8010362a:	eb ba                	jmp    801035e6 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
8010362c:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010362d:	eb b7                	jmp    801035e6 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
8010362f:	90                   	nop
  }

  // convert
  if (bcd) {
80103630:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103634:	0f 84 b4 00 00 00    	je     801036ee <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010363a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010363d:	c1 e8 04             	shr    $0x4,%eax
80103640:	89 c2                	mov    %eax,%edx
80103642:	89 d0                	mov    %edx,%eax
80103644:	c1 e0 02             	shl    $0x2,%eax
80103647:	01 d0                	add    %edx,%eax
80103649:	01 c0                	add    %eax,%eax
8010364b:	89 c2                	mov    %eax,%edx
8010364d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103650:	83 e0 0f             	and    $0xf,%eax
80103653:	01 d0                	add    %edx,%eax
80103655:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103658:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010365b:	c1 e8 04             	shr    $0x4,%eax
8010365e:	89 c2                	mov    %eax,%edx
80103660:	89 d0                	mov    %edx,%eax
80103662:	c1 e0 02             	shl    $0x2,%eax
80103665:	01 d0                	add    %edx,%eax
80103667:	01 c0                	add    %eax,%eax
80103669:	89 c2                	mov    %eax,%edx
8010366b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010366e:	83 e0 0f             	and    $0xf,%eax
80103671:	01 d0                	add    %edx,%eax
80103673:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103676:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103679:	c1 e8 04             	shr    $0x4,%eax
8010367c:	89 c2                	mov    %eax,%edx
8010367e:	89 d0                	mov    %edx,%eax
80103680:	c1 e0 02             	shl    $0x2,%eax
80103683:	01 d0                	add    %edx,%eax
80103685:	01 c0                	add    %eax,%eax
80103687:	89 c2                	mov    %eax,%edx
80103689:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010368c:	83 e0 0f             	and    $0xf,%eax
8010368f:	01 d0                	add    %edx,%eax
80103691:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103694:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103697:	c1 e8 04             	shr    $0x4,%eax
8010369a:	89 c2                	mov    %eax,%edx
8010369c:	89 d0                	mov    %edx,%eax
8010369e:	c1 e0 02             	shl    $0x2,%eax
801036a1:	01 d0                	add    %edx,%eax
801036a3:	01 c0                	add    %eax,%eax
801036a5:	89 c2                	mov    %eax,%edx
801036a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801036aa:	83 e0 0f             	and    $0xf,%eax
801036ad:	01 d0                	add    %edx,%eax
801036af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801036b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801036b5:	c1 e8 04             	shr    $0x4,%eax
801036b8:	89 c2                	mov    %eax,%edx
801036ba:	89 d0                	mov    %edx,%eax
801036bc:	c1 e0 02             	shl    $0x2,%eax
801036bf:	01 d0                	add    %edx,%eax
801036c1:	01 c0                	add    %eax,%eax
801036c3:	89 c2                	mov    %eax,%edx
801036c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801036c8:	83 e0 0f             	and    $0xf,%eax
801036cb:	01 d0                	add    %edx,%eax
801036cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801036d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036d3:	c1 e8 04             	shr    $0x4,%eax
801036d6:	89 c2                	mov    %eax,%edx
801036d8:	89 d0                	mov    %edx,%eax
801036da:	c1 e0 02             	shl    $0x2,%eax
801036dd:	01 d0                	add    %edx,%eax
801036df:	01 c0                	add    %eax,%eax
801036e1:	89 c2                	mov    %eax,%edx
801036e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036e6:	83 e0 0f             	and    $0xf,%eax
801036e9:	01 d0                	add    %edx,%eax
801036eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801036ee:	8b 45 08             	mov    0x8(%ebp),%eax
801036f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
801036f4:	89 10                	mov    %edx,(%eax)
801036f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
801036f9:	89 50 04             	mov    %edx,0x4(%eax)
801036fc:	8b 55 e0             	mov    -0x20(%ebp),%edx
801036ff:	89 50 08             	mov    %edx,0x8(%eax)
80103702:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103705:	89 50 0c             	mov    %edx,0xc(%eax)
80103708:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010370b:	89 50 10             	mov    %edx,0x10(%eax)
8010370e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103711:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103714:	8b 45 08             	mov    0x8(%ebp),%eax
80103717:	8b 40 14             	mov    0x14(%eax),%eax
8010371a:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103720:	8b 45 08             	mov    0x8(%ebp),%eax
80103723:	89 50 14             	mov    %edx,0x14(%eax)
}
80103726:	90                   	nop
80103727:	c9                   	leave  
80103728:	c3                   	ret    

80103729 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103729:	55                   	push   %ebp
8010372a:	89 e5                	mov    %esp,%ebp
8010372c:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010372f:	83 ec 08             	sub    $0x8,%esp
80103732:	68 cc 90 10 80       	push   $0x801090cc
80103737:	68 60 32 11 80       	push   $0x80113260
8010373c:	e8 d5 1c 00 00       	call   80105416 <initlock>
80103741:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103744:	83 ec 08             	sub    $0x8,%esp
80103747:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010374a:	50                   	push   %eax
8010374b:	ff 75 08             	pushl  0x8(%ebp)
8010374e:	e8 31 dc ff ff       	call   80101384 <readsb>
80103753:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103756:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103759:	a3 94 32 11 80       	mov    %eax,0x80113294
  log.size = sb.nlog;
8010375e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103761:	a3 98 32 11 80       	mov    %eax,0x80113298
  log.dev = dev;
80103766:	8b 45 08             	mov    0x8(%ebp),%eax
80103769:	a3 a4 32 11 80       	mov    %eax,0x801132a4
  recover_from_log();
8010376e:	e8 b2 01 00 00       	call   80103925 <recover_from_log>
}
80103773:	90                   	nop
80103774:	c9                   	leave  
80103775:	c3                   	ret    

80103776 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103776:	55                   	push   %ebp
80103777:	89 e5                	mov    %esp,%ebp
80103779:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010377c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103783:	e9 95 00 00 00       	jmp    8010381d <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103788:	8b 15 94 32 11 80    	mov    0x80113294,%edx
8010378e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103791:	01 d0                	add    %edx,%eax
80103793:	83 c0 01             	add    $0x1,%eax
80103796:	89 c2                	mov    %eax,%edx
80103798:	a1 a4 32 11 80       	mov    0x801132a4,%eax
8010379d:	83 ec 08             	sub    $0x8,%esp
801037a0:	52                   	push   %edx
801037a1:	50                   	push   %eax
801037a2:	e8 0f ca ff ff       	call   801001b6 <bread>
801037a7:	83 c4 10             	add    $0x10,%esp
801037aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801037ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b0:	83 c0 10             	add    $0x10,%eax
801037b3:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
801037ba:	89 c2                	mov    %eax,%edx
801037bc:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801037c1:	83 ec 08             	sub    $0x8,%esp
801037c4:	52                   	push   %edx
801037c5:	50                   	push   %eax
801037c6:	e8 eb c9 ff ff       	call   801001b6 <bread>
801037cb:	83 c4 10             	add    $0x10,%esp
801037ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801037d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037d4:	8d 50 18             	lea    0x18(%eax),%edx
801037d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037da:	83 c0 18             	add    $0x18,%eax
801037dd:	83 ec 04             	sub    $0x4,%esp
801037e0:	68 00 02 00 00       	push   $0x200
801037e5:	52                   	push   %edx
801037e6:	50                   	push   %eax
801037e7:	e8 6e 1f 00 00       	call   8010575a <memmove>
801037ec:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801037ef:	83 ec 0c             	sub    $0xc,%esp
801037f2:	ff 75 ec             	pushl  -0x14(%ebp)
801037f5:	e8 f5 c9 ff ff       	call   801001ef <bwrite>
801037fa:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801037fd:	83 ec 0c             	sub    $0xc,%esp
80103800:	ff 75 f0             	pushl  -0x10(%ebp)
80103803:	e8 26 ca ff ff       	call   8010022e <brelse>
80103808:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010380b:	83 ec 0c             	sub    $0xc,%esp
8010380e:	ff 75 ec             	pushl  -0x14(%ebp)
80103811:	e8 18 ca ff ff       	call   8010022e <brelse>
80103816:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103819:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010381d:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103822:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103825:	0f 8f 5d ff ff ff    	jg     80103788 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
8010382b:	90                   	nop
8010382c:	c9                   	leave  
8010382d:	c3                   	ret    

8010382e <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010382e:	55                   	push   %ebp
8010382f:	89 e5                	mov    %esp,%ebp
80103831:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103834:	a1 94 32 11 80       	mov    0x80113294,%eax
80103839:	89 c2                	mov    %eax,%edx
8010383b:	a1 a4 32 11 80       	mov    0x801132a4,%eax
80103840:	83 ec 08             	sub    $0x8,%esp
80103843:	52                   	push   %edx
80103844:	50                   	push   %eax
80103845:	e8 6c c9 ff ff       	call   801001b6 <bread>
8010384a:	83 c4 10             	add    $0x10,%esp
8010384d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103850:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103853:	83 c0 18             	add    $0x18,%eax
80103856:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103859:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010385c:	8b 00                	mov    (%eax),%eax
8010385e:	a3 a8 32 11 80       	mov    %eax,0x801132a8
  for (i = 0; i < log.lh.n; i++) {
80103863:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010386a:	eb 1b                	jmp    80103887 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010386c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010386f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103872:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103876:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103879:	83 c2 10             	add    $0x10,%edx
8010387c:	89 04 95 6c 32 11 80 	mov    %eax,-0x7feecd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103883:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103887:	a1 a8 32 11 80       	mov    0x801132a8,%eax
8010388c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010388f:	7f db                	jg     8010386c <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103891:	83 ec 0c             	sub    $0xc,%esp
80103894:	ff 75 f0             	pushl  -0x10(%ebp)
80103897:	e8 92 c9 ff ff       	call   8010022e <brelse>
8010389c:	83 c4 10             	add    $0x10,%esp
}
8010389f:	90                   	nop
801038a0:	c9                   	leave  
801038a1:	c3                   	ret    

801038a2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801038a2:	55                   	push   %ebp
801038a3:	89 e5                	mov    %esp,%ebp
801038a5:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801038a8:	a1 94 32 11 80       	mov    0x80113294,%eax
801038ad:	89 c2                	mov    %eax,%edx
801038af:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	52                   	push   %edx
801038b8:	50                   	push   %eax
801038b9:	e8 f8 c8 ff ff       	call   801001b6 <bread>
801038be:	83 c4 10             	add    $0x10,%esp
801038c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801038c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c7:	83 c0 18             	add    $0x18,%eax
801038ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801038cd:	8b 15 a8 32 11 80    	mov    0x801132a8,%edx
801038d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038d6:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801038d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038df:	eb 1b                	jmp    801038fc <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801038e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038e4:	83 c0 10             	add    $0x10,%eax
801038e7:	8b 0c 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%ecx
801038ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038f4:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801038f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038fc:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103901:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103904:	7f db                	jg     801038e1 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103906:	83 ec 0c             	sub    $0xc,%esp
80103909:	ff 75 f0             	pushl  -0x10(%ebp)
8010390c:	e8 de c8 ff ff       	call   801001ef <bwrite>
80103911:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103914:	83 ec 0c             	sub    $0xc,%esp
80103917:	ff 75 f0             	pushl  -0x10(%ebp)
8010391a:	e8 0f c9 ff ff       	call   8010022e <brelse>
8010391f:	83 c4 10             	add    $0x10,%esp
}
80103922:	90                   	nop
80103923:	c9                   	leave  
80103924:	c3                   	ret    

80103925 <recover_from_log>:

static void
recover_from_log(void)
{
80103925:	55                   	push   %ebp
80103926:	89 e5                	mov    %esp,%ebp
80103928:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010392b:	e8 fe fe ff ff       	call   8010382e <read_head>
  install_trans(); // if committed, copy from log to disk
80103930:	e8 41 fe ff ff       	call   80103776 <install_trans>
  log.lh.n = 0;
80103935:	c7 05 a8 32 11 80 00 	movl   $0x0,0x801132a8
8010393c:	00 00 00 
  write_head(); // clear the log
8010393f:	e8 5e ff ff ff       	call   801038a2 <write_head>
}
80103944:	90                   	nop
80103945:	c9                   	leave  
80103946:	c3                   	ret    

80103947 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103947:	55                   	push   %ebp
80103948:	89 e5                	mov    %esp,%ebp
8010394a:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010394d:	83 ec 0c             	sub    $0xc,%esp
80103950:	68 60 32 11 80       	push   $0x80113260
80103955:	e8 de 1a 00 00       	call   80105438 <acquire>
8010395a:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010395d:	a1 a0 32 11 80       	mov    0x801132a0,%eax
80103962:	85 c0                	test   %eax,%eax
80103964:	74 17                	je     8010397d <begin_op+0x36>
      sleep(&log, &log.lock);
80103966:	83 ec 08             	sub    $0x8,%esp
80103969:	68 60 32 11 80       	push   $0x80113260
8010396e:	68 60 32 11 80       	push   $0x80113260
80103973:	e8 be 17 00 00       	call   80105136 <sleep>
80103978:	83 c4 10             	add    $0x10,%esp
8010397b:	eb e0                	jmp    8010395d <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010397d:	8b 0d a8 32 11 80    	mov    0x801132a8,%ecx
80103983:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80103988:	8d 50 01             	lea    0x1(%eax),%edx
8010398b:	89 d0                	mov    %edx,%eax
8010398d:	c1 e0 02             	shl    $0x2,%eax
80103990:	01 d0                	add    %edx,%eax
80103992:	01 c0                	add    %eax,%eax
80103994:	01 c8                	add    %ecx,%eax
80103996:	83 f8 1e             	cmp    $0x1e,%eax
80103999:	7e 17                	jle    801039b2 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010399b:	83 ec 08             	sub    $0x8,%esp
8010399e:	68 60 32 11 80       	push   $0x80113260
801039a3:	68 60 32 11 80       	push   $0x80113260
801039a8:	e8 89 17 00 00       	call   80105136 <sleep>
801039ad:	83 c4 10             	add    $0x10,%esp
801039b0:	eb ab                	jmp    8010395d <begin_op+0x16>
    } else {
      log.outstanding += 1;
801039b2:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801039b7:	83 c0 01             	add    $0x1,%eax
801039ba:	a3 9c 32 11 80       	mov    %eax,0x8011329c
      release(&log.lock);
801039bf:	83 ec 0c             	sub    $0xc,%esp
801039c2:	68 60 32 11 80       	push   $0x80113260
801039c7:	e8 d3 1a 00 00       	call   8010549f <release>
801039cc:	83 c4 10             	add    $0x10,%esp
      break;
801039cf:	90                   	nop
    }
  }
}
801039d0:	90                   	nop
801039d1:	c9                   	leave  
801039d2:	c3                   	ret    

801039d3 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801039d3:	55                   	push   %ebp
801039d4:	89 e5                	mov    %esp,%ebp
801039d6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801039d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801039e0:	83 ec 0c             	sub    $0xc,%esp
801039e3:	68 60 32 11 80       	push   $0x80113260
801039e8:	e8 4b 1a 00 00       	call   80105438 <acquire>
801039ed:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801039f0:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801039f5:	83 e8 01             	sub    $0x1,%eax
801039f8:	a3 9c 32 11 80       	mov    %eax,0x8011329c
  if(log.committing)
801039fd:	a1 a0 32 11 80       	mov    0x801132a0,%eax
80103a02:	85 c0                	test   %eax,%eax
80103a04:	74 0d                	je     80103a13 <end_op+0x40>
    panic("log.committing");
80103a06:	83 ec 0c             	sub    $0xc,%esp
80103a09:	68 d0 90 10 80       	push   $0x801090d0
80103a0e:	e8 53 cb ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103a13:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80103a18:	85 c0                	test   %eax,%eax
80103a1a:	75 13                	jne    80103a2f <end_op+0x5c>
    do_commit = 1;
80103a1c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103a23:	c7 05 a0 32 11 80 01 	movl   $0x1,0x801132a0
80103a2a:	00 00 00 
80103a2d:	eb 10                	jmp    80103a3f <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103a2f:	83 ec 0c             	sub    $0xc,%esp
80103a32:	68 60 32 11 80       	push   $0x80113260
80103a37:	e8 e8 17 00 00       	call   80105224 <wakeup>
80103a3c:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103a3f:	83 ec 0c             	sub    $0xc,%esp
80103a42:	68 60 32 11 80       	push   $0x80113260
80103a47:	e8 53 1a 00 00       	call   8010549f <release>
80103a4c:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103a4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103a53:	74 3f                	je     80103a94 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103a55:	e8 f5 00 00 00       	call   80103b4f <commit>
    acquire(&log.lock);
80103a5a:	83 ec 0c             	sub    $0xc,%esp
80103a5d:	68 60 32 11 80       	push   $0x80113260
80103a62:	e8 d1 19 00 00       	call   80105438 <acquire>
80103a67:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103a6a:	c7 05 a0 32 11 80 00 	movl   $0x0,0x801132a0
80103a71:	00 00 00 
    wakeup(&log);
80103a74:	83 ec 0c             	sub    $0xc,%esp
80103a77:	68 60 32 11 80       	push   $0x80113260
80103a7c:	e8 a3 17 00 00       	call   80105224 <wakeup>
80103a81:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103a84:	83 ec 0c             	sub    $0xc,%esp
80103a87:	68 60 32 11 80       	push   $0x80113260
80103a8c:	e8 0e 1a 00 00       	call   8010549f <release>
80103a91:	83 c4 10             	add    $0x10,%esp
  }
}
80103a94:	90                   	nop
80103a95:	c9                   	leave  
80103a96:	c3                   	ret    

80103a97 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103a97:	55                   	push   %ebp
80103a98:	89 e5                	mov    %esp,%ebp
80103a9a:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103aa4:	e9 95 00 00 00       	jmp    80103b3e <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103aa9:	8b 15 94 32 11 80    	mov    0x80113294,%edx
80103aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab2:	01 d0                	add    %edx,%eax
80103ab4:	83 c0 01             	add    $0x1,%eax
80103ab7:	89 c2                	mov    %eax,%edx
80103ab9:	a1 a4 32 11 80       	mov    0x801132a4,%eax
80103abe:	83 ec 08             	sub    $0x8,%esp
80103ac1:	52                   	push   %edx
80103ac2:	50                   	push   %eax
80103ac3:	e8 ee c6 ff ff       	call   801001b6 <bread>
80103ac8:	83 c4 10             	add    $0x10,%esp
80103acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad1:	83 c0 10             	add    $0x10,%eax
80103ad4:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
80103adb:	89 c2                	mov    %eax,%edx
80103add:	a1 a4 32 11 80       	mov    0x801132a4,%eax
80103ae2:	83 ec 08             	sub    $0x8,%esp
80103ae5:	52                   	push   %edx
80103ae6:	50                   	push   %eax
80103ae7:	e8 ca c6 ff ff       	call   801001b6 <bread>
80103aec:	83 c4 10             	add    $0x10,%esp
80103aef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103af5:	8d 50 18             	lea    0x18(%eax),%edx
80103af8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103afb:	83 c0 18             	add    $0x18,%eax
80103afe:	83 ec 04             	sub    $0x4,%esp
80103b01:	68 00 02 00 00       	push   $0x200
80103b06:	52                   	push   %edx
80103b07:	50                   	push   %eax
80103b08:	e8 4d 1c 00 00       	call   8010575a <memmove>
80103b0d:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103b10:	83 ec 0c             	sub    $0xc,%esp
80103b13:	ff 75 f0             	pushl  -0x10(%ebp)
80103b16:	e8 d4 c6 ff ff       	call   801001ef <bwrite>
80103b1b:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103b1e:	83 ec 0c             	sub    $0xc,%esp
80103b21:	ff 75 ec             	pushl  -0x14(%ebp)
80103b24:	e8 05 c7 ff ff       	call   8010022e <brelse>
80103b29:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103b2c:	83 ec 0c             	sub    $0xc,%esp
80103b2f:	ff 75 f0             	pushl  -0x10(%ebp)
80103b32:	e8 f7 c6 ff ff       	call   8010022e <brelse>
80103b37:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103b3a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b3e:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103b43:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b46:	0f 8f 5d ff ff ff    	jg     80103aa9 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103b4c:	90                   	nop
80103b4d:	c9                   	leave  
80103b4e:	c3                   	ret    

80103b4f <commit>:

static void
commit()
{
80103b4f:	55                   	push   %ebp
80103b50:	89 e5                	mov    %esp,%ebp
80103b52:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103b55:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103b5a:	85 c0                	test   %eax,%eax
80103b5c:	7e 1e                	jle    80103b7c <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103b5e:	e8 34 ff ff ff       	call   80103a97 <write_log>
    write_head();    // Write header to disk -- the real commit
80103b63:	e8 3a fd ff ff       	call   801038a2 <write_head>
    install_trans(); // Now install writes to home locations
80103b68:	e8 09 fc ff ff       	call   80103776 <install_trans>
    log.lh.n = 0; 
80103b6d:	c7 05 a8 32 11 80 00 	movl   $0x0,0x801132a8
80103b74:	00 00 00 
    write_head();    // Erase the transaction from the log
80103b77:	e8 26 fd ff ff       	call   801038a2 <write_head>
  }
}
80103b7c:	90                   	nop
80103b7d:	c9                   	leave  
80103b7e:	c3                   	ret    

80103b7f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103b7f:	55                   	push   %ebp
80103b80:	89 e5                	mov    %esp,%ebp
80103b82:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103b85:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103b8a:	83 f8 1d             	cmp    $0x1d,%eax
80103b8d:	7f 12                	jg     80103ba1 <log_write+0x22>
80103b8f:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103b94:	8b 15 98 32 11 80    	mov    0x80113298,%edx
80103b9a:	83 ea 01             	sub    $0x1,%edx
80103b9d:	39 d0                	cmp    %edx,%eax
80103b9f:	7c 0d                	jl     80103bae <log_write+0x2f>
    panic("too big a transaction");
80103ba1:	83 ec 0c             	sub    $0xc,%esp
80103ba4:	68 df 90 10 80       	push   $0x801090df
80103ba9:	e8 b8 c9 ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103bae:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80103bb3:	85 c0                	test   %eax,%eax
80103bb5:	7f 0d                	jg     80103bc4 <log_write+0x45>
    panic("log_write outside of trans");
80103bb7:	83 ec 0c             	sub    $0xc,%esp
80103bba:	68 f5 90 10 80       	push   $0x801090f5
80103bbf:	e8 a2 c9 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103bc4:	83 ec 0c             	sub    $0xc,%esp
80103bc7:	68 60 32 11 80       	push   $0x80113260
80103bcc:	e8 67 18 00 00       	call   80105438 <acquire>
80103bd1:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103bd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bdb:	eb 1d                	jmp    80103bfa <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be0:	83 c0 10             	add    $0x10,%eax
80103be3:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
80103bea:	89 c2                	mov    %eax,%edx
80103bec:	8b 45 08             	mov    0x8(%ebp),%eax
80103bef:	8b 40 08             	mov    0x8(%eax),%eax
80103bf2:	39 c2                	cmp    %eax,%edx
80103bf4:	74 10                	je     80103c06 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103bf6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bfa:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103bff:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c02:	7f d9                	jg     80103bdd <log_write+0x5e>
80103c04:	eb 01                	jmp    80103c07 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103c06:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103c07:	8b 45 08             	mov    0x8(%ebp),%eax
80103c0a:	8b 40 08             	mov    0x8(%eax),%eax
80103c0d:	89 c2                	mov    %eax,%edx
80103c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c12:	83 c0 10             	add    $0x10,%eax
80103c15:	89 14 85 6c 32 11 80 	mov    %edx,-0x7feecd94(,%eax,4)
  if (i == log.lh.n)
80103c1c:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103c21:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c24:	75 0d                	jne    80103c33 <log_write+0xb4>
    log.lh.n++;
80103c26:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103c2b:	83 c0 01             	add    $0x1,%eax
80103c2e:	a3 a8 32 11 80       	mov    %eax,0x801132a8
  b->flags |= B_DIRTY; // prevent eviction
80103c33:	8b 45 08             	mov    0x8(%ebp),%eax
80103c36:	8b 00                	mov    (%eax),%eax
80103c38:	83 c8 04             	or     $0x4,%eax
80103c3b:	89 c2                	mov    %eax,%edx
80103c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c40:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103c42:	83 ec 0c             	sub    $0xc,%esp
80103c45:	68 60 32 11 80       	push   $0x80113260
80103c4a:	e8 50 18 00 00       	call   8010549f <release>
80103c4f:	83 c4 10             	add    $0x10,%esp
}
80103c52:	90                   	nop
80103c53:	c9                   	leave  
80103c54:	c3                   	ret    

80103c55 <v2p>:
80103c55:	55                   	push   %ebp
80103c56:	89 e5                	mov    %esp,%ebp
80103c58:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5b:	05 00 00 00 80       	add    $0x80000000,%eax
80103c60:	5d                   	pop    %ebp
80103c61:	c3                   	ret    

80103c62 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103c62:	55                   	push   %ebp
80103c63:	89 e5                	mov    %esp,%ebp
80103c65:	8b 45 08             	mov    0x8(%ebp),%eax
80103c68:	05 00 00 00 80       	add    $0x80000000,%eax
80103c6d:	5d                   	pop    %ebp
80103c6e:	c3                   	ret    

80103c6f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103c6f:	55                   	push   %ebp
80103c70:	89 e5                	mov    %esp,%ebp
80103c72:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103c75:	8b 55 08             	mov    0x8(%ebp),%edx
80103c78:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103c7e:	f0 87 02             	lock xchg %eax,(%edx)
80103c81:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103c84:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103c87:	c9                   	leave  
80103c88:	c3                   	ret    

80103c89 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103c89:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103c8d:	83 e4 f0             	and    $0xfffffff0,%esp
80103c90:	ff 71 fc             	pushl  -0x4(%ecx)
80103c93:	55                   	push   %ebp
80103c94:	89 e5                	mov    %esp,%ebp
80103c96:	51                   	push   %ecx
80103c97:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103c9a:	83 ec 08             	sub    $0x8,%esp
80103c9d:	68 00 00 40 80       	push   $0x80400000
80103ca2:	68 3c 83 11 80       	push   $0x8011833c
80103ca7:	e8 7d f2 ff ff       	call   80102f29 <kinit1>
80103cac:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103caf:	e8 bf 45 00 00       	call   80108273 <kvmalloc>
  mpinit();        // collect info about this machine
80103cb4:	e8 43 04 00 00       	call   801040fc <mpinit>
  lapicinit();
80103cb9:	e8 ea f5 ff ff       	call   801032a8 <lapicinit>
  seginit();       // set up segments
80103cbe:	e8 4f 3f 00 00       	call   80107c12 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103cc3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103cc9:	0f b6 00             	movzbl (%eax),%eax
80103ccc:	0f b6 c0             	movzbl %al,%eax
80103ccf:	83 ec 08             	sub    $0x8,%esp
80103cd2:	50                   	push   %eax
80103cd3:	68 10 91 10 80       	push   $0x80109110
80103cd8:	e8 e9 c6 ff ff       	call   801003c6 <cprintf>
80103cdd:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103ce0:	e8 6d 06 00 00       	call   80104352 <picinit>
  ioapicinit();    // another interrupt controller
80103ce5:	e8 34 f1 ff ff       	call   80102e1e <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103cea:	e8 2a ce ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80103cef:	e8 7a 32 00 00       	call   80106f6e <uartinit>
  pinit();         // process table
80103cf4:	e8 56 0b 00 00       	call   8010484f <pinit>
  tvinit();        // trap vectors
80103cf9:	e8 bd 2d 00 00       	call   80106abb <tvinit>
  binit();         // buffer cache
80103cfe:	e8 31 c3 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103d03:	e8 6d d2 ff ff       	call   80100f75 <fileinit>
  ideinit();       // disk
80103d08:	e8 19 ed ff ff       	call   80102a26 <ideinit>
  if(!ismp)
80103d0d:	a1 44 33 11 80       	mov    0x80113344,%eax
80103d12:	85 c0                	test   %eax,%eax
80103d14:	75 05                	jne    80103d1b <main+0x92>
    timerinit();   // uniprocessor timer
80103d16:	e8 fd 2c 00 00       	call   80106a18 <timerinit>
  startothers();   // start other processors
80103d1b:	e8 7f 00 00 00       	call   80103d9f <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103d20:	83 ec 08             	sub    $0x8,%esp
80103d23:	68 00 00 00 8e       	push   $0x8e000000
80103d28:	68 00 00 40 80       	push   $0x80400000
80103d2d:	e8 30 f2 ff ff       	call   80102f62 <kinit2>
80103d32:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103d35:	e8 3c 0c 00 00       	call   80104976 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103d3a:	e8 1a 00 00 00       	call   80103d59 <mpmain>

80103d3f <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103d3f:	55                   	push   %ebp
80103d40:	89 e5                	mov    %esp,%ebp
80103d42:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103d45:	e8 41 45 00 00       	call   8010828b <switchkvm>
  seginit();
80103d4a:	e8 c3 3e 00 00       	call   80107c12 <seginit>
  lapicinit();
80103d4f:	e8 54 f5 ff ff       	call   801032a8 <lapicinit>
  mpmain();
80103d54:	e8 00 00 00 00       	call   80103d59 <mpmain>

80103d59 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103d59:	55                   	push   %ebp
80103d5a:	89 e5                	mov    %esp,%ebp
80103d5c:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103d5f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d65:	0f b6 00             	movzbl (%eax),%eax
80103d68:	0f b6 c0             	movzbl %al,%eax
80103d6b:	83 ec 08             	sub    $0x8,%esp
80103d6e:	50                   	push   %eax
80103d6f:	68 27 91 10 80       	push   $0x80109127
80103d74:	e8 4d c6 ff ff       	call   801003c6 <cprintf>
80103d79:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103d7c:	e8 b0 2e 00 00       	call   80106c31 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103d81:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d87:	05 a8 00 00 00       	add    $0xa8,%eax
80103d8c:	83 ec 08             	sub    $0x8,%esp
80103d8f:	6a 01                	push   $0x1
80103d91:	50                   	push   %eax
80103d92:	e8 d8 fe ff ff       	call   80103c6f <xchg>
80103d97:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103d9a:	e8 b2 11 00 00       	call   80104f51 <scheduler>

80103d9f <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103d9f:	55                   	push   %ebp
80103da0:	89 e5                	mov    %esp,%ebp
80103da2:	53                   	push   %ebx
80103da3:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103da6:	68 00 70 00 00       	push   $0x7000
80103dab:	e8 b2 fe ff ff       	call   80103c62 <p2v>
80103db0:	83 c4 04             	add    $0x4,%esp
80103db3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103db6:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103dbb:	83 ec 04             	sub    $0x4,%esp
80103dbe:	50                   	push   %eax
80103dbf:	68 0c c5 10 80       	push   $0x8010c50c
80103dc4:	ff 75 f0             	pushl  -0x10(%ebp)
80103dc7:	e8 8e 19 00 00       	call   8010575a <memmove>
80103dcc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103dcf:	c7 45 f4 60 33 11 80 	movl   $0x80113360,-0xc(%ebp)
80103dd6:	e9 90 00 00 00       	jmp    80103e6b <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103ddb:	e8 e6 f5 ff ff       	call   801033c6 <cpunum>
80103de0:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103de6:	05 60 33 11 80       	add    $0x80113360,%eax
80103deb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103dee:	74 73                	je     80103e63 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103df0:	e8 6b f2 ff ff       	call   80103060 <kalloc>
80103df5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dfb:	83 e8 04             	sub    $0x4,%eax
80103dfe:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103e01:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103e07:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e0c:	83 e8 08             	sub    $0x8,%eax
80103e0f:	c7 00 3f 3d 10 80    	movl   $0x80103d3f,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e18:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103e1b:	83 ec 0c             	sub    $0xc,%esp
80103e1e:	68 00 b0 10 80       	push   $0x8010b000
80103e23:	e8 2d fe ff ff       	call   80103c55 <v2p>
80103e28:	83 c4 10             	add    $0x10,%esp
80103e2b:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103e2d:	83 ec 0c             	sub    $0xc,%esp
80103e30:	ff 75 f0             	pushl  -0x10(%ebp)
80103e33:	e8 1d fe ff ff       	call   80103c55 <v2p>
80103e38:	83 c4 10             	add    $0x10,%esp
80103e3b:	89 c2                	mov    %eax,%edx
80103e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e40:	0f b6 00             	movzbl (%eax),%eax
80103e43:	0f b6 c0             	movzbl %al,%eax
80103e46:	83 ec 08             	sub    $0x8,%esp
80103e49:	52                   	push   %edx
80103e4a:	50                   	push   %eax
80103e4b:	e8 f0 f5 ff ff       	call   80103440 <lapicstartap>
80103e50:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103e53:	90                   	nop
80103e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e57:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103e5d:	85 c0                	test   %eax,%eax
80103e5f:	74 f3                	je     80103e54 <startothers+0xb5>
80103e61:	eb 01                	jmp    80103e64 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103e63:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103e64:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103e6b:	a1 40 39 11 80       	mov    0x80113940,%eax
80103e70:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e76:	05 60 33 11 80       	add    $0x80113360,%eax
80103e7b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e7e:	0f 87 57 ff ff ff    	ja     80103ddb <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103e84:	90                   	nop
80103e85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e88:	c9                   	leave  
80103e89:	c3                   	ret    

80103e8a <p2v>:
80103e8a:	55                   	push   %ebp
80103e8b:	89 e5                	mov    %esp,%ebp
80103e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e90:	05 00 00 00 80       	add    $0x80000000,%eax
80103e95:	5d                   	pop    %ebp
80103e96:	c3                   	ret    

80103e97 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103e97:	55                   	push   %ebp
80103e98:	89 e5                	mov    %esp,%ebp
80103e9a:	83 ec 14             	sub    $0x14,%esp
80103e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ea4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103ea8:	89 c2                	mov    %eax,%edx
80103eaa:	ec                   	in     (%dx),%al
80103eab:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103eae:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103eb2:	c9                   	leave  
80103eb3:	c3                   	ret    

80103eb4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103eb4:	55                   	push   %ebp
80103eb5:	89 e5                	mov    %esp,%ebp
80103eb7:	83 ec 08             	sub    $0x8,%esp
80103eba:	8b 55 08             	mov    0x8(%ebp),%edx
80103ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ec0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ec4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ec7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ecb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ecf:	ee                   	out    %al,(%dx)
}
80103ed0:	90                   	nop
80103ed1:	c9                   	leave  
80103ed2:	c3                   	ret    

80103ed3 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103ed3:	55                   	push   %ebp
80103ed4:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103ed6:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80103edb:	89 c2                	mov    %eax,%edx
80103edd:	b8 60 33 11 80       	mov    $0x80113360,%eax
80103ee2:	29 c2                	sub    %eax,%edx
80103ee4:	89 d0                	mov    %edx,%eax
80103ee6:	c1 f8 02             	sar    $0x2,%eax
80103ee9:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103eef:	5d                   	pop    %ebp
80103ef0:	c3                   	ret    

80103ef1 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103ef1:	55                   	push   %ebp
80103ef2:	89 e5                	mov    %esp,%ebp
80103ef4:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103ef7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103efe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103f05:	eb 15                	jmp    80103f1c <sum+0x2b>
    sum += addr[i];
80103f07:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0d:	01 d0                	add    %edx,%eax
80103f0f:	0f b6 00             	movzbl (%eax),%eax
80103f12:	0f b6 c0             	movzbl %al,%eax
80103f15:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103f18:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103f1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103f1f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103f22:	7c e3                	jl     80103f07 <sum+0x16>
    sum += addr[i];
  return sum;
80103f24:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103f27:	c9                   	leave  
80103f28:	c3                   	ret    

80103f29 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103f29:	55                   	push   %ebp
80103f2a:	89 e5                	mov    %esp,%ebp
80103f2c:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103f2f:	ff 75 08             	pushl  0x8(%ebp)
80103f32:	e8 53 ff ff ff       	call   80103e8a <p2v>
80103f37:	83 c4 04             	add    $0x4,%esp
80103f3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103f3d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f43:	01 d0                	add    %edx,%eax
80103f45:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f4e:	eb 36                	jmp    80103f86 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103f50:	83 ec 04             	sub    $0x4,%esp
80103f53:	6a 04                	push   $0x4
80103f55:	68 38 91 10 80       	push   $0x80109138
80103f5a:	ff 75 f4             	pushl  -0xc(%ebp)
80103f5d:	e8 a0 17 00 00       	call   80105702 <memcmp>
80103f62:	83 c4 10             	add    $0x10,%esp
80103f65:	85 c0                	test   %eax,%eax
80103f67:	75 19                	jne    80103f82 <mpsearch1+0x59>
80103f69:	83 ec 08             	sub    $0x8,%esp
80103f6c:	6a 10                	push   $0x10
80103f6e:	ff 75 f4             	pushl  -0xc(%ebp)
80103f71:	e8 7b ff ff ff       	call   80103ef1 <sum>
80103f76:	83 c4 10             	add    $0x10,%esp
80103f79:	84 c0                	test   %al,%al
80103f7b:	75 05                	jne    80103f82 <mpsearch1+0x59>
      return (struct mp*)p;
80103f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f80:	eb 11                	jmp    80103f93 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103f82:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f89:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103f8c:	72 c2                	jb     80103f50 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103f8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f93:	c9                   	leave  
80103f94:	c3                   	ret    

80103f95 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103f95:	55                   	push   %ebp
80103f96:	89 e5                	mov    %esp,%ebp
80103f98:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103f9b:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fa5:	83 c0 0f             	add    $0xf,%eax
80103fa8:	0f b6 00             	movzbl (%eax),%eax
80103fab:	0f b6 c0             	movzbl %al,%eax
80103fae:	c1 e0 08             	shl    $0x8,%eax
80103fb1:	89 c2                	mov    %eax,%edx
80103fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb6:	83 c0 0e             	add    $0xe,%eax
80103fb9:	0f b6 00             	movzbl (%eax),%eax
80103fbc:	0f b6 c0             	movzbl %al,%eax
80103fbf:	09 d0                	or     %edx,%eax
80103fc1:	c1 e0 04             	shl    $0x4,%eax
80103fc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103fc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103fcb:	74 21                	je     80103fee <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103fcd:	83 ec 08             	sub    $0x8,%esp
80103fd0:	68 00 04 00 00       	push   $0x400
80103fd5:	ff 75 f0             	pushl  -0x10(%ebp)
80103fd8:	e8 4c ff ff ff       	call   80103f29 <mpsearch1>
80103fdd:	83 c4 10             	add    $0x10,%esp
80103fe0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103fe3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103fe7:	74 51                	je     8010403a <mpsearch+0xa5>
      return mp;
80103fe9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fec:	eb 61                	jmp    8010404f <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff1:	83 c0 14             	add    $0x14,%eax
80103ff4:	0f b6 00             	movzbl (%eax),%eax
80103ff7:	0f b6 c0             	movzbl %al,%eax
80103ffa:	c1 e0 08             	shl    $0x8,%eax
80103ffd:	89 c2                	mov    %eax,%edx
80103fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104002:	83 c0 13             	add    $0x13,%eax
80104005:	0f b6 00             	movzbl (%eax),%eax
80104008:	0f b6 c0             	movzbl %al,%eax
8010400b:	09 d0                	or     %edx,%eax
8010400d:	c1 e0 0a             	shl    $0xa,%eax
80104010:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104016:	2d 00 04 00 00       	sub    $0x400,%eax
8010401b:	83 ec 08             	sub    $0x8,%esp
8010401e:	68 00 04 00 00       	push   $0x400
80104023:	50                   	push   %eax
80104024:	e8 00 ff ff ff       	call   80103f29 <mpsearch1>
80104029:	83 c4 10             	add    $0x10,%esp
8010402c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010402f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104033:	74 05                	je     8010403a <mpsearch+0xa5>
      return mp;
80104035:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104038:	eb 15                	jmp    8010404f <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
8010403a:	83 ec 08             	sub    $0x8,%esp
8010403d:	68 00 00 01 00       	push   $0x10000
80104042:	68 00 00 0f 00       	push   $0xf0000
80104047:	e8 dd fe ff ff       	call   80103f29 <mpsearch1>
8010404c:	83 c4 10             	add    $0x10,%esp
}
8010404f:	c9                   	leave  
80104050:	c3                   	ret    

80104051 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80104051:	55                   	push   %ebp
80104052:	89 e5                	mov    %esp,%ebp
80104054:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104057:	e8 39 ff ff ff       	call   80103f95 <mpsearch>
8010405c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010405f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104063:	74 0a                	je     8010406f <mpconfig+0x1e>
80104065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104068:	8b 40 04             	mov    0x4(%eax),%eax
8010406b:	85 c0                	test   %eax,%eax
8010406d:	75 0a                	jne    80104079 <mpconfig+0x28>
    return 0;
8010406f:	b8 00 00 00 00       	mov    $0x0,%eax
80104074:	e9 81 00 00 00       	jmp    801040fa <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80104079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407c:	8b 40 04             	mov    0x4(%eax),%eax
8010407f:	83 ec 0c             	sub    $0xc,%esp
80104082:	50                   	push   %eax
80104083:	e8 02 fe ff ff       	call   80103e8a <p2v>
80104088:	83 c4 10             	add    $0x10,%esp
8010408b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010408e:	83 ec 04             	sub    $0x4,%esp
80104091:	6a 04                	push   $0x4
80104093:	68 3d 91 10 80       	push   $0x8010913d
80104098:	ff 75 f0             	pushl  -0x10(%ebp)
8010409b:	e8 62 16 00 00       	call   80105702 <memcmp>
801040a0:	83 c4 10             	add    $0x10,%esp
801040a3:	85 c0                	test   %eax,%eax
801040a5:	74 07                	je     801040ae <mpconfig+0x5d>
    return 0;
801040a7:	b8 00 00 00 00       	mov    $0x0,%eax
801040ac:	eb 4c                	jmp    801040fa <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801040ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040b1:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801040b5:	3c 01                	cmp    $0x1,%al
801040b7:	74 12                	je     801040cb <mpconfig+0x7a>
801040b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040bc:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801040c0:	3c 04                	cmp    $0x4,%al
801040c2:	74 07                	je     801040cb <mpconfig+0x7a>
    return 0;
801040c4:	b8 00 00 00 00       	mov    $0x0,%eax
801040c9:	eb 2f                	jmp    801040fa <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
801040cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040ce:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801040d2:	0f b7 c0             	movzwl %ax,%eax
801040d5:	83 ec 08             	sub    $0x8,%esp
801040d8:	50                   	push   %eax
801040d9:	ff 75 f0             	pushl  -0x10(%ebp)
801040dc:	e8 10 fe ff ff       	call   80103ef1 <sum>
801040e1:	83 c4 10             	add    $0x10,%esp
801040e4:	84 c0                	test   %al,%al
801040e6:	74 07                	je     801040ef <mpconfig+0x9e>
    return 0;
801040e8:	b8 00 00 00 00       	mov    $0x0,%eax
801040ed:	eb 0b                	jmp    801040fa <mpconfig+0xa9>
  *pmp = mp;
801040ef:	8b 45 08             	mov    0x8(%ebp),%eax
801040f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040f5:	89 10                	mov    %edx,(%eax)
  return conf;
801040f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801040fa:	c9                   	leave  
801040fb:	c3                   	ret    

801040fc <mpinit>:

void
mpinit(void)
{
801040fc:	55                   	push   %ebp
801040fd:	89 e5                	mov    %esp,%ebp
801040ff:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104102:	c7 05 44 c6 10 80 60 	movl   $0x80113360,0x8010c644
80104109:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
8010410c:	83 ec 0c             	sub    $0xc,%esp
8010410f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104112:	50                   	push   %eax
80104113:	e8 39 ff ff ff       	call   80104051 <mpconfig>
80104118:	83 c4 10             	add    $0x10,%esp
8010411b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010411e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104122:	0f 84 96 01 00 00    	je     801042be <mpinit+0x1c2>
    return;
  ismp = 1;
80104128:	c7 05 44 33 11 80 01 	movl   $0x1,0x80113344
8010412f:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104132:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104135:	8b 40 24             	mov    0x24(%eax),%eax
80104138:	a3 5c 32 11 80       	mov    %eax,0x8011325c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010413d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104140:	83 c0 2c             	add    $0x2c,%eax
80104143:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104146:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104149:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010414d:	0f b7 d0             	movzwl %ax,%edx
80104150:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104153:	01 d0                	add    %edx,%eax
80104155:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104158:	e9 f2 00 00 00       	jmp    8010424f <mpinit+0x153>
    switch(*p){
8010415d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104160:	0f b6 00             	movzbl (%eax),%eax
80104163:	0f b6 c0             	movzbl %al,%eax
80104166:	83 f8 04             	cmp    $0x4,%eax
80104169:	0f 87 bc 00 00 00    	ja     8010422b <mpinit+0x12f>
8010416f:	8b 04 85 80 91 10 80 	mov    -0x7fef6e80(,%eax,4),%eax
80104176:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80104178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
8010417e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104181:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104185:	0f b6 d0             	movzbl %al,%edx
80104188:	a1 40 39 11 80       	mov    0x80113940,%eax
8010418d:	39 c2                	cmp    %eax,%edx
8010418f:	74 2b                	je     801041bc <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104191:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104194:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104198:	0f b6 d0             	movzbl %al,%edx
8010419b:	a1 40 39 11 80       	mov    0x80113940,%eax
801041a0:	83 ec 04             	sub    $0x4,%esp
801041a3:	52                   	push   %edx
801041a4:	50                   	push   %eax
801041a5:	68 42 91 10 80       	push   $0x80109142
801041aa:	e8 17 c2 ff ff       	call   801003c6 <cprintf>
801041af:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801041b2:	c7 05 44 33 11 80 00 	movl   $0x0,0x80113344
801041b9:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801041bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041bf:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801041c3:	0f b6 c0             	movzbl %al,%eax
801041c6:	83 e0 02             	and    $0x2,%eax
801041c9:	85 c0                	test   %eax,%eax
801041cb:	74 15                	je     801041e2 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
801041cd:	a1 40 39 11 80       	mov    0x80113940,%eax
801041d2:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801041d8:	05 60 33 11 80       	add    $0x80113360,%eax
801041dd:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
801041e2:	a1 40 39 11 80       	mov    0x80113940,%eax
801041e7:	8b 15 40 39 11 80    	mov    0x80113940,%edx
801041ed:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801041f3:	05 60 33 11 80       	add    $0x80113360,%eax
801041f8:	88 10                	mov    %dl,(%eax)
      ncpu++;
801041fa:	a1 40 39 11 80       	mov    0x80113940,%eax
801041ff:	83 c0 01             	add    $0x1,%eax
80104202:	a3 40 39 11 80       	mov    %eax,0x80113940
      p += sizeof(struct mpproc);
80104207:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010420b:	eb 42                	jmp    8010424f <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010420d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104210:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104213:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104216:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010421a:	a2 40 33 11 80       	mov    %al,0x80113340
      p += sizeof(struct mpioapic);
8010421f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104223:	eb 2a                	jmp    8010424f <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104225:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104229:	eb 24                	jmp    8010424f <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
8010422b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422e:	0f b6 00             	movzbl (%eax),%eax
80104231:	0f b6 c0             	movzbl %al,%eax
80104234:	83 ec 08             	sub    $0x8,%esp
80104237:	50                   	push   %eax
80104238:	68 60 91 10 80       	push   $0x80109160
8010423d:	e8 84 c1 ff ff       	call   801003c6 <cprintf>
80104242:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80104245:	c7 05 44 33 11 80 00 	movl   $0x0,0x80113344
8010424c:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010424f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104252:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104255:	0f 82 02 ff ff ff    	jb     8010415d <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
8010425b:	a1 44 33 11 80       	mov    0x80113344,%eax
80104260:	85 c0                	test   %eax,%eax
80104262:	75 1d                	jne    80104281 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104264:	c7 05 40 39 11 80 01 	movl   $0x1,0x80113940
8010426b:	00 00 00 
    lapic = 0;
8010426e:	c7 05 5c 32 11 80 00 	movl   $0x0,0x8011325c
80104275:	00 00 00 
    ioapicid = 0;
80104278:	c6 05 40 33 11 80 00 	movb   $0x0,0x80113340
    return;
8010427f:	eb 3e                	jmp    801042bf <mpinit+0x1c3>
  }

  if(mp->imcrp){
80104281:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104284:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80104288:	84 c0                	test   %al,%al
8010428a:	74 33                	je     801042bf <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
8010428c:	83 ec 08             	sub    $0x8,%esp
8010428f:	6a 70                	push   $0x70
80104291:	6a 22                	push   $0x22
80104293:	e8 1c fc ff ff       	call   80103eb4 <outb>
80104298:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
8010429b:	83 ec 0c             	sub    $0xc,%esp
8010429e:	6a 23                	push   $0x23
801042a0:	e8 f2 fb ff ff       	call   80103e97 <inb>
801042a5:	83 c4 10             	add    $0x10,%esp
801042a8:	83 c8 01             	or     $0x1,%eax
801042ab:	0f b6 c0             	movzbl %al,%eax
801042ae:	83 ec 08             	sub    $0x8,%esp
801042b1:	50                   	push   %eax
801042b2:	6a 23                	push   $0x23
801042b4:	e8 fb fb ff ff       	call   80103eb4 <outb>
801042b9:	83 c4 10             	add    $0x10,%esp
801042bc:	eb 01                	jmp    801042bf <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801042be:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801042bf:	c9                   	leave  
801042c0:	c3                   	ret    

801042c1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801042c1:	55                   	push   %ebp
801042c2:	89 e5                	mov    %esp,%ebp
801042c4:	83 ec 08             	sub    $0x8,%esp
801042c7:	8b 55 08             	mov    0x8(%ebp),%edx
801042ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801042cd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801042d1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801042d4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801042d8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801042dc:	ee                   	out    %al,(%dx)
}
801042dd:	90                   	nop
801042de:	c9                   	leave  
801042df:	c3                   	ret    

801042e0 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
801042e0:	55                   	push   %ebp
801042e1:	89 e5                	mov    %esp,%ebp
801042e3:	83 ec 04             	sub    $0x4,%esp
801042e6:	8b 45 08             	mov    0x8(%ebp),%eax
801042e9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
801042ed:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801042f1:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
801042f7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801042fb:	0f b6 c0             	movzbl %al,%eax
801042fe:	50                   	push   %eax
801042ff:	6a 21                	push   $0x21
80104301:	e8 bb ff ff ff       	call   801042c1 <outb>
80104306:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104309:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010430d:	66 c1 e8 08          	shr    $0x8,%ax
80104311:	0f b6 c0             	movzbl %al,%eax
80104314:	50                   	push   %eax
80104315:	68 a1 00 00 00       	push   $0xa1
8010431a:	e8 a2 ff ff ff       	call   801042c1 <outb>
8010431f:	83 c4 08             	add    $0x8,%esp
}
80104322:	90                   	nop
80104323:	c9                   	leave  
80104324:	c3                   	ret    

80104325 <picenable>:

void
picenable(int irq)
{
80104325:	55                   	push   %ebp
80104326:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104328:	8b 45 08             	mov    0x8(%ebp),%eax
8010432b:	ba 01 00 00 00       	mov    $0x1,%edx
80104330:	89 c1                	mov    %eax,%ecx
80104332:	d3 e2                	shl    %cl,%edx
80104334:	89 d0                	mov    %edx,%eax
80104336:	f7 d0                	not    %eax
80104338:	89 c2                	mov    %eax,%edx
8010433a:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104341:	21 d0                	and    %edx,%eax
80104343:	0f b7 c0             	movzwl %ax,%eax
80104346:	50                   	push   %eax
80104347:	e8 94 ff ff ff       	call   801042e0 <picsetmask>
8010434c:	83 c4 04             	add    $0x4,%esp
}
8010434f:	90                   	nop
80104350:	c9                   	leave  
80104351:	c3                   	ret    

80104352 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104352:	55                   	push   %ebp
80104353:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104355:	68 ff 00 00 00       	push   $0xff
8010435a:	6a 21                	push   $0x21
8010435c:	e8 60 ff ff ff       	call   801042c1 <outb>
80104361:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104364:	68 ff 00 00 00       	push   $0xff
80104369:	68 a1 00 00 00       	push   $0xa1
8010436e:	e8 4e ff ff ff       	call   801042c1 <outb>
80104373:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104376:	6a 11                	push   $0x11
80104378:	6a 20                	push   $0x20
8010437a:	e8 42 ff ff ff       	call   801042c1 <outb>
8010437f:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104382:	6a 20                	push   $0x20
80104384:	6a 21                	push   $0x21
80104386:	e8 36 ff ff ff       	call   801042c1 <outb>
8010438b:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
8010438e:	6a 04                	push   $0x4
80104390:	6a 21                	push   $0x21
80104392:	e8 2a ff ff ff       	call   801042c1 <outb>
80104397:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
8010439a:	6a 03                	push   $0x3
8010439c:	6a 21                	push   $0x21
8010439e:	e8 1e ff ff ff       	call   801042c1 <outb>
801043a3:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801043a6:	6a 11                	push   $0x11
801043a8:	68 a0 00 00 00       	push   $0xa0
801043ad:	e8 0f ff ff ff       	call   801042c1 <outb>
801043b2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801043b5:	6a 28                	push   $0x28
801043b7:	68 a1 00 00 00       	push   $0xa1
801043bc:	e8 00 ff ff ff       	call   801042c1 <outb>
801043c1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801043c4:	6a 02                	push   $0x2
801043c6:	68 a1 00 00 00       	push   $0xa1
801043cb:	e8 f1 fe ff ff       	call   801042c1 <outb>
801043d0:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801043d3:	6a 03                	push   $0x3
801043d5:	68 a1 00 00 00       	push   $0xa1
801043da:	e8 e2 fe ff ff       	call   801042c1 <outb>
801043df:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801043e2:	6a 68                	push   $0x68
801043e4:	6a 20                	push   $0x20
801043e6:	e8 d6 fe ff ff       	call   801042c1 <outb>
801043eb:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
801043ee:	6a 0a                	push   $0xa
801043f0:	6a 20                	push   $0x20
801043f2:	e8 ca fe ff ff       	call   801042c1 <outb>
801043f7:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
801043fa:	6a 68                	push   $0x68
801043fc:	68 a0 00 00 00       	push   $0xa0
80104401:	e8 bb fe ff ff       	call   801042c1 <outb>
80104406:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104409:	6a 0a                	push   $0xa
8010440b:	68 a0 00 00 00       	push   $0xa0
80104410:	e8 ac fe ff ff       	call   801042c1 <outb>
80104415:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104418:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
8010441f:	66 83 f8 ff          	cmp    $0xffff,%ax
80104423:	74 13                	je     80104438 <picinit+0xe6>
    picsetmask(irqmask);
80104425:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
8010442c:	0f b7 c0             	movzwl %ax,%eax
8010442f:	50                   	push   %eax
80104430:	e8 ab fe ff ff       	call   801042e0 <picsetmask>
80104435:	83 c4 04             	add    $0x4,%esp
}
80104438:	90                   	nop
80104439:	c9                   	leave  
8010443a:	c3                   	ret    

8010443b <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010443b:	55                   	push   %ebp
8010443c:	89 e5                	mov    %esp,%ebp
8010443e:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104441:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104448:	8b 45 0c             	mov    0xc(%ebp),%eax
8010444b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104451:	8b 45 0c             	mov    0xc(%ebp),%eax
80104454:	8b 10                	mov    (%eax),%edx
80104456:	8b 45 08             	mov    0x8(%ebp),%eax
80104459:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010445b:	e8 33 cb ff ff       	call   80100f93 <filealloc>
80104460:	89 c2                	mov    %eax,%edx
80104462:	8b 45 08             	mov    0x8(%ebp),%eax
80104465:	89 10                	mov    %edx,(%eax)
80104467:	8b 45 08             	mov    0x8(%ebp),%eax
8010446a:	8b 00                	mov    (%eax),%eax
8010446c:	85 c0                	test   %eax,%eax
8010446e:	0f 84 cb 00 00 00    	je     8010453f <pipealloc+0x104>
80104474:	e8 1a cb ff ff       	call   80100f93 <filealloc>
80104479:	89 c2                	mov    %eax,%edx
8010447b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010447e:	89 10                	mov    %edx,(%eax)
80104480:	8b 45 0c             	mov    0xc(%ebp),%eax
80104483:	8b 00                	mov    (%eax),%eax
80104485:	85 c0                	test   %eax,%eax
80104487:	0f 84 b2 00 00 00    	je     8010453f <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010448d:	e8 ce eb ff ff       	call   80103060 <kalloc>
80104492:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104495:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104499:	0f 84 9f 00 00 00    	je     8010453e <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
8010449f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a2:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801044a9:	00 00 00 
  p->writeopen = 1;
801044ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044af:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801044b6:	00 00 00 
  p->nwrite = 0;
801044b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bc:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801044c3:	00 00 00 
  p->nread = 0;
801044c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801044d0:	00 00 00 
  initlock(&p->lock, "pipe");
801044d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d6:	83 ec 08             	sub    $0x8,%esp
801044d9:	68 94 91 10 80       	push   $0x80109194
801044de:	50                   	push   %eax
801044df:	e8 32 0f 00 00       	call   80105416 <initlock>
801044e4:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801044e7:	8b 45 08             	mov    0x8(%ebp),%eax
801044ea:	8b 00                	mov    (%eax),%eax
801044ec:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801044f2:	8b 45 08             	mov    0x8(%ebp),%eax
801044f5:	8b 00                	mov    (%eax),%eax
801044f7:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801044fb:	8b 45 08             	mov    0x8(%ebp),%eax
801044fe:	8b 00                	mov    (%eax),%eax
80104500:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104504:	8b 45 08             	mov    0x8(%ebp),%eax
80104507:	8b 00                	mov    (%eax),%eax
80104509:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010450c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010450f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104512:	8b 00                	mov    (%eax),%eax
80104514:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010451a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010451d:	8b 00                	mov    (%eax),%eax
8010451f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104523:	8b 45 0c             	mov    0xc(%ebp),%eax
80104526:	8b 00                	mov    (%eax),%eax
80104528:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010452c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010452f:	8b 00                	mov    (%eax),%eax
80104531:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104534:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104537:	b8 00 00 00 00       	mov    $0x0,%eax
8010453c:	eb 4e                	jmp    8010458c <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010453e:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010453f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104543:	74 0e                	je     80104553 <pipealloc+0x118>
    kfree((char*)p);
80104545:	83 ec 0c             	sub    $0xc,%esp
80104548:	ff 75 f4             	pushl  -0xc(%ebp)
8010454b:	e8 73 ea ff ff       	call   80102fc3 <kfree>
80104550:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104553:	8b 45 08             	mov    0x8(%ebp),%eax
80104556:	8b 00                	mov    (%eax),%eax
80104558:	85 c0                	test   %eax,%eax
8010455a:	74 11                	je     8010456d <pipealloc+0x132>
    fileclose(*f0);
8010455c:	8b 45 08             	mov    0x8(%ebp),%eax
8010455f:	8b 00                	mov    (%eax),%eax
80104561:	83 ec 0c             	sub    $0xc,%esp
80104564:	50                   	push   %eax
80104565:	e8 e7 ca ff ff       	call   80101051 <fileclose>
8010456a:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010456d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104570:	8b 00                	mov    (%eax),%eax
80104572:	85 c0                	test   %eax,%eax
80104574:	74 11                	je     80104587 <pipealloc+0x14c>
    fileclose(*f1);
80104576:	8b 45 0c             	mov    0xc(%ebp),%eax
80104579:	8b 00                	mov    (%eax),%eax
8010457b:	83 ec 0c             	sub    $0xc,%esp
8010457e:	50                   	push   %eax
8010457f:	e8 cd ca ff ff       	call   80101051 <fileclose>
80104584:	83 c4 10             	add    $0x10,%esp
  return -1;
80104587:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010458c:	c9                   	leave  
8010458d:	c3                   	ret    

8010458e <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010458e:	55                   	push   %ebp
8010458f:	89 e5                	mov    %esp,%ebp
80104591:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104594:	8b 45 08             	mov    0x8(%ebp),%eax
80104597:	83 ec 0c             	sub    $0xc,%esp
8010459a:	50                   	push   %eax
8010459b:	e8 98 0e 00 00       	call   80105438 <acquire>
801045a0:	83 c4 10             	add    $0x10,%esp
  if(writable){
801045a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801045a7:	74 23                	je     801045cc <pipeclose+0x3e>
    p->writeopen = 0;
801045a9:	8b 45 08             	mov    0x8(%ebp),%eax
801045ac:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801045b3:	00 00 00 
    wakeup(&p->nread);
801045b6:	8b 45 08             	mov    0x8(%ebp),%eax
801045b9:	05 34 02 00 00       	add    $0x234,%eax
801045be:	83 ec 0c             	sub    $0xc,%esp
801045c1:	50                   	push   %eax
801045c2:	e8 5d 0c 00 00       	call   80105224 <wakeup>
801045c7:	83 c4 10             	add    $0x10,%esp
801045ca:	eb 21                	jmp    801045ed <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801045cc:	8b 45 08             	mov    0x8(%ebp),%eax
801045cf:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801045d6:	00 00 00 
    wakeup(&p->nwrite);
801045d9:	8b 45 08             	mov    0x8(%ebp),%eax
801045dc:	05 38 02 00 00       	add    $0x238,%eax
801045e1:	83 ec 0c             	sub    $0xc,%esp
801045e4:	50                   	push   %eax
801045e5:	e8 3a 0c 00 00       	call   80105224 <wakeup>
801045ea:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801045ed:	8b 45 08             	mov    0x8(%ebp),%eax
801045f0:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801045f6:	85 c0                	test   %eax,%eax
801045f8:	75 2c                	jne    80104626 <pipeclose+0x98>
801045fa:	8b 45 08             	mov    0x8(%ebp),%eax
801045fd:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104603:	85 c0                	test   %eax,%eax
80104605:	75 1f                	jne    80104626 <pipeclose+0x98>
    release(&p->lock);
80104607:	8b 45 08             	mov    0x8(%ebp),%eax
8010460a:	83 ec 0c             	sub    $0xc,%esp
8010460d:	50                   	push   %eax
8010460e:	e8 8c 0e 00 00       	call   8010549f <release>
80104613:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104616:	83 ec 0c             	sub    $0xc,%esp
80104619:	ff 75 08             	pushl  0x8(%ebp)
8010461c:	e8 a2 e9 ff ff       	call   80102fc3 <kfree>
80104621:	83 c4 10             	add    $0x10,%esp
80104624:	eb 0f                	jmp    80104635 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104626:	8b 45 08             	mov    0x8(%ebp),%eax
80104629:	83 ec 0c             	sub    $0xc,%esp
8010462c:	50                   	push   %eax
8010462d:	e8 6d 0e 00 00       	call   8010549f <release>
80104632:	83 c4 10             	add    $0x10,%esp
}
80104635:	90                   	nop
80104636:	c9                   	leave  
80104637:	c3                   	ret    

80104638 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104638:	55                   	push   %ebp
80104639:	89 e5                	mov    %esp,%ebp
8010463b:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010463e:	8b 45 08             	mov    0x8(%ebp),%eax
80104641:	83 ec 0c             	sub    $0xc,%esp
80104644:	50                   	push   %eax
80104645:	e8 ee 0d 00 00       	call   80105438 <acquire>
8010464a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010464d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104654:	e9 ad 00 00 00       	jmp    80104706 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104659:	8b 45 08             	mov    0x8(%ebp),%eax
8010465c:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104662:	85 c0                	test   %eax,%eax
80104664:	74 0d                	je     80104673 <pipewrite+0x3b>
80104666:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010466c:	8b 40 24             	mov    0x24(%eax),%eax
8010466f:	85 c0                	test   %eax,%eax
80104671:	74 19                	je     8010468c <pipewrite+0x54>
        release(&p->lock);
80104673:	8b 45 08             	mov    0x8(%ebp),%eax
80104676:	83 ec 0c             	sub    $0xc,%esp
80104679:	50                   	push   %eax
8010467a:	e8 20 0e 00 00       	call   8010549f <release>
8010467f:	83 c4 10             	add    $0x10,%esp
        return -1;
80104682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104687:	e9 a8 00 00 00       	jmp    80104734 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
8010468c:	8b 45 08             	mov    0x8(%ebp),%eax
8010468f:	05 34 02 00 00       	add    $0x234,%eax
80104694:	83 ec 0c             	sub    $0xc,%esp
80104697:	50                   	push   %eax
80104698:	e8 87 0b 00 00       	call   80105224 <wakeup>
8010469d:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801046a0:	8b 45 08             	mov    0x8(%ebp),%eax
801046a3:	8b 55 08             	mov    0x8(%ebp),%edx
801046a6:	81 c2 38 02 00 00    	add    $0x238,%edx
801046ac:	83 ec 08             	sub    $0x8,%esp
801046af:	50                   	push   %eax
801046b0:	52                   	push   %edx
801046b1:	e8 80 0a 00 00       	call   80105136 <sleep>
801046b6:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801046b9:	8b 45 08             	mov    0x8(%ebp),%eax
801046bc:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801046c2:	8b 45 08             	mov    0x8(%ebp),%eax
801046c5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801046cb:	05 00 02 00 00       	add    $0x200,%eax
801046d0:	39 c2                	cmp    %eax,%edx
801046d2:	74 85                	je     80104659 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801046d4:	8b 45 08             	mov    0x8(%ebp),%eax
801046d7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801046dd:	8d 48 01             	lea    0x1(%eax),%ecx
801046e0:	8b 55 08             	mov    0x8(%ebp),%edx
801046e3:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801046e9:	25 ff 01 00 00       	and    $0x1ff,%eax
801046ee:	89 c1                	mov    %eax,%ecx
801046f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801046f6:	01 d0                	add    %edx,%eax
801046f8:	0f b6 10             	movzbl (%eax),%edx
801046fb:	8b 45 08             	mov    0x8(%ebp),%eax
801046fe:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104702:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104709:	3b 45 10             	cmp    0x10(%ebp),%eax
8010470c:	7c ab                	jl     801046b9 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010470e:	8b 45 08             	mov    0x8(%ebp),%eax
80104711:	05 34 02 00 00       	add    $0x234,%eax
80104716:	83 ec 0c             	sub    $0xc,%esp
80104719:	50                   	push   %eax
8010471a:	e8 05 0b 00 00       	call   80105224 <wakeup>
8010471f:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104722:	8b 45 08             	mov    0x8(%ebp),%eax
80104725:	83 ec 0c             	sub    $0xc,%esp
80104728:	50                   	push   %eax
80104729:	e8 71 0d 00 00       	call   8010549f <release>
8010472e:	83 c4 10             	add    $0x10,%esp
  return n;
80104731:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104734:	c9                   	leave  
80104735:	c3                   	ret    

80104736 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104736:	55                   	push   %ebp
80104737:	89 e5                	mov    %esp,%ebp
80104739:	53                   	push   %ebx
8010473a:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010473d:	8b 45 08             	mov    0x8(%ebp),%eax
80104740:	83 ec 0c             	sub    $0xc,%esp
80104743:	50                   	push   %eax
80104744:	e8 ef 0c 00 00       	call   80105438 <acquire>
80104749:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010474c:	eb 3f                	jmp    8010478d <piperead+0x57>
    if(proc->killed){
8010474e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104754:	8b 40 24             	mov    0x24(%eax),%eax
80104757:	85 c0                	test   %eax,%eax
80104759:	74 19                	je     80104774 <piperead+0x3e>
      release(&p->lock);
8010475b:	8b 45 08             	mov    0x8(%ebp),%eax
8010475e:	83 ec 0c             	sub    $0xc,%esp
80104761:	50                   	push   %eax
80104762:	e8 38 0d 00 00       	call   8010549f <release>
80104767:	83 c4 10             	add    $0x10,%esp
      return -1;
8010476a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010476f:	e9 bf 00 00 00       	jmp    80104833 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104774:	8b 45 08             	mov    0x8(%ebp),%eax
80104777:	8b 55 08             	mov    0x8(%ebp),%edx
8010477a:	81 c2 34 02 00 00    	add    $0x234,%edx
80104780:	83 ec 08             	sub    $0x8,%esp
80104783:	50                   	push   %eax
80104784:	52                   	push   %edx
80104785:	e8 ac 09 00 00       	call   80105136 <sleep>
8010478a:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010478d:	8b 45 08             	mov    0x8(%ebp),%eax
80104790:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104796:	8b 45 08             	mov    0x8(%ebp),%eax
80104799:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010479f:	39 c2                	cmp    %eax,%edx
801047a1:	75 0d                	jne    801047b0 <piperead+0x7a>
801047a3:	8b 45 08             	mov    0x8(%ebp),%eax
801047a6:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801047ac:	85 c0                	test   %eax,%eax
801047ae:	75 9e                	jne    8010474e <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801047b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801047b7:	eb 49                	jmp    80104802 <piperead+0xcc>
    if(p->nread == p->nwrite)
801047b9:	8b 45 08             	mov    0x8(%ebp),%eax
801047bc:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801047c2:	8b 45 08             	mov    0x8(%ebp),%eax
801047c5:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801047cb:	39 c2                	cmp    %eax,%edx
801047cd:	74 3d                	je     8010480c <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801047cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801047d5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801047d8:	8b 45 08             	mov    0x8(%ebp),%eax
801047db:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801047e1:	8d 48 01             	lea    0x1(%eax),%ecx
801047e4:	8b 55 08             	mov    0x8(%ebp),%edx
801047e7:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801047ed:	25 ff 01 00 00       	and    $0x1ff,%eax
801047f2:	89 c2                	mov    %eax,%edx
801047f4:	8b 45 08             	mov    0x8(%ebp),%eax
801047f7:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801047fc:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801047fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104805:	3b 45 10             	cmp    0x10(%ebp),%eax
80104808:	7c af                	jl     801047b9 <piperead+0x83>
8010480a:	eb 01                	jmp    8010480d <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
8010480c:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010480d:	8b 45 08             	mov    0x8(%ebp),%eax
80104810:	05 38 02 00 00       	add    $0x238,%eax
80104815:	83 ec 0c             	sub    $0xc,%esp
80104818:	50                   	push   %eax
80104819:	e8 06 0a 00 00       	call   80105224 <wakeup>
8010481e:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104821:	8b 45 08             	mov    0x8(%ebp),%eax
80104824:	83 ec 0c             	sub    $0xc,%esp
80104827:	50                   	push   %eax
80104828:	e8 72 0c 00 00       	call   8010549f <release>
8010482d:	83 c4 10             	add    $0x10,%esp
  return i;
80104830:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104833:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104836:	c9                   	leave  
80104837:	c3                   	ret    

80104838 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104838:	55                   	push   %ebp
80104839:	89 e5                	mov    %esp,%ebp
8010483b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010483e:	9c                   	pushf  
8010483f:	58                   	pop    %eax
80104840:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104843:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104846:	c9                   	leave  
80104847:	c3                   	ret    

80104848 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104848:	55                   	push   %ebp
80104849:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010484b:	fb                   	sti    
}
8010484c:	90                   	nop
8010484d:	5d                   	pop    %ebp
8010484e:	c3                   	ret    

8010484f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010484f:	55                   	push   %ebp
80104850:	89 e5                	mov    %esp,%ebp
80104852:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104855:	83 ec 08             	sub    $0x8,%esp
80104858:	68 99 91 10 80       	push   $0x80109199
8010485d:	68 60 39 11 80       	push   $0x80113960
80104862:	e8 af 0b 00 00       	call   80105416 <initlock>
80104867:	83 c4 10             	add    $0x10,%esp
}
8010486a:	90                   	nop
8010486b:	c9                   	leave  
8010486c:	c3                   	ret    

8010486d <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010486d:	55                   	push   %ebp
8010486e:	89 e5                	mov    %esp,%ebp
80104870:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104873:	83 ec 0c             	sub    $0xc,%esp
80104876:	68 60 39 11 80       	push   $0x80113960
8010487b:	e8 b8 0b 00 00       	call   80105438 <acquire>
80104880:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104883:	c7 45 f4 94 39 11 80 	movl   $0x80113994,-0xc(%ebp)
8010488a:	eb 11                	jmp    8010489d <allocproc+0x30>
    if(p->state == UNUSED)
8010488c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488f:	8b 40 0c             	mov    0xc(%eax),%eax
80104892:	85 c0                	test   %eax,%eax
80104894:	74 2a                	je     801048c0 <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104896:	81 45 f4 04 01 00 00 	addl   $0x104,-0xc(%ebp)
8010489d:	81 7d f4 94 7a 11 80 	cmpl   $0x80117a94,-0xc(%ebp)
801048a4:	72 e6                	jb     8010488c <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801048a6:	83 ec 0c             	sub    $0xc,%esp
801048a9:	68 60 39 11 80       	push   $0x80113960
801048ae:	e8 ec 0b 00 00       	call   8010549f <release>
801048b3:	83 c4 10             	add    $0x10,%esp
  return 0;
801048b6:	b8 00 00 00 00       	mov    $0x0,%eax
801048bb:	e9 b4 00 00 00       	jmp    80104974 <allocproc+0x107>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801048c0:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801048c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c4:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801048cb:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801048d0:	8d 50 01             	lea    0x1(%eax),%edx
801048d3:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801048d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048dc:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801048df:	83 ec 0c             	sub    $0xc,%esp
801048e2:	68 60 39 11 80       	push   $0x80113960
801048e7:	e8 b3 0b 00 00       	call   8010549f <release>
801048ec:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801048ef:	e8 6c e7 ff ff       	call   80103060 <kalloc>
801048f4:	89 c2                	mov    %eax,%edx
801048f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f9:	89 50 08             	mov    %edx,0x8(%eax)
801048fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ff:	8b 40 08             	mov    0x8(%eax),%eax
80104902:	85 c0                	test   %eax,%eax
80104904:	75 11                	jne    80104917 <allocproc+0xaa>
    p->state = UNUSED;
80104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104909:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104910:	b8 00 00 00 00       	mov    $0x0,%eax
80104915:	eb 5d                	jmp    80104974 <allocproc+0x107>
  }
  sp = p->kstack + KSTACKSIZE;
80104917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491a:	8b 40 08             	mov    0x8(%eax),%eax
8010491d:	05 00 10 00 00       	add    $0x1000,%eax
80104922:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104925:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010492f:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104932:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104936:	ba 75 6a 10 80       	mov    $0x80106a75,%edx
8010493b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010493e:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104940:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104947:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494a:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010494d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104950:	8b 40 1c             	mov    0x1c(%eax),%eax
80104953:	83 ec 04             	sub    $0x4,%esp
80104956:	6a 14                	push   $0x14
80104958:	6a 00                	push   $0x0
8010495a:	50                   	push   %eax
8010495b:	e8 3b 0d 00 00       	call   8010569b <memset>
80104960:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104966:	8b 40 1c             	mov    0x1c(%eax),%eax
80104969:	ba f0 50 10 80       	mov    $0x801050f0,%edx
8010496e:	89 50 10             	mov    %edx,0x10(%eax)
  //init swapfile
  // cprintf("pid: %d\n",p->pid);
  // if(p->pid > 2) //do not init swapFile for shell and init proc
  // 	p->swapFile = (struct file*)createSwapFile(p);

  return p;
80104971:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104974:	c9                   	leave  
80104975:	c3                   	ret    

80104976 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104976:	55                   	push   %ebp
80104977:	89 e5                	mov    %esp,%ebp
80104979:	83 ec 18             	sub    $0x18,%esp
  
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  p = allocproc();
8010497c:	e8 ec fe ff ff       	call   8010486d <allocproc>
80104981:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104987:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
8010498c:	e8 30 38 00 00       	call   801081c1 <setupkvm>
80104991:	89 c2                	mov    %eax,%edx
80104993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104996:	89 50 04             	mov    %edx,0x4(%eax)
80104999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499c:	8b 40 04             	mov    0x4(%eax),%eax
8010499f:	85 c0                	test   %eax,%eax
801049a1:	75 0d                	jne    801049b0 <userinit+0x3a>
    panic("userinit: out of memory?");
801049a3:	83 ec 0c             	sub    $0xc,%esp
801049a6:	68 a0 91 10 80       	push   $0x801091a0
801049ab:	e8 b6 bb ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801049b0:	ba 2c 00 00 00       	mov    $0x2c,%edx
801049b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b8:	8b 40 04             	mov    0x4(%eax),%eax
801049bb:	83 ec 04             	sub    $0x4,%esp
801049be:	52                   	push   %edx
801049bf:	68 e0 c4 10 80       	push   $0x8010c4e0
801049c4:	50                   	push   %eax
801049c5:	e8 51 3a 00 00       	call   8010841b <inituvm>
801049ca:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801049cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d9:	8b 40 18             	mov    0x18(%eax),%eax
801049dc:	83 ec 04             	sub    $0x4,%esp
801049df:	6a 4c                	push   $0x4c
801049e1:	6a 00                	push   $0x0
801049e3:	50                   	push   %eax
801049e4:	e8 b2 0c 00 00       	call   8010569b <memset>
801049e9:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801049ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ef:	8b 40 18             	mov    0x18(%eax),%eax
801049f2:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801049f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fb:	8b 40 18             	mov    0x18(%eax),%eax
801049fe:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a07:	8b 40 18             	mov    0x18(%eax),%eax
80104a0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a0d:	8b 52 18             	mov    0x18(%edx),%edx
80104a10:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104a14:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1b:	8b 40 18             	mov    0x18(%eax),%eax
80104a1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a21:	8b 52 18             	mov    0x18(%edx),%edx
80104a24:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104a28:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2f:	8b 40 18             	mov    0x18(%eax),%eax
80104a32:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3c:	8b 40 18             	mov    0x18(%eax),%eax
80104a3f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a49:	8b 40 18             	mov    0x18(%eax),%eax
80104a4c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a56:	83 c0 6c             	add    $0x6c,%eax
80104a59:	83 ec 04             	sub    $0x4,%esp
80104a5c:	6a 10                	push   $0x10
80104a5e:	68 b9 91 10 80       	push   $0x801091b9
80104a63:	50                   	push   %eax
80104a64:	e8 35 0e 00 00       	call   8010589e <safestrcpy>
80104a69:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104a6c:	83 ec 0c             	sub    $0xc,%esp
80104a6f:	68 c2 91 10 80       	push   $0x801091c2
80104a74:	e8 af da ff ff       	call   80102528 <namei>
80104a79:	83 c4 10             	add    $0x10,%esp
80104a7c:	89 c2                	mov    %eax,%edx
80104a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a81:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a87:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104a8e:	90                   	nop
80104a8f:	c9                   	leave  
80104a90:	c3                   	ret    

80104a91 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104a91:	55                   	push   %ebp
80104a92:	89 e5                	mov    %esp,%ebp
80104a94:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104a97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a9d:	8b 00                	mov    (%eax),%eax
80104a9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104aa2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104aa6:	7e 31                	jle    80104ad9 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104aa8:	8b 55 08             	mov    0x8(%ebp),%edx
80104aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aae:	01 c2                	add    %eax,%edx
80104ab0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab6:	8b 40 04             	mov    0x4(%eax),%eax
80104ab9:	83 ec 04             	sub    $0x4,%esp
80104abc:	52                   	push   %edx
80104abd:	ff 75 f4             	pushl  -0xc(%ebp)
80104ac0:	50                   	push   %eax
80104ac1:	e8 a2 3a 00 00       	call   80108568 <allocuvm>
80104ac6:	83 c4 10             	add    $0x10,%esp
80104ac9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104acc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ad0:	75 3e                	jne    80104b10 <growproc+0x7f>
      return -1;
80104ad2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ad7:	eb 59                	jmp    80104b32 <growproc+0xa1>
  } else if(n < 0){
80104ad9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104add:	79 31                	jns    80104b10 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104adf:	8b 55 08             	mov    0x8(%ebp),%edx
80104ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae5:	01 c2                	add    %eax,%edx
80104ae7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aed:	8b 40 04             	mov    0x4(%eax),%eax
80104af0:	83 ec 04             	sub    $0x4,%esp
80104af3:	52                   	push   %edx
80104af4:	ff 75 f4             	pushl  -0xc(%ebp)
80104af7:	50                   	push   %eax
80104af8:	e8 96 3c 00 00       	call   80108793 <deallocuvm>
80104afd:	83 c4 10             	add    $0x10,%esp
80104b00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104b03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104b07:	75 07                	jne    80104b10 <growproc+0x7f>
      return -1;
80104b09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b0e:	eb 22                	jmp    80104b32 <growproc+0xa1>
  }
  proc->sz = sz;
80104b10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b19:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104b1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b21:	83 ec 0c             	sub    $0xc,%esp
80104b24:	50                   	push   %eax
80104b25:	e8 7e 37 00 00       	call   801082a8 <switchuvm>
80104b2a:	83 c4 10             	add    $0x10,%esp
  return 0;
80104b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b32:	c9                   	leave  
80104b33:	c3                   	ret    

80104b34 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104b34:	55                   	push   %ebp
80104b35:	89 e5                	mov    %esp,%ebp
80104b37:	57                   	push   %edi
80104b38:	56                   	push   %esi
80104b39:	53                   	push   %ebx
80104b3a:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104b3d:	e8 2b fd ff ff       	call   8010486d <allocproc>
80104b42:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104b45:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104b49:	75 0a                	jne    80104b55 <fork+0x21>
    return -1;
80104b4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b50:	e9 92 01 00 00       	jmp    80104ce7 <fork+0x1b3>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104b55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b5b:	8b 10                	mov    (%eax),%edx
80104b5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b63:	8b 40 04             	mov    0x4(%eax),%eax
80104b66:	83 ec 08             	sub    $0x8,%esp
80104b69:	52                   	push   %edx
80104b6a:	50                   	push   %eax
80104b6b:	e8 89 3e 00 00       	call   801089f9 <copyuvm>
80104b70:	83 c4 10             	add    $0x10,%esp
80104b73:	89 c2                	mov    %eax,%edx
80104b75:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b78:	89 50 04             	mov    %edx,0x4(%eax)
80104b7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b7e:	8b 40 04             	mov    0x4(%eax),%eax
80104b81:	85 c0                	test   %eax,%eax
80104b83:	75 30                	jne    80104bb5 <fork+0x81>
    kfree(np->kstack);
80104b85:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b88:	8b 40 08             	mov    0x8(%eax),%eax
80104b8b:	83 ec 0c             	sub    $0xc,%esp
80104b8e:	50                   	push   %eax
80104b8f:	e8 2f e4 ff ff       	call   80102fc3 <kfree>
80104b94:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104b97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b9a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104ba1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ba4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104bab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bb0:	e9 32 01 00 00       	jmp    80104ce7 <fork+0x1b3>
  }
  np->sz = proc->sz;
80104bb5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bbb:	8b 10                	mov    (%eax),%edx
80104bbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bc0:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104bc2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bcc:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104bcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bd2:	8b 50 18             	mov    0x18(%eax),%edx
80104bd5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bdb:	8b 40 18             	mov    0x18(%eax),%eax
80104bde:	89 c3                	mov    %eax,%ebx
80104be0:	b8 13 00 00 00       	mov    $0x13,%eax
80104be5:	89 d7                	mov    %edx,%edi
80104be7:	89 de                	mov    %ebx,%esi
80104be9:	89 c1                	mov    %eax,%ecx
80104beb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // copy swapFile for np
 
  np->numPhysPages = proc->numPhysPages;
80104bed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf3:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104bf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bfc:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->numStoredPages = proc->numStoredPages;
80104c02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c08:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104c0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c11:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104c17:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c1a:	8b 40 18             	mov    0x18(%eax),%eax
80104c1d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104c24:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104c2b:	eb 43                	jmp    80104c70 <fork+0x13c>
    if(proc->ofile[i])
80104c2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c33:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c36:	83 c2 08             	add    $0x8,%edx
80104c39:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104c3d:	85 c0                	test   %eax,%eax
80104c3f:	74 2b                	je     80104c6c <fork+0x138>
      np->ofile[i] = filedup(proc->ofile[i]);
80104c41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c4a:	83 c2 08             	add    $0x8,%edx
80104c4d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104c51:	83 ec 0c             	sub    $0xc,%esp
80104c54:	50                   	push   %eax
80104c55:	e8 a6 c3 ff ff       	call   80101000 <filedup>
80104c5a:	83 c4 10             	add    $0x10,%esp
80104c5d:	89 c1                	mov    %eax,%ecx
80104c5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c65:	83 c2 08             	add    $0x8,%edx
80104c68:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104c6c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104c70:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104c74:	7e b7                	jle    80104c2d <fork+0xf9>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104c76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c7c:	8b 40 68             	mov    0x68(%eax),%eax
80104c7f:	83 ec 0c             	sub    $0xc,%esp
80104c82:	50                   	push   %eax
80104c83:	e8 a8 cc ff ff       	call   80101930 <idup>
80104c88:	83 c4 10             	add    $0x10,%esp
80104c8b:	89 c2                	mov    %eax,%edx
80104c8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c90:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104c93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c99:	8d 50 6c             	lea    0x6c(%eax),%edx
80104c9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c9f:	83 c0 6c             	add    $0x6c,%eax
80104ca2:	83 ec 04             	sub    $0x4,%esp
80104ca5:	6a 10                	push   $0x10
80104ca7:	52                   	push   %edx
80104ca8:	50                   	push   %eax
80104ca9:	e8 f0 0b 00 00       	call   8010589e <safestrcpy>
80104cae:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104cb4:	8b 40 10             	mov    0x10(%eax),%eax
80104cb7:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104cba:	83 ec 0c             	sub    $0xc,%esp
80104cbd:	68 60 39 11 80       	push   $0x80113960
80104cc2:	e8 71 07 00 00       	call   80105438 <acquire>
80104cc7:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104cca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ccd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104cd4:	83 ec 0c             	sub    $0xc,%esp
80104cd7:	68 60 39 11 80       	push   $0x80113960
80104cdc:	e8 be 07 00 00       	call   8010549f <release>
80104ce1:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80104ce4:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104cea:	5b                   	pop    %ebx
80104ceb:	5e                   	pop    %esi
80104cec:	5f                   	pop    %edi
80104ced:	5d                   	pop    %ebp
80104cee:	c3                   	ret    

80104cef <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104cef:	55                   	push   %ebp
80104cf0:	89 e5                	mov    %esp,%ebp
80104cf2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104cf5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cfc:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104d01:	39 c2                	cmp    %eax,%edx
80104d03:	75 0d                	jne    80104d12 <exit+0x23>
    panic("init exiting");
80104d05:	83 ec 0c             	sub    $0xc,%esp
80104d08:	68 c4 91 10 80       	push   $0x801091c4
80104d0d:	e8 54 b8 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104d12:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104d19:	eb 48                	jmp    80104d63 <exit+0x74>
    if(proc->ofile[fd]){
80104d1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d21:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d24:	83 c2 08             	add    $0x8,%edx
80104d27:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d2b:	85 c0                	test   %eax,%eax
80104d2d:	74 30                	je     80104d5f <exit+0x70>
      fileclose(proc->ofile[fd]);
80104d2f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d35:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d38:	83 c2 08             	add    $0x8,%edx
80104d3b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d3f:	83 ec 0c             	sub    $0xc,%esp
80104d42:	50                   	push   %eax
80104d43:	e8 09 c3 ff ff       	call   80101051 <fileclose>
80104d48:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104d4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d51:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d54:	83 c2 08             	add    $0x8,%edx
80104d57:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104d5e:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104d5f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104d63:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104d67:	7e b2                	jle    80104d1b <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104d69:	e8 d9 eb ff ff       	call   80103947 <begin_op>
  iput(proc->cwd);
80104d6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d74:	8b 40 68             	mov    0x68(%eax),%eax
80104d77:	83 ec 0c             	sub    $0xc,%esp
80104d7a:	50                   	push   %eax
80104d7b:	e8 ba cd ff ff       	call   80101b3a <iput>
80104d80:	83 c4 10             	add    $0x10,%esp
  end_op();
80104d83:	e8 4b ec ff ff       	call   801039d3 <end_op>
  proc->cwd = 0;
80104d88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d8e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104d95:	83 ec 0c             	sub    $0xc,%esp
80104d98:	68 60 39 11 80       	push   $0x80113960
80104d9d:	e8 96 06 00 00       	call   80105438 <acquire>
80104da2:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104da5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dab:	8b 40 14             	mov    0x14(%eax),%eax
80104dae:	83 ec 0c             	sub    $0xc,%esp
80104db1:	50                   	push   %eax
80104db2:	e8 2b 04 00 00       	call   801051e2 <wakeup1>
80104db7:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dba:	c7 45 f4 94 39 11 80 	movl   $0x80113994,-0xc(%ebp)
80104dc1:	eb 3f                	jmp    80104e02 <exit+0x113>
    if(p->parent == proc){
80104dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc6:	8b 50 14             	mov    0x14(%eax),%edx
80104dc9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dcf:	39 c2                	cmp    %eax,%edx
80104dd1:	75 28                	jne    80104dfb <exit+0x10c>
      p->parent = initproc;
80104dd3:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
80104dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ddc:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de2:	8b 40 0c             	mov    0xc(%eax),%eax
80104de5:	83 f8 05             	cmp    $0x5,%eax
80104de8:	75 11                	jne    80104dfb <exit+0x10c>
        wakeup1(initproc);
80104dea:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104def:	83 ec 0c             	sub    $0xc,%esp
80104df2:	50                   	push   %eax
80104df3:	e8 ea 03 00 00       	call   801051e2 <wakeup1>
80104df8:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dfb:	81 45 f4 04 01 00 00 	addl   $0x104,-0xc(%ebp)
80104e02:	81 7d f4 94 7a 11 80 	cmpl   $0x80117a94,-0xc(%ebp)
80104e09:	72 b8                	jb     80104dc3 <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104e0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e11:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104e18:	e8 dc 01 00 00       	call   80104ff9 <sched>
  panic("zombie exit");
80104e1d:	83 ec 0c             	sub    $0xc,%esp
80104e20:	68 d1 91 10 80       	push   $0x801091d1
80104e25:	e8 3c b7 ff ff       	call   80100566 <panic>

80104e2a <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104e2a:	55                   	push   %ebp
80104e2b:	89 e5                	mov    %esp,%ebp
80104e2d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104e30:	83 ec 0c             	sub    $0xc,%esp
80104e33:	68 60 39 11 80       	push   $0x80113960
80104e38:	e8 fb 05 00 00       	call   80105438 <acquire>
80104e3d:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104e40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e47:	c7 45 f4 94 39 11 80 	movl   $0x80113994,-0xc(%ebp)
80104e4e:	e9 a9 00 00 00       	jmp    80104efc <wait+0xd2>
      if(p->parent != proc)
80104e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e56:	8b 50 14             	mov    0x14(%eax),%edx
80104e59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e5f:	39 c2                	cmp    %eax,%edx
80104e61:	0f 85 8d 00 00 00    	jne    80104ef4 <wait+0xca>
        continue;
      havekids = 1;
80104e67:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e71:	8b 40 0c             	mov    0xc(%eax),%eax
80104e74:	83 f8 05             	cmp    $0x5,%eax
80104e77:	75 7c                	jne    80104ef5 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7c:	8b 40 10             	mov    0x10(%eax),%eax
80104e7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e85:	8b 40 08             	mov    0x8(%eax),%eax
80104e88:	83 ec 0c             	sub    $0xc,%esp
80104e8b:	50                   	push   %eax
80104e8c:	e8 32 e1 ff ff       	call   80102fc3 <kfree>
80104e91:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e97:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea1:	8b 40 04             	mov    0x4(%eax),%eax
80104ea4:	83 ec 0c             	sub    $0xc,%esp
80104ea7:	50                   	push   %eax
80104ea8:	e8 6b 3a 00 00       	call   80108918 <freevm>
80104ead:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed1:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed8:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104edf:	83 ec 0c             	sub    $0xc,%esp
80104ee2:	68 60 39 11 80       	push   $0x80113960
80104ee7:	e8 b3 05 00 00       	call   8010549f <release>
80104eec:	83 c4 10             	add    $0x10,%esp
        return pid;
80104eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ef2:	eb 5b                	jmp    80104f4f <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104ef4:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ef5:	81 45 f4 04 01 00 00 	addl   $0x104,-0xc(%ebp)
80104efc:	81 7d f4 94 7a 11 80 	cmpl   $0x80117a94,-0xc(%ebp)
80104f03:	0f 82 4a ff ff ff    	jb     80104e53 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104f09:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f0d:	74 0d                	je     80104f1c <wait+0xf2>
80104f0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f15:	8b 40 24             	mov    0x24(%eax),%eax
80104f18:	85 c0                	test   %eax,%eax
80104f1a:	74 17                	je     80104f33 <wait+0x109>
      release(&ptable.lock);
80104f1c:	83 ec 0c             	sub    $0xc,%esp
80104f1f:	68 60 39 11 80       	push   $0x80113960
80104f24:	e8 76 05 00 00       	call   8010549f <release>
80104f29:	83 c4 10             	add    $0x10,%esp
      return -1;
80104f2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f31:	eb 1c                	jmp    80104f4f <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104f33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f39:	83 ec 08             	sub    $0x8,%esp
80104f3c:	68 60 39 11 80       	push   $0x80113960
80104f41:	50                   	push   %eax
80104f42:	e8 ef 01 00 00       	call   80105136 <sleep>
80104f47:	83 c4 10             	add    $0x10,%esp
  }
80104f4a:	e9 f1 fe ff ff       	jmp    80104e40 <wait+0x16>
}
80104f4f:	c9                   	leave  
80104f50:	c3                   	ret    

80104f51 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104f51:	55                   	push   %ebp
80104f52:	89 e5                	mov    %esp,%ebp
80104f54:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104f57:	e8 ec f8 ff ff       	call   80104848 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104f5c:	83 ec 0c             	sub    $0xc,%esp
80104f5f:	68 60 39 11 80       	push   $0x80113960
80104f64:	e8 cf 04 00 00       	call   80105438 <acquire>
80104f69:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f6c:	c7 45 f4 94 39 11 80 	movl   $0x80113994,-0xc(%ebp)
80104f73:	eb 66                	jmp    80104fdb <scheduler+0x8a>
      if(p->state != RUNNABLE)
80104f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f78:	8b 40 0c             	mov    0xc(%eax),%eax
80104f7b:	83 f8 03             	cmp    $0x3,%eax
80104f7e:	75 53                	jne    80104fd3 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f83:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104f89:	83 ec 0c             	sub    $0xc,%esp
80104f8c:	ff 75 f4             	pushl  -0xc(%ebp)
80104f8f:	e8 14 33 00 00       	call   801082a8 <switchuvm>
80104f94:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9a:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104fa1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fa7:	8b 40 1c             	mov    0x1c(%eax),%eax
80104faa:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104fb1:	83 c2 04             	add    $0x4,%edx
80104fb4:	83 ec 08             	sub    $0x8,%esp
80104fb7:	50                   	push   %eax
80104fb8:	52                   	push   %edx
80104fb9:	e8 51 09 00 00       	call   8010590f <swtch>
80104fbe:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104fc1:	e8 c5 32 00 00       	call   8010828b <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104fc6:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104fcd:	00 00 00 00 
80104fd1:	eb 01                	jmp    80104fd4 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104fd3:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fd4:	81 45 f4 04 01 00 00 	addl   $0x104,-0xc(%ebp)
80104fdb:	81 7d f4 94 7a 11 80 	cmpl   $0x80117a94,-0xc(%ebp)
80104fe2:	72 91                	jb     80104f75 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104fe4:	83 ec 0c             	sub    $0xc,%esp
80104fe7:	68 60 39 11 80       	push   $0x80113960
80104fec:	e8 ae 04 00 00       	call   8010549f <release>
80104ff1:	83 c4 10             	add    $0x10,%esp

  }
80104ff4:	e9 5e ff ff ff       	jmp    80104f57 <scheduler+0x6>

80104ff9 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ff9:	55                   	push   %ebp
80104ffa:	89 e5                	mov    %esp,%ebp
80104ffc:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104fff:	83 ec 0c             	sub    $0xc,%esp
80105002:	68 60 39 11 80       	push   $0x80113960
80105007:	e8 5f 05 00 00       	call   8010556b <holding>
8010500c:	83 c4 10             	add    $0x10,%esp
8010500f:	85 c0                	test   %eax,%eax
80105011:	75 0d                	jne    80105020 <sched+0x27>
    panic("sched ptable.lock");
80105013:	83 ec 0c             	sub    $0xc,%esp
80105016:	68 dd 91 10 80       	push   $0x801091dd
8010501b:	e8 46 b5 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105020:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105026:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010502c:	83 f8 01             	cmp    $0x1,%eax
8010502f:	74 0d                	je     8010503e <sched+0x45>
    panic("sched locks");
80105031:	83 ec 0c             	sub    $0xc,%esp
80105034:	68 ef 91 10 80       	push   $0x801091ef
80105039:	e8 28 b5 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
8010503e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105044:	8b 40 0c             	mov    0xc(%eax),%eax
80105047:	83 f8 04             	cmp    $0x4,%eax
8010504a:	75 0d                	jne    80105059 <sched+0x60>
    panic("sched running");
8010504c:	83 ec 0c             	sub    $0xc,%esp
8010504f:	68 fb 91 10 80       	push   $0x801091fb
80105054:	e8 0d b5 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80105059:	e8 da f7 ff ff       	call   80104838 <readeflags>
8010505e:	25 00 02 00 00       	and    $0x200,%eax
80105063:	85 c0                	test   %eax,%eax
80105065:	74 0d                	je     80105074 <sched+0x7b>
    panic("sched interruptible");
80105067:	83 ec 0c             	sub    $0xc,%esp
8010506a:	68 09 92 10 80       	push   $0x80109209
8010506f:	e8 f2 b4 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80105074:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010507a:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105080:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80105083:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105089:	8b 40 04             	mov    0x4(%eax),%eax
8010508c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105093:	83 c2 1c             	add    $0x1c,%edx
80105096:	83 ec 08             	sub    $0x8,%esp
80105099:	50                   	push   %eax
8010509a:	52                   	push   %edx
8010509b:	e8 6f 08 00 00       	call   8010590f <swtch>
801050a0:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801050a3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050ac:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801050b2:	90                   	nop
801050b3:	c9                   	leave  
801050b4:	c3                   	ret    

801050b5 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801050b5:	55                   	push   %ebp
801050b6:	89 e5                	mov    %esp,%ebp
801050b8:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801050bb:	83 ec 0c             	sub    $0xc,%esp
801050be:	68 60 39 11 80       	push   $0x80113960
801050c3:	e8 70 03 00 00       	call   80105438 <acquire>
801050c8:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
801050cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050d1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801050d8:	e8 1c ff ff ff       	call   80104ff9 <sched>
  release(&ptable.lock);
801050dd:	83 ec 0c             	sub    $0xc,%esp
801050e0:	68 60 39 11 80       	push   $0x80113960
801050e5:	e8 b5 03 00 00       	call   8010549f <release>
801050ea:	83 c4 10             	add    $0x10,%esp
}
801050ed:	90                   	nop
801050ee:	c9                   	leave  
801050ef:	c3                   	ret    

801050f0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801050f0:	55                   	push   %ebp
801050f1:	89 e5                	mov    %esp,%ebp
801050f3:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801050f6:	83 ec 0c             	sub    $0xc,%esp
801050f9:	68 60 39 11 80       	push   $0x80113960
801050fe:	e8 9c 03 00 00       	call   8010549f <release>
80105103:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105106:	a1 08 c0 10 80       	mov    0x8010c008,%eax
8010510b:	85 c0                	test   %eax,%eax
8010510d:	74 24                	je     80105133 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010510f:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105116:	00 00 00 
    iinit(ROOTDEV);
80105119:	83 ec 0c             	sub    $0xc,%esp
8010511c:	6a 01                	push   $0x1
8010511e:	e8 1b c5 ff ff       	call   8010163e <iinit>
80105123:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80105126:	83 ec 0c             	sub    $0xc,%esp
80105129:	6a 01                	push   $0x1
8010512b:	e8 f9 e5 ff ff       	call   80103729 <initlog>
80105130:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80105133:	90                   	nop
80105134:	c9                   	leave  
80105135:	c3                   	ret    

80105136 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105136:	55                   	push   %ebp
80105137:	89 e5                	mov    %esp,%ebp
80105139:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
8010513c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105142:	85 c0                	test   %eax,%eax
80105144:	75 0d                	jne    80105153 <sleep+0x1d>
    panic("sleep");
80105146:	83 ec 0c             	sub    $0xc,%esp
80105149:	68 1d 92 10 80       	push   $0x8010921d
8010514e:	e8 13 b4 ff ff       	call   80100566 <panic>

  if(lk == 0)
80105153:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105157:	75 0d                	jne    80105166 <sleep+0x30>
    panic("sleep without lk");
80105159:	83 ec 0c             	sub    $0xc,%esp
8010515c:	68 23 92 10 80       	push   $0x80109223
80105161:	e8 00 b4 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80105166:	81 7d 0c 60 39 11 80 	cmpl   $0x80113960,0xc(%ebp)
8010516d:	74 1e                	je     8010518d <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010516f:	83 ec 0c             	sub    $0xc,%esp
80105172:	68 60 39 11 80       	push   $0x80113960
80105177:	e8 bc 02 00 00       	call   80105438 <acquire>
8010517c:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010517f:	83 ec 0c             	sub    $0xc,%esp
80105182:	ff 75 0c             	pushl  0xc(%ebp)
80105185:	e8 15 03 00 00       	call   8010549f <release>
8010518a:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
8010518d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105193:	8b 55 08             	mov    0x8(%ebp),%edx
80105196:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105199:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010519f:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801051a6:	e8 4e fe ff ff       	call   80104ff9 <sched>

  // Tidy up.
  proc->chan = 0;
801051ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051b1:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801051b8:	81 7d 0c 60 39 11 80 	cmpl   $0x80113960,0xc(%ebp)
801051bf:	74 1e                	je     801051df <sleep+0xa9>
    release(&ptable.lock);
801051c1:	83 ec 0c             	sub    $0xc,%esp
801051c4:	68 60 39 11 80       	push   $0x80113960
801051c9:	e8 d1 02 00 00       	call   8010549f <release>
801051ce:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801051d1:	83 ec 0c             	sub    $0xc,%esp
801051d4:	ff 75 0c             	pushl  0xc(%ebp)
801051d7:	e8 5c 02 00 00       	call   80105438 <acquire>
801051dc:	83 c4 10             	add    $0x10,%esp
  }
}
801051df:	90                   	nop
801051e0:	c9                   	leave  
801051e1:	c3                   	ret    

801051e2 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801051e2:	55                   	push   %ebp
801051e3:	89 e5                	mov    %esp,%ebp
801051e5:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801051e8:	c7 45 fc 94 39 11 80 	movl   $0x80113994,-0x4(%ebp)
801051ef:	eb 27                	jmp    80105218 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801051f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051f4:	8b 40 0c             	mov    0xc(%eax),%eax
801051f7:	83 f8 02             	cmp    $0x2,%eax
801051fa:	75 15                	jne    80105211 <wakeup1+0x2f>
801051fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051ff:	8b 40 20             	mov    0x20(%eax),%eax
80105202:	3b 45 08             	cmp    0x8(%ebp),%eax
80105205:	75 0a                	jne    80105211 <wakeup1+0x2f>
      p->state = RUNNABLE;
80105207:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010520a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105211:	81 45 fc 04 01 00 00 	addl   $0x104,-0x4(%ebp)
80105218:	81 7d fc 94 7a 11 80 	cmpl   $0x80117a94,-0x4(%ebp)
8010521f:	72 d0                	jb     801051f1 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105221:	90                   	nop
80105222:	c9                   	leave  
80105223:	c3                   	ret    

80105224 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105224:	55                   	push   %ebp
80105225:	89 e5                	mov    %esp,%ebp
80105227:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010522a:	83 ec 0c             	sub    $0xc,%esp
8010522d:	68 60 39 11 80       	push   $0x80113960
80105232:	e8 01 02 00 00       	call   80105438 <acquire>
80105237:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010523a:	83 ec 0c             	sub    $0xc,%esp
8010523d:	ff 75 08             	pushl  0x8(%ebp)
80105240:	e8 9d ff ff ff       	call   801051e2 <wakeup1>
80105245:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105248:	83 ec 0c             	sub    $0xc,%esp
8010524b:	68 60 39 11 80       	push   $0x80113960
80105250:	e8 4a 02 00 00       	call   8010549f <release>
80105255:	83 c4 10             	add    $0x10,%esp
}
80105258:	90                   	nop
80105259:	c9                   	leave  
8010525a:	c3                   	ret    

8010525b <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010525b:	55                   	push   %ebp
8010525c:	89 e5                	mov    %esp,%ebp
8010525e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105261:	83 ec 0c             	sub    $0xc,%esp
80105264:	68 60 39 11 80       	push   $0x80113960
80105269:	e8 ca 01 00 00       	call   80105438 <acquire>
8010526e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105271:	c7 45 f4 94 39 11 80 	movl   $0x80113994,-0xc(%ebp)
80105278:	eb 48                	jmp    801052c2 <kill+0x67>
    if(p->pid == pid){
8010527a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527d:	8b 40 10             	mov    0x10(%eax),%eax
80105280:	3b 45 08             	cmp    0x8(%ebp),%eax
80105283:	75 36                	jne    801052bb <kill+0x60>
      p->killed = 1;
80105285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105288:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010528f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105292:	8b 40 0c             	mov    0xc(%eax),%eax
80105295:	83 f8 02             	cmp    $0x2,%eax
80105298:	75 0a                	jne    801052a4 <kill+0x49>
        p->state = RUNNABLE;
8010529a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801052a4:	83 ec 0c             	sub    $0xc,%esp
801052a7:	68 60 39 11 80       	push   $0x80113960
801052ac:	e8 ee 01 00 00       	call   8010549f <release>
801052b1:	83 c4 10             	add    $0x10,%esp
      return 0;
801052b4:	b8 00 00 00 00       	mov    $0x0,%eax
801052b9:	eb 25                	jmp    801052e0 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052bb:	81 45 f4 04 01 00 00 	addl   $0x104,-0xc(%ebp)
801052c2:	81 7d f4 94 7a 11 80 	cmpl   $0x80117a94,-0xc(%ebp)
801052c9:	72 af                	jb     8010527a <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801052cb:	83 ec 0c             	sub    $0xc,%esp
801052ce:	68 60 39 11 80       	push   $0x80113960
801052d3:	e8 c7 01 00 00       	call   8010549f <release>
801052d8:	83 c4 10             	add    $0x10,%esp
  return -1;
801052db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052e0:	c9                   	leave  
801052e1:	c3                   	ret    

801052e2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801052e2:	55                   	push   %ebp
801052e3:	89 e5                	mov    %esp,%ebp
801052e5:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052e8:	c7 45 f0 94 39 11 80 	movl   $0x80113994,-0x10(%ebp)
801052ef:	e9 da 00 00 00       	jmp    801053ce <procdump+0xec>
    if(p->state == UNUSED)
801052f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052f7:	8b 40 0c             	mov    0xc(%eax),%eax
801052fa:	85 c0                	test   %eax,%eax
801052fc:	0f 84 c4 00 00 00    	je     801053c6 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105302:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105305:	8b 40 0c             	mov    0xc(%eax),%eax
80105308:	83 f8 05             	cmp    $0x5,%eax
8010530b:	77 23                	ja     80105330 <procdump+0x4e>
8010530d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105310:	8b 40 0c             	mov    0xc(%eax),%eax
80105313:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010531a:	85 c0                	test   %eax,%eax
8010531c:	74 12                	je     80105330 <procdump+0x4e>
      state = states[p->state];
8010531e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105321:	8b 40 0c             	mov    0xc(%eax),%eax
80105324:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010532b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010532e:	eb 07                	jmp    80105337 <procdump+0x55>
    else
      state = "???";
80105330:	c7 45 ec 34 92 10 80 	movl   $0x80109234,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010533a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010533d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105340:	8b 40 10             	mov    0x10(%eax),%eax
80105343:	52                   	push   %edx
80105344:	ff 75 ec             	pushl  -0x14(%ebp)
80105347:	50                   	push   %eax
80105348:	68 38 92 10 80       	push   $0x80109238
8010534d:	e8 74 b0 ff ff       	call   801003c6 <cprintf>
80105352:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105358:	8b 40 0c             	mov    0xc(%eax),%eax
8010535b:	83 f8 02             	cmp    $0x2,%eax
8010535e:	75 54                	jne    801053b4 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105360:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105363:	8b 40 1c             	mov    0x1c(%eax),%eax
80105366:	8b 40 0c             	mov    0xc(%eax),%eax
80105369:	83 c0 08             	add    $0x8,%eax
8010536c:	89 c2                	mov    %eax,%edx
8010536e:	83 ec 08             	sub    $0x8,%esp
80105371:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105374:	50                   	push   %eax
80105375:	52                   	push   %edx
80105376:	e8 76 01 00 00       	call   801054f1 <getcallerpcs>
8010537b:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010537e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105385:	eb 1c                	jmp    801053a3 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010538a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010538e:	83 ec 08             	sub    $0x8,%esp
80105391:	50                   	push   %eax
80105392:	68 41 92 10 80       	push   $0x80109241
80105397:	e8 2a b0 ff ff       	call   801003c6 <cprintf>
8010539c:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010539f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801053a3:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801053a7:	7f 0b                	jg     801053b4 <procdump+0xd2>
801053a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ac:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801053b0:	85 c0                	test   %eax,%eax
801053b2:	75 d3                	jne    80105387 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801053b4:	83 ec 0c             	sub    $0xc,%esp
801053b7:	68 45 92 10 80       	push   $0x80109245
801053bc:	e8 05 b0 ff ff       	call   801003c6 <cprintf>
801053c1:	83 c4 10             	add    $0x10,%esp
801053c4:	eb 01                	jmp    801053c7 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801053c6:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053c7:	81 45 f0 04 01 00 00 	addl   $0x104,-0x10(%ebp)
801053ce:	81 7d f0 94 7a 11 80 	cmpl   $0x80117a94,-0x10(%ebp)
801053d5:	0f 82 19 ff ff ff    	jb     801052f4 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801053db:	90                   	nop
801053dc:	c9                   	leave  
801053dd:	c3                   	ret    

801053de <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801053de:	55                   	push   %ebp
801053df:	89 e5                	mov    %esp,%ebp
801053e1:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801053e4:	9c                   	pushf  
801053e5:	58                   	pop    %eax
801053e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801053e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053ec:	c9                   	leave  
801053ed:	c3                   	ret    

801053ee <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801053ee:	55                   	push   %ebp
801053ef:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801053f1:	fa                   	cli    
}
801053f2:	90                   	nop
801053f3:	5d                   	pop    %ebp
801053f4:	c3                   	ret    

801053f5 <sti>:

static inline void
sti(void)
{
801053f5:	55                   	push   %ebp
801053f6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801053f8:	fb                   	sti    
}
801053f9:	90                   	nop
801053fa:	5d                   	pop    %ebp
801053fb:	c3                   	ret    

801053fc <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801053fc:	55                   	push   %ebp
801053fd:	89 e5                	mov    %esp,%ebp
801053ff:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105402:	8b 55 08             	mov    0x8(%ebp),%edx
80105405:	8b 45 0c             	mov    0xc(%ebp),%eax
80105408:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010540b:	f0 87 02             	lock xchg %eax,(%edx)
8010540e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105414:	c9                   	leave  
80105415:	c3                   	ret    

80105416 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105416:	55                   	push   %ebp
80105417:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105419:	8b 45 08             	mov    0x8(%ebp),%eax
8010541c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010541f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105422:	8b 45 08             	mov    0x8(%ebp),%eax
80105425:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010542b:	8b 45 08             	mov    0x8(%ebp),%eax
8010542e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105435:	90                   	nop
80105436:	5d                   	pop    %ebp
80105437:	c3                   	ret    

80105438 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105438:	55                   	push   %ebp
80105439:	89 e5                	mov    %esp,%ebp
8010543b:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010543e:	e8 52 01 00 00       	call   80105595 <pushcli>
  if(holding(lk))
80105443:	8b 45 08             	mov    0x8(%ebp),%eax
80105446:	83 ec 0c             	sub    $0xc,%esp
80105449:	50                   	push   %eax
8010544a:	e8 1c 01 00 00       	call   8010556b <holding>
8010544f:	83 c4 10             	add    $0x10,%esp
80105452:	85 c0                	test   %eax,%eax
80105454:	74 0d                	je     80105463 <acquire+0x2b>
    panic("acquire");
80105456:	83 ec 0c             	sub    $0xc,%esp
80105459:	68 71 92 10 80       	push   $0x80109271
8010545e:	e8 03 b1 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105463:	90                   	nop
80105464:	8b 45 08             	mov    0x8(%ebp),%eax
80105467:	83 ec 08             	sub    $0x8,%esp
8010546a:	6a 01                	push   $0x1
8010546c:	50                   	push   %eax
8010546d:	e8 8a ff ff ff       	call   801053fc <xchg>
80105472:	83 c4 10             	add    $0x10,%esp
80105475:	85 c0                	test   %eax,%eax
80105477:	75 eb                	jne    80105464 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105479:	8b 45 08             	mov    0x8(%ebp),%eax
8010547c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105483:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105486:	8b 45 08             	mov    0x8(%ebp),%eax
80105489:	83 c0 0c             	add    $0xc,%eax
8010548c:	83 ec 08             	sub    $0x8,%esp
8010548f:	50                   	push   %eax
80105490:	8d 45 08             	lea    0x8(%ebp),%eax
80105493:	50                   	push   %eax
80105494:	e8 58 00 00 00       	call   801054f1 <getcallerpcs>
80105499:	83 c4 10             	add    $0x10,%esp
}
8010549c:	90                   	nop
8010549d:	c9                   	leave  
8010549e:	c3                   	ret    

8010549f <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010549f:	55                   	push   %ebp
801054a0:	89 e5                	mov    %esp,%ebp
801054a2:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801054a5:	83 ec 0c             	sub    $0xc,%esp
801054a8:	ff 75 08             	pushl  0x8(%ebp)
801054ab:	e8 bb 00 00 00       	call   8010556b <holding>
801054b0:	83 c4 10             	add    $0x10,%esp
801054b3:	85 c0                	test   %eax,%eax
801054b5:	75 0d                	jne    801054c4 <release+0x25>
    panic("release");
801054b7:	83 ec 0c             	sub    $0xc,%esp
801054ba:	68 79 92 10 80       	push   $0x80109279
801054bf:	e8 a2 b0 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
801054c4:	8b 45 08             	mov    0x8(%ebp),%eax
801054c7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801054ce:	8b 45 08             	mov    0x8(%ebp),%eax
801054d1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801054d8:	8b 45 08             	mov    0x8(%ebp),%eax
801054db:	83 ec 08             	sub    $0x8,%esp
801054de:	6a 00                	push   $0x0
801054e0:	50                   	push   %eax
801054e1:	e8 16 ff ff ff       	call   801053fc <xchg>
801054e6:	83 c4 10             	add    $0x10,%esp

  popcli();
801054e9:	e8 ec 00 00 00       	call   801055da <popcli>
}
801054ee:	90                   	nop
801054ef:	c9                   	leave  
801054f0:	c3                   	ret    

801054f1 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801054f1:	55                   	push   %ebp
801054f2:	89 e5                	mov    %esp,%ebp
801054f4:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801054f7:	8b 45 08             	mov    0x8(%ebp),%eax
801054fa:	83 e8 08             	sub    $0x8,%eax
801054fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105500:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105507:	eb 38                	jmp    80105541 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105509:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010550d:	74 53                	je     80105562 <getcallerpcs+0x71>
8010550f:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105516:	76 4a                	jbe    80105562 <getcallerpcs+0x71>
80105518:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010551c:	74 44                	je     80105562 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010551e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105521:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105528:	8b 45 0c             	mov    0xc(%ebp),%eax
8010552b:	01 c2                	add    %eax,%edx
8010552d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105530:	8b 40 04             	mov    0x4(%eax),%eax
80105533:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105535:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105538:	8b 00                	mov    (%eax),%eax
8010553a:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010553d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105541:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105545:	7e c2                	jle    80105509 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105547:	eb 19                	jmp    80105562 <getcallerpcs+0x71>
    pcs[i] = 0;
80105549:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010554c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105553:	8b 45 0c             	mov    0xc(%ebp),%eax
80105556:	01 d0                	add    %edx,%eax
80105558:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010555e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105562:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105566:	7e e1                	jle    80105549 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105568:	90                   	nop
80105569:	c9                   	leave  
8010556a:	c3                   	ret    

8010556b <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010556b:	55                   	push   %ebp
8010556c:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010556e:	8b 45 08             	mov    0x8(%ebp),%eax
80105571:	8b 00                	mov    (%eax),%eax
80105573:	85 c0                	test   %eax,%eax
80105575:	74 17                	je     8010558e <holding+0x23>
80105577:	8b 45 08             	mov    0x8(%ebp),%eax
8010557a:	8b 50 08             	mov    0x8(%eax),%edx
8010557d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105583:	39 c2                	cmp    %eax,%edx
80105585:	75 07                	jne    8010558e <holding+0x23>
80105587:	b8 01 00 00 00       	mov    $0x1,%eax
8010558c:	eb 05                	jmp    80105593 <holding+0x28>
8010558e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105593:	5d                   	pop    %ebp
80105594:	c3                   	ret    

80105595 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105595:	55                   	push   %ebp
80105596:	89 e5                	mov    %esp,%ebp
80105598:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010559b:	e8 3e fe ff ff       	call   801053de <readeflags>
801055a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801055a3:	e8 46 fe ff ff       	call   801053ee <cli>
  if(cpu->ncli++ == 0)
801055a8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801055af:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801055b5:	8d 48 01             	lea    0x1(%eax),%ecx
801055b8:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801055be:	85 c0                	test   %eax,%eax
801055c0:	75 15                	jne    801055d7 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801055c2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055c8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055cb:	81 e2 00 02 00 00    	and    $0x200,%edx
801055d1:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801055d7:	90                   	nop
801055d8:	c9                   	leave  
801055d9:	c3                   	ret    

801055da <popcli>:

void
popcli(void)
{
801055da:	55                   	push   %ebp
801055db:	89 e5                	mov    %esp,%ebp
801055dd:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801055e0:	e8 f9 fd ff ff       	call   801053de <readeflags>
801055e5:	25 00 02 00 00       	and    $0x200,%eax
801055ea:	85 c0                	test   %eax,%eax
801055ec:	74 0d                	je     801055fb <popcli+0x21>
    panic("popcli - interruptible");
801055ee:	83 ec 0c             	sub    $0xc,%esp
801055f1:	68 81 92 10 80       	push   $0x80109281
801055f6:	e8 6b af ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
801055fb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105601:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105607:	83 ea 01             	sub    $0x1,%edx
8010560a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105610:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105616:	85 c0                	test   %eax,%eax
80105618:	79 0d                	jns    80105627 <popcli+0x4d>
    panic("popcli");
8010561a:	83 ec 0c             	sub    $0xc,%esp
8010561d:	68 98 92 10 80       	push   $0x80109298
80105622:	e8 3f af ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105627:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010562d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105633:	85 c0                	test   %eax,%eax
80105635:	75 15                	jne    8010564c <popcli+0x72>
80105637:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010563d:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105643:	85 c0                	test   %eax,%eax
80105645:	74 05                	je     8010564c <popcli+0x72>
    sti();
80105647:	e8 a9 fd ff ff       	call   801053f5 <sti>
}
8010564c:	90                   	nop
8010564d:	c9                   	leave  
8010564e:	c3                   	ret    

8010564f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010564f:	55                   	push   %ebp
80105650:	89 e5                	mov    %esp,%ebp
80105652:	57                   	push   %edi
80105653:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105654:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105657:	8b 55 10             	mov    0x10(%ebp),%edx
8010565a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010565d:	89 cb                	mov    %ecx,%ebx
8010565f:	89 df                	mov    %ebx,%edi
80105661:	89 d1                	mov    %edx,%ecx
80105663:	fc                   	cld    
80105664:	f3 aa                	rep stos %al,%es:(%edi)
80105666:	89 ca                	mov    %ecx,%edx
80105668:	89 fb                	mov    %edi,%ebx
8010566a:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010566d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105670:	90                   	nop
80105671:	5b                   	pop    %ebx
80105672:	5f                   	pop    %edi
80105673:	5d                   	pop    %ebp
80105674:	c3                   	ret    

80105675 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105675:	55                   	push   %ebp
80105676:	89 e5                	mov    %esp,%ebp
80105678:	57                   	push   %edi
80105679:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010567a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010567d:	8b 55 10             	mov    0x10(%ebp),%edx
80105680:	8b 45 0c             	mov    0xc(%ebp),%eax
80105683:	89 cb                	mov    %ecx,%ebx
80105685:	89 df                	mov    %ebx,%edi
80105687:	89 d1                	mov    %edx,%ecx
80105689:	fc                   	cld    
8010568a:	f3 ab                	rep stos %eax,%es:(%edi)
8010568c:	89 ca                	mov    %ecx,%edx
8010568e:	89 fb                	mov    %edi,%ebx
80105690:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105693:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105696:	90                   	nop
80105697:	5b                   	pop    %ebx
80105698:	5f                   	pop    %edi
80105699:	5d                   	pop    %ebp
8010569a:	c3                   	ret    

8010569b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010569b:	55                   	push   %ebp
8010569c:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010569e:	8b 45 08             	mov    0x8(%ebp),%eax
801056a1:	83 e0 03             	and    $0x3,%eax
801056a4:	85 c0                	test   %eax,%eax
801056a6:	75 43                	jne    801056eb <memset+0x50>
801056a8:	8b 45 10             	mov    0x10(%ebp),%eax
801056ab:	83 e0 03             	and    $0x3,%eax
801056ae:	85 c0                	test   %eax,%eax
801056b0:	75 39                	jne    801056eb <memset+0x50>
    c &= 0xFF;
801056b2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801056b9:	8b 45 10             	mov    0x10(%ebp),%eax
801056bc:	c1 e8 02             	shr    $0x2,%eax
801056bf:	89 c1                	mov    %eax,%ecx
801056c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c4:	c1 e0 18             	shl    $0x18,%eax
801056c7:	89 c2                	mov    %eax,%edx
801056c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801056cc:	c1 e0 10             	shl    $0x10,%eax
801056cf:	09 c2                	or     %eax,%edx
801056d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d4:	c1 e0 08             	shl    $0x8,%eax
801056d7:	09 d0                	or     %edx,%eax
801056d9:	0b 45 0c             	or     0xc(%ebp),%eax
801056dc:	51                   	push   %ecx
801056dd:	50                   	push   %eax
801056de:	ff 75 08             	pushl  0x8(%ebp)
801056e1:	e8 8f ff ff ff       	call   80105675 <stosl>
801056e6:	83 c4 0c             	add    $0xc,%esp
801056e9:	eb 12                	jmp    801056fd <memset+0x62>
  } else
    stosb(dst, c, n);
801056eb:	8b 45 10             	mov    0x10(%ebp),%eax
801056ee:	50                   	push   %eax
801056ef:	ff 75 0c             	pushl  0xc(%ebp)
801056f2:	ff 75 08             	pushl  0x8(%ebp)
801056f5:	e8 55 ff ff ff       	call   8010564f <stosb>
801056fa:	83 c4 0c             	add    $0xc,%esp
  return dst;
801056fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105700:	c9                   	leave  
80105701:	c3                   	ret    

80105702 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105702:	55                   	push   %ebp
80105703:	89 e5                	mov    %esp,%ebp
80105705:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105708:	8b 45 08             	mov    0x8(%ebp),%eax
8010570b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010570e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105711:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105714:	eb 30                	jmp    80105746 <memcmp+0x44>
    if(*s1 != *s2)
80105716:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105719:	0f b6 10             	movzbl (%eax),%edx
8010571c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010571f:	0f b6 00             	movzbl (%eax),%eax
80105722:	38 c2                	cmp    %al,%dl
80105724:	74 18                	je     8010573e <memcmp+0x3c>
      return *s1 - *s2;
80105726:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105729:	0f b6 00             	movzbl (%eax),%eax
8010572c:	0f b6 d0             	movzbl %al,%edx
8010572f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105732:	0f b6 00             	movzbl (%eax),%eax
80105735:	0f b6 c0             	movzbl %al,%eax
80105738:	29 c2                	sub    %eax,%edx
8010573a:	89 d0                	mov    %edx,%eax
8010573c:	eb 1a                	jmp    80105758 <memcmp+0x56>
    s1++, s2++;
8010573e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105742:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105746:	8b 45 10             	mov    0x10(%ebp),%eax
80105749:	8d 50 ff             	lea    -0x1(%eax),%edx
8010574c:	89 55 10             	mov    %edx,0x10(%ebp)
8010574f:	85 c0                	test   %eax,%eax
80105751:	75 c3                	jne    80105716 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105753:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105758:	c9                   	leave  
80105759:	c3                   	ret    

8010575a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010575a:	55                   	push   %ebp
8010575b:	89 e5                	mov    %esp,%ebp
8010575d:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105760:	8b 45 0c             	mov    0xc(%ebp),%eax
80105763:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105766:	8b 45 08             	mov    0x8(%ebp),%eax
80105769:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010576c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010576f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105772:	73 54                	jae    801057c8 <memmove+0x6e>
80105774:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105777:	8b 45 10             	mov    0x10(%ebp),%eax
8010577a:	01 d0                	add    %edx,%eax
8010577c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010577f:	76 47                	jbe    801057c8 <memmove+0x6e>
    s += n;
80105781:	8b 45 10             	mov    0x10(%ebp),%eax
80105784:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105787:	8b 45 10             	mov    0x10(%ebp),%eax
8010578a:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010578d:	eb 13                	jmp    801057a2 <memmove+0x48>
      *--d = *--s;
8010578f:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105793:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105797:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010579a:	0f b6 10             	movzbl (%eax),%edx
8010579d:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057a0:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801057a2:	8b 45 10             	mov    0x10(%ebp),%eax
801057a5:	8d 50 ff             	lea    -0x1(%eax),%edx
801057a8:	89 55 10             	mov    %edx,0x10(%ebp)
801057ab:	85 c0                	test   %eax,%eax
801057ad:	75 e0                	jne    8010578f <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801057af:	eb 24                	jmp    801057d5 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801057b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057b4:	8d 50 01             	lea    0x1(%eax),%edx
801057b7:	89 55 f8             	mov    %edx,-0x8(%ebp)
801057ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057bd:	8d 4a 01             	lea    0x1(%edx),%ecx
801057c0:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801057c3:	0f b6 12             	movzbl (%edx),%edx
801057c6:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801057c8:	8b 45 10             	mov    0x10(%ebp),%eax
801057cb:	8d 50 ff             	lea    -0x1(%eax),%edx
801057ce:	89 55 10             	mov    %edx,0x10(%ebp)
801057d1:	85 c0                	test   %eax,%eax
801057d3:	75 dc                	jne    801057b1 <memmove+0x57>
      *d++ = *s++;

  return dst;
801057d5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801057d8:	c9                   	leave  
801057d9:	c3                   	ret    

801057da <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801057da:	55                   	push   %ebp
801057db:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801057dd:	ff 75 10             	pushl  0x10(%ebp)
801057e0:	ff 75 0c             	pushl  0xc(%ebp)
801057e3:	ff 75 08             	pushl  0x8(%ebp)
801057e6:	e8 6f ff ff ff       	call   8010575a <memmove>
801057eb:	83 c4 0c             	add    $0xc,%esp
}
801057ee:	c9                   	leave  
801057ef:	c3                   	ret    

801057f0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801057f0:	55                   	push   %ebp
801057f1:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801057f3:	eb 0c                	jmp    80105801 <strncmp+0x11>
    n--, p++, q++;
801057f5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801057fd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105801:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105805:	74 1a                	je     80105821 <strncmp+0x31>
80105807:	8b 45 08             	mov    0x8(%ebp),%eax
8010580a:	0f b6 00             	movzbl (%eax),%eax
8010580d:	84 c0                	test   %al,%al
8010580f:	74 10                	je     80105821 <strncmp+0x31>
80105811:	8b 45 08             	mov    0x8(%ebp),%eax
80105814:	0f b6 10             	movzbl (%eax),%edx
80105817:	8b 45 0c             	mov    0xc(%ebp),%eax
8010581a:	0f b6 00             	movzbl (%eax),%eax
8010581d:	38 c2                	cmp    %al,%dl
8010581f:	74 d4                	je     801057f5 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105821:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105825:	75 07                	jne    8010582e <strncmp+0x3e>
    return 0;
80105827:	b8 00 00 00 00       	mov    $0x0,%eax
8010582c:	eb 16                	jmp    80105844 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010582e:	8b 45 08             	mov    0x8(%ebp),%eax
80105831:	0f b6 00             	movzbl (%eax),%eax
80105834:	0f b6 d0             	movzbl %al,%edx
80105837:	8b 45 0c             	mov    0xc(%ebp),%eax
8010583a:	0f b6 00             	movzbl (%eax),%eax
8010583d:	0f b6 c0             	movzbl %al,%eax
80105840:	29 c2                	sub    %eax,%edx
80105842:	89 d0                	mov    %edx,%eax
}
80105844:	5d                   	pop    %ebp
80105845:	c3                   	ret    

80105846 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105846:	55                   	push   %ebp
80105847:	89 e5                	mov    %esp,%ebp
80105849:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010584c:	8b 45 08             	mov    0x8(%ebp),%eax
8010584f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105852:	90                   	nop
80105853:	8b 45 10             	mov    0x10(%ebp),%eax
80105856:	8d 50 ff             	lea    -0x1(%eax),%edx
80105859:	89 55 10             	mov    %edx,0x10(%ebp)
8010585c:	85 c0                	test   %eax,%eax
8010585e:	7e 2c                	jle    8010588c <strncpy+0x46>
80105860:	8b 45 08             	mov    0x8(%ebp),%eax
80105863:	8d 50 01             	lea    0x1(%eax),%edx
80105866:	89 55 08             	mov    %edx,0x8(%ebp)
80105869:	8b 55 0c             	mov    0xc(%ebp),%edx
8010586c:	8d 4a 01             	lea    0x1(%edx),%ecx
8010586f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105872:	0f b6 12             	movzbl (%edx),%edx
80105875:	88 10                	mov    %dl,(%eax)
80105877:	0f b6 00             	movzbl (%eax),%eax
8010587a:	84 c0                	test   %al,%al
8010587c:	75 d5                	jne    80105853 <strncpy+0xd>
    ;
  while(n-- > 0)
8010587e:	eb 0c                	jmp    8010588c <strncpy+0x46>
    *s++ = 0;
80105880:	8b 45 08             	mov    0x8(%ebp),%eax
80105883:	8d 50 01             	lea    0x1(%eax),%edx
80105886:	89 55 08             	mov    %edx,0x8(%ebp)
80105889:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010588c:	8b 45 10             	mov    0x10(%ebp),%eax
8010588f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105892:	89 55 10             	mov    %edx,0x10(%ebp)
80105895:	85 c0                	test   %eax,%eax
80105897:	7f e7                	jg     80105880 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105899:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010589c:	c9                   	leave  
8010589d:	c3                   	ret    

8010589e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010589e:	55                   	push   %ebp
8010589f:	89 e5                	mov    %esp,%ebp
801058a1:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801058a4:	8b 45 08             	mov    0x8(%ebp),%eax
801058a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801058aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058ae:	7f 05                	jg     801058b5 <safestrcpy+0x17>
    return os;
801058b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058b3:	eb 31                	jmp    801058e6 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801058b5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801058b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058bd:	7e 1e                	jle    801058dd <safestrcpy+0x3f>
801058bf:	8b 45 08             	mov    0x8(%ebp),%eax
801058c2:	8d 50 01             	lea    0x1(%eax),%edx
801058c5:	89 55 08             	mov    %edx,0x8(%ebp)
801058c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801058cb:	8d 4a 01             	lea    0x1(%edx),%ecx
801058ce:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801058d1:	0f b6 12             	movzbl (%edx),%edx
801058d4:	88 10                	mov    %dl,(%eax)
801058d6:	0f b6 00             	movzbl (%eax),%eax
801058d9:	84 c0                	test   %al,%al
801058db:	75 d8                	jne    801058b5 <safestrcpy+0x17>
    ;
  *s = 0;
801058dd:	8b 45 08             	mov    0x8(%ebp),%eax
801058e0:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801058e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058e6:	c9                   	leave  
801058e7:	c3                   	ret    

801058e8 <strlen>:

int
strlen(const char *s)
{
801058e8:	55                   	push   %ebp
801058e9:	89 e5                	mov    %esp,%ebp
801058eb:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801058ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801058f5:	eb 04                	jmp    801058fb <strlen+0x13>
801058f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801058fb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105901:	01 d0                	add    %edx,%eax
80105903:	0f b6 00             	movzbl (%eax),%eax
80105906:	84 c0                	test   %al,%al
80105908:	75 ed                	jne    801058f7 <strlen+0xf>
    ;
  return n;
8010590a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010590d:	c9                   	leave  
8010590e:	c3                   	ret    

8010590f <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010590f:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105913:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105917:	55                   	push   %ebp
  pushl %ebx
80105918:	53                   	push   %ebx
  pushl %esi
80105919:	56                   	push   %esi
  pushl %edi
8010591a:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010591b:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010591d:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010591f:	5f                   	pop    %edi
  popl %esi
80105920:	5e                   	pop    %esi
  popl %ebx
80105921:	5b                   	pop    %ebx
  popl %ebp
80105922:	5d                   	pop    %ebp
  ret
80105923:	c3                   	ret    

80105924 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105924:	55                   	push   %ebp
80105925:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105927:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010592d:	8b 00                	mov    (%eax),%eax
8010592f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105932:	76 12                	jbe    80105946 <fetchint+0x22>
80105934:	8b 45 08             	mov    0x8(%ebp),%eax
80105937:	8d 50 04             	lea    0x4(%eax),%edx
8010593a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105940:	8b 00                	mov    (%eax),%eax
80105942:	39 c2                	cmp    %eax,%edx
80105944:	76 07                	jbe    8010594d <fetchint+0x29>
    return -1;
80105946:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594b:	eb 0f                	jmp    8010595c <fetchint+0x38>
  *ip = *(int*)(addr);
8010594d:	8b 45 08             	mov    0x8(%ebp),%eax
80105950:	8b 10                	mov    (%eax),%edx
80105952:	8b 45 0c             	mov    0xc(%ebp),%eax
80105955:	89 10                	mov    %edx,(%eax)
  return 0;
80105957:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010595c:	5d                   	pop    %ebp
8010595d:	c3                   	ret    

8010595e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010595e:	55                   	push   %ebp
8010595f:	89 e5                	mov    %esp,%ebp
80105961:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105964:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010596a:	8b 00                	mov    (%eax),%eax
8010596c:	3b 45 08             	cmp    0x8(%ebp),%eax
8010596f:	77 07                	ja     80105978 <fetchstr+0x1a>
    return -1;
80105971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105976:	eb 46                	jmp    801059be <fetchstr+0x60>
  *pp = (char*)addr;
80105978:	8b 55 08             	mov    0x8(%ebp),%edx
8010597b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010597e:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105980:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105986:	8b 00                	mov    (%eax),%eax
80105988:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010598b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010598e:	8b 00                	mov    (%eax),%eax
80105990:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105993:	eb 1c                	jmp    801059b1 <fetchstr+0x53>
    if(*s == 0)
80105995:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105998:	0f b6 00             	movzbl (%eax),%eax
8010599b:	84 c0                	test   %al,%al
8010599d:	75 0e                	jne    801059ad <fetchstr+0x4f>
      return s - *pp;
8010599f:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801059a5:	8b 00                	mov    (%eax),%eax
801059a7:	29 c2                	sub    %eax,%edx
801059a9:	89 d0                	mov    %edx,%eax
801059ab:	eb 11                	jmp    801059be <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801059ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059b4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801059b7:	72 dc                	jb     80105995 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801059b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059be:	c9                   	leave  
801059bf:	c3                   	ret    

801059c0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801059c0:	55                   	push   %ebp
801059c1:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801059c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059c9:	8b 40 18             	mov    0x18(%eax),%eax
801059cc:	8b 40 44             	mov    0x44(%eax),%eax
801059cf:	8b 55 08             	mov    0x8(%ebp),%edx
801059d2:	c1 e2 02             	shl    $0x2,%edx
801059d5:	01 d0                	add    %edx,%eax
801059d7:	83 c0 04             	add    $0x4,%eax
801059da:	ff 75 0c             	pushl  0xc(%ebp)
801059dd:	50                   	push   %eax
801059de:	e8 41 ff ff ff       	call   80105924 <fetchint>
801059e3:	83 c4 08             	add    $0x8,%esp
}
801059e6:	c9                   	leave  
801059e7:	c3                   	ret    

801059e8 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801059e8:	55                   	push   %ebp
801059e9:	89 e5                	mov    %esp,%ebp
801059eb:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
801059ee:	8d 45 fc             	lea    -0x4(%ebp),%eax
801059f1:	50                   	push   %eax
801059f2:	ff 75 08             	pushl  0x8(%ebp)
801059f5:	e8 c6 ff ff ff       	call   801059c0 <argint>
801059fa:	83 c4 08             	add    $0x8,%esp
801059fd:	85 c0                	test   %eax,%eax
801059ff:	79 07                	jns    80105a08 <argptr+0x20>
    return -1;
80105a01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a06:	eb 3b                	jmp    80105a43 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105a08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a0e:	8b 00                	mov    (%eax),%eax
80105a10:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a13:	39 d0                	cmp    %edx,%eax
80105a15:	76 16                	jbe    80105a2d <argptr+0x45>
80105a17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a1a:	89 c2                	mov    %eax,%edx
80105a1c:	8b 45 10             	mov    0x10(%ebp),%eax
80105a1f:	01 c2                	add    %eax,%edx
80105a21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a27:	8b 00                	mov    (%eax),%eax
80105a29:	39 c2                	cmp    %eax,%edx
80105a2b:	76 07                	jbe    80105a34 <argptr+0x4c>
    return -1;
80105a2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a32:	eb 0f                	jmp    80105a43 <argptr+0x5b>
  *pp = (char*)i;
80105a34:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a37:	89 c2                	mov    %eax,%edx
80105a39:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a3c:	89 10                	mov    %edx,(%eax)
  return 0;
80105a3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a43:	c9                   	leave  
80105a44:	c3                   	ret    

80105a45 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105a45:	55                   	push   %ebp
80105a46:	89 e5                	mov    %esp,%ebp
80105a48:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105a4b:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105a4e:	50                   	push   %eax
80105a4f:	ff 75 08             	pushl  0x8(%ebp)
80105a52:	e8 69 ff ff ff       	call   801059c0 <argint>
80105a57:	83 c4 08             	add    $0x8,%esp
80105a5a:	85 c0                	test   %eax,%eax
80105a5c:	79 07                	jns    80105a65 <argstr+0x20>
    return -1;
80105a5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a63:	eb 0f                	jmp    80105a74 <argstr+0x2f>
  return fetchstr(addr, pp);
80105a65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a68:	ff 75 0c             	pushl  0xc(%ebp)
80105a6b:	50                   	push   %eax
80105a6c:	e8 ed fe ff ff       	call   8010595e <fetchstr>
80105a71:	83 c4 08             	add    $0x8,%esp
}
80105a74:	c9                   	leave  
80105a75:	c3                   	ret    

80105a76 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105a76:	55                   	push   %ebp
80105a77:	89 e5                	mov    %esp,%ebp
80105a79:	53                   	push   %ebx
80105a7a:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105a7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a83:	8b 40 18             	mov    0x18(%eax),%eax
80105a86:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105a8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a90:	7e 30                	jle    80105ac2 <syscall+0x4c>
80105a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a95:	83 f8 15             	cmp    $0x15,%eax
80105a98:	77 28                	ja     80105ac2 <syscall+0x4c>
80105a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9d:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105aa4:	85 c0                	test   %eax,%eax
80105aa6:	74 1a                	je     80105ac2 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105aa8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105aae:	8b 58 18             	mov    0x18(%eax),%ebx
80105ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab4:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105abb:	ff d0                	call   *%eax
80105abd:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105ac0:	eb 34                	jmp    80105af6 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105ac2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ac8:	8d 50 6c             	lea    0x6c(%eax),%edx
80105acb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105ad1:	8b 40 10             	mov    0x10(%eax),%eax
80105ad4:	ff 75 f4             	pushl  -0xc(%ebp)
80105ad7:	52                   	push   %edx
80105ad8:	50                   	push   %eax
80105ad9:	68 9f 92 10 80       	push   $0x8010929f
80105ade:	e8 e3 a8 ff ff       	call   801003c6 <cprintf>
80105ae3:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105ae6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105aec:	8b 40 18             	mov    0x18(%eax),%eax
80105aef:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105af6:	90                   	nop
80105af7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105afa:	c9                   	leave  
80105afb:	c3                   	ret    

80105afc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105afc:	55                   	push   %ebp
80105afd:	89 e5                	mov    %esp,%ebp
80105aff:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105b02:	83 ec 08             	sub    $0x8,%esp
80105b05:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b08:	50                   	push   %eax
80105b09:	ff 75 08             	pushl  0x8(%ebp)
80105b0c:	e8 af fe ff ff       	call   801059c0 <argint>
80105b11:	83 c4 10             	add    $0x10,%esp
80105b14:	85 c0                	test   %eax,%eax
80105b16:	79 07                	jns    80105b1f <argfd+0x23>
    return -1;
80105b18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1d:	eb 50                	jmp    80105b6f <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b22:	85 c0                	test   %eax,%eax
80105b24:	78 21                	js     80105b47 <argfd+0x4b>
80105b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b29:	83 f8 0f             	cmp    $0xf,%eax
80105b2c:	7f 19                	jg     80105b47 <argfd+0x4b>
80105b2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b34:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b37:	83 c2 08             	add    $0x8,%edx
80105b3a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b45:	75 07                	jne    80105b4e <argfd+0x52>
    return -1;
80105b47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4c:	eb 21                	jmp    80105b6f <argfd+0x73>
  if(pfd)
80105b4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105b52:	74 08                	je     80105b5c <argfd+0x60>
    *pfd = fd;
80105b54:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b57:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b5a:	89 10                	mov    %edx,(%eax)
  if(pf)
80105b5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b60:	74 08                	je     80105b6a <argfd+0x6e>
    *pf = f;
80105b62:	8b 45 10             	mov    0x10(%ebp),%eax
80105b65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b68:	89 10                	mov    %edx,(%eax)
  return 0;
80105b6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b6f:	c9                   	leave  
80105b70:	c3                   	ret    

80105b71 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105b71:	55                   	push   %ebp
80105b72:	89 e5                	mov    %esp,%ebp
80105b74:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105b77:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105b7e:	eb 30                	jmp    80105bb0 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105b80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b86:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b89:	83 c2 08             	add    $0x8,%edx
80105b8c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b90:	85 c0                	test   %eax,%eax
80105b92:	75 18                	jne    80105bac <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105b94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b9a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b9d:	8d 4a 08             	lea    0x8(%edx),%ecx
80105ba0:	8b 55 08             	mov    0x8(%ebp),%edx
80105ba3:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105ba7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105baa:	eb 0f                	jmp    80105bbb <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105bac:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105bb0:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105bb4:	7e ca                	jle    80105b80 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105bb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bbb:	c9                   	leave  
80105bbc:	c3                   	ret    

80105bbd <sys_dup>:

int
sys_dup(void)
{
80105bbd:	55                   	push   %ebp
80105bbe:	89 e5                	mov    %esp,%ebp
80105bc0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105bc3:	83 ec 04             	sub    $0x4,%esp
80105bc6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bc9:	50                   	push   %eax
80105bca:	6a 00                	push   $0x0
80105bcc:	6a 00                	push   $0x0
80105bce:	e8 29 ff ff ff       	call   80105afc <argfd>
80105bd3:	83 c4 10             	add    $0x10,%esp
80105bd6:	85 c0                	test   %eax,%eax
80105bd8:	79 07                	jns    80105be1 <sys_dup+0x24>
    return -1;
80105bda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bdf:	eb 31                	jmp    80105c12 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be4:	83 ec 0c             	sub    $0xc,%esp
80105be7:	50                   	push   %eax
80105be8:	e8 84 ff ff ff       	call   80105b71 <fdalloc>
80105bed:	83 c4 10             	add    $0x10,%esp
80105bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bf3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bf7:	79 07                	jns    80105c00 <sys_dup+0x43>
    return -1;
80105bf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfe:	eb 12                	jmp    80105c12 <sys_dup+0x55>
  filedup(f);
80105c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c03:	83 ec 0c             	sub    $0xc,%esp
80105c06:	50                   	push   %eax
80105c07:	e8 f4 b3 ff ff       	call   80101000 <filedup>
80105c0c:	83 c4 10             	add    $0x10,%esp
  return fd;
80105c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c12:	c9                   	leave  
80105c13:	c3                   	ret    

80105c14 <sys_read>:

int
sys_read(void)
{
80105c14:	55                   	push   %ebp
80105c15:	89 e5                	mov    %esp,%ebp
80105c17:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c1a:	83 ec 04             	sub    $0x4,%esp
80105c1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c20:	50                   	push   %eax
80105c21:	6a 00                	push   $0x0
80105c23:	6a 00                	push   $0x0
80105c25:	e8 d2 fe ff ff       	call   80105afc <argfd>
80105c2a:	83 c4 10             	add    $0x10,%esp
80105c2d:	85 c0                	test   %eax,%eax
80105c2f:	78 2e                	js     80105c5f <sys_read+0x4b>
80105c31:	83 ec 08             	sub    $0x8,%esp
80105c34:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c37:	50                   	push   %eax
80105c38:	6a 02                	push   $0x2
80105c3a:	e8 81 fd ff ff       	call   801059c0 <argint>
80105c3f:	83 c4 10             	add    $0x10,%esp
80105c42:	85 c0                	test   %eax,%eax
80105c44:	78 19                	js     80105c5f <sys_read+0x4b>
80105c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c49:	83 ec 04             	sub    $0x4,%esp
80105c4c:	50                   	push   %eax
80105c4d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c50:	50                   	push   %eax
80105c51:	6a 01                	push   $0x1
80105c53:	e8 90 fd ff ff       	call   801059e8 <argptr>
80105c58:	83 c4 10             	add    $0x10,%esp
80105c5b:	85 c0                	test   %eax,%eax
80105c5d:	79 07                	jns    80105c66 <sys_read+0x52>
    return -1;
80105c5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c64:	eb 17                	jmp    80105c7d <sys_read+0x69>
  return fileread(f, p, n);
80105c66:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c69:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6f:	83 ec 04             	sub    $0x4,%esp
80105c72:	51                   	push   %ecx
80105c73:	52                   	push   %edx
80105c74:	50                   	push   %eax
80105c75:	e8 16 b5 ff ff       	call   80101190 <fileread>
80105c7a:	83 c4 10             	add    $0x10,%esp
}
80105c7d:	c9                   	leave  
80105c7e:	c3                   	ret    

80105c7f <sys_write>:

int
sys_write(void)
{
80105c7f:	55                   	push   %ebp
80105c80:	89 e5                	mov    %esp,%ebp
80105c82:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c85:	83 ec 04             	sub    $0x4,%esp
80105c88:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c8b:	50                   	push   %eax
80105c8c:	6a 00                	push   $0x0
80105c8e:	6a 00                	push   $0x0
80105c90:	e8 67 fe ff ff       	call   80105afc <argfd>
80105c95:	83 c4 10             	add    $0x10,%esp
80105c98:	85 c0                	test   %eax,%eax
80105c9a:	78 2e                	js     80105cca <sys_write+0x4b>
80105c9c:	83 ec 08             	sub    $0x8,%esp
80105c9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ca2:	50                   	push   %eax
80105ca3:	6a 02                	push   $0x2
80105ca5:	e8 16 fd ff ff       	call   801059c0 <argint>
80105caa:	83 c4 10             	add    $0x10,%esp
80105cad:	85 c0                	test   %eax,%eax
80105caf:	78 19                	js     80105cca <sys_write+0x4b>
80105cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb4:	83 ec 04             	sub    $0x4,%esp
80105cb7:	50                   	push   %eax
80105cb8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cbb:	50                   	push   %eax
80105cbc:	6a 01                	push   $0x1
80105cbe:	e8 25 fd ff ff       	call   801059e8 <argptr>
80105cc3:	83 c4 10             	add    $0x10,%esp
80105cc6:	85 c0                	test   %eax,%eax
80105cc8:	79 07                	jns    80105cd1 <sys_write+0x52>
    return -1;
80105cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccf:	eb 17                	jmp    80105ce8 <sys_write+0x69>
  return filewrite(f, p, n);
80105cd1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105cd4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cda:	83 ec 04             	sub    $0x4,%esp
80105cdd:	51                   	push   %ecx
80105cde:	52                   	push   %edx
80105cdf:	50                   	push   %eax
80105ce0:	e8 63 b5 ff ff       	call   80101248 <filewrite>
80105ce5:	83 c4 10             	add    $0x10,%esp
}
80105ce8:	c9                   	leave  
80105ce9:	c3                   	ret    

80105cea <sys_close>:

int
sys_close(void)
{
80105cea:	55                   	push   %ebp
80105ceb:	89 e5                	mov    %esp,%ebp
80105ced:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105cf0:	83 ec 04             	sub    $0x4,%esp
80105cf3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cf6:	50                   	push   %eax
80105cf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cfa:	50                   	push   %eax
80105cfb:	6a 00                	push   $0x0
80105cfd:	e8 fa fd ff ff       	call   80105afc <argfd>
80105d02:	83 c4 10             	add    $0x10,%esp
80105d05:	85 c0                	test   %eax,%eax
80105d07:	79 07                	jns    80105d10 <sys_close+0x26>
    return -1;
80105d09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0e:	eb 28                	jmp    80105d38 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105d10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d19:	83 c2 08             	add    $0x8,%edx
80105d1c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d23:	00 
  fileclose(f);
80105d24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d27:	83 ec 0c             	sub    $0xc,%esp
80105d2a:	50                   	push   %eax
80105d2b:	e8 21 b3 ff ff       	call   80101051 <fileclose>
80105d30:	83 c4 10             	add    $0x10,%esp
  return 0;
80105d33:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d38:	c9                   	leave  
80105d39:	c3                   	ret    

80105d3a <sys_fstat>:

int
sys_fstat(void)
{
80105d3a:	55                   	push   %ebp
80105d3b:	89 e5                	mov    %esp,%ebp
80105d3d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105d40:	83 ec 04             	sub    $0x4,%esp
80105d43:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d46:	50                   	push   %eax
80105d47:	6a 00                	push   $0x0
80105d49:	6a 00                	push   $0x0
80105d4b:	e8 ac fd ff ff       	call   80105afc <argfd>
80105d50:	83 c4 10             	add    $0x10,%esp
80105d53:	85 c0                	test   %eax,%eax
80105d55:	78 17                	js     80105d6e <sys_fstat+0x34>
80105d57:	83 ec 04             	sub    $0x4,%esp
80105d5a:	6a 14                	push   $0x14
80105d5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d5f:	50                   	push   %eax
80105d60:	6a 01                	push   $0x1
80105d62:	e8 81 fc ff ff       	call   801059e8 <argptr>
80105d67:	83 c4 10             	add    $0x10,%esp
80105d6a:	85 c0                	test   %eax,%eax
80105d6c:	79 07                	jns    80105d75 <sys_fstat+0x3b>
    return -1;
80105d6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d73:	eb 13                	jmp    80105d88 <sys_fstat+0x4e>
  return filestat(f, st);
80105d75:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7b:	83 ec 08             	sub    $0x8,%esp
80105d7e:	52                   	push   %edx
80105d7f:	50                   	push   %eax
80105d80:	e8 b4 b3 ff ff       	call   80101139 <filestat>
80105d85:	83 c4 10             	add    $0x10,%esp
}
80105d88:	c9                   	leave  
80105d89:	c3                   	ret    

80105d8a <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d8a:	55                   	push   %ebp
80105d8b:	89 e5                	mov    %esp,%ebp
80105d8d:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d90:	83 ec 08             	sub    $0x8,%esp
80105d93:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d96:	50                   	push   %eax
80105d97:	6a 00                	push   $0x0
80105d99:	e8 a7 fc ff ff       	call   80105a45 <argstr>
80105d9e:	83 c4 10             	add    $0x10,%esp
80105da1:	85 c0                	test   %eax,%eax
80105da3:	78 15                	js     80105dba <sys_link+0x30>
80105da5:	83 ec 08             	sub    $0x8,%esp
80105da8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105dab:	50                   	push   %eax
80105dac:	6a 01                	push   $0x1
80105dae:	e8 92 fc ff ff       	call   80105a45 <argstr>
80105db3:	83 c4 10             	add    $0x10,%esp
80105db6:	85 c0                	test   %eax,%eax
80105db8:	79 0a                	jns    80105dc4 <sys_link+0x3a>
    return -1;
80105dba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dbf:	e9 68 01 00 00       	jmp    80105f2c <sys_link+0x1a2>

  begin_op();
80105dc4:	e8 7e db ff ff       	call   80103947 <begin_op>
  if((ip = namei(old)) == 0){
80105dc9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105dcc:	83 ec 0c             	sub    $0xc,%esp
80105dcf:	50                   	push   %eax
80105dd0:	e8 53 c7 ff ff       	call   80102528 <namei>
80105dd5:	83 c4 10             	add    $0x10,%esp
80105dd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ddb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ddf:	75 0f                	jne    80105df0 <sys_link+0x66>
    end_op();
80105de1:	e8 ed db ff ff       	call   801039d3 <end_op>
    return -1;
80105de6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105deb:	e9 3c 01 00 00       	jmp    80105f2c <sys_link+0x1a2>
  }

  ilock(ip);
80105df0:	83 ec 0c             	sub    $0xc,%esp
80105df3:	ff 75 f4             	pushl  -0xc(%ebp)
80105df6:	e8 6f bb ff ff       	call   8010196a <ilock>
80105dfb:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e01:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e05:	66 83 f8 01          	cmp    $0x1,%ax
80105e09:	75 1d                	jne    80105e28 <sys_link+0x9e>
    iunlockput(ip);
80105e0b:	83 ec 0c             	sub    $0xc,%esp
80105e0e:	ff 75 f4             	pushl  -0xc(%ebp)
80105e11:	e8 14 be ff ff       	call   80101c2a <iunlockput>
80105e16:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e19:	e8 b5 db ff ff       	call   801039d3 <end_op>
    return -1;
80105e1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e23:	e9 04 01 00 00       	jmp    80105f2c <sys_link+0x1a2>
  }

  ip->nlink++;
80105e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e2f:	83 c0 01             	add    $0x1,%eax
80105e32:	89 c2                	mov    %eax,%edx
80105e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e37:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e3b:	83 ec 0c             	sub    $0xc,%esp
80105e3e:	ff 75 f4             	pushl  -0xc(%ebp)
80105e41:	e8 4a b9 ff ff       	call   80101790 <iupdate>
80105e46:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105e49:	83 ec 0c             	sub    $0xc,%esp
80105e4c:	ff 75 f4             	pushl  -0xc(%ebp)
80105e4f:	e8 74 bc ff ff       	call   80101ac8 <iunlock>
80105e54:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105e57:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e5a:	83 ec 08             	sub    $0x8,%esp
80105e5d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105e60:	52                   	push   %edx
80105e61:	50                   	push   %eax
80105e62:	e8 dd c6 ff ff       	call   80102544 <nameiparent>
80105e67:	83 c4 10             	add    $0x10,%esp
80105e6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e6d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e71:	74 71                	je     80105ee4 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105e73:	83 ec 0c             	sub    $0xc,%esp
80105e76:	ff 75 f0             	pushl  -0x10(%ebp)
80105e79:	e8 ec ba ff ff       	call   8010196a <ilock>
80105e7e:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e84:	8b 10                	mov    (%eax),%edx
80105e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e89:	8b 00                	mov    (%eax),%eax
80105e8b:	39 c2                	cmp    %eax,%edx
80105e8d:	75 1d                	jne    80105eac <sys_link+0x122>
80105e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e92:	8b 40 04             	mov    0x4(%eax),%eax
80105e95:	83 ec 04             	sub    $0x4,%esp
80105e98:	50                   	push   %eax
80105e99:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e9c:	50                   	push   %eax
80105e9d:	ff 75 f0             	pushl  -0x10(%ebp)
80105ea0:	e8 e7 c3 ff ff       	call   8010228c <dirlink>
80105ea5:	83 c4 10             	add    $0x10,%esp
80105ea8:	85 c0                	test   %eax,%eax
80105eaa:	79 10                	jns    80105ebc <sys_link+0x132>
    iunlockput(dp);
80105eac:	83 ec 0c             	sub    $0xc,%esp
80105eaf:	ff 75 f0             	pushl  -0x10(%ebp)
80105eb2:	e8 73 bd ff ff       	call   80101c2a <iunlockput>
80105eb7:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105eba:	eb 29                	jmp    80105ee5 <sys_link+0x15b>
  }
  iunlockput(dp);
80105ebc:	83 ec 0c             	sub    $0xc,%esp
80105ebf:	ff 75 f0             	pushl  -0x10(%ebp)
80105ec2:	e8 63 bd ff ff       	call   80101c2a <iunlockput>
80105ec7:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105eca:	83 ec 0c             	sub    $0xc,%esp
80105ecd:	ff 75 f4             	pushl  -0xc(%ebp)
80105ed0:	e8 65 bc ff ff       	call   80101b3a <iput>
80105ed5:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ed8:	e8 f6 da ff ff       	call   801039d3 <end_op>

  return 0;
80105edd:	b8 00 00 00 00       	mov    $0x0,%eax
80105ee2:	eb 48                	jmp    80105f2c <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105ee4:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105ee5:	83 ec 0c             	sub    $0xc,%esp
80105ee8:	ff 75 f4             	pushl  -0xc(%ebp)
80105eeb:	e8 7a ba ff ff       	call   8010196a <ilock>
80105ef0:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105efa:	83 e8 01             	sub    $0x1,%eax
80105efd:	89 c2                	mov    %eax,%edx
80105eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f02:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f06:	83 ec 0c             	sub    $0xc,%esp
80105f09:	ff 75 f4             	pushl  -0xc(%ebp)
80105f0c:	e8 7f b8 ff ff       	call   80101790 <iupdate>
80105f11:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105f14:	83 ec 0c             	sub    $0xc,%esp
80105f17:	ff 75 f4             	pushl  -0xc(%ebp)
80105f1a:	e8 0b bd ff ff       	call   80101c2a <iunlockput>
80105f1f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f22:	e8 ac da ff ff       	call   801039d3 <end_op>
  return -1;
80105f27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f2c:	c9                   	leave  
80105f2d:	c3                   	ret    

80105f2e <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
int
isdirempty(struct inode *dp)
{
80105f2e:	55                   	push   %ebp
80105f2f:	89 e5                	mov    %esp,%ebp
80105f31:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f34:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105f3b:	eb 40                	jmp    80105f7d <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f40:	6a 10                	push   $0x10
80105f42:	50                   	push   %eax
80105f43:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f46:	50                   	push   %eax
80105f47:	ff 75 08             	pushl  0x8(%ebp)
80105f4a:	e8 89 bf ff ff       	call   80101ed8 <readi>
80105f4f:	83 c4 10             	add    $0x10,%esp
80105f52:	83 f8 10             	cmp    $0x10,%eax
80105f55:	74 0d                	je     80105f64 <isdirempty+0x36>
      panic("isdirempty: readi");
80105f57:	83 ec 0c             	sub    $0xc,%esp
80105f5a:	68 bb 92 10 80       	push   $0x801092bb
80105f5f:	e8 02 a6 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80105f64:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105f68:	66 85 c0             	test   %ax,%ax
80105f6b:	74 07                	je     80105f74 <isdirempty+0x46>
      return 0;
80105f6d:	b8 00 00 00 00       	mov    $0x0,%eax
80105f72:	eb 1b                	jmp    80105f8f <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f77:	83 c0 10             	add    $0x10,%eax
80105f7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f80:	8b 50 18             	mov    0x18(%eax),%edx
80105f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f86:	39 c2                	cmp    %eax,%edx
80105f88:	77 b3                	ja     80105f3d <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105f8a:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f8f:	c9                   	leave  
80105f90:	c3                   	ret    

80105f91 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f91:	55                   	push   %ebp
80105f92:	89 e5                	mov    %esp,%ebp
80105f94:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f97:	83 ec 08             	sub    $0x8,%esp
80105f9a:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f9d:	50                   	push   %eax
80105f9e:	6a 00                	push   $0x0
80105fa0:	e8 a0 fa ff ff       	call   80105a45 <argstr>
80105fa5:	83 c4 10             	add    $0x10,%esp
80105fa8:	85 c0                	test   %eax,%eax
80105faa:	79 0a                	jns    80105fb6 <sys_unlink+0x25>
    return -1;
80105fac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb1:	e9 bc 01 00 00       	jmp    80106172 <sys_unlink+0x1e1>

  begin_op();
80105fb6:	e8 8c d9 ff ff       	call   80103947 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105fbb:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105fbe:	83 ec 08             	sub    $0x8,%esp
80105fc1:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105fc4:	52                   	push   %edx
80105fc5:	50                   	push   %eax
80105fc6:	e8 79 c5 ff ff       	call   80102544 <nameiparent>
80105fcb:	83 c4 10             	add    $0x10,%esp
80105fce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fd5:	75 0f                	jne    80105fe6 <sys_unlink+0x55>
    end_op();
80105fd7:	e8 f7 d9 ff ff       	call   801039d3 <end_op>
    return -1;
80105fdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe1:	e9 8c 01 00 00       	jmp    80106172 <sys_unlink+0x1e1>
  }

  ilock(dp);
80105fe6:	83 ec 0c             	sub    $0xc,%esp
80105fe9:	ff 75 f4             	pushl  -0xc(%ebp)
80105fec:	e8 79 b9 ff ff       	call   8010196a <ilock>
80105ff1:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105ff4:	83 ec 08             	sub    $0x8,%esp
80105ff7:	68 cd 92 10 80       	push   $0x801092cd
80105ffc:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fff:	50                   	push   %eax
80106000:	e8 b2 c1 ff ff       	call   801021b7 <namecmp>
80106005:	83 c4 10             	add    $0x10,%esp
80106008:	85 c0                	test   %eax,%eax
8010600a:	0f 84 4a 01 00 00    	je     8010615a <sys_unlink+0x1c9>
80106010:	83 ec 08             	sub    $0x8,%esp
80106013:	68 cf 92 10 80       	push   $0x801092cf
80106018:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010601b:	50                   	push   %eax
8010601c:	e8 96 c1 ff ff       	call   801021b7 <namecmp>
80106021:	83 c4 10             	add    $0x10,%esp
80106024:	85 c0                	test   %eax,%eax
80106026:	0f 84 2e 01 00 00    	je     8010615a <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010602c:	83 ec 04             	sub    $0x4,%esp
8010602f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106032:	50                   	push   %eax
80106033:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106036:	50                   	push   %eax
80106037:	ff 75 f4             	pushl  -0xc(%ebp)
8010603a:	e8 93 c1 ff ff       	call   801021d2 <dirlookup>
8010603f:	83 c4 10             	add    $0x10,%esp
80106042:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106045:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106049:	0f 84 0a 01 00 00    	je     80106159 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
8010604f:	83 ec 0c             	sub    $0xc,%esp
80106052:	ff 75 f0             	pushl  -0x10(%ebp)
80106055:	e8 10 b9 ff ff       	call   8010196a <ilock>
8010605a:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010605d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106060:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106064:	66 85 c0             	test   %ax,%ax
80106067:	7f 0d                	jg     80106076 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106069:	83 ec 0c             	sub    $0xc,%esp
8010606c:	68 d2 92 10 80       	push   $0x801092d2
80106071:	e8 f0 a4 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106076:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106079:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010607d:	66 83 f8 01          	cmp    $0x1,%ax
80106081:	75 25                	jne    801060a8 <sys_unlink+0x117>
80106083:	83 ec 0c             	sub    $0xc,%esp
80106086:	ff 75 f0             	pushl  -0x10(%ebp)
80106089:	e8 a0 fe ff ff       	call   80105f2e <isdirempty>
8010608e:	83 c4 10             	add    $0x10,%esp
80106091:	85 c0                	test   %eax,%eax
80106093:	75 13                	jne    801060a8 <sys_unlink+0x117>
    iunlockput(ip);
80106095:	83 ec 0c             	sub    $0xc,%esp
80106098:	ff 75 f0             	pushl  -0x10(%ebp)
8010609b:	e8 8a bb ff ff       	call   80101c2a <iunlockput>
801060a0:	83 c4 10             	add    $0x10,%esp
    goto bad;
801060a3:	e9 b2 00 00 00       	jmp    8010615a <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
801060a8:	83 ec 04             	sub    $0x4,%esp
801060ab:	6a 10                	push   $0x10
801060ad:	6a 00                	push   $0x0
801060af:	8d 45 e0             	lea    -0x20(%ebp),%eax
801060b2:	50                   	push   %eax
801060b3:	e8 e3 f5 ff ff       	call   8010569b <memset>
801060b8:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801060bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
801060be:	6a 10                	push   $0x10
801060c0:	50                   	push   %eax
801060c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801060c4:	50                   	push   %eax
801060c5:	ff 75 f4             	pushl  -0xc(%ebp)
801060c8:	e8 62 bf ff ff       	call   8010202f <writei>
801060cd:	83 c4 10             	add    $0x10,%esp
801060d0:	83 f8 10             	cmp    $0x10,%eax
801060d3:	74 0d                	je     801060e2 <sys_unlink+0x151>
    panic("unlink: writei");
801060d5:	83 ec 0c             	sub    $0xc,%esp
801060d8:	68 e4 92 10 80       	push   $0x801092e4
801060dd:	e8 84 a4 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801060e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060e9:	66 83 f8 01          	cmp    $0x1,%ax
801060ed:	75 21                	jne    80106110 <sys_unlink+0x17f>
    dp->nlink--;
801060ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060f6:	83 e8 01             	sub    $0x1,%eax
801060f9:	89 c2                	mov    %eax,%edx
801060fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fe:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106102:	83 ec 0c             	sub    $0xc,%esp
80106105:	ff 75 f4             	pushl  -0xc(%ebp)
80106108:	e8 83 b6 ff ff       	call   80101790 <iupdate>
8010610d:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106110:	83 ec 0c             	sub    $0xc,%esp
80106113:	ff 75 f4             	pushl  -0xc(%ebp)
80106116:	e8 0f bb ff ff       	call   80101c2a <iunlockput>
8010611b:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010611e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106121:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106125:	83 e8 01             	sub    $0x1,%eax
80106128:	89 c2                	mov    %eax,%edx
8010612a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010612d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106131:	83 ec 0c             	sub    $0xc,%esp
80106134:	ff 75 f0             	pushl  -0x10(%ebp)
80106137:	e8 54 b6 ff ff       	call   80101790 <iupdate>
8010613c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010613f:	83 ec 0c             	sub    $0xc,%esp
80106142:	ff 75 f0             	pushl  -0x10(%ebp)
80106145:	e8 e0 ba ff ff       	call   80101c2a <iunlockput>
8010614a:	83 c4 10             	add    $0x10,%esp

  end_op();
8010614d:	e8 81 d8 ff ff       	call   801039d3 <end_op>

  return 0;
80106152:	b8 00 00 00 00       	mov    $0x0,%eax
80106157:	eb 19                	jmp    80106172 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106159:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
8010615a:	83 ec 0c             	sub    $0xc,%esp
8010615d:	ff 75 f4             	pushl  -0xc(%ebp)
80106160:	e8 c5 ba ff ff       	call   80101c2a <iunlockput>
80106165:	83 c4 10             	add    $0x10,%esp
  end_op();
80106168:	e8 66 d8 ff ff       	call   801039d3 <end_op>
  return -1;
8010616d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106172:	c9                   	leave  
80106173:	c3                   	ret    

80106174 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
80106174:	55                   	push   %ebp
80106175:	89 e5                	mov    %esp,%ebp
80106177:	83 ec 38             	sub    $0x38,%esp
8010617a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010617d:	8b 55 10             	mov    0x10(%ebp),%edx
80106180:	8b 45 14             	mov    0x14(%ebp),%eax
80106183:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106187:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010618b:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010618f:	83 ec 08             	sub    $0x8,%esp
80106192:	8d 45 de             	lea    -0x22(%ebp),%eax
80106195:	50                   	push   %eax
80106196:	ff 75 08             	pushl  0x8(%ebp)
80106199:	e8 a6 c3 ff ff       	call   80102544 <nameiparent>
8010619e:	83 c4 10             	add    $0x10,%esp
801061a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061a8:	75 0a                	jne    801061b4 <create+0x40>
    return 0;
801061aa:	b8 00 00 00 00       	mov    $0x0,%eax
801061af:	e9 90 01 00 00       	jmp    80106344 <create+0x1d0>
  ilock(dp);
801061b4:	83 ec 0c             	sub    $0xc,%esp
801061b7:	ff 75 f4             	pushl  -0xc(%ebp)
801061ba:	e8 ab b7 ff ff       	call   8010196a <ilock>
801061bf:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801061c2:	83 ec 04             	sub    $0x4,%esp
801061c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061c8:	50                   	push   %eax
801061c9:	8d 45 de             	lea    -0x22(%ebp),%eax
801061cc:	50                   	push   %eax
801061cd:	ff 75 f4             	pushl  -0xc(%ebp)
801061d0:	e8 fd bf ff ff       	call   801021d2 <dirlookup>
801061d5:	83 c4 10             	add    $0x10,%esp
801061d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061df:	74 50                	je     80106231 <create+0xbd>
    iunlockput(dp);
801061e1:	83 ec 0c             	sub    $0xc,%esp
801061e4:	ff 75 f4             	pushl  -0xc(%ebp)
801061e7:	e8 3e ba ff ff       	call   80101c2a <iunlockput>
801061ec:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801061ef:	83 ec 0c             	sub    $0xc,%esp
801061f2:	ff 75 f0             	pushl  -0x10(%ebp)
801061f5:	e8 70 b7 ff ff       	call   8010196a <ilock>
801061fa:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801061fd:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106202:	75 15                	jne    80106219 <create+0xa5>
80106204:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106207:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010620b:	66 83 f8 02          	cmp    $0x2,%ax
8010620f:	75 08                	jne    80106219 <create+0xa5>
      return ip;
80106211:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106214:	e9 2b 01 00 00       	jmp    80106344 <create+0x1d0>
    iunlockput(ip);
80106219:	83 ec 0c             	sub    $0xc,%esp
8010621c:	ff 75 f0             	pushl  -0x10(%ebp)
8010621f:	e8 06 ba ff ff       	call   80101c2a <iunlockput>
80106224:	83 c4 10             	add    $0x10,%esp
    return 0;
80106227:	b8 00 00 00 00       	mov    $0x0,%eax
8010622c:	e9 13 01 00 00       	jmp    80106344 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106231:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106238:	8b 00                	mov    (%eax),%eax
8010623a:	83 ec 08             	sub    $0x8,%esp
8010623d:	52                   	push   %edx
8010623e:	50                   	push   %eax
8010623f:	e8 75 b4 ff ff       	call   801016b9 <ialloc>
80106244:	83 c4 10             	add    $0x10,%esp
80106247:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010624a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010624e:	75 0d                	jne    8010625d <create+0xe9>
    panic("create: ialloc");
80106250:	83 ec 0c             	sub    $0xc,%esp
80106253:	68 f3 92 10 80       	push   $0x801092f3
80106258:	e8 09 a3 ff ff       	call   80100566 <panic>

  ilock(ip);
8010625d:	83 ec 0c             	sub    $0xc,%esp
80106260:	ff 75 f0             	pushl  -0x10(%ebp)
80106263:	e8 02 b7 ff ff       	call   8010196a <ilock>
80106268:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010626b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626e:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106272:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106276:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106279:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010627d:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106281:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106284:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010628a:	83 ec 0c             	sub    $0xc,%esp
8010628d:	ff 75 f0             	pushl  -0x10(%ebp)
80106290:	e8 fb b4 ff ff       	call   80101790 <iupdate>
80106295:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106298:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010629d:	75 6a                	jne    80106309 <create+0x195>
    dp->nlink++;  // for ".."
8010629f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801062a6:	83 c0 01             	add    $0x1,%eax
801062a9:	89 c2                	mov    %eax,%edx
801062ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ae:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801062b2:	83 ec 0c             	sub    $0xc,%esp
801062b5:	ff 75 f4             	pushl  -0xc(%ebp)
801062b8:	e8 d3 b4 ff ff       	call   80101790 <iupdate>
801062bd:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801062c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c3:	8b 40 04             	mov    0x4(%eax),%eax
801062c6:	83 ec 04             	sub    $0x4,%esp
801062c9:	50                   	push   %eax
801062ca:	68 cd 92 10 80       	push   $0x801092cd
801062cf:	ff 75 f0             	pushl  -0x10(%ebp)
801062d2:	e8 b5 bf ff ff       	call   8010228c <dirlink>
801062d7:	83 c4 10             	add    $0x10,%esp
801062da:	85 c0                	test   %eax,%eax
801062dc:	78 1e                	js     801062fc <create+0x188>
801062de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e1:	8b 40 04             	mov    0x4(%eax),%eax
801062e4:	83 ec 04             	sub    $0x4,%esp
801062e7:	50                   	push   %eax
801062e8:	68 cf 92 10 80       	push   $0x801092cf
801062ed:	ff 75 f0             	pushl  -0x10(%ebp)
801062f0:	e8 97 bf ff ff       	call   8010228c <dirlink>
801062f5:	83 c4 10             	add    $0x10,%esp
801062f8:	85 c0                	test   %eax,%eax
801062fa:	79 0d                	jns    80106309 <create+0x195>
      panic("create dots");
801062fc:	83 ec 0c             	sub    $0xc,%esp
801062ff:	68 02 93 10 80       	push   $0x80109302
80106304:	e8 5d a2 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010630c:	8b 40 04             	mov    0x4(%eax),%eax
8010630f:	83 ec 04             	sub    $0x4,%esp
80106312:	50                   	push   %eax
80106313:	8d 45 de             	lea    -0x22(%ebp),%eax
80106316:	50                   	push   %eax
80106317:	ff 75 f4             	pushl  -0xc(%ebp)
8010631a:	e8 6d bf ff ff       	call   8010228c <dirlink>
8010631f:	83 c4 10             	add    $0x10,%esp
80106322:	85 c0                	test   %eax,%eax
80106324:	79 0d                	jns    80106333 <create+0x1bf>
    panic("create: dirlink");
80106326:	83 ec 0c             	sub    $0xc,%esp
80106329:	68 0e 93 10 80       	push   $0x8010930e
8010632e:	e8 33 a2 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106333:	83 ec 0c             	sub    $0xc,%esp
80106336:	ff 75 f4             	pushl  -0xc(%ebp)
80106339:	e8 ec b8 ff ff       	call   80101c2a <iunlockput>
8010633e:	83 c4 10             	add    $0x10,%esp

  return ip;
80106341:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106344:	c9                   	leave  
80106345:	c3                   	ret    

80106346 <sys_open>:

int
sys_open(void)
{
80106346:	55                   	push   %ebp
80106347:	89 e5                	mov    %esp,%ebp
80106349:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010634c:	83 ec 08             	sub    $0x8,%esp
8010634f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106352:	50                   	push   %eax
80106353:	6a 00                	push   $0x0
80106355:	e8 eb f6 ff ff       	call   80105a45 <argstr>
8010635a:	83 c4 10             	add    $0x10,%esp
8010635d:	85 c0                	test   %eax,%eax
8010635f:	78 15                	js     80106376 <sys_open+0x30>
80106361:	83 ec 08             	sub    $0x8,%esp
80106364:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106367:	50                   	push   %eax
80106368:	6a 01                	push   $0x1
8010636a:	e8 51 f6 ff ff       	call   801059c0 <argint>
8010636f:	83 c4 10             	add    $0x10,%esp
80106372:	85 c0                	test   %eax,%eax
80106374:	79 0a                	jns    80106380 <sys_open+0x3a>
    return -1;
80106376:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637b:	e9 61 01 00 00       	jmp    801064e1 <sys_open+0x19b>

  begin_op();
80106380:	e8 c2 d5 ff ff       	call   80103947 <begin_op>

  if(omode & O_CREATE){
80106385:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106388:	25 00 02 00 00       	and    $0x200,%eax
8010638d:	85 c0                	test   %eax,%eax
8010638f:	74 2a                	je     801063bb <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106391:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106394:	6a 00                	push   $0x0
80106396:	6a 00                	push   $0x0
80106398:	6a 02                	push   $0x2
8010639a:	50                   	push   %eax
8010639b:	e8 d4 fd ff ff       	call   80106174 <create>
801063a0:	83 c4 10             	add    $0x10,%esp
801063a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801063a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063aa:	75 75                	jne    80106421 <sys_open+0xdb>
      end_op();
801063ac:	e8 22 d6 ff ff       	call   801039d3 <end_op>
      return -1;
801063b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b6:	e9 26 01 00 00       	jmp    801064e1 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801063bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063be:	83 ec 0c             	sub    $0xc,%esp
801063c1:	50                   	push   %eax
801063c2:	e8 61 c1 ff ff       	call   80102528 <namei>
801063c7:	83 c4 10             	add    $0x10,%esp
801063ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063d1:	75 0f                	jne    801063e2 <sys_open+0x9c>
      end_op();
801063d3:	e8 fb d5 ff ff       	call   801039d3 <end_op>
      return -1;
801063d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063dd:	e9 ff 00 00 00       	jmp    801064e1 <sys_open+0x19b>
    }
    ilock(ip);
801063e2:	83 ec 0c             	sub    $0xc,%esp
801063e5:	ff 75 f4             	pushl  -0xc(%ebp)
801063e8:	e8 7d b5 ff ff       	call   8010196a <ilock>
801063ed:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801063f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801063f7:	66 83 f8 01          	cmp    $0x1,%ax
801063fb:	75 24                	jne    80106421 <sys_open+0xdb>
801063fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106400:	85 c0                	test   %eax,%eax
80106402:	74 1d                	je     80106421 <sys_open+0xdb>
      iunlockput(ip);
80106404:	83 ec 0c             	sub    $0xc,%esp
80106407:	ff 75 f4             	pushl  -0xc(%ebp)
8010640a:	e8 1b b8 ff ff       	call   80101c2a <iunlockput>
8010640f:	83 c4 10             	add    $0x10,%esp
      end_op();
80106412:	e8 bc d5 ff ff       	call   801039d3 <end_op>
      return -1;
80106417:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641c:	e9 c0 00 00 00       	jmp    801064e1 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106421:	e8 6d ab ff ff       	call   80100f93 <filealloc>
80106426:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106429:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010642d:	74 17                	je     80106446 <sys_open+0x100>
8010642f:	83 ec 0c             	sub    $0xc,%esp
80106432:	ff 75 f0             	pushl  -0x10(%ebp)
80106435:	e8 37 f7 ff ff       	call   80105b71 <fdalloc>
8010643a:	83 c4 10             	add    $0x10,%esp
8010643d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106440:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106444:	79 2e                	jns    80106474 <sys_open+0x12e>
    if(f)
80106446:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010644a:	74 0e                	je     8010645a <sys_open+0x114>
      fileclose(f);
8010644c:	83 ec 0c             	sub    $0xc,%esp
8010644f:	ff 75 f0             	pushl  -0x10(%ebp)
80106452:	e8 fa ab ff ff       	call   80101051 <fileclose>
80106457:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010645a:	83 ec 0c             	sub    $0xc,%esp
8010645d:	ff 75 f4             	pushl  -0xc(%ebp)
80106460:	e8 c5 b7 ff ff       	call   80101c2a <iunlockput>
80106465:	83 c4 10             	add    $0x10,%esp
    end_op();
80106468:	e8 66 d5 ff ff       	call   801039d3 <end_op>
    return -1;
8010646d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106472:	eb 6d                	jmp    801064e1 <sys_open+0x19b>
  }
  iunlock(ip);
80106474:	83 ec 0c             	sub    $0xc,%esp
80106477:	ff 75 f4             	pushl  -0xc(%ebp)
8010647a:	e8 49 b6 ff ff       	call   80101ac8 <iunlock>
8010647f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106482:	e8 4c d5 ff ff       	call   801039d3 <end_op>

  f->type = FD_INODE;
80106487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010648a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106490:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106493:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106496:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106499:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010649c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801064a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064a6:	83 e0 01             	and    $0x1,%eax
801064a9:	85 c0                	test   %eax,%eax
801064ab:	0f 94 c0             	sete   %al
801064ae:	89 c2                	mov    %eax,%edx
801064b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b3:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801064b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064b9:	83 e0 01             	and    $0x1,%eax
801064bc:	85 c0                	test   %eax,%eax
801064be:	75 0a                	jne    801064ca <sys_open+0x184>
801064c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064c3:	83 e0 02             	and    $0x2,%eax
801064c6:	85 c0                	test   %eax,%eax
801064c8:	74 07                	je     801064d1 <sys_open+0x18b>
801064ca:	b8 01 00 00 00       	mov    $0x1,%eax
801064cf:	eb 05                	jmp    801064d6 <sys_open+0x190>
801064d1:	b8 00 00 00 00       	mov    $0x0,%eax
801064d6:	89 c2                	mov    %eax,%edx
801064d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064db:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801064de:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801064e1:	c9                   	leave  
801064e2:	c3                   	ret    

801064e3 <sys_mkdir>:

int
sys_mkdir(void)
{
801064e3:	55                   	push   %ebp
801064e4:	89 e5                	mov    %esp,%ebp
801064e6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801064e9:	e8 59 d4 ff ff       	call   80103947 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801064ee:	83 ec 08             	sub    $0x8,%esp
801064f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064f4:	50                   	push   %eax
801064f5:	6a 00                	push   $0x0
801064f7:	e8 49 f5 ff ff       	call   80105a45 <argstr>
801064fc:	83 c4 10             	add    $0x10,%esp
801064ff:	85 c0                	test   %eax,%eax
80106501:	78 1b                	js     8010651e <sys_mkdir+0x3b>
80106503:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106506:	6a 00                	push   $0x0
80106508:	6a 00                	push   $0x0
8010650a:	6a 01                	push   $0x1
8010650c:	50                   	push   %eax
8010650d:	e8 62 fc ff ff       	call   80106174 <create>
80106512:	83 c4 10             	add    $0x10,%esp
80106515:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106518:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010651c:	75 0c                	jne    8010652a <sys_mkdir+0x47>
    end_op();
8010651e:	e8 b0 d4 ff ff       	call   801039d3 <end_op>
    return -1;
80106523:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106528:	eb 18                	jmp    80106542 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010652a:	83 ec 0c             	sub    $0xc,%esp
8010652d:	ff 75 f4             	pushl  -0xc(%ebp)
80106530:	e8 f5 b6 ff ff       	call   80101c2a <iunlockput>
80106535:	83 c4 10             	add    $0x10,%esp
  end_op();
80106538:	e8 96 d4 ff ff       	call   801039d3 <end_op>
  return 0;
8010653d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106542:	c9                   	leave  
80106543:	c3                   	ret    

80106544 <sys_mknod>:

int
sys_mknod(void)
{
80106544:	55                   	push   %ebp
80106545:	89 e5                	mov    %esp,%ebp
80106547:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010654a:	e8 f8 d3 ff ff       	call   80103947 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010654f:	83 ec 08             	sub    $0x8,%esp
80106552:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106555:	50                   	push   %eax
80106556:	6a 00                	push   $0x0
80106558:	e8 e8 f4 ff ff       	call   80105a45 <argstr>
8010655d:	83 c4 10             	add    $0x10,%esp
80106560:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106563:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106567:	78 4f                	js     801065b8 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106569:	83 ec 08             	sub    $0x8,%esp
8010656c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010656f:	50                   	push   %eax
80106570:	6a 01                	push   $0x1
80106572:	e8 49 f4 ff ff       	call   801059c0 <argint>
80106577:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010657a:	85 c0                	test   %eax,%eax
8010657c:	78 3a                	js     801065b8 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010657e:	83 ec 08             	sub    $0x8,%esp
80106581:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106584:	50                   	push   %eax
80106585:	6a 02                	push   $0x2
80106587:	e8 34 f4 ff ff       	call   801059c0 <argint>
8010658c:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010658f:	85 c0                	test   %eax,%eax
80106591:	78 25                	js     801065b8 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106593:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106596:	0f bf c8             	movswl %ax,%ecx
80106599:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010659c:	0f bf d0             	movswl %ax,%edx
8010659f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801065a2:	51                   	push   %ecx
801065a3:	52                   	push   %edx
801065a4:	6a 03                	push   $0x3
801065a6:	50                   	push   %eax
801065a7:	e8 c8 fb ff ff       	call   80106174 <create>
801065ac:	83 c4 10             	add    $0x10,%esp
801065af:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065b6:	75 0c                	jne    801065c4 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801065b8:	e8 16 d4 ff ff       	call   801039d3 <end_op>
    return -1;
801065bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c2:	eb 18                	jmp    801065dc <sys_mknod+0x98>
  }
  iunlockput(ip);
801065c4:	83 ec 0c             	sub    $0xc,%esp
801065c7:	ff 75 f0             	pushl  -0x10(%ebp)
801065ca:	e8 5b b6 ff ff       	call   80101c2a <iunlockput>
801065cf:	83 c4 10             	add    $0x10,%esp
  end_op();
801065d2:	e8 fc d3 ff ff       	call   801039d3 <end_op>
  return 0;
801065d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065dc:	c9                   	leave  
801065dd:	c3                   	ret    

801065de <sys_chdir>:

int
sys_chdir(void)
{
801065de:	55                   	push   %ebp
801065df:	89 e5                	mov    %esp,%ebp
801065e1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801065e4:	e8 5e d3 ff ff       	call   80103947 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801065e9:	83 ec 08             	sub    $0x8,%esp
801065ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065ef:	50                   	push   %eax
801065f0:	6a 00                	push   $0x0
801065f2:	e8 4e f4 ff ff       	call   80105a45 <argstr>
801065f7:	83 c4 10             	add    $0x10,%esp
801065fa:	85 c0                	test   %eax,%eax
801065fc:	78 18                	js     80106616 <sys_chdir+0x38>
801065fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106601:	83 ec 0c             	sub    $0xc,%esp
80106604:	50                   	push   %eax
80106605:	e8 1e bf ff ff       	call   80102528 <namei>
8010660a:	83 c4 10             	add    $0x10,%esp
8010660d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106610:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106614:	75 0c                	jne    80106622 <sys_chdir+0x44>
    end_op();
80106616:	e8 b8 d3 ff ff       	call   801039d3 <end_op>
    return -1;
8010661b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106620:	eb 6e                	jmp    80106690 <sys_chdir+0xb2>
  }
  ilock(ip);
80106622:	83 ec 0c             	sub    $0xc,%esp
80106625:	ff 75 f4             	pushl  -0xc(%ebp)
80106628:	e8 3d b3 ff ff       	call   8010196a <ilock>
8010662d:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106633:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106637:	66 83 f8 01          	cmp    $0x1,%ax
8010663b:	74 1a                	je     80106657 <sys_chdir+0x79>
    iunlockput(ip);
8010663d:	83 ec 0c             	sub    $0xc,%esp
80106640:	ff 75 f4             	pushl  -0xc(%ebp)
80106643:	e8 e2 b5 ff ff       	call   80101c2a <iunlockput>
80106648:	83 c4 10             	add    $0x10,%esp
    end_op();
8010664b:	e8 83 d3 ff ff       	call   801039d3 <end_op>
    return -1;
80106650:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106655:	eb 39                	jmp    80106690 <sys_chdir+0xb2>
  }
  iunlock(ip);
80106657:	83 ec 0c             	sub    $0xc,%esp
8010665a:	ff 75 f4             	pushl  -0xc(%ebp)
8010665d:	e8 66 b4 ff ff       	call   80101ac8 <iunlock>
80106662:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106665:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010666b:	8b 40 68             	mov    0x68(%eax),%eax
8010666e:	83 ec 0c             	sub    $0xc,%esp
80106671:	50                   	push   %eax
80106672:	e8 c3 b4 ff ff       	call   80101b3a <iput>
80106677:	83 c4 10             	add    $0x10,%esp
  end_op();
8010667a:	e8 54 d3 ff ff       	call   801039d3 <end_op>
  proc->cwd = ip;
8010667f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106685:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106688:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010668b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106690:	c9                   	leave  
80106691:	c3                   	ret    

80106692 <sys_exec>:

int
sys_exec(void)
{
80106692:	55                   	push   %ebp
80106693:	89 e5                	mov    %esp,%ebp
80106695:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010669b:	83 ec 08             	sub    $0x8,%esp
8010669e:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066a1:	50                   	push   %eax
801066a2:	6a 00                	push   $0x0
801066a4:	e8 9c f3 ff ff       	call   80105a45 <argstr>
801066a9:	83 c4 10             	add    $0x10,%esp
801066ac:	85 c0                	test   %eax,%eax
801066ae:	78 18                	js     801066c8 <sys_exec+0x36>
801066b0:	83 ec 08             	sub    $0x8,%esp
801066b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801066b9:	50                   	push   %eax
801066ba:	6a 01                	push   $0x1
801066bc:	e8 ff f2 ff ff       	call   801059c0 <argint>
801066c1:	83 c4 10             	add    $0x10,%esp
801066c4:	85 c0                	test   %eax,%eax
801066c6:	79 0a                	jns    801066d2 <sys_exec+0x40>
    return -1;
801066c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066cd:	e9 c6 00 00 00       	jmp    80106798 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801066d2:	83 ec 04             	sub    $0x4,%esp
801066d5:	68 80 00 00 00       	push   $0x80
801066da:	6a 00                	push   $0x0
801066dc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066e2:	50                   	push   %eax
801066e3:	e8 b3 ef ff ff       	call   8010569b <memset>
801066e8:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801066eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801066f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f5:	83 f8 1f             	cmp    $0x1f,%eax
801066f8:	76 0a                	jbe    80106704 <sys_exec+0x72>
      return -1;
801066fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ff:	e9 94 00 00 00       	jmp    80106798 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106707:	c1 e0 02             	shl    $0x2,%eax
8010670a:	89 c2                	mov    %eax,%edx
8010670c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106712:	01 c2                	add    %eax,%edx
80106714:	83 ec 08             	sub    $0x8,%esp
80106717:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010671d:	50                   	push   %eax
8010671e:	52                   	push   %edx
8010671f:	e8 00 f2 ff ff       	call   80105924 <fetchint>
80106724:	83 c4 10             	add    $0x10,%esp
80106727:	85 c0                	test   %eax,%eax
80106729:	79 07                	jns    80106732 <sys_exec+0xa0>
      return -1;
8010672b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106730:	eb 66                	jmp    80106798 <sys_exec+0x106>
    if(uarg == 0){
80106732:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106738:	85 c0                	test   %eax,%eax
8010673a:	75 27                	jne    80106763 <sys_exec+0xd1>
      argv[i] = 0;
8010673c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673f:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106746:	00 00 00 00 
      break;
8010674a:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010674b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010674e:	83 ec 08             	sub    $0x8,%esp
80106751:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106757:	52                   	push   %edx
80106758:	50                   	push   %eax
80106759:	e8 13 a4 ff ff       	call   80100b71 <exec>
8010675e:	83 c4 10             	add    $0x10,%esp
80106761:	eb 35                	jmp    80106798 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106763:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106769:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010676c:	c1 e2 02             	shl    $0x2,%edx
8010676f:	01 c2                	add    %eax,%edx
80106771:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106777:	83 ec 08             	sub    $0x8,%esp
8010677a:	52                   	push   %edx
8010677b:	50                   	push   %eax
8010677c:	e8 dd f1 ff ff       	call   8010595e <fetchstr>
80106781:	83 c4 10             	add    $0x10,%esp
80106784:	85 c0                	test   %eax,%eax
80106786:	79 07                	jns    8010678f <sys_exec+0xfd>
      return -1;
80106788:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010678d:	eb 09                	jmp    80106798 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010678f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106793:	e9 5a ff ff ff       	jmp    801066f2 <sys_exec+0x60>
  return exec(path, argv);
}
80106798:	c9                   	leave  
80106799:	c3                   	ret    

8010679a <sys_pipe>:

int
sys_pipe(void)
{
8010679a:	55                   	push   %ebp
8010679b:	89 e5                	mov    %esp,%ebp
8010679d:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801067a0:	83 ec 04             	sub    $0x4,%esp
801067a3:	6a 08                	push   $0x8
801067a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801067a8:	50                   	push   %eax
801067a9:	6a 00                	push   $0x0
801067ab:	e8 38 f2 ff ff       	call   801059e8 <argptr>
801067b0:	83 c4 10             	add    $0x10,%esp
801067b3:	85 c0                	test   %eax,%eax
801067b5:	79 0a                	jns    801067c1 <sys_pipe+0x27>
    return -1;
801067b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bc:	e9 af 00 00 00       	jmp    80106870 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
801067c1:	83 ec 08             	sub    $0x8,%esp
801067c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801067c7:	50                   	push   %eax
801067c8:	8d 45 e8             	lea    -0x18(%ebp),%eax
801067cb:	50                   	push   %eax
801067cc:	e8 6a dc ff ff       	call   8010443b <pipealloc>
801067d1:	83 c4 10             	add    $0x10,%esp
801067d4:	85 c0                	test   %eax,%eax
801067d6:	79 0a                	jns    801067e2 <sys_pipe+0x48>
    return -1;
801067d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067dd:	e9 8e 00 00 00       	jmp    80106870 <sys_pipe+0xd6>
  fd0 = -1;
801067e2:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801067e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067ec:	83 ec 0c             	sub    $0xc,%esp
801067ef:	50                   	push   %eax
801067f0:	e8 7c f3 ff ff       	call   80105b71 <fdalloc>
801067f5:	83 c4 10             	add    $0x10,%esp
801067f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067ff:	78 18                	js     80106819 <sys_pipe+0x7f>
80106801:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106804:	83 ec 0c             	sub    $0xc,%esp
80106807:	50                   	push   %eax
80106808:	e8 64 f3 ff ff       	call   80105b71 <fdalloc>
8010680d:	83 c4 10             	add    $0x10,%esp
80106810:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106813:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106817:	79 3f                	jns    80106858 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106819:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010681d:	78 14                	js     80106833 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
8010681f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106825:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106828:	83 c2 08             	add    $0x8,%edx
8010682b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106832:	00 
    fileclose(rf);
80106833:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106836:	83 ec 0c             	sub    $0xc,%esp
80106839:	50                   	push   %eax
8010683a:	e8 12 a8 ff ff       	call   80101051 <fileclose>
8010683f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106842:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106845:	83 ec 0c             	sub    $0xc,%esp
80106848:	50                   	push   %eax
80106849:	e8 03 a8 ff ff       	call   80101051 <fileclose>
8010684e:	83 c4 10             	add    $0x10,%esp
    return -1;
80106851:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106856:	eb 18                	jmp    80106870 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106858:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010685b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010685e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106860:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106863:	8d 50 04             	lea    0x4(%eax),%edx
80106866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106869:	89 02                	mov    %eax,(%edx)
  return 0;
8010686b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106870:	c9                   	leave  
80106871:	c3                   	ret    

80106872 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106872:	55                   	push   %ebp
80106873:	89 e5                	mov    %esp,%ebp
80106875:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106878:	e8 b7 e2 ff ff       	call   80104b34 <fork>
}
8010687d:	c9                   	leave  
8010687e:	c3                   	ret    

8010687f <sys_exit>:

int
sys_exit(void)
{
8010687f:	55                   	push   %ebp
80106880:	89 e5                	mov    %esp,%ebp
80106882:	83 ec 08             	sub    $0x8,%esp
  exit();
80106885:	e8 65 e4 ff ff       	call   80104cef <exit>
  return 0;  // not reached
8010688a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010688f:	c9                   	leave  
80106890:	c3                   	ret    

80106891 <sys_wait>:

int
sys_wait(void)
{
80106891:	55                   	push   %ebp
80106892:	89 e5                	mov    %esp,%ebp
80106894:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106897:	e8 8e e5 ff ff       	call   80104e2a <wait>
}
8010689c:	c9                   	leave  
8010689d:	c3                   	ret    

8010689e <sys_kill>:

int
sys_kill(void)
{
8010689e:	55                   	push   %ebp
8010689f:	89 e5                	mov    %esp,%ebp
801068a1:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801068a4:	83 ec 08             	sub    $0x8,%esp
801068a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068aa:	50                   	push   %eax
801068ab:	6a 00                	push   $0x0
801068ad:	e8 0e f1 ff ff       	call   801059c0 <argint>
801068b2:	83 c4 10             	add    $0x10,%esp
801068b5:	85 c0                	test   %eax,%eax
801068b7:	79 07                	jns    801068c0 <sys_kill+0x22>
    return -1;
801068b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068be:	eb 0f                	jmp    801068cf <sys_kill+0x31>
  return kill(pid);
801068c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c3:	83 ec 0c             	sub    $0xc,%esp
801068c6:	50                   	push   %eax
801068c7:	e8 8f e9 ff ff       	call   8010525b <kill>
801068cc:	83 c4 10             	add    $0x10,%esp
}
801068cf:	c9                   	leave  
801068d0:	c3                   	ret    

801068d1 <sys_getpid>:

int
sys_getpid(void)
{
801068d1:	55                   	push   %ebp
801068d2:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801068d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068da:	8b 40 10             	mov    0x10(%eax),%eax
}
801068dd:	5d                   	pop    %ebp
801068de:	c3                   	ret    

801068df <sys_sbrk>:

int
sys_sbrk(void)
{
801068df:	55                   	push   %ebp
801068e0:	89 e5                	mov    %esp,%ebp
801068e2:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801068e5:	83 ec 08             	sub    $0x8,%esp
801068e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068eb:	50                   	push   %eax
801068ec:	6a 00                	push   $0x0
801068ee:	e8 cd f0 ff ff       	call   801059c0 <argint>
801068f3:	83 c4 10             	add    $0x10,%esp
801068f6:	85 c0                	test   %eax,%eax
801068f8:	79 07                	jns    80106901 <sys_sbrk+0x22>
    return -1;
801068fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ff:	eb 28                	jmp    80106929 <sys_sbrk+0x4a>
  addr = proc->sz;
80106901:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106907:	8b 00                	mov    (%eax),%eax
80106909:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010690c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010690f:	83 ec 0c             	sub    $0xc,%esp
80106912:	50                   	push   %eax
80106913:	e8 79 e1 ff ff       	call   80104a91 <growproc>
80106918:	83 c4 10             	add    $0x10,%esp
8010691b:	85 c0                	test   %eax,%eax
8010691d:	79 07                	jns    80106926 <sys_sbrk+0x47>
    return -1;
8010691f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106924:	eb 03                	jmp    80106929 <sys_sbrk+0x4a>
  return addr;
80106926:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106929:	c9                   	leave  
8010692a:	c3                   	ret    

8010692b <sys_sleep>:

int
sys_sleep(void)
{
8010692b:	55                   	push   %ebp
8010692c:	89 e5                	mov    %esp,%ebp
8010692e:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106931:	83 ec 08             	sub    $0x8,%esp
80106934:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106937:	50                   	push   %eax
80106938:	6a 00                	push   $0x0
8010693a:	e8 81 f0 ff ff       	call   801059c0 <argint>
8010693f:	83 c4 10             	add    $0x10,%esp
80106942:	85 c0                	test   %eax,%eax
80106944:	79 07                	jns    8010694d <sys_sleep+0x22>
    return -1;
80106946:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010694b:	eb 77                	jmp    801069c4 <sys_sleep+0x99>
  acquire(&tickslock);
8010694d:	83 ec 0c             	sub    $0xc,%esp
80106950:	68 a0 7a 11 80       	push   $0x80117aa0
80106955:	e8 de ea ff ff       	call   80105438 <acquire>
8010695a:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010695d:	a1 e0 82 11 80       	mov    0x801182e0,%eax
80106962:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106965:	eb 39                	jmp    801069a0 <sys_sleep+0x75>
    if(proc->killed){
80106967:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010696d:	8b 40 24             	mov    0x24(%eax),%eax
80106970:	85 c0                	test   %eax,%eax
80106972:	74 17                	je     8010698b <sys_sleep+0x60>
      release(&tickslock);
80106974:	83 ec 0c             	sub    $0xc,%esp
80106977:	68 a0 7a 11 80       	push   $0x80117aa0
8010697c:	e8 1e eb ff ff       	call   8010549f <release>
80106981:	83 c4 10             	add    $0x10,%esp
      return -1;
80106984:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106989:	eb 39                	jmp    801069c4 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
8010698b:	83 ec 08             	sub    $0x8,%esp
8010698e:	68 a0 7a 11 80       	push   $0x80117aa0
80106993:	68 e0 82 11 80       	push   $0x801182e0
80106998:	e8 99 e7 ff ff       	call   80105136 <sleep>
8010699d:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801069a0:	a1 e0 82 11 80       	mov    0x801182e0,%eax
801069a5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801069a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069ab:	39 d0                	cmp    %edx,%eax
801069ad:	72 b8                	jb     80106967 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801069af:	83 ec 0c             	sub    $0xc,%esp
801069b2:	68 a0 7a 11 80       	push   $0x80117aa0
801069b7:	e8 e3 ea ff ff       	call   8010549f <release>
801069bc:	83 c4 10             	add    $0x10,%esp
  return 0;
801069bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069c4:	c9                   	leave  
801069c5:	c3                   	ret    

801069c6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801069c6:	55                   	push   %ebp
801069c7:	89 e5                	mov    %esp,%ebp
801069c9:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801069cc:	83 ec 0c             	sub    $0xc,%esp
801069cf:	68 a0 7a 11 80       	push   $0x80117aa0
801069d4:	e8 5f ea ff ff       	call   80105438 <acquire>
801069d9:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801069dc:	a1 e0 82 11 80       	mov    0x801182e0,%eax
801069e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801069e4:	83 ec 0c             	sub    $0xc,%esp
801069e7:	68 a0 7a 11 80       	push   $0x80117aa0
801069ec:	e8 ae ea ff ff       	call   8010549f <release>
801069f1:	83 c4 10             	add    $0x10,%esp
  return xticks;
801069f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069f7:	c9                   	leave  
801069f8:	c3                   	ret    

801069f9 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801069f9:	55                   	push   %ebp
801069fa:	89 e5                	mov    %esp,%ebp
801069fc:	83 ec 08             	sub    $0x8,%esp
801069ff:	8b 55 08             	mov    0x8(%ebp),%edx
80106a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a05:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106a09:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a0c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106a10:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106a14:	ee                   	out    %al,(%dx)
}
80106a15:	90                   	nop
80106a16:	c9                   	leave  
80106a17:	c3                   	ret    

80106a18 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106a18:	55                   	push   %ebp
80106a19:	89 e5                	mov    %esp,%ebp
80106a1b:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106a1e:	6a 34                	push   $0x34
80106a20:	6a 43                	push   $0x43
80106a22:	e8 d2 ff ff ff       	call   801069f9 <outb>
80106a27:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106a2a:	68 9c 00 00 00       	push   $0x9c
80106a2f:	6a 40                	push   $0x40
80106a31:	e8 c3 ff ff ff       	call   801069f9 <outb>
80106a36:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106a39:	6a 2e                	push   $0x2e
80106a3b:	6a 40                	push   $0x40
80106a3d:	e8 b7 ff ff ff       	call   801069f9 <outb>
80106a42:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106a45:	83 ec 0c             	sub    $0xc,%esp
80106a48:	6a 00                	push   $0x0
80106a4a:	e8 d6 d8 ff ff       	call   80104325 <picenable>
80106a4f:	83 c4 10             	add    $0x10,%esp
}
80106a52:	90                   	nop
80106a53:	c9                   	leave  
80106a54:	c3                   	ret    

80106a55 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a55:	1e                   	push   %ds
  pushl %es
80106a56:	06                   	push   %es
  pushl %fs
80106a57:	0f a0                	push   %fs
  pushl %gs
80106a59:	0f a8                	push   %gs
  pushal
80106a5b:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106a5c:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106a60:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106a62:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106a64:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106a68:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106a6a:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106a6c:	54                   	push   %esp
  call trap
80106a6d:	e8 d7 01 00 00       	call   80106c49 <trap>
  addl $4, %esp
80106a72:	83 c4 04             	add    $0x4,%esp

80106a75 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106a75:	61                   	popa   
  popl %gs
80106a76:	0f a9                	pop    %gs
  popl %fs
80106a78:	0f a1                	pop    %fs
  popl %es
80106a7a:	07                   	pop    %es
  popl %ds
80106a7b:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106a7c:	83 c4 08             	add    $0x8,%esp
  iret
80106a7f:	cf                   	iret   

80106a80 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106a80:	55                   	push   %ebp
80106a81:	89 e5                	mov    %esp,%ebp
80106a83:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106a86:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a89:	83 e8 01             	sub    $0x1,%eax
80106a8c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106a90:	8b 45 08             	mov    0x8(%ebp),%eax
80106a93:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106a97:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9a:	c1 e8 10             	shr    $0x10,%eax
80106a9d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106aa1:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106aa4:	0f 01 18             	lidtl  (%eax)
}
80106aa7:	90                   	nop
80106aa8:	c9                   	leave  
80106aa9:	c3                   	ret    

80106aaa <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106aaa:	55                   	push   %ebp
80106aab:	89 e5                	mov    %esp,%ebp
80106aad:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106ab0:	0f 20 d0             	mov    %cr2,%eax
80106ab3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106ab6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106ab9:	c9                   	leave  
80106aba:	c3                   	ret    

80106abb <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106abb:	55                   	push   %ebp
80106abc:	89 e5                	mov    %esp,%ebp
80106abe:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106ac1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ac8:	e9 c3 00 00 00       	jmp    80106b90 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad0:	8b 04 85 98 c0 10 80 	mov    -0x7fef3f68(,%eax,4),%eax
80106ad7:	89 c2                	mov    %eax,%edx
80106ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106adc:	66 89 14 c5 e0 7a 11 	mov    %dx,-0x7fee8520(,%eax,8)
80106ae3:	80 
80106ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae7:	66 c7 04 c5 e2 7a 11 	movw   $0x8,-0x7fee851e(,%eax,8)
80106aee:	80 08 00 
80106af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af4:	0f b6 14 c5 e4 7a 11 	movzbl -0x7fee851c(,%eax,8),%edx
80106afb:	80 
80106afc:	83 e2 e0             	and    $0xffffffe0,%edx
80106aff:	88 14 c5 e4 7a 11 80 	mov    %dl,-0x7fee851c(,%eax,8)
80106b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b09:	0f b6 14 c5 e4 7a 11 	movzbl -0x7fee851c(,%eax,8),%edx
80106b10:	80 
80106b11:	83 e2 1f             	and    $0x1f,%edx
80106b14:	88 14 c5 e4 7a 11 80 	mov    %dl,-0x7fee851c(,%eax,8)
80106b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b1e:	0f b6 14 c5 e5 7a 11 	movzbl -0x7fee851b(,%eax,8),%edx
80106b25:	80 
80106b26:	83 e2 f0             	and    $0xfffffff0,%edx
80106b29:	83 ca 0e             	or     $0xe,%edx
80106b2c:	88 14 c5 e5 7a 11 80 	mov    %dl,-0x7fee851b(,%eax,8)
80106b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b36:	0f b6 14 c5 e5 7a 11 	movzbl -0x7fee851b(,%eax,8),%edx
80106b3d:	80 
80106b3e:	83 e2 ef             	and    $0xffffffef,%edx
80106b41:	88 14 c5 e5 7a 11 80 	mov    %dl,-0x7fee851b(,%eax,8)
80106b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b4b:	0f b6 14 c5 e5 7a 11 	movzbl -0x7fee851b(,%eax,8),%edx
80106b52:	80 
80106b53:	83 e2 9f             	and    $0xffffff9f,%edx
80106b56:	88 14 c5 e5 7a 11 80 	mov    %dl,-0x7fee851b(,%eax,8)
80106b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b60:	0f b6 14 c5 e5 7a 11 	movzbl -0x7fee851b(,%eax,8),%edx
80106b67:	80 
80106b68:	83 ca 80             	or     $0xffffff80,%edx
80106b6b:	88 14 c5 e5 7a 11 80 	mov    %dl,-0x7fee851b(,%eax,8)
80106b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b75:	8b 04 85 98 c0 10 80 	mov    -0x7fef3f68(,%eax,4),%eax
80106b7c:	c1 e8 10             	shr    $0x10,%eax
80106b7f:	89 c2                	mov    %eax,%edx
80106b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b84:	66 89 14 c5 e6 7a 11 	mov    %dx,-0x7fee851a(,%eax,8)
80106b8b:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b90:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106b97:	0f 8e 30 ff ff ff    	jle    80106acd <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106b9d:	a1 98 c1 10 80       	mov    0x8010c198,%eax
80106ba2:	66 a3 e0 7c 11 80    	mov    %ax,0x80117ce0
80106ba8:	66 c7 05 e2 7c 11 80 	movw   $0x8,0x80117ce2
80106baf:	08 00 
80106bb1:	0f b6 05 e4 7c 11 80 	movzbl 0x80117ce4,%eax
80106bb8:	83 e0 e0             	and    $0xffffffe0,%eax
80106bbb:	a2 e4 7c 11 80       	mov    %al,0x80117ce4
80106bc0:	0f b6 05 e4 7c 11 80 	movzbl 0x80117ce4,%eax
80106bc7:	83 e0 1f             	and    $0x1f,%eax
80106bca:	a2 e4 7c 11 80       	mov    %al,0x80117ce4
80106bcf:	0f b6 05 e5 7c 11 80 	movzbl 0x80117ce5,%eax
80106bd6:	83 c8 0f             	or     $0xf,%eax
80106bd9:	a2 e5 7c 11 80       	mov    %al,0x80117ce5
80106bde:	0f b6 05 e5 7c 11 80 	movzbl 0x80117ce5,%eax
80106be5:	83 e0 ef             	and    $0xffffffef,%eax
80106be8:	a2 e5 7c 11 80       	mov    %al,0x80117ce5
80106bed:	0f b6 05 e5 7c 11 80 	movzbl 0x80117ce5,%eax
80106bf4:	83 c8 60             	or     $0x60,%eax
80106bf7:	a2 e5 7c 11 80       	mov    %al,0x80117ce5
80106bfc:	0f b6 05 e5 7c 11 80 	movzbl 0x80117ce5,%eax
80106c03:	83 c8 80             	or     $0xffffff80,%eax
80106c06:	a2 e5 7c 11 80       	mov    %al,0x80117ce5
80106c0b:	a1 98 c1 10 80       	mov    0x8010c198,%eax
80106c10:	c1 e8 10             	shr    $0x10,%eax
80106c13:	66 a3 e6 7c 11 80    	mov    %ax,0x80117ce6
  
  initlock(&tickslock, "time");
80106c19:	83 ec 08             	sub    $0x8,%esp
80106c1c:	68 20 93 10 80       	push   $0x80109320
80106c21:	68 a0 7a 11 80       	push   $0x80117aa0
80106c26:	e8 eb e7 ff ff       	call   80105416 <initlock>
80106c2b:	83 c4 10             	add    $0x10,%esp
}
80106c2e:	90                   	nop
80106c2f:	c9                   	leave  
80106c30:	c3                   	ret    

80106c31 <idtinit>:

void
idtinit(void)
{
80106c31:	55                   	push   %ebp
80106c32:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c34:	68 00 08 00 00       	push   $0x800
80106c39:	68 e0 7a 11 80       	push   $0x80117ae0
80106c3e:	e8 3d fe ff ff       	call   80106a80 <lidt>
80106c43:	83 c4 08             	add    $0x8,%esp
}
80106c46:	90                   	nop
80106c47:	c9                   	leave  
80106c48:	c3                   	ret    

80106c49 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c49:	55                   	push   %ebp
80106c4a:	89 e5                	mov    %esp,%ebp
80106c4c:	57                   	push   %edi
80106c4d:	56                   	push   %esi
80106c4e:	53                   	push   %ebx
80106c4f:	83 ec 2c             	sub    $0x2c,%esp
  uint addr;
  pde_t *va;
  if(tf->trapno == T_SYSCALL){
80106c52:	8b 45 08             	mov    0x8(%ebp),%eax
80106c55:	8b 40 30             	mov    0x30(%eax),%eax
80106c58:	83 f8 40             	cmp    $0x40,%eax
80106c5b:	75 3e                	jne    80106c9b <trap+0x52>
    if(proc->killed)
80106c5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c63:	8b 40 24             	mov    0x24(%eax),%eax
80106c66:	85 c0                	test   %eax,%eax
80106c68:	74 05                	je     80106c6f <trap+0x26>
      exit();
80106c6a:	e8 80 e0 ff ff       	call   80104cef <exit>
    proc->tf = tf;
80106c6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c75:	8b 55 08             	mov    0x8(%ebp),%edx
80106c78:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106c7b:	e8 f6 ed ff ff       	call   80105a76 <syscall>
    if(proc->killed)
80106c80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c86:	8b 40 24             	mov    0x24(%eax),%eax
80106c89:	85 c0                	test   %eax,%eax
80106c8b:	0f 84 98 02 00 00    	je     80106f29 <trap+0x2e0>
      exit();
80106c91:	e8 59 e0 ff ff       	call   80104cef <exit>
    return;
80106c96:	e9 8e 02 00 00       	jmp    80106f29 <trap+0x2e0>
  }

  switch(tf->trapno){
80106c9b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c9e:	8b 40 30             	mov    0x30(%eax),%eax
80106ca1:	83 e8 0e             	sub    $0xe,%eax
80106ca4:	83 f8 31             	cmp    $0x31,%eax
80106ca7:	0f 87 3a 01 00 00    	ja     80106de7 <trap+0x19e>
80106cad:	8b 04 85 c8 93 10 80 	mov    -0x7fef6c38(,%eax,4),%eax
80106cb4:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106cb6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106cbc:	0f b6 00             	movzbl (%eax),%eax
80106cbf:	84 c0                	test   %al,%al
80106cc1:	75 3d                	jne    80106d00 <trap+0xb7>
      acquire(&tickslock);
80106cc3:	83 ec 0c             	sub    $0xc,%esp
80106cc6:	68 a0 7a 11 80       	push   $0x80117aa0
80106ccb:	e8 68 e7 ff ff       	call   80105438 <acquire>
80106cd0:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106cd3:	a1 e0 82 11 80       	mov    0x801182e0,%eax
80106cd8:	83 c0 01             	add    $0x1,%eax
80106cdb:	a3 e0 82 11 80       	mov    %eax,0x801182e0
      wakeup(&ticks);
80106ce0:	83 ec 0c             	sub    $0xc,%esp
80106ce3:	68 e0 82 11 80       	push   $0x801182e0
80106ce8:	e8 37 e5 ff ff       	call   80105224 <wakeup>
80106ced:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106cf0:	83 ec 0c             	sub    $0xc,%esp
80106cf3:	68 a0 7a 11 80       	push   $0x80117aa0
80106cf8:	e8 a2 e7 ff ff       	call   8010549f <release>
80106cfd:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106d00:	e8 1a c7 ff ff       	call   8010341f <lapiceoi>
    break;
80106d05:	e9 99 01 00 00       	jmp    80106ea3 <trap+0x25a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d0a:	e8 23 bf ff ff       	call   80102c32 <ideintr>
    lapiceoi();
80106d0f:	e8 0b c7 ff ff       	call   8010341f <lapiceoi>
    break;
80106d14:	e9 8a 01 00 00       	jmp    80106ea3 <trap+0x25a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106d19:	e8 03 c5 ff ff       	call   80103221 <kbdintr>
    lapiceoi();
80106d1e:	e8 fc c6 ff ff       	call   8010341f <lapiceoi>
    break;
80106d23:	e9 7b 01 00 00       	jmp    80106ea3 <trap+0x25a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d28:	e8 dd 03 00 00       	call   8010710a <uartintr>
    lapiceoi();
80106d2d:	e8 ed c6 ff ff       	call   8010341f <lapiceoi>
    break;
80106d32:	e9 6c 01 00 00       	jmp    80106ea3 <trap+0x25a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d37:	8b 45 08             	mov    0x8(%ebp),%eax
80106d3a:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d40:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d44:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106d47:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d4d:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d50:	0f b6 c0             	movzbl %al,%eax
80106d53:	51                   	push   %ecx
80106d54:	52                   	push   %edx
80106d55:	50                   	push   %eax
80106d56:	68 28 93 10 80       	push   $0x80109328
80106d5b:	e8 66 96 ff ff       	call   801003c6 <cprintf>
80106d60:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106d63:	e8 b7 c6 ff ff       	call   8010341f <lapiceoi>
    break;
80106d68:	e9 36 01 00 00       	jmp    80106ea3 <trap+0x25a>

  case T_PGFLT:

    addr = rcr2();
80106d6d:	e8 38 fd ff ff       	call   80106aaa <rcr2>
80106d72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    va = &proc->pgdir[PDX(addr)];
80106d75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d7b:	8b 40 04             	mov    0x4(%eax),%eax
80106d7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106d81:	c1 ea 16             	shr    $0x16,%edx
80106d84:	c1 e2 02             	shl    $0x2,%edx
80106d87:	01 d0                	add    %edx,%eax
80106d89:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (((int)(*va) & PTE_P) != 0){  // if page table isn't present at page directory -> hard page fault
80106d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d8f:	8b 00                	mov    (%eax),%eax
80106d91:	83 e0 01             	and    $0x1,%eax
80106d94:	85 c0                	test   %eax,%eax
80106d96:	0f 84 06 01 00 00    	je     80106ea2 <trap+0x259>
      if (((uint*)PTE_ADDR(P2V(*va)))[PTX(addr)] & PTE_PG) { // if the page is in the process's swap file
80106d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d9f:	c1 e8 0c             	shr    $0xc,%eax
80106da2:	25 ff 03 00 00       	and    $0x3ff,%eax
80106da7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106dae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106db1:	8b 00                	mov    (%eax),%eax
80106db3:	05 00 00 00 80       	add    $0x80000000,%eax
80106db8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106dbd:	01 d0                	add    %edx,%eax
80106dbf:	8b 00                	mov    (%eax),%eax
80106dc1:	25 00 02 00 00       	and    $0x200,%eax
80106dc6:	85 c0                	test   %eax,%eax
80106dc8:	0f 84 d4 00 00 00    	je     80106ea2 <trap+0x259>
        swapPages(PTE_ADDR(addr)); 
80106dce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106dd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106dd6:	83 ec 0c             	sub    $0xc,%esp
80106dd9:	50                   	push   %eax
80106dda:	e8 2e 1e 00 00       	call   80108c0d <swapPages>
80106ddf:	83 c4 10             	add    $0x10,%esp
      }
    }   
    break;
80106de2:	e9 bb 00 00 00       	jmp    80106ea2 <trap+0x259>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106de7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ded:	85 c0                	test   %eax,%eax
80106def:	74 11                	je     80106e02 <trap+0x1b9>
80106df1:	8b 45 08             	mov    0x8(%ebp),%eax
80106df4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106df8:	0f b7 c0             	movzwl %ax,%eax
80106dfb:	83 e0 03             	and    $0x3,%eax
80106dfe:	85 c0                	test   %eax,%eax
80106e00:	75 40                	jne    80106e42 <trap+0x1f9>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e02:	e8 a3 fc ff ff       	call   80106aaa <rcr2>
80106e07:	89 c3                	mov    %eax,%ebx
80106e09:	8b 45 08             	mov    0x8(%ebp),%eax
80106e0c:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106e0f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e15:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e18:	0f b6 d0             	movzbl %al,%edx
80106e1b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e1e:	8b 40 30             	mov    0x30(%eax),%eax
80106e21:	83 ec 0c             	sub    $0xc,%esp
80106e24:	53                   	push   %ebx
80106e25:	51                   	push   %ecx
80106e26:	52                   	push   %edx
80106e27:	50                   	push   %eax
80106e28:	68 4c 93 10 80       	push   $0x8010934c
80106e2d:	e8 94 95 ff ff       	call   801003c6 <cprintf>
80106e32:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106e35:	83 ec 0c             	sub    $0xc,%esp
80106e38:	68 7e 93 10 80       	push   $0x8010937e
80106e3d:	e8 24 97 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e42:	e8 63 fc ff ff       	call   80106aaa <rcr2>
80106e47:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80106e4d:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e50:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e56:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e59:	0f b6 d8             	movzbl %al,%ebx
80106e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5f:	8b 48 34             	mov    0x34(%eax),%ecx
80106e62:	8b 45 08             	mov    0x8(%ebp),%eax
80106e65:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e68:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e6e:	8d 78 6c             	lea    0x6c(%eax),%edi
80106e71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e77:	8b 40 10             	mov    0x10(%eax),%eax
80106e7a:	ff 75 d4             	pushl  -0x2c(%ebp)
80106e7d:	56                   	push   %esi
80106e7e:	53                   	push   %ebx
80106e7f:	51                   	push   %ecx
80106e80:	52                   	push   %edx
80106e81:	57                   	push   %edi
80106e82:	50                   	push   %eax
80106e83:	68 84 93 10 80       	push   $0x80109384
80106e88:	e8 39 95 ff ff       	call   801003c6 <cprintf>
80106e8d:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e96:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106e9d:	eb 04                	jmp    80106ea3 <trap+0x25a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106e9f:	90                   	nop
80106ea0:	eb 01                	jmp    80106ea3 <trap+0x25a>
    if (((int)(*va) & PTE_P) != 0){  // if page table isn't present at page directory -> hard page fault
      if (((uint*)PTE_ADDR(P2V(*va)))[PTX(addr)] & PTE_PG) { // if the page is in the process's swap file
        swapPages(PTE_ADDR(addr)); 
      }
    }   
    break;
80106ea2:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106ea3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ea9:	85 c0                	test   %eax,%eax
80106eab:	74 24                	je     80106ed1 <trap+0x288>
80106ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eb3:	8b 40 24             	mov    0x24(%eax),%eax
80106eb6:	85 c0                	test   %eax,%eax
80106eb8:	74 17                	je     80106ed1 <trap+0x288>
80106eba:	8b 45 08             	mov    0x8(%ebp),%eax
80106ebd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ec1:	0f b7 c0             	movzwl %ax,%eax
80106ec4:	83 e0 03             	and    $0x3,%eax
80106ec7:	83 f8 03             	cmp    $0x3,%eax
80106eca:	75 05                	jne    80106ed1 <trap+0x288>
    exit();
80106ecc:	e8 1e de ff ff       	call   80104cef <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106ed1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ed7:	85 c0                	test   %eax,%eax
80106ed9:	74 1e                	je     80106ef9 <trap+0x2b0>
80106edb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ee1:	8b 40 0c             	mov    0xc(%eax),%eax
80106ee4:	83 f8 04             	cmp    $0x4,%eax
80106ee7:	75 10                	jne    80106ef9 <trap+0x2b0>
80106ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80106eec:	8b 40 30             	mov    0x30(%eax),%eax
80106eef:	83 f8 20             	cmp    $0x20,%eax
80106ef2:	75 05                	jne    80106ef9 <trap+0x2b0>
    yield();
80106ef4:	e8 bc e1 ff ff       	call   801050b5 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106ef9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eff:	85 c0                	test   %eax,%eax
80106f01:	74 27                	je     80106f2a <trap+0x2e1>
80106f03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f09:	8b 40 24             	mov    0x24(%eax),%eax
80106f0c:	85 c0                	test   %eax,%eax
80106f0e:	74 1a                	je     80106f2a <trap+0x2e1>
80106f10:	8b 45 08             	mov    0x8(%ebp),%eax
80106f13:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f17:	0f b7 c0             	movzwl %ax,%eax
80106f1a:	83 e0 03             	and    $0x3,%eax
80106f1d:	83 f8 03             	cmp    $0x3,%eax
80106f20:	75 08                	jne    80106f2a <trap+0x2e1>
    exit();
80106f22:	e8 c8 dd ff ff       	call   80104cef <exit>
80106f27:	eb 01                	jmp    80106f2a <trap+0x2e1>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106f29:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f2d:	5b                   	pop    %ebx
80106f2e:	5e                   	pop    %esi
80106f2f:	5f                   	pop    %edi
80106f30:	5d                   	pop    %ebp
80106f31:	c3                   	ret    

80106f32 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106f32:	55                   	push   %ebp
80106f33:	89 e5                	mov    %esp,%ebp
80106f35:	83 ec 14             	sub    $0x14,%esp
80106f38:	8b 45 08             	mov    0x8(%ebp),%eax
80106f3b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f3f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f43:	89 c2                	mov    %eax,%edx
80106f45:	ec                   	in     (%dx),%al
80106f46:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f49:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f4d:	c9                   	leave  
80106f4e:	c3                   	ret    

80106f4f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106f4f:	55                   	push   %ebp
80106f50:	89 e5                	mov    %esp,%ebp
80106f52:	83 ec 08             	sub    $0x8,%esp
80106f55:	8b 55 08             	mov    0x8(%ebp),%edx
80106f58:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f5b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106f5f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f62:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f66:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f6a:	ee                   	out    %al,(%dx)
}
80106f6b:	90                   	nop
80106f6c:	c9                   	leave  
80106f6d:	c3                   	ret    

80106f6e <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f6e:	55                   	push   %ebp
80106f6f:	89 e5                	mov    %esp,%ebp
80106f71:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f74:	6a 00                	push   $0x0
80106f76:	68 fa 03 00 00       	push   $0x3fa
80106f7b:	e8 cf ff ff ff       	call   80106f4f <outb>
80106f80:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106f83:	68 80 00 00 00       	push   $0x80
80106f88:	68 fb 03 00 00       	push   $0x3fb
80106f8d:	e8 bd ff ff ff       	call   80106f4f <outb>
80106f92:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106f95:	6a 0c                	push   $0xc
80106f97:	68 f8 03 00 00       	push   $0x3f8
80106f9c:	e8 ae ff ff ff       	call   80106f4f <outb>
80106fa1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106fa4:	6a 00                	push   $0x0
80106fa6:	68 f9 03 00 00       	push   $0x3f9
80106fab:	e8 9f ff ff ff       	call   80106f4f <outb>
80106fb0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106fb3:	6a 03                	push   $0x3
80106fb5:	68 fb 03 00 00       	push   $0x3fb
80106fba:	e8 90 ff ff ff       	call   80106f4f <outb>
80106fbf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106fc2:	6a 00                	push   $0x0
80106fc4:	68 fc 03 00 00       	push   $0x3fc
80106fc9:	e8 81 ff ff ff       	call   80106f4f <outb>
80106fce:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106fd1:	6a 01                	push   $0x1
80106fd3:	68 f9 03 00 00       	push   $0x3f9
80106fd8:	e8 72 ff ff ff       	call   80106f4f <outb>
80106fdd:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106fe0:	68 fd 03 00 00       	push   $0x3fd
80106fe5:	e8 48 ff ff ff       	call   80106f32 <inb>
80106fea:	83 c4 04             	add    $0x4,%esp
80106fed:	3c ff                	cmp    $0xff,%al
80106fef:	74 6e                	je     8010705f <uartinit+0xf1>
    return;
  uart = 1;
80106ff1:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80106ff8:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106ffb:	68 fa 03 00 00       	push   $0x3fa
80107000:	e8 2d ff ff ff       	call   80106f32 <inb>
80107005:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107008:	68 f8 03 00 00       	push   $0x3f8
8010700d:	e8 20 ff ff ff       	call   80106f32 <inb>
80107012:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107015:	83 ec 0c             	sub    $0xc,%esp
80107018:	6a 04                	push   $0x4
8010701a:	e8 06 d3 ff ff       	call   80104325 <picenable>
8010701f:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107022:	83 ec 08             	sub    $0x8,%esp
80107025:	6a 00                	push   $0x0
80107027:	6a 04                	push   $0x4
80107029:	e8 a6 be ff ff       	call   80102ed4 <ioapicenable>
8010702e:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107031:	c7 45 f4 90 94 10 80 	movl   $0x80109490,-0xc(%ebp)
80107038:	eb 19                	jmp    80107053 <uartinit+0xe5>
    uartputc(*p);
8010703a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703d:	0f b6 00             	movzbl (%eax),%eax
80107040:	0f be c0             	movsbl %al,%eax
80107043:	83 ec 0c             	sub    $0xc,%esp
80107046:	50                   	push   %eax
80107047:	e8 16 00 00 00       	call   80107062 <uartputc>
8010704c:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010704f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107056:	0f b6 00             	movzbl (%eax),%eax
80107059:	84 c0                	test   %al,%al
8010705b:	75 dd                	jne    8010703a <uartinit+0xcc>
8010705d:	eb 01                	jmp    80107060 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
8010705f:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107060:	c9                   	leave  
80107061:	c3                   	ret    

80107062 <uartputc>:

void
uartputc(int c)
{
80107062:	55                   	push   %ebp
80107063:	89 e5                	mov    %esp,%ebp
80107065:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107068:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
8010706d:	85 c0                	test   %eax,%eax
8010706f:	74 53                	je     801070c4 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107071:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107078:	eb 11                	jmp    8010708b <uartputc+0x29>
    microdelay(10);
8010707a:	83 ec 0c             	sub    $0xc,%esp
8010707d:	6a 0a                	push   $0xa
8010707f:	e8 b6 c3 ff ff       	call   8010343a <microdelay>
80107084:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107087:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010708b:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010708f:	7f 1a                	jg     801070ab <uartputc+0x49>
80107091:	83 ec 0c             	sub    $0xc,%esp
80107094:	68 fd 03 00 00       	push   $0x3fd
80107099:	e8 94 fe ff ff       	call   80106f32 <inb>
8010709e:	83 c4 10             	add    $0x10,%esp
801070a1:	0f b6 c0             	movzbl %al,%eax
801070a4:	83 e0 20             	and    $0x20,%eax
801070a7:	85 c0                	test   %eax,%eax
801070a9:	74 cf                	je     8010707a <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801070ab:	8b 45 08             	mov    0x8(%ebp),%eax
801070ae:	0f b6 c0             	movzbl %al,%eax
801070b1:	83 ec 08             	sub    $0x8,%esp
801070b4:	50                   	push   %eax
801070b5:	68 f8 03 00 00       	push   $0x3f8
801070ba:	e8 90 fe ff ff       	call   80106f4f <outb>
801070bf:	83 c4 10             	add    $0x10,%esp
801070c2:	eb 01                	jmp    801070c5 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801070c4:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801070c5:	c9                   	leave  
801070c6:	c3                   	ret    

801070c7 <uartgetc>:

static int
uartgetc(void)
{
801070c7:	55                   	push   %ebp
801070c8:	89 e5                	mov    %esp,%ebp
  if(!uart)
801070ca:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
801070cf:	85 c0                	test   %eax,%eax
801070d1:	75 07                	jne    801070da <uartgetc+0x13>
    return -1;
801070d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070d8:	eb 2e                	jmp    80107108 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801070da:	68 fd 03 00 00       	push   $0x3fd
801070df:	e8 4e fe ff ff       	call   80106f32 <inb>
801070e4:	83 c4 04             	add    $0x4,%esp
801070e7:	0f b6 c0             	movzbl %al,%eax
801070ea:	83 e0 01             	and    $0x1,%eax
801070ed:	85 c0                	test   %eax,%eax
801070ef:	75 07                	jne    801070f8 <uartgetc+0x31>
    return -1;
801070f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070f6:	eb 10                	jmp    80107108 <uartgetc+0x41>
  return inb(COM1+0);
801070f8:	68 f8 03 00 00       	push   $0x3f8
801070fd:	e8 30 fe ff ff       	call   80106f32 <inb>
80107102:	83 c4 04             	add    $0x4,%esp
80107105:	0f b6 c0             	movzbl %al,%eax
}
80107108:	c9                   	leave  
80107109:	c3                   	ret    

8010710a <uartintr>:

void
uartintr(void)
{
8010710a:	55                   	push   %ebp
8010710b:	89 e5                	mov    %esp,%ebp
8010710d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107110:	83 ec 0c             	sub    $0xc,%esp
80107113:	68 c7 70 10 80       	push   $0x801070c7
80107118:	e8 dc 96 ff ff       	call   801007f9 <consoleintr>
8010711d:	83 c4 10             	add    $0x10,%esp
}
80107120:	90                   	nop
80107121:	c9                   	leave  
80107122:	c3                   	ret    

80107123 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $0
80107125:	6a 00                	push   $0x0
  jmp alltraps
80107127:	e9 29 f9 ff ff       	jmp    80106a55 <alltraps>

8010712c <vector1>:
.globl vector1
vector1:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $1
8010712e:	6a 01                	push   $0x1
  jmp alltraps
80107130:	e9 20 f9 ff ff       	jmp    80106a55 <alltraps>

80107135 <vector2>:
.globl vector2
vector2:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $2
80107137:	6a 02                	push   $0x2
  jmp alltraps
80107139:	e9 17 f9 ff ff       	jmp    80106a55 <alltraps>

8010713e <vector3>:
.globl vector3
vector3:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $3
80107140:	6a 03                	push   $0x3
  jmp alltraps
80107142:	e9 0e f9 ff ff       	jmp    80106a55 <alltraps>

80107147 <vector4>:
.globl vector4
vector4:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $4
80107149:	6a 04                	push   $0x4
  jmp alltraps
8010714b:	e9 05 f9 ff ff       	jmp    80106a55 <alltraps>

80107150 <vector5>:
.globl vector5
vector5:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $5
80107152:	6a 05                	push   $0x5
  jmp alltraps
80107154:	e9 fc f8 ff ff       	jmp    80106a55 <alltraps>

80107159 <vector6>:
.globl vector6
vector6:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $6
8010715b:	6a 06                	push   $0x6
  jmp alltraps
8010715d:	e9 f3 f8 ff ff       	jmp    80106a55 <alltraps>

80107162 <vector7>:
.globl vector7
vector7:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $7
80107164:	6a 07                	push   $0x7
  jmp alltraps
80107166:	e9 ea f8 ff ff       	jmp    80106a55 <alltraps>

8010716b <vector8>:
.globl vector8
vector8:
  pushl $8
8010716b:	6a 08                	push   $0x8
  jmp alltraps
8010716d:	e9 e3 f8 ff ff       	jmp    80106a55 <alltraps>

80107172 <vector9>:
.globl vector9
vector9:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $9
80107174:	6a 09                	push   $0x9
  jmp alltraps
80107176:	e9 da f8 ff ff       	jmp    80106a55 <alltraps>

8010717b <vector10>:
.globl vector10
vector10:
  pushl $10
8010717b:	6a 0a                	push   $0xa
  jmp alltraps
8010717d:	e9 d3 f8 ff ff       	jmp    80106a55 <alltraps>

80107182 <vector11>:
.globl vector11
vector11:
  pushl $11
80107182:	6a 0b                	push   $0xb
  jmp alltraps
80107184:	e9 cc f8 ff ff       	jmp    80106a55 <alltraps>

80107189 <vector12>:
.globl vector12
vector12:
  pushl $12
80107189:	6a 0c                	push   $0xc
  jmp alltraps
8010718b:	e9 c5 f8 ff ff       	jmp    80106a55 <alltraps>

80107190 <vector13>:
.globl vector13
vector13:
  pushl $13
80107190:	6a 0d                	push   $0xd
  jmp alltraps
80107192:	e9 be f8 ff ff       	jmp    80106a55 <alltraps>

80107197 <vector14>:
.globl vector14
vector14:
  pushl $14
80107197:	6a 0e                	push   $0xe
  jmp alltraps
80107199:	e9 b7 f8 ff ff       	jmp    80106a55 <alltraps>

8010719e <vector15>:
.globl vector15
vector15:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $15
801071a0:	6a 0f                	push   $0xf
  jmp alltraps
801071a2:	e9 ae f8 ff ff       	jmp    80106a55 <alltraps>

801071a7 <vector16>:
.globl vector16
vector16:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $16
801071a9:	6a 10                	push   $0x10
  jmp alltraps
801071ab:	e9 a5 f8 ff ff       	jmp    80106a55 <alltraps>

801071b0 <vector17>:
.globl vector17
vector17:
  pushl $17
801071b0:	6a 11                	push   $0x11
  jmp alltraps
801071b2:	e9 9e f8 ff ff       	jmp    80106a55 <alltraps>

801071b7 <vector18>:
.globl vector18
vector18:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $18
801071b9:	6a 12                	push   $0x12
  jmp alltraps
801071bb:	e9 95 f8 ff ff       	jmp    80106a55 <alltraps>

801071c0 <vector19>:
.globl vector19
vector19:
  pushl $0
801071c0:	6a 00                	push   $0x0
  pushl $19
801071c2:	6a 13                	push   $0x13
  jmp alltraps
801071c4:	e9 8c f8 ff ff       	jmp    80106a55 <alltraps>

801071c9 <vector20>:
.globl vector20
vector20:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $20
801071cb:	6a 14                	push   $0x14
  jmp alltraps
801071cd:	e9 83 f8 ff ff       	jmp    80106a55 <alltraps>

801071d2 <vector21>:
.globl vector21
vector21:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $21
801071d4:	6a 15                	push   $0x15
  jmp alltraps
801071d6:	e9 7a f8 ff ff       	jmp    80106a55 <alltraps>

801071db <vector22>:
.globl vector22
vector22:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $22
801071dd:	6a 16                	push   $0x16
  jmp alltraps
801071df:	e9 71 f8 ff ff       	jmp    80106a55 <alltraps>

801071e4 <vector23>:
.globl vector23
vector23:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $23
801071e6:	6a 17                	push   $0x17
  jmp alltraps
801071e8:	e9 68 f8 ff ff       	jmp    80106a55 <alltraps>

801071ed <vector24>:
.globl vector24
vector24:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $24
801071ef:	6a 18                	push   $0x18
  jmp alltraps
801071f1:	e9 5f f8 ff ff       	jmp    80106a55 <alltraps>

801071f6 <vector25>:
.globl vector25
vector25:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $25
801071f8:	6a 19                	push   $0x19
  jmp alltraps
801071fa:	e9 56 f8 ff ff       	jmp    80106a55 <alltraps>

801071ff <vector26>:
.globl vector26
vector26:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $26
80107201:	6a 1a                	push   $0x1a
  jmp alltraps
80107203:	e9 4d f8 ff ff       	jmp    80106a55 <alltraps>

80107208 <vector27>:
.globl vector27
vector27:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $27
8010720a:	6a 1b                	push   $0x1b
  jmp alltraps
8010720c:	e9 44 f8 ff ff       	jmp    80106a55 <alltraps>

80107211 <vector28>:
.globl vector28
vector28:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $28
80107213:	6a 1c                	push   $0x1c
  jmp alltraps
80107215:	e9 3b f8 ff ff       	jmp    80106a55 <alltraps>

8010721a <vector29>:
.globl vector29
vector29:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $29
8010721c:	6a 1d                	push   $0x1d
  jmp alltraps
8010721e:	e9 32 f8 ff ff       	jmp    80106a55 <alltraps>

80107223 <vector30>:
.globl vector30
vector30:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $30
80107225:	6a 1e                	push   $0x1e
  jmp alltraps
80107227:	e9 29 f8 ff ff       	jmp    80106a55 <alltraps>

8010722c <vector31>:
.globl vector31
vector31:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $31
8010722e:	6a 1f                	push   $0x1f
  jmp alltraps
80107230:	e9 20 f8 ff ff       	jmp    80106a55 <alltraps>

80107235 <vector32>:
.globl vector32
vector32:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $32
80107237:	6a 20                	push   $0x20
  jmp alltraps
80107239:	e9 17 f8 ff ff       	jmp    80106a55 <alltraps>

8010723e <vector33>:
.globl vector33
vector33:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $33
80107240:	6a 21                	push   $0x21
  jmp alltraps
80107242:	e9 0e f8 ff ff       	jmp    80106a55 <alltraps>

80107247 <vector34>:
.globl vector34
vector34:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $34
80107249:	6a 22                	push   $0x22
  jmp alltraps
8010724b:	e9 05 f8 ff ff       	jmp    80106a55 <alltraps>

80107250 <vector35>:
.globl vector35
vector35:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $35
80107252:	6a 23                	push   $0x23
  jmp alltraps
80107254:	e9 fc f7 ff ff       	jmp    80106a55 <alltraps>

80107259 <vector36>:
.globl vector36
vector36:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $36
8010725b:	6a 24                	push   $0x24
  jmp alltraps
8010725d:	e9 f3 f7 ff ff       	jmp    80106a55 <alltraps>

80107262 <vector37>:
.globl vector37
vector37:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $37
80107264:	6a 25                	push   $0x25
  jmp alltraps
80107266:	e9 ea f7 ff ff       	jmp    80106a55 <alltraps>

8010726b <vector38>:
.globl vector38
vector38:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $38
8010726d:	6a 26                	push   $0x26
  jmp alltraps
8010726f:	e9 e1 f7 ff ff       	jmp    80106a55 <alltraps>

80107274 <vector39>:
.globl vector39
vector39:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $39
80107276:	6a 27                	push   $0x27
  jmp alltraps
80107278:	e9 d8 f7 ff ff       	jmp    80106a55 <alltraps>

8010727d <vector40>:
.globl vector40
vector40:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $40
8010727f:	6a 28                	push   $0x28
  jmp alltraps
80107281:	e9 cf f7 ff ff       	jmp    80106a55 <alltraps>

80107286 <vector41>:
.globl vector41
vector41:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $41
80107288:	6a 29                	push   $0x29
  jmp alltraps
8010728a:	e9 c6 f7 ff ff       	jmp    80106a55 <alltraps>

8010728f <vector42>:
.globl vector42
vector42:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $42
80107291:	6a 2a                	push   $0x2a
  jmp alltraps
80107293:	e9 bd f7 ff ff       	jmp    80106a55 <alltraps>

80107298 <vector43>:
.globl vector43
vector43:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $43
8010729a:	6a 2b                	push   $0x2b
  jmp alltraps
8010729c:	e9 b4 f7 ff ff       	jmp    80106a55 <alltraps>

801072a1 <vector44>:
.globl vector44
vector44:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $44
801072a3:	6a 2c                	push   $0x2c
  jmp alltraps
801072a5:	e9 ab f7 ff ff       	jmp    80106a55 <alltraps>

801072aa <vector45>:
.globl vector45
vector45:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $45
801072ac:	6a 2d                	push   $0x2d
  jmp alltraps
801072ae:	e9 a2 f7 ff ff       	jmp    80106a55 <alltraps>

801072b3 <vector46>:
.globl vector46
vector46:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $46
801072b5:	6a 2e                	push   $0x2e
  jmp alltraps
801072b7:	e9 99 f7 ff ff       	jmp    80106a55 <alltraps>

801072bc <vector47>:
.globl vector47
vector47:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $47
801072be:	6a 2f                	push   $0x2f
  jmp alltraps
801072c0:	e9 90 f7 ff ff       	jmp    80106a55 <alltraps>

801072c5 <vector48>:
.globl vector48
vector48:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $48
801072c7:	6a 30                	push   $0x30
  jmp alltraps
801072c9:	e9 87 f7 ff ff       	jmp    80106a55 <alltraps>

801072ce <vector49>:
.globl vector49
vector49:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $49
801072d0:	6a 31                	push   $0x31
  jmp alltraps
801072d2:	e9 7e f7 ff ff       	jmp    80106a55 <alltraps>

801072d7 <vector50>:
.globl vector50
vector50:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $50
801072d9:	6a 32                	push   $0x32
  jmp alltraps
801072db:	e9 75 f7 ff ff       	jmp    80106a55 <alltraps>

801072e0 <vector51>:
.globl vector51
vector51:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $51
801072e2:	6a 33                	push   $0x33
  jmp alltraps
801072e4:	e9 6c f7 ff ff       	jmp    80106a55 <alltraps>

801072e9 <vector52>:
.globl vector52
vector52:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $52
801072eb:	6a 34                	push   $0x34
  jmp alltraps
801072ed:	e9 63 f7 ff ff       	jmp    80106a55 <alltraps>

801072f2 <vector53>:
.globl vector53
vector53:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $53
801072f4:	6a 35                	push   $0x35
  jmp alltraps
801072f6:	e9 5a f7 ff ff       	jmp    80106a55 <alltraps>

801072fb <vector54>:
.globl vector54
vector54:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $54
801072fd:	6a 36                	push   $0x36
  jmp alltraps
801072ff:	e9 51 f7 ff ff       	jmp    80106a55 <alltraps>

80107304 <vector55>:
.globl vector55
vector55:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $55
80107306:	6a 37                	push   $0x37
  jmp alltraps
80107308:	e9 48 f7 ff ff       	jmp    80106a55 <alltraps>

8010730d <vector56>:
.globl vector56
vector56:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $56
8010730f:	6a 38                	push   $0x38
  jmp alltraps
80107311:	e9 3f f7 ff ff       	jmp    80106a55 <alltraps>

80107316 <vector57>:
.globl vector57
vector57:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $57
80107318:	6a 39                	push   $0x39
  jmp alltraps
8010731a:	e9 36 f7 ff ff       	jmp    80106a55 <alltraps>

8010731f <vector58>:
.globl vector58
vector58:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $58
80107321:	6a 3a                	push   $0x3a
  jmp alltraps
80107323:	e9 2d f7 ff ff       	jmp    80106a55 <alltraps>

80107328 <vector59>:
.globl vector59
vector59:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $59
8010732a:	6a 3b                	push   $0x3b
  jmp alltraps
8010732c:	e9 24 f7 ff ff       	jmp    80106a55 <alltraps>

80107331 <vector60>:
.globl vector60
vector60:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $60
80107333:	6a 3c                	push   $0x3c
  jmp alltraps
80107335:	e9 1b f7 ff ff       	jmp    80106a55 <alltraps>

8010733a <vector61>:
.globl vector61
vector61:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $61
8010733c:	6a 3d                	push   $0x3d
  jmp alltraps
8010733e:	e9 12 f7 ff ff       	jmp    80106a55 <alltraps>

80107343 <vector62>:
.globl vector62
vector62:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $62
80107345:	6a 3e                	push   $0x3e
  jmp alltraps
80107347:	e9 09 f7 ff ff       	jmp    80106a55 <alltraps>

8010734c <vector63>:
.globl vector63
vector63:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $63
8010734e:	6a 3f                	push   $0x3f
  jmp alltraps
80107350:	e9 00 f7 ff ff       	jmp    80106a55 <alltraps>

80107355 <vector64>:
.globl vector64
vector64:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $64
80107357:	6a 40                	push   $0x40
  jmp alltraps
80107359:	e9 f7 f6 ff ff       	jmp    80106a55 <alltraps>

8010735e <vector65>:
.globl vector65
vector65:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $65
80107360:	6a 41                	push   $0x41
  jmp alltraps
80107362:	e9 ee f6 ff ff       	jmp    80106a55 <alltraps>

80107367 <vector66>:
.globl vector66
vector66:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $66
80107369:	6a 42                	push   $0x42
  jmp alltraps
8010736b:	e9 e5 f6 ff ff       	jmp    80106a55 <alltraps>

80107370 <vector67>:
.globl vector67
vector67:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $67
80107372:	6a 43                	push   $0x43
  jmp alltraps
80107374:	e9 dc f6 ff ff       	jmp    80106a55 <alltraps>

80107379 <vector68>:
.globl vector68
vector68:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $68
8010737b:	6a 44                	push   $0x44
  jmp alltraps
8010737d:	e9 d3 f6 ff ff       	jmp    80106a55 <alltraps>

80107382 <vector69>:
.globl vector69
vector69:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $69
80107384:	6a 45                	push   $0x45
  jmp alltraps
80107386:	e9 ca f6 ff ff       	jmp    80106a55 <alltraps>

8010738b <vector70>:
.globl vector70
vector70:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $70
8010738d:	6a 46                	push   $0x46
  jmp alltraps
8010738f:	e9 c1 f6 ff ff       	jmp    80106a55 <alltraps>

80107394 <vector71>:
.globl vector71
vector71:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $71
80107396:	6a 47                	push   $0x47
  jmp alltraps
80107398:	e9 b8 f6 ff ff       	jmp    80106a55 <alltraps>

8010739d <vector72>:
.globl vector72
vector72:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $72
8010739f:	6a 48                	push   $0x48
  jmp alltraps
801073a1:	e9 af f6 ff ff       	jmp    80106a55 <alltraps>

801073a6 <vector73>:
.globl vector73
vector73:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $73
801073a8:	6a 49                	push   $0x49
  jmp alltraps
801073aa:	e9 a6 f6 ff ff       	jmp    80106a55 <alltraps>

801073af <vector74>:
.globl vector74
vector74:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $74
801073b1:	6a 4a                	push   $0x4a
  jmp alltraps
801073b3:	e9 9d f6 ff ff       	jmp    80106a55 <alltraps>

801073b8 <vector75>:
.globl vector75
vector75:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $75
801073ba:	6a 4b                	push   $0x4b
  jmp alltraps
801073bc:	e9 94 f6 ff ff       	jmp    80106a55 <alltraps>

801073c1 <vector76>:
.globl vector76
vector76:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $76
801073c3:	6a 4c                	push   $0x4c
  jmp alltraps
801073c5:	e9 8b f6 ff ff       	jmp    80106a55 <alltraps>

801073ca <vector77>:
.globl vector77
vector77:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $77
801073cc:	6a 4d                	push   $0x4d
  jmp alltraps
801073ce:	e9 82 f6 ff ff       	jmp    80106a55 <alltraps>

801073d3 <vector78>:
.globl vector78
vector78:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $78
801073d5:	6a 4e                	push   $0x4e
  jmp alltraps
801073d7:	e9 79 f6 ff ff       	jmp    80106a55 <alltraps>

801073dc <vector79>:
.globl vector79
vector79:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $79
801073de:	6a 4f                	push   $0x4f
  jmp alltraps
801073e0:	e9 70 f6 ff ff       	jmp    80106a55 <alltraps>

801073e5 <vector80>:
.globl vector80
vector80:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $80
801073e7:	6a 50                	push   $0x50
  jmp alltraps
801073e9:	e9 67 f6 ff ff       	jmp    80106a55 <alltraps>

801073ee <vector81>:
.globl vector81
vector81:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $81
801073f0:	6a 51                	push   $0x51
  jmp alltraps
801073f2:	e9 5e f6 ff ff       	jmp    80106a55 <alltraps>

801073f7 <vector82>:
.globl vector82
vector82:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $82
801073f9:	6a 52                	push   $0x52
  jmp alltraps
801073fb:	e9 55 f6 ff ff       	jmp    80106a55 <alltraps>

80107400 <vector83>:
.globl vector83
vector83:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $83
80107402:	6a 53                	push   $0x53
  jmp alltraps
80107404:	e9 4c f6 ff ff       	jmp    80106a55 <alltraps>

80107409 <vector84>:
.globl vector84
vector84:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $84
8010740b:	6a 54                	push   $0x54
  jmp alltraps
8010740d:	e9 43 f6 ff ff       	jmp    80106a55 <alltraps>

80107412 <vector85>:
.globl vector85
vector85:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $85
80107414:	6a 55                	push   $0x55
  jmp alltraps
80107416:	e9 3a f6 ff ff       	jmp    80106a55 <alltraps>

8010741b <vector86>:
.globl vector86
vector86:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $86
8010741d:	6a 56                	push   $0x56
  jmp alltraps
8010741f:	e9 31 f6 ff ff       	jmp    80106a55 <alltraps>

80107424 <vector87>:
.globl vector87
vector87:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $87
80107426:	6a 57                	push   $0x57
  jmp alltraps
80107428:	e9 28 f6 ff ff       	jmp    80106a55 <alltraps>

8010742d <vector88>:
.globl vector88
vector88:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $88
8010742f:	6a 58                	push   $0x58
  jmp alltraps
80107431:	e9 1f f6 ff ff       	jmp    80106a55 <alltraps>

80107436 <vector89>:
.globl vector89
vector89:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $89
80107438:	6a 59                	push   $0x59
  jmp alltraps
8010743a:	e9 16 f6 ff ff       	jmp    80106a55 <alltraps>

8010743f <vector90>:
.globl vector90
vector90:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $90
80107441:	6a 5a                	push   $0x5a
  jmp alltraps
80107443:	e9 0d f6 ff ff       	jmp    80106a55 <alltraps>

80107448 <vector91>:
.globl vector91
vector91:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $91
8010744a:	6a 5b                	push   $0x5b
  jmp alltraps
8010744c:	e9 04 f6 ff ff       	jmp    80106a55 <alltraps>

80107451 <vector92>:
.globl vector92
vector92:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $92
80107453:	6a 5c                	push   $0x5c
  jmp alltraps
80107455:	e9 fb f5 ff ff       	jmp    80106a55 <alltraps>

8010745a <vector93>:
.globl vector93
vector93:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $93
8010745c:	6a 5d                	push   $0x5d
  jmp alltraps
8010745e:	e9 f2 f5 ff ff       	jmp    80106a55 <alltraps>

80107463 <vector94>:
.globl vector94
vector94:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $94
80107465:	6a 5e                	push   $0x5e
  jmp alltraps
80107467:	e9 e9 f5 ff ff       	jmp    80106a55 <alltraps>

8010746c <vector95>:
.globl vector95
vector95:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $95
8010746e:	6a 5f                	push   $0x5f
  jmp alltraps
80107470:	e9 e0 f5 ff ff       	jmp    80106a55 <alltraps>

80107475 <vector96>:
.globl vector96
vector96:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $96
80107477:	6a 60                	push   $0x60
  jmp alltraps
80107479:	e9 d7 f5 ff ff       	jmp    80106a55 <alltraps>

8010747e <vector97>:
.globl vector97
vector97:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $97
80107480:	6a 61                	push   $0x61
  jmp alltraps
80107482:	e9 ce f5 ff ff       	jmp    80106a55 <alltraps>

80107487 <vector98>:
.globl vector98
vector98:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $98
80107489:	6a 62                	push   $0x62
  jmp alltraps
8010748b:	e9 c5 f5 ff ff       	jmp    80106a55 <alltraps>

80107490 <vector99>:
.globl vector99
vector99:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $99
80107492:	6a 63                	push   $0x63
  jmp alltraps
80107494:	e9 bc f5 ff ff       	jmp    80106a55 <alltraps>

80107499 <vector100>:
.globl vector100
vector100:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $100
8010749b:	6a 64                	push   $0x64
  jmp alltraps
8010749d:	e9 b3 f5 ff ff       	jmp    80106a55 <alltraps>

801074a2 <vector101>:
.globl vector101
vector101:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $101
801074a4:	6a 65                	push   $0x65
  jmp alltraps
801074a6:	e9 aa f5 ff ff       	jmp    80106a55 <alltraps>

801074ab <vector102>:
.globl vector102
vector102:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $102
801074ad:	6a 66                	push   $0x66
  jmp alltraps
801074af:	e9 a1 f5 ff ff       	jmp    80106a55 <alltraps>

801074b4 <vector103>:
.globl vector103
vector103:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $103
801074b6:	6a 67                	push   $0x67
  jmp alltraps
801074b8:	e9 98 f5 ff ff       	jmp    80106a55 <alltraps>

801074bd <vector104>:
.globl vector104
vector104:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $104
801074bf:	6a 68                	push   $0x68
  jmp alltraps
801074c1:	e9 8f f5 ff ff       	jmp    80106a55 <alltraps>

801074c6 <vector105>:
.globl vector105
vector105:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $105
801074c8:	6a 69                	push   $0x69
  jmp alltraps
801074ca:	e9 86 f5 ff ff       	jmp    80106a55 <alltraps>

801074cf <vector106>:
.globl vector106
vector106:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $106
801074d1:	6a 6a                	push   $0x6a
  jmp alltraps
801074d3:	e9 7d f5 ff ff       	jmp    80106a55 <alltraps>

801074d8 <vector107>:
.globl vector107
vector107:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $107
801074da:	6a 6b                	push   $0x6b
  jmp alltraps
801074dc:	e9 74 f5 ff ff       	jmp    80106a55 <alltraps>

801074e1 <vector108>:
.globl vector108
vector108:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $108
801074e3:	6a 6c                	push   $0x6c
  jmp alltraps
801074e5:	e9 6b f5 ff ff       	jmp    80106a55 <alltraps>

801074ea <vector109>:
.globl vector109
vector109:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $109
801074ec:	6a 6d                	push   $0x6d
  jmp alltraps
801074ee:	e9 62 f5 ff ff       	jmp    80106a55 <alltraps>

801074f3 <vector110>:
.globl vector110
vector110:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $110
801074f5:	6a 6e                	push   $0x6e
  jmp alltraps
801074f7:	e9 59 f5 ff ff       	jmp    80106a55 <alltraps>

801074fc <vector111>:
.globl vector111
vector111:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $111
801074fe:	6a 6f                	push   $0x6f
  jmp alltraps
80107500:	e9 50 f5 ff ff       	jmp    80106a55 <alltraps>

80107505 <vector112>:
.globl vector112
vector112:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $112
80107507:	6a 70                	push   $0x70
  jmp alltraps
80107509:	e9 47 f5 ff ff       	jmp    80106a55 <alltraps>

8010750e <vector113>:
.globl vector113
vector113:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $113
80107510:	6a 71                	push   $0x71
  jmp alltraps
80107512:	e9 3e f5 ff ff       	jmp    80106a55 <alltraps>

80107517 <vector114>:
.globl vector114
vector114:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $114
80107519:	6a 72                	push   $0x72
  jmp alltraps
8010751b:	e9 35 f5 ff ff       	jmp    80106a55 <alltraps>

80107520 <vector115>:
.globl vector115
vector115:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $115
80107522:	6a 73                	push   $0x73
  jmp alltraps
80107524:	e9 2c f5 ff ff       	jmp    80106a55 <alltraps>

80107529 <vector116>:
.globl vector116
vector116:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $116
8010752b:	6a 74                	push   $0x74
  jmp alltraps
8010752d:	e9 23 f5 ff ff       	jmp    80106a55 <alltraps>

80107532 <vector117>:
.globl vector117
vector117:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $117
80107534:	6a 75                	push   $0x75
  jmp alltraps
80107536:	e9 1a f5 ff ff       	jmp    80106a55 <alltraps>

8010753b <vector118>:
.globl vector118
vector118:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $118
8010753d:	6a 76                	push   $0x76
  jmp alltraps
8010753f:	e9 11 f5 ff ff       	jmp    80106a55 <alltraps>

80107544 <vector119>:
.globl vector119
vector119:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $119
80107546:	6a 77                	push   $0x77
  jmp alltraps
80107548:	e9 08 f5 ff ff       	jmp    80106a55 <alltraps>

8010754d <vector120>:
.globl vector120
vector120:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $120
8010754f:	6a 78                	push   $0x78
  jmp alltraps
80107551:	e9 ff f4 ff ff       	jmp    80106a55 <alltraps>

80107556 <vector121>:
.globl vector121
vector121:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $121
80107558:	6a 79                	push   $0x79
  jmp alltraps
8010755a:	e9 f6 f4 ff ff       	jmp    80106a55 <alltraps>

8010755f <vector122>:
.globl vector122
vector122:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $122
80107561:	6a 7a                	push   $0x7a
  jmp alltraps
80107563:	e9 ed f4 ff ff       	jmp    80106a55 <alltraps>

80107568 <vector123>:
.globl vector123
vector123:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $123
8010756a:	6a 7b                	push   $0x7b
  jmp alltraps
8010756c:	e9 e4 f4 ff ff       	jmp    80106a55 <alltraps>

80107571 <vector124>:
.globl vector124
vector124:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $124
80107573:	6a 7c                	push   $0x7c
  jmp alltraps
80107575:	e9 db f4 ff ff       	jmp    80106a55 <alltraps>

8010757a <vector125>:
.globl vector125
vector125:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $125
8010757c:	6a 7d                	push   $0x7d
  jmp alltraps
8010757e:	e9 d2 f4 ff ff       	jmp    80106a55 <alltraps>

80107583 <vector126>:
.globl vector126
vector126:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $126
80107585:	6a 7e                	push   $0x7e
  jmp alltraps
80107587:	e9 c9 f4 ff ff       	jmp    80106a55 <alltraps>

8010758c <vector127>:
.globl vector127
vector127:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $127
8010758e:	6a 7f                	push   $0x7f
  jmp alltraps
80107590:	e9 c0 f4 ff ff       	jmp    80106a55 <alltraps>

80107595 <vector128>:
.globl vector128
vector128:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $128
80107597:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010759c:	e9 b4 f4 ff ff       	jmp    80106a55 <alltraps>

801075a1 <vector129>:
.globl vector129
vector129:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $129
801075a3:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075a8:	e9 a8 f4 ff ff       	jmp    80106a55 <alltraps>

801075ad <vector130>:
.globl vector130
vector130:
  pushl $0
801075ad:	6a 00                	push   $0x0
  pushl $130
801075af:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075b4:	e9 9c f4 ff ff       	jmp    80106a55 <alltraps>

801075b9 <vector131>:
.globl vector131
vector131:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $131
801075bb:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075c0:	e9 90 f4 ff ff       	jmp    80106a55 <alltraps>

801075c5 <vector132>:
.globl vector132
vector132:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $132
801075c7:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801075cc:	e9 84 f4 ff ff       	jmp    80106a55 <alltraps>

801075d1 <vector133>:
.globl vector133
vector133:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $133
801075d3:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801075d8:	e9 78 f4 ff ff       	jmp    80106a55 <alltraps>

801075dd <vector134>:
.globl vector134
vector134:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $134
801075df:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801075e4:	e9 6c f4 ff ff       	jmp    80106a55 <alltraps>

801075e9 <vector135>:
.globl vector135
vector135:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $135
801075eb:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801075f0:	e9 60 f4 ff ff       	jmp    80106a55 <alltraps>

801075f5 <vector136>:
.globl vector136
vector136:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $136
801075f7:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801075fc:	e9 54 f4 ff ff       	jmp    80106a55 <alltraps>

80107601 <vector137>:
.globl vector137
vector137:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $137
80107603:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107608:	e9 48 f4 ff ff       	jmp    80106a55 <alltraps>

8010760d <vector138>:
.globl vector138
vector138:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $138
8010760f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107614:	e9 3c f4 ff ff       	jmp    80106a55 <alltraps>

80107619 <vector139>:
.globl vector139
vector139:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $139
8010761b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107620:	e9 30 f4 ff ff       	jmp    80106a55 <alltraps>

80107625 <vector140>:
.globl vector140
vector140:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $140
80107627:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010762c:	e9 24 f4 ff ff       	jmp    80106a55 <alltraps>

80107631 <vector141>:
.globl vector141
vector141:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $141
80107633:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107638:	e9 18 f4 ff ff       	jmp    80106a55 <alltraps>

8010763d <vector142>:
.globl vector142
vector142:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $142
8010763f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107644:	e9 0c f4 ff ff       	jmp    80106a55 <alltraps>

80107649 <vector143>:
.globl vector143
vector143:
  pushl $0
80107649:	6a 00                	push   $0x0
  pushl $143
8010764b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107650:	e9 00 f4 ff ff       	jmp    80106a55 <alltraps>

80107655 <vector144>:
.globl vector144
vector144:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $144
80107657:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010765c:	e9 f4 f3 ff ff       	jmp    80106a55 <alltraps>

80107661 <vector145>:
.globl vector145
vector145:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $145
80107663:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107668:	e9 e8 f3 ff ff       	jmp    80106a55 <alltraps>

8010766d <vector146>:
.globl vector146
vector146:
  pushl $0
8010766d:	6a 00                	push   $0x0
  pushl $146
8010766f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107674:	e9 dc f3 ff ff       	jmp    80106a55 <alltraps>

80107679 <vector147>:
.globl vector147
vector147:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $147
8010767b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107680:	e9 d0 f3 ff ff       	jmp    80106a55 <alltraps>

80107685 <vector148>:
.globl vector148
vector148:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $148
80107687:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010768c:	e9 c4 f3 ff ff       	jmp    80106a55 <alltraps>

80107691 <vector149>:
.globl vector149
vector149:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $149
80107693:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107698:	e9 b8 f3 ff ff       	jmp    80106a55 <alltraps>

8010769d <vector150>:
.globl vector150
vector150:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $150
8010769f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076a4:	e9 ac f3 ff ff       	jmp    80106a55 <alltraps>

801076a9 <vector151>:
.globl vector151
vector151:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $151
801076ab:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076b0:	e9 a0 f3 ff ff       	jmp    80106a55 <alltraps>

801076b5 <vector152>:
.globl vector152
vector152:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $152
801076b7:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076bc:	e9 94 f3 ff ff       	jmp    80106a55 <alltraps>

801076c1 <vector153>:
.globl vector153
vector153:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $153
801076c3:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801076c8:	e9 88 f3 ff ff       	jmp    80106a55 <alltraps>

801076cd <vector154>:
.globl vector154
vector154:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $154
801076cf:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801076d4:	e9 7c f3 ff ff       	jmp    80106a55 <alltraps>

801076d9 <vector155>:
.globl vector155
vector155:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $155
801076db:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801076e0:	e9 70 f3 ff ff       	jmp    80106a55 <alltraps>

801076e5 <vector156>:
.globl vector156
vector156:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $156
801076e7:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801076ec:	e9 64 f3 ff ff       	jmp    80106a55 <alltraps>

801076f1 <vector157>:
.globl vector157
vector157:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $157
801076f3:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801076f8:	e9 58 f3 ff ff       	jmp    80106a55 <alltraps>

801076fd <vector158>:
.globl vector158
vector158:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $158
801076ff:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107704:	e9 4c f3 ff ff       	jmp    80106a55 <alltraps>

80107709 <vector159>:
.globl vector159
vector159:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $159
8010770b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107710:	e9 40 f3 ff ff       	jmp    80106a55 <alltraps>

80107715 <vector160>:
.globl vector160
vector160:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $160
80107717:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010771c:	e9 34 f3 ff ff       	jmp    80106a55 <alltraps>

80107721 <vector161>:
.globl vector161
vector161:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $161
80107723:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107728:	e9 28 f3 ff ff       	jmp    80106a55 <alltraps>

8010772d <vector162>:
.globl vector162
vector162:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $162
8010772f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107734:	e9 1c f3 ff ff       	jmp    80106a55 <alltraps>

80107739 <vector163>:
.globl vector163
vector163:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $163
8010773b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107740:	e9 10 f3 ff ff       	jmp    80106a55 <alltraps>

80107745 <vector164>:
.globl vector164
vector164:
  pushl $0
80107745:	6a 00                	push   $0x0
  pushl $164
80107747:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010774c:	e9 04 f3 ff ff       	jmp    80106a55 <alltraps>

80107751 <vector165>:
.globl vector165
vector165:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $165
80107753:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107758:	e9 f8 f2 ff ff       	jmp    80106a55 <alltraps>

8010775d <vector166>:
.globl vector166
vector166:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $166
8010775f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107764:	e9 ec f2 ff ff       	jmp    80106a55 <alltraps>

80107769 <vector167>:
.globl vector167
vector167:
  pushl $0
80107769:	6a 00                	push   $0x0
  pushl $167
8010776b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107770:	e9 e0 f2 ff ff       	jmp    80106a55 <alltraps>

80107775 <vector168>:
.globl vector168
vector168:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $168
80107777:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010777c:	e9 d4 f2 ff ff       	jmp    80106a55 <alltraps>

80107781 <vector169>:
.globl vector169
vector169:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $169
80107783:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107788:	e9 c8 f2 ff ff       	jmp    80106a55 <alltraps>

8010778d <vector170>:
.globl vector170
vector170:
  pushl $0
8010778d:	6a 00                	push   $0x0
  pushl $170
8010778f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107794:	e9 bc f2 ff ff       	jmp    80106a55 <alltraps>

80107799 <vector171>:
.globl vector171
vector171:
  pushl $0
80107799:	6a 00                	push   $0x0
  pushl $171
8010779b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077a0:	e9 b0 f2 ff ff       	jmp    80106a55 <alltraps>

801077a5 <vector172>:
.globl vector172
vector172:
  pushl $0
801077a5:	6a 00                	push   $0x0
  pushl $172
801077a7:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077ac:	e9 a4 f2 ff ff       	jmp    80106a55 <alltraps>

801077b1 <vector173>:
.globl vector173
vector173:
  pushl $0
801077b1:	6a 00                	push   $0x0
  pushl $173
801077b3:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077b8:	e9 98 f2 ff ff       	jmp    80106a55 <alltraps>

801077bd <vector174>:
.globl vector174
vector174:
  pushl $0
801077bd:	6a 00                	push   $0x0
  pushl $174
801077bf:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801077c4:	e9 8c f2 ff ff       	jmp    80106a55 <alltraps>

801077c9 <vector175>:
.globl vector175
vector175:
  pushl $0
801077c9:	6a 00                	push   $0x0
  pushl $175
801077cb:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801077d0:	e9 80 f2 ff ff       	jmp    80106a55 <alltraps>

801077d5 <vector176>:
.globl vector176
vector176:
  pushl $0
801077d5:	6a 00                	push   $0x0
  pushl $176
801077d7:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801077dc:	e9 74 f2 ff ff       	jmp    80106a55 <alltraps>

801077e1 <vector177>:
.globl vector177
vector177:
  pushl $0
801077e1:	6a 00                	push   $0x0
  pushl $177
801077e3:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801077e8:	e9 68 f2 ff ff       	jmp    80106a55 <alltraps>

801077ed <vector178>:
.globl vector178
vector178:
  pushl $0
801077ed:	6a 00                	push   $0x0
  pushl $178
801077ef:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801077f4:	e9 5c f2 ff ff       	jmp    80106a55 <alltraps>

801077f9 <vector179>:
.globl vector179
vector179:
  pushl $0
801077f9:	6a 00                	push   $0x0
  pushl $179
801077fb:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107800:	e9 50 f2 ff ff       	jmp    80106a55 <alltraps>

80107805 <vector180>:
.globl vector180
vector180:
  pushl $0
80107805:	6a 00                	push   $0x0
  pushl $180
80107807:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010780c:	e9 44 f2 ff ff       	jmp    80106a55 <alltraps>

80107811 <vector181>:
.globl vector181
vector181:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $181
80107813:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107818:	e9 38 f2 ff ff       	jmp    80106a55 <alltraps>

8010781d <vector182>:
.globl vector182
vector182:
  pushl $0
8010781d:	6a 00                	push   $0x0
  pushl $182
8010781f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107824:	e9 2c f2 ff ff       	jmp    80106a55 <alltraps>

80107829 <vector183>:
.globl vector183
vector183:
  pushl $0
80107829:	6a 00                	push   $0x0
  pushl $183
8010782b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107830:	e9 20 f2 ff ff       	jmp    80106a55 <alltraps>

80107835 <vector184>:
.globl vector184
vector184:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $184
80107837:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010783c:	e9 14 f2 ff ff       	jmp    80106a55 <alltraps>

80107841 <vector185>:
.globl vector185
vector185:
  pushl $0
80107841:	6a 00                	push   $0x0
  pushl $185
80107843:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107848:	e9 08 f2 ff ff       	jmp    80106a55 <alltraps>

8010784d <vector186>:
.globl vector186
vector186:
  pushl $0
8010784d:	6a 00                	push   $0x0
  pushl $186
8010784f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107854:	e9 fc f1 ff ff       	jmp    80106a55 <alltraps>

80107859 <vector187>:
.globl vector187
vector187:
  pushl $0
80107859:	6a 00                	push   $0x0
  pushl $187
8010785b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107860:	e9 f0 f1 ff ff       	jmp    80106a55 <alltraps>

80107865 <vector188>:
.globl vector188
vector188:
  pushl $0
80107865:	6a 00                	push   $0x0
  pushl $188
80107867:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010786c:	e9 e4 f1 ff ff       	jmp    80106a55 <alltraps>

80107871 <vector189>:
.globl vector189
vector189:
  pushl $0
80107871:	6a 00                	push   $0x0
  pushl $189
80107873:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107878:	e9 d8 f1 ff ff       	jmp    80106a55 <alltraps>

8010787d <vector190>:
.globl vector190
vector190:
  pushl $0
8010787d:	6a 00                	push   $0x0
  pushl $190
8010787f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107884:	e9 cc f1 ff ff       	jmp    80106a55 <alltraps>

80107889 <vector191>:
.globl vector191
vector191:
  pushl $0
80107889:	6a 00                	push   $0x0
  pushl $191
8010788b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107890:	e9 c0 f1 ff ff       	jmp    80106a55 <alltraps>

80107895 <vector192>:
.globl vector192
vector192:
  pushl $0
80107895:	6a 00                	push   $0x0
  pushl $192
80107897:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010789c:	e9 b4 f1 ff ff       	jmp    80106a55 <alltraps>

801078a1 <vector193>:
.globl vector193
vector193:
  pushl $0
801078a1:	6a 00                	push   $0x0
  pushl $193
801078a3:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078a8:	e9 a8 f1 ff ff       	jmp    80106a55 <alltraps>

801078ad <vector194>:
.globl vector194
vector194:
  pushl $0
801078ad:	6a 00                	push   $0x0
  pushl $194
801078af:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078b4:	e9 9c f1 ff ff       	jmp    80106a55 <alltraps>

801078b9 <vector195>:
.globl vector195
vector195:
  pushl $0
801078b9:	6a 00                	push   $0x0
  pushl $195
801078bb:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078c0:	e9 90 f1 ff ff       	jmp    80106a55 <alltraps>

801078c5 <vector196>:
.globl vector196
vector196:
  pushl $0
801078c5:	6a 00                	push   $0x0
  pushl $196
801078c7:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801078cc:	e9 84 f1 ff ff       	jmp    80106a55 <alltraps>

801078d1 <vector197>:
.globl vector197
vector197:
  pushl $0
801078d1:	6a 00                	push   $0x0
  pushl $197
801078d3:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801078d8:	e9 78 f1 ff ff       	jmp    80106a55 <alltraps>

801078dd <vector198>:
.globl vector198
vector198:
  pushl $0
801078dd:	6a 00                	push   $0x0
  pushl $198
801078df:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801078e4:	e9 6c f1 ff ff       	jmp    80106a55 <alltraps>

801078e9 <vector199>:
.globl vector199
vector199:
  pushl $0
801078e9:	6a 00                	push   $0x0
  pushl $199
801078eb:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801078f0:	e9 60 f1 ff ff       	jmp    80106a55 <alltraps>

801078f5 <vector200>:
.globl vector200
vector200:
  pushl $0
801078f5:	6a 00                	push   $0x0
  pushl $200
801078f7:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801078fc:	e9 54 f1 ff ff       	jmp    80106a55 <alltraps>

80107901 <vector201>:
.globl vector201
vector201:
  pushl $0
80107901:	6a 00                	push   $0x0
  pushl $201
80107903:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107908:	e9 48 f1 ff ff       	jmp    80106a55 <alltraps>

8010790d <vector202>:
.globl vector202
vector202:
  pushl $0
8010790d:	6a 00                	push   $0x0
  pushl $202
8010790f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107914:	e9 3c f1 ff ff       	jmp    80106a55 <alltraps>

80107919 <vector203>:
.globl vector203
vector203:
  pushl $0
80107919:	6a 00                	push   $0x0
  pushl $203
8010791b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107920:	e9 30 f1 ff ff       	jmp    80106a55 <alltraps>

80107925 <vector204>:
.globl vector204
vector204:
  pushl $0
80107925:	6a 00                	push   $0x0
  pushl $204
80107927:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010792c:	e9 24 f1 ff ff       	jmp    80106a55 <alltraps>

80107931 <vector205>:
.globl vector205
vector205:
  pushl $0
80107931:	6a 00                	push   $0x0
  pushl $205
80107933:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107938:	e9 18 f1 ff ff       	jmp    80106a55 <alltraps>

8010793d <vector206>:
.globl vector206
vector206:
  pushl $0
8010793d:	6a 00                	push   $0x0
  pushl $206
8010793f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107944:	e9 0c f1 ff ff       	jmp    80106a55 <alltraps>

80107949 <vector207>:
.globl vector207
vector207:
  pushl $0
80107949:	6a 00                	push   $0x0
  pushl $207
8010794b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107950:	e9 00 f1 ff ff       	jmp    80106a55 <alltraps>

80107955 <vector208>:
.globl vector208
vector208:
  pushl $0
80107955:	6a 00                	push   $0x0
  pushl $208
80107957:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010795c:	e9 f4 f0 ff ff       	jmp    80106a55 <alltraps>

80107961 <vector209>:
.globl vector209
vector209:
  pushl $0
80107961:	6a 00                	push   $0x0
  pushl $209
80107963:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107968:	e9 e8 f0 ff ff       	jmp    80106a55 <alltraps>

8010796d <vector210>:
.globl vector210
vector210:
  pushl $0
8010796d:	6a 00                	push   $0x0
  pushl $210
8010796f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107974:	e9 dc f0 ff ff       	jmp    80106a55 <alltraps>

80107979 <vector211>:
.globl vector211
vector211:
  pushl $0
80107979:	6a 00                	push   $0x0
  pushl $211
8010797b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107980:	e9 d0 f0 ff ff       	jmp    80106a55 <alltraps>

80107985 <vector212>:
.globl vector212
vector212:
  pushl $0
80107985:	6a 00                	push   $0x0
  pushl $212
80107987:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010798c:	e9 c4 f0 ff ff       	jmp    80106a55 <alltraps>

80107991 <vector213>:
.globl vector213
vector213:
  pushl $0
80107991:	6a 00                	push   $0x0
  pushl $213
80107993:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107998:	e9 b8 f0 ff ff       	jmp    80106a55 <alltraps>

8010799d <vector214>:
.globl vector214
vector214:
  pushl $0
8010799d:	6a 00                	push   $0x0
  pushl $214
8010799f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079a4:	e9 ac f0 ff ff       	jmp    80106a55 <alltraps>

801079a9 <vector215>:
.globl vector215
vector215:
  pushl $0
801079a9:	6a 00                	push   $0x0
  pushl $215
801079ab:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079b0:	e9 a0 f0 ff ff       	jmp    80106a55 <alltraps>

801079b5 <vector216>:
.globl vector216
vector216:
  pushl $0
801079b5:	6a 00                	push   $0x0
  pushl $216
801079b7:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079bc:	e9 94 f0 ff ff       	jmp    80106a55 <alltraps>

801079c1 <vector217>:
.globl vector217
vector217:
  pushl $0
801079c1:	6a 00                	push   $0x0
  pushl $217
801079c3:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801079c8:	e9 88 f0 ff ff       	jmp    80106a55 <alltraps>

801079cd <vector218>:
.globl vector218
vector218:
  pushl $0
801079cd:	6a 00                	push   $0x0
  pushl $218
801079cf:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801079d4:	e9 7c f0 ff ff       	jmp    80106a55 <alltraps>

801079d9 <vector219>:
.globl vector219
vector219:
  pushl $0
801079d9:	6a 00                	push   $0x0
  pushl $219
801079db:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801079e0:	e9 70 f0 ff ff       	jmp    80106a55 <alltraps>

801079e5 <vector220>:
.globl vector220
vector220:
  pushl $0
801079e5:	6a 00                	push   $0x0
  pushl $220
801079e7:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801079ec:	e9 64 f0 ff ff       	jmp    80106a55 <alltraps>

801079f1 <vector221>:
.globl vector221
vector221:
  pushl $0
801079f1:	6a 00                	push   $0x0
  pushl $221
801079f3:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801079f8:	e9 58 f0 ff ff       	jmp    80106a55 <alltraps>

801079fd <vector222>:
.globl vector222
vector222:
  pushl $0
801079fd:	6a 00                	push   $0x0
  pushl $222
801079ff:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a04:	e9 4c f0 ff ff       	jmp    80106a55 <alltraps>

80107a09 <vector223>:
.globl vector223
vector223:
  pushl $0
80107a09:	6a 00                	push   $0x0
  pushl $223
80107a0b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a10:	e9 40 f0 ff ff       	jmp    80106a55 <alltraps>

80107a15 <vector224>:
.globl vector224
vector224:
  pushl $0
80107a15:	6a 00                	push   $0x0
  pushl $224
80107a17:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a1c:	e9 34 f0 ff ff       	jmp    80106a55 <alltraps>

80107a21 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a21:	6a 00                	push   $0x0
  pushl $225
80107a23:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a28:	e9 28 f0 ff ff       	jmp    80106a55 <alltraps>

80107a2d <vector226>:
.globl vector226
vector226:
  pushl $0
80107a2d:	6a 00                	push   $0x0
  pushl $226
80107a2f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a34:	e9 1c f0 ff ff       	jmp    80106a55 <alltraps>

80107a39 <vector227>:
.globl vector227
vector227:
  pushl $0
80107a39:	6a 00                	push   $0x0
  pushl $227
80107a3b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a40:	e9 10 f0 ff ff       	jmp    80106a55 <alltraps>

80107a45 <vector228>:
.globl vector228
vector228:
  pushl $0
80107a45:	6a 00                	push   $0x0
  pushl $228
80107a47:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a4c:	e9 04 f0 ff ff       	jmp    80106a55 <alltraps>

80107a51 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a51:	6a 00                	push   $0x0
  pushl $229
80107a53:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a58:	e9 f8 ef ff ff       	jmp    80106a55 <alltraps>

80107a5d <vector230>:
.globl vector230
vector230:
  pushl $0
80107a5d:	6a 00                	push   $0x0
  pushl $230
80107a5f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a64:	e9 ec ef ff ff       	jmp    80106a55 <alltraps>

80107a69 <vector231>:
.globl vector231
vector231:
  pushl $0
80107a69:	6a 00                	push   $0x0
  pushl $231
80107a6b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a70:	e9 e0 ef ff ff       	jmp    80106a55 <alltraps>

80107a75 <vector232>:
.globl vector232
vector232:
  pushl $0
80107a75:	6a 00                	push   $0x0
  pushl $232
80107a77:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107a7c:	e9 d4 ef ff ff       	jmp    80106a55 <alltraps>

80107a81 <vector233>:
.globl vector233
vector233:
  pushl $0
80107a81:	6a 00                	push   $0x0
  pushl $233
80107a83:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107a88:	e9 c8 ef ff ff       	jmp    80106a55 <alltraps>

80107a8d <vector234>:
.globl vector234
vector234:
  pushl $0
80107a8d:	6a 00                	push   $0x0
  pushl $234
80107a8f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107a94:	e9 bc ef ff ff       	jmp    80106a55 <alltraps>

80107a99 <vector235>:
.globl vector235
vector235:
  pushl $0
80107a99:	6a 00                	push   $0x0
  pushl $235
80107a9b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107aa0:	e9 b0 ef ff ff       	jmp    80106a55 <alltraps>

80107aa5 <vector236>:
.globl vector236
vector236:
  pushl $0
80107aa5:	6a 00                	push   $0x0
  pushl $236
80107aa7:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107aac:	e9 a4 ef ff ff       	jmp    80106a55 <alltraps>

80107ab1 <vector237>:
.globl vector237
vector237:
  pushl $0
80107ab1:	6a 00                	push   $0x0
  pushl $237
80107ab3:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107ab8:	e9 98 ef ff ff       	jmp    80106a55 <alltraps>

80107abd <vector238>:
.globl vector238
vector238:
  pushl $0
80107abd:	6a 00                	push   $0x0
  pushl $238
80107abf:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107ac4:	e9 8c ef ff ff       	jmp    80106a55 <alltraps>

80107ac9 <vector239>:
.globl vector239
vector239:
  pushl $0
80107ac9:	6a 00                	push   $0x0
  pushl $239
80107acb:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107ad0:	e9 80 ef ff ff       	jmp    80106a55 <alltraps>

80107ad5 <vector240>:
.globl vector240
vector240:
  pushl $0
80107ad5:	6a 00                	push   $0x0
  pushl $240
80107ad7:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107adc:	e9 74 ef ff ff       	jmp    80106a55 <alltraps>

80107ae1 <vector241>:
.globl vector241
vector241:
  pushl $0
80107ae1:	6a 00                	push   $0x0
  pushl $241
80107ae3:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107ae8:	e9 68 ef ff ff       	jmp    80106a55 <alltraps>

80107aed <vector242>:
.globl vector242
vector242:
  pushl $0
80107aed:	6a 00                	push   $0x0
  pushl $242
80107aef:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107af4:	e9 5c ef ff ff       	jmp    80106a55 <alltraps>

80107af9 <vector243>:
.globl vector243
vector243:
  pushl $0
80107af9:	6a 00                	push   $0x0
  pushl $243
80107afb:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b00:	e9 50 ef ff ff       	jmp    80106a55 <alltraps>

80107b05 <vector244>:
.globl vector244
vector244:
  pushl $0
80107b05:	6a 00                	push   $0x0
  pushl $244
80107b07:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b0c:	e9 44 ef ff ff       	jmp    80106a55 <alltraps>

80107b11 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b11:	6a 00                	push   $0x0
  pushl $245
80107b13:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b18:	e9 38 ef ff ff       	jmp    80106a55 <alltraps>

80107b1d <vector246>:
.globl vector246
vector246:
  pushl $0
80107b1d:	6a 00                	push   $0x0
  pushl $246
80107b1f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b24:	e9 2c ef ff ff       	jmp    80106a55 <alltraps>

80107b29 <vector247>:
.globl vector247
vector247:
  pushl $0
80107b29:	6a 00                	push   $0x0
  pushl $247
80107b2b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b30:	e9 20 ef ff ff       	jmp    80106a55 <alltraps>

80107b35 <vector248>:
.globl vector248
vector248:
  pushl $0
80107b35:	6a 00                	push   $0x0
  pushl $248
80107b37:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b3c:	e9 14 ef ff ff       	jmp    80106a55 <alltraps>

80107b41 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b41:	6a 00                	push   $0x0
  pushl $249
80107b43:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b48:	e9 08 ef ff ff       	jmp    80106a55 <alltraps>

80107b4d <vector250>:
.globl vector250
vector250:
  pushl $0
80107b4d:	6a 00                	push   $0x0
  pushl $250
80107b4f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b54:	e9 fc ee ff ff       	jmp    80106a55 <alltraps>

80107b59 <vector251>:
.globl vector251
vector251:
  pushl $0
80107b59:	6a 00                	push   $0x0
  pushl $251
80107b5b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b60:	e9 f0 ee ff ff       	jmp    80106a55 <alltraps>

80107b65 <vector252>:
.globl vector252
vector252:
  pushl $0
80107b65:	6a 00                	push   $0x0
  pushl $252
80107b67:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b6c:	e9 e4 ee ff ff       	jmp    80106a55 <alltraps>

80107b71 <vector253>:
.globl vector253
vector253:
  pushl $0
80107b71:	6a 00                	push   $0x0
  pushl $253
80107b73:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b78:	e9 d8 ee ff ff       	jmp    80106a55 <alltraps>

80107b7d <vector254>:
.globl vector254
vector254:
  pushl $0
80107b7d:	6a 00                	push   $0x0
  pushl $254
80107b7f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107b84:	e9 cc ee ff ff       	jmp    80106a55 <alltraps>

80107b89 <vector255>:
.globl vector255
vector255:
  pushl $0
80107b89:	6a 00                	push   $0x0
  pushl $255
80107b8b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107b90:	e9 c0 ee ff ff       	jmp    80106a55 <alltraps>

80107b95 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107b95:	55                   	push   %ebp
80107b96:	89 e5                	mov    %esp,%ebp
80107b98:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b9e:	83 e8 01             	sub    $0x1,%eax
80107ba1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ba8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bac:	8b 45 08             	mov    0x8(%ebp),%eax
80107baf:	c1 e8 10             	shr    $0x10,%eax
80107bb2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107bb6:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bb9:	0f 01 10             	lgdtl  (%eax)
}
80107bbc:	90                   	nop
80107bbd:	c9                   	leave  
80107bbe:	c3                   	ret    

80107bbf <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107bbf:	55                   	push   %ebp
80107bc0:	89 e5                	mov    %esp,%ebp
80107bc2:	83 ec 04             	sub    $0x4,%esp
80107bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80107bc8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107bcc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107bd0:	0f 00 d8             	ltr    %ax
}
80107bd3:	90                   	nop
80107bd4:	c9                   	leave  
80107bd5:	c3                   	ret    

80107bd6 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107bd6:	55                   	push   %ebp
80107bd7:	89 e5                	mov    %esp,%ebp
80107bd9:	83 ec 04             	sub    $0x4,%esp
80107bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80107bdf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107be3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107be7:	8e e8                	mov    %eax,%gs
}
80107be9:	90                   	nop
80107bea:	c9                   	leave  
80107beb:	c3                   	ret    

80107bec <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107bec:	55                   	push   %ebp
80107bed:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107bef:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf2:	0f 22 d8             	mov    %eax,%cr3
}
80107bf5:	90                   	nop
80107bf6:	5d                   	pop    %ebp
80107bf7:	c3                   	ret    

80107bf8 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107bf8:	55                   	push   %ebp
80107bf9:	89 e5                	mov    %esp,%ebp
80107bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80107bfe:	05 00 00 00 80       	add    $0x80000000,%eax
80107c03:	5d                   	pop    %ebp
80107c04:	c3                   	ret    

80107c05 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107c05:	55                   	push   %ebp
80107c06:	89 e5                	mov    %esp,%ebp
80107c08:	8b 45 08             	mov    0x8(%ebp),%eax
80107c0b:	05 00 00 00 80       	add    $0x80000000,%eax
80107c10:	5d                   	pop    %ebp
80107c11:	c3                   	ret    

80107c12 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c12:	55                   	push   %ebp
80107c13:	89 e5                	mov    %esp,%ebp
80107c15:	53                   	push   %ebx
80107c16:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107c19:	e8 a8 b7 ff ff       	call   801033c6 <cpunum>
80107c1e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107c24:	05 60 33 11 80       	add    $0x80113360,%eax
80107c29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2f:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c38:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c41:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c4c:	83 e2 f0             	and    $0xfffffff0,%edx
80107c4f:	83 ca 0a             	or     $0xa,%edx
80107c52:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c58:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c5c:	83 ca 10             	or     $0x10,%edx
80107c5f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c65:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c69:	83 e2 9f             	and    $0xffffff9f,%edx
80107c6c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c72:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c76:	83 ca 80             	or     $0xffffff80,%edx
80107c79:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c83:	83 ca 0f             	or     $0xf,%edx
80107c86:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c90:	83 e2 ef             	and    $0xffffffef,%edx
80107c93:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c99:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c9d:	83 e2 df             	and    $0xffffffdf,%edx
80107ca0:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107caa:	83 ca 40             	or     $0x40,%edx
80107cad:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cb7:	83 ca 80             	or     $0xffffff80,%edx
80107cba:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc0:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc7:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107cce:	ff ff 
80107cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd3:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107cda:	00 00 
80107cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdf:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cf0:	83 e2 f0             	and    $0xfffffff0,%edx
80107cf3:	83 ca 02             	or     $0x2,%edx
80107cf6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cff:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d06:	83 ca 10             	or     $0x10,%edx
80107d09:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d12:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d19:	83 e2 9f             	and    $0xffffff9f,%edx
80107d1c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d25:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d2c:	83 ca 80             	or     $0xffffff80,%edx
80107d2f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d38:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d3f:	83 ca 0f             	or     $0xf,%edx
80107d42:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d52:	83 e2 ef             	and    $0xffffffef,%edx
80107d55:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d65:	83 e2 df             	and    $0xffffffdf,%edx
80107d68:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d71:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d78:	83 ca 40             	or     $0x40,%edx
80107d7b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d84:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d8b:	83 ca 80             	or     $0xffffff80,%edx
80107d8e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d97:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da1:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107da8:	ff ff 
80107daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dad:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107db4:	00 00 
80107db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db9:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107dca:	83 e2 f0             	and    $0xfffffff0,%edx
80107dcd:	83 ca 0a             	or     $0xa,%edx
80107dd0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107de0:	83 ca 10             	or     $0x10,%edx
80107de3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dec:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107df3:	83 ca 60             	or     $0x60,%edx
80107df6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dff:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e06:	83 ca 80             	or     $0xffffff80,%edx
80107e09:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e12:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e19:	83 ca 0f             	or     $0xf,%edx
80107e1c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e25:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e2c:	83 e2 ef             	and    $0xffffffef,%edx
80107e2f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e38:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e3f:	83 e2 df             	and    $0xffffffdf,%edx
80107e42:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e52:	83 ca 40             	or     $0x40,%edx
80107e55:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e65:	83 ca 80             	or     $0xffffff80,%edx
80107e68:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e71:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7b:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107e82:	ff ff 
80107e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e87:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107e8e:	00 00 
80107e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e93:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ea4:	83 e2 f0             	and    $0xfffffff0,%edx
80107ea7:	83 ca 02             	or     $0x2,%edx
80107eaa:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb3:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107eba:	83 ca 10             	or     $0x10,%edx
80107ebd:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec6:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ecd:	83 ca 60             	or     $0x60,%edx
80107ed0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ee0:	83 ca 80             	or     $0xffffff80,%edx
80107ee3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eec:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ef3:	83 ca 0f             	or     $0xf,%edx
80107ef6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eff:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f06:	83 e2 ef             	and    $0xffffffef,%edx
80107f09:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f12:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f19:	83 e2 df             	and    $0xffffffdf,%edx
80107f1c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f25:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f2c:	83 ca 40             	or     $0x40,%edx
80107f2f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f38:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f3f:	83 ca 80             	or     $0xffffff80,%edx
80107f42:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4b:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f55:	05 b4 00 00 00       	add    $0xb4,%eax
80107f5a:	89 c3                	mov    %eax,%ebx
80107f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5f:	05 b4 00 00 00       	add    $0xb4,%eax
80107f64:	c1 e8 10             	shr    $0x10,%eax
80107f67:	89 c2                	mov    %eax,%edx
80107f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6c:	05 b4 00 00 00       	add    $0xb4,%eax
80107f71:	c1 e8 18             	shr    $0x18,%eax
80107f74:	89 c1                	mov    %eax,%ecx
80107f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f79:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107f80:	00 00 
80107f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f85:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8f:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f98:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107f9f:	83 e2 f0             	and    $0xfffffff0,%edx
80107fa2:	83 ca 02             	or     $0x2,%edx
80107fa5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fae:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fb5:	83 ca 10             	or     $0x10,%edx
80107fb8:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc1:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fc8:	83 e2 9f             	and    $0xffffff9f,%edx
80107fcb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fdb:	83 ca 80             	or     $0xffffff80,%edx
80107fde:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107fee:	83 e2 f0             	and    $0xfffffff0,%edx
80107ff1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffa:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108001:	83 e2 ef             	and    $0xffffffef,%edx
80108004:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010800a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108014:	83 e2 df             	and    $0xffffffdf,%edx
80108017:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010801d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108020:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108027:	83 ca 40             	or     $0x40,%edx
8010802a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108033:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010803a:	83 ca 80             	or     $0xffffff80,%edx
8010803d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108046:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010804c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804f:	83 c0 70             	add    $0x70,%eax
80108052:	83 ec 08             	sub    $0x8,%esp
80108055:	6a 38                	push   $0x38
80108057:	50                   	push   %eax
80108058:	e8 38 fb ff ff       	call   80107b95 <lgdt>
8010805d:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108060:	83 ec 0c             	sub    $0xc,%esp
80108063:	6a 18                	push   $0x18
80108065:	e8 6c fb ff ff       	call   80107bd6 <loadgs>
8010806a:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
8010806d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108070:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108076:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010807d:	00 00 00 00 
}
80108081:	90                   	nop
80108082:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108085:	c9                   	leave  
80108086:	c3                   	ret    

80108087 <choosePTESwap>:

static pte_t* choosePTESwap(){
80108087:	55                   	push   %ebp
80108088:	89 e5                	mov    %esp,%ebp
  return (pte_t*)0;
8010808a:	b8 00 00 00 00       	mov    $0x0,%eax
} 
8010808f:	5d                   	pop    %ebp
80108090:	c3                   	ret    

80108091 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108091:	55                   	push   %ebp
80108092:	89 e5                	mov    %esp,%ebp
80108094:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108097:	8b 45 0c             	mov    0xc(%ebp),%eax
8010809a:	c1 e8 16             	shr    $0x16,%eax
8010809d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080a4:	8b 45 08             	mov    0x8(%ebp),%eax
801080a7:	01 d0                	add    %edx,%eax
801080a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801080ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080af:	8b 00                	mov    (%eax),%eax
801080b1:	83 e0 01             	and    $0x1,%eax
801080b4:	85 c0                	test   %eax,%eax
801080b6:	74 18                	je     801080d0 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801080b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080bb:	8b 00                	mov    (%eax),%eax
801080bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080c2:	50                   	push   %eax
801080c3:	e8 3d fb ff ff       	call   80107c05 <p2v>
801080c8:	83 c4 04             	add    $0x4,%esp
801080cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080ce:	eb 48                	jmp    80108118 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801080d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801080d4:	74 0e                	je     801080e4 <walkpgdir+0x53>
801080d6:	e8 85 af ff ff       	call   80103060 <kalloc>
801080db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801080e2:	75 07                	jne    801080eb <walkpgdir+0x5a>
      return 0;
801080e4:	b8 00 00 00 00       	mov    $0x0,%eax
801080e9:	eb 44                	jmp    8010812f <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801080eb:	83 ec 04             	sub    $0x4,%esp
801080ee:	68 00 10 00 00       	push   $0x1000
801080f3:	6a 00                	push   $0x0
801080f5:	ff 75 f4             	pushl  -0xc(%ebp)
801080f8:	e8 9e d5 ff ff       	call   8010569b <memset>
801080fd:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108100:	83 ec 0c             	sub    $0xc,%esp
80108103:	ff 75 f4             	pushl  -0xc(%ebp)
80108106:	e8 ed fa ff ff       	call   80107bf8 <v2p>
8010810b:	83 c4 10             	add    $0x10,%esp
8010810e:	83 c8 07             	or     $0x7,%eax
80108111:	89 c2                	mov    %eax,%edx
80108113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108116:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108118:	8b 45 0c             	mov    0xc(%ebp),%eax
8010811b:	c1 e8 0c             	shr    $0xc,%eax
8010811e:	25 ff 03 00 00       	and    $0x3ff,%eax
80108123:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010812a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812d:	01 d0                	add    %edx,%eax
}
8010812f:	c9                   	leave  
80108130:	c3                   	ret    

80108131 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108131:	55                   	push   %ebp
80108132:	89 e5                	mov    %esp,%ebp
80108134:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108137:	8b 45 0c             	mov    0xc(%ebp),%eax
8010813a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010813f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108142:	8b 55 0c             	mov    0xc(%ebp),%edx
80108145:	8b 45 10             	mov    0x10(%ebp),%eax
80108148:	01 d0                	add    %edx,%eax
8010814a:	83 e8 01             	sub    $0x1,%eax
8010814d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108152:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108155:	83 ec 04             	sub    $0x4,%esp
80108158:	6a 01                	push   $0x1
8010815a:	ff 75 f4             	pushl  -0xc(%ebp)
8010815d:	ff 75 08             	pushl  0x8(%ebp)
80108160:	e8 2c ff ff ff       	call   80108091 <walkpgdir>
80108165:	83 c4 10             	add    $0x10,%esp
80108168:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010816b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010816f:	75 07                	jne    80108178 <mappages+0x47>
      return -1;
80108171:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108176:	eb 47                	jmp    801081bf <mappages+0x8e>
    if(*pte & PTE_P)
80108178:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010817b:	8b 00                	mov    (%eax),%eax
8010817d:	83 e0 01             	and    $0x1,%eax
80108180:	85 c0                	test   %eax,%eax
80108182:	74 0d                	je     80108191 <mappages+0x60>
      panic("remap");
80108184:	83 ec 0c             	sub    $0xc,%esp
80108187:	68 98 94 10 80       	push   $0x80109498
8010818c:	e8 d5 83 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108191:	8b 45 18             	mov    0x18(%ebp),%eax
80108194:	0b 45 14             	or     0x14(%ebp),%eax
80108197:	83 c8 01             	or     $0x1,%eax
8010819a:	89 c2                	mov    %eax,%edx
8010819c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010819f:	89 10                	mov    %edx,(%eax)
    if(a == last)
801081a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801081a7:	74 10                	je     801081b9 <mappages+0x88>
      break;
    a += PGSIZE;
801081a9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801081b0:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801081b7:	eb 9c                	jmp    80108155 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801081b9:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801081ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081bf:	c9                   	leave  
801081c0:	c3                   	ret    

801081c1 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801081c1:	55                   	push   %ebp
801081c2:	89 e5                	mov    %esp,%ebp
801081c4:	53                   	push   %ebx
801081c5:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801081c8:	e8 93 ae ff ff       	call   80103060 <kalloc>
801081cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081d4:	75 0a                	jne    801081e0 <setupkvm+0x1f>
    return 0;
801081d6:	b8 00 00 00 00       	mov    $0x0,%eax
801081db:	e9 8e 00 00 00       	jmp    8010826e <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
801081e0:	83 ec 04             	sub    $0x4,%esp
801081e3:	68 00 10 00 00       	push   $0x1000
801081e8:	6a 00                	push   $0x0
801081ea:	ff 75 f0             	pushl  -0x10(%ebp)
801081ed:	e8 a9 d4 ff ff       	call   8010569b <memset>
801081f2:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801081f5:	83 ec 0c             	sub    $0xc,%esp
801081f8:	68 00 00 00 0e       	push   $0xe000000
801081fd:	e8 03 fa ff ff       	call   80107c05 <p2v>
80108202:	83 c4 10             	add    $0x10,%esp
80108205:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010820a:	76 0d                	jbe    80108219 <setupkvm+0x58>
    panic("PHYSTOP too high");
8010820c:	83 ec 0c             	sub    $0xc,%esp
8010820f:	68 9e 94 10 80       	push   $0x8010949e
80108214:	e8 4d 83 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108219:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108220:	eb 40                	jmp    80108262 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108225:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822b:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010822e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108231:	8b 58 08             	mov    0x8(%eax),%ebx
80108234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108237:	8b 40 04             	mov    0x4(%eax),%eax
8010823a:	29 c3                	sub    %eax,%ebx
8010823c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823f:	8b 00                	mov    (%eax),%eax
80108241:	83 ec 0c             	sub    $0xc,%esp
80108244:	51                   	push   %ecx
80108245:	52                   	push   %edx
80108246:	53                   	push   %ebx
80108247:	50                   	push   %eax
80108248:	ff 75 f0             	pushl  -0x10(%ebp)
8010824b:	e8 e1 fe ff ff       	call   80108131 <mappages>
80108250:	83 c4 20             	add    $0x20,%esp
80108253:	85 c0                	test   %eax,%eax
80108255:	79 07                	jns    8010825e <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108257:	b8 00 00 00 00       	mov    $0x0,%eax
8010825c:	eb 10                	jmp    8010826e <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010825e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108262:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108269:	72 b7                	jb     80108222 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
8010826b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010826e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108271:	c9                   	leave  
80108272:	c3                   	ret    

80108273 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108273:	55                   	push   %ebp
80108274:	89 e5                	mov    %esp,%ebp
80108276:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108279:	e8 43 ff ff ff       	call   801081c1 <setupkvm>
8010827e:	a3 38 83 11 80       	mov    %eax,0x80118338
  switchkvm();
80108283:	e8 03 00 00 00       	call   8010828b <switchkvm>
}
80108288:	90                   	nop
80108289:	c9                   	leave  
8010828a:	c3                   	ret    

8010828b <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010828b:	55                   	push   %ebp
8010828c:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010828e:	a1 38 83 11 80       	mov    0x80118338,%eax
80108293:	50                   	push   %eax
80108294:	e8 5f f9 ff ff       	call   80107bf8 <v2p>
80108299:	83 c4 04             	add    $0x4,%esp
8010829c:	50                   	push   %eax
8010829d:	e8 4a f9 ff ff       	call   80107bec <lcr3>
801082a2:	83 c4 04             	add    $0x4,%esp
}
801082a5:	90                   	nop
801082a6:	c9                   	leave  
801082a7:	c3                   	ret    

801082a8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801082a8:	55                   	push   %ebp
801082a9:	89 e5                	mov    %esp,%ebp
801082ab:	56                   	push   %esi
801082ac:	53                   	push   %ebx
  pushcli();
801082ad:	e8 e3 d2 ff ff       	call   80105595 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801082b2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082b8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801082bf:	83 c2 08             	add    $0x8,%edx
801082c2:	89 d6                	mov    %edx,%esi
801082c4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801082cb:	83 c2 08             	add    $0x8,%edx
801082ce:	c1 ea 10             	shr    $0x10,%edx
801082d1:	89 d3                	mov    %edx,%ebx
801082d3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801082da:	83 c2 08             	add    $0x8,%edx
801082dd:	c1 ea 18             	shr    $0x18,%edx
801082e0:	89 d1                	mov    %edx,%ecx
801082e2:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801082e9:	67 00 
801082eb:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
801082f2:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
801082f8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801082ff:	83 e2 f0             	and    $0xfffffff0,%edx
80108302:	83 ca 09             	or     $0x9,%edx
80108305:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010830b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108312:	83 ca 10             	or     $0x10,%edx
80108315:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010831b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108322:	83 e2 9f             	and    $0xffffff9f,%edx
80108325:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010832b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108332:	83 ca 80             	or     $0xffffff80,%edx
80108335:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010833b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108342:	83 e2 f0             	and    $0xfffffff0,%edx
80108345:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010834b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108352:	83 e2 ef             	and    $0xffffffef,%edx
80108355:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010835b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108362:	83 e2 df             	and    $0xffffffdf,%edx
80108365:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010836b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108372:	83 ca 40             	or     $0x40,%edx
80108375:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010837b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108382:	83 e2 7f             	and    $0x7f,%edx
80108385:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010838b:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108391:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108397:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010839e:	83 e2 ef             	and    $0xffffffef,%edx
801083a1:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801083a7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083ad:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801083b3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083b9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801083c0:	8b 52 08             	mov    0x8(%edx),%edx
801083c3:	81 c2 00 10 00 00    	add    $0x1000,%edx
801083c9:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801083cc:	83 ec 0c             	sub    $0xc,%esp
801083cf:	6a 30                	push   $0x30
801083d1:	e8 e9 f7 ff ff       	call   80107bbf <ltr>
801083d6:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
801083d9:	8b 45 08             	mov    0x8(%ebp),%eax
801083dc:	8b 40 04             	mov    0x4(%eax),%eax
801083df:	85 c0                	test   %eax,%eax
801083e1:	75 0d                	jne    801083f0 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
801083e3:	83 ec 0c             	sub    $0xc,%esp
801083e6:	68 af 94 10 80       	push   $0x801094af
801083eb:	e8 76 81 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801083f0:	8b 45 08             	mov    0x8(%ebp),%eax
801083f3:	8b 40 04             	mov    0x4(%eax),%eax
801083f6:	83 ec 0c             	sub    $0xc,%esp
801083f9:	50                   	push   %eax
801083fa:	e8 f9 f7 ff ff       	call   80107bf8 <v2p>
801083ff:	83 c4 10             	add    $0x10,%esp
80108402:	83 ec 0c             	sub    $0xc,%esp
80108405:	50                   	push   %eax
80108406:	e8 e1 f7 ff ff       	call   80107bec <lcr3>
8010840b:	83 c4 10             	add    $0x10,%esp
  popcli();
8010840e:	e8 c7 d1 ff ff       	call   801055da <popcli>
}
80108413:	90                   	nop
80108414:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108417:	5b                   	pop    %ebx
80108418:	5e                   	pop    %esi
80108419:	5d                   	pop    %ebp
8010841a:	c3                   	ret    

8010841b <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010841b:	55                   	push   %ebp
8010841c:	89 e5                	mov    %esp,%ebp
8010841e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108421:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108428:	76 0d                	jbe    80108437 <inituvm+0x1c>
    panic("inituvm: more than a page");
8010842a:	83 ec 0c             	sub    $0xc,%esp
8010842d:	68 c3 94 10 80       	push   $0x801094c3
80108432:	e8 2f 81 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108437:	e8 24 ac ff ff       	call   80103060 <kalloc>
8010843c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010843f:	83 ec 04             	sub    $0x4,%esp
80108442:	68 00 10 00 00       	push   $0x1000
80108447:	6a 00                	push   $0x0
80108449:	ff 75 f4             	pushl  -0xc(%ebp)
8010844c:	e8 4a d2 ff ff       	call   8010569b <memset>
80108451:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108454:	83 ec 0c             	sub    $0xc,%esp
80108457:	ff 75 f4             	pushl  -0xc(%ebp)
8010845a:	e8 99 f7 ff ff       	call   80107bf8 <v2p>
8010845f:	83 c4 10             	add    $0x10,%esp
80108462:	83 ec 0c             	sub    $0xc,%esp
80108465:	6a 06                	push   $0x6
80108467:	50                   	push   %eax
80108468:	68 00 10 00 00       	push   $0x1000
8010846d:	6a 00                	push   $0x0
8010846f:	ff 75 08             	pushl  0x8(%ebp)
80108472:	e8 ba fc ff ff       	call   80108131 <mappages>
80108477:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010847a:	83 ec 04             	sub    $0x4,%esp
8010847d:	ff 75 10             	pushl  0x10(%ebp)
80108480:	ff 75 0c             	pushl  0xc(%ebp)
80108483:	ff 75 f4             	pushl  -0xc(%ebp)
80108486:	e8 cf d2 ff ff       	call   8010575a <memmove>
8010848b:	83 c4 10             	add    $0x10,%esp
}
8010848e:	90                   	nop
8010848f:	c9                   	leave  
80108490:	c3                   	ret    

80108491 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108491:	55                   	push   %ebp
80108492:	89 e5                	mov    %esp,%ebp
80108494:	53                   	push   %ebx
80108495:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108498:	8b 45 0c             	mov    0xc(%ebp),%eax
8010849b:	25 ff 0f 00 00       	and    $0xfff,%eax
801084a0:	85 c0                	test   %eax,%eax
801084a2:	74 0d                	je     801084b1 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801084a4:	83 ec 0c             	sub    $0xc,%esp
801084a7:	68 e0 94 10 80       	push   $0x801094e0
801084ac:	e8 b5 80 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801084b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084b8:	e9 95 00 00 00       	jmp    80108552 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801084bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801084c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c3:	01 d0                	add    %edx,%eax
801084c5:	83 ec 04             	sub    $0x4,%esp
801084c8:	6a 00                	push   $0x0
801084ca:	50                   	push   %eax
801084cb:	ff 75 08             	pushl  0x8(%ebp)
801084ce:	e8 be fb ff ff       	call   80108091 <walkpgdir>
801084d3:	83 c4 10             	add    $0x10,%esp
801084d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801084d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084dd:	75 0d                	jne    801084ec <loaduvm+0x5b>
      panic("loaduvm: address should exist");
801084df:	83 ec 0c             	sub    $0xc,%esp
801084e2:	68 03 95 10 80       	push   $0x80109503
801084e7:	e8 7a 80 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801084ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ef:	8b 00                	mov    (%eax),%eax
801084f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801084f9:	8b 45 18             	mov    0x18(%ebp),%eax
801084fc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801084ff:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108504:	77 0b                	ja     80108511 <loaduvm+0x80>
      n = sz - i;
80108506:	8b 45 18             	mov    0x18(%ebp),%eax
80108509:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010850c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010850f:	eb 07                	jmp    80108518 <loaduvm+0x87>
    else
      n = PGSIZE;
80108511:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108518:	8b 55 14             	mov    0x14(%ebp),%edx
8010851b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851e:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108521:	83 ec 0c             	sub    $0xc,%esp
80108524:	ff 75 e8             	pushl  -0x18(%ebp)
80108527:	e8 d9 f6 ff ff       	call   80107c05 <p2v>
8010852c:	83 c4 10             	add    $0x10,%esp
8010852f:	ff 75 f0             	pushl  -0x10(%ebp)
80108532:	53                   	push   %ebx
80108533:	50                   	push   %eax
80108534:	ff 75 10             	pushl  0x10(%ebp)
80108537:	e8 9c 99 ff ff       	call   80101ed8 <readi>
8010853c:	83 c4 10             	add    $0x10,%esp
8010853f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108542:	74 07                	je     8010854b <loaduvm+0xba>
      return -1;
80108544:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108549:	eb 18                	jmp    80108563 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010854b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108555:	3b 45 18             	cmp    0x18(%ebp),%eax
80108558:	0f 82 5f ff ff ff    	jb     801084bd <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010855e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108563:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108566:	c9                   	leave  
80108567:	c3                   	ret    

80108568 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108568:	55                   	push   %ebp
80108569:	89 e5                	mov    %esp,%ebp
8010856b:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010856e:	8b 45 10             	mov    0x10(%ebp),%eax
80108571:	85 c0                	test   %eax,%eax
80108573:	79 0a                	jns    8010857f <allocuvm+0x17>
    return 0;
80108575:	b8 00 00 00 00       	mov    $0x0,%eax
8010857a:	e9 12 02 00 00       	jmp    80108791 <allocuvm+0x229>
  if(newsz < oldsz)
8010857f:	8b 45 10             	mov    0x10(%ebp),%eax
80108582:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108585:	73 08                	jae    8010858f <allocuvm+0x27>
    return oldsz;
80108587:	8b 45 0c             	mov    0xc(%ebp),%eax
8010858a:	e9 02 02 00 00       	jmp    80108791 <allocuvm+0x229>

  a = PGROUNDUP(oldsz);
8010858f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108592:	05 ff 0f 00 00       	add    $0xfff,%eax
80108597:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010859c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010859f:	e9 de 01 00 00       	jmp    80108782 <allocuvm+0x21a>


    mem = kalloc();
801085a4:	e8 b7 aa ff ff       	call   80103060 <kalloc>
801085a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(mem == 0){
801085ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085b0:	75 2e                	jne    801085e0 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
801085b2:	83 ec 0c             	sub    $0xc,%esp
801085b5:	68 21 95 10 80       	push   $0x80109521
801085ba:	e8 07 7e ff ff       	call   801003c6 <cprintf>
801085bf:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801085c2:	83 ec 04             	sub    $0x4,%esp
801085c5:	ff 75 0c             	pushl  0xc(%ebp)
801085c8:	ff 75 10             	pushl  0x10(%ebp)
801085cb:	ff 75 08             	pushl  0x8(%ebp)
801085ce:	e8 c0 01 00 00       	call   80108793 <deallocuvm>
801085d3:	83 c4 10             	add    $0x10,%esp
      return 0;
801085d6:	b8 00 00 00 00       	mov    $0x0,%eax
801085db:	e9 b1 01 00 00       	jmp    80108791 <allocuvm+0x229>
    }
    memset(mem, 0, PGSIZE);
801085e0:	83 ec 04             	sub    $0x4,%esp
801085e3:	68 00 10 00 00       	push   $0x1000
801085e8:	6a 00                	push   $0x0
801085ea:	ff 75 ec             	pushl  -0x14(%ebp)
801085ed:	e8 a9 d0 ff ff       	call   8010569b <memset>
801085f2:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801085f5:	83 ec 0c             	sub    $0xc,%esp
801085f8:	ff 75 ec             	pushl  -0x14(%ebp)
801085fb:	e8 f8 f5 ff ff       	call   80107bf8 <v2p>
80108600:	83 c4 10             	add    $0x10,%esp
80108603:	89 c2                	mov    %eax,%edx
80108605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108608:	83 ec 0c             	sub    $0xc,%esp
8010860b:	6a 06                	push   $0x6
8010860d:	52                   	push   %edx
8010860e:	68 00 10 00 00       	push   $0x1000
80108613:	50                   	push   %eax
80108614:	ff 75 08             	pushl  0x8(%ebp)
80108617:	e8 15 fb ff ff       	call   80108131 <mappages>
8010861c:	83 c4 20             	add    $0x20,%esp

    // our poor implementation (mostly omer`s work)
    if(proc->numPhysPages < MAX_PSYC_PAGES){
8010861f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108625:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010862b:	83 f8 0e             	cmp    $0xe,%eax
8010862e:	7f 41                	jg     80108671 <allocuvm+0x109>
      proc->numPhysPages++;
80108630:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108636:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
8010863c:	83 c2 01             	add    $0x1,%edx
8010863f:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
      cprintf("%d. filled page %d\n",proc->pid,proc->numPhysPages);
80108645:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010864b:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80108651:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108657:	8b 40 10             	mov    0x10(%eax),%eax
8010865a:	83 ec 04             	sub    $0x4,%esp
8010865d:	52                   	push   %edx
8010865e:	50                   	push   %eax
8010865f:	68 39 95 10 80       	push   $0x80109539
80108664:	e8 5d 7d ff ff       	call   801003c6 <cprintf>
80108669:	83 c4 10             	add    $0x10,%esp
8010866c:	e9 0a 01 00 00       	jmp    8010877b <allocuvm+0x213>
    }
    else{
      if(proc->swapFile == 0) // if swapFile not init
80108671:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108677:	8b 40 7c             	mov    0x7c(%eax),%eax
8010867a:	85 c0                	test   %eax,%eax
8010867c:	75 12                	jne    80108690 <allocuvm+0x128>
         createSwapFile(proc);
8010867e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108684:	83 ec 0c             	sub    $0xc,%esp
80108687:	50                   	push   %eax
80108688:	e8 ac a1 ff ff       	call   80102839 <createSwapFile>
8010868d:	83 c4 10             	add    $0x10,%esp

      
      int i;
      for(i=0;i<MAX_PSYC_PAGES;i++){
80108690:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108697:	eb 18                	jmp    801086b1 <allocuvm+0x149>
        if(!proc->storedPages[i].inUse)
80108699:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010869f:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086a2:	83 c2 10             	add    $0x10,%edx
801086a5:	8b 44 d0 08          	mov    0x8(%eax,%edx,8),%eax
801086a9:	85 c0                	test   %eax,%eax
801086ab:	74 0c                	je     801086b9 <allocuvm+0x151>
      if(proc->swapFile == 0) // if swapFile not init
         createSwapFile(proc);

      
      int i;
      for(i=0;i<MAX_PSYC_PAGES;i++){
801086ad:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801086b1:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
801086b5:	7e e2                	jle    80108699 <allocuvm+0x131>
801086b7:	eb 01                	jmp    801086ba <allocuvm+0x152>
        if(!proc->storedPages[i].inUse)
          break;
801086b9:	90                   	nop
      }

      if(i==MAX_PSYC_PAGES)
801086ba:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801086be:	75 0d                	jne    801086cd <allocuvm+0x165>
        panic("MAX_PSYC_PAGES exceeded");
801086c0:	83 ec 0c             	sub    $0xc,%esp
801086c3:	68 4d 95 10 80       	push   $0x8010954d
801086c8:	e8 99 7e ff ff       	call   80100566 <panic>

      proc->storedPages[i].inUse = 1;
801086cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086d6:	83 c2 10             	add    $0x10,%edx
801086d9:	c7 44 d0 08 01 00 00 	movl   $0x1,0x8(%eax,%edx,8)
801086e0:	00 
      proc->storedPages[i].va = (char*)PTE_ADDR(a);
801086e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086ea:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
801086f0:	89 d1                	mov    %edx,%ecx
801086f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086f5:	83 c2 10             	add    $0x10,%edx
801086f8:	89 4c d0 0c          	mov    %ecx,0xc(%eax,%edx,8)

      // write to swapfile new page???
      // char buf[PGSIZE];
      // writeToSwapFile(proc, buf, i*PGSIZE, PGSIZE);
      
      pte_t* pte = walkpgdir(pgdir, (void*)a, 0);
801086fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ff:	83 ec 04             	sub    $0x4,%esp
80108702:	6a 00                	push   $0x0
80108704:	50                   	push   %eax
80108705:	ff 75 08             	pushl  0x8(%ebp)
80108708:	e8 84 f9 ff ff       	call   80108091 <walkpgdir>
8010870d:	83 c4 10             	add    $0x10,%esp
80108710:	89 45 e8             	mov    %eax,-0x18(%ebp)
      *pte |= PTE_PG; //turn on second storage flag
80108713:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108716:	8b 00                	mov    (%eax),%eax
80108718:	80 cc 02             	or     $0x2,%ah
8010871b:	89 c2                	mov    %eax,%edx
8010871d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108720:	89 10                	mov    %edx,(%eax)
      *pte &= ~PTE_P; //turn off present flag
80108722:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108725:	8b 00                	mov    (%eax),%eax
80108727:	83 e0 fe             	and    $0xfffffffe,%eax
8010872a:	89 c2                	mov    %eax,%edx
8010872c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010872f:	89 10                	mov    %edx,(%eax)
      kfree(mem);
80108731:	83 ec 0c             	sub    $0xc,%esp
80108734:	ff 75 ec             	pushl  -0x14(%ebp)
80108737:	e8 87 a8 ff ff       	call   80102fc3 <kfree>
8010873c:	83 c4 10             	add    $0x10,%esp
      proc->numStoredPages++;
8010873f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108745:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
8010874b:	83 c2 01             	add    $0x1,%edx
8010874e:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      cprintf("%d. stored page %d\n",proc->pid,proc->numStoredPages);
80108754:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010875a:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80108760:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108766:	8b 40 10             	mov    0x10(%eax),%eax
80108769:	83 ec 04             	sub    $0x4,%esp
8010876c:	52                   	push   %edx
8010876d:	50                   	push   %eax
8010876e:	68 65 95 10 80       	push   $0x80109565
80108773:	e8 4e 7c ff ff       	call   801003c6 <cprintf>
80108778:	83 c4 10             	add    $0x10,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010877b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108785:	3b 45 10             	cmp    0x10(%ebp),%eax
80108788:	0f 82 16 fe ff ff    	jb     801085a4 <allocuvm+0x3c>
      proc->numStoredPages++;
      cprintf("%d. stored page %d\n",proc->pid,proc->numStoredPages);
    }

  }
  return newsz;
8010878e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108791:	c9                   	leave  
80108792:	c3                   	ret    

80108793 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108793:	55                   	push   %ebp
80108794:	89 e5                	mov    %esp,%ebp
80108796:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108799:	8b 45 10             	mov    0x10(%ebp),%eax
8010879c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010879f:	72 08                	jb     801087a9 <deallocuvm+0x16>
    return oldsz;
801087a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801087a4:	e9 6d 01 00 00       	jmp    80108916 <deallocuvm+0x183>

  a = PGROUNDUP(newsz);
801087a9:	8b 45 10             	mov    0x10(%ebp),%eax
801087ac:	05 ff 0f 00 00       	add    $0xfff,%eax
801087b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801087b9:	e9 49 01 00 00       	jmp    80108907 <deallocuvm+0x174>
    pte = walkpgdir(pgdir, (char*)a, 0);
801087be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c1:	83 ec 04             	sub    $0x4,%esp
801087c4:	6a 00                	push   $0x0
801087c6:	50                   	push   %eax
801087c7:	ff 75 08             	pushl  0x8(%ebp)
801087ca:	e8 c2 f8 ff ff       	call   80108091 <walkpgdir>
801087cf:	83 c4 10             	add    $0x10,%esp
801087d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(!pte)
801087d5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087d9:	75 0c                	jne    801087e7 <deallocuvm+0x54>
      a += (NPTENTRIES - 1) * PGSIZE;
801087db:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801087e2:	e9 19 01 00 00       	jmp    80108900 <deallocuvm+0x16d>
    else if((*pte & PTE_P) != 0){ // page is present
801087e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ea:	8b 00                	mov    (%eax),%eax
801087ec:	83 e0 01             	and    $0x1,%eax
801087ef:	85 c0                	test   %eax,%eax
801087f1:	0f 84 89 00 00 00    	je     80108880 <deallocuvm+0xed>
      pa = PTE_ADDR(*pte);
801087f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087fa:	8b 00                	mov    (%eax),%eax
801087fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108801:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(pa == 0)
80108804:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108808:	75 0d                	jne    80108817 <deallocuvm+0x84>
        panic("kfree");
8010880a:	83 ec 0c             	sub    $0xc,%esp
8010880d:	68 79 95 10 80       	push   $0x80109579
80108812:	e8 4f 7d ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108817:	83 ec 0c             	sub    $0xc,%esp
8010881a:	ff 75 e8             	pushl  -0x18(%ebp)
8010881d:	e8 e3 f3 ff ff       	call   80107c05 <p2v>
80108822:	83 c4 10             	add    $0x10,%esp
80108825:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80108828:	83 ec 0c             	sub    $0xc,%esp
8010882b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010882e:	e8 90 a7 ff ff       	call   80102fc3 <kfree>
80108833:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108836:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108839:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      proc->numPhysPages--;
8010883f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108845:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
8010884b:	83 ea 01             	sub    $0x1,%edx
8010884e:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
      cprintf("%d. emptied page %d\n",proc->pid,proc->numPhysPages);
80108854:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010885a:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80108860:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108866:	8b 40 10             	mov    0x10(%eax),%eax
80108869:	83 ec 04             	sub    $0x4,%esp
8010886c:	52                   	push   %edx
8010886d:	50                   	push   %eax
8010886e:	68 7f 95 10 80       	push   $0x8010957f
80108873:	e8 4e 7b ff ff       	call   801003c6 <cprintf>
80108878:	83 c4 10             	add    $0x10,%esp
8010887b:	e9 80 00 00 00       	jmp    80108900 <deallocuvm+0x16d>
    }
    else if((*pte & PTE_PG) != 0){ // page isn`t present and in secondary storage
80108880:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108883:	8b 00                	mov    (%eax),%eax
80108885:	25 00 02 00 00       	and    $0x200,%eax
8010888a:	85 c0                	test   %eax,%eax
8010888c:	74 72                	je     80108900 <deallocuvm+0x16d>
      int i;
      for(i=0;i<MAX_PSYC_PAGES;i++){
8010888e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108895:	eb 1b                	jmp    801088b2 <deallocuvm+0x11f>
        if((char*)a == proc->storedPages[i].va)
80108897:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010889d:	8b 55 f0             	mov    -0x10(%ebp),%edx
801088a0:	83 c2 10             	add    $0x10,%edx
801088a3:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
801088a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088aa:	39 c2                	cmp    %eax,%edx
801088ac:	74 0c                	je     801088ba <deallocuvm+0x127>
      proc->numPhysPages--;
      cprintf("%d. emptied page %d\n",proc->pid,proc->numPhysPages);
    }
    else if((*pte & PTE_PG) != 0){ // page isn`t present and in secondary storage
      int i;
      for(i=0;i<MAX_PSYC_PAGES;i++){
801088ae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801088b2:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
801088b6:	7e df                	jle    80108897 <deallocuvm+0x104>
801088b8:	eb 01                	jmp    801088bb <deallocuvm+0x128>
        if((char*)a == proc->storedPages[i].va)
          break;
801088ba:	90                   	nop
      }

      if(i==MAX_PSYC_PAGES)
801088bb:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801088bf:	75 0d                	jne    801088ce <deallocuvm+0x13b>
        panic("deallocuvm - page not found");
801088c1:	83 ec 0c             	sub    $0xc,%esp
801088c4:	68 94 95 10 80       	push   $0x80109594
801088c9:	e8 98 7c ff ff       	call   80100566 <panic>


      proc->storedPages[i].inUse = 0;
801088ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801088d7:	83 c2 10             	add    $0x10,%edx
801088da:	c7 44 d0 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,8)
801088e1:	00 
      proc->numStoredPages--;
801088e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088e8:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
801088ee:	83 ea 01             	sub    $0x1,%edx
801088f1:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      *pte = 0;
801088f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108900:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010890d:	0f 82 ab fe ff ff    	jb     801087be <deallocuvm+0x2b>
      proc->storedPages[i].inUse = 0;
      proc->numStoredPages--;
      *pte = 0;
    }
  }
  return newsz;
80108913:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108916:	c9                   	leave  
80108917:	c3                   	ret    

80108918 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108918:	55                   	push   %ebp
80108919:	89 e5                	mov    %esp,%ebp
8010891b:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010891e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108922:	75 0d                	jne    80108931 <freevm+0x19>
    panic("freevm: no pgdir");
80108924:	83 ec 0c             	sub    $0xc,%esp
80108927:	68 b0 95 10 80       	push   $0x801095b0
8010892c:	e8 35 7c ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108931:	83 ec 04             	sub    $0x4,%esp
80108934:	6a 00                	push   $0x0
80108936:	68 00 00 00 80       	push   $0x80000000
8010893b:	ff 75 08             	pushl  0x8(%ebp)
8010893e:	e8 50 fe ff ff       	call   80108793 <deallocuvm>
80108943:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010894d:	eb 4f                	jmp    8010899e <freevm+0x86>
    if(pgdir[i] & PTE_P){
8010894f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108952:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108959:	8b 45 08             	mov    0x8(%ebp),%eax
8010895c:	01 d0                	add    %edx,%eax
8010895e:	8b 00                	mov    (%eax),%eax
80108960:	83 e0 01             	and    $0x1,%eax
80108963:	85 c0                	test   %eax,%eax
80108965:	74 33                	je     8010899a <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108971:	8b 45 08             	mov    0x8(%ebp),%eax
80108974:	01 d0                	add    %edx,%eax
80108976:	8b 00                	mov    (%eax),%eax
80108978:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010897d:	83 ec 0c             	sub    $0xc,%esp
80108980:	50                   	push   %eax
80108981:	e8 7f f2 ff ff       	call   80107c05 <p2v>
80108986:	83 c4 10             	add    $0x10,%esp
80108989:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010898c:	83 ec 0c             	sub    $0xc,%esp
8010898f:	ff 75 f0             	pushl  -0x10(%ebp)
80108992:	e8 2c a6 ff ff       	call   80102fc3 <kfree>
80108997:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010899a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010899e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801089a5:	76 a8                	jbe    8010894f <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801089a7:	83 ec 0c             	sub    $0xc,%esp
801089aa:	ff 75 08             	pushl  0x8(%ebp)
801089ad:	e8 11 a6 ff ff       	call   80102fc3 <kfree>
801089b2:	83 c4 10             	add    $0x10,%esp
}
801089b5:	90                   	nop
801089b6:	c9                   	leave  
801089b7:	c3                   	ret    

801089b8 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801089b8:	55                   	push   %ebp
801089b9:	89 e5                	mov    %esp,%ebp
801089bb:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801089be:	83 ec 04             	sub    $0x4,%esp
801089c1:	6a 00                	push   $0x0
801089c3:	ff 75 0c             	pushl  0xc(%ebp)
801089c6:	ff 75 08             	pushl  0x8(%ebp)
801089c9:	e8 c3 f6 ff ff       	call   80108091 <walkpgdir>
801089ce:	83 c4 10             	add    $0x10,%esp
801089d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801089d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801089d8:	75 0d                	jne    801089e7 <clearpteu+0x2f>
    panic("clearpteu");
801089da:	83 ec 0c             	sub    $0xc,%esp
801089dd:	68 c1 95 10 80       	push   $0x801095c1
801089e2:	e8 7f 7b ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801089e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ea:	8b 00                	mov    (%eax),%eax
801089ec:	83 e0 fb             	and    $0xfffffffb,%eax
801089ef:	89 c2                	mov    %eax,%edx
801089f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f4:	89 10                	mov    %edx,(%eax)
}
801089f6:	90                   	nop
801089f7:	c9                   	leave  
801089f8:	c3                   	ret    

801089f9 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801089f9:	55                   	push   %ebp
801089fa:	89 e5                	mov    %esp,%ebp
801089fc:	53                   	push   %ebx
801089fd:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108a00:	e8 bc f7 ff ff       	call   801081c1 <setupkvm>
80108a05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a0c:	75 0a                	jne    80108a18 <copyuvm+0x1f>
    return 0;
80108a0e:	b8 00 00 00 00       	mov    $0x0,%eax
80108a13:	e9 f8 00 00 00       	jmp    80108b10 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80108a18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a1f:	e9 c4 00 00 00       	jmp    80108ae8 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a27:	83 ec 04             	sub    $0x4,%esp
80108a2a:	6a 00                	push   $0x0
80108a2c:	50                   	push   %eax
80108a2d:	ff 75 08             	pushl  0x8(%ebp)
80108a30:	e8 5c f6 ff ff       	call   80108091 <walkpgdir>
80108a35:	83 c4 10             	add    $0x10,%esp
80108a38:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a3b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a3f:	75 0d                	jne    80108a4e <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108a41:	83 ec 0c             	sub    $0xc,%esp
80108a44:	68 cb 95 10 80       	push   $0x801095cb
80108a49:	e8 18 7b ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80108a4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a51:	8b 00                	mov    (%eax),%eax
80108a53:	83 e0 01             	and    $0x1,%eax
80108a56:	85 c0                	test   %eax,%eax
80108a58:	75 0d                	jne    80108a67 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80108a5a:	83 ec 0c             	sub    $0xc,%esp
80108a5d:	68 e5 95 10 80       	push   $0x801095e5
80108a62:	e8 ff 7a ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108a67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a6a:	8b 00                	mov    (%eax),%eax
80108a6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a71:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108a74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a77:	8b 00                	mov    (%eax),%eax
80108a79:	25 ff 0f 00 00       	and    $0xfff,%eax
80108a7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108a81:	e8 da a5 ff ff       	call   80103060 <kalloc>
80108a86:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108a89:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108a8d:	74 6a                	je     80108af9 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108a8f:	83 ec 0c             	sub    $0xc,%esp
80108a92:	ff 75 e8             	pushl  -0x18(%ebp)
80108a95:	e8 6b f1 ff ff       	call   80107c05 <p2v>
80108a9a:	83 c4 10             	add    $0x10,%esp
80108a9d:	83 ec 04             	sub    $0x4,%esp
80108aa0:	68 00 10 00 00       	push   $0x1000
80108aa5:	50                   	push   %eax
80108aa6:	ff 75 e0             	pushl  -0x20(%ebp)
80108aa9:	e8 ac cc ff ff       	call   8010575a <memmove>
80108aae:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108ab1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108ab4:	83 ec 0c             	sub    $0xc,%esp
80108ab7:	ff 75 e0             	pushl  -0x20(%ebp)
80108aba:	e8 39 f1 ff ff       	call   80107bf8 <v2p>
80108abf:	83 c4 10             	add    $0x10,%esp
80108ac2:	89 c2                	mov    %eax,%edx
80108ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac7:	83 ec 0c             	sub    $0xc,%esp
80108aca:	53                   	push   %ebx
80108acb:	52                   	push   %edx
80108acc:	68 00 10 00 00       	push   $0x1000
80108ad1:	50                   	push   %eax
80108ad2:	ff 75 f0             	pushl  -0x10(%ebp)
80108ad5:	e8 57 f6 ff ff       	call   80108131 <mappages>
80108ada:	83 c4 20             	add    $0x20,%esp
80108add:	85 c0                	test   %eax,%eax
80108adf:	78 1b                	js     80108afc <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108ae1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aeb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108aee:	0f 82 30 ff ff ff    	jb     80108a24 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af7:	eb 17                	jmp    80108b10 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108af9:	90                   	nop
80108afa:	eb 01                	jmp    80108afd <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108afc:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108afd:	83 ec 0c             	sub    $0xc,%esp
80108b00:	ff 75 f0             	pushl  -0x10(%ebp)
80108b03:	e8 10 fe ff ff       	call   80108918 <freevm>
80108b08:	83 c4 10             	add    $0x10,%esp
  return 0;
80108b0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b13:	c9                   	leave  
80108b14:	c3                   	ret    

80108b15 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108b15:	55                   	push   %ebp
80108b16:	89 e5                	mov    %esp,%ebp
80108b18:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108b1b:	83 ec 04             	sub    $0x4,%esp
80108b1e:	6a 00                	push   $0x0
80108b20:	ff 75 0c             	pushl  0xc(%ebp)
80108b23:	ff 75 08             	pushl  0x8(%ebp)
80108b26:	e8 66 f5 ff ff       	call   80108091 <walkpgdir>
80108b2b:	83 c4 10             	add    $0x10,%esp
80108b2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b34:	8b 00                	mov    (%eax),%eax
80108b36:	83 e0 01             	and    $0x1,%eax
80108b39:	85 c0                	test   %eax,%eax
80108b3b:	75 07                	jne    80108b44 <uva2ka+0x2f>
    return 0;
80108b3d:	b8 00 00 00 00       	mov    $0x0,%eax
80108b42:	eb 29                	jmp    80108b6d <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b47:	8b 00                	mov    (%eax),%eax
80108b49:	83 e0 04             	and    $0x4,%eax
80108b4c:	85 c0                	test   %eax,%eax
80108b4e:	75 07                	jne    80108b57 <uva2ka+0x42>
    return 0;
80108b50:	b8 00 00 00 00       	mov    $0x0,%eax
80108b55:	eb 16                	jmp    80108b6d <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80108b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b5a:	8b 00                	mov    (%eax),%eax
80108b5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b61:	83 ec 0c             	sub    $0xc,%esp
80108b64:	50                   	push   %eax
80108b65:	e8 9b f0 ff ff       	call   80107c05 <p2v>
80108b6a:	83 c4 10             	add    $0x10,%esp
}
80108b6d:	c9                   	leave  
80108b6e:	c3                   	ret    

80108b6f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108b6f:	55                   	push   %ebp
80108b70:	89 e5                	mov    %esp,%ebp
80108b72:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108b75:	8b 45 10             	mov    0x10(%ebp),%eax
80108b78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108b7b:	eb 7f                	jmp    80108bfc <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b85:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108b88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b8b:	83 ec 08             	sub    $0x8,%esp
80108b8e:	50                   	push   %eax
80108b8f:	ff 75 08             	pushl  0x8(%ebp)
80108b92:	e8 7e ff ff ff       	call   80108b15 <uva2ka>
80108b97:	83 c4 10             	add    $0x10,%esp
80108b9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108b9d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108ba1:	75 07                	jne    80108baa <copyout+0x3b>
      return -1;
80108ba3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ba8:	eb 61                	jmp    80108c0b <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108baa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bad:	2b 45 0c             	sub    0xc(%ebp),%eax
80108bb0:	05 00 10 00 00       	add    $0x1000,%eax
80108bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bbb:	3b 45 14             	cmp    0x14(%ebp),%eax
80108bbe:	76 06                	jbe    80108bc6 <copyout+0x57>
      n = len;
80108bc0:	8b 45 14             	mov    0x14(%ebp),%eax
80108bc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bc9:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108bcc:	89 c2                	mov    %eax,%edx
80108bce:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bd1:	01 d0                	add    %edx,%eax
80108bd3:	83 ec 04             	sub    $0x4,%esp
80108bd6:	ff 75 f0             	pushl  -0x10(%ebp)
80108bd9:	ff 75 f4             	pushl  -0xc(%ebp)
80108bdc:	50                   	push   %eax
80108bdd:	e8 78 cb ff ff       	call   8010575a <memmove>
80108be2:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108be8:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bee:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108bf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bf4:	05 00 10 00 00       	add    $0x1000,%eax
80108bf9:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108bfc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108c00:	0f 85 77 ff ff ff    	jne    80108b7d <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108c06:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c0b:	c9                   	leave  
80108c0c:	c3                   	ret    

80108c0d <swapPages>:

void swapPages(uint va) {
80108c0d:	55                   	push   %ebp
80108c0e:	89 e5                	mov    %esp,%ebp
80108c10:	81 ec 18 10 00 00    	sub    $0x1018,%esp
  
  //TODO delet   cprintf("resched swapPages!\n");
  if (strncmp(proc->name, "init",strlen(proc->name)) == 0 || strncmp(proc->name, "sh",strlen(proc->name)) == 0) {
80108c16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108c1c:	83 c0 6c             	add    $0x6c,%eax
80108c1f:	83 ec 0c             	sub    $0xc,%esp
80108c22:	50                   	push   %eax
80108c23:	e8 c0 cc ff ff       	call   801058e8 <strlen>
80108c28:	83 c4 10             	add    $0x10,%esp
80108c2b:	89 c2                	mov    %eax,%edx
80108c2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108c33:	83 c0 6c             	add    $0x6c,%eax
80108c36:	83 ec 04             	sub    $0x4,%esp
80108c39:	52                   	push   %edx
80108c3a:	68 ff 95 10 80       	push   $0x801095ff
80108c3f:	50                   	push   %eax
80108c40:	e8 ab cb ff ff       	call   801057f0 <strncmp>
80108c45:	83 c4 10             	add    $0x10,%esp
80108c48:	85 c0                	test   %eax,%eax
80108c4a:	0f 84 b0 01 00 00    	je     80108e00 <swapPages+0x1f3>
80108c50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108c56:	83 c0 6c             	add    $0x6c,%eax
80108c59:	83 ec 0c             	sub    $0xc,%esp
80108c5c:	50                   	push   %eax
80108c5d:	e8 86 cc ff ff       	call   801058e8 <strlen>
80108c62:	83 c4 10             	add    $0x10,%esp
80108c65:	89 c2                	mov    %eax,%edx
80108c67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108c6d:	83 c0 6c             	add    $0x6c,%eax
80108c70:	83 ec 04             	sub    $0x4,%esp
80108c73:	52                   	push   %edx
80108c74:	68 04 96 10 80       	push   $0x80109604
80108c79:	50                   	push   %eax
80108c7a:	e8 71 cb ff ff       	call   801057f0 <strncmp>
80108c7f:	83 c4 10             	add    $0x10,%esp
80108c82:	85 c0                	test   %eax,%eax
80108c84:	0f 84 76 01 00 00    	je     80108e00 <swapPages+0x1f3>
    return;
  }

  char buf[PGSIZE];
  pte_t *pte_to, *pte_from;
  int i = 0;
80108c8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for(i=0;i < MAX_PSYC_PAGES;i++){
80108c91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c98:	eb 21                	jmp    80108cbb <swapPages+0xae>
    if(proc->storedPages[i].va == (char*)PTE_ADDR(va))
80108c9a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ca0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ca3:	83 c2 10             	add    $0x10,%edx
80108ca6:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108caa:	8b 55 08             	mov    0x8(%ebp),%edx
80108cad:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80108cb3:	39 d0                	cmp    %edx,%eax
80108cb5:	74 0c                	je     80108cc3 <swapPages+0xb6>
  }

  char buf[PGSIZE];
  pte_t *pte_to, *pte_from;
  int i = 0;
  for(i=0;i < MAX_PSYC_PAGES;i++){
80108cb7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108cbb:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80108cbf:	7e d9                	jle    80108c9a <swapPages+0x8d>
80108cc1:	eb 01                	jmp    80108cc4 <swapPages+0xb7>
    if(proc->storedPages[i].va == (char*)PTE_ADDR(va))
      break;
80108cc3:	90                   	nop
  }

  if(i==MAX_PSYC_PAGES)
80108cc4:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80108cc8:	75 0d                	jne    80108cd7 <swapPages+0xca>
    panic("attack");
80108cca:	83 ec 0c             	sub    $0xc,%esp
80108ccd:	68 07 96 10 80       	push   $0x80109607
80108cd2:	e8 8f 78 ff ff       	call   80100566 <panic>

  pte_to = walkpgdir(proc->pgdir, proc->storedPages[i].va, 0);
80108cd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108cdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ce0:	83 c2 10             	add    $0x10,%edx
80108ce3:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
80108ce7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ced:	8b 40 04             	mov    0x4(%eax),%eax
80108cf0:	83 ec 04             	sub    $0x4,%esp
80108cf3:	6a 00                	push   $0x0
80108cf5:	52                   	push   %edx
80108cf6:	50                   	push   %eax
80108cf7:	e8 95 f3 ff ff       	call   80108091 <walkpgdir>
80108cfc:	83 c4 10             	add    $0x10,%esp
80108cff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  pte_from = choosePTESwap();
80108d02:	e8 80 f3 ff ff       	call   80108087 <choosePTESwap>
80108d07:	89 45 ec             	mov    %eax,-0x14(%ebp)
  cprintf("reading from swap\n");
80108d0a:	83 ec 0c             	sub    $0xc,%esp
80108d0d:	68 0e 96 10 80       	push   $0x8010960e
80108d12:	e8 af 76 ff ff       	call   801003c6 <cprintf>
80108d17:	83 c4 10             	add    $0x10,%esp
  readFromSwapFile(proc, buf, i*PGSIZE, PGSIZE);
80108d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d1d:	c1 e0 0c             	shl    $0xc,%eax
80108d20:	89 c2                	mov    %eax,%edx
80108d22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d28:	68 00 10 00 00       	push   $0x1000
80108d2d:	52                   	push   %edx
80108d2e:	8d 95 ec ef ff ff    	lea    -0x1014(%ebp),%edx
80108d34:	52                   	push   %edx
80108d35:	50                   	push   %eax
80108d36:	e8 f1 9b ff ff       	call   8010292c <readFromSwapFile>
80108d3b:	83 c4 10             	add    $0x10,%esp
  cprintf("finished reading from swap\n");
80108d3e:	83 ec 0c             	sub    $0xc,%esp
80108d41:	68 21 96 10 80       	push   $0x80109621
80108d46:	e8 7b 76 ff ff       	call   801003c6 <cprintf>
80108d4b:	83 c4 10             	add    $0x10,%esp
  writeToSwapFile(proc, (char*)P2V_WO(PTE_ADDR(*pte_from)), i*PGSIZE, PGSIZE);  
80108d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d51:	c1 e0 0c             	shl    $0xc,%eax
80108d54:	89 c1                	mov    %eax,%ecx
80108d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d59:	8b 00                	mov    (%eax),%eax
80108d5b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d60:	05 00 00 00 80       	add    $0x80000000,%eax
80108d65:	89 c2                	mov    %eax,%edx
80108d67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108d6d:	68 00 10 00 00       	push   $0x1000
80108d72:	51                   	push   %ecx
80108d73:	52                   	push   %edx
80108d74:	50                   	push   %eax
80108d75:	e8 85 9b ff ff       	call   801028ff <writeToSwapFile>
80108d7a:	83 c4 10             	add    $0x10,%esp
  memmove((void*)PTE_ADDR(*pte_to), (void*)buf, PGSIZE);
80108d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d80:	8b 00                	mov    (%eax),%eax
80108d82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d87:	89 c2                	mov    %eax,%edx
80108d89:	83 ec 04             	sub    $0x4,%esp
80108d8c:	68 00 10 00 00       	push   $0x1000
80108d91:	8d 85 ec ef ff ff    	lea    -0x1014(%ebp),%eax
80108d97:	50                   	push   %eax
80108d98:	52                   	push   %edx
80108d99:	e8 bc c9 ff ff       	call   8010575a <memmove>
80108d9e:	83 c4 10             	add    $0x10,%esp
  *pte_from |= PTE_PG;
80108da1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108da4:	8b 00                	mov    (%eax),%eax
80108da6:	80 cc 02             	or     $0x2,%ah
80108da9:	89 c2                	mov    %eax,%edx
80108dab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dae:	89 10                	mov    %edx,(%eax)
  *pte_from &= ~PTE_P;
80108db0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db3:	8b 00                	mov    (%eax),%eax
80108db5:	83 e0 fe             	and    $0xfffffffe,%eax
80108db8:	89 c2                	mov    %eax,%edx
80108dba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dbd:	89 10                	mov    %edx,(%eax)
  *pte_to |= PTE_P;
80108dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dc2:	8b 00                	mov    (%eax),%eax
80108dc4:	83 c8 01             	or     $0x1,%eax
80108dc7:	89 c2                	mov    %eax,%edx
80108dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dcc:	89 10                	mov    %edx,(%eax)
  *pte_to &= ~PTE_PG;
80108dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dd1:	8b 00                	mov    (%eax),%eax
80108dd3:	80 e4 fd             	and    $0xfd,%ah
80108dd6:	89 c2                	mov    %eax,%edx
80108dd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ddb:	89 10                	mov    %edx,(%eax)

  lcr3(v2p(proc->pgdir));
80108ddd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108de3:	8b 40 04             	mov    0x4(%eax),%eax
80108de6:	83 ec 0c             	sub    $0xc,%esp
80108de9:	50                   	push   %eax
80108dea:	e8 09 ee ff ff       	call   80107bf8 <v2p>
80108def:	83 c4 10             	add    $0x10,%esp
80108df2:	83 ec 0c             	sub    $0xc,%esp
80108df5:	50                   	push   %eax
80108df6:	e8 f1 ed ff ff       	call   80107bec <lcr3>
80108dfb:	83 c4 10             	add    $0x10,%esp
80108dfe:	eb 01                	jmp    80108e01 <swapPages+0x1f4>
void swapPages(uint va) {
  
  //TODO delet   cprintf("resched swapPages!\n");
  if (strncmp(proc->name, "init",strlen(proc->name)) == 0 || strncmp(proc->name, "sh",strlen(proc->name)) == 0) {
    //proc->pagesinmem++;
    return;
80108e00:	90                   	nop
  *pte_from &= ~PTE_P;
  *pte_to |= PTE_P;
  *pte_to &= ~PTE_PG;

  lcr3(v2p(proc->pgdir));
}
80108e01:	c9                   	leave  
80108e02:	c3                   	ret    
