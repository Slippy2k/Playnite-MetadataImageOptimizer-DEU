[CmdletBinding()]
param (
    [Parameter()]
    [string]$tag
)
Write-Host "Importing powershell-yaml"
Import-Module .\powershell-yaml\powershell-yaml.psd1
Write-Host "Imported powershell-yaml"

function Get-ReleaseData {
    param(
        [Parameter(Mandatory = $true, HelpMessage = "The tag name of this release")]
        [string]$tagName
    )
    #$releaseTitle = ""
    if ($tagName -match '[0-9]{4}(-[0-9]{2}){2}') {
        $all = $true
        $projectNames = Get-ProjectNames "all"
    }
    elseif ($tagName -match '(?<Name>[a-z]+)(?<Version>([0-9]+\.){1,3}[0-9]+)') {
        $all = $false
        $projectNames = Get-ProjectNames $Matches.Name
    }
    else {
        throw "No name + version match found for $t"
    }

    $manifests = @($projectNames | % { $_ | Get-ManifestData })

    if ($all) {
        $manifests = $manifests | Where-Object { $_.ReleaseDate -eq $tagName }
        $releaseTitle = $tagName
    }
    else {
        foreach ($m in $manifests) {
            if ($m.Version -ne $Matches.Version) {
                throw "Version mismatch: tag=$($Matches.Version) yaml=$($m.Version)"
            }
        }
        $releaseTitle = ($manifests | % { "$($_.DisplayName) $($_.Version)" }) -join " + "
    }

    Get-ReleaseDescription $manifests #side effect: writes to ./publish/release_notes.txt

    $output = @(
        "releasetitle=$releaseTitle"
        "projects=$($manifests | ConvertTo-Json -Compress)"
    )
    foreach ($o in $output) {
        Write-Host $o
        Write-Output $o >> $env:GITHUB_OUTPUT
    }
}

function Get-ProjectNames {
    param (
        [string]$tagProjectName
    )
    $projectNames = @{
        "metadataimageoptimizer" = @("MetadataImageOptimizer")
    }

    if ($tagProjectName -eq "all") {
        $o = @()
        foreach ($key in $projectNames.Keys) {
            $o += $projectNames[$key]
        }
        return $o
    }
    else {
        return $projectNames[$tagProjectName]
    }
}

function Get-ManifestData {
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$projectName
    )
    $extensionYamlData = Get-Content ".\src\$projectName\extension.yaml" | ConvertFrom-Yaml
    $manifestFiles = Get-ChildItem .\manifests\* -Include "*.yml", "*.yaml"
    foreach ($manifestFile in $manifestFiles) {
        $manifestContent = $manifestFile | Get-Content | ConvertFrom-Yaml
        if ($extensionYamlData.Id -ne $manifestContent.AddonId) { continue; }

        $latestRelease = $manifestContent.Packages[-1]
        if ($latestRelease.Version -ne $extensionYamlData.Version) {
            throw "Version mismatch: $projectName\extension.yaml: $($extensionYamlData.Version), $($manifestFile.Name): $($latestRelease.Version)"
        }
        return @{ Name = $projectName; DisplayName = $extensionYamlData.Name; Version = $latestRelease.Version; ReleaseDate = $latestRelease.ReleaseDate; Changelog = $latestRelease.Changelog }
    }
    throw "Could not find manifest for addon ID $($manifestContent.Id)"
}

function Get-ReleaseDescription {
    param (
        [Array]$manifests
    )
    $description = ""
    foreach ($m in @($manifests)) {
        if ($manifests.Length -gt 1) {
            $description += "## $($m.DisplayName) $($m.Version)`r`n"
        }
        foreach ($c in $m.Changelog) {
            $description += "- $c`r`n"
        }
        $description += "`r`n`r`n"
    }
    $description | Set-Content -Path "./publish/release_notes.txt"
    return $description
}

return Get-ReleaseData $tag