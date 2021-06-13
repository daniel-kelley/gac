#
#  Makefile
#
#  Copyright (c) 2021 by Daniel Kelley
#

.PHONY: test style

all:

test: style
	$(MAKE) -C test clean all

style:
	rubocop
