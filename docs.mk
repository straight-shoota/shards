ASCIIDOC ?= asciidoctor

ASCIIDOC_OPTIONS = -a shards_version=$(SHARDS_VERSION)

MAN_FILES := man/shards.1 man/shard.yml.5
HTML_FILES := docs/shards.html docs/shard.yml.html

SHARDS_VERSION := $(shell cat VERSION)

docs: manpages

manpages: $(MAN_FILES)

htmlpages: $(HTML_FILES)

man/%.1 man/%.5: docs/%.adoc
	SOURCE_DATE_EPOCH=$(shell (git log -1 --format="%at" -- $< || stat -c "%Y" $<)) $(ASCIIDOC) $(ASCIIDOC_OPTIONS) $< -b manpage -o $@

docs/%.html: docs/%.adoc
	SOURCE_DATE_EPOCH=$(shell (git log -1 --format="%at" -- $< || stat -c "%Y" $<)) $(ASCIIDOC) $(ASCIIDOC_OPTIONS) $< -b html5 -o $@

clean_docs: phony
	rm -f $(MAN_FILES)
	rm -rf docs/*.html

phony:
