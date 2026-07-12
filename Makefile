CONF := draw/config.yaml
BOARD_TARGETS := luna glove80 cradio aurora piantor corne cygnus artemis ansic klotz lambbt lintilla adept totem cantor_ble yetis wysteria klor dartyl choctyl dactyl_cc charybdis_nano flake

# ─── Draw config ────────────────────────────────────────────────────
GLOVE80_KEYMAP   := config/keyboards/glove80/glove80.keymap
GLOVE80_YAML     := draw/glove80.yaml
GLOVE80_SVG      := draw/glove80.svg
GLOVE80_KEYBOARD := glove80
GLOVE80_LAYERS   := Graphite Honeypie Symbol Nav Num NumMirror Fn Mouse Magic Vestnik

CRADIO_KEYMAP   := config/keyboards/cradio/cradio.keymap
CRADIO_YAML     := draw/cradio.yaml
CRADIO_SVG      := draw/cradio.svg
CRADIO_LAYERS   := Graphite Honeypie Symbol Nav Num NumMirror Fn Mouse System Vestnik

AURORA_KEYMAP   := config/keyboards/splitkb_aurora_sweep/splitkb_aurora_sweep.keymap
AURORA_YAML     := draw/splitkb_aurora_sweep.yaml
AURORA_SVG      := draw/splitkb_aurora_sweep.svg
AURORA_LAYERS   := Graphite Honeypie Symbol Nav Num NumMirror Fn Mouse System Vestnik

# Boards sharing includes/34key.dtsi (same role order as Cradio, just wired
# to different real matrix positions) draw with Cradio's real geometry.
ARTEMIS_KEYMAP := config/keyboards/artemis/artemis.keymap
ARTEMIS_YAML   := draw/artemis.yaml
ARTEMIS_SVG    := draw/artemis.svg
ARTEMIS_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

KLOTZ_KEYMAP := config/keyboards/klotz/klotz.keymap
KLOTZ_YAML   := draw/klotz.yaml
KLOTZ_SVG    := draw/klotz.svg
KLOTZ_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

LAMBBT_KEYMAP := config/keyboards/lambbt/lambbt.keymap
LAMBBT_YAML   := draw/lambbt.yaml
LAMBBT_SVG    := draw/lambbt.svg
LAMBBT_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

PIANTOR_KEYMAP := config/keyboards/piantor_pro/piantor_pro.keymap
PIANTOR_YAML   := draw/piantor.yaml
PIANTOR_SVG    := draw/piantor.svg
PIANTOR_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

# Corne shares the same foostan 5-column shape as Cygnus's real crkbd/rev1
# geometry.
CORNE_KEYMAP := config/keyboards/corne/corne.keymap
CORNE_YAML   := draw/corne.yaml
CORNE_SVG    := draw/corne.svg
CORNE_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

CANTOR_BLE_KEYMAP := config/keyboards/cantor_ble/cantor_ble.keymap
CANTOR_BLE_YAML   := draw/cantor_ble.yaml
CANTOR_BLE_SVG    := draw/cantor_ble.svg
CANTOR_BLE_LAYOUT := 333333+3 3+333333
CANTOR_BLE_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

LINTILLA_KEYMAP := config/keyboards/lintilla/lintilla.keymap
LINTILLA_YAML   := draw/lintilla.yaml
LINTILLA_SVG    := draw/lintilla.svg
LINTILLA_LAYOUT := 1^^2^33333+3 3+333332^1^^
LINTILLA_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

DACTYL_CC_YAML    := draw/dactyl_cc.yaml
DACTYL_CC_SVG     := draw/dactyl_cc.svg
DACTYL_CC_PROFILE := dactyl_cc_68
DACTYL_CC_INFO    := qmk/keyboards/dactyl_cc/keyboard.json
DACTYL_CC_LAYOUT  := LAYOUT

FLAKE_KEYMAP := config/keyboards/flake/flake.keymap
FLAKE_YAML   := draw/flake.yaml
FLAKE_SVG    := draw/flake.svg
FLAKE_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System
FLAKE_PHYSICAL_LAYOUT := .cache/anywhy_flake.dtsi

