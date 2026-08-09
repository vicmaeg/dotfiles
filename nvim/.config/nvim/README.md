# Neovim config

Neovim config (0.12+) with a handful of focused plugins managed by the
built-in `vim.pack` plugin manager. No plugin-manager wrapper, no mason, native
LSP, native statusline, built-in colorscheme.

## Plugins

| Plugin | Role |
|--------|------|
| `tpope/vim-fugitive` | Git client |
| `tpope/vim-surround` | Surround operations |
| `ibhagwan/fzf-lua` | Files / live grep / buffers |
| `stevearc/oil.nvim` | File explorer (takes over directory buffers) |
| `lewis6991/gitsigns.nvim` | Hunk signs + navigation |
| `nvim-treesitter/nvim-treesitter` (`main` branch) | Highlighting |

Manage plugins with `:packupdate` (review buffer, `:w` to confirm) and
`:packdel <name>`. The lockfile `nvim-pack-lock.json` lives next to this file —
commit it for reproducible setups.

## Structure

```
init.lua                -- leader + module load order
lsp/
  lua_ls.lua            -- Lua (lua-language-server)
  roslyn_ls.lua         -- C# (Roslyn), adapted from nvim-lspconfig
lua/
  options.lua           -- sane defaults, 0.11/0.12 native features
  plugins.lua           -- vim.pack.add + setup() calls
  keymaps.lua
  autocmds.lua          -- yank highlight, restore cursor
  statusline.lua        -- native: mode | git branch | path | diags | ft
  diagnostics.lua
  lsp.lua               -- vim.lsp.enable + builtin completion on attach
  formatting.lua        -- stylua for lua, else LSP format on save
  colors.lua            -- habamax
```

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>ff` / `<leader>fg` / `<leader>fb` | fzf-lua files / live grep / buffers |
| `<leader>gg` | fugitive `:Git` status |
| `[h` / `]h` | gitsigns prev/next hunk |
| `-` | oil: parent of current file |
| `<leader>e` | oil: project root (`.git` marker) |
| `<leader>d` | diagnostics to quickfix |
| `<C-h/j/k/l>` | window navigation |

Everything else relies on stock defaults: `grn`, `grr`, `gri`, `gra`, `gO`,
`K`, `[d` `]d`, `[q` `]q`, LSP completion via builtin `vim.lsp.completion`.

## System dependencies

`git`, `fzf`, `rg`, `stylua`, `lua-language-server`,
`roslyn-language-server` (for C#).
