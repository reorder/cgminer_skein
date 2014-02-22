#define ROL32(x, n)     rotate(x, (uint) n)
#define SHR(x, n)   ((x) >> n)
#define SWAP32(a)       (as_uint(as_uchar4(a).wzyx))
#define TOBE32V16(v) (uint16)(SWAP32(v.s0), SWAP32(v.s1), SWAP32(v.s2), SWAP32(v.s3), \
    SWAP32(v.s4), SWAP32(v.s5), SWAP32(v.s6), SWAP32(v.s7), \
    SWAP32(v.s8), SWAP32(v.s9), SWAP32(v.sa), SWAP32(v.sb), \
    SWAP32(v.sc), SWAP32(v.sd), SWAP32(v.se), SWAP32(v.sf))

inline uint sha256_res(uint16 data)
{
    uint temp1, W[62];
    vstore16(TOBE32V16(data), 0, W);

#define S0(x) (ROL32(x, 25) ^ ROL32(x, 14) ^  SHR(x, 3))
#define S1(x) (ROL32(x, 15) ^ ROL32(x, 13) ^  SHR(x, 10))

#define S2(x) (ROL32(x, 30) ^ ROL32(x, 19) ^ ROL32(x, 10))
#define S3(x) (ROL32(x, 26) ^ ROL32(x, 21) ^ ROL32(x, 7))

#define F0(y, x, z) bitselect(z, y, z ^ x)
#define F1(x, y, z) bitselect(z, y, x)

#define R(t)                                    \
(                                               \
    W[t] = S1(W[t -  2]) + W[t -  7] +          \
           S0(W[t - 15]) + W[t - 16]            \
)

#define RD(t)                                   \
(                                               \
    S1(W[t -  2]) + W[t -  7] +                 \
           S0(W[t - 15]) + W[t - 16]            \
)

#define P(a,b,c,d,e,f,g,h,x,K)                  \
{                                               \
    temp1 = h + S3(e) + F1(e,f,g) + K + x;      \
    d += temp1; h = temp1 + S2(a) + F0(a,b,c);  \
}
#define PS(a,b,c,d,e,f,g,h,S)                  \
{                                               \
    temp1 = h + S3(e) + F1(e,f,g) + S;      \
    d += temp1; h = temp1 + S2(a) + F0(a,b,c);              \
}

#define PSLAST(a,b,c,d,e,f,g,h,S)                  \
{                                               \
    d += h + S3(e) + F1(e,f,g) + S;              \
}

    uint8 state = (uint8)(0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A, 0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19);
    uint8 vars = state;

    P( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, W[ 0], 0x428A2F98 );
    P( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, W[ 1], 0x71374491 );
    P( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, W[ 2], 0xB5C0FBCF );
    P( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, W[ 3], 0xE9B5DBA5 );
    P( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, W[ 4], 0x3956C25B );
    P( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, W[ 5], 0x59F111F1 );
    P( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, W[ 6], 0x923F82A4 );
    P( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, W[ 7], 0xAB1C5ED5 );
    P( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, W[ 8], 0xD807AA98 );
    P( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, W[ 9], 0x12835B01 );
    P( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, W[10], 0x243185BE );
    P( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, W[11], 0x550C7DC3 );
    P( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, W[12], 0x72BE5D74 );
    P( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, W[13], 0x80DEB1FE );
    P( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, W[14], 0x9BDC06A7 );
    P( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, W[15], 0xC19BF174 );
    P( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, R(16), 0xE49B69C1 );
    P( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, R(17), 0xEFBE4786 );
    P( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, R(18), 0x0FC19DC6 );
    P( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, R(19), 0x240CA1CC );
    P( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, R(20), 0x2DE92C6F );
    P( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, R(21), 0x4A7484AA );
    P( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, R(22), 0x5CB0A9DC );
    P( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, R(23), 0x76F988DA );
    P( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, R(24), 0x983E5152 );
    P( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, R(25), 0xA831C66D );
    P( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, R(26), 0xB00327C8 );
    P( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, R(27), 0xBF597FC7 );
    P( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, R(28), 0xC6E00BF3 );
    P( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, R(29), 0xD5A79147 );
    P( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, R(30), 0x06CA6351 );
    P( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, R(31), 0x14292967 );
    P( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, R(32), 0x27B70A85 );
    P( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, R(33), 0x2E1B2138 );
    P( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, R(34), 0x4D2C6DFC );
    P( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, R(35), 0x53380D13 );
    P( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, R(36), 0x650A7354 );
    P( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, R(37), 0x766A0ABB );
    P( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, R(38), 0x81C2C92E );
    P( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, R(39), 0x92722C85 );
    P( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, R(40), 0xA2BFE8A1 );
    P( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, R(41), 0xA81A664B );
    P( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, R(42), 0xC24B8B70 );
    P( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, R(43), 0xC76C51A3 );
    P( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, R(44), 0xD192E819 );
    P( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, R(45), 0xD6990624 );
    P( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, R(46), 0xF40E3585 );
    P( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, R(47), 0x106AA070 );
    P( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, R(48), 0x19A4C116 );
    P( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, R(49), 0x1E376C08 );
    P( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, R(50), 0x2748774C );
    P( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, R(51), 0x34B0BCB5 );
    P( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, R(52), 0x391C0CB3 );
    P( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, R(53), 0x4ED8AA4A );
    P( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, R(54), 0x5B9CCA4F );
    P( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, R(55), 0x682E6FF3 );
    P( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, R(56), 0x748F82EE );
    P( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, R(57), 0x78A5636F );
    P( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, R(58), 0x84C87814 );
    P( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, R(59), 0x8CC70208 );
    P( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, R(60), 0x90BEFFFA );
    P( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, R(61), 0xA4506CEB );
    P( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, RD(62), 0xBEF9A3F7 );
    P( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, RD(63), 0xC67178F2 );

    state += vars;
    vars = state;

    PS( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, 0x80000000 + 0x428A2F98 );
    PS( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, 0 + 0x71374491 );
    PS( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, 0 + 0xB5C0FBCF );
    PS( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, 0 + 0xE9B5DBA5 );
    PS( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, 0 + 0x3956C25B );
    PS( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, 0 + 0x59F111F1 );
    PS( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, 0 + 0x923F82A4 );
    PS( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, 0 + 0xAB1C5ED5 );
    PS( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, 0 + 0xD807AA98 );
    PS( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, 0 + 0x12835B01 );
    PS( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, 0 + 0x243185BE );
    PS( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, 0 + 0x550C7DC3 );
    PS( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, 0 + 0x72BE5D74 );
    PS( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, 0 + 0x80DEB1FE );
    PS( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, 0 + 0x9BDC06A7 );
    PS( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, 512 + 0xC19BF174 );

    PS( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, 0x80000000 + 0xE49B69C1 );
    PS( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, 0x01400000 + 0xEFBE4786 );
    PS( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, 0x00205000 + 0x0FC19DC6 );
    PS( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, 0x00005088 + 0x240CA1CC );
    PS( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, 0x22000800 + 0x2DE92C6F );
    PS( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, 0x22550014 + 0x4A7484AA );
    PS( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, 0x05089742 + 0x5CB0A9DC );
    PS( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, 0xa0000020 + 0x76F988DA );
    PS( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, 0x5a880000 + 0x983E5152 );
    PS( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, 0x005c9400 + 0xA831C66D );
    PS( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, 0x0016d49d + 0xB00327C8 );
    PS( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, 0xfa801f00 + 0xBF597FC7 );
    PS( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, 0xd33225d0 + 0xC6E00BF3 );
    PS( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, 0x11675959 + 0xD5A79147 );
    PS( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, 0xf6e6bfda + 0x06CA6351 );
    PS( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, 0xb30c1549 + 0x14292967 );
    PS( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, 0x08b2b050 + 0x27B70A85 );
    PS( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, 0x9d7c4c27 + 0x2E1B2138 );
    PS( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, 0x0ce2a393 + 0x4D2C6DFC );
    PS( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, 0x88e6e1ea + 0x53380D13 );
    PS( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, 0xa52b4335 + 0x650A7354 );
    PS( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, 0x67a16f49 + 0x766A0ABB );
    PS( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, 0xd732016f + 0x81C2C92E );
    PS( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, 0x4eeb2e91 + 0x92722C85 );
    PS( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, 0x5dbf55e5 + 0xA2BFE8A1 );
    PS( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, 0x8eee2335 + 0xA81A664B );
    PS( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, 0xe2bc5ec2 + 0xC24B8B70 );
    PS( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, 0xa83f4394 + 0xC76C51A3 );
    PS( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, 0x45ad78f7 + 0xD192E819 );
    PS( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, 0x36f3d0cd + 0xD6990624 );
    PS( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, 0xd99c05e8 + 0xF40E3585 );
    PS( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, 0xb0511dc7 + 0x106AA070 );
    PS( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, 0x69bc7ac4 + 0x19A4C116 );
    PS( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, 0xbd11375b + 0x1E376C08 );
    PS( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, 0xe3ba71e5 + 0x2748774C );
    PS( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, 0x3b209ff2 + 0x34B0BCB5 );
    PS( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, 0x18feee17 + 0x391C0CB3 );
    PS( vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, 0xe25ad9e7 + 0x4ED8AA4A );
    PS( vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, 0x13375046 + 0x5B9CCA4F );
    PS( vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, 0x0515089d + 0x682E6FF3 );
    PS( vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, vars.s7, 0x4f0d0f04 + 0x748F82EE );
    PS( vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, vars.s6, 0x2627484e + 0x78A5636F );
    PS( vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, vars.s5, 0x310128d2 + 0x84C87814 );
    PS( vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, vars.s4, 0xc668b434 + 0x8CC70208 );
    PSLAST( vars.s4, vars.s5, vars.s6, vars.s7, vars.s0, vars.s1, vars.s2, vars.s3, 0x420841cc + 0x90BEFFFA );

    return vars.s7 + state.s7;
}

