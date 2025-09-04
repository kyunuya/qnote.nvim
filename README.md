# qnote.nvim
This is a global note taking plugin for Neovim, aiming to help you quickly create, delete, read, and edit notes from a single central directory.

## Features
- [x] **Open Note:** Toggle floating notepad from any neovim file
- [x] **Create Note:** Create multiple notes
- [x] **Select Note:** Use the note selector to view and open notes in the note store

## Installation
**lazy.nvim**
``` lua
return {
  "kyunuya/qnote.nvim",
  opts = { directory = "absolute/path/to/note/store" -- creates dir if doesn't exist, defaults to "~/qnotes" },
}
```
