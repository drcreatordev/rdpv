<#
.SYNOPSIS
  Publishes the relay and installs it as a Windows service that auto-starts.

.DESCRIPTION
  Makes the relay a proper Windows service ("RdpV.Relay") so it keeps running
  without a console window and restarts automatically when Windows boots.
  Use this on the always-on relay box (a VPS or an always-on PC).

  Before this, you must also open the relay port (default 8443) in that box's
  firewall / NAT so Host and Controller can reach it from the internet.

.EXAMPLE
  # Install on the default port 8443 (creates a self-signed cert under the
  # publish folder under .relay\), auto-start, and start now.
  powershell -ExecutionPolicy Bypass -File scripts\install-relay-service.ps1

.EXAMPLE
  # Install on another port.
  powershell -ExecutionPolicy Bypass -File scripts\install-relay-service.ps1 -Port 9000

.EXAMPLE
  # Use a real certificate (skip CA distribution).
  powershell -ExecutionPolicy Bypass -File scripts\install-relay-service.ps1 `
      -Cert C:\certs\relay.pfx -CertPass "secret"

.EXAMPLE
  # Remove the service.
  powershell -ExecutionPolicy Bypass -File scripts\install-relay-service.ps1 -Uninstall
#>
[CmdletBinding()]
param(
    [int]$Port = 8443,
    [string]$Cert = "",
    [string]$CertPass = "",
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$svcName = "RdpV.Relay"
$deploy = Join-Path $env:ProgramData "RdpV\relay"

# --- Self-elevate so service creation / firewall changes always work. -------
function Test-Admin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent())
        .IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
if (-not (Test-Admin)) {
    Write-Host "This script needs Administrator rights. Relaunching elevated..."
    $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"")
    $argList += $args
    try {
        Start-Process -FilePath "powershell.exe" -ArgumentList $argList -Verb RunAs -Wait
    } catch {
        Write-Host "Elevation cancelled by user. Aborting." -ForegroundColor Yellow
    }
    exit $LASTEXITCODE
}

function Invoke-Scl([string]$line) {
    Write-Host "> $line"
    & "sc.exe" $line.Split(' ')
    if ($LASTEXITCODE -ne 0) {
        throw "sc.exe failed (exit $LASTEXITCODE): $line"
    }
}

# Opens (or refreshes) the inbound firewall rule for the relay port. No-op when
# an identical rule already exists so re-runs are idempotent.
function Update-FirewallRule([int]$port) {
    $ruleName = "RdpV Relay $port"
    $existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Firewall rule '$ruleName' already exists - leaving as is."
        return
    }
    Write-Host "Opening port $port in Windows Firewall..."
    try {
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow `
            -Protocol TCP -LocalPort $port -Profile Any | Out-Null
        Write-Host "Firewall rule '$ruleName' created."
    } catch {
        Write-Host "Could not create firewall rule via New-NetFirewallRule; trying netsh..." -ForegroundColor Yellow
        & "netsh.exe" advfirewall firewall add rule name=$ruleName dir=in action=allow protocol=TCP localport=$port | Out-Null
    }
}

if ($Uninstall) {
    Write-Host "Stopping and removing service '$svcName'..."
    & "sc.exe" stop $svcName 2>$null | Out-Null
    & "sc.exe" delete $svcName 2>$null | Out-Null
    Write-Host "Service removed (if it existed)."
    exit 0
}

# 1) Publish the relay (single-file, self-contained).
$env:Path = "$env:USERPROFILE\.dotnet;" + $env:Path   # ensure dotnet on PATH (PS 5.1)
Write-Host "Publishing relay..."
dotnet publish (Join-Path $root "src\RelayServer\RelayServer.csproj") `
    -c Release -r win-x64 --self-contained true -o $deploy
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed" }

# 2) Build the service command line.
$exe = Join-Path $deploy "RdpV.RelayServer.exe"
$argsForService = @("--service", "$Port")
if ($Cert) { $argsForService += @("--cert", "$Cert", "--certpass", $CertPass) }

$escapedExe = '"' + $exe + '"'
$binPath = ($argsForService | ForEach-Object { '"' + ($_ -replace '"','\"') + '"' }) -join ' '
$binPath = "$escapedExe $binPath"

# 3) Create the service (auto start).
Write-Host "Creating service '$svcName' (port $Port)..."
$existing = Get-Service -Name $svcName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Service already exists - reconfiguring."
    & "sc.exe" stop $svcName 2>$null | Out-Null
    & "sc.exe" config $svcName binPath= $binPath start= auto | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "sc config failed" }
} else {
    sc.exe create $svcName start= auto binPath= $binPath DisplayName= "RdpV Relay" 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "sc create failed" }
}

# 4) Start it.
Write-Host "Starting service..."
sc.exe start $svcName | Out-Null

Start-Sleep -Seconds 2
$svc = Get-Service -Name $svcName
Write-Host ("Relay service status: {0}" -f $svc.Status)

# 5) Open the port in the firewall (idempotent).
Update-FirewallRule $Port

$certHint = Join-Path $deploy ".relay\relay-ca.crt"
if (Test-Path $certHint) {
    Write-Host ""
    Write-Host "IMPORTANT - distribute this CA file to every Controller/Host client:"
    Write-Host "  $certHint"
}

Write-Host ""
Write-Host "Relay is running on port $Port and auto-starts on boot."
Write-Host "Windows Firewall is open for TCP $Port (inbound)."
Write-Host "If clients are outside your LAN, still forward port $Port in your router / NAT to this machine."
