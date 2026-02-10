CONF := draw/config.yaml

# ─── Draw: Glove80 ──────────────────────────────────────────────────
GLOVE80_KEYMAP   := config/glove80.keymap
GLOVE80_YAML     := draw/glove80.yaml
GLOVE80_SVG      := draw/glove80.svg
GLOVE80_KEYBOARD := glove80

# ─── Draw: Cradio ───────────────────────────────────────────────────
CRADIO_KEYMAP   := config/cradio.keymap
CRADIO_YAML     := draw/cradio.yaml
CRADIO_SVG      := draw/cradio.svg
CRADIO_KEYBOARD := cradio

# ─── Cache: zmk-helpers headers for keymap-drawer ─────────────────
ZMK_HELPERS_BASE := https://raw.githubusercontent.com/urob/zmk-helpers/main/include
ZMK_HELPERS_H    := .cache/zmk-helpers/helper.h
GLOVE80_LABELS   := .cache/zmk-helpers/key-labels/glove80.h
LABELS_36        := .cache/zmk-helpers/key-labels/36.h

# ─── Targets ─────────────────────────────────────────────────────────
.PHONY: all draw glove80 cradio clean

all: draw

draw: $(GLOVE80_SVG) $(CRADIO_SVG)

glove80: $(GLOVE80_SVG)
cradio: $(CRADIO_SVG)

$(ZMK_HELPERS_H):
	mkdir -p $(dir $@)
	curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/helper.h -o $@

$(GLOVE80_LABELS):
	mkdir -p $(dir $@)
	curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/key-labels/glove80.h -o $@

$(LABELS_36):
	mkdir -p $(dir $@)
	curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/key-labels/36.h -o $@

# Glove80 draw pipeline
$(GLOVE80_YAML): $(GLOVE80_KEYMAP) config/base.keymap $(CONF) $(ZMK_HELPERS_H) $(GLOVE80_LABELS)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ Graphite Symbol Nav Num Magic Vestnik

$(GLOVE80_SVG): $(GLOVE80_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(GLOVE80_KEYBOARD) > $@

# Cradio draw pipeline
$(CRADIO_YAML): $(CRADIO_KEYMAP) config/base.keymap $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ Graphite Symbol Nav Num System Vestnik

$(CRADIO_SVG): $(CRADIO_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(CRADIO_KEYBOARD) > $@

clean:
	rm -f $(GLOVE80_YAML) $(GLOVE80_SVG) $(CRADIO_YAML) $(CRADIO_SVG)
	rm -rf .cache
