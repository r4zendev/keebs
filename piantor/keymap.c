#include QMK_KEYBOARD_H
#include "os_detection.h"

// Layers
enum layers {
    GRAPHITE,
    SYMBOL,
    NAV,
    FUNCTION,
    MOUSE,
    QWERTY,
};

// Custom keycodes
enum custom_keycodes {
    LANG_EN = SAFE_RANGE,
    LANG_RU,
    LANG_UA,
};

// ─── OS detection ───────────────────────────────────────────────────
static bool is_macos(void) {
    return detected_host_os() == OS_MACOS || detected_host_os() == OS_IOS;
}

// ─── Mod-morph via key overrides ────────────────────────────────────

const key_override_t quote_under = ko_make_with_layers_negmods_and_options(
    MOD_MASK_SHIFT, KC_QUOT, KC_UNDS,
    1 << GRAPHITE, 0, ko_option_no_reregister_trigger);

const key_override_t hyphen_qmark = ko_make_with_layers_negmods_and_options(
    MOD_MASK_SHIFT, KC_MINS, KC_QUES,
    1 << GRAPHITE, 0, ko_option_no_reregister_trigger);

const key_override_t comma_excl = ko_make_with_layers_negmods_and_options(
    MOD_MASK_SHIFT, KC_COMM, KC_EXLM,
    1 << GRAPHITE, 0, ko_option_no_reregister_trigger);

const key_override_t dot_dqt = ko_make_with_layers_negmods_and_options(
    MOD_MASK_SHIFT, KC_DOT, KC_DQUO,
    1 << GRAPHITE, 0, ko_option_no_reregister_trigger);

const key_override_t fslh_bslh = ko_make_with_layers_negmods_and_options(
    MOD_MASK_SHIFT, KC_SLSH, KC_BSLS,
    1 << GRAPHITE, 0, ko_option_no_reregister_trigger);

const key_override_t *key_overrides[] = {
    &quote_under, &hyphen_qmark, &comma_excl, &dot_dqt, &fslh_bslh, NULL
};

// ─── Combos ─────────────────────────────────────────────────────────
//  0  1  2  3  4  5  |  6  7  8  9 10 11
// 12 13 14 15 16 17  | 18 19 20 21 22 23
// 24 25 26 27 28 29  | 30 31 32 33 34 35
//             36 37 38 | 39 40 41

const uint16_t PROGMEM combo_caps[] = {KC_G, KC_Y, COMBO_END};
const uint16_t PROGMEM combo_lgui[] = {KC_TAB, KC_N, COMBO_END};
const uint16_t PROGMEM combo_lalt[] = {KC_LSFT, KC_X, COMBO_END};
const uint16_t PROGMEM combo_rgui[] = {KC_I, KC_DEL, COMBO_END};
const uint16_t PROGMEM combo_ralt[] = {KC_DOT, KC_LCTL, COMBO_END};

combo_t key_combos[] = {
    COMBO(combo_caps, CW_TOGG),
    COMBO(combo_lgui, KC_LGUI),
    COMBO(combo_lalt, KC_LALT),
    COMBO(combo_rgui, KC_LGUI),
    COMBO(combo_ralt, KC_LALT),
};

bool combo_should_trigger(uint16_t combo_index, combo_t *combo, uint16_t keycode, keyrecord_t *record) {
    uint8_t layer = get_highest_layer(layer_state);
    return layer == GRAPHITE || layer == QWERTY;
}

// ─── Caps Word ──────────────────────────────────────────────────────
bool caps_word_press_user(uint16_t keycode) {
    switch (keycode) {
        case KC_A ... KC_Z:
            add_weak_mods(MOD_BIT(KC_LSFT));
            return true;
        case KC_UNDS: case KC_MINS: case KC_BSPC: case KC_DEL:
        case KC_1 ... KC_0:
            return true;
        default:
            return false;
    }
}

// ─── OS-aware key handling ──────────────────────────────────────────
// On macOS, Ctrl shortcuts become Cmd, word-nav uses Alt instead of Ctrl.

static bool handle_os_key(uint16_t keycode, keyrecord_t *record) {
    if (!is_macos() || !record->event.pressed) return false;

    uint16_t replacement = 0;
    switch (keycode) {
        case C(KC_Z):    replacement = G(KC_Z);    break;
        case C(KC_X):    replacement = G(KC_X);    break;
        case C(KC_C):    replacement = G(KC_C);    break;
        case C(KC_V):    replacement = G(KC_V);    break;
        case C(KC_A):    replacement = G(KC_A);    break;
        case C(KC_S):    replacement = G(KC_S);    break;
        case C(KC_F):    replacement = G(KC_F);    break;
        case C(KC_Y):    replacement = G(S(KC_Z)); break;  // Redo
        case C(KC_BSPC): replacement = A(KC_BSPC); break;  // Word delete
        case C(KC_LEFT): replacement = A(KC_LEFT); break;  // Word left
        case C(KC_RGHT): replacement = A(KC_RGHT); break;  // Word right
        case G(KC_L):    replacement = C(G(KC_Q)); break;  // Lock screen
        default: return false;
    }
    tap_code16(replacement);
    return true;
}

