<#
.SYNOPSIS
Creates a new offline installer of Build Tools for Visual Studio with a
pre-selected set of workloads.

.DESCRIPTION
The following workloads are included in the new offline installer:
 - Microsoft.VisualStudio.Workload.MSBuildTools
 - Microsoft.VisualStudio.Workload.NetCoreBuildTools

The constructed Artifactory URI is based on this pattern:
    http://artifactory-base-uri/repo/org/module/module-date.zip
#>

[CmdletBinding()]
Param(
    # URI of bootstrapper (online installer)
    [string] $BootstrapperUri = 'https://aka.ms/vs/15/release/vs_buildtools.exe',

    # Artifactory base URI
    [string] $ArtifactoryBaseUri = 'http://artrepo.daptiv.com:8081/artifactory',

    # Artifactory repo
    [string] $ArtifactoryRepo = 'installs',

    # Artifactory org
    [string] $ArtifactoryOrg = 'microsoft',

    # Artifactory module (filename without extension) of offline installer
    [string] $ArtifactoryModule = 'visual_studio_build_tools_offline_installer',

    # Artifactory credential used for deployment (in basic auth format "user:base64apikey" or "user:base64password")
    [Parameter(Mandatory = $true)]
    [string] $ArtifactoryCredential,

    # Output TeamCity-compatible log
    [switch] $TeamCity
)

$ErrorActionPreference = 'Stop'

function New-WorkDirectory() {
    $path = [System.IO.Path]::GetFullPath((Join-Path $PWD 'vsbuildtools'))
    Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
    return (New-Item $path -ItemType Directory).FullName
}

function Get-ArtifactoryUri($properties = @{}) {
    $versionedFilename = "$ArtifactoryModule-$($properties.createDate).zip"
    $uri = [String]::Join('/', @($ArtifactoryBaseUri, $ArtifactoryRepo, $ArtifactoryOrg, $ArtifactoryModule, $versionedFilename))

    $propertyMatrix = ''
    $properties.GetEnumerator() | Sort-Object | ForEach-Object { $propertyMatrix += "$($_.Name)=$($_.Value);" }

    return [System.Uri]"$uri;$propertyMatrix"
}

function Get-Workloads($installerParams = @()) {
    $regex = '^--add Microsoft\.VisualStudio\.Workload\.(.*)$'
    return [String]::Join(',', ($installerParams | Where-Object { $_ -match $regex } | ForEach-Object { $matches[1] }))
}

function Get-InstallerVersion($installerPath) {
    return [System.Diagnostics.FileVersionInfo]::GetVersionInfo($installerPath).FileVersion
}

function Get-Headers($filePath) {
    $base64Credential = ([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ArtifactoryCredential)))

    return @{
        'Authorization' = "Basic $base64Credential"
        'Content-Length' = (Get-Item $filePath).Length
        'X-Checksum-Sha1' = (Get-FileHash $filePath -Algorithm SHA1).Hash
    }
}

$logStatuses = @{
    Normal = 'NORMAL'
    Warning = 'WARNING'
    Failure = 'FAILURE'
    Error = 'ERROR'
}

function Format-Message($message, $status = $logStatuses.Normal, $errorDetails = '') {
    if ($TeamCity) {
        $message = $message.replace("`n", '|n').replace("`r", '|r')
        return "##teamcity[message text='$message' status='$status' errorDetails='$errorDetails']"
    }

    if ($status -ne $logStatuses.Normal) {
        $message = "${status}: $message"
        if ($status -eq $logStatuses.Error) {
            $message += " :: $errorDetails"
        }
    }
    return $message
}

function Write-TCOutput($message, $status = $logStatuses.Normal, $errorDetails = '') {
    Write-Output Format-Message($message, $status, $errorDetails)
}

function Write-TCVerbose($message, $status = $logStatuses.Normal, $errorDetails = '') {
    if ($VerbosePreference -eq 'SilentlyContinue') {
        return
    }

    $message = Format-Message $message $status $errorDetails

    if ($TeamCity) {
        Write-Output $message
        return
    }

    Write-Verbose $message
}

function Start-LogBlock($block, $description) {
    if ($TeamCity) {
        Write-Output "##teamcity[blockOpened name='$block' description='$description']"
        return
    }

    Write-Output "[$block] $description"
}

function Stop-LogBlock($block) {
    if ($TeamCity) {
        Write-Output "##teamcity[blockClosed name='$block']"
        return
    }

    Write-Output "[$block] Completed"
}

<#---------------------
   Generate file paths
  ---------------------#>
$paths = @{}
$paths.work = New-WorkDirectory
$paths.archive = (Join-Path $paths.work "$ArtifactoryModule.zip")
$paths.bootstrapper = (Join-Path $paths.work 'vs_buildtools.exe')
$paths.layout = (Join-Path $paths.work 'layout')

Write-TCVerbose "Paths: $($paths | Format-List | Out-String)"

<#-------------------------------------
   Download bootstrap/online installer
  -------------------------------------#>
$bootstrapperDownloadParams = @{
    Uri = $BootstrapperUri
    OutFile = $paths.bootstrapper
}
Write-TCVerbose "Bootstrapper download params: $($bootstrapperDownloadParams | Format-List | Out-String)"

Start-LogBlock 'Download' 'Downloading bootstrapper from web'
Invoke-WebRequest @bootstrapperDownloadParams
Stop-LogBlock 'Download'

<#---------------------------------
   Create offline/layout installer
  ---------------------------------#>
$bootstrapperParams =
    '--add Microsoft.VisualStudio.Workload.MSBuildTools',
    '--add Microsoft.VisualStudio.Workload.NetCoreBuildTools',
    '--lang en-US',
    "--layout $($paths.layout)",
    '--quiet',
    '--wait'
Write-TCVerbose "Bootstrapper parameters: $([String]::Join(' ', $bootstrapperParams))"

Start-LogBlock 'Install' 'Running bootstrap of offline installer in the background'
$createDate = Get-Date
$bootstrapperProcess = Start-Process $paths.bootstrapper $bootstrapperParams -NoNewWindow -PassThru -Wait
if ($bootstrapperProcess.ExitCode -gt 0) {
    throw "Bootstrapper exited with code $($bootstrapperProcess.ExitCode)"
}
Stop-LogBlock 'Install'

<#--------
   Zip it
  --------#>
Start-LogBlock 'Archive' 'Creating offline installer archive'
Add-Type -Assembly System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($paths.layout, $paths.archive)
Stop-LogBlock 'Archive'

<#--------------------------
   Deploy it to Artifactory
  --------------------------#>
$uploadProperties = @{
    createDate = $createDate.ToString('yyyy.MM.dd')
    installerVersion = Get-InstallerVersion $paths.bootstrapper
    lang = 'en-US'
    workloads = Get-Workloads $bootstrapperParams
}

$uploadParams = @{
    Headers = Get-Headers $paths.archive
    InFile = $paths.archive
    Method = 'PUT'
    TimeoutSec = 3600  # upload from non-agent (outside AWS) is very slow
    Uri = Get-ArtifactoryUri $uploadProperties
    UseBasicParsing = $true
}
Write-TCVerbose "Upload params: $($uploadParams | Format-List | Out-String)"

Start-LogBlock 'Upload' 'Uploading offline installer to Artifactory'
Invoke-WebRequest @uploadParams
Stop-LogBlock 'Upload'
