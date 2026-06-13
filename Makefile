CONF := draw/config.yaml
BOARD_TARGETS := glove80 cradio aurora piantor corne cygnus artemis ansic klotz lambbt lintilla adept totem cantor_ble yetis wysteria klor dartyl choctyl charybdis_nano

# ─── Draw config ────────────────────────────────────────────────────
GLOVE80_KEYMAP   := config/keyboards/glove80/glove80.keymap
GLOVE80_YAML     := draw/glove80.yaml
GLOVE80_SVG      := draw/glove80.svg
GLOVE80_KEYBOARD := glove80
GLOVE80_LAYERS   := Graphite WhirlMrl Symbol Nav Num NumMirror Fn Mouse Magic Vestnik

CRADIO_KEYMAP   := config/keyboards/cradio/cradio.keymap
CRADIO_YAML     := draw/cradio.yaml
CRADIO_SVG      := draw/cradio.svg
CRADIO_KEYBOARD := cradio
CRADIO_LAYERS   := Graphite WhirlMrl Symbol Nav Num NumMirror Fn Mouse System Vestnik

AURORA_KEYMAP   := config/keyboards/splitkb_aurora_sweep/splitkb_aurora_sweep.keymap
AURORA_YAML     := draw/splitkb_aurora_sweep.yaml
AURORA_SVG      := draw/splitkb_aurora_sweep.svg
AURORA_KEYBOARD := cradio
AURORA_LAYERS   := Graphite WhirlMrl Symbol Nav Num NumMirror Fn Mouse System Vestnik

ZMK_HELPERS_BASE := https://raw.githubusercontent.com/urob/zmk-helpers/main/include
ZMK_HELPERS_H    := .cache/zmk-helpers/helper.h
GLOVE80_LABELS   := .cache/zmk-helpers/key-labels/glove80.h
LABELS_36        := .cache/zmk-helpers/key-labels/36.h

# ─── Main targets ───────────────────────────────────────────────────
.PHONY: all build draw setup clean help \
         glove80 cradio aurora piantor corne cygnus artemis ansic klotz lambbt lintilla adept totem cantor_ble yetis wysteria klor dartyl choctyl charybdis_nano charybdis \
         corne-build corne-setup corne-clean corne-flash corne-distclean \
         corne-qmk corne-qmk-build corne-qmk-setup corne-qmk-clean corne-qmk-flash corne-qmk-distclean \
         corne-zmk corne-zmk-build corne-zmk-setup corne-zmk-clean corne-zmk-reset \
         corne-wired corne-wireless \
         cygnus-build cygnus-setup cygnus-clean cygnus-flash cygnus-distclean \
         cygnus-qmk cygnus-qmk-build cygnus-qmk-setup cygnus-qmk-clean cygnus-qmk-flash cygnus-qmk-distclean \
         cygnus-zmk cygnus-zmk-build cygnus-zmk-setup cygnus-zmk-clean cygnus-zmk-reset \
         cygnus-wired cygnus-wireless \
         yetis-build yetis-setup yetis-clean yetis-flash yetis-distclean \
         wysteria-build wysteria-setup wysteria-clean wysteria-flash wysteria-distclean \
         wysteria-bodged-wired wysteria-bodged-qmk-build wysteria-bodged-qmk-setup wysteria-bodged-qmk-clean wysteria-bodged-qmk-flash \
         wysteria-qmk wysteria-qmk-build wysteria-qmk-setup wysteria-qmk-clean wysteria-qmk-flash wysteria-qmk-distclean \
         wysteria-zmk wysteria-zmk-build wysteria-zmk-setup wysteria-zmk-clean wysteria-zmk-reset \
         wysteria-wired wysteria-wireless \
         klor-build klor-setup klor-clean klor-flash klor-distclean \
         klor-qmk klor-qmk-build klor-qmk-setup klor-qmk-clean klor-qmk-flash klor-qmk-distclean \
         klor-zmk klor-zmk-build klor-zmk-setup klor-zmk-clean klor-zmk-reset \
         klor-wired klor-wireless \
         %-build %-draw %-setup %-clean %-reset %-left %-right

