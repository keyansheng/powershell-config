$PSDefaultParameterValues['*:Encoding'] = 'Default'
function Hide-Item { (Get-Item @args).Attributes += 'Hidden' }
function Show-Item { (Get-Item @args -Force).Attributes -= 'Hidden' }
function Update-ScoopApps {
    $ScoopArgs = $args
    if (!$ScoopArgs) { $ScoopArgs += '*' }
    scoop update @ScoopArgs
    scoop cleanup @ScoopArgs -k
}
function Set-Journal ([datetime] $Date = (Get-Date) ) {
    $ISODate = $Date.ToString('yyyy-MM-dd')
    $JournalPath = Join-Path $env:JOURNAL "$ISODate.md"
    $Action = if (Test-Path $JournalPath) { 'Update' } else { 'Add' }
    vim $JournalPath
    git -C $env:JOURNAL add $JournalPath
    git -C $env:JOURNAL commit -m "$Action $ISODate"
}
function Measure-Duration (
    [string]$EndTime,
    [string]$StartTime = 0
) {
    try {
        [TimeSpan]::Parse($EndTime).TotalSeconds - [TimeSpan]::Parse($StartTime).TotalSeconds
    } catch {
        $EndTime - $StartTime
    }
}
function New-VideoClip (
    [string] $SourceFile,
    [string] $StartTime,
    [string] $EndTime,
    [string] $DestinationFile = 'video.mp4'
) {
    ffmpeg -ss $StartTime -i $SourceFile -t (Measure-Duration $EndTime $StartTime) $DestinationFile
}
function New-VideoClipYouTube (
    [string] $Url,
    [string] $StartTime,
    [string] $EndTime,
    [string] $DestinationFile = 'video.mp4',
    [string] $TempFile = 'temp'
) {
    youtube-dl $Url -f bestvideo[ext=webm]+bestaudio[ext=webm] -o $TempFile
    New-VideoClip "$TempFile.webm" $StartTime $EndTime $DestinationFile
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -HistorySavePath $env:TEMP\history.ps1
Remove-Item Alias:\* -Force -Exclude cd
