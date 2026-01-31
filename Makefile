CONF := draw/config.yaml

# ─── Piantor (QMK) ───────────────────────────────────────────────────
QMK_HOME     := $(HOME)/src/qmk_firmware
QMK_KEYBOARD := beekeeb/piantor_pro
QMK_KEYMAP   := razen
QMK_SRC      := $(QMK_HOME)/keyboards/$(QMK_KEYBOARD)/keymaps/$(QMK_KEYMAP)
QMK_UF2      := $(subst /,_,$(QMK_KEYBOARD))_$(QMK_KEYMAP).uf2

# ─── Draw: Piantor ───────────────────────────────────────────────────
QMK_JSON       := draw/piantor_qmk.json
PIANTOR_YAML   := draw/piantor.yaml
PIANTOR_SVG    := draw/piantor.svg
PIANTOR_COMBOS := draw/piantor_combos.yaml
PIANTOR_LAYERS := Graphite Symbol Nav Function Mouse QWERTY

# ─── Draw: Glove80 ──────────────────────────────────────────────────
GLOVE80_KEYMAP   := glove80/glove80.keymap
GLOVE80_YAML     := draw/glove80.yaml
GLOVE80_SVG      := draw/glove80.svg
GLOVE80_KEYBOARD := glove80

# ─── Targets ─────────────────────────────────────────────────────────
.PHONY: all draw piantor glove80 qmk qmk-sync qmk-flash clean

all: draw

draw: $(PIANTOR_SVG) $(GLOVE80_SVG)

piantor: $(PIANTOR_SVG)
glove80: $(GLOVE80_SVG)

# QMK build
qmk-sync:
	mkdir -p $(QMK_SRC)
	cp piantor/* $(QMK_SRC)/

qmk: qmk-sync
	qmk compile -kb $(QMK_KEYBOARD) -km $(QMK_KEYMAP)
	cp $(QMK_HOME)/$(QMK_UF2) .

qmk-flash: qmk-sync
	qmk flash -kb $(QMK_KEYBOARD) -km $(QMK_KEYMAP)

# Piantor draw pipeline: c2json → parse → inject held → draw with combos
$(QMK_JSON): piantor/keymap.c qmk-sync
	cd $(QMK_HOME) && qmk c2json --no-cpp -kb $(QMK_KEYBOARD) -km $(QMK_KEYMAP) -o $(CURDIR)/$@

$(PIANTOR_YAML): $(QMK_JSON) $(CONF) draw/inject_held.py
	keymap -c $(CONF) parse -q $< -l $(PIANTOR_LAYERS) | python3 draw/inject_held.py > $@

$(PIANTOR_SVG): $(PIANTOR_YAML) $(PIANTOR_COMBOS) $(CONF)
	keymap -c $(CONF) draw $< $(PIANTOR_COMBOS) -k $(QMK_KEYBOARD) > $@

# Glove80 draw pipeline: ZMK keymap → parse → draw
$(GLOVE80_YAML): $(GLOVE80_KEYMAP) $(CONF)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ Graphite Symbol Nav Num Magic QWERTY

$(GLOVE80_SVG): $(GLOVE80_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(GLOVE80_KEYBOARD) > $@

# Clean all generated files
clean:
	rm -f $(QMK_JSON) $(PIANTOR_YAML) $(PIANTOR_SVG) $(GLOVE80_YAML) $(GLOVE80_SVG) *.uf2
