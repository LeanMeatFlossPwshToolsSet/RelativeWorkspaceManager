function Join-PathImproved {
    param (
        [parameter(ValueFromPipeline)]
        [string]
        $LeftPath,
        [parameter(Position=1)]
        [string[]]
        $RightPath=@("")
    )
    process{
        Join-Path $LeftPath @RightPath
    }    
}
function Resolve-PathImproved{
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $Path
    )
    process{
        $Path|Join-PathImproved
    }
}
function Select-ObjectImproved{
    param(
        [parameter(ValueFromPipeline)]
        [PSCustomObject[]]
        $InputObject,
        [int]
        $First=-1,
        [scriptblock]
        $UniqueHashScript
    )
    begin{
        $CurrentOutputNumber=0
    }
    process{
        if(($CurrentOutputNumber -ne $First)){
            if($UniqueHashScript){
                
            }
            $CurrentOutputNumber++
            return $InputObject
        }
    }
}
function Import-ModuleFromGallery{
    param(
        [parameter(ValueFromPipeline,Position=1)]
        [string]
        $ModuleName,
        [switch]
        $Force
    )
    process{
        if(Get-Module $ModuleName){

        }
        else{
            Install-Module $ModuleName -Force -Scope CurrentUser
        }
        $currentVersion=(Get-Module $ModuleName).Version
        $cloudVersion=(Find-Module $ModuleName).Version
        if($currentVersion -ne $cloudVersion){
            Update-Module $ModuleName
        }
        Import-Module $ModuleName -Force:$Force

    }
}
function Get-RelativePath{
    param (
        [parameter(ValueFromPipeline)]
        [string]
        $Path,
        [parameter(Position=0)]
        [string]
        $RootPath
    )
    process{
        [System.IO.Path]::GetRelativePath($RootPath,$Path)
    }
    
}