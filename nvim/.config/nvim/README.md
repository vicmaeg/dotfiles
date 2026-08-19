# Neovim config

Neovim config (0.12+) managed with the built-in `vim.pack` plugin manager. No
plugin-manager wrapper, no mason: native LSP, mini.nvim UI modules, and a small
set of focused plugins.

## Overview

- **Leader**: `<Space>`
- **Colorscheme**: `retrobox`
- **Plugins**: `vim.pack` + lockfile (`nvim-pack-lock.json`)
- **LSP**: native `vim.lsp` (`lua_ls`; C#/Roslyn via easy-dotnet)
- **Completion**: mini.completion + native cmdline autocompletion
- **Git**: fugitive (status/blame) + mini.diff (hunk signs) + diffs.nvim
- **Pickers**: fzf-lua (primary) and mini.pick (fallback)

## Plugins

| Plugin | Role |
|--------|------|
| `nvim-mini/mini.nvim` | icons, ai, surround, completion, diff, jump, jump2d, pick, statusline, files |
| `tpope/vim-fugitive` | Git client (`:Git`, blame, etc.) |
| `ibhagwan/fzf-lua` | Files / live grep / buffers (ivy layout) |
| `barrettruth/diffs.nvim` | Diff views (Fugitive integration) |
| `nvim-orgmode/orgmode` | Org files and agenda (`~/org`) |
| `nvim-treesitter/nvim-treesitter` (`main`) | Highlighting + indent |
| `GustavEikaas/easy-dotnet.nvim` | .NET: Roslyn LSP, tests, build/run, debug bootstrap |
| `mfussenegger/nvim-dap` | Debug adapter protocol client |
| `rcarriga/nvim-dap-ui` (+ `nvim-neotest/nvim-nio`) | Debug UI |
| `nvim-lua/plenary.nvim` | Lua library (easy-dotnet dependency) |

Manage plugins with `:lua vim.pack.update()` (review the update buffer, `:w` to
confirm) and `:lua vim.pack.del({ "name" })`. Offline inspect:
`:lua vim.pack.update(nil, { offline = true })`. Commit `nvim-pack-lock.json`
for reproducible setups.

## Structure

```
init.lua                -- leader, vim.loader, module load order
lsp/
  lua_ls.lua            -- Lua language server config
  easy_dotnet.lua       -- C# (Roslyn) settings; server started by easy-dotnet
lua/
  options.lua           -- defaults, wildmode/pum, rg grepprg
  keymaps.lua           -- general + cmdline history maps
  autocmds.lua          -- yank highlight, restore cursor
  cmdline.lua           -- cmdline autocompletion, fuzzy :find, live :Grep
  diagnostics.lua       -- diagnostic UI
  colors.lua            -- retrobox
  pack.lua              -- vim.pack hooks (TSUpdate on treesitter install/update)
  plugins/init.lua      -- ordered plugin loader
  plugins/*.lua         -- one vim.pack.add + setup per plugin
  formatting.lua        -- stylua for lua, else LSP format on save
  lsp.lua               -- vim.lsp.enable
```

Each plugin module owns install, setup, and its keymaps. `init.lua` stays a
short explicit load order.

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>ff` / `<leader>fg` / `<leader>fb` | fzf-lua: files / live grep / buffers |
| `<leader>of` | fzf-lua: files in `~/org` |
| `<leader>pf` / `<leader>pg` / `<leader>pb` | mini.pick: files / live grep / buffers |
| `<leader>ph` / `<leader>pr` | mini.pick: help / resume |
| `<leader>e` / `<leader>E` | mini.files: current path / project root |
| `<leader>gg` | fugitive `:Git` status |
| `[h` / `]h` | mini.diff: prev / next hunk |
| `[H` / `]H` | mini.diff: first / last hunk |
| `gh` / `gH` | mini.diff: apply / reset hunk (`gh` also textobject) |
| `sa` / `sd` / `sr` | mini.surround: add / delete / replace |
| `<CR>` | mini.jump2d: jump within visible lines |
| `grd` | go to definition |
| `<leader>ld` | diagnostics → quickfix |
| `<Esc>` | clear search highlights |
| `<C-h/j/k/l>` | window navigation |
| `<Esc><Esc>` (terminal) | exit terminal mode |
| `<F5>` / `<F10>` / `<F11>` / `<F12>` | debug: continue / step over / into / out |
| `<leader>b` / `<leader>B` | debug: toggle / conditional breakpoint |
| `<leader>dq` / `<leader>dr` / `<leader>du` | debug: terminate / REPL / toggle UI |
| `<leader>tt` | easy-dotnet test runner (`:Dotnet` for more) |

In C# buffers easy-dotnet adds: `<leader>tr` run test, `<leader>tf` run file,
`<leader>td` debug test, `<leader>tp` peek stacktrace, `<leader>te` build errors.

Stock Neovim LSP/diagnostic defaults still apply: `grn`, `grr`, `gri`, `gra`,
`gO`, `K`, `[d` `]d`, `[q` `]q`. `mini.jump` extends `f`/`F`/`t`/`T` across
lines; `mini.ai` adds textobjects; `mini.completion` handles insert completion
and signature help.

## Cmdline

Native cmdline autocompletion (Neovim 0.12+):

- Popup suggestions while typing on `:`, `/`, and `?` (`Tab` / `<C-n>` / `<C-p>` to cycle)
- **`:find <query>`** — fuzzy file picker (`findfunc` + cache)
- **`:Grep <pattern>`** — live ripgrep results as you type (after 2 chars)

Requires `rg` on `PATH` for `:Grep` / `grepprg`.

## Treesitter parsers

Installed by default: `lua`, `c_sharp`, `json`, `markdown`, `markdown_inline`,
`query`, `vim`, `vimdoc`. Others install on demand when a matching filetype is
opened (if available).

## System dependencies

| Tool | Used for |
|------|----------|
| `git` | fugitive, mini.diff, vim.pack |
| `fzf` | fzf-lua |
| `rg` | grepprg, `:Grep`, pickers |
| `stylua` | Lua format on save |
| `lua-language-server` | Lua LSP |
| .NET SDK + `EasyDotnet` global tool | easy-dotnet (`dotnet tool install -g EasyDotnet`) |

`roslyn-language-server` and netcoredbg are installed/managed by easy-dotnet.
Optional: `vscode-langservers-extracted` (npm) for HTML support in Razor files.
