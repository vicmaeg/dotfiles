# config.nu
#
# Installed by:
# version = "0.108.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

# General =====================================================================
$env.config.show_banner = false
$env.config.bracketed_paste = true

# Table view
$env.config.table.mode = 'compact_double'
$env.config.table.header_on_separator = true
$env.config.table.missing_value_symbol = '×'
$env.config.table.trim = { methodology: "truncating", truncating_suffix: "…" }

$env.config.datetime_format.table = "%Y-%m-%d %H:%M:%S"
$env.config.datetime_format.normal = "%Y-%m-%d %H:%M:%S"

$env.config.completions.algorithm = "fuzzy"

# Vi mode =====================================================================
$env.config.edit_mode = 'vi'
$env.config.cursor_shape.vi_insert = 'line'
$env.config.cursor_shape.vi_normal = 'block'

$env.config.keybindings ++= [
  {
    name: clear_line
    modifier: control
    keycode: char_u
    mode: vi_insert
    event: { edit: CutFromStart }
  },
  {
    name: history_hint_complete
    modifier: control
    keycode: char_f
    mode: vi_insert
    event: { send: HistoryHintComplete }
  },
  {
    name: history_hint_word_complete
    modifier: alt
    keycode: char_f
    mode: vi_insert
    event: { send: HistoryHintWordComplete }
  },
]

# Environment variables =======================================================
$env.EDITOR = 'nvim'

# Theme =======================================================================
source ($nu.default-config-dir | path join "theme.nu")

# Completions =================================================================
source ($nu.default-config-dir | path join "git-completions.nu")

# Prompt ======================================================================
source ($nu.default-config-dir | path join "starship.nu")

# Fuzzy finder picker using nvim ==============================================
def nvim_pick [command: string] {
  let out_path = '/tmp/nvim/out-file'

  nvim --noplugin -u ~/.config/nvim/init-cli-pick.lua -c $command

  if ($out_path | path exists) {
    let text = open $out_path | str trim | str replace "\n" " "
    rm -p $out_path
    commandline edit --insert $text
  }
}

def nvim_pick_files [] { nvim_pick "lua _G.pick_file_cli()" }

def nvim_pick_dirs [] { nvim_pick "lua _G.pick_dir_cli()" }

def nvim_pick_input []: list -> list {
  let in_path = '/tmp/nvim/in-file'
  let out_path = '/tmp/nvim/out-file'

  mkdir ($in_path | path dirname)
  $in | save $in_path

  nvim --noplugin -u ~/.config/nvim/init-cli-pick.lua -c "lua _G.pick_from_file()"

  rm -p $in_path
  if ($out_path | path exists) {
    let res = open $out_path | str trim | split row "\n"
    rm -p $out_path
    return $res
  }
  return []
}

$env.config.keybindings ++= [
  {
    name: clear_line
    modifier: control
    keycode: char_t
    mode: vi_insert
    event: { send: executehostcommand, cmd: nvim_pick_files }
  },
  {
    name: clear_line
    modifier: control
    keycode: char_d
    mode: vi_insert
    event: { send: executehostcommand, cmd: nvim_pick_dirs }
  }
]
