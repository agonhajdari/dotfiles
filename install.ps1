$ErrorActionPreference = 'Stop'

$vimHome = if ($env:HOME) { $env:HOME }
           elseif ($env:HOMEDRIVE -and $env:HOMEPATH) { $env:HOMEDRIVE + $env:HOMEPATH }
           else { $env:USERPROFILE }

# Ctags uses HOME when set, otherwise HOMEDRIVE + HOMEPATH on Windows.
$ctagsConfig = if ($env:HOME) { Join-Path $env:HOME '.ctags.d' }
               else { Join-Path ($env:HOMEDRIVE + $env:HOMEPATH) 'ctags.d' }
New-Item -ItemType Directory -Path $ctagsConfig -Force | Out-Null
Copy-Item -Path "$PSScriptRoot/_ctags.d/*.ctags" -Destination $ctagsConfig -Force

$target = Join-Path $vimHome '_vimrc'
$config = (Join-Path $PSScriptRoot '_vim/vimrc').Replace('\', '/').Replace("'", "''")
$loader = "execute 'source ' . fnameescape('$config')"

if (Test-Path -LiteralPath $target) {
    if ([IO.File]::ReadAllText($target).TrimEnd() -eq $loader) { return }
    Copy-Item -LiteralPath $target -Destination "$target.backup-$(Get-Date -Format yyyyMMddHHmmssfffffff)"
}

Set-Content -LiteralPath $target -Value $loader -Encoding UTF8
Write-Host 'Installed. Open Vim and run :PlugInstall.'
