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
function Get-FileInfoFromRelativePath{
    param(
        [Parameter(ValueFromPipeline)]
        $RelativePath
    )
    process{
        [System.IO.FileInfo]($RelativePath|Get-FullPathFromRelativePathToWorkspace)
    }
}
function Get-AllChildInRelativePath{
    param(
        [Parameter(ValueFromPipeline,Mandatory)]
        $RelativePath,
        [switch]
        $Recurse
    )
    process{
        if(Test-RelativePath $RelativePath){
            $RelativePath|Get-FullPathFromRelativePathToSource|Get-ChildItem -Recurse:$Recurse
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
function Get-ContentFromRelativePath{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $RelativePath,
        [switch]
        $Raw
    )
    process{
        $RelativePath|Get-FullPathFromRelativePathToWorkspace|Get-Content -Raw:$Raw
    }
}
function Out-FileToRelativePath{
    param(
        
        [string]
        $RelativePath,
        [switch]
        $Force,
        [parameter(ValueFromPipeline)]
        [string]
        $Content
    )
    process{
        $Content|Out-File -FilePath ($RelativePath|Get-FullPathFromRelativePathToWorkspace) -Force:$Force
    }
}