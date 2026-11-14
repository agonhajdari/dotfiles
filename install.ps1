$ErrorActionPreference = 'Stop'

$bin = Join-Path $PSScriptRoot '_vim/bin'
if ($env:OS -eq 'Windows_NT' -and
    -not (Get-Command rg -CommandType Application -ErrorAction SilentlyContinue) -and
    -not (Test-Path -LiteralPath "$bin/rg.exe")) {
    $cpu = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
    $arch = @{ AMD64 = 'x86_64'; ARM64 = 'aarch64'; x86 = 'i686' }[$cpu]
    if (-not $arch) { throw "Unsupported Windows architecture: $cpu" }
    $package = "ripgrep-15.2.0-$arch-pc-windows-msvc"
    New-Item -ItemType Directory -Path $bin -Force | Out-Null
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest "https://github.com/BurntSushi/ripgrep/releases/download/15.2.0/$package.zip" -OutFile "$bin/$package.zip" -UseBasicParsing
    Expand-Archive -LiteralPath "$bin/$package.zip" -DestinationPath $bin -Force
    Move-Item -LiteralPath "$bin/$package/rg.exe" -Destination "$bin/rg.exe" -Force
    Remove-Item -LiteralPath "$bin/$package.zip"
}

$vimHome = if ($env:HOME) { $env:HOME }
           elseif ($env:HOMEDRIVE -and $env:HOMEPATH) { $env:HOMEDRIVE + $env:HOMEPATH }
           else { $env:USERPROFILE }

$target = Join-Path $vimHome '_vimrc'
$config = (Join-Path $PSScriptRoot '_vim/vimrc').Replace('\', '/').Replace("'", "''")
$loader = "execute 'source ' . fnameescape('$config')"

if (Test-Path -LiteralPath $target) {
    if ([IO.File]::ReadAllText($target).TrimEnd() -eq $loader) { return }
    Copy-Item -LiteralPath $target -Destination "$target.backup-$(Get-Date -Format yyyyMMddHHmmssfffffff)"
}

Set-Content -LiteralPath $target -Value $loader -Encoding UTF8
Write-Host 'Installed. Open Vim and run :PlugInstall.'
