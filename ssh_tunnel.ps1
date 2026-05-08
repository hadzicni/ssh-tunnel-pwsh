Clear-Host

$Host.UI.RawUI.WindowTitle = "SSH Tunnel Manager"

$ProfileFile = "$PSScriptRoot\profiles.json"

# =========================================================
# HEADER
# =========================================================
function Show-Header {

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              SSH TUNNEL MANAGER              ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan

    Write-Host ""
    Write-Host (" User : " + $env:USERNAME) -ForegroundColor DarkGray
    Write-Host (" Host : " + $env:COMPUTERNAME) -ForegroundColor DarkGray
    Write-Host (" Time : " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) -ForegroundColor DarkGray
    Write-Host ""
}

# =========================================================
# LOAD PROFILES
# =========================================================
function Load-Profiles {

    if (Test-Path $ProfileFile) {

        $data = Get-Content $ProfileFile | ConvertFrom-Json

        if ($data -is [array]) {
            return $data
        }

        elseif ($null -ne $data) {
            return @($data)
        }
    }

    return @()
}

# =========================================================
# SAVE PROFILES
# =========================================================
function Save-Profiles($profiles) {

    @($profiles) |
        ConvertTo-Json -Depth 3 |
        Set-Content $ProfileFile
}

# =========================================================
# INPUT HELPER
# =========================================================
function Read-Input {

    param (
        $prompt,
        $default = $null
    )

    if ($default) {

        $input = Read-Host "$prompt [$default]"

        if ([string]::IsNullOrWhiteSpace($input)) {
            return $default
        }

        return $input
    }

    return Read-Host $prompt
}

# =========================================================
# CREATE PROFILE
# =========================================================
function Create-Profile {

    Clear-Host
    Show-Header

    Write-Host "Create New Profile" -ForegroundColor Yellow
    Write-Host "────────────────────────────────────────────"
    Write-Host ""

    $name       = Read-Input "Profile name"
    $user       = Read-Input "SSH user"
    $server     = Read-Input "Server" "217.160.47.213"
    $localPort  = Read-Input "Local port" "8006"
    $remoteIP   = Read-Input "Remote IP" "127.0.0.1"
    $remotePort = Read-Input "Remote port" "8006"
    $key        = Read-Input "SSH key (optional)"

    $profile = [PSCustomObject]@{
        Name       = $name
        User       = $user
        Server     = $server
        LocalPort  = $localPort
        RemoteIP   = $remoteIP
        RemotePort = $remotePort
        Key        = $key
    }

    $profiles = @(Load-Profiles)
    $profiles += $profile

    Save-Profiles $profiles

    Write-Host ""
    Write-Host "Profile saved successfully." -ForegroundColor Green

    Read-Host "`nPress Enter to continue"
}

# =========================================================
# QUICK CONNECT
# =========================================================
function Quick-Connect {

    Clear-Host
    Show-Header

    Write-Host "Quick Connect" -ForegroundColor Yellow
    Write-Host "────────────────────────────────────────────"
    Write-Host ""

    $user       = Read-Input "SSH user"
    $server     = Read-Input "Server" "217.160.47.213"
    $localPort  = Read-Input "Local port" "8006"
    $remoteIP   = Read-Input "Remote IP" "127.0.0.1"
    $remotePort = Read-Input "Remote port" "8006"
    $key        = Read-Input "SSH key (optional)"

    $tempProfile = [PSCustomObject]@{
        Name       = "QuickConnect"
        User       = $user
        Server     = $server
        LocalPort  = $localPort
        RemoteIP   = $remoteIP
        RemotePort = $remotePort
        Key        = $key
    }

    Start-Tunnel $tempProfile
}

