CONF := draw/config.yaml
BOARD_TARGETS := glove80 cradio aurora piantor corne artemis ansic klotz lambbt lintilla yetis wysteria klor

# ─── Draw config ────────────────────────────────────────────────────
GLOVE80_KEYMAP   := config/keyboards/glove80/glove80.keymap
GLOVE80_YAML     := draw/glove80.yaml
GLOVE80_SVG      := draw/glove80.svg
GLOVE80_KEYBOARD := glove80
GLOVE80_LAYERS   := Graphite Symbol Nav Num NumMirror Fn Mouse Magic Sturdy Vestnik Racket

CRADIO_KEYMAP   := config/keyboards/cradio/cradio.keymap
CRADIO_YAML     := draw/cradio.yaml
CRADIO_SVG      := draw/cradio.svg
CRADIO_KEYBOARD := cradio
CRADIO_LAYERS   := Graphite Symbol Nav Num NumMirror Fn Mouse System Sturdy Vestnik Racket

AURORA_KEYMAP   := config/keyboards/splitkb_aurora_sweep/splitkb_aurora_sweep.keymap
AURORA_YAML     := draw/splitkb_aurora_sweep.yaml
AURORA_SVG      := draw/splitkb_aurora_sweep.svg
AURORA_KEYBOARD := cradio
AURORA_LAYERS   := Graphite Symbol Nav Num NumMirror Fn Mouse System Sturdy Vestnik Racket

ZMK_HELPERS_BASE := https://raw.githubusercontent.com/urob/zmk-helpers/main/include
ZMK_HELPERS_H    := .cache/zmk-helpers/helper.h
GLOVE80_LABELS   := .cache/zmk-helpers/key-labels/glove80.h
LABELS_36        := .cache/zmk-helpers/key-labels/36.h

# ─── Main targets ───────────────────────────────────────────────────
.PHONY: all build draw setup clean help \
         glove80 cradio aurora piantor corne artemis ansic klotz lambbt lintilla yetis wysteria klor \
         yetis-build yetis-setup yetis-clean yetis-flash yetis-distclean \
         wysteria-build wysteria-setup wysteria-clean wysteria-flash wysteria-distclean \
         wysteria-qmk wysteria-qmk-build wysteria-qmk-setup wysteria-qmk-clean wysteria-qmk-flash wysteria-qmk-distclean \
         wysteria-zmk wysteria-zmk-build wysteria-zmk-setup wysteria-zmk-clean wysteria-zmk-reset \
         wysteria-wired wysteria-wireless \
         klor-build klor-setup klor-clean klor-flash klor-distclean \
         klor-qmk klor-qmk-build klor-qmk-setup klor-qmk-clean klor-qmk-flash klor-qmk-distclean \
         klor-zmk klor-zmk-build klor-zmk-setup klor-zmk-clean klor-zmk-reset \
         klor-wired klor-wireless \
         %-build %-draw %-setup %-clean %-reset %-left %-right

all: build draw
build: glove80-build cradio-build aurora-build piantor-build corne-build artemis-build ansic-build klotz-build lambbt-build lintilla-build yetis-build wysteria-build klor-build
draw: $(GLOVE80_SVG) $(CRADIO_SVG) $(AURORA_SVG)
setup: glove80-setup cradio-setup aurora-setup piantor-setup corne-setup artemis-setup ansic-setup klotz-setup lambbt-setup lintilla-setup yetis-setup wysteria-setup

