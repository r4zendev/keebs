#pragma once

#include QMK_KEYBOARD_H

enum razen_layers {
    L_GRAPHITE,
    L_VESTNIK,
    L_SYMBOL,
    L_NAV,
    L_NUM,
    L_VESTNIK_X,
    L_MOUSE,
    L_SYSTEM,
    L_COMBO_REF,
};

enum razen_tap_kind {
    RAZEN_TAP_KEY,
    RAZEN_TAP_MAGIC,
    RAZEN_TAP_MOUSE_TOGGLE,
    RAZEN_TAP_ONESHOT_LAYER,
};

enum razen_hold_kind {
    RAZEN_HOLD_KEY,
    RAZEN_HOLD_LAYER,
};

typedef struct {
    uint16_t trigger;
    uint16_t tap;
    uint16_t shifted;
} razen_morph_t;

typedef struct {
    uint16_t trigger;
    uint8_t layer;
    uint16_t keycode;
} razen_macro_t;

typedef struct {
    uint8_t layer;
    uint16_t input;
    uint16_t after[6];
    uint8_t after_len;
    uint16_t emit[6];
    uint8_t emit_len;
    uint16_t timeout_ms;
    bool strict_modifiers;
} razen_adaptive_rule_t;

typedef struct {
    uint32_t layers;
    uint16_t term_ms;
    uint16_t idle_ms;
} razen_combo_t;

typedef struct {
    uint8_t tap_kind;
    uint16_t tap;
    uint8_t hold_kind;
    uint16_t hold;
    uint16_t term_ms;
    bool hold_on_interrupt;
    bool held;
} razen_tap_dance_t;

extern const razen_morph_t razen_morphs[];
extern const uint8_t razen_morph_count;
extern const razen_macro_t razen_macros[];
extern const uint8_t razen_macro_count;
extern const razen_adaptive_rule_t razen_adaptive_rules[];
extern const uint8_t razen_adaptive_rule_count;
extern const razen_combo_t razen_combos[];
extern const uint8_t razen_combo_count;
extern const uint16_t razen_smart_mouse_keycode;
extern const uint16_t razen_magic_hold_keycode;
extern razen_tap_dance_t razen_tap_dance_data[];
extern tap_dance_action_t tap_dance_actions[];
extern const uint16_t razen_home_row_keys[];
extern const uint8_t razen_home_row_key_count;

void razen_tap_dance_finished(tap_dance_state_t *state, void *user_data);
void razen_tap_dance_reset(tap_dance_state_t *state, void *user_data);

#define RAZEN_TAP_DANCE(data) { .fn = {NULL, razen_tap_dance_finished, razen_tap_dance_reset, NULL}, .user_data = (void *)(data) }
