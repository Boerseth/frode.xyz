TITLE = frode.xyz
TEMPLATE = tmpl/index.html
TEMPLATES = $(wildcard tmpl/*)
PANDOC = pandoc -f markdown+raw_html -t html5 --template $(TEMPLATE) --data-dir=./tmpl --metadata title=$(TITLE) --mathml


default: all


# TRIVIAL ===================

WORKSPACE = build build/images build/posts meta meta/images meta/posts
$(WORKSPACE):
	@mkdir -p $@

NON_MARKDOWN_SOURCES = $(shell find src -type f -not -name "*.md")
NON_HTML_TARGETS = $(NON_MARKDOWN_SOURCES:src/%=build/%)
$(NON_HTML_TARGETS): build/%: src/%
	@echo $@
	@mkdir -p $(@D)
	@cp $< $@


# METADATA ====================

IMAGES_METADATA_FILES = $(patsubst src/images/%, meta/images/%.yaml, $(wildcard src/images/*))
$(IMAGES_METADATA_FILES): meta/images/%.yaml: src/images/%
	@echo $@
	@mkdir -p $(@D)
	@echo '- {"path": "/images/$*", "date": "$*"}' > $@

POSTS_METADATA_FILES = $(patsubst src/posts/%index.md, meta/posts/%index.yaml, $(shell find src/posts -type f -name "*.md"))
$(POSTS_METADATA_FILES): meta/posts/%index.yaml: src/posts/%index.md
	@echo $@
	@mkdir -p $(@D)
	@yq e '.date and .pagetitle and .summary' --exit-status --front-matter extract $< > /dev/null
	@yq e '[{"path": "/posts/$*"} * .]' --front-matter extract $< > $@

meta/images/index.yaml: $(IMAGES_METADATA_FILES)
	@cat $^ | yq eval '{"pagetitle": "images", "images": . | sort_by(.date) | reverse}' > $@

meta/posts/index.yaml: $(POSTS_METADATA_FILES)
	@cat $^ | yq eval '{"pagetitle": "posts", "posts": . | sort_by(.date) | reverse}' > $@

meta/index.yaml: meta/images/index.yaml meta/posts/index.yaml
	@echo $@
	@yq ea 'select(fi==0) * select(fi==1) | .images = .images.[:3] | .posts = .posts.[:3] | .isroot = true' $^ > $@


# HTML ======================

ROOT_HTML_TARGET = build/index.html
POSTS_HTML_TARGET = build/posts/index.html
IMAGES_HTML_TARGET = build/images/index.html

GENERATED_TARGETS = $(ROOT_HTML_TARGET) $(POSTS_HTML_TARGET) $(IMAGES_HTML_TARGET)
$(GENERATED_TARGETS): build/%.html: meta/%.yaml $(TEMPLATES)
	@echo $@
	@echo "" | $(PANDOC) --metadata-file=$< -o $@

HTML_TARGETS = $(patsubst src/%.md, build/%.html, $(shell find src -type f -name "*.md"))
$(HTML_TARGETS): build/%.html: src/%.md $(TEMPLATE)
	@echo $@
	@mkdir -p $(@D)
	@$(PANDOC) -i $< -o $@


# DEV ===================

.PHONY: all
all: $(WORKSPACE) $(NON_HTML_TARGETS) $(HTML_TARGETS) $(GENERATED_TARGETS)

.PHONY: serve
serve: all
	@cd build && python3 -m http.server 1234

.PHONY: clean
clean: $(WORKSPACE)
	@rm -rf $^
