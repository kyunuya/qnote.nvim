# qnote.nvim
This is a global notepad plugin for Neovim, to quickly create, delete, read, and edit notes no matter where you are in neovim.

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

## Usage
```lua
:QnoteToggle  -- Open last modified note (toggles new note prompt if non exists)
:QnoteNew     -- Prompts new note input window
:QnoteList    -- Toggles list of notes
```
**:QnoteToggle**
- Opens last modified note  
- Toggles new note prompt if no last modified file exists
  
**:QnoteNew**  
- Prompts new note input window
- All notes are saved as .md
  
**:QnoteList**  
- Toggles list of notes
- `<cr>` opens selected note
- `dd` deletes selected note
