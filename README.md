# README

The script `pd` generates the entire site from
- The directory `mark/`, assumed to contain

```
mark/
 |- about/  (empty dir)
 |
 |- contact/  (empty dir)
 |
 `- posts/
     |- 2020-01-01/
     |   `- index.md  (markdown generating post)
     |
     |- 2020-01-02/
     |   `- index.md
     ...
```

- The directory `tmpl/`, assumed to contain the templates
  - `banner.html`
  - `footer.html`
  - `home.md` - template for home-page source
  - `about.md` - etc.
  - `contact.md`
  - `posts.md`


The script generates html-files in the folder `site/` with the same folder structure as `mark/`. This folder is ready to be pushed to the server.

Additionally, a second folder, `test/`, is generated, with all paths replaced with absolute ones for easier local navigation.

The names of the post-folders in `mark/posts/` must all be dates, and this date must match the one in the meta-block of the markdown file `index.md` contained inside. If the two dates are different an error message will be printed and the post will be pruned from the `site/posts/` folder. It will still be left in the `test/posts/` folder, however (draft mode).

