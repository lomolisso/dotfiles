# Helix cheat sheet

F1 opens this file; `:bc` (or Space b, then another file) gets you back.
Read-only, so it can't be changed by accident.

## How helix thinks

- **Select, then act.** `w` selects the next word, then `d` deletes it.
  (Vim is the other way round: `dw`.) What's selected is highlighted.
- **Menus appear by themselves.** Press `Space`, `g`, `m`, `z`, `[`, `]` or
  `Ctrl-w` and wait: a popup lists every key that can follow.
- **Everything else:** `Space ?` lists every command with its key; type to search.
- `:tutor` is a 15-minute hands-on tutorial. Worth doing once.

## Modes

| Key | Does |
|---|---|
| `Esc` | back to normal mode (moving and commands) |
| `i` / `a` | insert before / after the selection |
| `I` / `A` | insert at the start / end of the line |
| `o` / `O` | new line below / above, in insert mode |
| `v` | select mode: moves extend the selection (`Esc` leaves) |
| `:` | command mode: type a command, `Enter` runs it |

The mode is shown at the bottom left (NOR / INS / SEL).

## Saving and quitting

| Key | Does |
|---|---|
| `Ctrl-s` or `:w` | save |
| `:q` | close the window (quits helix if it's the last one) |
| `:wq` | save and quit |
| `:q!` | quit without saving |
| `:qa` / `:wqa` | quit everything / save everything and quit |
| `:bc` | close the current file, keep helix open |
| `:reload` | throw away changes, reload from disk |

## Moving around a file

| Key | Does |
|---|---|
| `h` `j` `k` `l` or arrows | left, down, up, right |
| `w` / `b` / `e` | next word / previous word / end of word |
| `W` `B` `E` | same, but words are anything between spaces |
| `gh` / `gl` / `gs` | start of line / end of line / first character of line |
| `gg` / `ge` | top / bottom of the file |
| `42G` or `:42` | line 42 |
| `Ctrl-d` / `Ctrl-u` | half a page down / up |
| `f` + char / `t` + char | jump to / just before the next char on the line (`F`, `T` backward) |
| `mm` | matching bracket |
| `gw` | labels appear on every word; type one to jump there |
| `zz` | scroll so the cursor is in the middle |
| `Ctrl-o` / `Ctrl-i` | jump back / forward (like a browser) |

## Selecting

| Key | Does |
|---|---|
| `x` | select the line (again: the next line too) |
| `%` | select the whole file |
| `mi(` / `ma(` | inside / around the parentheses (also `"` `[` `{` `w` word `f` function) |
| `;` | shrink the selection to just the cursor |
| `Alt-o` / `Alt-i` | grow / shrink the selection along the code's structure |

## Editing

| Key | Does |
|---|---|
| `d` / `c` | delete / delete and type (change) the selection |
| `y` / `p` / `P` | copy / paste after / paste before (inside helix) |
| `Space y` / `Space p` | copy to / paste from the system clipboard |
| `u` / `U` | undo / redo |
| `r` + char | replace the selection with that char |
| `>` / `<` | indent / unindent |
| `Ctrl-c` | comment / uncomment |
| `J` | join the selected lines |
| `~` | switch upper/lower case |
| `.` | repeat the last edit |

## Searching

| Key | Does |
|---|---|
| `/` / `?` | search forward / backward in the file (`Enter` to confirm) |
| `n` / `N` | next / previous match |
| `*` | search for the selected text (then `n`) |
| `Space /` | search the whole project; `Enter` opens the match |
| `%` `s` text `Enter` | select every "text" in the file: one cursor each, edit all at once |
| `C` | add a cursor on the next line |
| `,` | back to one cursor |

## The project

| Key | Does |
|---|---|
| `Space e` | file explorer at the project root (`Space E`: at this file's folder) |
| `Space f` | find a file by name |
| `Space b` | switch between open files |
| `gn` / `gp` | next / previous open file |
| `ga` | the file you were in before |
| `Space g` | files changed since the last git commit |
| `Space j` | everywhere you jumped from |
| `:open path` | open or create a file |

In any of these lists: type to filter, arrows or `Ctrl-n`/`Ctrl-p` to move,
`Enter` to open, `Ctrl-v` to open beside the current file, `Esc` to close.

## Code (needs the language's server, see `hx --health`)

| Key | Does |
|---|---|
| `gd` / `gr` | go to definition / list references |
| `gy` / `gi` | go to type definition / implementation |
| `Space k` | documentation for what's under the cursor |
| `Space r` | rename everywhere |
| `Space a` | quick fixes (code actions) |
| `Space s` / `Space S` | symbols (functions, classes) in this file / project |
| `Space d` / `Space D` | errors and warnings in this file / project |
| `]d` / `[d` | next / previous error or warning |
| `]f` / `[f` | next / previous function |
| `:fmt` | format the file (also done on save if the language has a formatter) |

While typing, suggestions pop up: `Tab` / `Shift-Tab` to choose, `Enter` to accept.

## Splits

| Key | Does |
|---|---|
| `Ctrl-w v` / `Ctrl-w s` | split side by side / top and bottom |
| `Ctrl-w h` `j` `k` `l` | move to the split on that side |
| `Ctrl-w q` / `Ctrl-w o` | close this split / close all others |

## Shell

- `Ctrl-z` pauses helix and drops to the shell; `fg` comes back.
- `:sh cmd` runs a shell command and shows its output.
- `|` then a command pipes the selection through it, e.g. `|sort` sorts the lines.
