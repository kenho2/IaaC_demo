param(
  [string]$WorkingDirectory = "c:\Projects\IaaC_demo\environments\homelab",
  [string]$PlanPath         = "tfplan.binary"
)

. "c:\Projects\IaaC_demo\scripts\load-homelab-env.ps1"

$terraform = Get-Command terraform -ErrorAction Stop
$planFile = Join-Path $WorkingDirectory $PlanPath

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

if (-not (Test-Path $planFile)) {
  throw "Plan file not found: $planFile. Run scripts/terraform-plan.ps1 first."
}

Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "apply", "-input=false", "-auto-approve", $PlanPath)

