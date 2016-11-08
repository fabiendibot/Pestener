    $workplace = "c:\temp"
    # This function will create a new file for each describe

    $text = Get-Content D:\git\Pestener\tests\DSC.tests.ps1 -Raw 
    $tokens = $null
    $errors = $null
    $a = @()
    $i = 1
    $b = [Management.Automation.Language.Parser]::ParseInput($text, [ref]$tokens, [ref]$errors).FindAll([Func[Management.Automation.Language.Ast,bool]]{`
    param ($ast) $ast.CommandElements -and  $ast.CommandElements[0].Value -eq 'describe' }, $true) 
    $b| ForEach-Object {
        #$tempName = $PSItem.Parent.CommandElements[3].Value.ToString().replace(' ','')
            if ($_.CommandElements[1].value -eq 'tags') {
                $tempName = $_.Parent.CommandElements[3].Value.ToString().replace(' ','')
            }
            else {
                $tempName = $_.Parent.CommandElements[1].Value.ToString().replace(' ','')
            }
            $_.Parent.ToString() | Out-File (Join-Path -Path $Workplace -ChildPath ("$tempname.tests.ps1"))
        }
            
 

