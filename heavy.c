#include <string.h>

#include "sha2.h"
#include "hefty1.h"
#include "heavy.h"
#include "sph_keccak.h"
#include "sph_blake.h"
#include "sph_groestl.h"


/* Combines top 64-bits from each hash into a single hash */
static void combine_hashes(uint32_t *out, uint32_t *hash1, uint32_t *hash2, uint32_t *hash3, uint32_t *hash4)
{
    uint32_t *hash[4] = { hash1, hash2, hash3, hash4 };

    /* Transpose first 64 bits of each hash into out */
    memset(out, 0, 32);
    int bits = 0;
    uint32_t i, mask, k;
    for (i = 7; i >= 6; i--) {
        for (mask = 0x80000000; mask; mask >>= 1) {
            for (k = 0; k < 4; k++) {
                out[(255 - bits)/32] <<= 1;
                if ((hash[k][i] & mask) != 0)
                    out[(255 - bits)/32] |= 1;
                bits++;
            }
        }
    }
}

void heavycoin_hash(const char* input, int len, char* output)
{
    unsigned char hash1[32];
    HEFTY1((unsigned char *)input, len, hash1);

    /* HEFTY1 is new, so take an extra security measure to eliminate
     * the possiblity of collisions:
     *
     *     Hash(x) = SHA256(x + HEFTY1(x))
     *
     * N.B. '+' is concatenation.
     */
    unsigned char hash2[32];;

    sha256_ctx ctx;
    sha256_init(&ctx);
    sha256_update(&ctx, (const unsigned char *)input, len);
    sha256_update(&ctx, hash1, sizeof(hash1));
    sha256_final(&ctx, hash2);

    /* Additional security: Do not rely on a single cryptographic hash
     * function.  Instead, combine the outputs of 4 of the most secure
     * cryptographic hash functions-- SHA256, KECCAK512, GROESTL512
     * and BLAKE512.
     */

    uint32_t hash3[16];
    sph_keccak512_context keccakCtx;
    sph_keccak512_init(&keccakCtx);
    sph_keccak512(&keccakCtx, input, len);
    sph_keccak512(&keccakCtx, hash1, sizeof(hash1));
    sph_keccak512_close(&keccakCtx, (void *)&hash3);

    uint32_t hash4[16];
    sph_groestl512_context groestlCtx;
    sph_groestl512_init(&groestlCtx);
    sph_groestl512(&groestlCtx, input, len);
    sph_groestl512(&groestlCtx, hash1, sizeof(hash1));
    sph_groestl512_close(&groestlCtx, (void *)&hash4);

    uint32_t hash5[16];
    sph_blake512_context blakeCtx;
    sph_blake512_init(&blakeCtx);
    sph_blake512(&blakeCtx, input, len);
    sph_blake512(&blakeCtx, (unsigned char *)&hash1, sizeof(hash1));
    sph_blake512_close(&blakeCtx, (void *)&hash5);

    uint32_t *final = (uint32_t *)output;
    combine_hashes(final, (uint32_t *)hash2, hash3, hash4, hash5);
}

void heavy_regenhash(struct work *work)
{
    uint32_t result[8];

    unsigned int data[21], datacopy[21]; // 32-aligned
    memcpy(datacopy, work->data, 84);
    flip80(data, datacopy);
    data[20] = swab32(datacopy[20]);

    char *hdata = bin2hex(data, 84);
    applog(LOG_DEBUG, "Verifying heavy data %s", hdata);
    free(hdata);

    heavycoin_hash((const char*)data, 84, (char*)&result);
    memcpy(work->hash, &result, 32);
}

extern bool heavy_prepare_work(struct thr_info *thr, struct work *work)
{
    unsigned int src[21], dst[21]; // 32-aligned
    memcpy(src, work->data, 84);
    flip80(dst, src);
    dst[20] = swab32(src[20]);
    memcpy(work->blk.heavy_data, dst, 84);
    char *hdata = bin2hex(work->blk.heavy_data, 84);
    applog(LOG_DEBUG, "Generated heavy data %s", hdata);
    free(hdata);
    return 1;
}

