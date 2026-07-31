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
        Move-Item -Path "$SteamRoot\*overlay*" -Destination $Temp -Force
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
