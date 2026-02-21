CONF := draw/config.yaml

# ─── Draw config ────────────────────────────────────────────────────
GLOVE80_KEYMAP   := config/glove80.keymap
GLOVE80_YAML     := draw/glove80.yaml
GLOVE80_SVG      := draw/glove80.svg
GLOVE80_KEYBOARD := glove80
GLOVE80_LAYERS   := Graphite Symbol Nav Num Fn Mouse Magic Vestnik

CRADIO_KEYMAP   := config/cradio.keymap
CRADIO_YAML     := draw/cradio.yaml
CRADIO_SVG      := draw/cradio.svg
CRADIO_KEYBOARD := cradio
CRADIO_LAYERS   := Graphite Symbol Nav Num Fn Mouse System Vestnik

AURORA_KEYMAP   := config/splitkb_aurora_sweep.keymap
AURORA_YAML     := draw/splitkb_aurora_sweep.yaml
AURORA_SVG      := draw/splitkb_aurora_sweep.svg
AURORA_KEYBOARD := cradio
AURORA_LAYERS   := Graphite Symbol Nav Num Fn Mouse System Vestnik

ZMK_HELPERS_BASE := https://raw.githubusercontent.com/urob/zmk-helpers/main/include
ZMK_HELPERS_H    := .cache/zmk-helpers/helper.h
GLOVE80_LABELS   := .cache/zmk-helpers/key-labels/glove80.h
LABELS_36        := .cache/zmk-helpers/key-labels/36.h

# ─── Main targets ───────────────────────────────────────────────────
.PHONY: all build draw setup clean \
        glove80 cradio aurora \
        %-build %-draw %-setup %-clean %-reset

all: build draw
build: glove80-build cradio-build aurora-build
draw: $(GLOVE80_SVG) $(CRADIO_SVG) $(AURORA_SVG)
setup: glove80-setup cradio-setup aurora-setup

glove80: glove80-build $(GLOVE80_SVG)
cradio:  cradio-build $(CRADIO_SVG)
aurora:  aurora-build $(AURORA_SVG)

# ─── Firmware (delegates to build.sh) ───────────────────────────────
glove80-build: ; ./build.sh glove80
cradio-build:  ; ./build.sh cradio
aurora-build:  ; ./build.sh splitkb_aurora_sweep

glove80-draw: $(GLOVE80_SVG)
cradio-draw:  $(CRADIO_SVG)
aurora-draw:  $(AURORA_SVG)

%-setup: ; ./build.sh $(if $(filter aurora%,$*),splitkb_aurora_sweep,$*) setup
%-clean: ; ./build.sh $(if $(filter aurora%,$*),splitkb_aurora_sweep,$*) clean
%-reset: ; ./build.sh $(if $(filter aurora%,$*),splitkb_aurora_sweep,$*) reset

# ─── Cache ──────────────────────────────────────────────────────────
$(ZMK_HELPERS_H):
	mkdir -p $(dir $@) && curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/helper.h -o $@

$(GLOVE80_LABELS):
	mkdir -p $(dir $@) && curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/key-labels/glove80.h -o $@

$(LABELS_36):
	mkdir -p $(dir $@) && curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/key-labels/36.h -o $@

# ─── Draw pipelines ─────────────────────────────────────────────────
$(GLOVE80_YAML): $(GLOVE80_KEYMAP) config/base.keymap $(CONF) $(ZMK_HELPERS_H) $(GLOVE80_LABELS)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(GLOVE80_LAYERS)

$(GLOVE80_SVG): $(GLOVE80_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(GLOVE80_KEYBOARD) > $@

$(CRADIO_YAML): $(CRADIO_KEYMAP) config/base.keymap $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(CRADIO_LAYERS)

$(CRADIO_SVG): $(CRADIO_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(CRADIO_KEYBOARD) > $@

$(AURORA_YAML): $(AURORA_KEYMAP) config/base.keymap $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(AURORA_LAYERS)

$(AURORA_SVG): $(AURORA_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(AURORA_KEYBOARD) > $@

# ─── Clean ──────────────────────────────────────────────────────────
clean: glove80-clean cradio-clean aurora-clean
	rm -f $(GLOVE80_YAML) $(GLOVE80_SVG) $(CRADIO_YAML) $(CRADIO_SVG) $(AURORA_YAML) $(AURORA_SVG)
	rm -rf .cache
