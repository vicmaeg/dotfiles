# dotfiles

Install the appropriate profile with GNU Stow:

```bash
./omarchy
# or
./arch_wsl
```

The profiles install shared Bash, Neovim, nb, and local-bin configuration.
`nb` itself is an external dependency; install it using the upstream
[installation instructions](https://github.com/xwmx/nb#installation).
nb's Git author is isolated in `~/.nb/.gitconfig`; its normal first-run prompt
creates that file without changing the identity used by other repositories.

## Notes

Notes use independent nb notebooks and Git histories:

- Personal machines: `personal` and `daily`.
- Work machines: `work` and `daily`.
- General notes live at the primary notebook root, with `projects/` and
  `areas/` subfolders.
- Project tags use `#projects/<name>` and area tags use `#areas/<name>`.
- `#next` on an open task marks it for the next-actions picker. A standalone
  todo can instead carry the document-level `#next` tag.

Notebook roles and task folders are configured in `~/.config/nb-fzf/config`.
Task pickers query the notebook root plus `NB_FZF_TASK_FOLDERS` (by default,
`projects` and `areas`). Missing configured notebooks or folders are ignored,
so the same configuration works on personal and work computers. Select the
primary notebook used for creation with `nb use personal` or `nb use work`.

```bash
nb-fzf find                 # titles, paths, and tags
nb-fzf search "query"       # full text
nb-fzf tags                 # multi-tag AND search
nb-fzf tasks                # all open tasks and todos across folders
nb-fzf next                 # open tasks tagged #next
nb-fzf new project          # create in the current primary notebook
nb-fzf daily                # today's note in daily
```

On a fresh installation, rename nb's initial `home` notebook and initialize its
layout:

```bash
nb notebooks rename home personal  # use work on a work computer
nb-fzf init personal
```

The one-time zk migration is dry-run by default:

```bash
scripts/migrate-zk-to-nb
scripts/migrate-zk-to-nb --apply
```

It retains a full nb backup and manifest under
`~/.local/state/nb-fzf/migrations/`, and renames the old `~/org` directory to a
timestamped archive only after verification. It does not configure Git remotes.

## TODO

- [ ] Add an option to manage database connections and run sql scripts
