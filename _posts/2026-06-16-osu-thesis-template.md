---
layout: single
classes: wide
title: "Quarto template for OSU thesis!"
date: "June 2026"
categories: "Software"
toc: true
---

Writing a thesis is hard enough without wrestling with Word styles or LaTeX preambles. To make the formatting part easier, I built a [Quarto](https://quarto.org) custom format extension (extension `osu`) that handles OSU thesis formatting automatically for both PDF and Microsoft Word output. 

## What it does

The template takes care of the formatting requirements so you can focus on the science:

- **Title page, abstract, and front matter** generated from simple YAML fields (advisor name, degree, department, etc.)
- **Table of contents, list of figures, and list of tables** inserted automatically in the correct order
- [**OSU College of Forestry color scheme**](https://cf.forestry.oregonstate.edu/sites/default/files/Style%20Guide_September2019.pdf) applied to hyperlinks, inline code, and code blocks.
- **Chapter-level figure and table numbering** (e.g., Figure 2.3, Table A.1)
- **Appendix support** with a separate list of appendices, list of appendix figures, and list of appendix tables — generated automatically when your appendices are substantial enough to warrant them (**PDF output only**).
- **Per-chapter bibliographies** for manuscript-style theses, in both PDF and Word output

### Output formats

Both formats use the same source `.qmd` files — no duplicating content.

- **PDF** (`osu-pdf`) uses LaTeX under the hood with `biblatex` for citations, giving precise control over spacing, page layout, and appendix list infrastructure.

- **Microsoft Word** (`osu-docx`) uses a reference `.docx` for styles and a set of Lua filters to reconstruct front matter, per-chapter reference sections, and colored citation links in OpenXML.


## Installation

```bash
quarto use template CoF-Stats/osu
```

This installs the extension and creates a starter `.qmd` file along with the suggested directory structure. Most of your writing goes in `_chapters/`, organized by chapter, with the main document acting as a stitching file that provides front-matter metadata.

```
your-thesis/
├── your_thesis.qmd          # YAML front matter + chapter includes
├── references.bib
├── _variables.yml           # project-wide variables (advisor, department, etc.)
├── _chapters/
│   ├── chapter1/
│   ├── chapter2/
│   └── appendices/
└── _extensions/osu/         # installed by quarto use template
```

## Why use Quarto for my thesis?

- Highest standards of reproducible science. Every step can be version controlled, documented, and reproduced using Quarto and GitHub.

- No more *Figure XX*. Figure and table numbering is done automatically so you don't need to go back through and update numbers.

- No more editing tables by hand as numbers change with new analyses. R, Python, or Julia code blocks compute the values and drop them directly into the final document.

- Templates reduce the amount of time spent formatting, allowing you to write in simple markdown blocks that get formatted behind the scenes.


## Source

The extension is open source and hosted at [github.com/CoF-Stats/osu-thesis-template](https://github.com/CoF-Stats/osu-thesis-template). Issues and pull requests welcome.
