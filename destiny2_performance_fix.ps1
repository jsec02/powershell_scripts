# ================================================================================
# =                           DESTINY2_PERFORMANCE_FIX                           =
# ================================================================================

# https://www.reddit.com/r/DestinyTheGame/comments/1vaen8x/another_possible_steam_performance_fix/

param(
    [String]$SteamRoot = 'C:\Program Files (x86)\Steam'
)

function Assert-SteamInactive {
    if (Get-Process -Name 'steam' -ErrorAction SilentlyContinue) {
        Write-Host 'Steam is already running'
        exit 1
    }
}

function Assert-SteamRoot {
    if (-not (Test-Path -Path $SteamRoot)) {
        Write-Host "Cannot find the path: $SteamRoot"
        exit 1
    }
}

function Assert-SteamEXE {
    param(
        [Parameter(Mandatory)]
        [String]$SteamEXE

    )

    if (-not (Test-Path -Path $SteamEXE)) {
        Write-Host "Cannot find the steam executable: $SteamEXE"
        exit 1
    }
}

function Start-Steam  {
    $SteamEXE = "$SteamRoot\steam.exe"

    Assert-SteamEXE -SteamEXE $SteamEXE

    Start-Process -FilePath $SteamEXE
}

function Remove-OverlayFiles {
    # The existence of the steamservice process means that steam has fully started
    while (-not (Get-Process -Name 'steamservice' -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 1
    }
    Remove-Item -Path "$SteamRoot\*overlay*"
}

function Invoke-Main {
    Assert-SteamInactive
    Assert-SteamRoot
    Start-Steam
    Remove-OverlayFiles
}

Invoke-Main
