#
#  Makefile
#
#  Copyright (c) 2021 by Daniel Kelley
#

.PHONY: test style

all:

test: check_style check_code

check_code:
	$(MAKE) -C test clean all

check_style:
	rubocop
