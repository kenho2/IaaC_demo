[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$WorkloadName,

    [string]$WorkingDirectory = "c:\Projects\IaaC_demo\environments\homelab",
    [string]$BackendConfig = "c:\Projects\IaaC_demo\environments\homelab\backend.hcl",
    [switch]$AutoApprove
)

. "c:\Projects\IaaC_demo\scripts\load-homelab-env.ps1"

$terraform = Get-Command terraform -ErrorAction Stop

function Invoke-Terraform {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    & $terraform.Source @Args
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform command failed (exit code $LASTEXITCODE): terraform $($Args -join ' ')"
    }
}

if (Test-Path $BackendConfig) {
    Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "init", "-input=false", "-reconfigure", "-backend-config=$BackendConfig")
}
else {
    Write-Warning "Backend config not found at $BackendConfig. Falling back to default backend initialization."
    Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "init", "-input=false")
}

$stateLines = Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "state", "list")

$escapedName = [Regex]::Escape($WorkloadName)
$addressPattern = '^(module\.proxmox_vms(?:_strict)?\["' + $escapedName + '"\]\.proxmox_virtual_environment_vm\.this|module\.proxmox_lxcs\["' + $escapedName + '"\]\.proxmox_virtual_environment_container\.this)$'

$matches = @($stateLines | Where-Object { $_ -match $addressPattern })

if ($matches.Count -eq 0) {
    throw "No managed VM/LXC found in Terraform state for workload '$WorkloadName'."
}

if ($matches.Count -gt 1) {
    throw "Multiple resources match workload '$WorkloadName': $($matches -join ', '). Resolve state ambiguity before targeted destroy."
}

$target = $matches[0]

$targetArg = "-target=$target"

$destroyArgs = @(
    "-chdir=$WorkingDirectory",
    "destroy",
    "-input=false",
    $targetArg
)

if ($AutoApprove) {
    $destroyArgs += "-auto-approve"
}

if ($PSCmdlet.ShouldProcess($target, "terraform destroy target")) {
    # Use cmd /c to preserve literal quotes in the -target address
    $argString = $destroyArgs -join ' '
    cmd /c "`"$($terraform.Source)`" $argString"
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform command failed (exit code $LASTEXITCODE): terraform $argString"
    }
}
