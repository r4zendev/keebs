#include "razen.h"
#include "adaptive.h"

#include "repeat_key.h"

static uint16_t history[6];
static uint8_t history_len;
static uint32_t history_timer;
static uint16_t suppressed_keycode = KC_NO;
static bool smart_mouse_active;
static uint32_t last_keypress_timer;
static uint32_t current_keypress_idle = UINT32_MAX;
static uint32_t repeat_timer;

static bool shift_active(void) {
    return (get_mods() | get_oneshot_mods() | get_weak_mods()) & MOD_MASK_SHIFT;
}

static void tap_without_shift(uint16_t keycode) {
    uint8_t mods = get_mods();
    uint8_t oneshot = get_oneshot_mods();
    uint8_t weak = get_weak_mods();
    del_mods(MOD_MASK_SHIFT);
    del_weak_mods(MOD_MASK_SHIFT);
    set_oneshot_mods(oneshot & ~MOD_MASK_SHIFT);
    tap_code16(keycode);
    set_mods(mods);
    set_weak_mods(weak);
    set_oneshot_mods(oneshot & ~MOD_MASK_SHIFT);
}

static void tap_morph(uint16_t tap, uint16_t shifted) {
    if (shift_active()) {
        tap_without_shift(shifted);
    } else {
        tap_code16(tap);
    }
}

static void clear_history(void) {
    history_len = 0;
    history_timer = 0;
}

static void append_history(uint16_t keycode) {
    if (history_len == 6) {
        memmove(history, history + 1, sizeof(history[0]) * 5);
        history_len = 5;
    }
    history[history_len++] = keycode;
    history_timer = timer_read32();
}

static void pop_history(void) {
    if (history_len) {
        history_len--;
    }
    history_timer = timer_read32();
}

static bool text_key(uint16_t keycode) {
    if (keycode >= KC_A && keycode <= KC_Z) {
        return true;
    }
    switch (keycode) {
        case KC_SPC:
        case KC_COMM:
        case KC_DOT:
        case KC_SCLN:
        case KC_QUOT:
        case KC_MINS:
        case KC_EQL:
        case KC_SLSH:
        case KC_BSLS:
        case KC_LBRC:
        case KC_RBRC:
        case KC_GRV:
            return true;
    }
    return false;
}

static uint16_t tap_keycode(uint16_t keycode, keyrecord_t *record) {
    if (IS_QK_MOD_TAP(keycode) || IS_QK_LAYER_TAP(keycode)) {
        return record->tap.count ? get_tap_keycode(keycode) : KC_NO;
    }
    return keycode;
}

static bool history_matches(const razen_adaptive_rule_t *rule) {
    return razen_suffix_matches(history, history_len, rule->after, rule->after_len);
}

static bool process_adaptive(uint16_t keycode, keyrecord_t *record) {
    if (!record->event.pressed) {
        if (suppressed_keycode == keycode) {
            suppressed_keycode = KC_NO;
            return false;
        }
        return true;
    }

    uint16_t basic = tap_keycode(keycode, record);
    if (basic == KC_NO) {
        return true;
    }
    if (basic == KC_BSPC) {
        pop_history();
        return true;
    }

    uint8_t mods = get_mods() | get_oneshot_mods() | get_weak_mods();
    uint8_t layer = get_highest_layer(layer_state | default_layer_state);
    for (uint8_t index = 0; index < razen_adaptive_rule_count; index++) {
        const razen_adaptive_rule_t *rule = &razen_adaptive_rules[index];
        if (rule->layer != layer || rule->input != basic || !history_timer || timer_elapsed32(history_timer) > rule->timeout_ms || (rule->strict_modifiers && mods) || !history_matches(rule)) {
            continue;
        }
        suppressed_keycode = keycode;
        for (uint8_t output = 0; output < rule->emit_len; output++) {
            tap_code16(rule->emit[output]);
            append_history(rule->emit[output]);
        }
        if (rule->emit_len) {
            set_last_keycode(rule->emit[rule->emit_len - 1]);
            set_last_mods(0);
        }
        return false;
    }

    if (text_key(basic) && !mods) {
        append_history(basic);
    } else {
        clear_history();
    }
    return true;
}

