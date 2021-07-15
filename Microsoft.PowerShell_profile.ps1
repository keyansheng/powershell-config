$PSDefaultParameterValues['*:Encoding'] = 'Default'
function Get-SymbolicLink { cmd /c dir /al /s | Where-Object { $_ -match 'symlink' } }
function Get-SymbolicLinkDirectory { cmd /c dir /al /s | Where-Object { $_ -match 'symlinkd' } }
function Get-Junction { cmd /c dir /al /s | Where-Object { $_ -match 'junction' } }
function New-SymbolicLink { cmd /c mklink @args }
function New-SymbolicLinkDirectory { cmd /c mklink /d @args }
function New-Junction { cmd /c mklink /j @args }
function Hide-Item { (Get-Item @args).Attributes += 'Hidden' }
function Show-Item { (Get-Item @args -Force).Attributes -= 'Hidden' }
function Update-ScoopApps {
    $ScoopArgs = $args
    if (!$ScoopArgs) { $ScoopArgs += '*' }
    scoop update @ScoopArgs
    scoop cleanup @ScoopArgs -k
}
function Set-Journal ([string] $Date = (Get-Date -Format 'yyyy-MM-dd') ) {
    $JournalPath = Join-Path $env:JOURNAL "$Date.md"
    $Action = if (Test-Path $JournalPath) { 'Update' } else { 'Add' }
    vim $JournalPath
    git -C $env:JOURNAL add $JournalPath
    git -C $env:JOURNAL commit -m "$Action $Date"
}
function Send-Journal { git -C $env:JOURNAL push }
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
    ffmpeg -ss $StartTime -i $SourceFile -t (Measure-Duration $EndTime $StartTime) $DestinationFile -y
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
Set-Alias gsl Get-SymbolicLink
Set-Alias gsld Get-SymbolicLinkDirectory
Set-Alias gj Get-Junction
Set-Alias nsl New-SymbolicLink
Set-Alias nsld New-SymbolicLinkDirectory
Set-Alias nj New-Junction
Set-Alias hi Hide-Item
Set-Alias shi Show-Item
Set-Alias udsa Update-ScoopApps
Set-Alias sj Set-Journal
Set-Alias sdj Send-Journal
Set-Alias msd Measure-Duration
Set-Alias nvc New-VideoClip
Set-Alias nvcy New-VideoClipYouTube
