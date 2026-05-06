# slideviewer for Stata

**Interactive navigation engine for SMCL-based slides, presentations, and tutorials.**

[![Stata Version](https://img.shields.io/badge/Stata-16+-blue.svg)](https://www.stata.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🚀 Overview

`slideviewer` is a powerful navigation tool designed to turn a collection of [SMCL](https://www.stata.com/help.cgi?smcl) files into a professional, interactive presentation or tutorial directly within the Stata Viewer window. 

Version 2.0 is optimized for Stata 16+ and introduces intelligent sequencing, persistent state management, and a dynamic navigation bar—eliminating the need to manually hard-code "Next" and "Previous" links in every individual slide.

---

## ✨ Key Features

- **Automatic Sequencing:** Navigate through your slide deck alphabetically using the `next`, `prev`, `first`, and `last` keywords.
- **Dynamic Navigation Bar:** Inject an interactive header and footer (`[First] [Prev] [TOC] [Next] [Last]`) into any slide automatically with the `navbar` option.
- **Auto-Generated TOC:** Instantly create a clickable Table of Contents of all `.smcl` files in your project directory using `slideviewer toc`.
- **Persistent State:** Set your project subdirectory once, and `slideviewer` remembers it across your entire Stata session.
- **UTF-8 Ready:** Full support for modern Stata character encoding.

---

## 🛠️ Installation

Clone this repository or place `slideviewer.ado` and `slideviewer.sthlp` in your Stata `personal/s/` folder.

```stata
* Manual Installation:
* Copy slideviewer.ado and slideviewer.sthlp to your PLUS or PERSONAL ado folder.
```

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

### Options
| Option | Description |
| :--- | :--- |
| `subdir(path)` | Sets the directory containing your `.smcl` files. |
| `navbar` | Injects interactive [First][Prev][TOC][Next][Last] links. |
| `clear` | Resets the persistent subdirectory and current slide state. |

---

## 👤 Author

**Eric A. Booth**
- 📧 [eric.a.booth@gmail.com](mailto:eric.a.booth@gmail.com)
- 🌐 [www.eric-booth.com](http://www.eric-booth.com)
- 💼 [GitHub Profile](https://github.com/ericabooth)

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
