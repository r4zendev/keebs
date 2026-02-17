CONF := draw/config.yaml
BOARDS := glove80 cradio splitkb_aurora_sweep

# ─── Draw: Glove80 ──────────────────────────────────────────────────
GLOVE80_KEYMAP   := config/glove80.keymap
GLOVE80_YAML     := draw/glove80.yaml
GLOVE80_SVG      := draw/glove80.svg
GLOVE80_KEYBOARD := glove80
GLOVE80_LAYERS   := Graphite Symbol Nav Num Fn Mouse Magic Vestnik

# ─── Draw: Cradio (Sweep) ───────────────────────────────────────────
CRADIO_KEYMAP   := config/cradio.keymap
CRADIO_YAML     := draw/cradio.yaml
CRADIO_SVG      := draw/cradio.svg
CRADIO_KEYBOARD := cradio
CRADIO_LAYERS   := Graphite Symbol Nav Num Fn Mouse System Vestnik

# ─── Cache: zmk-helpers headers for keymap-drawer ─────────────────
ZMK_HELPERS_BASE := https://raw.githubusercontent.com/urob/zmk-helpers/main/include
ZMK_HELPERS_H    := .cache/zmk-helpers/helper.h
GLOVE80_LABELS   := .cache/zmk-helpers/key-labels/glove80.h
LABELS_36        := .cache/zmk-helpers/key-labels/36.h

# ─── Draw: Aurora Sweep ────────────────────────────────────────────
AURORA_KEYMAP   := config/splitkb_aurora_sweep.keymap
AURORA_YAML     := draw/splitkb_aurora_sweep.yaml
AURORA_SVG      := draw/splitkb_aurora_sweep.svg
AURORA_KEYBOARD := cradio
AURORA_LAYERS   := Graphite Symbol Nav Num Fn Mouse System Vestnik

# ─── Targets ─────────────────────────────────────────────────────────
.PHONY: all build draw setup clean \
        glove80 glove80-build glove80-draw glove80-setup glove80-clean \
        cradio cradio-build cradio-draw cradio-setup cradio-clean \
        aurora aurora-build aurora-draw aurora-setup aurora-clean

all: build draw

build: glove80-build cradio-build aurora-build
draw: $(GLOVE80_SVG) $(CRADIO_SVG) $(AURORA_SVG)
setup: glove80-setup cradio-setup aurora-setup

glove80: glove80-build $(GLOVE80_SVG)
cradio: cradio-build $(CRADIO_SVG)
aurora: aurora-build $(AURORA_SVG)

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

aurora-build:
	./build.sh splitkb_aurora_sweep

aurora-setup:
	./build.sh splitkb_aurora_sweep setup

aurora-clean:
	./build.sh splitkb_aurora_sweep clean

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

# ─── Aurora Sweep draw pipeline ───────────────────────────────────
$(AURORA_YAML): $(AURORA_KEYMAP) config/base.keymap $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(AURORA_LAYERS)

$(AURORA_SVG): $(AURORA_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(AURORA_KEYBOARD) > $@

aurora-draw: $(AURORA_SVG)

# ─── Clean ───────────────────────────────────────────────────────────
clean: glove80-clean cradio-clean aurora-clean
	rm -f $(GLOVE80_YAML) $(GLOVE80_SVG) $(CRADIO_YAML) $(CRADIO_SVG) $(AURORA_YAML) $(AURORA_SVG)
	rm -rf .cache
