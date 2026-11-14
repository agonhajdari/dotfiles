# Vim dotfiles

## Windows

Install native Vim (a current Vim 9.x build is recommended) and Git, then clone
this repository. From PowerShell 5.1 or newer, run:

```powershell
.\install.ps1
```

The script works from any working directory. It writes a small `_vimrc` in
Vim's home directory that sources this checkout, backs up any existing `_vimrc`,
and leaves repeat runs unchanged. No administrator access, Developer Mode, or
symlinks are needed.

If `rg` is missing from `PATH`, the installer downloads ripgrep 15.2.0 from
the [official GitHub releases](https://github.com/BurntSushi/ripgrep/releases/tag/15.2.0)
for Windows x64, ARM64, or x86 into `_vim/bin/` (ignored by Git). Vim uses this
local copy automatically; the system `PATH` stays unchanged. An existing local
copy is reused on subsequent runs. The initial download requires internet access.

If script execution is blocked, use a policy override for this process:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

Open Vim and run `:PlugInstall`. The bundled vim-plug autoloader is used;
plugins are installed into `_vim/plugged/` in this checkout. Keep the checkout
in place, or rerun the installer after moving it.

The installer follows Vim's `HOME`, then `HOMEDRIVE` + `HOMEPATH`, then
`USERPROFILE` lookup. To diagnose startup, use `:echo expand('~')`,
`:echo $MYVIMRC`, and `:scriptnames`. `VIMINIT` or starting Vim with `-u` can
override this setup.
This installer targets native Vim/gVim; use the Unix setup separately for WSL.

To uninstall, remove the generated `_vimrc` and restore its backup if present.

## Portability notes

- The Unix installer uses `~/.config/vim`; native Windows Vim searches for
  `$HOME/_vimrc` or `$HOME/vimfiles/vimrc` instead. The PowerShell loader bridges
  that difference. See [Vim's startup documentation](https://github.com/vim/vim/blob/master/runtime/doc/starting.txt).
- The vimrc locates its own runtime directory and plugin directory explicitly,
  so the bundled autoloader works when sourced from outside that directory.
- Clipboard and true-color options are guarded for builds without those
  features. `wildcharm` falls back to `default` when the runtime lacks it.
  Unicode list characters still require a suitable terminal font.
- Windows setup downloads `rg` if needed; on Unix, install ripgrep on `PATH`
  for consistent `:Grep` / `:LGrep` behavior.
  Otherwise Vim retains its platform-specific `grepprg` and `grepformat` defaults.
  These commands execute shell command text: quote search patterns and paths
  with spaces for Vim's `:set shell?` (normally `cmd.exe` on Windows).
- The `mt` mapping requires the dispatch plugin and a `ctags` executable
  supporting `--exclude` and `-R`, such as Universal Ctags. Fugitive and plugin
  installation require Git. Restart Vim after changing `PATH`.
- `vim-formatprgs` depends on external formatters for each language; having
  the plugin installed does not install those tools. Some formatter commands
  or other plugin operations may rely on Unix tools unavailable on Windows.
- PowerShell runs the installer; Vim keeps its own default shell. Changing
  Vim's shell to PowerShell also requires compatible shell quoting/redirection
  options. See `:help shell-powershell` before doing so.
- `set path-=/usr/include` is harmless on Windows; the other search paths use
  forward slashes, which Vim accepts on Windows.

## macOS / Linux

The existing `./install.sh` links `_vim` into `~/.config/vim`. Run it from the
repository root with `~/.config` already present. This requires Vim with XDG
configuration support; an existing `~/.vimrc` may take precedence.
