#include QMK_KEYBOARD_H

enum layers {
    L_GRAPHITE,
    L_RACKET,
    L_STURDY,
    L_VESTNIK,
    L_SYMBOL,
    L_NAV,
    L_NUM,
    L_NUM_MIRROR,
    L_FN,
    L_MOUSE,
    L_SYSTEM,
    L_COMBO_REF,
};

enum custom_keycodes {
    COM_EX = SAFE_RANGE,
    DOT_Q,
    MNS_SLSH,
    SQT_DQT,
    UNDO_REDO,
    PASTE_M,
    COPY_CUT,
    ESC_TAB,
    BSPC_DEL,
    NUM_REPEAT,
    MOUSE_T,
    MAGIC,
    RACKET_MAGIC,
    STURDY_MAGIC,
    STURDY_REPEAT,
    LANG_EN,
    LANG_RU,
    V_COM_EX,
    V_DOT_Q,
    P_LT4,
    P_LT3,
    P_LT2,
    P_LT1,
    P_LT0,
    P_RT0,
    P_RT1,
    P_RT2,
    P_RT3,
    P_RT4,
    P_LM4,
    P_LM3,
    P_LM2,
    P_LM1,
    P_LM0,
    P_RM0,
    P_RM1,
    P_RM2,
    P_RM3,
    P_RM4,
    P_LB4,
    P_LB3,
    P_LB2,
    P_LB1,
    P_LB0,
    P_RB0,
    P_RB1,
    P_RB2,
    P_RB3,
    P_RB4,
    P_LH2,
    P_LH1,
    P_RH1,
    P_RH2,
};

#define OS_LINUX 1
#define OS_MACOS 2
#define OS_WINDOWS 3

#ifndef OPERATING_SYSTEM
#    define OPERATING_SYSTEM OS_LINUX
#endif

#if OPERATING_SYSTEM == OS_MACOS
#    define KC_HOME_OS G(KC_LEFT)
#    define KC_END_OS G(KC_RIGHT)
#    define KC_LOCK_OS G(C(KC_Q))
#    define KC_SHUT_OS KC_PWR
#    define KC_PASTE_OS G(KC_V)
#    define KC_SCR_FULL_OS G(S(KC_3))
#    define KC_SCR_AREA_OS G(S(KC_4))
#elif OPERATING_SYSTEM == OS_WINDOWS
#    define KC_HOME_OS KC_HOME
#    define KC_END_OS KC_END
#    define KC_LOCK_OS G(KC_L)
#    define KC_SHUT_OS KC_PWR
#    define KC_PASTE_OS C(KC_V)
#    define KC_SCR_FULL_OS G(S(KC_S))
#    define KC_SCR_AREA_OS G(S(KC_S))
#else
#    define KC_HOME_OS KC_HOME
#    define KC_END_OS KC_END
#    define KC_LOCK_OS G(S(KC_L))
#    define KC_SHUT_OS G(C(S(KC_Q)))
#    define KC_PASTE_OS C(S(KC_V))
#    define KC_SCR_FULL_OS G(S(KC_P))
#    define KC_SCR_AREA_OS G(S(KC_S))
#endif

#define HMLG(kc) LGUI_T(kc)
#define HMLA(kc) LALT_T(kc)
#define HMLC(kc) LCTL_T(kc)
#define HMLS(kc) LSFT_T(kc)
#define HMRS(kc) RSFT_T(kc)
#define HMRC(kc) RCTL_T(kc)
#define HMRA(kc) RALT_T(kc)
#define HMRG(kc) RGUI_T(kc)

#define NAV_ESC LT(L_NAV, KC_ESC)
#define NAV_BSPC_DEL LT(L_NAV, KC_BSPC)
#define NUM_0 LT(L_NUM, KC_0)

#ifdef RGB_MATRIX_ENABLE
#    undef RGB_TOG
#    undef RGB_VAD
#    undef RGB_VAI
#    define RGB_TOG RM_TOGG
#    define RGB_VAD RM_VALD
#    define RGB_VAI RM_VALU
#endif

#define RAZEN_LAYOUT( \
    LT4, LT3, LT2, LT1, LT0, RT0, RT1, RT2, RT3, RT4, \
    LM4, LM3, LM2, LM1, LM0, RM0, RM1, RM2, RM3, RM4, \
    LB4, LB3, LB2, LB1, LB0, RB0, RB1, RB2, RB3, RB4, \
    LH2, LH1, RH1, RH2 \
) \
    LAYOUT_split_3x5_2( \
        LT4, LT3, LT2, LT1, LT0,       RT0, RT1, RT2, RT3, RT4, \
        LM4, LM3, LM2, LM1, LM0,       RM0, RM1, RM2, RM3, RM4, \
        LB4, LB3, LB2, LB1, LB0,       RB0, RB1, RB2, RB3, RB4, \
                            LH2, LH1,  RH1, RH2 \
    )

