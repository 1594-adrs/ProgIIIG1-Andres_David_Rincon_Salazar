#!/bin/sh
# Regenerates the SLD trees of the report (run from this folder).
# Requires SWI-Prolog with the sldnfdraw pack: ?- pack_install(sldnfdraw).
# sldnfdraw/1 builds the whole tree (depth limit high enough so that terms
# are not abbreviated); sld2forest.py draws it with forest and cuts it.
#   name                  generation depth   levels drawn
set -e
gen() {
    swipl -q -g "set_depth($2),draw_goal(\"$1.tmp\")" -t halt "$1-sld.pl"
    python sld2forest.py "$1.tmp" "../$1-arbol.tex" $3
    rm "$1.tmp"
}
gen pto01          300  8
gen pto02          300  10
gen pto03-seguro   300
gen pto03-ingenuo  24   13
