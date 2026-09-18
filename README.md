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
- `#next` marks a line that should appear in the next-actions picker.

Notebook roles are configured in `~/.config/nb-fzf/config`. Missing configured
notebooks are ignored by combined searches, so the same configuration works on
personal and work computers. Select the primary notebook used for creation with
`nb use personal` or `nb use work`.

```bash
nb-fzf find                 # titles, paths, and tags
nb-fzf search "query"       # full text
nb-fzf tags                 # multi-tag AND search
nb-fzf next                 # exact #next lines
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