// ─── Macros ─────────────────────────────────────────────────────────
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (handle_os_key(keycode, record)) return false;

    if (!record->event.pressed) return true;

    switch (keycode) {
        case CW_TOGG:
            if (get_mods() & MOD_MASK_SHIFT) {
                del_mods(MOD_MASK_SHIFT);
                tap_code(KC_CAPS);
                return false;
            }
            return true;
        case LANG_EN:
            layer_move(GRAPHITE);
            tap_code16(C(S(G(KC_1))));
            return false;
        case LANG_RU:
            layer_move(QWERTY);
            tap_code16(C(S(G(KC_2))));
            return false;
        case LANG_UA:
            layer_move(QWERTY);
            tap_code16(C(S(G(KC_3))));
            return false;
    }
    return true;
}

// ─── Keymap ─────────────────────────────────────────────────────────
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

    [GRAPHITE] = LAYOUT_split_3x6_3(
        KC_F13,  KC_B,    KC_L,    KC_D,    KC_W,    KC_Z,       KC_J,    KC_F,    KC_O,    KC_U,    KC_MINS, KC_SLSH,
        KC_TAB,  KC_N,    KC_R,    KC_T,    KC_S,    KC_G,       KC_Y,    KC_H,    KC_A,    KC_E,    KC_I,    KC_DEL,
        KC_LSFT, KC_X,    KC_Q,    KC_M,    KC_C,    KC_V,       KC_K,    KC_P,    KC_QUOT, KC_COMM, KC_DOT,  KC_LCTL,
                          MO(NAV), KC_SPC,  LT(FUNCTION,KC_ESC), LT(MOUSE,KC_ENT), KC_BSPC, MO(SYMBOL)
    ),

    [SYMBOL] = LAYOUT_split_3x6_3(
        KC_AT,   KC_1,    KC_2,    KC_3,    KC_4,    KC_5,       KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_HASH,
        KC_TILD, KC_LPRN, KC_RPRN, KC_LCBR, KC_RCBR, KC_UNDS,   KC_EQL,  OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), OSM(MOD_LSFT), KC_CIRC,
        KC_GRV,  KC_LABK, KC_RABK, KC_LBRC, KC_RBRC, KC_AMPR,   KC_PIPE, KC_PLUS, KC_MINS, KC_ASTR, KC_SLSH, KC_DLR,
                                   KC_PERC, KC_COLN, KC_SCLN,    XXXXXXX, XXXXXXX, XXXXXXX
    ),

    [NAV] = LAYOUT_split_3x6_3(
        XXXXXXX, C(KC_Y), XXXXXXX, C(KC_F), XXXXXXX, XXXXXXX,   KC_PGUP, KC_HOME, KC_UP,   KC_END,  KC_DEL,  KC_INS,
        XXXXXXX, OSM(MOD_LSFT), OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), C(KC_S), KC_PGDN, KC_LEFT, KC_DOWN, KC_RGHT, KC_BSPC, KC_ENT,
        XXXXXXX, C(KC_Z), C(KC_X), C(KC_C), C(KC_V), C(KC_A),   C(KC_BSPC), C(KC_LEFT), C(KC_RGHT), KC_HOME, KC_END, G(KC_TAB),
                                   XXXXXXX, XXXXXXX, XXXXXXX,    XXXXXXX, XXXXXXX, XXXXXXX
    ),

    [FUNCTION] = LAYOUT_split_3x6_3(
        QK_BOOT, LANG_EN, LANG_RU, LANG_UA, TG(QWERTY), XXXXXXX, KC_VOLU, KC_F7,   KC_F8,   KC_F9,   KC_F12,  G(KC_L),
        XXXXXXX, OSM(MOD_LSFT), OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), XXXXXXX, KC_VOLD, KC_F4, KC_F5, KC_F6, KC_F11, KC_PWR,
        QK_RBT,  XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,   KC_MUTE, KC_F1,   KC_F2,   KC_F3,   KC_F10,  KC_SLEP,
                                   XXXXXXX, XXXXXXX, XXXXXXX,    KC_MPRV, KC_MPLY, KC_MNXT
    ),

    [MOUSE] = LAYOUT_split_3x6_3(
        XXXXXXX, XXXXXXX, MS_WHLL, MS_UP,   MS_WHLR, MS_WHLU,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
        XXXXXXX, XXXXXXX, MS_LEFT, MS_DOWN, MS_RGHT, MS_WHLD,   XXXXXXX, OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), OSM(MOD_LSFT), XXXXXXX,
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, MS_BTN4, MS_BTN5,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
                                   MS_BTN1, MS_BTN3, MS_BTN2,    XXXXXXX, XXXXXXX, XXXXXXX
    ),

    [QWERTY] = LAYOUT_split_3x6_3(
        KC_F13,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,       KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSLS,
        KC_TAB,  KC_A,    KC_S,    KC_D,    KC_F,    KC_G,       KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_DEL,
        KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,       KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_LCTL,
                          MO(NAV), KC_SPC,  LT(FUNCTION,KC_ESC), LT(MOUSE,KC_ENT), KC_BSPC, MO(SYMBOL)
    ),
};
