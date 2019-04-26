# Import Module
Import-Module PSGraph

#global
#Continue options (comment/uncomment)
#$DebugPreference = "Continue"
#$InformationPreference = "Continue"
#$warningpreference = "Continue"

#Silent continue options (comment/uncomment)
$DebugPreference = "SilentlyContinue"
$InformationPreference = "SilentlyContinue"
$warningpreference = "SilentlyContinue"

#Variable initialisation
$strFileName = "$env:TEMP\dnscache-temp.png"
$intFwdLookupCount = 0
$intRevLookupCount = 0
$intDepthControl = 7
$htIDs = @{}

$results = Get-DnsClientCache
$thisHTGraph = graph "myHTGraph" {
    node root -Attributes @{shape='rectangle'}
    
    Write-Debug "===Parsing==="
    foreach($result in $results){
        if($result.Entry -like "*.in-addr.arpa")
        {
            #Reverse lookup processing
            $intRevLookupCount = $intRevLookupCount +1
            $strOut = "Rev:" + $result.Entry
            Write-debug $strOut
        }
        else
        {
            #Forward lookup processing
            $thisDepth = 0
            $intFwdLookupCount = $intFwdLookupCount + 1
            $thisCacheEntry = $result.Entry

            Write-debug "Fwd:$thisCacheEntry"

            #Split our entry text on "."
            $subs= $thisCacheEntry.Split(".")           

            #We expect a minum of 2 strings as all muti-label entries will contain one "." minimum
            if($subs.Count -gt 1)
            {   
                #TLD processing (com, org, net etc)
                $thisID = $subs[$subs.Count-1]

                if($htIDs.ContainsKey($thisID) -eq $false)
                {
                #if unique add to our hastable and create an edge
                    $htIDs.add($thisID,1)
                    node $thisID
                    edge -from root -to $thisID
                }

                $previousNodeID = $thisID
                Write-debug ">>>New:$thisCacheEntry<<<" 
                
                #We want to continue processing IDs and labels limited only by depth control or we get to the end of labels
                # www.google.com. Label =www, ID=www.google.com 
                while($thisDepth -le ($subs.Count-2) -and ($thisDepth -lt $intDepthControl))
                {
                    $intSubCount = $subs.Count
                    Write-debug  $"Substring count:$intSubCount"
                    Write-debug "This depth:$thisDepth"

                    #Determine the node label based on the depth working from right to left as we increment the depth counter
                    $thisNodeLabel = $subs[($subs.Count-2-$thisDepth)]

                    #Form the node ID from an array of entry substrings from the rightmost substring (-1) to that based on the depth through iteration
                    $thisArrSubs = $subs[($subs.Count-2 - $thisDepth)..($subs.Count-1)]
                    $thisNodeID =  [string]::Join(".",$thisArrSubs)
                    
                    Write-Debug "ID:$thisNodeID"
                    Write-Debug "Label:$thisNodeLabel"
                    
                    #if unique add to the HT, create a node and create an edge to the parent node
                    if($htIDs.ContainsKey($thisNodeID) -eq $false)
                    {                    
                        $htIDs.add($thisNodeID,1)
                        node $thisNodeID -Attributes @{label=$thisNodeLabel}
                        edge -from $previousNodeID -to $thisNodeID
                        Write-Debug "Not IN HT: $thisNodeID"
                    }
                    else {
                        Write-Debug "IN HT: $thisNodeID"
                    }

                    #Set our previousNodeID so we can create edges if the while loop iterates again
                    $previousNodeID = $thisNodeID
                    $thisDepth = $thisDepth + 1
                }
                Write-debug ">>>End<<<"
            }
            
        }
    }    
}
Write-Debug "Forward entry count:$intFwdLookupCount" 
Write-Debug "Reverse entry count:$intRevLookupCount"

#Create the graph and open
$thisHTGraph | Export-PSGraph -ShowGraph -DestinationPath $strFileName