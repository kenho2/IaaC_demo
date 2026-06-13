param(
  [string]$WorkingDirectory = "c:\Projects\IaaC_demo\environments\homelab",
  [string]$BackendConfig    = "c:\Projects\IaaC_demo\environments\homelab\backend.hcl",
  [string]$PlanPath         = "tfplan.binary",
  [string]$PlanJsonPath      = "tfplan.json"
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
} else {
  Write-Warning "Backend config not found at $BackendConfig. Falling back to default backend initialization."
  Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "init", "-input=false")
}

Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "fmt", "-check", "-recursive")
Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "validate")
Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "plan", "-input=false", "-out=$PlanPath")
Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "show", "-json", $PlanPath) | Out-File -Encoding utf8 -FilePath (Join-Path $WorkingDirectory $PlanJsonPath)
