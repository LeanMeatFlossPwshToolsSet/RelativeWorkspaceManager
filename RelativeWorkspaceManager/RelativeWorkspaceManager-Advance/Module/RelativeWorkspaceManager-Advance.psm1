function Use-WorkspaceItemLock{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $LockName,
        [parameter(Position=1)]
        [scriptblock]
        $Process,
        [int]
        $WaitSeconds=1,
        [string]
        $LocksPath=".Locks"
    )
    begin{
        $LocksPath=$LocksPath|Resolve-DirWithRelativePath
    }
    process{
        $uid=New-Guid
        $lockFilePath=$locksPath|Join-PathImproved "$LockName.lock"
        while($true){
            while ($lockFilePath|Test-RelativePath) {
                Start-Sleep -Seconds $WaitSeconds
            }
            New-FileToRelativePath -RelativePath $lockFilePath -Value $uid|Out-Null
            if(($lockFilePath|Get-ContentFromRelativePath -Raw)-eq $uid){
                break
            }
        }       
        if($Process){
            &$Process
        }         
        $lockFilePath|Remove-ItemFromRelativePath
    }
}