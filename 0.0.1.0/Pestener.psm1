
$FunctionsPath = "$PSScriptRoot\Functions"
Get-ChildItem $FunctionsPath -Directory -Exclude "Tests" | ForEach-Object {
    . (join-path $FunctionsPath (Join-Path $_.BaseName "$($PSItem.BaseName).ps1"))
}