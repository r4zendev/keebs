#include QMK_KEYBOARD_H
#include "eeprom.h"

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
    KC_OSTOGG, // Toggle Linux/macOS
};

// ─── OS detection ───────────────────────────────────────────────────
// Stored in EEPROM byte 40 (arbitrary, after QMK's reserved range).
// 0 = Linux (default), 1 = macOS.
#define EEPROM_OS_ADDR 40

static bool is_macos = false;

void keyboard_post_init_user(void) {
    is_macos = eeprom_read_byte((uint8_t *)EEPROM_OS_ADDR) == 1;
}

// OS-aware modifier: Ctrl on Linux, Cmd on macOS
static uint16_t os_mod(uint16_t key) {
    return is_macos ? G(key) : C(key);
}

// OS-aware word modifier: Ctrl on Linux, Alt on macOS
static uint16_t os_word_mod(uint16_t key) {
    return is_macos ? A(key) : C(key);
}

// Layer-tap shortcuts
#define LT_FN  LT(FUNCTION, KC_ESC)
#define LT_MS  LT(MOUSE, KC_ENT)

// ─── Mod-morph via key overrides ────────────────────────────────────

// quote (') -> underscore (_) with shift
const key_override_t quote_under = ko_make_with_layers_negmods_and_options(
    MOD_MASK_SHIFT, KC_QUOT, KC_UNDS,
    1 << GRAPHITE, 0, ko_option_no_reregister_trigger);

// minus (-) -> question (?) with shift
const key_override_t hyphen_qmark = ko_make_with_layers_negmods_and_options(
    MOD_MASK_SHIFT, KC_MINS, KC_QUES,
    1 << GRAPHITE, 0, ko_option_no_reregister_trigger);

// comma (,) -> exclamation (!) with shift
const key_override_t comma_excl = ko_make_with_layers_negmods_and_options(
    MOD_MASK_SHIFT, KC_COMM, KC_EXLM,
    1 << GRAPHITE, 0, ko_option_no_reregister_trigger);

// dot (.) -> double quote (") with shift
const key_override_t dot_dqt = ko_make_with_layers_negmods_and_options(
    MOD_MASK_SHIFT, KC_DOT, KC_DQUO,
    1 << GRAPHITE, 0, ko_option_no_reregister_trigger);

// slash (/) -> backslash (\) with shift
const key_override_t fslh_bslh = ko_make_with_layers_negmods_and_options(
    MOD_MASK_SHIFT, KC_SLSH, KC_BSLS,
    1 << GRAPHITE, 0, ko_option_no_reregister_trigger);

const key_override_t *key_overrides[] = {
    &quote_under,
    &hyphen_qmark,
    &comma_excl,
    &dot_dqt,
    &fslh_bslh,
    NULL
};

// ─── Combos ─────────────────────────────────────────────────────────
// Key positions (42-key split_3x6_3):
//  0  1  2  3  4  5  |  6  7  8  9 10 11
// 12 13 14 15 16 17  | 18 19 20 21 22 23
// 24 25 26 27 28 29  | 30 31 32 33 34 35
//             36 37 38 | 39 40 41

// CapsWord: positions 17+18 (G+Y inner home row gap)
const uint16_t PROGMEM combo_caps[] = {KC_G, KC_Y, COMBO_END};
// GUI left: positions 16+17 (S+G)
const uint16_t PROGMEM combo_lgui[] = {KC_S, KC_G, COMBO_END};
// ALT left: positions 28+29 (C+V)
const uint16_t PROGMEM combo_lalt[] = {KC_C, KC_V, COMBO_END};
// GUI right: positions 18+19 (Y+H)
const uint16_t PROGMEM combo_rgui[] = {KC_Y, KC_H, COMBO_END};
// ALT right: positions 30+31 (K+P)
const uint16_t PROGMEM combo_ralt[] = {KC_K, KC_P, COMBO_END};

