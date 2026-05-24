#pragma once

#define TAPPING_TERM 175
#define TAPPING_TERM_PER_KEY
#define QUICK_TAP_TERM 175
#define FLOW_TAP_TERM 100
#define PERMISSIVE_HOLD_PER_KEY
#define CHORDAL_HOLD

#define COMBO_TERM 30
#define COMBO_TERM_PER_COMBO
#define COMBO_SHOULD_TRIGGER
#define MOUSEKEY_DELAY 0
#define MOUSEKEY_INTERVAL 16
#define MOUSEKEY_MOVE_DELTA 16
#define MOUSEKEY_MAX_SPEED 8
#define MOUSEKEY_TIME_TO_MAX 40
#define MOUSEKEY_WHEEL_DELAY 0
#define MOUSEKEY_WHEEL_INTERVAL 16
#define MOUSEKEY_WHEEL_MAX_SPEED 4
#define MOUSEKEY_WHEEL_TIME_TO_MAX 40

/*
 * Bodged RP2040 Pro Micro wiring:
 * Left-half bodged RP2040 Pro Micro wiring:
 *   PCB net that originally landed on GP6 -> MCU GP14
 *   PCB net that originally landed on GP7 -> MCU GP13
 *   PCB net that originally landed on GP9 -> MCU GP12
 *   PCB net that originally landed on GP8 stays on MCU GP8
 *
 * QMK's generated info_config.h defines these from keyboard.json before this
 * keymap config is included, so undef them here and provide the scanned pins
 * for the bodged left controller. The right half is not bodged and keeps the
 * stock row pins.
 */
#undef MATRIX_ROW_PINS
#define MATRIX_ROW_PINS { GP4, GP14, GP13, GP5 }

#undef MATRIX_ROW_PINS_RIGHT
#define MATRIX_ROW_PINS_RIGHT { GP4, GP5, GP6, GP21 }

#undef ENCODER_A_PINS
#define ENCODER_A_PINS { GP12 }

#undef ENCODER_B_PINS
#define ENCODER_B_PINS { GP8 }