LUNA_KEYMAP   := config/keyboards/luna/luna.keymap
LUNA_YAML     := draw/luna.yaml
LUNA_SVG      := draw/luna.svg
LUNA_LAYERS   := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

TOTEM_KEYMAP := config/keyboards/totem/totem.keymap
TOTEM_YAML   := draw/totem.yaml
TOTEM_SVG    := draw/totem.svg
SHAPE_36 := 33333+3 3+33333

TOTEM_LAYOUT := 133333+3 3+333331
TOTEM_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

ANSIC_KEYMAP := config/keyboards/ansic/ansic.keymap
ANSIC_YAML   := draw/ansic.yaml
ANSIC_SVG    := draw/ansic.svg
ANSIC_INFO   := draw/ansic_layout.json
ANSIC_LAYOUT := LAYOUT_ansic
ANSIC_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

CYGNUS_YAML    := draw/cygnus.yaml
CYGNUS_SVG     := draw/cygnus.svg
CYGNUS_PROFILE := cygnus_36

CHARYBDIS_KEYMAP := config/keyboards/charybdis_nano/charybdis_nano.keymap
CHARYBDIS_35_YAML := draw/charybdis_35.yaml
CHARYBDIS_35_SVG := draw/charybdis_35.svg
CHARYBDIS_35_LAYOUT := 33333+3 2+33333
CHARYBDIS_36_YAML := draw/charybdis_36.yaml
CHARYBDIS_36_SVG := draw/charybdis_36.svg
CHARYBDIS_36_LAYOUT := $(SHAPE_36)
CHARYBDIS_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

DARTYL_YAML    := draw/dartyl.yaml
DARTYL_SVG     := draw/dartyl.svg
DARTYL_PROFILE := dartyl_34
DARTYL_INFO    := qmk/keyboards/dartyl/keyboard.json
DARTYL_LAYOUT  := LAYOUT_dartyl_34

CHOCTYL_YAML    := draw/choctyl.yaml
CHOCTYL_SVG     := draw/choctyl.svg
CHOCTYL_PROFILE := choctyl_36
CHOCTYL_INFO    := qmk/keyboards/choctyl/keyboard.json
CHOCTYL_LAYOUT  := LAYOUT_split_3x5_3

YETIS_YAML    := draw/yetis.yaml
YETIS_SVG     := draw/yetis.svg
YETIS_PROFILE := yetis_34
YETIS_INFO    := qmk/keyboards/yetis/keyboard.json
YETIS_LAYOUT  := LAYOUT

WYSTERIA_YAML    := draw/wysteria.yaml
WYSTERIA_SVG     := draw/wysteria.svg
WYSTERIA_PROFILE := wysteria_38
WYSTERIA_INFO    := qmk/keyboards/wysteria/keyboard.json
WYSTERIA_LAYOUT  := LAYOUT_wyst_draw_36

KLOR_POLYDACTYL_YAML    := draw/klor_polydactyl.yaml
KLOR_POLYDACTYL_SVG     := draw/klor_polydactyl.svg
KLOR_POLYDACTYL_PROFILE := klor_polydactyl_42
KLOR_POLYDACTYL_INFO    := qmk/keyboards/klor/keyboard.json
KLOR_POLYDACTYL_NOTATION := 233333+4 4+333332

KLOR_KONRAD_YAML    := draw/klor_konrad.yaml
KLOR_KONRAD_SVG     := draw/klor_konrad.svg
KLOR_KONRAD_PROFILE := klor_konrad_40
KLOR_KONRAD_INFO    := qmk/keyboards/klor/keyboard.json
KLOR_KONRAD_NOTATION := 233333+3 3+333332

KLOR_SAEGEWERK_KEYMAP := config/keyboards/klor/saegewerk.keymap
KLOR_SAEGEWERK_YAML   := draw/klor_saegewerk.yaml
KLOR_SAEGEWERK_SVG    := draw/klor_saegewerk.svg
KLOR_SAEGEWERK_LAYOUT := $(SHAPE_36)
KLOR_SAEGEWERK_LAYERS := Graphite VestnikDm Symbol Nav Num NumMirror Fn Mouse System

