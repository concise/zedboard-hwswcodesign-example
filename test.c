/*
 * Test the 1024-bit Montgomery multiplier (R = 2^1040)
 *
 *
 * Memory map
 *
 * 0x0000   (4) RW: Control register
 *                  bit   17 RO:  System reset done
 *                  bit   16 RO:  Multiplication done
 *                  bit   15 RW:  System reset start
 *                  bit  2,1 RW:  Select multiplication mode
 *                  bit    0 RW:  Multiplication start
 * 0x0004 (128) RO: C <- A B R^(-1) mod N  if {bit 2, bit 1} = 00
 *                  C <- A   R      mod N  if {bit 2, bit 1} = 01
 *                  C <- A   R^(-1) mod N  if {bit 2, bit 1} = 10
 * 0x0084 (128) RW: A
 * 0x0104 (128) RW: B
 * 0x0184 (128) RW: Modulus (N)
 *
 *
 * Least significant first indexing
 *
 *     ctrl         C             A             B             N
 * +---------+-------------+-------------+-------------+-------------+
 * | 0 1 2 3 |  4  ... 131 | 132 ... 259 | 260 ... 387 | 388 ... 515 |
 * +---------+-------------+-------------+-------------+-------------+
 *
 *     ctrl         C             A             B             N
 * +---------+-------------+-------------+-------------+-------------+
 * |    0    |  1  ...  32 |  33 ...  64 |  65 ...  96 |  97 ... 128 |
 * +---------+-------------+-------------+-------------+-------------+
 */

#include <assert.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <fcntl.h>
#include <poll.h>
#include <sys/mman.h>
#include <unistd.h>

#define MMIP_RESET_START (1 << 15)
#define MMIP_RESET_DONE  (1 << 17)

#define MMIP_MULTI_START (1 <<  0)
#define MMIP_MULTI_DONE  (1 << 16)

#define MMIP_MODE_NORMAL 0
#define MMIP_MODE_ENCODE (1 << 1)
#define MMIP_MODE_DECODE (1 << 2)

#define CONSUME_ONE_INTERRUPT(fd)   \
    do {                            \
        uint32_t buf;               \
        read(fd, &buf, 4);          \
        buf = 1;                    \
        write(fd, &buf, 4);         \
    } while (0)

static const uint32_t tvN[32] = {
    0xb889530b, 0xd788f313, 0x416809cf, 0x5c8ce6da, 0x133598db, 0x90b3f991,
    0x2f6289cb, 0xa2f4edcf, 0x452baeeb, 0x0bf35412, 0x414ea6e6, 0x8ed9f85d,
    0x3bf499ae, 0xd3671f43, 0xa0e8a7ab, 0xd7a98f93, 0x02d03fee, 0x317bd231,
    0x8e4afbd0, 0x3b742c68, 0x058c424f, 0xcc19987a, 0x40a6146c, 0x92b0a085,
    0x2f95a596, 0xdac85478, 0x24bedc54, 0x5b8cb99f, 0xf4f1afa7, 0xbeaa6bfd,
    0x16d3335b, 0xf2de7c55, };

static const uint32_t tvA[32] = {
    0x1c87490b, 0xd0db52d3, 0x83ac475e, 0xa75060a0, 0x0b70c897, 0x04dffb07,
    0x551e1aa5, 0xc72dd0c9, 0x85460eaa, 0xe26f4d7a, 0x2ec64fe4, 0x86744ac5,
    0xb36c144e, 0x9d75f642, 0x147c8cb1, 0x2e7170e9, 0xe39978de, 0x7277152c,
    0x94f6f089, 0x147c14a9, 0xe1e2ce95, 0x45570348, 0xc5d5fc52, 0x26b8ddfa,
    0x265210ad, 0x32365372, 0xddac4f03, 0x07474fcf, 0xdd90de36, 0x23d1d1e3,
    0x7ea8edde, 0xe3d4a95d, };

