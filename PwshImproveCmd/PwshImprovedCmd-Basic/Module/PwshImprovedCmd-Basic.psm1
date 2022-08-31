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