combo_t key_combos[] = {
    COMBO(combo_caps, CW_TOGG),
    COMBO(combo_lgui, KC_LGUI),
    COMBO(combo_lalt, KC_LALT),
    COMBO(combo_rgui, KC_LGUI),
    COMBO(combo_ralt, KC_LALT),
};

// Only trigger combos on alpha layers
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
        case KC_UNDS:
        case KC_MINS:
        case KC_BSPC:
        case KC_DEL:
        case KC_1 ... KC_0:
            return true;
        default:
            return false;
    }
}

// ─── OS-aware key sending ───────────────────────────────────────────
// Nav/editing keys that differ between Linux (Ctrl+X) and macOS (Cmd+X)
enum os_key {
    OSK_UNDO, OSK_CUT, OSK_COPY, OSK_PASTE, OSK_SALL,
    OSK_SAVE, OSK_REDO, OSK_FIND,
    OSK_WBSP, OSK_WLFT, OSK_WRGT,
    OSK_LOCK, OSK_LAST_SPACE,
    OSK_TOGG,
};

// We use a range of custom keycodes for OS-aware keys
#define OS_KEY(k) (QK_USER + 0x100 + (k))

static void tap_os_key(enum os_key key) {
    switch (key) {
        case OSK_UNDO:       tap_code16(os_mod(KC_Z));    break;
        case OSK_CUT:        tap_code16(os_mod(KC_X));    break;
        case OSK_COPY:       tap_code16(os_mod(KC_C));    break;
        case OSK_PASTE:      tap_code16(os_mod(KC_V));    break;
        case OSK_SALL:       tap_code16(os_mod(KC_A));    break;
        case OSK_SAVE:       tap_code16(os_mod(KC_S));    break;
        case OSK_REDO:       tap_code16(is_macos ? G(S(KC_Z)) : C(KC_Y)); break;
        case OSK_FIND:       tap_code16(os_mod(KC_F));    break;
        case OSK_WBSP:       tap_code16(os_word_mod(KC_BSPC)); break;
        case OSK_WLFT:       tap_code16(os_word_mod(KC_LEFT)); break;
        case OSK_WRGT:       tap_code16(os_word_mod(KC_RGHT)); break;
        case OSK_LOCK:       tap_code16(is_macos ? C(G(KC_Q)) : G(KC_L)); break;
        case OSK_LAST_SPACE: tap_code16(is_macos ? G(KC_TAB) : G(KC_TAB)); break;
        default: break;
    }
}

