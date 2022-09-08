$Script:WorkSpacesStack=[System.Collections.ArrayList]@()
function Use-Workspace{
    param (
        [Parameter(ValueFromPipeline)]
        [string]
        $ProjectRootPath,
        [Parameter(Position=1)]
        [scriptblock]
        $Process
    )    
    process{
        if(-not (Test-Path $ProjectRootPath)){
            New-Item $ProjectRootPath -ItemType Directory|Out-Null
        }
        $lastIndex=$Script:WorkSpacesStack.Add((Resolve-PathImproved -Path $ProjectRootPath))
        if($Process){
            &$Process
        }        
        $Script:WorkSpacesStack.Remove($lastIndex)
    }
}
function Use-RelativeLocation{
    param (
        [Parameter(ValueFromPipeline)]
        [string]
        $LocationInRelativePath="",
        [Parameter(Position=1)]
        [scriptblock]
        $Process
    ) 
    process{
        $Location=Get-Location
        Set-Location ($LocationInRelativePath|Get-FullPathFromRelativePathToWorkspace)
        if($Process){
            &$Process
        } 
        Set-Location  $Location
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
function Test-RelativePath{
    param(
        [Parameter(ValueFromPipeline)]
        [string]
        $RelativeFilePath
    )
    process{
        return Test-Path ($RelativeFilePath|Get-FullPathFromRelativePathToWorkspace)
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
            $RelativePath|Get-FullPathFromRelativePathToWorkspace|Get-ChildItem -Recurse:$Recurse
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
function Remove-ItemFromRelativePath{
    param(
        [parameter(ValueFromPipeline)]    
        [string]
        $RelativePath
    )
    process{
        $RelativePath|Get-FullPathFromRelativePathToWorkspace|Remove-Item -Recurse -Force
    }
}
function New-FileToRelativePath{
    param(    
        [parameter(ValueFromPipeline)]    
        [string]
        $RelativePath,
        [parameter(ValueFromPipeline)]   
        [string]
        $Value
    )
    process{
        New-Item ($RelativePath|Get-FullPathFromRelativePathToWorkspace) -ItemType File -Value $Value -Force
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
        $RelativePath|Get-FullPathFromRelativePathToWorkspace|Get-Content -Path {$_} -Raw:$Raw
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
    begin{
        # $RelativePath|New-FileToRelativePath     
        # $StringBuffer=[System.Collections.ArrayList]@()   
    }
    process{
        ($Content)|Out-File -FilePath ($RelativePath|Get-FullPathFromRelativePathToWorkspace) -Force:$Force
        
    }
    end{
        
    }
}
function Resolve-DirWithRelativePath{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $SubFolderName,
        [switch]
        $Force
    )
    process{
        $newPath=$SubFolderName|Get-FullPathFromRelativePathToWorkspace
        if($Force){
            Remove-Item $newPath -Recurse -Force -ErrorAction Continue
        }
        if(-not (Test-Path ($newPath))){
            New-Item -Path ($newPath) -ItemType Directory|Out-Null
        }
        return $SubFolderName  
    }
}