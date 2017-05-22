
_malloc_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  int i;

  for(i = 1; i < 40; i++){
  11:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  18:	eb 14                	jmp    2e <main+0x2e>
  	malloc(4096);
  1a:	83 ec 0c             	sub    $0xc,%esp
  1d:	68 00 10 00 00       	push   $0x1000
  22:	e8 c5 06 00 00       	call   6ec <malloc>
  27:	83 c4 10             	add    $0x10,%esp
int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < 40; i++){
  2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  2e:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
  32:	7e e6                	jle    1a <main+0x1a>
  	malloc(4096);
  }
  printf(1,"finished malloc test - shit in your face\n");
  34:	83 ec 08             	sub    $0x8,%esp
  37:	68 d0 07 00 00       	push   $0x7d0
  3c:	6a 01                	push   $0x1
  3e:	e8 d6 03 00 00       	call   419 <printf>
  43:	83 c4 10             	add    $0x10,%esp

    
  exit();
  46:	e8 57 02 00 00       	call   2a2 <exit>

0000004b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  4b:	55                   	push   %ebp
  4c:	89 e5                	mov    %esp,%ebp
  4e:	57                   	push   %edi
  4f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  53:	8b 55 10             	mov    0x10(%ebp),%edx
  56:	8b 45 0c             	mov    0xc(%ebp),%eax
  59:	89 cb                	mov    %ecx,%ebx
  5b:	89 df                	mov    %ebx,%edi
  5d:	89 d1                	mov    %edx,%ecx
  5f:	fc                   	cld    
  60:	f3 aa                	rep stos %al,%es:(%edi)
  62:	89 ca                	mov    %ecx,%edx
  64:	89 fb                	mov    %edi,%ebx
  66:	89 5d 08             	mov    %ebx,0x8(%ebp)
  69:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  6c:	90                   	nop
  6d:	5b                   	pop    %ebx
  6e:	5f                   	pop    %edi
  6f:	5d                   	pop    %ebp
  70:	c3                   	ret    

00000071 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  71:	55                   	push   %ebp
  72:	89 e5                	mov    %esp,%ebp
  74:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  77:	8b 45 08             	mov    0x8(%ebp),%eax
  7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  7d:	90                   	nop
  7e:	8b 45 08             	mov    0x8(%ebp),%eax
  81:	8d 50 01             	lea    0x1(%eax),%edx
  84:	89 55 08             	mov    %edx,0x8(%ebp)
  87:	8b 55 0c             	mov    0xc(%ebp),%edx
  8a:	8d 4a 01             	lea    0x1(%edx),%ecx
  8d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  90:	0f b6 12             	movzbl (%edx),%edx
  93:	88 10                	mov    %dl,(%eax)
  95:	0f b6 00             	movzbl (%eax),%eax
  98:	84 c0                	test   %al,%al
  9a:	75 e2                	jne    7e <strcpy+0xd>
    ;
  return os;
  9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  9f:	c9                   	leave  
  a0:	c3                   	ret    

000000a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a1:	55                   	push   %ebp
  a2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  a4:	eb 08                	jmp    ae <strcmp+0xd>
    p++, q++;
  a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  aa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ae:	8b 45 08             	mov    0x8(%ebp),%eax
  b1:	0f b6 00             	movzbl (%eax),%eax
  b4:	84 c0                	test   %al,%al
  b6:	74 10                	je     c8 <strcmp+0x27>
  b8:	8b 45 08             	mov    0x8(%ebp),%eax
  bb:	0f b6 10             	movzbl (%eax),%edx
  be:	8b 45 0c             	mov    0xc(%ebp),%eax
  c1:	0f b6 00             	movzbl (%eax),%eax
  c4:	38 c2                	cmp    %al,%dl
  c6:	74 de                	je     a6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  c8:	8b 45 08             	mov    0x8(%ebp),%eax
  cb:	0f b6 00             	movzbl (%eax),%eax
  ce:	0f b6 d0             	movzbl %al,%edx
  d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  d4:	0f b6 00             	movzbl (%eax),%eax
  d7:	0f b6 c0             	movzbl %al,%eax
  da:	29 c2                	sub    %eax,%edx
  dc:	89 d0                	mov    %edx,%eax
}
  de:	5d                   	pop    %ebp
  df:	c3                   	ret    

