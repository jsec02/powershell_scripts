# ================================================================================
# =                           DESTINY2_PERFORMANCE_FIX                           =
# ================================================================================

# https://www.reddit.com/r/DestinyTheGame/comments/1vaen8x/another_possible_steam_performance_fix/

param(
    [String]$SteamRoot = 'C:\Program Files (x86)\Steam'
)

function Assert-SteamRoot {
    if (-not (Test-Path -Path $SteamRoot)) {
        Write-Host "Cannot find the path: $SteamRoot"
        exit 1
    }
}

function Move-OverlayFiles {
    param(
        [ValidateSet('Out', 'In')]
        [string]$Direction
    )

    $Temp = "$Env:TEMP\Overlay"

    if ($Direction -eq 'Out') {
        New-Item -Path $Temp -ItemType Directory -Force | Out-Null
        # Sometimes steam creates handles to GameOverlayRenderer.dll and GameOverlayRenderer64.dll
        # which means we cannot move these files. I've opted to supress these errors
        # I originally wrote an alterate version of this script that sidesteps this problem with different architecture
        # https://github.com/jsec02/powershell_scripts/blob/bb72237d72235bcd5745c5288fca904c86e0b837/destiny2_performance_fix.ps1
        # The current version only disables steam overlay for Destiny 2 which is why I decided to keep it despite this handle situation
        Move-Item -Path "$SteamRoot\*overlay*" -Destination $Temp -Force -ErrorAction SilentlyContinue
    } elseif ($Direction -eq 'In') {
        Move-Item -Path "$Temp\*" -Destination $SteamRoot -Force
    }
}

function Wait-ForDestiny2Process {
    while (-not $Process) {
        $Process = Get-Process -Name 'destiny2' -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }

    return $Process
}

function Start-Destiny2 {
    Move-OverlayFiles -Direction Out

    try {
        Start-Process 'steam://rungameid/1085660' # Destiny 2 Steam App ID
        $Destiny2Process = Wait-ForDestiny2Process
        $Destiny2Process.WaitForExit()
    } finally {
        Move-OverlayFiles -Direction In
    }
}

function Invoke-Main {
    Assert-SteamRoot
    Start-Destiny2
}

Invoke-Main
