
$FunctionsPath = "$PSScriptRoot\Functions"
Get-ChildItem $FunctionsPath -Directory -Exclude "Tests" | foreach {
    Write-Verbose "Test $($_.BaseName).ps1)"
    . (join-path $FunctionsPath (Join-Path $_.BaseName "$($_.BaseName).ps1"))
}