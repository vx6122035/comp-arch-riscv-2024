#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

typedef uint16_t fp16_t;

static inline float bits_to_fp32(uint32_t w)
{
    union {
        uint32_t as_bits;
        float as_value;
    } fp32 = {.as_bits = w};
    return fp32.as_value;
}

static inline uint32_t fp32_to_bits(float f)
{
    union {
        float as_value;
        uint32_t as_bits;
    } fp32 = {.as_value = f};
    return fp32.as_bits;
}

static inline float fp16_to_fp32(fp16_t h)
{
    const uint32_t w = (uint32_t) h << 16;
    const uint32_t sign = w & UINT32_C(0x80000000);
    const uint32_t two_w = w + w;

    const uint32_t exp_offset = UINT32_C(0xE0) << 23;
    const float exp_scale = 0x1.0p-112f;
    const float normalized_value =
        bits_to_fp32((two_w >> 4) + exp_offset) * exp_scale;

    const uint32_t mask = UINT32_C(126) << 23;
    const float magic_bias = 0.5f;
    const float denormalized_value =
        bits_to_fp32((two_w >> 17) | mask) - magic_bias;

    const uint32_t denormalized_cutoff = UINT32_C(1) << 27;
    const uint32_t result =
        sign | (two_w < denormalized_cutoff ? fp32_to_bits(denormalized_value)
                                            : fp32_to_bits(normalized_value));
    return bits_to_fp32(result);
}

int main()
{
    // Test data: array of 16-bit FP16 bit patterns
    fp16_t bit_patterns[] = {
        0x3C00, // 1.0
        0xBC00, // -1.0
        0x0000, // 0.0
        0x8000, // -0.0
        0x7C00, // Infinity
        0xFC00, // -Infinity
        0x3555, // Approximately 0.33325
        0xC000, // -2.0
        0x7BFF, // Max normal positive number
        0x0400, // Smallest positive normal number
        0x03FF, // Largest subnormal number
        0x0001, // Smallest positive subnormal number
    };

    int array_length = sizeof(bit_patterns) / sizeof(bit_patterns[0]);

    // Process each bit pattern
    for (int i = 0; i < array_length; i++)
    {
        fp16_t h = bit_patterns[i];
        float fp32_value = fp16_to_fp32(h);
        uint32_t fp32_bits = fp32_to_bits(fp32_value);

        // Print the input FP16 bit pattern and the resulting FP32 value and bit pattern
        printf("Input FP16 bit pattern: 0x%04X\n", h);
        printf("Output FP32 value: %f\n", fp32_value);
        printf("Output FP32 bit pattern: 0x%08X\n", fp32_bits);
        printf("-----------------------------\n");
    }

    return 0;
}