#define rolhackl(n) \
inline ulong rol ## n  (ulong l) \
{ \
    uint2 t = rotate(as_uint2(l), (n)); \
    return as_ulong((uint2)(bitselect(t.s0, t.s1, (uint)(1 << (n)) - 1), bitselect(t.s0, t.s1, (uint)(~((1 << (n)) - 1))))); \
}

rolhackl(8)
rolhackl(9)
rolhackl(10)
rolhackl(13)
rolhackl(14)
rolhackl(17)
rolhackl(19)
rolhackl(22)
rolhackl(24)
rolhackl(25)
rolhackl(27)
rolhackl(29)
rolhackl(30)

#define rolhackr(n) \
inline ulong rol ## n  (ulong l) \
{ \
    uint2 t = rotate(as_uint2(l), (n - 32)); \
    return as_ulong((uint2)(bitselect(t.s1, t.s0, (uint)(1 << (n - 32)) - 1), bitselect(t.s1, t.s0, (uint)(~((1 << (n - 32)) - 1))))); \
}

rolhackr(33)
rolhackr(34)
rolhackr(35)
rolhackr(36)
rolhackr(37)
rolhackr(39)
rolhackr(42)
rolhackr(43)
rolhackr(44)
rolhackr(46)
rolhackr(49)
rolhackr(50)
rolhackr(54)
rolhackr(56)