ZMK_HELPERS_BASE := https://raw.githubusercontent.com/urob/zmk-helpers/main/include
ZMK_HELPERS_H    := .cache/zmk-helpers/helper.h
GLOVE80_LABELS   := .cache/zmk-helpers/key-labels/glove80.h
LABELS_36        := .cache/zmk-helpers/key-labels/36.h

# ─── Main targets ───────────────────────────────────────────────────
.PHONY: all build draw setup clean help \
         luna luna-build luna-draw luna-setup luna-clean glove80 cradio aurora aurora-build aurora-zmk aurora-zmk-build aurora-zmk-setup aurora-zmk-clean aurora-qmk aurora-qmk-build aurora-qmk-setup aurora-qmk-clean aurora-qmk-flash aurora-qmk-distclean aurora-wired aurora-wireless piantor corne cygnus artemis ansic klotz lambbt lintilla adept totem cantor_ble yetis wysteria klor dartyl choctyl dactyl_cc dactyl-cc charybdis_nano charybdis \
         corne-build corne-distclean \
         corne-qmk corne-qmk-build corne-qmk-setup corne-qmk-clean corne-qmk-flash corne-qmk-distclean \
         corne-zmk corne-zmk-build corne-zmk-setup corne-zmk-clean corne-zmk-reset \
         corne-wired corne-wireless \
         cygnus-build cygnus-setup cygnus-clean cygnus-flash cygnus-distclean \
         cygnus-qmk cygnus-qmk-build cygnus-qmk-setup cygnus-qmk-clean cygnus-qmk-flash cygnus-qmk-distclean \
         yetis-build yetis-setup yetis-clean yetis-flash yetis-distclean \
         wysteria-build wysteria-setup wysteria-clean wysteria-flash wysteria-distclean \
         wysteria-bodged-wired wysteria-bodged-qmk-build wysteria-bodged-qmk-setup wysteria-bodged-qmk-clean wysteria-bodged-qmk-flash \
         wysteria-qmk wysteria-qmk-build wysteria-qmk-setup wysteria-qmk-clean wysteria-qmk-flash wysteria-qmk-distclean \
         wysteria-zmk wysteria-zmk-build wysteria-zmk-setup wysteria-zmk-clean wysteria-zmk-reset \
         wysteria-wired wysteria-wireless \
         klor-build klor-setup klor-clean klor-flash klor-distclean klor-polydactyl klor-konrad klor-konrad-build klor-konrad-zmk-build klor-konrad-qmk-build \
         klor-saegewerk klor-saegewerk-build klor-saegewerk-draw \
         klor-qmk klor-qmk-build klor-qmk-setup klor-qmk-clean klor-qmk-flash klor-qmk-distclean \
         klor-zmk klor-zmk-build klor-zmk-setup klor-zmk-clean klor-zmk-reset \
         klor-wired klor-wireless \
         dactyl-cc-build dactyl-cc-setup dactyl-cc-clean dactyl-cc-flash dactyl-cc-distclean \
         totem-draw ansic-draw cygnus-draw charybdis_nano-draw charybdis-draw dartyl-draw choctyl-draw yetis-draw wysteria-draw klor-draw klor-polydactyl-draw klor-konrad-draw \
         artemis-draw klotz-draw lambbt-draw piantor-draw corne-draw cantor_ble-draw lintilla-draw dactyl-cc-draw \
         %-setup %-clean %-reset %-left %-right

