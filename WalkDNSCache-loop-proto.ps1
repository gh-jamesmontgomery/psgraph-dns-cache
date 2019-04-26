#global
#Continue options (comment/uncomment)
#$DebugPreference = "Continue"
#$InformationPreference = "Continue"
#$warningpreference = "Continue"

#Silent continue options (comment/uncomment)
$DebugPreference = "SilentlyContinue"
$InformationPreference = "SilentlyContinue"
$warningpreference = "SilentlyContinue"

$results = Get-DnsClientCache
$intFwdLookupCount = 0
$intRevLookupCount = 0
$results
Write-Debug "===Parsing==="

$intDepthControl = 7

foreach($result in $results){
    if($result.Entry -like "*.in-addr.arpa")
    {
        $intRevLookupCount = $intRevLookupCount +1
        $strOut = "Rev:" + $result.Entry
        Write-Information $strOut
    }
    else
    {
        $thisDepth = 0
        $intFwdLookupCount = $intFwdLookupCount + 1
        Write-Debug "entering ELSE"
        $thisCacheEntry = $result.Entry
        Write-debug "Fwd:$thisCacheEntry"
        $subs= $thisCacheEntry.Split(".")
        Write-debug $subs.Count
        
        $thisDepth = 0
            
        if($subs.Count -gt 1)
        {   
            Write-debug ">>>New:$thisCacheEntry<<<"  
            while($thisDepth -le ($subs.Count-2) -and ($thisDepth -lt $intDepthControl))
            {
                $intSubCount = $subs.Count
                $strCount = 'Substring count:{0}' -f $intSubCount
                Write-debug  $strCount
                Write-debug "This depth:$thisDepth"
                $thisNodeLabel = $subs[($subs.Count-2-$thisDepth)]
                $thisArrSubs = $subs[($subs.Count-2 - $thisDepth)..($subs.Count-1)]
                $thisNodeID =  [string]::Join(".",$thisArrSubs)
                $thisDepth = $thisDepth + 1
                Write-Host "ID:$thisNodeID"
                Write-Host "Label:$thisNodeLabel"
            }
            Write-debug ">>>End<<<"
        }
        
    }
}
Write-Host "Forward lookups: $intFwdLookupCount"
Write-Host "Reverse lookups: $intRevLookupCount"