#define RAZEN_COMBO_REF_LAYER L_COMBO_REF

const char chordal_hold_layout[MATRIX_ROWS][MATRIX_COLS] PROGMEM = RAZEN_LAYOUT(
    'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R',
    'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R',
    'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R',
    '*', '*', '*', '*'
);

static bool shift_active(void);
static void tap_without_shift(uint16_t keycode);
static void tap_morph(uint16_t normal, uint16_t shifted);
static bool process_tap_hold_morph(keyrecord_t *record, uint16_t normal, uint16_t shifted);
static void handle_caps_combo(void);

static uint16_t last_basic_keycode = KC_NO;
static uint32_t last_basic_key_timer = 0;
static bool num_repeat_active = false;
static bool num_repeat_interrupted = false;
static uint32_t num_repeat_timer = 0;
static bool mouse_t_active = false;
static bool mouse_t_interrupted = false;
static bool mouse_t_was_on = false;
static uint32_t mouse_t_timer = 0;
static uint16_t active_tap_hold_morph_keycode = KC_NO;

#include "generated_keymap.inc"

uint8_t combo_ref_from_layer(uint8_t layer) {
    return RAZEN_COMBO_REF_LAYER;
}

static bool shift_active(void) {
    return (get_mods() | get_oneshot_mods() | get_weak_mods()) & MOD_MASK_SHIFT;
}

static void tap_without_shift(uint16_t keycode) {
    const uint8_t mods = get_mods();
    const uint8_t oneshot = get_oneshot_mods();
    del_mods(MOD_MASK_SHIFT);
    clear_oneshot_mods();
    tap_code16(keycode);
    set_mods(mods);
    set_oneshot_mods(oneshot & ~MOD_MASK_SHIFT);
}

static void tap_morph(uint16_t normal, uint16_t shifted) {
    if (shift_active()) {
        tap_without_shift(shifted);
    } else {
        tap_code16(normal);
    }
}

static bool process_tap_hold_morph(keyrecord_t *record, uint16_t normal, uint16_t shifted) {
    if (record->event.pressed) {
        if (record->tap.count > 1 && !shift_active()) {
            active_tap_hold_morph_keycode = normal;
            register_code16(normal);
        } else {
            tap_morph(normal, shifted);
        }
    } else if (active_tap_hold_morph_keycode != KC_NO) {
        unregister_code16(active_tap_hold_morph_keycode);
        active_tap_hold_morph_keycode = KC_NO;
    }
    return false;
}

static void handle_caps_combo(void) {
    if (shift_active()) {
        tap_without_shift(KC_CAPS);
    } else {
        caps_word_on();
    }
}

static void tap_repeat_key(keyrecord_t *record) {
    keyevent_t event = record->event;
    event.pressed = true;
    repeat_key_invoke(&event);
    event.pressed = false;
    repeat_key_invoke(&event);
}

static bool process_num_repeat(uint16_t keycode, keyrecord_t *record) {
    if (keycode == NUM_REPEAT) {
        if (record->event.pressed) {
            num_repeat_active = true;
            num_repeat_interrupted = false;
            num_repeat_timer = timer_read32();
            layer_on(L_NUM);
        } else {
            layer_off(L_NUM);
            const bool should_repeat = !num_repeat_interrupted && timer_elapsed32(num_repeat_timer) < TAPPING_TERM;
            num_repeat_active = false;
            if (should_repeat) {
                tap_repeat_key(record);
            }
        }
        return false;
    }

    if (num_repeat_active && record->event.pressed) {
        num_repeat_interrupted = true;
    }
    return true;
}

static bool process_mouse_t(uint16_t keycode, keyrecord_t *record) {
    if (keycode == MOUSE_T) {
        if (record->event.pressed) {
            mouse_t_active = true;
            mouse_t_interrupted = false;
            mouse_t_was_on = layer_state_is(L_MOUSE);
            mouse_t_timer = timer_read32();
            layer_on(L_MOUSE);
        } else {
            const bool should_toggle = !mouse_t_interrupted && timer_elapsed32(mouse_t_timer) < 200;
            mouse_t_active = false;
            if (should_toggle) {
                if (mouse_t_was_on) {
                    layer_off(L_MOUSE);
                } else {
                    layer_on(L_MOUSE);
                }
            } else if (!mouse_t_was_on) {
                layer_off(L_MOUSE);
            }
        }
        return false;
    }

    if (mouse_t_active && record->event.pressed) {
        mouse_t_interrupted = true;
    }
    return true;
}

