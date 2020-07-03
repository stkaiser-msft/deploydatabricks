param(
    [Parameter(Mandatory=$true)]
    [string] $ConfigFile
)


# Init
Install-Module -Name Az -AllowClobber -Scope CurrentUser
Install-Module -Name Az.Databricks -AllowPrerelease
if ((Get-AzContext).Count  -ne 1) {
    Write-Output "Use Connect-AzAccount to set your Azure context before running this script."
    exit 1
}
Register-AzResourceProvider -ProviderNamespace Microsoft.Databricks

# Read deployment configuration
try {
    $c = Get-Content $ConfigFile -Raw
    Invoke-Expression $c
}
catch {
    WriteLog "Could not open config file $ConfigFile."
    Exit 2
}


$SubscriptionName = (Read-Host "Subscription Name")
Set-AzContext -Subscription $SubscriptionName
New-AzDatabricksWorkspace `
    -Name $($config.WorkspaceName) `
    -ResourceGroupName $($config.RG) `
    -Location $($config.Location) `
    -ManagedResourceGroupName $($config.ManagedRG) `
    -Sku $($config.SKU)

Get-AzDatabricksWorkspace -Name $WorkspaceName -ResourceGroupName $RG |
  Select-Object -Property Name, SkuName, Location, ProvisioningState