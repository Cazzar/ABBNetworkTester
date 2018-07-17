#Name:           Unofficial AussieBB Network Tester (http://abbnt.eth7.network)
#Version:        1.0.1

# Format of the date and time for results directory
$dateTimeFormat = "dd-MM-yyy-HHmm"

# Directory to store the output logs
$resultsDirectoryName = "Results"

# File extension
$resultsFileExtension = "txt"

# List of addresses to check for latency
$latencyCheckAddresses = [ordered]@{
    AussieBB_DNS   = '202.142.142.142'
    Cloudflare_DNS = '1.1.1.1'
    Google_DNS     = '8.8.8.8'

    AussieBB_Speed_Website  = 'speed.aussiebroadband.com.au'
    Google_Website          = 'www.google.com'
}

# Check the default gateway ($TRUE or $FALSE)
# In rare instances this will not work, we are relying on second hop from 0.0.0.0/0 been gateway
$CheckDefaultGatewayLatency = $TRUE

# The number of echo Request messages to send
$echoRequestAmount = 50

# List of download addresses
$speedCheckAddresses = [ordered]@{
    Adelaide_AussieBB = @{
        Address      = 'lg-ade.aussiebroadband.com.au'
        DownloadFile = '50MB.test'
        SizeInMB     = '50'
        Prefix       = 'https'
    }
    Brisbane_AussieBB = @{
        Address      = 'lg-bne.aussiebroadband.com.au'
        DownloadFile = '50MB.test'
        SizeInMB     = '50'
        Prefix       = 'https'
    }
    Melbourne_AussieBB = @{
        Address      = 'lg-mel.aussiebroadband.com.au'
        DownloadFile = '50MB.test'
        SizeInMB     = '50'
        Prefix       = 'https'
    }
    Perth_AussieBB = @{
        Address  = 'lg-per.aussiebroadband.com.au'
        DownloadFile = '50MB.test'
        SizeInMB     = '50'
        Prefix       = 'https'
    }
    Sydney_AussieBB = @{
        Address      = 'lg-syd.aussiebroadband.com.au'
        DownloadFile = '50MB.test'
        SizeInMB     = '50'
        Prefix       = 'https'
    }
}

# Add support for TLS 1.2 so https works.
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Import-Module $PSScriptRoot\SpeedFunctions.psm1
Import-Module $PSScriptRoot\LatencyFunctions.psm1

# Title
Write-Host " Unofficial AussieBB Network Tester v1.0.1`n`n This can take a while. Please be patient,`n you will be prompted once the test has completed"

# Setup the results directory
[string]$localPath = Get-Location
$DirectoryPath  = "$($localPath)\$($resultsDirectoryName)\"
$filePath = "$($DirectoryPath)\$([DateTime]::Now.ToString($dateTimeFormat))\"

# Make the results directory
New-Item -ItemType Directory -Force -Path $filePath | Out-Null

# Perform POI check
Write-Host "`n----------------------`n Your POI`n----------------------"
Write-Host ' '((Invoke-WebRequest -Uri "https://www.aussiebroadband.com.au/__process.php?mode=CVCDropdown" -UseBasicParsing | ConvertFrom-Json) | Where-Object { $_.selected }).name

# Perform latency tests
Write-Host "`n----------------------`n Latency`n----------------------"
LatencyTest -HashTable $latencyCheckAddresses -Gateway $CheckDefaultGatewayLatency -Requests $echoRequestAmount -Path $filePath -Extension $resultsFileExtension

# Perform download speed tests
Write-Host "`n----------------------`n Download Speed`n----------------------"

DownloadSpeedTest -HashTable $speedCheckAddresses -Path $filePath -Extension $resultsFileExtension

# Ask if its time to close the command window
[string]$end = Read-Host -Prompt "`n Press Enter To Open Results Directory"

if([string]::IsNullOrWhiteSpace($end))
{
    # We are finished so open explorer to the results directory
    invoke-item $filePath
}