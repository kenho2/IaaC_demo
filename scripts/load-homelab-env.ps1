param(
    [string]$EnvFile = "c:\Projects\IaaC_demo\environments\homelab\.env"
)

function Test-ProxmoxApiTokenFormat {
    param(
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    # Expected format: user@realm!tokenid=secret
    return $Value -match '^[^=\s!@]+@[^=\s!]+![^=\s]+=[^=\s]+$'
}

if (-not (Test-Path $EnvFile)) {
    return
}

Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()

    if (-not $line -or $line.StartsWith("#")) {
        return
    }

    $parts = $line -split '=', 2
    if ($parts.Count -ne 2) {
        return
    }

    $name = $parts[0].Trim()
    $value = $parts[1].Trim().Trim('"').Trim("'")
    [Environment]::SetEnvironmentVariable($name, $value, 'Process')
}

$tfToken = [Environment]::GetEnvironmentVariable('TF_VAR_proxmox_api_token', 'Process')
$apiToken = [Environment]::GetEnvironmentVariable('PROXMOX_VE_API_TOKEN', 'Process')

if (-not $tfToken -and $apiToken) {
    [Environment]::SetEnvironmentVariable('TF_VAR_proxmox_api_token', $apiToken, 'Process')
    $tfToken = $apiToken
}

if (-not $apiToken -and $tfToken) {
    [Environment]::SetEnvironmentVariable('PROXMOX_VE_API_TOKEN', $tfToken, 'Process')
    $apiToken = $tfToken
}

if ($tfToken -and $tfToken -match '(?i)replace-me|changeme|example') {
    throw "TF_VAR_proxmox_api_token appears to be a placeholder. Set a real Proxmox token in $EnvFile."
}

if ($apiToken -and $apiToken -match '(?i)replace-me|changeme|example') {
    throw "PROXMOX_VE_API_TOKEN appears to be a placeholder. Set a real Proxmox token in $EnvFile."
}

if ($tfToken -and -not (Test-ProxmoxApiTokenFormat -Value $tfToken)) {
    throw "TF_VAR_proxmox_api_token has invalid format. Expected user@realm!tokenid=secret."
}

if ($apiToken -and -not (Test-ProxmoxApiTokenFormat -Value $apiToken)) {
    throw "PROXMOX_VE_API_TOKEN has invalid format. Expected user@realm!tokenid=secret."
}
