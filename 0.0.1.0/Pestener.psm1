$FunctionsPath = "$PSScriptRoot\Functions"
Get-ChildItem $FunctionsPath -Directory -Exclude "Tests" | foreach {
    . (join-path $FunctionsPath (Join-Path $_.BaseName "$($_.BaseName).ps1"))
}