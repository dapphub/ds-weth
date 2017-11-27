templates = $(wildcard src/*.sol.in)
generated = $(templates:%.sol.in=%.gen.sol)
sources = $(wildcard src/*) $(generated)
all: $(sources); dapp build
test: all; DAPP_SKIP_BUILD=1 dapp test
%.gen.sol: %.sol.in $(sources) $(wildcard out/*)
	dapp build; rm -rf $@
	if $< >$@; then chmod -w $@; else rm $@; exit 1; fi