all: build draw
build: luna-build glove80-build cradio-build aurora-build piantor-build corne-build cygnus-build artemis-build ansic-build klotz-build lambbt-build lintilla-build adept-build totem-build cantor_ble-build yetis-build wysteria-build klor-build dartyl-build choctyl-build dactyl-cc-build charybdis_nano-build flake-build
draw: $(LUNA_SVG) $(GLOVE80_SVG) $(CRADIO_SVG) $(AURORA_SVG) $(TOTEM_SVG) $(ANSIC_SVG) $(CYGNUS_SVG) $(CHARYBDIS_35_SVG) $(CHARYBDIS_36_SVG) $(DARTYL_SVG) $(CHOCTYL_SVG) $(YETIS_SVG) $(WYSTERIA_SVG) $(KLOR_POLYDACTYL_SVG) $(KLOR_KONRAD_SVG) $(KLOR_SAEGEWERK_SVG) $(ARTEMIS_SVG) $(KLOTZ_SVG) $(LAMBBT_SVG) $(PIANTOR_SVG) $(CORNE_SVG) $(CANTOR_BLE_SVG) $(LINTILLA_SVG) $(FLAKE_SVG) $(DACTYL_CC_SVG)
setup: luna-setup glove80-setup cradio-setup aurora-setup piantor-setup corne-setup cygnus-setup artemis-setup ansic-setup klotz-setup lambbt-setup lintilla-setup adept-setup totem-setup cantor_ble-setup yetis-setup wysteria-setup klor-setup dartyl-setup choctyl-setup dactyl-cc-setup charybdis_nano-setup flake-setup

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
	@printf "  make corne-wireless   Build ZMK Corne firmware\n"
	@printf "  make cygnus           Build QMK Cygnus/Corne RP2040 firmware\n"
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

luna: luna-build $(LUNA_SVG)
luna-draw: $(LUNA_SVG)
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
flake: flake-build
cantor_ble: cantor_ble-build
yetis: yetis-build
wysteria: wysteria-build
klor: klor-build
klor-polydactyl: klor-build
klor-konrad: klor-konrad-build
klor-saegewerk: klor-saegewerk-build
dartyl: dartyl-build
dactyl_cc: dactyl-cc-build
dactyl-cc: dactyl-cc-build
charybdis_nano: charybdis_nano-build
charybdis: charybdis_nano-build

# ─── Firmware (delegates to build.sh / qmk-build.sh) ────────────────
define QMK_BUILD_RULES
$(1)-qmk: $(1)-qmk-build
$(1)-qmk-build: ; QMK_KEYBOARD=$(2)$(if $(3), QMK_OUTPUT_KEYBOARD=$(3)) ./qmk-build.sh build
$(1)-qmk-setup: ; QMK_KEYBOARD=$(2)$(if $(3), QMK_OUTPUT_KEYBOARD=$(3)) ./qmk-build.sh setup
$(1)-qmk-clean: ; QMK_KEYBOARD=$(2)$(if $(3), QMK_OUTPUT_KEYBOARD=$(3)) ./qmk-build.sh clean
$(1)-qmk-flash: ; QMK_KEYBOARD=$(2)$(if $(3), QMK_OUTPUT_KEYBOARD=$(3)) ./qmk-build.sh flash
$(1)-qmk-distclean: ; QMK_KEYBOARD=$(2)$(if $(3), QMK_OUTPUT_KEYBOARD=$(3)) ./qmk-build.sh distclean
endef

$(eval $(call QMK_BUILD_RULES,dartyl,dartyl,))
$(eval $(call QMK_BUILD_RULES,choctyl,choctyl,))
$(eval $(call QMK_BUILD_RULES,aurora,splitkb/aurora/sweep/rev1,splitkb_aurora_sweep))
$(eval $(call QMK_BUILD_RULES,cygnus,crkbd/rev1,cygnus))
$(eval $(call QMK_BUILD_RULES,wysteria,wysteria,))
$(eval $(call QMK_BUILD_RULES,klor,klor,klor))

define ZMK_BUILD_RULES
$(1)-zmk: $(1)-zmk-build
$(1)-zmk-build: ; ./build.sh $(1)
$(1)-zmk-setup: ; ./build.sh $(1) setup
$(1)-zmk-clean: ; ./build.sh $(1) clean
$(1)-zmk-reset: ; ./build.sh $(1) reset
endef

$(eval $(call ZMK_BUILD_RULES,corne))
$(eval $(call ZMK_BUILD_RULES,wysteria))
$(eval $(call ZMK_BUILD_RULES,klor))

