#
#  Makefile
#
#  Copyright (c) 2021 by Daniel Kelley
#

FAUST := faust
FAUST_COMMON := -I ../lib
FAUST_FLAGS := -lang c -svg $(FAUST_COMMON)

OUTPUT := clock.c
OUTPUT += clock_ui
OUTPUT += edge_ui
OUTPUT += oneshot_ui
OUTPUT += ar_ui
OUTPUT += osc_ui
OUTPUT += seq_ui
OUTPUT += bp_ui
OUTPUT += seq_panel
OUTPUT += tabgroup
OUTPUT += p0
STUFF := $(OUTPUT)

all: $(OUTPUT)

clock.c: clock.dsp ../lib/gac.lib
	$(FAUST) $(FAUST_FLAGS) $< > $@ || rm -rf $@

clock_ui: clock_ui.dsp ../lib/gac.lib
	faust2jaqt $(FAUST_COMMON) $<

edge_ui: edge_ui.dsp ../lib/gac.lib
	faust2jaqt $(FAUST_COMMON) $<

oneshot_ui: oneshot_ui.dsp ../lib/gac.lib
	faust2jaqt $(FAUST_COMMON) $<

ar_ui: ar_ui.dsp ../lib/gac.lib
	faust2jaqt $(FAUST_COMMON) $<

osc_ui: osc_ui.dsp ../lib/gac.lib
	faust2jaqt $(FAUST_COMMON) $<

seq_ui: seq_ui.dsp ../lib/gac.lib
	faust2jaqt $(FAUST_COMMON) -osc $<

bp_ui: bp_ui.dsp
	faust2jaqt $(FAUST_COMMON) $<

seq_panel: seq_panel.dsp ../lib/gac.lib
	faust2jaqt -osc -svg $(FAUST_COMMON) $<

tabgroup: tabgroup.dsp
	faust2jaqt $(FAUST_COMMON) $<

p0: p0.dsp
	faust2jaqt -osc -json $(FAUST_COMMON) $<

p0.dsp: ../example/p0.yml
	../bin/panel $< > $@

test:
	ruby test_gac.rb $(TEST_ARG)

clean:
	-rm -rf $(STUFF) *-svg faust.* p0.dsp test_gac_*

