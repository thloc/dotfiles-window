### PowerShell Profile

# Set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# PSReadLine
. $env:USERPROFILE\.config\powershell\psreadline-profile.ps1

# Fzf
# Import-Module PSFzf
# Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Get theme from profile.ps1 or use a default theme
function Get-Theme {
    if (Test-Path -Path $PROFILE.CurrentUserAllHosts -PathType leaf) {
        $existingTheme = Select-String -Raw -Path $PROFILE.CurrentUserAllHosts -Pattern "oh-my-posh init pwsh --config"

	if ($null -ne $existingTheme) {
            Invoke-Expression $existingTheme
            return
        }

	oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json | Invoke-Expression
    } else {
        oh-my-posh init pwsh --config "$env:USERPROFILE\.config\powershell\zash.omp.json"| Invoke-Expression
    }
}

# System Utilities
function admin {
    if ($args.Count -gt 0) {
        $argList = $args -join ' '
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}

## Final Line to set prompt
Get-Theme

# Alias
Set-Alias -Name vim -Value nvim
Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias -Name sudo -Value admin

# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Use-Java {
    param ([string]$version)

    $result = jabba use $version 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Output "❌ ERROR: Unable to switch to Java $version. Please check the version"
        return
    }

    $JDK_PATH = jabba which $version
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $JDK_PATH, [System.EnvironmentVariableTarget]::User)

    $binPath = Join-Path -Path $JDK_PATH -ChildPath "bin"
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

    if (-not $currentPath.Contains($binPath)) {
        $newPath = "$currentPath;$binPath"
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::User)
        Write-Output "Path updated to include Java bin directory: $binPath"
    } else {
        Write-Output "Java bin directory already exists in Path: $binPath"
    }

    Write-Output "Switched to Java $version, JAVA_HOME updated: $JDK_PATH"
}