# =========================================================
# SELECT PROFILE
# =========================================================
function Select-Profile {

    Clear-Host
    Show-Header

    $profiles = Load-Profiles

    if ($profiles.Count -eq 0) {

        Write-Host "No profiles found." -ForegroundColor Red
        Read-Host "`nPress Enter to continue"

        return $null
    }

    Write-Host "Saved Profiles" -ForegroundColor Cyan
    Write-Host "────────────────────────────────────────────"

    for ($i = 0; $i -lt $profiles.Count; $i++) {

        $p = $profiles[$i]

        Write-Host ""
        Write-Host (" [{0}] {1}" -f $i, $p.Name) -ForegroundColor Yellow
        Write-Host ("      {0}@{1}" -f $p.User, $p.Server) -ForegroundColor Gray
        Write-Host ("      localhost:{0} → {1}:{2}" -f `
            $p.LocalPort,
            $p.RemoteIP,
            $p.RemotePort) -ForegroundColor DarkCyan
    }

    Write-Host ""

    $index = Read-Host "Select profile"

    if ($index -match "^\d+$" -and $index -lt $profiles.Count) {
        return $profiles[$index]
    }

    Write-Host ""
    Write-Host "Invalid selection." -ForegroundColor Red

    Read-Host "`nPress Enter to continue"

    return $null
}

# =========================================================
# DELETE PROFILE
# =========================================================
function Delete-Profile {

    Clear-Host
    Show-Header

    $profiles = Load-Profiles

    if ($profiles.Count -eq 0) {

        Write-Host "No profiles available." -ForegroundColor Red

        Read-Host "`nPress Enter to continue"

        return
    }

    Write-Host "Delete Profile" -ForegroundColor Yellow
    Write-Host "────────────────────────────────────────────"

    for ($i = 0; $i -lt $profiles.Count; $i++) {

        Write-Host ""
        Write-Host (" [{0}] {1}" -f $i, $profiles[$i].Name) -ForegroundColor Cyan
    }

    Write-Host ""

    $index = Read-Host "Select profile"

    if ($index -match "^\d+$" -and $index -lt $profiles.Count) {

        $profiles = $profiles | Where-Object {
            $_ -ne $profiles[$index]
        }

        Save-Profiles $profiles

        Write-Host ""
        Write-Host "Profile deleted." -ForegroundColor Yellow
    }

    else {

        Write-Host ""
        Write-Host "Invalid selection." -ForegroundColor Red
    }

    Read-Host "`nPress Enter to continue"
}

# =========================================================
# START TUNNEL
# =========================================================
function Start-Tunnel($profile) {

    Clear-Host
    Show-Header

    Write-Host "Starting tunnel..." -ForegroundColor Green
    Write-Host ""

    $url = "http://localhost:$($profile.LocalPort)"

    $sshArgs = @(
        "-N"
        "-T"
        "-o", "ServerAliveInterval=60"
        "-o", "ServerAliveCountMax=3"
        "-L", "$($profile.LocalPort):$($profile.RemoteIP):$($profile.RemotePort)"
    )

    if ($profile.Key) {
        $sshArgs += @("-i", $profile.Key)
    }

    $sshArgs += "$($profile.User)@$($profile.Server)"

    $mode = Read-Input "Run in background? (y/N)"

    # =====================================================
    # BACKGROUND MODE
    # =====================================================
    if ($mode -eq "y") {

        $process = Start-Process `
            -FilePath "ssh" `
            -ArgumentList $sshArgs `
            -NoNewWindow `
            -PassThru

        Start-Sleep 1

        if (-not $process.HasExited) {

            Start-Process $url

            Write-Host ""
            Write-Host "Tunnel started in background." -ForegroundColor Green
            Write-Host ("Open: " + $url) -ForegroundColor Cyan
        }

        else {

            Write-Host ""
            Write-Host "Tunnel failed." -ForegroundColor Red
        }

        Read-Host "`nPress Enter to continue"

        return
    }

    # =====================================================
    # FOREGROUND MODE
    # =====================================================
    $process = Start-Process `
        -FilePath "ssh" `
        -ArgumentList $sshArgs `
        -NoNewWindow `
        -PassThru

    Start-Sleep 1

    if (-not $process.HasExited) {
        Start-Process $url
    }

    $startTime = Get-Date

    Write-Host ""
    Write-Host "────────────────────────────────────────────"
    Write-Host (" Profile : " + $profile.Name) -ForegroundColor Yellow
    Write-Host (" Server  : " + $profile.Server) -ForegroundColor Gray
    Write-Host (" Target  : localhost:{0} → {1}:{2}" -f `
        $profile.LocalPort,
        $profile.RemoteIP,
        $profile.RemotePort) -ForegroundColor Cyan

    Write-Host "────────────────────────────────────────────"
    Write-Host ""
    Write-Host "Press CTRL+C to stop tunnel" -ForegroundColor DarkGray
    Write-Host ""

    try {

        while (-not $process.HasExited) {

            $elapsed = (Get-Date) - $startTime
            $time = "{0:hh\:mm\:ss}" -f $elapsed

            Write-Host -NoNewline "`r"

            Write-Host -NoNewline "● CONNECTED " -ForegroundColor Green
            Write-Host -NoNewline "| " -ForegroundColor DarkGray
            Write-Host -NoNewline $time -ForegroundColor Yellow
            Write-Host -NoNewline " | " -ForegroundColor DarkGray
            Write-Host -NoNewline ("localhost:{0}" -f $profile.LocalPort) -ForegroundColor Cyan
            Write-Host -NoNewline (" " * 20)

            Start-Sleep 1
        }
    }

    finally {

        if (-not $process.HasExited) {
            $process.Kill()
        }

        Write-Host ""
        Write-Host ""
        Write-Host "● DISCONNECTED" -ForegroundColor Red

        Read-Host "`nPress Enter to continue"
    }
}

# =========================================================
# MENU
# =========================================================
function Show-Menu {

    Write-Host "┌──────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "│                MENU                  │" -ForegroundColor Cyan
    Write-Host "├──────────────────────────────────────┤" -ForegroundColor DarkGray
    Write-Host "│  [1] Start Tunnel                    │" -ForegroundColor White
    Write-Host "│  [2] Quick Connect                   │" -ForegroundColor White
    Write-Host "│  [3] Create Profile                  │" -ForegroundColor White
    Write-Host "│  [4] Delete Profile                  │" -ForegroundColor White
    Write-Host "│  [5] Exit                            │" -ForegroundColor White
    Write-Host "└──────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
}

# =========================================================
# MAIN LOOP
# =========================================================
while ($true) {

    Clear-Host

    Show-Header
    Show-Menu

    $choice = Read-Host "Select option"

    switch ($choice) {

        "1" {

            $profile = Select-Profile

            if ($profile) {
                Start-Tunnel $profile
            }
        }

        "2" {
            Quick-Connect
        }

        "3" {
            Create-Profile
        }

        "4" {
            Delete-Profile
        }

        "5" {
            break
        }

        default {

            Write-Host ""
            Write-Host "Invalid option." -ForegroundColor Red

            Start-Sleep 1
        }
    }
}

Clear-Host
Write-Host "Goodbye." -ForegroundColor Cyan