dartyl-build: dartyl-qmk-build
dartyl-setup: dartyl-qmk-setup ;
dartyl-clean: dartyl-qmk-clean ;
dartyl-flash: dartyl-qmk-flash
dartyl-distclean: dartyl-qmk-distclean

luna-build: ; ./build.sh luna

choctyl: choctyl-build
choctyl-build: choctyl-qmk-build
choctyl-setup: choctyl-qmk-setup ;
choctyl-clean: choctyl-qmk-clean ;
choctyl-flash: choctyl-qmk-flash
choctyl-distclean: choctyl-qmk-distclean
dactyl-cc-build: ; QMK_KEYBOARD=dactyl_cc QMK_KEYMAP=razen ./qmk-build.sh build
dactyl-cc-setup: ; QMK_KEYBOARD=dactyl_cc QMK_KEYMAP=razen ./qmk-build.sh setup
dactyl-cc-clean: ; QMK_KEYBOARD=dactyl_cc QMK_KEYMAP=razen ./qmk-build.sh clean
dactyl-cc-flash: ; QMK_KEYBOARD=dactyl_cc QMK_KEYMAP=razen ./qmk-build.sh flash
dactyl-cc-distclean: ; QMK_KEYBOARD=dactyl_cc QMK_KEYMAP=razen ./qmk-build.sh distclean
glove80-build: ; ./build.sh glove80
cradio-build:  ; ./build.sh cradio
aurora-build: aurora-zmk-build aurora-qmk-build
aurora-setup: aurora-zmk-setup aurora-qmk-setup ;
aurora-clean: aurora-zmk-clean aurora-qmk-clean ;
aurora-distclean: aurora-zmk-clean aurora-qmk-distclean
aurora-zmk-build: ; ./build.sh splitkb_aurora_sweep
aurora-zmk-setup: ; ./build.sh splitkb_aurora_sweep setup
aurora-zmk-clean: ; ./build.sh splitkb_aurora_sweep clean
aurora-zmk: aurora-zmk-build
aurora-wired: aurora-qmk-build
aurora-wireless: aurora-zmk-build
piantor-build: ; ./build.sh piantor_pro
charybdis_nano-build: ; ./build.sh charybdis_nano
corne-build: corne-zmk-build
corne-distclean: corne-zmk-clean
corne-wireless: corne-zmk-build
corne-wired corne-qmk corne-qmk-build corne-qmk-setup corne-qmk-clean corne-qmk-flash corne-qmk-distclean:
	@printf "No QMK Corne target in this repo. Use cygnus-build for crkbd/rev1 wiring.\n" >&2
	@false
