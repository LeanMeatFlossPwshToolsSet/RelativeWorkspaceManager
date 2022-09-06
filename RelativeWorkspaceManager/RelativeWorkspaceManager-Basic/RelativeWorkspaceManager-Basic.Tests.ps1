BeforeAll{
    $env:PSModulePath+=[IO.Path]::PathSeparator+(Resolve-Path "$PSScriptRoot/..")
    Import-Module RelativeWorkspaceManager-Basic -Force
}
Describe "Use-Workspace" {
    It "Test for Get-FileNameFromPath"{
        {"a"|Use-Workspace}|Should -Not -Throw
    }
}