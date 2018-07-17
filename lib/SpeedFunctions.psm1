#Name:           Unofficial AussieBB Network Tester (http://abbnt.eth7.network)
#Version:        1.0.0

function DownloadSpeedTest
{
    Param($HashTable, $Path, $Extension)

    foreach ($testAddress in $HashTable.Keys)
    {
        # Add support for TLS 1.2 so https works.
        $TLSProtocol = [System.Net.SecurityProtocolType]'Tls12'
        [System.Net.ServicePointManager]::SecurityProtocol = $TLSProtocol

        $server = $HashTable[$testAddress]

        # File name
        $speedTestFile = "$($Path)speedtests.$($Extension)"

        # We need to save the test file to the system so we will dump it in the results directory
        $fileOutput = "$($Path)$(${testAddress}).test"

        # Use WebClient for the download
        $webClient = New-Object System.Net.WebClient

        # Display what we are testing, replacing the underscore in the name with space
        Write-Host " $($testAddress.replace('_' , ' '))"

        # Build the full URL
        $url = "$($server.Prefix)://$($server.Address)/$($server.DownloadFile)"

        # Get the current date/time so we can count how many seconds it takes to download the test file
        $start_time = Get-Date

        # Download the test file
        $webClient.DownloadFile($url, $fileOutput)

        # Get the current date/time and subtract the starting date/time and get the total seconds
        $end_time = (Get-Date).Subtract($start_time).totalseconds

        # Convert the time it took the file to download into Mbps and save the results
        $speed = (($server.SizeInMB / $end_time) * 8);
        "$($url) Average Speed = $([math]::Round($speed,2)) Mbps, Download Time = $($end_time) Seconds`n" | Out-File -Encoding utf8 -Append -FilePath $speedTestFile

        # We don't need the test file no more so delete it
        Remove-Item -path $fileOutput

        # Display Results
        Write-Host "    Average Speed = $([math]::Round($speed,2)) Mbps, Download Time = $([math]::Round($end_time, 2)) Seconds"
    }
}