cygnus-build: cygnus-qmk-build
cygnus-setup: cygnus-qmk-setup ;
cygnus-clean: cygnus-qmk-clean ;
cygnus-flash: cygnus-qmk-flash
cygnus-distclean: cygnus-qmk-distclean
artemis-build: ; ./build.sh artemis
ansic-build:   ; ./build.sh ansic
klotz-build:   ; ./build.sh klotz
lambbt-build:  ; ./build.sh lambbt
lintilla-build: ; ./build.sh lintilla
adept-build: ; ./build.sh adept
totem-build: ; ./build.sh totem
flake-build: ; ./build.sh flake
cantor_ble-build: ; ./build.sh cantor_ble
yetis-build:   ; ./qmk-build.sh build
yetis-setup:   ; ./qmk-build.sh setup
yetis-clean:   ; ./qmk-build.sh clean
yetis-flash:   ; ./qmk-build.sh flash
yetis-distclean: ; ./qmk-build.sh distclean
wysteria-build: wysteria-zmk-build wysteria-qmk-build
wysteria-setup: wysteria-zmk-setup wysteria-qmk-setup ;
wysteria-clean: wysteria-zmk-clean wysteria-qmk-clean ;
wysteria-flash: wysteria-qmk-flash
wysteria-distclean: wysteria-zmk-clean wysteria-qmk-distclean
wysteria-wired: wysteria-qmk-build
wysteria-wireless: wysteria-zmk-build
wysteria-bodged-wired: wysteria-bodged-qmk-build
wysteria-bodged-qmk-build: ; QMK_HOME="$(CURDIR)/.qmk/qmk_firmware_wysteria_build" QMK_KEYBOARD=wysteria QMK_KEYMAP=razen_bodged ./qmk-build.sh build
wysteria-bodged-qmk-setup: ; QMK_HOME="$(CURDIR)/.qmk/qmk_firmware_wysteria_build" QMK_KEYBOARD=wysteria QMK_KEYMAP=razen_bodged ./qmk-build.sh setup
wysteria-bodged-qmk-clean: ; QMK_HOME="$(CURDIR)/.qmk/qmk_firmware_wysteria_build" QMK_KEYBOARD=wysteria QMK_KEYMAP=razen_bodged ./qmk-build.sh clean
wysteria-bodged-qmk-flash: ; QMK_HOME="$(CURDIR)/.qmk/qmk_firmware_wysteria_build" QMK_KEYBOARD=wysteria QMK_KEYMAP=razen_bodged ./qmk-build.sh flash
klor-build: klor-zmk-build klor-qmk-build
klor-setup: klor-zmk-setup klor-qmk-setup ;
klor-clean: klor-zmk-clean klor-qmk-clean ;
klor-flash: klor-qmk-flash
klor-distclean: klor-zmk-clean klor-qmk-distclean
klor-wired: klor-qmk-build
klor-wireless: klor-zmk-build
klor-konrad-build: klor-konrad-zmk-build klor-konrad-qmk-build
klor-konrad-zmk-build: ; ZMK_OUTPUT_KEYBOARD=klor_konrad EXTRA_KEYMAP_PATH="$(CURDIR)/config/keyboards/klor/konrad.keymap" ./build.sh klor
klor-konrad-qmk-build: ; QMK_KEYBOARD=klor QMK_OUTPUT_KEYBOARD=klor_konrad QMK_MAKE_ARGS="RAZEN_KLOR_KONRAD=yes" ./qmk-build.sh build
klor-saegewerk-build: ; ZMK_OUTPUT_KEYBOARD=klor_saegewerk EXTRA_KEYMAP_PATH="$(CURDIR)/config/keyboards/klor/saegewerk.keymap" ./build.sh klor

glove80-draw: $(GLOVE80_SVG)
cradio-draw:  $(CRADIO_SVG)
aurora-draw:  $(AURORA_SVG)
totem-draw: $(TOTEM_SVG)
ansic-draw: $(ANSIC_SVG)
cygnus-draw: $(CYGNUS_SVG)
artemis-draw: $(ARTEMIS_SVG)
klotz-draw: $(KLOTZ_SVG)
lambbt-draw: $(LAMBBT_SVG)
piantor-draw: $(PIANTOR_SVG)
corne-draw: $(CORNE_SVG)
cantor_ble-draw: $(CANTOR_BLE_SVG)
lintilla-draw: $(LINTILLA_SVG)
flake-draw: $(FLAKE_SVG)
charybdis_nano-draw: $(CHARYBDIS_35_SVG) $(CHARYBDIS_36_SVG)
charybdis-draw: charybdis_nano-draw
dartyl-draw: $(DARTYL_SVG)
choctyl-draw: $(CHOCTYL_SVG)
yetis-draw: $(YETIS_SVG)
wysteria-draw: $(WYSTERIA_SVG)
dactyl-cc-draw: $(DACTYL_CC_SVG)
klor-draw: $(KLOR_POLYDACTYL_SVG)
klor-polydactyl-draw: $(KLOR_POLYDACTYL_SVG)
klor-konrad-draw: $(KLOR_KONRAD_SVG)
klor-saegewerk-draw: $(KLOR_SAEGEWERK_SVG)

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

$(FLAKE_PHYSICAL_LAYOUT):
	mkdir -p $(dir $@) && curl -sL https://raw.githubusercontent.com/hailee0710/flake-zmk-module/main/boards/shields/anywhy_flake/anywhy_flake.dtsi -o $@

