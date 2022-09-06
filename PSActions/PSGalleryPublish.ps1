param(
    [string]
    $NugetKey,
    [string]
    $GitHubKey
)
$PSVersionTable
$gitUrl=(git remote get-url --all origin)
Write-Host "Current git url is $gitUrl"
$gitRepoName=($gitUrl.replace(".git","") -split "/")[-1]
Write-Host "Current git repo name is $gitRepoName"
$moduleBaseName=$gitRepoName.Replace("-","")
Write-Host "Current module base name $moduleBaseName"
$env:PSModulePath+=[IO.Path]::PathSeparator+"$($env:GITHUB_WORKSPACE)/$moduleBaseName"
# create temp module folder to by pass the error from depenedenct
$env:PSModulePath+=[IO.Path]::PathSeparator+"$($env:GITHUB_WORKSPACE)/tempModules"
New-Item "$($env:GITHUB_WORKSPACE)/tempModules" -ItemType Directory


git config user.name "CD Process"
git config user.email "CD.Process@users.noreply.github.com"

# new change here
# module dependency analysis
$PublishOrderHash=@{

}

Get-ChildItem -Path "$($env:GITHUB_WORKSPACE)/$moduleBaseName" -Directory |ForEach-Object{    
    $subModuleName=$_.Name   
    if(-not $PublishOrderHash.ContainsKey($subModuleName)){
        $PublishOrderHash[$subModuleName]=0
    }     
    $moduleManifestFile=Import-PowerShellDataFile  "$($env:GITHUB_WORKSPACE)/$moduleBaseName/$subModuleName/$subModuleName.psd1"
    $moduleManifestFile.RequiredModules|ForEach-Object{
        if(Test-Path "$($env:GITHUB_WORKSPACE)/$moduleBaseName/$_"){
            if($PublishOrderHash.ContainsKey($_)){
                $PublishOrderHash[$_]=$PublishOrderHash[$_]+1
            }
            else{
                $PublishOrderHash[$_]=1
            }
        }
        else{
            if(-not (Test-Path "$($env:GITHUB_WORKSPACE)/tempModules/$_")){
                New-Item "$($env:GITHUB_WORKSPACE)/tempModules/$_" -ItemType Directory
                New-ModuleManifest -Path "$($env:GITHUB_WORKSPACE)/tempModules/$_/$_.psd1"
            }            
        }
    }
}
$PublishOrderHash|Format-Table|Out-String|Write-Host


Write-Host "
The Ps modules path are:
$env:PSModulePath
"
dir env:
Set-PSRepository PSGallery -InstallationPolicy Trusted
git fetch --all --tags
Write-Host "Current Tags:"
git tag
$taggedVersions=@()+(git tag -l "v[0-9.]*" --sort="v:refname")
$taggedVersions|Write-Host

$taggedVersion=$taggedVersions[-1]
if($LASTEXITCODE -ne 0 -or(-not $taggedVersion)){
    $taggedVersion="v0.0.1"
    Write-Host "Using $taggedVersion as the init version."
}
$taggedVersionArray=$taggedVersion.Split([string[]]@(".","v"),[System.StringSplitOptions]::RemoveEmptyEntries)
$taggedVersionArray[-1]=([int]$taggedVersionArray[-1]+1).ToString()




$submitVersion=$taggedVersionArray -join "."
$GitNewTaggedVersion="v$($submitVersion)"

# increasing the version
$rev=$env:GITHUB_SHA
Write-Host "
Current Commit $rev
New Version need to be tagged $GitNewTaggedVersion
"

$moduleBaseName=$gitRepoName.Replace("-","")
if(Test-Path "$($env:GITHUB_WORKSPACE)/$moduleBaseName"){
    Get-ChildItem -Path "$($env:GITHUB_WORKSPACE)/$moduleBaseName" -Directory|Sort-Object {$PublishOrderHash[$_.Name]} -Descending|ForEach-Object{
    
        $moduleOnCloud=Find-Module -Name $_.Name -ErrorAction Continue
        # $moduleOnCloud|Write-Host
        if($moduleOnCloud){
            $cloudVersion=$moduleOnCloud.Version.Split([string[]]@(".","v"),[System.StringSplitOptions]::RemoveEmptyEntries)
            for ($i = 0; $i -lt $cloudVersion.Count; $i++) {
                <# Action that will repeat until the condition is met #>
                if($taggedVersionArray[$i] -le $cloudVersion[$i]){
                    $taggedVersionArray[$i]=$cloudVersion[$i]
                    if($i -eq 2){
                        $taggedVersionArray[$i]=(([int]$cloudVersion[$i])+1).ToString()
                    }
                }
                $newSubmitVersion=$taggedVersionArray -join "."
                if(-not $newSubmitVersion.Equals($submitVersion)){
                    $submitVersion=$taggedVersionArray -join "."
                    $GitNewTaggedVersion="v$($submitVersion)"
                    Write-Host "
                    Version update
                    New Version need to be tagged $GitNewTaggedVersion
                    "
                }
                
            }
        }
        Update-ModuleManifest -Path (Join-Path $_.FullName "$($_.Name).psd1") -ModuleVersion $submitVersion
        Test-ModuleManifest -Path (Join-Path $_.FullName "$($_.Name).psd1")
        if($env:GITHUB_REF_NAME -eq "main"){
            # main branch methods
            Publish-Module -Path "$($_.FullName)" -NuGetApiKey $NugetKey -Verbose -Force
            
        }
        else {
            # sub branch methods
            Publish-Module -Path "$($_.FullName)" -NuGetApiKey $NugetKey -WhatIf -Verbose
           
        }
    }
    if($env:GITHUB_REF_NAME -eq "main"){
        # main branch methods
        "Push tag to Repo"|Write-Host
        git tag -a $GitNewTaggedVersion $rev -m "Continous Delivery Version Submitted"
        git push origin "$GitNewTaggedVersion"
        
    }
    else{
        "In branch don't push the tag"|Write-Host
    }
}