#define SKEIN_ROL_0_0(x) rol46(x)
#define SKEIN_ROL_0_1(x) rol36(x) 
#define SKEIN_ROL_0_2(x) rol19(x) 
#define SKEIN_ROL_0_3(x) rol37(x) 
#define SKEIN_ROL_1_0(x) rol33(x) 
#define SKEIN_ROL_1_1(x) rol27(x) 
#define SKEIN_ROL_1_2(x) rol14(x) 
#define SKEIN_ROL_1_3(x) rol42(x) 
#define SKEIN_ROL_2_0(x) rol17(x) 
#define SKEIN_ROL_2_1(x) rol49(x) 
#define SKEIN_ROL_2_2(x) rol36(x) 
#define SKEIN_ROL_2_3(x) rol39(x) 
#define SKEIN_ROL_3_0(x) rol44(x) 
#define SKEIN_ROL_3_1(x) rol9(x) 
#define SKEIN_ROL_3_2(x) rol54(x) 
#define SKEIN_ROL_3_3(x) rol56(x) 
#define SKEIN_ROL_4_0(x) rol39(x) 
#define SKEIN_ROL_4_1(x) rol30(x) 
#define SKEIN_ROL_4_2(x) rol34(x) 
#define SKEIN_ROL_4_3(x) rol24(x) 
#define SKEIN_ROL_5_0(x) rol13(x) 
#define SKEIN_ROL_5_1(x) rol50(x) 
#define SKEIN_ROL_5_2(x) rol10(x) 
#define SKEIN_ROL_5_3(x) rol17(x) 
#define SKEIN_ROL_6_0(x) rol25(x) 
#define SKEIN_ROL_6_1(x) rol29(x) 
#define SKEIN_ROL_6_2(x) rol39(x) 
#define SKEIN_ROL_6_3(x) rol43(x) 
#define SKEIN_ROL_7_0(x) rol8(x) 
#define SKEIN_ROL_7_1(x) rol35(x) 
#define SKEIN_ROL_7_2(x) rol56(x) 
#define SKEIN_ROL_7_3(x) rol22(x) 

#define SKEIN_KS_PARITY         0x1BD11BDAA9FC1A22UL