SHARED_KEYMAP := config/base.keymap keymap/adaptive_swaps.toml $(wildcard config/includes/*.dtsi config/includes/layers/*.dtsi config/includes/generated/*.dtsi)
QMK_DRAW_DEPS := scripts/render_qmk_draw.py qmk/scripts/generate_keymap.py keymap/model.json keymap/profiles.json $(SHARED_KEYMAP)

# ─── Draw pipelines ─────────────────────────────────────────────────
$(GLOVE80_YAML): $(GLOVE80_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(GLOVE80_LABELS)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(GLOVE80_LAYERS)

$(GLOVE80_SVG): $(GLOVE80_YAML) $(CONF)
	keymap -c $(CONF) draw $< -z $(GLOVE80_KEYBOARD) > $@

define ZMK_DRAW_34KEY_RULE
$$($(1)_YAML): $$($(1)_KEYMAP) $$(SHARED_KEYMAP) $$(CONF) $$(ZMK_HELPERS_H) $$(LABELS_36)
	./scripts/generate zmk
	keymap -c $$(CONF) parse -z $$< > $$@
	python3 draw/reorder_layers.py $$@ $$($(1)_LAYERS)

$$($(1)_SVG): $$($(1)_YAML) $$(CONF)
	keymap -c $$(CONF) draw $$< -z cradio > $$@
endef

$(eval $(call ZMK_DRAW_34KEY_RULE,CRADIO))
$(eval $(call ZMK_DRAW_34KEY_RULE,AURORA))
$(eval $(call ZMK_DRAW_34KEY_RULE,ARTEMIS))
$(eval $(call ZMK_DRAW_34KEY_RULE,KLOTZ))
$(eval $(call ZMK_DRAW_34KEY_RULE,LAMBBT))
$(eval $(call ZMK_DRAW_34KEY_RULE,PIANTOR))

$(LUNA_YAML): $(LUNA_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(LUNA_LAYERS)

$(LUNA_SVG): $(LUNA_YAML) $(CONF)
	keymap -c $(CONF) draw -n '23332+2 2+23332' $< > $@

$(TOTEM_YAML): $(TOTEM_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py --permute 0-9,20,10-19,31,21-30,32-37 $@ $(TOTEM_LAYERS)

$(TOTEM_SVG): $(TOTEM_YAML) $(CONF)
	keymap -c $(CONF) draw -n '$(TOTEM_LAYOUT)' $< > $@

$(ANSIC_YAML): $(ANSIC_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py --drop 35 $@ $(ANSIC_LAYERS)

$(ANSIC_SVG): $(ANSIC_YAML) $(CONF) $(ANSIC_INFO)
	keymap -c $(CONF) draw $< -j $(ANSIC_INFO) -l $(ANSIC_LAYOUT) > $@

$(KLOR_SAEGEWERK_YAML): $(KLOR_SAEGEWERK_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py --drop 25,26 $@ $(KLOR_SAEGEWERK_LAYERS)

$(KLOR_SAEGEWERK_SVG): $(KLOR_SAEGEWERK_YAML) $(CONF)
	keymap -c $(CONF) draw -n '$(KLOR_SAEGEWERK_LAYOUT)' $< > $@

$(CYGNUS_SVG): $(CYGNUS_YAML) $(CONF)
	keymap -c $(CONF) draw $< -k crkbd/rev1 -l LAYOUT_split_3x5_3 > $@

$(CORNE_YAML): $(CORNE_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(CORNE_LAYERS)

$(CORNE_SVG): $(CORNE_YAML) $(CONF)
	keymap -c $(CONF) draw $< -k crkbd/rev1 -l LAYOUT_split_3x5_3 > $@

$(CANTOR_BLE_YAML): $(CANTOR_BLE_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(CANTOR_BLE_LAYERS)

$(CANTOR_BLE_SVG): $(CANTOR_BLE_YAML) $(CONF)
	keymap -c $(CONF) draw -n '$(CANTOR_BLE_LAYOUT)' $< > $@

$(LINTILLA_YAML): $(LINTILLA_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py --permute 0,2-13,1,14-41 $@ $(LINTILLA_LAYERS)

$(LINTILLA_SVG): $(LINTILLA_YAML) $(CONF)
	keymap -c $(CONF) draw -n '$(LINTILLA_LAYOUT)' $< > $@

$(FLAKE_YAML): $(FLAKE_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(FLAKE_LAYERS)

$(FLAKE_SVG): $(FLAKE_YAML) $(CONF) $(FLAKE_PHYSICAL_LAYOUT)
	keymap -c $(CONF) draw $< -d $(FLAKE_PHYSICAL_LAYOUT) -l medium_layout > $@

$(CHARYBDIS_36_YAML): $(CHARYBDIS_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py $@ $(CHARYBDIS_LAYERS)

$(CHARYBDIS_36_SVG): $(CHARYBDIS_36_YAML) $(CONF)
	keymap -c $(CONF) draw -n '$(CHARYBDIS_36_LAYOUT)' $< > $@

$(CHARYBDIS_35_YAML): $(CHARYBDIS_KEYMAP) $(SHARED_KEYMAP) $(CONF) $(ZMK_HELPERS_H) $(LABELS_36)
	./scripts/generate zmk
	keymap -c $(CONF) parse -z $< > $@
	python3 draw/reorder_layers.py --drop 35 $@ $(CHARYBDIS_LAYERS)

$(CHARYBDIS_35_SVG): $(CHARYBDIS_35_YAML) $(CONF)
	keymap -c $(CONF) draw -n '$(CHARYBDIS_35_LAYOUT)' $< > $@

define QMK_DRAW_YAML_RULE
$$($(1)_YAML): $$(QMK_DRAW_DEPS) $$($(1)_INFO)
	./scripts/generate zmk
	python3 scripts/render_qmk_draw.py --repo . --profile $$($(1)_PROFILE) --out $$@
endef

$(eval $(call QMK_DRAW_YAML_RULE,DARTYL))
$(eval $(call QMK_DRAW_YAML_RULE,CHOCTYL))
$(eval $(call QMK_DRAW_YAML_RULE,YETIS))
$(eval $(call QMK_DRAW_YAML_RULE,WYSTERIA))
$(eval $(call QMK_DRAW_YAML_RULE,KLOR_POLYDACTYL))
$(eval $(call QMK_DRAW_YAML_RULE,KLOR_KONRAD))
$(eval $(call QMK_DRAW_YAML_RULE,CYGNUS))
$(eval $(call QMK_DRAW_YAML_RULE,DACTYL_CC))

define QMK_DRAW_SVG_FROM_INFO
$$($(1)_SVG): $$($(1)_YAML) $$(CONF) $$($(1)_INFO)
	keymap -c $$(CONF) draw $$< -j $$($(1)_INFO) -l $$($(1)_LAYOUT) > $$@
endef

$(eval $(call QMK_DRAW_SVG_FROM_INFO,DARTYL))
$(eval $(call QMK_DRAW_SVG_FROM_INFO,CHOCTYL))
$(eval $(call QMK_DRAW_SVG_FROM_INFO,YETIS))
$(eval $(call QMK_DRAW_SVG_FROM_INFO,WYSTERIA))
$(eval $(call QMK_DRAW_SVG_FROM_INFO,DACTYL_CC))

$(KLOR_POLYDACTYL_SVG): $(KLOR_POLYDACTYL_YAML) $(CONF)
	keymap -c $(CONF) draw -n '$(KLOR_POLYDACTYL_NOTATION)' $< > $@

$(KLOR_KONRAD_SVG): $(KLOR_KONRAD_YAML) $(CONF)
	keymap -c $(CONF) draw -n '$(KLOR_KONRAD_NOTATION)' $< > $@

# ─── Clean ──────────────────────────────────────────────────────────
clean: luna-clean glove80-clean cradio-clean aurora-clean piantor-clean corne-clean cygnus-clean artemis-clean ansic-clean klotz-clean lambbt-clean lintilla-clean adept-clean totem-clean cantor_ble-clean yetis-clean wysteria-clean klor-clean dartyl-clean choctyl-clean dactyl-cc-clean charybdis_nano-clean flake-clean
	rm -rf .cache
