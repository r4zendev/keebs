CONF := draw/config.yaml

# ─── Draw: Glove80 ──────────────────────────────────────────────────
GLOVE80_KEYMAP   := config/glove80.keymap
GLOVE80_YAML     := draw/glove80.yaml
GLOVE80_SVG      := draw/glove80.svg
GLOVE80_KEYBOARD := glove80

# ─── Draw: Sweep (Cradio) ───────────────────────────────────────────
SWEEP_KEYMAP   := config/cradio.keymap
SWEEP_YAML     := draw/sweep.yaml
SWEEP_SVG      := draw/sweep.svg
SWEEP_KEYBOARD := cradio

# ─── Cache: zmk-helpers headers for keymap-drawer ─────────────────
ZMK_HELPERS_BASE := https://raw.githubusercontent.com/urob/zmk-helpers/main/include
ZMK_HELPERS_H    := .cache/zmk-helpers/helper.h
GLOVE80_LABELS   := .cache/zmk-helpers/key-labels/glove80.h
LABELS_36        := .cache/zmk-helpers/key-labels/36.h

# ─── Targets ─────────────────────────────────────────────────────────
.PHONY: all draw glove80 sweep clean

all: draw

draw: $(GLOVE80_SVG) $(SWEEP_SVG)

glove80: $(GLOVE80_SVG)
sweep: $(SWEEP_SVG)

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

# Sweep draw pipeline
$(SWEEP_YAML): $(SWEEP_KEYMAP) config/base.keymap $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ Graphite Symbol Nav Num System Vestnik

$(SWEEP_SVG): $(SWEEP_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(SWEEP_KEYBOARD) > $@

clean:
	rm -f $(GLOVE80_YAML) $(GLOVE80_SVG) $(SWEEP_YAML) $(SWEEP_SVG)
	rm -rf .cache
