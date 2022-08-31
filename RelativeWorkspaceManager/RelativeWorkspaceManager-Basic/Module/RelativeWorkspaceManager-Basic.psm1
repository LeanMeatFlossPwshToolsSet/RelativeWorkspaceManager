$Script:WorkSpacesStack=[System.Collections.ArrayList]@()
function Use-Workspace{
    param (
        [Parameter(ValueFromPipeline)]
        [string]
        $ProjectRootPath,
        [scriptblock]
        $Process
    )    
    process{
        $lastIndex=$Script:WorkSpacesStack.Add((Resolve-Path $ProjectRootPath).Path)
        &$Process
        $Script:WorkSpacesStack.Remove($lastIndex)
    }
}
function Get-CurrentWorkspace{
    process{
        return $Script:WorkSpacesStack[-1]
    }
}
function Get-FullPathFromRelativePathToWorkspace{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $RelativePath
    )
    process{
        Get-CurrentWorkspace|Join-PathImproved "$RelativePath"
    }
}
function Get-AllChildInRelativePath{
    param(
        [Parameter(ValueFromPipeline,Mandatory)]
        $RelativePath
    )
    process{
        if(Test-RelativePath $RelativePath){
            $RelativePath|Get-FullPathFromRelativePathToWorkspace|Get-ChildItem -Recurse
        }
        
    }
}
function Get-RelativePathToWorkspace{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $FullPath
    )
    process{
        $FullPath|Get-RelativePath -RootPath (Get-CurrentWorkspace)
    }
}
