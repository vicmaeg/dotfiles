# Neovim config

Neovim config (0.12+) managed with the built-in `vim.pack` plugin manager. No
plugin-manager wrapper, no mason: native LSP, mini.nvim UI modules, and a small
set of focused plugins.

## Overview

- **Leader**: `<Space>`
- **Colorscheme**: `retrobox`
- **Plugins**: `vim.pack` + lockfile (`nvim-pack-lock.json`)
- **LSP**: native `vim.lsp` (`lua_ls`, `roslyn_ls`)
- **Completion**: mini.completion + native cmdline autocompletion
- **Git**: fugitive (status/blame) + mini.diff (hunk signs) + diffs.nvim
- **Pickers**: mini.pick (primary) and fzf-lua (`<leader>fz` picker menu)

## Plugins

| Plugin | Role |
|--------|------|
| `nvim-mini/mini.nvim` | icons, ai, surround, completion, diff, jump, jump2d, pick, statusline, files |
| `tpope/vim-fugitive` | Git client (`:Git`, blame, etc.) |
| `ibhagwan/fzf-lua` | Secondary picker menu (ivy layout) |
| `barrettruth/diffs.nvim` | Diff views (Fugitive integration) |
| `nvim-orgmode/orgmode` | Org files and agenda (`~/org`) |
| `nvim-treesitter/nvim-treesitter` (`main`) | Highlighting + indent |
| `neovim/nvim-lspconfig` | Maintained native LSP configurations, including `roslyn_ls` |
| `nvim-neotest/neotest` + `nsidorenco/neotest-vstest` | .NET test discovery, execution, output, and DAP debugging |
| `GustavEikaas/easy-dotnet.nvim` | Optional on-demand .NET command and alternative test runner |
| `mfussenegger/nvim-dap` | Debug adapter protocol client |
| `rcarriga/nvim-dap-ui` (+ `nvim-neotest/nvim-nio`) | Debug UI and Neotest async support |
| `nvim-lua/plenary.nvim` | Lua library (easy-dotnet dependency) |

Manage plugins with `:lua vim.pack.update()` (review the update buffer, `:w` to
confirm) and `:lua vim.pack.del({ "name" })`. Offline inspect:
`:lua vim.pack.update(nil, { offline = true })`. Commit `nvim-pack-lock.json`
for reproducible setups.

## Structure

```
init.lua                -- leader, vim.loader, module load order
ripgreprc               -- include hidden files, exclude .git from rg-backed pickers
after/lsp/
  roslyn_ls.lua         -- local Roslyn settings layered on nvim-lspconfig
lua/
  options.lua           -- defaults, wildmode/pum, rg grepprg
  keymaps.lua           -- general keymaps
  autocmds.lua          -- yank highlight, restore cursor
  cmdline.lua           -- cmdline autocompletion, fuzzy :find, live :Grep
  diagnostics.lua       -- diagnostic UI
  colors.lua            -- retrobox
  pack.lua              -- vim.pack hooks (TSUpdate on treesitter install/update)
  plugins/init.lua      -- ordered plugin loader
  plugins/*.lua         -- one vim.pack.add + setup per plugin
  formatting.lua        -- diff-based stylua formatting, else one selected LSP formatter
  lsp.lua               -- vim.lsp.enable
```

Each plugin module owns install, setup, and its keymaps. `init.lua` stays a
short explicit load order.

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>ff` / `<leader>fg` / `<leader>fb` | mini.pick: files (including dotfiles) / live ripgrep (including dotfiles) / buffers |
| `<leader>fh` / `<leader>fr` | mini.pick: help / resume |
| `<leader>fz` | fzf-lua: choose an internal picker |
| `<leader>of` | mini.pick: files in `~/org` |
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
| `<leader>tt` | Neotest: toggle test summary |
| `<leader>tr` / `<leader>tf` | Neotest: run nearest test / current file |
| `<leader>td` / `<leader>to` | Neotest: debug nearest test / show output |

Run `:EasyDotnet` only when you want easy-dotnet's optional workflow. It
initializes the plugin without starting its LSP or test discovery; use
`:Dotnet testrunner` afterwards to open its alternative test runner.

Stock Neovim LSP/diagnostic defaults still apply: `grn`, `grr`, `gri`, `gra`,
`gO`, `K`, `[d` `]d`, `[q` `]q`. `mini.jump` extends `f`/`F`/`t`/`T` across
lines; `mini.ai` adds textobjects; `mini.completion` handles insert completion
and signature help.

## Cmdline

Native cmdline autocompletion (Neovim 0.12+):

- Popup suggestions while typing on `:`, `/`, and `?` (`Tab` / `<C-n>` / `<C-p>` to cycle)
- **`:find <query>`** — fuzzy file picker over `rg --files` (`findfunc` + cache)
- **`:Grep <pattern>`** — live ripgrep results as you type (after 2 chars, including multiword patterns)

Requires `rg` on `PATH` for `:Grep` / `grepprg`.
The bundled `ripgreprc` makes rg-backed pickers include dotfiles while excluding `.git`.

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
| .NET SDK | Roslyn and `neotest-vstest` |
| `roslyn-language-server` | C# LSP (`dotnet tool install --global roslyn-language-server --prerelease`) |
| `netcoredbg` | Neotest DAP debugging (`yay -S netcoredbg` on Arch/Omarchy) |
| `EasyDotnet` global tool | Optional easy-dotnet workflow (`dotnet tool install -g EasyDotnet`) |

`nvim-lspconfig` supplies the `roslyn_ls` configuration but does not install
the Roslyn language-server executable. `netcoredbg` must be on `PATH` before
using `<leader>td`. The standalone `roslyn_ls` setup supports C#; Razor/CSHTML
support previously supplied by easy-dotnet is intentionally not enabled.
The unused Node, Perl, Python, and Ruby remote providers are disabled.