static void repeat_magic(void) {
    if (shift_active()) {
        caps_word_on();
        return;
    }
    if (get_last_keycode() == KC_NO || !repeat_timer || timer_elapsed32(repeat_timer) > RAZEN_MAGIC_REPEAT_TIMEOUT) {
        add_oneshot_mods(MOD_BIT(razen_magic_hold_keycode));
        return;
    }
    keyevent_t event = MAKE_KEYEVENT(0, 0, true);
    repeat_key_invoke(&event);
    event.pressed = false;
    repeat_key_invoke(&event);
    repeat_timer = timer_read32();
}

static void smart_mouse_toggle(void) {
    smart_mouse_active = !smart_mouse_active;
    if (smart_mouse_active) {
        layer_on(L_MOUSE);
    } else {
        layer_off(L_MOUSE);
    }
}

static bool mouse_key(uint16_t keycode) {
    switch (keycode) {
        case MS_UP:
        case MS_DOWN:
        case MS_LEFT:
        case MS_RGHT:
        case MS_WHLU:
        case MS_WHLD:
        case MS_WHLL:
        case MS_WHLR:
        case MS_BTN1:
        case MS_BTN2:
        case MS_BTN3:
        case MS_BTN4:
        case MS_BTN5:
        case KC_PGUP:
        case KC_PGDN:
        case KC_LGUI:
        case KC_LALT:
        case KC_LCTL:
        case KC_LSFT:
            return true;
    }
    if (IS_QK_TAP_DANCE(keycode)) {
        razen_tap_dance_t *data = &razen_tap_dance_data[QK_TAP_DANCE_GET_INDEX(keycode)];
        return data->tap_kind == RAZEN_TAP_MOUSE_TOGGLE;
    }
    return false;
}

static void execute_tap(razen_tap_dance_t *data) {
    switch (data->tap_kind) {
        case RAZEN_TAP_KEY:
            tap_code16(data->tap);
            break;
        case RAZEN_TAP_MAGIC:
            repeat_magic();
            break;
        case RAZEN_TAP_MOUSE_TOGGLE:
            smart_mouse_toggle();
            break;
        case RAZEN_TAP_ONESHOT_LAYER:
            set_oneshot_layer(data->tap, ONESHOT_START);
            break;
    }
}

static void execute_hold(razen_tap_dance_t *data) {
    if (data->hold_kind == RAZEN_HOLD_KEY) {
        register_code16(data->hold);
    } else {
        layer_on(data->hold);
    }
    data->held = true;
}

static void release_hold(razen_tap_dance_t *data) {
    if (!data->held) {
        return;
    }
    if (data->hold_kind == RAZEN_HOLD_KEY) {
        unregister_code16(data->hold);
    } else {
        layer_off(data->hold);
    }
    data->held = false;
}

void razen_tap_dance_finished(tap_dance_state_t *state, void *user_data) {
    razen_tap_dance_t *data = user_data;
    if (!state->pressed) {
        return;
    }
    if (state->count == 1 && (!state->interrupted || data->hold_on_interrupt)) {
        execute_hold(data);
    } else {
        execute_tap(data);
    }
}

void razen_tap_dance_reset(tap_dance_state_t *state, void *user_data) {
    (void)state;
    release_hold(user_data);
}

static void process_tap_dance_release(uint16_t keycode, keyrecord_t *record) {
    if (!record->event.pressed && IS_QK_TAP_DANCE(keycode)) {
        tap_dance_action_t *action = &tap_dance_actions[QK_TAP_DANCE_GET_INDEX(keycode)];
        if (action->state.count && !action->state.finished) {
            execute_tap(action->user_data);
        }
    }
}

static bool custom_keycode(uint16_t keycode) {
    if (keycode == razen_smart_mouse_keycode) {
        return true;
    }
    for (uint8_t index = 0; index < razen_morph_count; index++) {
        if (razen_morphs[index].trigger == keycode) {
            return true;
        }
    }
    for (uint8_t index = 0; index < razen_macro_count; index++) {
        if (razen_macros[index].trigger == keycode) {
            return true;
        }
    }
    return false;
}

