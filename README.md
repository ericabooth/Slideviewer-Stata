# slideviewer for Stata

**Interactive navigation engine for SMCL-based slides, presentations, and tutorials.**

[![Stata Version](https://img.shields.io/badge/Stata-16+-blue.svg)](https://www.stata.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🚀 Overview

`slideviewer` is a powerful navigation tool designed to turn a collection of [SMCL](https://www.stata.com/help.cgi?smcl) files into a professional, interactive presentation or tutorial directly within the Stata Viewer window. 

Version 2.0 (current release 2.0.2) is optimized for Stata 16+ and introduces intelligent sequencing, persistent state management, and a dynamic navigation bar—eliminating the need to manually hard-code "Next" and "Previous" links in every individual slide.

---

## ✨ Key Features

- **Automatic Sequencing:** Navigate through your slide deck alphabetically using the `next`, `prev`, `first`, and `last` keywords.
- **Dynamic Navigation Bar:** Inject an interactive header and footer (`[First] [Prev] [TOC] [Next] [Last]`) into any slide automatically with the `navbar` option.
- **Auto-Generated TOC:** Instantly create a clickable Table of Contents of all `.smcl` files in your project directory using `slideviewer toc`.
- **Persistent State:** Set your project subdirectory once, and `slideviewer` remembers it across your entire Stata session.
- **UTF-8 Ready:** Full support for modern Stata character encoding.

---

## 🛠️ Installation

Install from GitHub in Stata:

```stata
net install slideviewer, from("https://raw.githubusercontent.com/ericabooth/Slideviewer-Stata/main/") replace force
discard
which slideviewer
help slideviewer
```

The repository ships `slideviewer.pkg` and `stata.toc`, so the command and its
help file arrive in one call. To install by hand instead, copy `slideviewer.ado`
and `slideviewer.sthlp` into your PLUS or PERSONAL ado folder.

---

## 📖 Minimum Working Example (MWE)

### 1. Organize your slides
Create a folder named `myslides` and add three files: `01_intro.smcl`, `02_data.smcl`, and `03_results.smcl`.

### 2. Launch the viewer
Start your presentation and enable the interactive navigation bar:
```stata
slideviewer first, subdir("myslides") navbar
```

### 3. Navigate seamlessly
Once launched, you can move through the deck using the on-screen links or the command line:
```stata
slideviewer next
slideviewer toc
```

---

## ⚙️ Options & Keywords

### Navigation Keywords
| Keyword | Action |
| :--- | :--- |
| `next` | Moves to the alphabetically next slide. |
| `prev` | Moves to the alphabetically previous slide. |
| `first` | Jumps to the very first slide. |
| `last` | Jumps to the very last slide. |
| `toc` | Generates a clickable Table of Contents. |

Keywords are not case sensitive. A slide name is matched to the file on disk without regard to case, and the on-disk spelling is remembered, so `slideviewer results` opens `Results.smcl` and `next` continues from it.

### Options
| Option | Description |
| :--- | :--- |
| `subdir(path)` | Sets the directory containing your `.smcl` files. Quotes, spaces, and a leading `~` are fine; a folder that does not exist stops with error 601. |
| `navbar` | Injects interactive [First][Prev][TOC][Next][Last] links. |
| `post` | Stores the name of the slide just shown in `r(lastslide)` (and the global `$totalscore` in `r(totalscore)`). |
| `clear` | Resets the persistent subdirectory and current slide state. |

### Stored results
With `post`: `r(lastslide)` (the slide just shown) and `r(totalscore)` (a copy of the global `$totalscore`, empty unless your tutorial slides set it).

---

## Changelog

- **2.0.2 (9 Nov 2026):** slide names keep their case and are matched to the file on disk without regard to case, so `next`/`prev` work after opening a mixed-case slide by name and TOC links work on case-sensitive file systems. Backslashes in `subdir()` are normalized. Standard `*! version` line.
- **2.0.1 (9 Nov 2026):** a quoted `subdir("myslides")`, as in the examples, is now used as the path (before, it was reset to `./ignore`, giving r(601) or the wrong deck). A missing folder is an error instead of a silent fallback. A leading `~` is expanded. `navbar` copies slide text verbatim, so `` `v' ``, `$S_DATE`, and lines with an unbalanced `"` survive.
- **2.0 (May 2026):** Stata 16+ rewrite with keywords, TOC, and navbar.

---

## 👤 Author

**Eric A. Booth**
- 🏛️ Sr Researcher, Texas 2036
- 📧 [eric.a.booth@gmail.com](mailto:eric.a.booth@gmail.com)
- 🌐 [www.eric-booth.com](http://www.eric-booth.com)
- 💼 [GitHub Profile](https://github.com/ericabooth)

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
