TITLE = frode.xyz
TEMP = template.html
PANDOC = pandoc --template $(TEMP) --metadata title=$(TITLE) --mathml -f markdown+raw_html -t html5

WORK_BASE = build meta
WORK_SUB = images posts
WORKSPACE = $(foreach base, $(WORK_BASE), $(foreach sub, $(WORK_SUB), $(base)/$(sub)))

INDEX_SOURCE = src/index.md
ABOUT_SOURCE = src/about/index.md
POSTS_SOURCES = $(shell find src/posts -type f -name "*.md" | sort --reverse)
MD_SOURCES = $(INDEX_SOURCE) $(ABOUT_SOURCE) $(POSTS_SOURCES)
OTHER_SOURCES = $(shell find src/posts -type f -not -name "*.md")
IMAGES_SOURCES = $(shell find src/images -mindepth 1 -type f | sort --reverse)

POSTS_METADATA_FILES = $(POSTS_SOURCES:src/posts/%.md=meta/posts/%.yaml)
IMAGES_METADATA_FILES = $(IMAGES_SOURCES:src/images/%=meta/images/%.yaml)

HTML_TARGETS = $(MD_SOURCES:src/%.md=build/%.html)
OTHER_TARGETS = $(OTHER_SOURCES:src/%=build/%)
POSTS_TARGET = build/posts/index.html
IMAGES_TARGET = build/images/index.html


# DEFAULT

all: $(WORKSPACE) $(OTHER_TARGETS) $(HTML_TARGETS) $(IMAGES_TARGET) $(POSTS_TARGET)

$(WORKSPACE):
	@mkdir -p $@

serve: all
	@cd build && python3 -m http.server 1234

.PHONY: clean
clean: $(WORK_BASE)
	@rm -rf $^


# METADATA

$(POSTS_METADATA_FILES): meta/%index.yaml: src/%index.md
	@echo $@
	@yq e '.date and .header and .summary' --exit-status --front-matter extract $< > /dev/null
	@mkdir -p $(@D)
	@yq e '[{"path": "/$*"} * .]' --front-matter extract $< > $@

meta/posts.yaml: $(POSTS_METADATA_FILES)
	@echo $@
	@cat $^ | yq eval '{"posts": .}' > $@

$(IMAGES_METADATA_FILES): meta/images/%.yaml: src/images/%
	@echo $@
	@echo "- {'name': '$*', 'path': '/images/$*'}" > $@

meta/images.yaml: $(IMAGES_METADATA_FILES)
	@echo $@
	@cat $^ | yq eval '{"images": .}' > $@


# BUILD

$(POSTS_TARGET) $(IMAGES_TARGET): build/%/index.html: meta/%.yaml $(TEMP)
	@echo $@
	@echo "" | $(PANDOC) --metadata-file=$< > $@

$(HTML_TARGETS): build/%.html: src/%.md $(TEMP)
	@echo $@
	@mkdir -p $(@D)
	@$(PANDOC) -i $< > $@

$(OTHER_TARGETS): build/%: src/%
	@echo $@
	@mkdir -p $(@D)
	@cp $< $@
