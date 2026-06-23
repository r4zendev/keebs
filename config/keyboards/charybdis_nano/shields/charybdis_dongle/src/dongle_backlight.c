#include <zephyr/device.h>
#include <zephyr/drivers/display.h>
#include <zephyr/drivers/led.h>
#include <zephyr/init.h>
#include <zephyr/kernel.h>

#define DISP_BL DT_NODE_CHILD_IDX(DT_NODELABEL(disp_bl))

static int charybdis_dongle_backlight_on(void) {
    const struct device *display = DEVICE_DT_GET(DT_CHOSEN(zephyr_display));
    const struct device *pwm_leds_dev = DEVICE_DT_GET_ONE(pwm_leds);

    if (!device_is_ready(pwm_leds_dev)) {
        return 0;
    }

    led_set_brightness(pwm_leds_dev, DISP_BL, 80);

    if (device_is_ready(display)) {
        display_blanking_off(display);
    }

    return 0;
}

SYS_INIT(charybdis_dongle_backlight_on, APPLICATION, 55);
