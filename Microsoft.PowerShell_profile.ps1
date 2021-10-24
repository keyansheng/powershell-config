$PSDefaultParameterValues['*:Encoding'] = 'Default'
function Invoke-CMD { cmd /c @args }
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
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -HistorySavePath $env:TEMP\history.ps1
Set-Alias c Invoke-CMD
