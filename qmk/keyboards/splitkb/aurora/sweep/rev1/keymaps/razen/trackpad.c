#include "sensors/cirque_pinnacle.h"
#include "keyboard.h"

void pointing_device_init_user(void) {
    if (!is_keyboard_left()) {
        cirque_pinnacle_cursor_smoothing(false);
    }
}