all: build draw
build: glove80-build cradio-build aurora-build piantor-build corne-build cygnus-build artemis-build ansic-build klotz-build lambbt-build lintilla-build adept-build totem-build cantor_ble-build yetis-build wysteria-build klor-build dartyl-build choctyl-build charybdis_nano-build
draw: $(GLOVE80_SVG) $(CRADIO_SVG) $(AURORA_SVG)
setup: glove80-setup cradio-setup aurora-setup piantor-setup corne-setup cygnus-setup artemis-setup ansic-setup klotz-setup lambbt-setup lintilla-setup yetis-setup wysteria-setup

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
	@printf "  make corne-wired      Build QMK Corne RP2040 firmware\n"
	@printf "  make corne-wireless   Build ZMK Corne firmware\n"
	@printf "  make cygnus-wired     Build QMK Cygnus/Corne RP2040 firmware\n"
	@printf "  make cygnus-wireless  Build ZMK Cygnus firmware using Corne shields\n"
	@printf "  make yetis-flash      Build and flash the QMK YetiS target\n"
	@printf "  make wysteria         Build Wysteria wired QMK and wireless ZMK\n"
	@printf "  make wysteria-wired   Build QMK Wysteria firmware\n"
	@printf "  make wysteria-bodged-wired Build QMK Wysteria bodged firmware\n"
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
cygnus:  cygnus-build
artemis: artemis-build
ansic: ansic-build
klotz: klotz-build
lambbt: lambbt-build
lintilla: lintilla-build
adept: adept-build
totem: totem-build
cantor_ble: cantor_ble-build
yetis: yetis-build
wysteria: wysteria-build
klor: klor-build
dartyl: dartyl-build
charybdis_nano: charybdis_nano-build
charybdis: charybdis_nano-build

# ─── Firmware (delegates to build.sh) ───────────────────────────────
dartyl-build: dartyl-qmk-build
dartyl-setup: dartyl-qmk-setup
dartyl-clean: dartyl-qmk-clean
dartyl-flash: dartyl-qmk-flash
dartyl-distclean: dartyl-qmk-distclean
dartyl-qmk: dartyl-qmk-build
dartyl-qmk-build: ; QMK_KEYBOARD=dartyl ./qmk-build.sh build
dartyl-qmk-setup: ; QMK_KEYBOARD=dartyl ./qmk-build.sh setup
dartyl-qmk-clean: ; QMK_KEYBOARD=dartyl ./qmk-build.sh clean
dartyl-qmk-flash: ; QMK_KEYBOARD=dartyl ./qmk-build.sh flash
dartyl-qmk-distclean: ; QMK_KEYBOARD=dartyl ./qmk-build.sh distclean

