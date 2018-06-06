[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [string] $InstallerArchiveFilePath
)

$artifactoryBaseUri = 'http://artrepo.daptiv.com:8081/artifactory'
$artifactoryRepo = 'installs'
$artifactoryOrg = 'microsoft'
$artifactoryModule = 'visual_studio_build_tools_offline_installer'
$installerArchive = "$artifactoryModule.zip"
$tempDir = Join-Path (Get-Item $env:TEMP) 'whatIfDefault'

function New-TemporaryDirectory {
    $tmpDir = Join-Path (Get-Item $env:TEMP).FullName "tmp_$([System.Guid]::NewGuid().ToString('N'))"
    $tmpDir = $tmpDir.Substring(0, ([System.Math]::Min($tmpDir.Length, 80))) # installer requires <= 80
    return (New-Item $tmpDir -ItemType Directory).FullName
}

function Get-LatestInstallerUri {
    return [System.Uri][String]::Join('/',
        @($artifactoryBaseUri, $artifactoryRepo, $artifactoryOrg, $artifactoryModule, "$artifactoryModule-[RELEASE].zip"))
}

function Test-VS2017MSBuild($vswhere) {
    return $vswhere.displayName -eq 'Visual Studio Build Tools 2017' `
        -and (Test-Path (Join-Path $vswhere.installationPath 'MSBuild\15.0\Bin\MSBuild.exe'))
}

try {
    $ErrorActionPreference = 'Stop'

    if ($PSCmdlet.ShouldProcess($env:TEMP, 'New-TemporaryDirectory')) {
        $tempDir = New-TemporaryDirectory
    }

    $installerArchivePath = Join-Path $tempDir $installerArchive
    $installerDownloadLocation = Get-LatestInstallerUri

    Write-Verbose "Installer archive: $installerArchive"
    Write-Verbose "Installer download: $installerDownloadLocation"
    Write-Verbose "Temp dir: $tempDir"
    Write-Verbose "Installer archive path: $installerArchivePath"

    if ($InstallerArchiveFilePath) {
        Write-Output 'Copying installer archive...'
        if ($PSCmdlet.ShouldProcess($InstallerArchiveFilePath, 'Copy-Item')) {
            Copy-Item $InstallerArchiveFilePath $installerArchivePath
            Write-Output 'Copied installer archive.'
        }
    } else {
        Write-Output 'Downloading installer archive...'
        if ($PSCmdlet.ShouldProcess($installerDownloadLocation, 'WebClient.DownloadFile')) {
            (New-Object System.Net.WebClient).DownloadFile($installerDownloadLocation, $installerArchivePath)
            Write-Output 'Downloaded installer archive.'
        }
    }

    Write-Output 'Expanding installer archive...'
    if ($PSCmdlet.ShouldProcess($installerArchivePath, 'Expand-Archive')) {
        Add-Type -Assembly System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($installerArchivePath, $tempDir)
        Write-Output 'Expanded installer archive.'
    }

    $installer = Join-Path $tempDir 'vs_setup.exe'

    $installerParams =
        '--add Microsoft.VisualStudio.Workload.MSBuildTools',
        '--add Microsoft.VisualStudio.Workload.NetCoreBuildTools',
        '--quiet',
        '--wait',
        '--norestart',
        '--noweb'

    Write-Output 'Starting installer in the background...'
    Write-Verbose "Installer: $installer"
    Write-Verbose "Installer parameters: $([String]::Join(' ', $installerParams))"
    if ($PSCmdlet.ShouldProcess($installer, 'Start-Process')) {
        $installerProcess = Start-Process $installer $installerParams -NoNewWindow -PassThru -Wait
        if ($installerProcess.ExitCode -gt 0) {
            throw "Installer exited with code $($installerProcess.ExitCode)"
        }
        Write-Output 'Installer completed.'
    }

    Write-Output 'Testing for success...'
    # https://github.com/Microsoft/vswhere
    $vswherePath = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (!(Test-Path $vswherePath)) {
        throw 'Testing failed: vswhere.exe not found'
    }
    $vswheres = & $vswherePath -products * -requires Microsoft.Component.MSBuild -format json `
        | Out-String `
        | ConvertFrom-Json
    $vswheres | ForEach-Object { Write-Verbose "vswhere: $_" }
    if ($vswheres.Where({ (Test-VS2017MSBuild $_) -eq $true }, 'First').Count -eq 0) {
        throw 'Testing failed: Build Tools for Visual Studio 2017 and/or MSBuild not found'
    }
    Write-Output 'Testing succeeded.'
} catch {
    throw
} finally {
    $ErrorActionPreference = 'Continue'

    Write-Output 'Cleaning up temp directory...'
    if ($PSCmdlet.ShouldProcess($tempDir, 'Remove-Item')) {
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Output 'Cleaned up temp directory.'
}