bool pre_process_record_user(uint16_t keycode, keyrecord_t *record) {
    (void)keycode;
    if (record->event.pressed) {
        current_keypress_idle = last_keypress_timer ? timer_elapsed32(last_keypress_timer) : UINT32_MAX;
        last_keypress_timer = timer_read32();
    }
    return true;
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    process_tap_dance_release(keycode, record);

    if (!record->event.pressed) {
        return process_adaptive(keycode, record);
    }

    if (smart_mouse_active && keycode != razen_smart_mouse_keycode && !mouse_key(keycode)) {
        smart_mouse_active = false;
        layer_off(L_MOUSE);
    }

    if (keycode == razen_smart_mouse_keycode) {
        smart_mouse_toggle();
        clear_history();
        return false;
    }

    for (uint8_t index = 0; index < razen_morph_count; index++) {
        if (razen_morphs[index].trigger != keycode) {
            continue;
        }
        uint16_t output = shift_active() ? razen_morphs[index].shifted : razen_morphs[index].tap;
        tap_morph(razen_morphs[index].tap, razen_morphs[index].shifted);
        if (output == KC_BSPC) {
            pop_history();
        } else if (text_key(output)) {
            append_history(output);
        } else {
            clear_history();
        }
        return false;
    }

    for (uint8_t index = 0; index < razen_macro_count; index++) {
        if (razen_macros[index].trigger != keycode) {
            continue;
        }
        layer_move(razen_macros[index].layer);
        tap_code16(razen_macros[index].keycode);
        clear_history();
        return false;
    }

    return process_adaptive(keycode, record);
}

bool remember_last_key_user(uint16_t keycode, keyrecord_t *record, uint8_t *remembered_mods) {
    (void)remembered_mods;
    bool remember = !IS_QK_TAP_DANCE(keycode) && !custom_keycode(keycode);
    if (remember && record->event.pressed) {
        repeat_timer = timer_read32();
    }
    return remember;
}

static bool home_row_key(uint16_t keycode) {
    for (uint8_t index = 0; index < razen_home_row_key_count; index++) {
        if (razen_home_row_keys[index] == keycode) {
            return true;
        }
    }
    return false;
}

uint16_t get_tapping_term(uint16_t keycode, keyrecord_t *record) {
    (void)record;
    if (IS_QK_TAP_DANCE(keycode)) {
        return razen_tap_dance_data[QK_TAP_DANCE_GET_INDEX(keycode)].term_ms;
    }
    return home_row_key(keycode) ? RAZEN_HOME_ROW_TAPPING_TERM : TAPPING_TERM;
}

uint16_t get_quick_tap_term(uint16_t keycode, keyrecord_t *record) {
    (void)record;
    return home_row_key(keycode) ? RAZEN_HOME_ROW_QUICK_TAP_TERM : QUICK_TAP_TERM;
}

bool get_permissive_hold(uint16_t keycode, keyrecord_t *record) {
    (void)record;
    return home_row_key(keycode);
}

uint16_t get_flow_tap_term(uint16_t keycode, keyrecord_t *record, uint16_t previous_keycode) {
    (void)record;
    uint16_t previous = get_tap_keycode(previous_keycode);
    if (!home_row_key(keycode) || previous < KC_A || previous > KC_Z || get_mods() || get_oneshot_mods() || get_weak_mods()) {
        return 0;
    }
    return FLOW_TAP_TERM;
}

uint16_t get_combo_term(uint16_t combo_index, combo_t *combo) {
    (void)combo;
    return combo_index < razen_combo_count ? razen_combos[combo_index].term_ms : COMBO_TERM;
}

bool combo_should_trigger(uint16_t combo_index, combo_t *combo, uint16_t keycode, keyrecord_t *record) {
    (void)keycode;
    if (combo_index >= razen_combo_count) {
        return true;
    }
    const razen_combo_t *meta = &razen_combos[combo_index];
    uint8_t layer = get_highest_layer(layer_state | default_layer_state);
    bool idle = !record->event.pressed || combo->state || current_keypress_idle >= meta->idle_ms;
    return idle && (meta->layers & (1UL << layer));
}

#ifdef ENCODER_ENABLE
bool encoder_update_user(uint8_t index, bool clockwise) {
    (void)index;
    tap_code(clockwise ? KC_VOLU : KC_VOLD);
    return false;
}
#endif

#ifdef OLED_ENABLE
oled_rotation_t oled_init_user(oled_rotation_t rotation) {
    return rotation;
}

bool oled_task_user(void) {
    static const char *const names[] = {"Graphite", "Vestnik", "Symbol", "Nav", "Num", "VestnikX", "Mouse", "System"};
    uint8_t layer = get_highest_layer(layer_state | default_layer_state);
    oled_write_ln(layer < 8 ? names[layer] : "", false);
    return false;
}
#endif
