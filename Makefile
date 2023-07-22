TITLE = frode.xyz
WORKSPACE = build meta

.PHONY: default
default: all

# Metadata

METADATA = $(patsubst src/%.md, meta/%.yaml, $(shell find src/images src/posts -type f -name "index.md"))
$(METADATA): meta/%/index.yaml: src/%/index.md
	@echo $@
	@mkdir -p $(@D)
	@yq -f extract e '. | .path = "/$*"' $< > $@

meta/images/index.yaml: $(filter meta/images/%, $(METADATA))
	@echo $@
	@yq ea '. as $$i ireduce ([]; . + $$i) | sort_by(.date) | reverse | {"images": ., "pagetitle": "images"}' $^ > $@

meta/posts/index.yaml: $(filter meta/posts/%, $(METADATA))
	@echo $@
	@yq ea '. as $$i ireduce ([]; . + $$i) | sort_by(.date) | reverse | {"posts": ., "pagetitle": "posts"}' $^ > $@

meta/index.yaml: meta/images/index.yaml meta/posts/index.yaml
	@echo $@
	@yq ea 'select(fi==0) * select(fi==1) | .images |= .[:3] | .posts |= .[:3] | .isroot = 1' $^ > $@

# Targets

PANDOC = pandoc -f markdown+raw_html -t html5 --template tmpl/index.html --data-dir=./tmpl --metadata title=$(TITLE) --mathml

GENERATED_TARGETS = build/index.html build/posts/index.html build/images/index.html
$(GENERATED_TARGETS): build/%.html: meta/%.yaml tmpl/*
	@echo $@
	@mkdir -p $(@D)
	@echo "" | $(PANDOC) --metadata-file=$< -o $@

POSTS_TARGETS = $(patsubst src/%.md, build/%.html, $(shell find src/posts -type f -name "index.md"))
TRANSLATED_TARGETS = build/about/index.html $(POSTS_TARGETS)
$(TRANSLATED_TARGETS): build/%/index.html: src/%/index.md tmpl/index.html
	@echo $@
	@mkdir -p $(@D)
	@$(PANDOC) -i $< -o $@

NON_HTML_TARGETS = $(patsubst src/%, build/%, $(shell find src -type f -not -name "*.md"))
$(NON_HTML_TARGETS): build/%: src/%
	@echo $@
	@mkdir -p $(@D)
	@cp $< $@

# Development

TARGETS = $(NON_HTML_TARGETS) $(TRANSLATED_TARGETS) $(GENERATED_TARGETS)
.PHONY: all
all: $(TARGETS)

.PHONY: serve
serve: all
	@cd build && python3 -m http.server 1234

.PHONY: clean
clean: $(WORKSPACE)
	@rm -rf $^

# The below does not remove folders...
ORPHAN_METADATA = $(filter-out $(METADATA), $(shell find meta -mindepth 3 -type f))
ORPHAN_TARGETS = $(filter-out $(TARGETS), $(shell find build -type f))
.PHONY: prune
prune: $(ORPHAN_METADATA) $(ORPHAN_TARGETS)
	@echo "Pruning " $^
	@rm -rf $^