help:
	@printf "Commands:\n"
	@printf "  make [all]            Build firmware and drawings\n"
	@printf "  make setup            Initialize all board workspaces\n"
	@printf "  make clean            Remove build outputs and draw cache\n"
	@printf "  make draw             Render layout previews (no Piantor draw target)\n"
	@printf "  make <board>          Build one board\n"
	@printf "  make <board>-setup    Initialize one board workspace\n"
	@printf "  make <board>-clean    Clean one board workspace\n"
	@printf "  make <board>-left     Build only the left half\n"
	@printf "  make <board>-right    Build only the right half\n"
	@printf "  make <board>-reset    Build settings_reset firmware\n"
	@printf "  make yetis-flash      Build and flash the QMK YetiS target\n"
	@printf "  make wysteria         Build Wysteria wired QMK and wireless ZMK\n"
	@printf "  make wysteria-wired   Build QMK Wysteria firmware\n"
	@printf "  make wysteria-wireless Build ZMK Wysteria firmware\n"
	@printf "  make wysteria-flash   Build and flash the QMK Wysteria target\n"
	@printf "  make klor             Build KLOR wired QMK and wireless ZMK\n"
	@printf "  make klor-wired       Build QMK KLOR RP2040 firmware\n"
	@printf "  make klor-wireless    Build ZMK KLOR firmware\n"
	@printf "  make klor-flash       Build and flash the QMK KLOR target\n"
	@printf "Boards: $(BOARD_TARGETS)\n"

glove80: glove80-build $(GLOVE80_SVG)
cradio:  cradio-build $(CRADIO_SVG)
aurora:  aurora-build $(AURORA_SVG)
piantor: piantor-build
corne:   corne-build
artemis: artemis-build
ansic: ansic-build
klotz: klotz-build
lambbt: lambbt-build
lintilla: lintilla-build
yetis: yetis-build
wysteria: wysteria-build
klor: klor-build

# ─── Firmware (delegates to build.sh) ───────────────────────────────
glove80-build: ; ./build.sh glove80
cradio-build:  ; ./build.sh cradio
aurora-build:  ; ./build.sh splitkb_aurora_sweep
piantor-build: ; ./build.sh piantor_pro
corne-build:   ; ./build.sh corne
artemis-build: ; ./build.sh artemis
ansic-build:   ; ./build.sh ansic
klotz-build:   ; ./build.sh klotz
lambbt-build:  ; ./build.sh lambbt
lintilla-build: ; ./build.sh lintilla
yetis-build:   ; ./qmk-build.sh build
yetis-setup:   ; ./qmk-build.sh setup
yetis-clean:   ; ./qmk-build.sh clean
yetis-flash:   ; ./qmk-build.sh flash
yetis-distclean: ; ./qmk-build.sh distclean
wysteria-build: wysteria-zmk-build wysteria-qmk-build
wysteria-setup: wysteria-zmk-setup wysteria-qmk-setup
wysteria-clean: wysteria-zmk-clean wysteria-qmk-clean
wysteria-flash: wysteria-qmk-flash
wysteria-distclean: wysteria-zmk-clean wysteria-qmk-distclean
wysteria-wired: wysteria-qmk-build
wysteria-wireless: wysteria-zmk-build
wysteria-qmk: wysteria-qmk-build
wysteria-qmk-build: ; QMK_KEYBOARD=wysteria ./qmk-build.sh build
wysteria-qmk-setup: ; QMK_KEYBOARD=wysteria ./qmk-build.sh setup
wysteria-qmk-clean: ; QMK_KEYBOARD=wysteria ./qmk-build.sh clean
wysteria-qmk-flash: ; QMK_KEYBOARD=wysteria ./qmk-build.sh flash
wysteria-qmk-distclean: ; QMK_KEYBOARD=wysteria ./qmk-build.sh distclean
wysteria-zmk: wysteria-zmk-build
wysteria-zmk-build: ; ./build.sh wysteria
wysteria-zmk-setup: ; ./build.sh wysteria setup
wysteria-zmk-clean: ; ./build.sh wysteria clean
wysteria-zmk-reset: ; ./build.sh wysteria reset
klor-build: klor-zmk-build klor-qmk-build
klor-setup: klor-zmk-setup klor-qmk-setup
klor-clean: klor-zmk-clean klor-qmk-clean
klor-flash: klor-qmk-flash
klor-distclean: klor-zmk-clean klor-qmk-distclean
klor-wired: klor-qmk-build
klor-wireless: klor-zmk-build
klor-qmk: klor-qmk-build
klor-qmk-build: ; QMK_KEYBOARD=klor QMK_OUTPUT_KEYBOARD=klor ./qmk-build.sh build
klor-qmk-setup: ; QMK_KEYBOARD=klor QMK_OUTPUT_KEYBOARD=klor ./qmk-build.sh setup
klor-qmk-clean: ; QMK_KEYBOARD=klor QMK_OUTPUT_KEYBOARD=klor ./qmk-build.sh clean
klor-qmk-flash: ; QMK_KEYBOARD=klor QMK_OUTPUT_KEYBOARD=klor ./qmk-build.sh flash
klor-qmk-distclean: ; QMK_KEYBOARD=klor QMK_OUTPUT_KEYBOARD=klor ./qmk-build.sh distclean
klor-zmk: klor-zmk-build
klor-zmk-build: ; ./build.sh klor
klor-zmk-setup: ; ./build.sh klor setup
klor-zmk-clean: ; ./build.sh klor clean
klor-zmk-reset: ; ./build.sh klor reset