// ─── Macros ─────────────────────────────────────────────────────────
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (!record->event.pressed) return true;

    // Handle OS-aware keys
    if (keycode >= OS_KEY(0) && keycode <= OS_KEY(OSK_TOGG)) {
        enum os_key key = keycode - OS_KEY(0);
        if (key == OSK_TOGG) {
            is_macos = !is_macos;
            eeprom_update_byte((uint8_t *)EEPROM_OS_ADDR, is_macos ? 1 : 0);
            return false;
        }
        tap_os_key(key);
        return false;
    }

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
#define K_UNDO OS_KEY(OSK_UNDO)
#define K_CUT  OS_KEY(OSK_CUT)
#define K_COPY OS_KEY(OSK_COPY)
#define K_PSTE OS_KEY(OSK_PASTE)
#define K_SALL OS_KEY(OSK_SALL)
#define K_SAVE OS_KEY(OSK_SAVE)
#define K_REDO OS_KEY(OSK_REDO)
#define K_FIND OS_KEY(OSK_FIND)
#define K_WBSP OS_KEY(OSK_WBSP)
#define K_WLFT OS_KEY(OSK_WLFT)
#define K_WRGT OS_KEY(OSK_WRGT)
#define K_LOCK OS_KEY(OSK_LOCK)
#define K_LSPC OS_KEY(OSK_LAST_SPACE)
#define K_OSTP OS_KEY(OSK_TOGG)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

    [GRAPHITE] = LAYOUT_split_3x6_3(
        KC_F13,  KC_B,    KC_L,    KC_D,    KC_W,    KC_Z,       KC_J,    KC_F,    KC_O,    KC_U,    KC_MINS, KC_SLSH,
        KC_TAB,  KC_N,    KC_R,    KC_T,    KC_S,    KC_G,       KC_Y,    KC_H,    KC_A,    KC_E,    KC_I,    KC_DEL,
        KC_LSFT, KC_X,    KC_Q,    KC_M,    KC_C,    KC_V,       KC_K,    KC_P,    KC_QUOT, KC_COMM, KC_DOT,  KC_LCTL,
                                   MO(NAV), KC_SPC,  LT_FN,      LT_MS,  KC_BSPC, MO(SYMBOL)
    ),

    [SYMBOL] = LAYOUT_split_3x6_3(
        KC_AT,   KC_1,    KC_2,    KC_3,    KC_4,    KC_5,       KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_HASH,
        KC_TILD, KC_LPRN, KC_RPRN, KC_LCBR, KC_RCBR, KC_UNDS,   KC_EQL,  OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), OSM(MOD_LSFT), KC_CIRC,
        KC_GRV,  KC_LABK, KC_RABK, KC_LBRC, KC_RBRC, KC_AMPR,   KC_PIPE, KC_PLUS, KC_MINS, KC_ASTR, KC_SLSH, KC_DLR,
                                   KC_PERC, KC_COLN, KC_SCLN,    XXXXXXX, XXXXXXX, XXXXXXX
    ),

    [NAV] = LAYOUT_split_3x6_3(
        XXXXXXX, K_REDO,  XXXXXXX, K_FIND,  XXXXXXX, XXXXXXX,   KC_PGUP, KC_HOME, KC_UP,   KC_END,  KC_DEL,  KC_INS,
        XXXXXXX, OSM(MOD_LSFT), OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), K_SAVE, KC_PGDN, KC_LEFT, KC_DOWN, KC_RGHT, KC_BSPC, KC_ENT,
        XXXXXXX, K_UNDO,  K_CUT,   K_COPY,  K_PSTE,  K_SALL,    K_WBSP,  K_WLFT,  K_WRGT,  KC_HOME, KC_END,  K_LSPC,
                                   XXXXXXX, XXXXXXX, XXXXXXX,    XXXXXXX, XXXXXXX, XXXXXXX
    ),

    [FUNCTION] = LAYOUT_split_3x6_3(
        QK_BOOT, LANG_EN, LANG_RU, LANG_UA, TG(QWERTY), K_OSTP,  KC_VOLU, KC_F7,   KC_F8,   KC_F9,   KC_F12,  K_LOCK,
        XXXXXXX, OSM(MOD_LSFT), OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), XXXXXXX, KC_VOLD, KC_F4, KC_F5, KC_F6, KC_F11, KC_PWR,
        QK_RBT,  XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,   KC_MUTE, KC_F1,   KC_F2,   KC_F3,   KC_F10,  KC_SLEP,
                                   XXXXXXX, XXXXXXX, XXXXXXX,    KC_MPRV, KC_MPLY, KC_MNXT
    ),

    [MOUSE] = LAYOUT_split_3x6_3(
        XXXXXXX, XXXXXXX, MS_WHLL, MS_UP,   MS_WHLR, MS_WHLU,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
        XXXXXXX, XXXXXXX, MS_LEFT, MS_DOWN, MS_RGHT, MS_WHLD,   XXXXXXX, OSM(MOD_LGUI), OSM(MOD_LALT), OSM(MOD_LCTL), OSM(MOD_LSFT), XXXXXXX,
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
                                   MS_BTN1, MS_BTN3, MS_BTN2,    XXXXXXX, XXXXXXX, XXXXXXX
    ),

    [QWERTY] = LAYOUT_split_3x6_3(
        KC_F13,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,       KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSLS,
        KC_TAB,  KC_A,    KC_S,    KC_D,    KC_F,    KC_G,       KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_DEL,
        KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,       KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_LCTL,
                                   MO(NAV), KC_SPC,  LT_FN,      LT_MS,  KC_BSPC, MO(SYMBOL)
    ),
};