static void send_repeat_or_shift(void) {
    if (shift_active()) {
        caps_word_on();
    } else if (last_basic_keycode != KC_NO) {
        tap_code16(last_basic_keycode);
    } else {
        set_oneshot_mods(get_oneshot_mods() | MOD_BIT(KC_LSFT));
    }
}

static void send_sturdy_magic(void) {
    switch (last_basic_keycode) {
        case KC_A: tap_code(KC_O); break;
        case KC_B: SEND_STRING("efore"); break;
        case KC_C: tap_code(KC_Y); break;
        case KC_D: tap_code(KC_Y); break;
        case KC_E: tap_code(KC_U); break;
        case KC_G: tap_code(KC_Y); break;
        case KC_H: SEND_STRING("oa"); break;
        case KC_I: SEND_STRING("on"); break;
        case KC_J: SEND_STRING("ust"); break;
        case KC_K: tap_code(KC_S); break;
        case KC_L: tap_code(KC_K); break;
        case KC_M: SEND_STRING("ent"); break;
        case KC_N: SEND_STRING("ion"); break;
        case KC_O: tap_code(KC_A); break;
        case KC_P: tap_code(KC_Y); break;
        case KC_Q: SEND_STRING("uen"); break;
        case KC_R: tap_code(KC_L); break;
        case KC_S: tap_code(KC_K); break;
        case KC_T: SEND_STRING("ment"); break;
        case KC_U: tap_code(KC_E); break;
        case KC_V: SEND_STRING("er"); break;
        case KC_W: SEND_STRING("hich"); break;
        case KC_X: SEND_STRING("es"); break;
        case KC_Y: tap_code(KC_P); break;
        case KC_Z: tap_code(KC_Y); break;
        case KC_SPC: SEND_STRING("the"); break;
        default: send_repeat_or_shift(); break;
    }
}

static void send_sturdy_repeat(void) {
    switch (last_basic_keycode) {
        case KC_A: SEND_STRING("nd"); break;
        case KC_I: SEND_STRING("ng"); break;
        case KC_Y: SEND_STRING("ou"); break;
        case KC_N: tap_code(KC_F); break;
        case KC_B: SEND_STRING("ecause"); break;
        case KC_W: SEND_STRING("ould"); break;
        case KC_COMM: SEND_STRING(" and"); break;
        case KC_DOT: SEND_STRING("org"); break;
        case KC_SPC: SEND_STRING("for"); break;
        default: send_repeat_or_shift(); break;
    }
}

static void send_racket_magic(void) {
    switch (last_basic_keycode) {
        case KC_F: tap_code(KC_T); break;
        case KC_S: tap_code(KC_K); break;
        case KC_K: tap_code(KC_S); break;
        case KC_L: tap_code(KC_K); break;
        case KC_U: tap_code(KC_E); break;
        case KC_E: tap_code(KC_U); break;
        case KC_O: tap_code(KC_A); break;
        case KC_C: tap_code(KC_Y); break;
        case KC_Y: tap_code(KC_W); break;
        case KC_G: tap_code(KC_Y); break;
        case KC_H: tap_code(KC_M); break;
        default: send_repeat_or_shift(); break;
    }
}

static void remember_basic_key(uint16_t keycode, keyrecord_t *record) {
    if (!record->event.pressed) {
        return;
    }
    if (IS_QK_MODS(keycode) || get_mods() || get_oneshot_mods() || get_weak_mods()) {
        last_basic_keycode = KC_NO;
        return;
    }

    const uint16_t basic = keycode & 0xFF;
    if ((basic >= KC_A && basic <= KC_Z) || basic == KC_SPC || basic == KC_COMM || basic == KC_DOT) {
        last_basic_keycode = basic;
        last_basic_key_timer = timer_read32();
    }
}