#define SKEIN_R512(p0,p1,p2,p3,p4,p5,p6,p7,ROTS)                      \
    X.s##p0 += X.s##p1; \
    X.s##p2 += X.s##p3; \
    X.s##p4 += X.s##p5; \
    X.s##p6 += X.s##p7; \
    X.s##p1 = SKEIN_ROL_ ## ROTS ## _0(X.s##p1) ^ X.s##p0; \
    X.s##p3 = SKEIN_ROL_ ## ROTS ## _1(X.s##p3) ^ X.s##p2; \
    X.s##p5 = SKEIN_ROL_ ## ROTS ## _2(X.s##p5) ^ X.s##p4; \
    X.s##p7 = SKEIN_ROL_ ## ROTS ## _3(X.s##p7) ^ X.s##p6;

#define SKEIN_I512(R)                                                     \
    X.s0   += ks[((R)+1) % 9];   /* inject the key schedule value */  \
    X.s1   += ks[((R)+2) % 9];                                        \
    X.s2   += ks[((R)+3) % 9];                                        \
    X.s3   += ks[((R)+4) % 9];                                        \
    X.s4   += ks[((R)+5) % 9];                                        \
    X.s5   += ks[((R)+6) % 9] + ts[((R)+1) % 3];                      \
    X.s6   += ks[((R)+7) % 9] + ts[((R)+2) % 3];                      \
    X.s7   += ks[((R)+8) % 9] +     (R)+1;                            \

#define SKEIN_R512_8_rounds(R) \
        SKEIN_R512(0,1,2,3,4,5,6,7, 0);   \
        SKEIN_R512(2,1,4,7,6,5,0,3, 1);   \
        SKEIN_R512(4,1,6,3,0,5,2,7, 2);   \
        SKEIN_R512(6,1,0,7,2,5,4,3, 3);   \
        SKEIN_I512(2*(R));                              \
        SKEIN_R512(0,1,2,3,4,5,6,7, 4);   \
        SKEIN_R512(2,1,4,7,6,5,0,3, 5);   \
        SKEIN_R512(4,1,6,3,0,5,2,7, 6);   \
        SKEIN_R512(6,1,0,7,2,5,4,3, 7);   \
        SKEIN_I512(2*(R)+1);

inline ulong8 skein512_mid_impl(ulong8 X, ulong2 msg)
{
    ulong ts[3], ks[9];

    vstore8(X, 0, ks);
    X.s01 += msg;

    ks[8] = ks[0] ^ ks[1] ^ ks[2] ^ ks[3] ^
            ks[4] ^ ks[5] ^ ks[6] ^ ks[7] ^ SKEIN_KS_PARITY;

    ts[0] = 80;
    ts[1] = 176UL << 56;
    ts[2] = 0xB000000000000050UL;

    X.s5 += 80;
    X.s6 += 176UL << 56;

    SKEIN_R512_8_rounds( 0);
    SKEIN_R512_8_rounds( 1);
    SKEIN_R512_8_rounds( 2);
    SKEIN_R512_8_rounds( 3);
    SKEIN_R512_8_rounds( 4);
    SKEIN_R512_8_rounds( 5);
    SKEIN_R512_8_rounds( 6);
    SKEIN_R512_8_rounds( 7);
    SKEIN_R512_8_rounds( 8);

    X.s01 ^= msg;
    vstore8(X, 0, ks);

    ks[8] = ks[0] ^ ks[1] ^ ks[2] ^ ks[3] ^
            ks[4] ^ ks[5] ^ ks[6] ^ ks[7] ^ SKEIN_KS_PARITY;

    ts[0] = 8UL;
    ts[1] = 255UL << 56;
    ts[2] = 0xFF00000000000008UL;

    X.s5 += 8UL;
    X.s6 += 255UL << 56;

    SKEIN_R512_8_rounds( 0);
    SKEIN_R512_8_rounds( 1);
    SKEIN_R512_8_rounds( 2);
    SKEIN_R512_8_rounds( 3);
    SKEIN_R512_8_rounds( 4);
    SKEIN_R512_8_rounds( 5);
    SKEIN_R512_8_rounds( 6);
    SKEIN_R512_8_rounds( 7);
    SKEIN_R512_8_rounds( 8);

    return X;
}

#define FOUND (0x0F)
#define SETFOUND(Xnonce) output[output[FOUND]++] = Xnonce

__kernel void search(const ulong state0, const ulong state1, const ulong state2, const ulong state3,
                     const ulong state4, const ulong state5, const ulong state6, const ulong state7,
                     const uint data16, const uint data17, const uint data18,
                     __global volatile uint* output)
{
    uint nonce = get_global_id(0);
    ulong8 state = (ulong8)(state0, state1, state2, state3, state4, state5, state6, state7);

    ulong2 msg = as_ulong2((uint4)(data16, data17, data18, SWAP32(nonce)));

    if(sha256_res(as_uint16(skein512_mid_impl(state, msg))) /*& 0xf0ffffff */  & 0xc0ffffff)
        return;
    SETFOUND(nonce);
}