choctyl: choctyl-build
choctyl-build: choctyl-qmk-build
choctyl-setup: choctyl-qmk-setup
choctyl-clean: choctyl-qmk-clean
choctyl-flash: choctyl-qmk-flash
choctyl-distclean: choctyl-qmk-distclean
choctyl-qmk: choctyl-qmk-build
choctyl-qmk-build: ; QMK_KEYBOARD=choctyl ./qmk-build.sh build
choctyl-qmk-setup: ; QMK_KEYBOARD=choctyl ./qmk-build.sh setup
choctyl-qmk-clean: ; QMK_KEYBOARD=choctyl ./qmk-build.sh clean
choctyl-qmk-flash: ; QMK_KEYBOARD=choctyl ./qmk-build.sh flash
choctyl-qmk-distclean: ; QMK_KEYBOARD=choctyl ./qmk-build.sh distclean
glove80-build: ; ./build.sh glove80
cradio-build:  ; ./build.sh cradio
aurora-build:  ; ./build.sh splitkb_aurora_sweep
piantor-build: ; ./build.sh piantor_pro
charybdis_nano-build: ; ./build.sh charybdis_nano
corne-build: corne-zmk-build corne-qmk-build
corne-setup: corne-zmk-setup corne-qmk-setup
corne-clean: corne-zmk-clean corne-qmk-clean
corne-flash: corne-qmk-flash
corne-distclean: corne-zmk-clean corne-qmk-distclean
corne-wired: corne-qmk-build
corne-wireless: corne-zmk-build
corne-qmk: corne-qmk-build
corne-qmk-build: ; QMK_KEYBOARD=crkbd/rev1 QMK_OUTPUT_KEYBOARD=corne ./qmk-build.sh build
corne-qmk-setup: ; QMK_KEYBOARD=crkbd/rev1 QMK_OUTPUT_KEYBOARD=corne ./qmk-build.sh setup
corne-qmk-clean: ; QMK_KEYBOARD=crkbd/rev1 QMK_OUTPUT_KEYBOARD=corne ./qmk-build.sh clean
corne-qmk-flash: ; QMK_KEYBOARD=crkbd/rev1 QMK_OUTPUT_KEYBOARD=corne ./qmk-build.sh flash
corne-qmk-distclean: ; QMK_KEYBOARD=crkbd/rev1 QMK_OUTPUT_KEYBOARD=corne ./qmk-build.sh distclean
corne-zmk: corne-zmk-build
corne-zmk-build: ; ./build.sh corne
corne-zmk-setup: ; ./build.sh corne setup
corne-zmk-clean: ; ./build.sh corne clean
corne-zmk-reset: ; ./build.sh corne reset
cygnus-build: cygnus-zmk-build cygnus-qmk-build
cygnus-setup: cygnus-zmk-setup cygnus-qmk-setup
cygnus-clean: cygnus-zmk-clean cygnus-qmk-clean
cygnus-flash: cygnus-qmk-flash
cygnus-distclean: cygnus-zmk-clean cygnus-qmk-distclean
cygnus-wired: cygnus-qmk-build
cygnus-wireless: cygnus-zmk-build
cygnus-qmk: cygnus-qmk-build
cygnus-qmk-build: ; QMK_KEYBOARD=crkbd/rev1 QMK_OUTPUT_KEYBOARD=cygnus ./qmk-build.sh build
cygnus-qmk-setup: ; QMK_KEYBOARD=crkbd/rev1 QMK_OUTPUT_KEYBOARD=cygnus ./qmk-build.sh setup
cygnus-qmk-clean: ; QMK_KEYBOARD=crkbd/rev1 QMK_OUTPUT_KEYBOARD=cygnus ./qmk-build.sh clean
cygnus-qmk-flash: ; QMK_KEYBOARD=crkbd/rev1 QMK_OUTPUT_KEYBOARD=cygnus ./qmk-build.sh flash
cygnus-qmk-distclean: ; QMK_KEYBOARD=crkbd/rev1 QMK_OUTPUT_KEYBOARD=cygnus ./qmk-build.sh distclean
cygnus-zmk: cygnus-zmk-build
cygnus-zmk-build: ; ./build.sh cygnus
cygnus-zmk-setup: ; ./build.sh cygnus setup
cygnus-zmk-clean: ; ./build.sh cygnus clean
cygnus-zmk-reset: ; ./build.sh cygnus reset
artemis-build: ; ./build.sh artemis
ansic-build:   ; ./build.sh ansic
klotz-build:   ; ./build.sh klotz
lambbt-build:  ; ./build.sh lambbt
lintilla-build: ; ./build.sh lintilla
adept-build: ; ./build.sh adept
totem-build: ; ./build.sh totem
cantor_ble-build: ; ./build.sh cantor_ble
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
wysteria-bodged-wired: wysteria-bodged-qmk-build
wysteria-bodged-qmk-build: ; QMK_HOME="$(CURDIR)/.qmk/qmk_firmware_wysteria_build" QMK_KEYBOARD=wysteria QMK_KEYMAP=razen_bodged ./qmk-build.sh build
wysteria-bodged-qmk-setup: ; QMK_HOME="$(CURDIR)/.qmk/qmk_firmware_wysteria_build" QMK_KEYBOARD=wysteria QMK_KEYMAP=razen_bodged ./qmk-build.sh setup
wysteria-bodged-qmk-clean: ; QMK_HOME="$(CURDIR)/.qmk/qmk_firmware_wysteria_build" QMK_KEYBOARD=wysteria QMK_KEYMAP=razen_bodged ./qmk-build.sh clean
wysteria-bodged-qmk-flash: ; QMK_HOME="$(CURDIR)/.qmk/qmk_firmware_wysteria_build" QMK_KEYBOARD=wysteria QMK_KEYMAP=razen_bodged ./qmk-build.sh flash
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
clean: glove80-clean cradio-clean aurora-clean piantor-clean corne-clean cygnus-clean artemis-clean ansic-clean klotz-clean lambbt-clean lintilla-clean adept-clean totem-clean cantor_ble-clean yetis-clean wysteria-clean klor-clean charybdis_nano-clean
	rm -f $(GLOVE80_YAML) $(GLOVE80_SVG) $(CRADIO_YAML) $(CRADIO_SVG) $(AURORA_YAML) $(AURORA_SVG)
	rm -rf .cache
