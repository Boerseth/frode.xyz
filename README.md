# frode.xyz

Contains the source files for my blog, hosted at [frode.xyz](https://frode.xyz). The source files are in `src`, and the templates in `tmpl`.
I generate it using `make`, so most of the logic is in the `Makefile`.


## Posts

Are expected to be placed in `src/posts`,
```
src/
 |- images/
 '- posts/
    '- 2000-01-01/
       '- index.md
```
with the format

```markdown
---
date: "2000-01-01"
pagetitle: "Title of post"
summary: "Summary of post"
---

Post content goes here...
```


## Images

Are expected to be placed in `src/images`, along with a markdown file containing metadata

```
src/
 |- images/
 |  '- 2000-01-01/
 |     |- pic.jpg
 |     '- index.md
 '- posts/
```

```markdown
---
date: "2000-01-01"
file: "pic.jpg"
description: "Description of image"
---
```

Anything after the metadata block is ignored (for now...)


## Generation

Most files are either converted from Markdown into HTML using `pandoc` and placed in `build/`, or copied over directly (e.g. images).

More logic is needed to generate the index-pages, showing an overview of posts or images in chronological order:
- Metadata is collected and sorted using the tool `yq`, and placed in `meta/`
- This in turn is used by `pandoc` to generate HTML placed in `build/`
