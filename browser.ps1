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
    elseif ($Browser -eq 'edge' -and $DataType -eq 'bookmarks') { $Path = "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks" }
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history') { $Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite" }
    elseif ($Browser -eq 'opera' -and $DataType -eq 'history') { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History" }
    elseif ($Browser -eq 'opera' -and $DataType -eq 'bookmarks') { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks" }

    $Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
    $Value | ForEach-Object {
        $Key = $_
        if ($Key -match $Search){
            New-Object -TypeName PSObject -Property @{
                User = $env:UserName
                Browser = $Browser
                DataType = $DataType
                Data = $_
            }
        }
    } 
}

$OutputFile = "$Env:USERPROFILE\Desktop\BrowserData.txt"

Get-BrowserData -Browser "edge" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "edge" -DataType "bookmarks" >> $OutputFile
Get-BrowserData -Browser "chrome" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "chrome" -DataType "bookmarks" >> $OutputFile
Get-BrowserData -Browser "firefox" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "opera" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "opera" -DataType "bookmarks" >> $OutputFile
