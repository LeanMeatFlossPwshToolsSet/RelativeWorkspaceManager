BeforeAll{
    $currentTestModuleName=([System.IO.FileInfo]$PSCommandPath).Name.Replace(".Tests.ps1","")
    $env:PSModulePath=(Resolve-Path "$PSScriptRoot/..").Path+[IO.Path]::PathSeparator+$env:PSModulePath
    $moduleManifestFile=Import-PowerShellDataFile  "$PSScriptRoot/$currentTestModuleName.psd1"
    # install dependency modules
    $moduleManifestFile.RequiredModules|Foreach-Object{
        if(-not (Get-Module $_)){
             # install them
             Install-Module $_ -Force
        }
    }
    Import-Module $currentTestModuleName -Force
}
Describe "Use-Workspace" {
    It "Test for Get-FileNameFromPath"{
        {""|Use-Workspace}|Should -Not -Throw
    }
}