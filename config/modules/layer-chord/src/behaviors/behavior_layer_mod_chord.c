#define DT_DRV_COMPAT zmk_behavior_layer_mod_chord

#include <zephyr/device.h>
#include <zephyr/sys/util.h>

#include <drivers/behavior.h>

#include <zmk/behavior.h>
#include <zmk/event_manager.h>
#include <zmk/events/layer_state_changed.h>
#include <zmk/events/position_state_changed.h>
#include <zmk/keymap.h>

struct behavior_layer_mod_chord_config {
    struct zmk_behavior_binding modifier;
    zmk_keymap_layer_id_t layer;
    uint32_t layer_position;
    uint32_t modifier_position;
};

struct behavior_layer_mod_chord_data {
    struct zmk_behavior_binding_event modifier_event;
    bool active;
    bool layer_pressed;
    bool modifier_pressed;
};

static int layer_mod_chord_pressed(struct zmk_behavior_binding *binding,
                                   struct zmk_behavior_binding_event event) {
    const struct device *dev = zmk_behavior_get_binding(binding->behavior_dev);
    const struct behavior_layer_mod_chord_config *config = dev->config;
    struct behavior_layer_mod_chord_data *data = dev->data;
    int ret = zmk_keymap_layer_activate(config->layer, false);
    if (ret < 0) {
        return ret;
    }
    event.position = config->modifier_position;
    ret = zmk_behavior_invoke_binding(&config->modifier, event, true);
    if (ret < 0) {
        zmk_keymap_layer_deactivate(config->layer, false);
        return ret;
    }
    data->modifier_event = event;
    data->active = true;
    data->layer_pressed = true;
    data->modifier_pressed = true;
    return ZMK_BEHAVIOR_OPAQUE;
}

static int layer_mod_chord_released(struct zmk_behavior_binding *binding,
                                    struct zmk_behavior_binding_event event) {
    const struct device *dev = zmk_behavior_get_binding(binding->behavior_dev);
    const struct behavior_layer_mod_chord_config *config = dev->config;
    struct behavior_layer_mod_chord_data *data = dev->data;
    int ret = 0;
    if (data->modifier_pressed) {
        data->modifier_pressed = false;
        data->modifier_event.timestamp = event.timestamp;
        ret = zmk_behavior_invoke_binding(&config->modifier, data->modifier_event, false);
    }
    if (data->layer_pressed) {
        data->layer_pressed = false;
        zmk_keymap_layer_deactivate(config->layer, false);
    }
    data->active = false;
    return ret < 0 ? ret : ZMK_BEHAVIOR_OPAQUE;
}

static const struct behavior_driver_api layer_mod_chord_driver_api = {
    .binding_pressed = layer_mod_chord_pressed,
    .binding_released = layer_mod_chord_released,
};

#define LAYER_MOD_CHORD_DEVICE(inst) DEVICE_DT_INST_GET(inst),
static const struct device *layer_mod_chord_devices[] = {
    DT_INST_FOREACH_STATUS_OKAY(LAYER_MOD_CHORD_DEVICE)};

static int layer_mod_chord_position_listener(const zmk_event_t *event) {
    const struct zmk_position_state_changed *position_event =
        as_zmk_position_state_changed(event);
    if (position_event == NULL || position_event->state) {
        return ZMK_EV_EVENT_BUBBLE;
    }
    for (size_t index = 0; index < ARRAY_SIZE(layer_mod_chord_devices); index++) {
        const struct device *dev = layer_mod_chord_devices[index];
        const struct behavior_layer_mod_chord_config *config = dev->config;
        struct behavior_layer_mod_chord_data *data = dev->data;
        if (!data->active) {
            continue;
        }
        if (position_event->position == config->layer_position && data->layer_pressed) {
            data->layer_pressed = false;
            zmk_keymap_layer_deactivate(config->layer, false);
        } else if (position_event->position == config->modifier_position &&
                   data->modifier_pressed) {
            data->modifier_pressed = false;
        }
        if (!data->layer_pressed && !data->modifier_pressed) {
            data->active = false;
        }
    }
    return ZMK_EV_EVENT_BUBBLE;
}

ZMK_LISTENER(layer_mod_chord, layer_mod_chord_position_listener);
ZMK_SUBSCRIPTION(layer_mod_chord, zmk_position_state_changed);

static int layer_mod_chord_layer_listener(const zmk_event_t *event) {
    const struct zmk_layer_state_changed *layer_event = as_zmk_layer_state_changed(event);
    if (layer_event == NULL || layer_event->state) {
        return ZMK_EV_EVENT_BUBBLE;
    }
    for (size_t index = 0; index < ARRAY_SIZE(layer_mod_chord_devices); index++) {
        const struct device *dev = layer_mod_chord_devices[index];
        const struct behavior_layer_mod_chord_config *config = dev->config;
        const struct behavior_layer_mod_chord_data *data = dev->data;
        if (data->layer_pressed && layer_event->layer == config->layer) {
            zmk_keymap_layer_activate(config->layer, false);
        }
    }
    return ZMK_EV_EVENT_BUBBLE;
}

ZMK_LISTENER(layer_mod_chord_layer, layer_mod_chord_layer_listener);
ZMK_SUBSCRIPTION(layer_mod_chord_layer, zmk_layer_state_changed);

#define LAYER_MOD_CHORD_INST(inst)                                                                 \
    static struct behavior_layer_mod_chord_data layer_mod_chord_data_##inst;                       \
    static const struct behavior_layer_mod_chord_config layer_mod_chord_config_##inst = {          \
        .modifier = ZMK_KEYMAP_EXTRACT_BINDING(0, DT_DRV_INST(inst)),                              \
        .layer = DT_INST_PROP(inst, layer),                                                        \
        .layer_position = DT_INST_PROP(inst, layer_position),                                     \
        .modifier_position = DT_INST_PROP(inst, modifier_position),                               \
    };                                                                                             \
    BEHAVIOR_DT_INST_DEFINE(inst, NULL, NULL, &layer_mod_chord_data_##inst,                        \
                            &layer_mod_chord_config_##inst, POST_KERNEL,                            \
                            CONFIG_KERNEL_INIT_PRIORITY_DEFAULT, &layer_mod_chord_driver_api);

DT_INST_FOREACH_STATUS_OKAY(LAYER_MOD_CHORD_INST)
