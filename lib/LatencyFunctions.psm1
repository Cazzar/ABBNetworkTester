#Name:           Unofficial AussieBB Network Tester (http://abbnt.eth7.network)
#Version:        1.0.0

function LatencyTest
{
    Param($HashTable, $Gateway, $Requests, $Path, $Extension)

    # If Gateway is true we'll attempt to find the default gateway and add it to the testAddresses array
    if($Gateway)
    {
        # Get the default route and hopefully extract the default gateway from the next hop
        [String]$gatewayAddress = Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty "NextHop"
        $HashTable["Default_Gateway"] = $gatewayAddress
    }

    foreach ($testAddress in $HashTable.Keys)
    {
        $address = $HashTable[$testAddress]

        # File name
        $latencyFile = "$($Path)$($address).latency.$($Extension)"

        # Display the address we are testing, replacing the underscore in the name with space
        Write-Host " $($testAddress.replace('_' , ' ')) [$($address)]"

        # Trace and ping the address and save results
        tracert $address | Out-File -Encoding utf8 -filepath $latencyFile
        ping $address -n $Requests | Out-File -Encoding utf8 -Append -filepath $latencyFile

        # Read the latency file to get results, had issues reading the command output
        $readLatencyFile = Get-Content $latencyFile | Select-Object -Last 3

        # Display Results
        foreach ($readLatencyFiles in $readLatencyFile)
        {
            # We don't want the Approximate round.... line
            if($readLatencyFiles -ne "Approximate round trip times in milli-seconds:")
            {
                Write-Host " $($readLatencyFiles)"
            }
        }
    }

}