bool remember_last_key_user(uint16_t keycode, keyrecord_t *record, uint8_t *remembered_mods) {
    (void)record;
    (void)remembered_mods;

    switch (keycode) {
        case NUM_REPEAT:
        case MAGIC:
        case RACKET_MAGIC:
        case STURDY_MAGIC:
        case STURDY_REPEAT:
            return false;
    }
    return true;
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (!process_generated_adaptive_key(keycode, record)) {
        return false;
    }

    if (!process_num_repeat(keycode, record)) {
        return false;
    }

    if (!process_mouse_t(keycode, record)) {
        return false;
    }

    switch (keycode) {
        case NAV_BSPC_DEL:
            if (record->tap.count) {
                return process_tap_hold_morph(record, KC_BSPC, KC_DEL);
            }
            return true;
    }

    if (!record->event.pressed) {
        return true;
    }

    switch (keycode) {
        case COM_EX: tap_morph(KC_COMM, S(KC_1)); return false;
        case DOT_Q: tap_morph(KC_DOT, S(KC_SLSH)); return false;
        case MNS_SLSH: tap_morph(KC_MINS, KC_SLSH); return false;
        case SQT_DQT: tap_morph(KC_QUOT, S(KC_QUOT)); return false;
        case UNDO_REDO: tap_morph(C(KC_Z), C(S(KC_Z))); return false;
        case PASTE_M: tap_morph(KC_PASTE_OS, C(KC_V)); return false;
        case COPY_CUT: tap_morph(C(KC_C), C(KC_X)); return false;
        case ESC_TAB: tap_morph(KC_ESC, KC_TAB); return false;
        case BSPC_DEL: tap_morph(KC_BSPC, KC_DEL); return false;
        case MAGIC: send_repeat_or_shift(); return false;
        case RACKET_MAGIC: send_racket_magic(); return false;
        case STURDY_MAGIC: send_sturdy_magic(); return false;
        case STURDY_REPEAT: send_sturdy_repeat(); return false;
        case LANG_EN:
            layer_move(L_GRAPHITE);
            tap_code16(C(S(G(KC_1))));
            return false;
        case LANG_RU:
            layer_move(L_VESTNIK);
            tap_code16(C(S(G(KC_2))));
            return false;
        case V_COM_EX: tap_morph(S(KC_SLSH), S(KC_1)); return false;
        case V_DOT_Q: tap_morph(KC_SLSH, S(KC_7)); return false;
    }

    remember_basic_key(keycode, record);
    return true;
}

void process_combo_event(uint16_t combo_index, bool pressed) {
    process_generated_combo_event(combo_index, pressed);
}

bool combo_should_trigger(uint16_t combo_index, combo_t *combo, uint16_t keycode, keyrecord_t *record) {
    (void)keycode;
    return generated_combo_should_trigger(combo_index, combo, record);
}

#ifdef ENCODER_ENABLE
bool encoder_update_user(uint8_t index, bool clockwise) {
    if (index == 0) {
        tap_code(clockwise ? KC_VOLU : KC_VOLD);
    } else {
        tap_code(clockwise ? KC_WH_D : KC_WH_U);
    }
    return false;
}
#endif

#ifdef OLED_ENABLE
oled_rotation_t oled_init_user(oled_rotation_t rotation) {
    return rotation;
}

static void render_oled_mods(void) {
    uint8_t mods = get_mods() | get_oneshot_mods();
    oled_write_ln_P((mods & MOD_MASK_SHIFT) ? PSTR("Shft") : PSTR(" "), false);
    oled_write_ln_P((mods & MOD_MASK_CTRL) ? PSTR("Ctrl") : PSTR(" "), false);
    oled_write_ln_P((mods & MOD_MASK_ALT) ? PSTR("Alt") : PSTR(" "), false);
    oled_write_ln_P((mods & MOD_MASK_GUI) ? PSTR("Win") : PSTR(" "), false);
}

static void render_oled_caps(void) {
    led_t leds = host_keyboard_led_state();
    oled_write_ln_P(leds.caps_lock ? PSTR("Caps Lock") : PSTR(" "), false);
}

static void render_oled_layer(void) {
    switch (get_highest_layer(layer_state)) {
        case L_RACKET: oled_write_ln_P(PSTR("Racket"), false); break;
        case L_STURDY: oled_write_ln_P(PSTR("Sturdy"), false); break;
        case L_VESTNIK: oled_write_ln_P(PSTR("Vestnik"), false); break;
        case L_SYMBOL: oled_write_ln_P(PSTR("Symbol"), false); break;
        case L_NAV: oled_write_ln_P(PSTR("Nav"), false); break;
        case L_NUM: oled_write_ln_P(PSTR("Num"), false); break;
        case L_NUM_MIRROR: oled_write_ln_P(PSTR("NumMir"), false); break;
        case L_FN: oled_write_ln_P(PSTR("Fn"), false); break;
        case L_MOUSE: oled_write_ln_P(PSTR("Mouse"), false); break;
        case L_SYSTEM: oled_write_ln_P(PSTR("System"), false); break;
        default: oled_write_ln_P(PSTR("Alpha"), false); break;
    }
}

static void render_oled_status(void) {
    oled_write_ln_P(PSTR("aurora\n"), false);
    render_oled_mods();
    render_oled_caps();
    render_oled_layer();
}

bool oled_task_user(void) {
    if (is_keyboard_left()) {
        render_oled_status();
    }
    return false;
}
#endif