glove80-draw: $(GLOVE80_SVG)
cradio-draw:  $(CRADIO_SVG)
aurora-draw:  $(AURORA_SVG)

%-setup: ; ./build.sh $(if $(filter aurora%,$*),splitkb_aurora_sweep,$(if $(filter piantor%,$*),piantor_pro,$*)) setup
%-clean: ; ./build.sh $(if $(filter aurora%,$*),splitkb_aurora_sweep,$(if $(filter piantor%,$*),piantor_pro,$*)) clean
%-left:  ; ./build.sh $(if $(filter aurora%,$*),splitkb_aurora_sweep,$(if $(filter piantor%,$*),piantor_pro,$*)) left
%-right: ; ./build.sh $(if $(filter aurora%,$*),splitkb_aurora_sweep,$(if $(filter piantor%,$*),piantor_pro,$*)) right
%-reset: ; ./build.sh $(if $(filter aurora%,$*),splitkb_aurora_sweep,$(if $(filter piantor%,$*),piantor_pro,$*)) reset
# ─── Cache ──────────────────────────────────────────────────────────
$(ZMK_HELPERS_H):
	mkdir -p $(dir $@) && curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/helper.h -o $@

$(GLOVE80_LABELS):
	mkdir -p $(dir $@) && curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/key-labels/glove80.h -o $@

$(LABELS_36):
	mkdir -p $(dir $@) && curl -sL $(ZMK_HELPERS_BASE)/zmk-helpers/key-labels/36.h -o $@

SHARED_KEYMAP := config/base.keymap $(wildcard config/includes/*.dtsi config/includes/layers/*.dtsi)

# ─── Draw pipelines ─────────────────────────────────────────────────
$(GLOVE80_YAML): $(GLOVE80_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(GLOVE80_LABELS)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(GLOVE80_LAYERS)

$(GLOVE80_SVG): $(GLOVE80_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(GLOVE80_KEYBOARD) > $@

$(CRADIO_YAML): $(CRADIO_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(CRADIO_LAYERS)

$(CRADIO_SVG): $(CRADIO_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(CRADIO_KEYBOARD) > $@

$(AURORA_YAML): $(AURORA_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(AURORA_LAYERS)

$(AURORA_SVG): $(AURORA_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(AURORA_KEYBOARD) > $@

# ─── Clean ──────────────────────────────────────────────────────────
clean: glove80-clean cradio-clean aurora-clean piantor-clean corne-clean artemis-clean ansic-clean klotz-clean lambbt-clean lintilla-clean yetis-clean wysteria-clean klor-clean
	rm -f $(GLOVE80_YAML) $(GLOVE80_SVG) $(CRADIO_YAML) $(CRADIO_SVG) $(AURORA_YAML) $(AURORA_SVG)
	rm -rf .cache
