param(
  [string]$WorkingDirectory = "c:\Projects\IaaC_demo\environments\homelab",
  [string]$BackendConfig = "c:\Projects\IaaC_demo\environments\homelab\backend.hcl",
  [string]$PlanPath = "tfplan.binary",
  [string]$PlanJsonPath = "tfplan.json"
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

Write-Host "[1/5] terraform init"
if (Test-Path $BackendConfig) {
  Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "init", "-input=false", "-reconfigure", "-backend-config=$BackendConfig")
}
else {
  Write-Warning "Backend config not found at $BackendConfig. Falling back to default backend initialization."
  Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "init", "-input=false")
}

Write-Host "[2/5] terraform destroy"
Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "destroy", "-input=false", "-auto-approve")

Write-Host "[3/5] terraform plan"
Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "fmt", "-recursive")
Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "validate")
Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "plan", "-input=false", "-out=$PlanPath")
Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "show", "-json", $PlanPath) | Out-File -Encoding utf8 -FilePath (Join-Path $WorkingDirectory $PlanJsonPath)

Write-Host "[4/5] terraform apply"
Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "apply", "-input=false", "-auto-approve", $PlanPath)

Write-Host "[5/5] terraform plan (drift check)"
Invoke-Terraform -Args @("-chdir=$WorkingDirectory", "plan", "-input=false")