000000e0 <strlen>:

uint
strlen(char *s)
{
  e0:	55                   	push   %ebp
  e1:	89 e5                	mov    %esp,%ebp
  e3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  ed:	eb 04                	jmp    f3 <strlen+0x13>
  ef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  f6:	8b 45 08             	mov    0x8(%ebp),%eax
  f9:	01 d0                	add    %edx,%eax
  fb:	0f b6 00             	movzbl (%eax),%eax
  fe:	84 c0                	test   %al,%al
 100:	75 ed                	jne    ef <strlen+0xf>
    ;
  return n;
 102:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 105:	c9                   	leave  
 106:	c3                   	ret    

00000107 <memset>:

void*
memset(void *dst, int c, uint n)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 10a:	8b 45 10             	mov    0x10(%ebp),%eax
 10d:	50                   	push   %eax
 10e:	ff 75 0c             	pushl  0xc(%ebp)
 111:	ff 75 08             	pushl  0x8(%ebp)
 114:	e8 32 ff ff ff       	call   4b <stosb>
 119:	83 c4 0c             	add    $0xc,%esp
  return dst;
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 11f:	c9                   	leave  
 120:	c3                   	ret    

00000121 <strchr>:

char*
strchr(const char *s, char c)
{
 121:	55                   	push   %ebp
 122:	89 e5                	mov    %esp,%ebp
 124:	83 ec 04             	sub    $0x4,%esp
 127:	8b 45 0c             	mov    0xc(%ebp),%eax
 12a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 12d:	eb 14                	jmp    143 <strchr+0x22>
    if(*s == c)
 12f:	8b 45 08             	mov    0x8(%ebp),%eax
 132:	0f b6 00             	movzbl (%eax),%eax
 135:	3a 45 fc             	cmp    -0x4(%ebp),%al
 138:	75 05                	jne    13f <strchr+0x1e>
      return (char*)s;
 13a:	8b 45 08             	mov    0x8(%ebp),%eax
 13d:	eb 13                	jmp    152 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 13f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 143:	8b 45 08             	mov    0x8(%ebp),%eax
 146:	0f b6 00             	movzbl (%eax),%eax
 149:	84 c0                	test   %al,%al
 14b:	75 e2                	jne    12f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 14d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 152:	c9                   	leave  
 153:	c3                   	ret    

00000154 <gets>:

char*
gets(char *buf, int max)
{
 154:	55                   	push   %ebp
 155:	89 e5                	mov    %esp,%ebp
 157:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 161:	eb 42                	jmp    1a5 <gets+0x51>
    cc = read(0, &c, 1);
 163:	83 ec 04             	sub    $0x4,%esp
 166:	6a 01                	push   $0x1
 168:	8d 45 ef             	lea    -0x11(%ebp),%eax
 16b:	50                   	push   %eax
 16c:	6a 00                	push   $0x0
 16e:	e8 47 01 00 00       	call   2ba <read>
 173:	83 c4 10             	add    $0x10,%esp
 176:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 179:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 17d:	7e 33                	jle    1b2 <gets+0x5e>
      break;
    buf[i++] = c;
 17f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 182:	8d 50 01             	lea    0x1(%eax),%edx
 185:	89 55 f4             	mov    %edx,-0xc(%ebp)
 188:	89 c2                	mov    %eax,%edx
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	01 c2                	add    %eax,%edx
 18f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 193:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 195:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 199:	3c 0a                	cmp    $0xa,%al
 19b:	74 16                	je     1b3 <gets+0x5f>
 19d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1a1:	3c 0d                	cmp    $0xd,%al
 1a3:	74 0e                	je     1b3 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a8:	83 c0 01             	add    $0x1,%eax
 1ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1ae:	7c b3                	jl     163 <gets+0xf>
 1b0:	eb 01                	jmp    1b3 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1b2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1b6:	8b 45 08             	mov    0x8(%ebp),%eax
 1b9:	01 d0                	add    %edx,%eax
 1bb:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1be:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c1:	c9                   	leave  
 1c2:	c3                   	ret    

000001c3 <stat>:

int
stat(char *n, struct stat *st)
{
 1c3:	55                   	push   %ebp
 1c4:	89 e5                	mov    %esp,%ebp
 1c6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c9:	83 ec 08             	sub    $0x8,%esp
 1cc:	6a 00                	push   $0x0
 1ce:	ff 75 08             	pushl  0x8(%ebp)
 1d1:	e8 0c 01 00 00       	call   2e2 <open>
 1d6:	83 c4 10             	add    $0x10,%esp
 1d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1e0:	79 07                	jns    1e9 <stat+0x26>
    return -1;
 1e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1e7:	eb 25                	jmp    20e <stat+0x4b>
  r = fstat(fd, st);
 1e9:	83 ec 08             	sub    $0x8,%esp
 1ec:	ff 75 0c             	pushl  0xc(%ebp)
 1ef:	ff 75 f4             	pushl  -0xc(%ebp)
 1f2:	e8 03 01 00 00       	call   2fa <fstat>
 1f7:	83 c4 10             	add    $0x10,%esp
 1fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1fd:	83 ec 0c             	sub    $0xc,%esp
 200:	ff 75 f4             	pushl  -0xc(%ebp)
 203:	e8 c2 00 00 00       	call   2ca <close>
 208:	83 c4 10             	add    $0x10,%esp
  return r;
 20b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 20e:	c9                   	leave  
 20f:	c3                   	ret    

00000210 <atoi>:

int
atoi(const char *s)
{
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 216:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 21d:	eb 25                	jmp    244 <atoi+0x34>
    n = n*10 + *s++ - '0';
 21f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 222:	89 d0                	mov    %edx,%eax
 224:	c1 e0 02             	shl    $0x2,%eax
 227:	01 d0                	add    %edx,%eax
 229:	01 c0                	add    %eax,%eax
 22b:	89 c1                	mov    %eax,%ecx
 22d:	8b 45 08             	mov    0x8(%ebp),%eax
 230:	8d 50 01             	lea    0x1(%eax),%edx
 233:	89 55 08             	mov    %edx,0x8(%ebp)
 236:	0f b6 00             	movzbl (%eax),%eax
 239:	0f be c0             	movsbl %al,%eax
 23c:	01 c8                	add    %ecx,%eax
 23e:	83 e8 30             	sub    $0x30,%eax
 241:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 244:	8b 45 08             	mov    0x8(%ebp),%eax
 247:	0f b6 00             	movzbl (%eax),%eax
 24a:	3c 2f                	cmp    $0x2f,%al
 24c:	7e 0a                	jle    258 <atoi+0x48>
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
 251:	0f b6 00             	movzbl (%eax),%eax
 254:	3c 39                	cmp    $0x39,%al
 256:	7e c7                	jle    21f <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 258:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 25b:	c9                   	leave  
 25c:	c3                   	ret    

0000025d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 25d:	55                   	push   %ebp
 25e:	89 e5                	mov    %esp,%ebp
 260:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 263:	8b 45 08             	mov    0x8(%ebp),%eax
 266:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 269:	8b 45 0c             	mov    0xc(%ebp),%eax
 26c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 26f:	eb 17                	jmp    288 <memmove+0x2b>
    *dst++ = *src++;
 271:	8b 45 fc             	mov    -0x4(%ebp),%eax
 274:	8d 50 01             	lea    0x1(%eax),%edx
 277:	89 55 fc             	mov    %edx,-0x4(%ebp)
 27a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 27d:	8d 4a 01             	lea    0x1(%edx),%ecx
 280:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 283:	0f b6 12             	movzbl (%edx),%edx
 286:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 288:	8b 45 10             	mov    0x10(%ebp),%eax
 28b:	8d 50 ff             	lea    -0x1(%eax),%edx
 28e:	89 55 10             	mov    %edx,0x10(%ebp)
 291:	85 c0                	test   %eax,%eax
 293:	7f dc                	jg     271 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 295:	8b 45 08             	mov    0x8(%ebp),%eax
}
 298:	c9                   	leave  
 299:	c3                   	ret    

0000029a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 29a:	b8 01 00 00 00       	mov    $0x1,%eax
 29f:	cd 40                	int    $0x40
 2a1:	c3                   	ret    

000002a2 <exit>:
SYSCALL(exit)
 2a2:	b8 02 00 00 00       	mov    $0x2,%eax
 2a7:	cd 40                	int    $0x40
 2a9:	c3                   	ret    

000002aa <wait>:
SYSCALL(wait)
 2aa:	b8 03 00 00 00       	mov    $0x3,%eax
 2af:	cd 40                	int    $0x40
 2b1:	c3                   	ret    

000002b2 <pipe>:
SYSCALL(pipe)
 2b2:	b8 04 00 00 00       	mov    $0x4,%eax
 2b7:	cd 40                	int    $0x40
 2b9:	c3                   	ret    

000002ba <read>:
SYSCALL(read)
 2ba:	b8 05 00 00 00       	mov    $0x5,%eax
 2bf:	cd 40                	int    $0x40
 2c1:	c3                   	ret    

000002c2 <write>:
SYSCALL(write)
 2c2:	b8 10 00 00 00       	mov    $0x10,%eax
 2c7:	cd 40                	int    $0x40
 2c9:	c3                   	ret    

000002ca <close>:
SYSCALL(close)
 2ca:	b8 15 00 00 00       	mov    $0x15,%eax
 2cf:	cd 40                	int    $0x40
 2d1:	c3                   	ret    

000002d2 <kill>:
SYSCALL(kill)
 2d2:	b8 06 00 00 00       	mov    $0x6,%eax
 2d7:	cd 40                	int    $0x40
 2d9:	c3                   	ret    

000002da <exec>:
SYSCALL(exec)
 2da:	b8 07 00 00 00       	mov    $0x7,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <open>:
SYSCALL(open)
 2e2:	b8 0f 00 00 00       	mov    $0xf,%eax
 2e7:	cd 40                	int    $0x40
 2e9:	c3                   	ret    

000002ea <mknod>:
SYSCALL(mknod)
 2ea:	b8 11 00 00 00       	mov    $0x11,%eax
 2ef:	cd 40                	int    $0x40
 2f1:	c3                   	ret    

000002f2 <unlink>:
SYSCALL(unlink)
 2f2:	b8 12 00 00 00       	mov    $0x12,%eax
 2f7:	cd 40                	int    $0x40
 2f9:	c3                   	ret    

000002fa <fstat>:
SYSCALL(fstat)
 2fa:	b8 08 00 00 00       	mov    $0x8,%eax
 2ff:	cd 40                	int    $0x40
 301:	c3                   	ret    

00000302 <link>:
SYSCALL(link)
 302:	b8 13 00 00 00       	mov    $0x13,%eax
 307:	cd 40                	int    $0x40
 309:	c3                   	ret    

0000030a <mkdir>:
SYSCALL(mkdir)
 30a:	b8 14 00 00 00       	mov    $0x14,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <chdir>:
SYSCALL(chdir)
 312:	b8 09 00 00 00       	mov    $0x9,%eax
 317:	cd 40                	int    $0x40
 319:	c3                   	ret    

0000031a <dup>:
SYSCALL(dup)
 31a:	b8 0a 00 00 00       	mov    $0xa,%eax
 31f:	cd 40                	int    $0x40
 321:	c3                   	ret    

00000322 <getpid>:
SYSCALL(getpid)
 322:	b8 0b 00 00 00       	mov    $0xb,%eax
 327:	cd 40                	int    $0x40
 329:	c3                   	ret    

0000032a <sbrk>:
SYSCALL(sbrk)
 32a:	b8 0c 00 00 00       	mov    $0xc,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <sleep>:
SYSCALL(sleep)
 332:	b8 0d 00 00 00       	mov    $0xd,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <uptime>:
SYSCALL(uptime)
 33a:	b8 0e 00 00 00       	mov    $0xe,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 342:	55                   	push   %ebp
 343:	89 e5                	mov    %esp,%ebp
 345:	83 ec 18             	sub    $0x18,%esp
 348:	8b 45 0c             	mov    0xc(%ebp),%eax
 34b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 34e:	83 ec 04             	sub    $0x4,%esp
 351:	6a 01                	push   $0x1
 353:	8d 45 f4             	lea    -0xc(%ebp),%eax
 356:	50                   	push   %eax
 357:	ff 75 08             	pushl  0x8(%ebp)
 35a:	e8 63 ff ff ff       	call   2c2 <write>
 35f:	83 c4 10             	add    $0x10,%esp
}
 362:	90                   	nop
 363:	c9                   	leave  
 364:	c3                   	ret    

00000365 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 365:	55                   	push   %ebp
 366:	89 e5                	mov    %esp,%ebp
 368:	53                   	push   %ebx
 369:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 36c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 373:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 377:	74 17                	je     390 <printint+0x2b>
 379:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 37d:	79 11                	jns    390 <printint+0x2b>
    neg = 1;
 37f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 386:	8b 45 0c             	mov    0xc(%ebp),%eax
 389:	f7 d8                	neg    %eax
 38b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 38e:	eb 06                	jmp    396 <printint+0x31>
  } else {
    x = xx;
 390:	8b 45 0c             	mov    0xc(%ebp),%eax
 393:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 396:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 39d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3a0:	8d 41 01             	lea    0x1(%ecx),%eax
 3a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ac:	ba 00 00 00 00       	mov    $0x0,%edx
 3b1:	f7 f3                	div    %ebx
 3b3:	89 d0                	mov    %edx,%eax
 3b5:	0f b6 80 4c 0a 00 00 	movzbl 0xa4c(%eax),%eax
 3bc:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3c6:	ba 00 00 00 00       	mov    $0x0,%edx
 3cb:	f7 f3                	div    %ebx
 3cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3d0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3d4:	75 c7                	jne    39d <printint+0x38>
  if(neg)
 3d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3da:	74 2d                	je     409 <printint+0xa4>
    buf[i++] = '-';
 3dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3df:	8d 50 01             	lea    0x1(%eax),%edx
 3e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3e5:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3ea:	eb 1d                	jmp    409 <printint+0xa4>
    putc(fd, buf[i]);
 3ec:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f2:	01 d0                	add    %edx,%eax
 3f4:	0f b6 00             	movzbl (%eax),%eax
 3f7:	0f be c0             	movsbl %al,%eax
 3fa:	83 ec 08             	sub    $0x8,%esp
 3fd:	50                   	push   %eax
 3fe:	ff 75 08             	pushl  0x8(%ebp)
 401:	e8 3c ff ff ff       	call   342 <putc>
 406:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 409:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 40d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 411:	79 d9                	jns    3ec <printint+0x87>
    putc(fd, buf[i]);
}
 413:	90                   	nop
 414:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 417:	c9                   	leave  
 418:	c3                   	ret    

00000419 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 419:	55                   	push   %ebp
 41a:	89 e5                	mov    %esp,%ebp
 41c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 41f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 426:	8d 45 0c             	lea    0xc(%ebp),%eax
 429:	83 c0 04             	add    $0x4,%eax
 42c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 42f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 436:	e9 59 01 00 00       	jmp    594 <printf+0x17b>
    c = fmt[i] & 0xff;
 43b:	8b 55 0c             	mov    0xc(%ebp),%edx
 43e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 441:	01 d0                	add    %edx,%eax
 443:	0f b6 00             	movzbl (%eax),%eax
 446:	0f be c0             	movsbl %al,%eax
 449:	25 ff 00 00 00       	and    $0xff,%eax
 44e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 451:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 455:	75 2c                	jne    483 <printf+0x6a>
      if(c == '%'){
 457:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 45b:	75 0c                	jne    469 <printf+0x50>
        state = '%';
 45d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 464:	e9 27 01 00 00       	jmp    590 <printf+0x177>
      } else {
        putc(fd, c);
 469:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 46c:	0f be c0             	movsbl %al,%eax
 46f:	83 ec 08             	sub    $0x8,%esp
 472:	50                   	push   %eax
 473:	ff 75 08             	pushl  0x8(%ebp)
 476:	e8 c7 fe ff ff       	call   342 <putc>
 47b:	83 c4 10             	add    $0x10,%esp
 47e:	e9 0d 01 00 00       	jmp    590 <printf+0x177>
      }
    } else if(state == '%'){
 483:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 487:	0f 85 03 01 00 00    	jne    590 <printf+0x177>
      if(c == 'd'){
 48d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 491:	75 1e                	jne    4b1 <printf+0x98>
        printint(fd, *ap, 10, 1);
 493:	8b 45 e8             	mov    -0x18(%ebp),%eax
 496:	8b 00                	mov    (%eax),%eax
 498:	6a 01                	push   $0x1
 49a:	6a 0a                	push   $0xa
 49c:	50                   	push   %eax
 49d:	ff 75 08             	pushl  0x8(%ebp)
 4a0:	e8 c0 fe ff ff       	call   365 <printint>
 4a5:	83 c4 10             	add    $0x10,%esp
        ap++;
 4a8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4ac:	e9 d8 00 00 00       	jmp    589 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4b1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4b5:	74 06                	je     4bd <printf+0xa4>
 4b7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4bb:	75 1e                	jne    4db <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4c0:	8b 00                	mov    (%eax),%eax
 4c2:	6a 00                	push   $0x0
 4c4:	6a 10                	push   $0x10
 4c6:	50                   	push   %eax
 4c7:	ff 75 08             	pushl  0x8(%ebp)
 4ca:	e8 96 fe ff ff       	call   365 <printint>
 4cf:	83 c4 10             	add    $0x10,%esp
        ap++;
 4d2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4d6:	e9 ae 00 00 00       	jmp    589 <printf+0x170>
      } else if(c == 's'){
 4db:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4df:	75 43                	jne    524 <printf+0x10b>
        s = (char*)*ap;
 4e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e4:	8b 00                	mov    (%eax),%eax
 4e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4e9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f1:	75 25                	jne    518 <printf+0xff>
          s = "(null)";
 4f3:	c7 45 f4 fa 07 00 00 	movl   $0x7fa,-0xc(%ebp)
        while(*s != 0){
 4fa:	eb 1c                	jmp    518 <printf+0xff>
          putc(fd, *s);
 4fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ff:	0f b6 00             	movzbl (%eax),%eax
 502:	0f be c0             	movsbl %al,%eax
 505:	83 ec 08             	sub    $0x8,%esp
 508:	50                   	push   %eax
 509:	ff 75 08             	pushl  0x8(%ebp)
 50c:	e8 31 fe ff ff       	call   342 <putc>
 511:	83 c4 10             	add    $0x10,%esp
          s++;
 514:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 518:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51b:	0f b6 00             	movzbl (%eax),%eax
 51e:	84 c0                	test   %al,%al
 520:	75 da                	jne    4fc <printf+0xe3>
 522:	eb 65                	jmp    589 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 524:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 528:	75 1d                	jne    547 <printf+0x12e>
        putc(fd, *ap);
 52a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 52d:	8b 00                	mov    (%eax),%eax
 52f:	0f be c0             	movsbl %al,%eax
 532:	83 ec 08             	sub    $0x8,%esp
 535:	50                   	push   %eax
 536:	ff 75 08             	pushl  0x8(%ebp)
 539:	e8 04 fe ff ff       	call   342 <putc>
 53e:	83 c4 10             	add    $0x10,%esp
        ap++;
 541:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 545:	eb 42                	jmp    589 <printf+0x170>
      } else if(c == '%'){
 547:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 54b:	75 17                	jne    564 <printf+0x14b>
        putc(fd, c);
 54d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 550:	0f be c0             	movsbl %al,%eax
 553:	83 ec 08             	sub    $0x8,%esp
 556:	50                   	push   %eax
 557:	ff 75 08             	pushl  0x8(%ebp)
 55a:	e8 e3 fd ff ff       	call   342 <putc>
 55f:	83 c4 10             	add    $0x10,%esp
 562:	eb 25                	jmp    589 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 564:	83 ec 08             	sub    $0x8,%esp
 567:	6a 25                	push   $0x25
 569:	ff 75 08             	pushl  0x8(%ebp)
 56c:	e8 d1 fd ff ff       	call   342 <putc>
 571:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 574:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 577:	0f be c0             	movsbl %al,%eax
 57a:	83 ec 08             	sub    $0x8,%esp
 57d:	50                   	push   %eax
 57e:	ff 75 08             	pushl  0x8(%ebp)
 581:	e8 bc fd ff ff       	call   342 <putc>
 586:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 589:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 590:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 594:	8b 55 0c             	mov    0xc(%ebp),%edx
 597:	8b 45 f0             	mov    -0x10(%ebp),%eax
 59a:	01 d0                	add    %edx,%eax
 59c:	0f b6 00             	movzbl (%eax),%eax
 59f:	84 c0                	test   %al,%al
 5a1:	0f 85 94 fe ff ff    	jne    43b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5a7:	90                   	nop
 5a8:	c9                   	leave  
 5a9:	c3                   	ret    

000005aa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5aa:	55                   	push   %ebp
 5ab:	89 e5                	mov    %esp,%ebp
 5ad:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5b0:	8b 45 08             	mov    0x8(%ebp),%eax
 5b3:	83 e8 08             	sub    $0x8,%eax
 5b6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5b9:	a1 68 0a 00 00       	mov    0xa68,%eax
 5be:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5c1:	eb 24                	jmp    5e7 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c6:	8b 00                	mov    (%eax),%eax
 5c8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5cb:	77 12                	ja     5df <free+0x35>
 5cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5d0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5d3:	77 24                	ja     5f9 <free+0x4f>
 5d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d8:	8b 00                	mov    (%eax),%eax
 5da:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5dd:	77 1a                	ja     5f9 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e2:	8b 00                	mov    (%eax),%eax
 5e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ea:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5ed:	76 d4                	jbe    5c3 <free+0x19>
 5ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f2:	8b 00                	mov    (%eax),%eax
 5f4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5f7:	76 ca                	jbe    5c3 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5fc:	8b 40 04             	mov    0x4(%eax),%eax
 5ff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 606:	8b 45 f8             	mov    -0x8(%ebp),%eax
 609:	01 c2                	add    %eax,%edx
 60b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60e:	8b 00                	mov    (%eax),%eax
 610:	39 c2                	cmp    %eax,%edx
 612:	75 24                	jne    638 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 614:	8b 45 f8             	mov    -0x8(%ebp),%eax
 617:	8b 50 04             	mov    0x4(%eax),%edx
 61a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61d:	8b 00                	mov    (%eax),%eax
 61f:	8b 40 04             	mov    0x4(%eax),%eax
 622:	01 c2                	add    %eax,%edx
 624:	8b 45 f8             	mov    -0x8(%ebp),%eax
 627:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 62a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62d:	8b 00                	mov    (%eax),%eax
 62f:	8b 10                	mov    (%eax),%edx
 631:	8b 45 f8             	mov    -0x8(%ebp),%eax
 634:	89 10                	mov    %edx,(%eax)
 636:	eb 0a                	jmp    642 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 638:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63b:	8b 10                	mov    (%eax),%edx
 63d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 640:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 642:	8b 45 fc             	mov    -0x4(%ebp),%eax
 645:	8b 40 04             	mov    0x4(%eax),%eax
 648:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 64f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 652:	01 d0                	add    %edx,%eax
 654:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 657:	75 20                	jne    679 <free+0xcf>
    p->s.size += bp->s.size;
 659:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65c:	8b 50 04             	mov    0x4(%eax),%edx
 65f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 662:	8b 40 04             	mov    0x4(%eax),%eax
 665:	01 c2                	add    %eax,%edx
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 66d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 670:	8b 10                	mov    (%eax),%edx
 672:	8b 45 fc             	mov    -0x4(%ebp),%eax
 675:	89 10                	mov    %edx,(%eax)
 677:	eb 08                	jmp    681 <free+0xd7>
  } else
    p->s.ptr = bp;
 679:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 67f:	89 10                	mov    %edx,(%eax)
  freep = p;
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	a3 68 0a 00 00       	mov    %eax,0xa68
}
 689:	90                   	nop
 68a:	c9                   	leave  
 68b:	c3                   	ret    

0000068c <morecore>:

static Header*
morecore(uint nu)
{
 68c:	55                   	push   %ebp
 68d:	89 e5                	mov    %esp,%ebp
 68f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 692:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 699:	77 07                	ja     6a2 <morecore+0x16>
    nu = 4096;
 69b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6a2:	8b 45 08             	mov    0x8(%ebp),%eax
 6a5:	c1 e0 03             	shl    $0x3,%eax
 6a8:	83 ec 0c             	sub    $0xc,%esp
 6ab:	50                   	push   %eax
 6ac:	e8 79 fc ff ff       	call   32a <sbrk>
 6b1:	83 c4 10             	add    $0x10,%esp
 6b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6b7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6bb:	75 07                	jne    6c4 <morecore+0x38>
    return 0;
 6bd:	b8 00 00 00 00       	mov    $0x0,%eax
 6c2:	eb 26                	jmp    6ea <morecore+0x5e>
  hp = (Header*)p;
 6c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6cd:	8b 55 08             	mov    0x8(%ebp),%edx
 6d0:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d6:	83 c0 08             	add    $0x8,%eax
 6d9:	83 ec 0c             	sub    $0xc,%esp
 6dc:	50                   	push   %eax
 6dd:	e8 c8 fe ff ff       	call   5aa <free>
 6e2:	83 c4 10             	add    $0x10,%esp
  return freep;
 6e5:	a1 68 0a 00 00       	mov    0xa68,%eax
}
 6ea:	c9                   	leave  
 6eb:	c3                   	ret    

000006ec <malloc>:

void*
malloc(uint nbytes)
{
 6ec:	55                   	push   %ebp
 6ed:	89 e5                	mov    %esp,%ebp
 6ef:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6f2:	8b 45 08             	mov    0x8(%ebp),%eax
 6f5:	83 c0 07             	add    $0x7,%eax
 6f8:	c1 e8 03             	shr    $0x3,%eax
 6fb:	83 c0 01             	add    $0x1,%eax
 6fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 701:	a1 68 0a 00 00       	mov    0xa68,%eax
 706:	89 45 f0             	mov    %eax,-0x10(%ebp)
 709:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 70d:	75 23                	jne    732 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 70f:	c7 45 f0 60 0a 00 00 	movl   $0xa60,-0x10(%ebp)
 716:	8b 45 f0             	mov    -0x10(%ebp),%eax
 719:	a3 68 0a 00 00       	mov    %eax,0xa68
 71e:	a1 68 0a 00 00       	mov    0xa68,%eax
 723:	a3 60 0a 00 00       	mov    %eax,0xa60
    base.s.size = 0;
 728:	c7 05 64 0a 00 00 00 	movl   $0x0,0xa64
 72f:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 732:	8b 45 f0             	mov    -0x10(%ebp),%eax
 735:	8b 00                	mov    (%eax),%eax
 737:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 73a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73d:	8b 40 04             	mov    0x4(%eax),%eax
 740:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 743:	72 4d                	jb     792 <malloc+0xa6>
      if(p->s.size == nunits)
 745:	8b 45 f4             	mov    -0xc(%ebp),%eax
 748:	8b 40 04             	mov    0x4(%eax),%eax
 74b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 74e:	75 0c                	jne    75c <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 750:	8b 45 f4             	mov    -0xc(%ebp),%eax
 753:	8b 10                	mov    (%eax),%edx
 755:	8b 45 f0             	mov    -0x10(%ebp),%eax
 758:	89 10                	mov    %edx,(%eax)
 75a:	eb 26                	jmp    782 <malloc+0x96>
      else {
        p->s.size -= nunits;
 75c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75f:	8b 40 04             	mov    0x4(%eax),%eax
 762:	2b 45 ec             	sub    -0x14(%ebp),%eax
 765:	89 c2                	mov    %eax,%edx
 767:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 76d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 770:	8b 40 04             	mov    0x4(%eax),%eax
 773:	c1 e0 03             	shl    $0x3,%eax
 776:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 779:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77c:	8b 55 ec             	mov    -0x14(%ebp),%edx
 77f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 782:	8b 45 f0             	mov    -0x10(%ebp),%eax
 785:	a3 68 0a 00 00       	mov    %eax,0xa68
      return (void*)(p + 1);
 78a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78d:	83 c0 08             	add    $0x8,%eax
 790:	eb 3b                	jmp    7cd <malloc+0xe1>
    }
    if(p == freep)
 792:	a1 68 0a 00 00       	mov    0xa68,%eax
 797:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 79a:	75 1e                	jne    7ba <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 79c:	83 ec 0c             	sub    $0xc,%esp
 79f:	ff 75 ec             	pushl  -0x14(%ebp)
 7a2:	e8 e5 fe ff ff       	call   68c <morecore>
 7a7:	83 c4 10             	add    $0x10,%esp
 7aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7b1:	75 07                	jne    7ba <malloc+0xce>
        return 0;
 7b3:	b8 00 00 00 00       	mov    $0x0,%eax
 7b8:	eb 13                	jmp    7cd <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c3:	8b 00                	mov    (%eax),%eax
 7c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7c8:	e9 6d ff ff ff       	jmp    73a <malloc+0x4e>
}
 7cd:	c9                   	leave  
 7ce:	c3                   	ret    
