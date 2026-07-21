_default:
    @just --list

all:
    @python3 scripts/keyboard.py build all
    @python3 scripts/keyboard.py draw all

build target backend='default':
    @python3 scripts/keyboard.py build '{{ target }}' --backend '{{ backend }}'

setup target backend='default':
    @python3 scripts/keyboard.py setup '{{ target }}' --backend '{{ backend }}'

draw target='all':
    @python3 scripts/keyboard.py draw '{{ target }}'

clean target='generated' backend='default':
    @python3 scripts/keyboard.py clean '{{ target }}' --backend '{{ backend }}'

left target:
    @python3 scripts/keyboard.py left '{{ target }}'

right target:
    @python3 scripts/keyboard.py right '{{ target }}'

reset target:
    @python3 scripts/keyboard.py reset '{{ target }}'

flash target:
    @python3 scripts/keyboard.py flash '{{ target }}'

distclean target:
    @python3 scripts/keyboard.py distclean '{{ target }}'

zmk target action='both':
    @python3 scripts/keyboard.py zmk '{{ target }}' '{{ action }}'

qmk target action='build':
    @python3 scripts/keyboard.py qmk '{{ target }}' '{{ action }}'

generate:
    @./scripts/generate all

render backend profile os='linux':
    @./scripts/generate '{{ backend }}' --profile '{{ profile }}' --os '{{ os }}'

check:
    @./scripts/generate check

profiles:
    @./scripts/generate profiles

targets:
    @python3 scripts/keyboard.py targets
