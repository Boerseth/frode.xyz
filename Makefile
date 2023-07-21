TITLE = frode.xyz
WORKSPACE = build meta

.PHONY: default
default: all

# Trivial

NON_HTML_TARGETS = $(patsubst src/%, build/%, $(shell find src -type f -not -name "*.md"))
$(NON_HTML_TARGETS): build/%: src/%
	@echo $@
	@mkdir -p $(@D)
	@cp $< $@

# Metadata

IMAGES_METADATA_FILES = $(patsubst src/images/%, meta/images/%.yaml, $(wildcard src/images/*))
$(IMAGES_METADATA_FILES): meta/images/%.yaml: src/images/%
	@echo $@
	@mkdir -p $(@D)
	@echo '- {"path": "/images/$*", "date": "$*"}' > $@

POSTS_METADATA_FILES = $(patsubst src/posts/%index.md, meta/posts/%index.yaml, $(shell find src/posts -type f -name "*.md"))
$(POSTS_METADATA_FILES): meta/posts/%index.yaml: src/posts/%index.md
	@echo $@
	@yq -f=extract --exit-status e '.date and .pagetitle and .summary' $< > /dev/null
	@mkdir -p $(@D)
	@yq -f=extract e '[{"path": "/posts/$*"} * .]' $< > $@

meta/images/index.yaml: $(IMAGES_METADATA_FILES)
	@echo $@
	@cat $^ | yq e '{"pagetitle": "images", "images": . | sort_by(.date) | reverse}' > $@

meta/posts/index.yaml: $(POSTS_METADATA_FILES)
	@echo $@
	@cat $^ | yq e '{"pagetitle": "posts", "posts": . | sort_by(.date) | reverse}' > $@

meta/index.yaml: meta/images/index.yaml meta/posts/index.yaml
	@echo $@
	@yq ea 'select(fi==0) * select(fi==1) | .images = .images.[:3] | .posts = .posts.[:3] | .isroot = true' $^ > $@

# HTML

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

# Development

.PHONY: all
all: $(NON_HTML_TARGETS) $(TRANSLATED_TARGETS) $(GENERATED_TARGETS)

.PHONY: serve
serve: all
	@cd build && python3 -m http.server 1234

.PHONY: clean
clean: $(WORKSPACE)
	@rm -rf $^
