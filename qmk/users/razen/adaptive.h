#pragma once

#include <stdbool.h>
#include <stdint.h>

static inline bool razen_suffix_matches(const uint16_t *history, uint8_t history_len, const uint16_t *suffix, uint8_t suffix_len) {
    if (history_len < suffix_len) {
        return false;
    }
    uint8_t start = history_len - suffix_len;
    for (uint8_t index = 0; index < suffix_len; index++) {
        if (history[start + index] != suffix[index]) {
            return false;
        }
    }
    return true;
}
