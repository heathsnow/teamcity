Write-Host 'Configuring SQL Server trace flags...'

$server = $env:computerName
$sqlservice = "MSSQLSERVER"
$sqlagentservice = "SQLSERVERAGENT"
$flagsToAdd = ";-T845;-T1140;-T3226;-T3427;-T4135;-T9481"

[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
$sqlwmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer $server
$wmisvc = $sqlwmi.Services | where {$_.name -eq $sqlservice}
$wmisvc.StartupParameters = $wmisvc.StartupParameters + $flagsToAdd
$wmisvc.Alter()

$wmisvc.Stop()
Start-Sleep -seconds 15
$wmisvc.Start()

$wmiAgent = $sqlwmi.Services | where {$_.name -eq $sqlagentservice}
$wmiAgent.Start()
