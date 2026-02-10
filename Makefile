CONF := draw/config.yaml
BOARDS := glove80 cradio

# ─── Draw: Glove80 ──────────────────────────────────────────────────
GLOVE80_KEYMAP   := config/glove80.keymap
GLOVE80_YAML     := draw/glove80.yaml
GLOVE80_SVG      := draw/glove80.svg
GLOVE80_KEYBOARD := glove80
GLOVE80_LAYERS   := Graphite Symbol Nav Num Magic Vestnik

# ─── Draw: Cradio (Sweep) ───────────────────────────────────────────
CRADIO_KEYMAP   := config/cradio.keymap
CRADIO_YAML     := draw/cradio.yaml
CRADIO_SVG      := draw/cradio.svg
CRADIO_KEYBOARD := cradio
CRADIO_LAYERS   := Graphite Symbol Nav Num System Vestnik

# ─── Cache: zmk-helpers headers for keymap-drawer ─────────────────
ZMK_HELPERS_BASE := https://raw.githubusercontent.com/urob/zmk-helpers/main/include
ZMK_HELPERS_H    := .cache/zmk-helpers/helper.h
GLOVE80_LABELS   := .cache/zmk-helpers/key-labels/glove80.h
LABELS_36        := .cache/zmk-helpers/key-labels/36.h

# ─── Targets ─────────────────────────────────────────────────────────
.PHONY: all build draw setup clean \
        glove80 glove80-build glove80-draw glove80-setup glove80-clean \
        cradio cradio-build cradio-draw cradio-setup cradio-clean

all: build draw

build: glove80-build cradio-build
draw: $(GLOVE80_SVG) $(CRADIO_SVG)
setup: glove80-setup cradio-setup

glove80: glove80-build $(GLOVE80_SVG)
cradio: cradio-build $(CRADIO_SVG)

# ─── Firmware builds (delegate to build.sh) ──────────────────────────
glove80-build:
	./build.sh glove80

glove80-setup:
	./build.sh glove80 setup

glove80-clean:
	./build.sh glove80 clean

cradio-build:
	./build.sh cradio

cradio-setup:
	./build.sh cradio setup

cradio-clean:
	./build.sh cradio clean

# ─── Cache fetching ─────────────────────────────────────────────────
$(ZMK_HELPERS_H):
	mkdir -p $(dir $@)
	curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/helper.h -o $@

$(GLOVE80_LABELS):
	mkdir -p $(dir $@)
	curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/key-labels/glove80.h -o $@

$(LABELS_36):
	mkdir -p $(dir $@)
	curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/key-labels/36.h -o $@

# ─── Glove80 draw pipeline ──────────────────────────────────────────
$(GLOVE80_YAML): $(GLOVE80_KEYMAP) config/base.keymap $(CONF) $(ZMK_HELPERS_H) $(GLOVE80_LABELS)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(GLOVE80_LAYERS)

$(GLOVE80_SVG): $(GLOVE80_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(GLOVE80_KEYBOARD) > $@

glove80-draw: $(GLOVE80_SVG)

# ─── Cradio draw pipeline ───────────────────────────────────────────
$(CRADIO_YAML): $(CRADIO_KEYMAP) config/base.keymap $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(CRADIO_LAYERS)

$(CRADIO_SVG): $(CRADIO_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(CRADIO_KEYBOARD) > $@

cradio-draw: $(CRADIO_SVG)

# ─── Clean ───────────────────────────────────────────────────────────
clean: glove80-clean cradio-clean
	rm -f $(GLOVE80_YAML) $(GLOVE80_SVG) $(CRADIO_YAML) $(CRADIO_SVG)
	rm -rf .cache
