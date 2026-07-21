# ================================================================================
# =                                   LINKSYNC                                   =
# ================================================================================

function Sync-DotfileLinks {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Hostname
    )

    $Output = python "$HOME/parsers/inventory.py" links $Hostname

    foreach ($Line in $Output) {
        # Ignore $Parts[0], the sudo flag is not needed on windows
        $Parts = $Line -split ' '
        $Target = $Parts[1]
        $Path = $Parts[2]

        # Skip if symlink already exists
        if ((Test-Path -Path $Path) -and (Get-Item -Path $Path).LinkType -eq 'SymbolicLink') {
            continue
        }

        # Ensure dotfiles destination dir exists
        New-Item -ItemType Directory -Path (Split-Path $Target -Parent) -Force

        # Fresh-install case where configs may exist already
        if ((Test-Path $Target) -and (Test-Path $Path)) {
            Remove-Item -Path $Path # Remove default config
        } elseif (Test-Path $Path) {
            Move-Item -Path $Path -Destination $Target # Move existing config into dotfiles
        }

        # Ensure target parent dir exists
        New-Item -ItemType Directory -Path (Split-Path $Path -Parent) -Force

        # Create symlink from dotfiles to target
        New-Item -ItemType SymbolicLink -Path $Path -Target $Target -Force
    }
}

function Invoke-Main {
    $Hostname = $Env:COMPUTERNAME.ToLowerInvariant()

    Sync-DotfileLinks -Hostname $Hostname
}

Invoke-Main
