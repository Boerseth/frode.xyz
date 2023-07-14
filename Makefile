TITLE = frode.xyz
TEMP = template.html
PANDOC = pandoc --template $(TEMP) --metadata title=$(TITLE) --mathml -f markdown+raw_html -t html5

WORK_BASE = build meta
WORK_SUB = images posts
WORKSPACE = $(foreach base, $(WORK_BASE), $(foreach sub, $(WORK_SUB), $(base)/$(sub)))

MD_SOURCES = $(shell find src -type f -name "*.md")
OTHER_SOURCES = $(shell find src -type f -not -name "*.md")
POSTS_SOURCES = $(shell find src/posts -type f -name "*.md" | sort --reverse)
IMAGES_SOURCES = $(shell find src/images -mindepth 1 -type f | sort --reverse)

POSTS_METADATA_FILES = $(POSTS_SOURCES:src/posts/%.md=meta/posts/%.yaml)
IMAGES_METADATA_FILES = $(IMAGES_SOURCES:src/images/%=meta/images/%.yaml)
POSTS_METADATA = meta/posts.yaml
IMAGES_METADATA = meta/images.yaml

HTML_TARGETS = $(MD_SOURCES:src/%.md=build/%.html)
OTHER_TARGETS = $(OTHER_SOURCES:src/%=build/%)
POSTS_TARGET = build/posts/index.html
IMAGES_TARGET = build/images/index.html


# DEFAULT


all: $(WORKSPACE) $(OTHER_TARGETS) $(HTML_TARGETS) $(IMAGES_TARGET) $(POSTS_TARGET)

$(WORKSPACE):
	@echo $@
	@mkdir -p $@


# METADATA prep


$(POSTS_METADATA_FILES): meta/%index.yaml: src/%index.md
	@echo $@
	@if ! head "$<" -n 1 | grep "^---$$" > /dev/null; then exit 1; fi
	@if ! head "$<" -n 4 | grep "^date: \".*\"$$" > /dev/null; then exit 1; fi
	@if ! head "$<" -n 4 | grep "^header: \".*\"$$" > /dev/null; then exit 1; fi
	@if ! head "$<" -n 4 | grep "^summary: \".*\"$$" > /dev/null; then exit 1; fi
	@if ! head "$<" -n 5 | grep "^...$$" > /dev/null; then exit 1; fi
	@mkdir -p $(@D)
	@echo "-" > $@
	@echo "  path: '/$*'" >> $@
	@head -n 4 $< | tail -n 3 | sed 's|^|  |' >> $@

$(POSTS_METADATA): $(POSTS_METADATA_FILES)
	@echo $@
	@(echo 'posts:'; cat $^) > $@

$(IMAGES_METADATA_FILES): meta/images/%.yaml: src/images/%
	@echo $@
	@echo "- {'name': '$*', 'path': '/images/$*'}" > $@

$(IMAGES_METADATA): $(IMAGES_METADATA_FILES)
	@echo $@
	@echo 'images:' > $@
	@if [ "$^" != "" ]; then cat $^ >> $@; fi


# HTML generation


$(POSTS_TARGET) $(IMAGES_TARGET): build/%/index.html: meta/%.yaml $(TEMP)
	@echo $@
	@echo "" | $(PANDOC) --metadata-file=$< > $@

$(HTML_TARGETS): build/%.html: src/%.md $(TEMP)
	@echo $@
	@mkdir -p $(@D)
	@$(PANDOC) -i $< > $@


# COPY other files


$(OTHER_TARGETS): build/%: src/%
	@echo $@
	@mkdir -p $(@D)
	@cp $< $@


# MISC.


.PHONY: clean
clean:
	@rm -rf build meta

serve:
	@cd build && python3 -m http.server 1234
