# frode.xyz

Contains the source files for my blog, hosted at [frode.xyz](https://frode.xyz). The source files are in `src`, and the templates in `tmpl`.

## Prerequisits

- I generate it using `make`, so most of the logic is in the `Makefile`.
- Files are generated using `pandoc`.
- Metadata is managed using `yq`.


## Structure

The folders and their contents:
```
├── Makefile
├── README.md
├── src
│   ├── favicon.ico
│   ├── styles.css
│   ├── about
│   │   └── index.md
│   ├── images
│   │   └── 2000-01-01
│   │       ├── pic1.jpg
│   │       └── index.md
│   └── posts
│       └── 2000-01-01
│           └── index.md
├── tmpl
|   └── ...
├── meta
|   └── ...
└── build
    └── ...
```
- `src/` contains the editable source files of the blog
- `tmpl/` contains the template files needed to generate the blog
- `meta/` (generated by `make`) contains metadata about posts/images, collected in order to create index pages
- `build/` (generated by `make`) contains the finished blog, ready to be served

In `src/images/` are located folders, each containing one image and one `index.md` with metadata:
```markdown
---
date: "2000-01-01"
file: "pic.jpg"
description: "Description of image"
---
```
Anything after the metadata block is ignored (for now...)

In `src/posts/` are located folders, each containing at least one `index.md` with a metadata block:
```markdown
---
date: "2000-01-01"
pagetitle: "Title of post"
summary: "Summary of post"
---

Post content goes here...
```