static const uint32_t tvB[32] = {
    0xc16cfce7, 0x8a1e09a8, 0x7c6c29bc, 0x53167218, 0x67d3b522, 0x69b4715c,
    0xd717d114, 0x37c3cfa4, 0x6a574c88, 0xa61421b0, 0xe5e21c18, 0x9e7bd97a,
    0xa2b19d6d, 0x38eb03ec, 0xa8e5c4b8, 0x0c0ddff5, 0xa61c7d89, 0x90f9b857,
    0x4eab7b75, 0x0a25774a, 0x9099bd58, 0xc4d446fc, 0xeaf5ce92, 0xaf3fd58c,
    0xc7ab46aa, 0xf4f0a481, 0xfe6b8af9, 0x7e732a3b, 0x985077b3, 0x60fa2c47,
    0xfa6ffcbe, 0xc8473e97, };

static void send_1024(volatile uint32_t *mem, const uint32_t *src)
{
    int i;
    for (i = 0; i <= 31; i++)
        mem[i] = src[i];
}

static void dump_1024(volatile const uint32_t *mem)
{
    int i;
    for (i = 31; i >= 0; i--)
        printf("%08x", mem[i]);
    printf("\n");
}

static void clear_if_any_interrupts(int fd)
{
    uint32_t buf = 1;
    write(fd, &buf, 4);
    while (1) {
        struct pollfd fds = { .fd = fd, .events = POLLIN };
        int ret = poll(&fds, 1, 0);
        assert(ret != -1);
        if (ret > 0) {
            CONSUME_ONE_INTERRUPT(fd);
        } else {
            break;
        }
    }
}

int main(void)
{
    // open the device
    int fd = open("/dev/uio0", O_RDWR);
    assert(fd != -1);

    // map the device into memory
    void *ptr = mmap(0, 0x10000, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    assert(ptr != MAP_FAILED);

    // access device memory through these pointers
    volatile uint32_t *ctrl = (uint32_t *)ptr;
    volatile uint32_t *memC = (uint32_t *)ptr + 1;
    volatile uint32_t *memA = (uint32_t *)ptr + 33;
    volatile uint32_t *memB = (uint32_t *)ptr + 65;
    volatile uint32_t *memN = (uint32_t *)ptr + 97;

    // enable interrupt
    clear_if_any_interrupts(fd);



    // send 1024-bit integer N to MMIP (N must be an odd number)
    send_1024(memN, tvN);

    // request MMIP to do "reset" (precomputations related to N)
    *ctrl = MMIP_RESET_START;
    *ctrl = 0;
    #ifdef USE_POLLING
        while (!(*ctrl & MMIP_RESET_DONE)) {}
    #else
        CONSUME_ONE_INTERRUPT(fd);
    #endif



    // send 1024-bit integer A to MMIP
    send_1024(memA, tvA);

    // send 1024-bit integer B to MMIP
    send_1024(memB, tvB);



    // request MMIP to do C <- A B R^(-1) mod N
    *ctrl = MMIP_MODE_NORMAL | MMIP_MULTI_START;
    *ctrl = MMIP_MODE_NORMAL;
    #ifdef USE_POLLING
        while (!(*ctrl & MMIP_MULTI_DONE)) {}
    #else
        CONSUME_ONE_INTERRUPT(fd);
    #endif
    dump_1024(memC);



    // request MMIP to do C <- A R mod N
    *ctrl = MMIP_MODE_ENCODE | MMIP_MULTI_START;
    *ctrl = MMIP_MODE_ENCODE;
    #ifdef USE_POLLING
        while (!(*ctrl & MMIP_MULTI_DONE)) {}
    #else
        CONSUME_ONE_INTERRUPT(fd);
    #endif
    dump_1024(memC);



    // request MMIP to do C <- A R^(-1) mod N
    *ctrl = MMIP_MODE_DECODE | MMIP_MULTI_START;
    *ctrl = MMIP_MODE_DECODE;
    #ifdef USE_POLLING
        while (!(*ctrl & MMIP_MULTI_DONE)) {}
    #else
        CONSUME_ONE_INTERRUPT(fd);
    #endif
    dump_1024(memC);



    // clean up
    munmap(ptr, 0x10000);
    close(fd);
    return 0;
}
