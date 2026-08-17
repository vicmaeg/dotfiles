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
| `GustavEikaas/easy-dotnet.nvim` | .NET: Roslyn LSP, test runner, build/run, debugging bootstrap |
| `mfussenegger/nvim-dap` | Debug adapter protocol client |
| `rcarriga/nvim-dap-ui` (+ `nvim-neotest/nvim-nio`) | Debug UI (scopes, stacks, watches) |
| `nvim-lua/plenary.nvim` | Lua library (easy-dotnet dependency) |

Manage plugins with `:packupdate` (review buffer, `:w` to confirm) and
`:packdel <name>`. The lockfile `nvim-pack-lock.json` lives next to this file —
commit it for reproducible setups.

## Structure

```
init.lua                -- leader + module load order
lsp/
  lua_ls.lua            -- Lua (lua-language-server)
  easy_dotnet.lua       -- C# (Roslyn) settings; server started by easy-dotnet.nvim
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
| `<leader>q` | diagnostics to quickfix |
| `<C-h/j/k/l>` | window navigation |
| `<F5>` / `<F10>` / `<F11>` / `<F12>` | debug: continue / step over / step into / step out |
| `<leader>b` / `<leader>B` | debug: toggle / conditional breakpoint |
| `<leader>dq` / `<leader>dr` / `<leader>du` | debug: terminate / REPL / toggle UI |
| `<leader>tt` | easy-dotnet test runner (more via `:Dotnet`) |

In C# buffers easy-dotnet adds: `<leader>tr` run test, `<leader>tf` run file,
`<leader>td` debug test, `<leader>tp` peek stacktrace, `<leader>te` build errors.

Everything else relies on stock defaults: `grn`, `grr`, `gri`, `gra`, `gO`,
`K`, `[d` `]d`, `[q` `]q`, LSP completion via builtin `vim.lsp.completion`.

## System dependencies

`git`, `fzf`, `rg`, `stylua`, `lua-language-server`, .NET SDK, and the
`EasyDotnet` dotnet global tool (`dotnet tool install -g EasyDotnet`, required
by easy-dotnet.nvim). `roslyn-language-server` and the netcoredbg debugger are
installed/managed by easy-dotnet itself. Optional:
`vscode-langservers-extracted` (npm) for HTML support in Razor files.
