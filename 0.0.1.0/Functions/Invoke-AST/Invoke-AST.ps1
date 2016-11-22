Function Get-ASTFromInput {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]$Content
	)
	$ast = [System.Management.Automation.Language.Parser]::ParseInput($Content,[ref]$null,[ref]$Null)
	return $ast
}

Function Get-TestNameAndTestBlock {
	[OutputType([String])]
	param(
		[Parameter()]
		[String]$Content
	)
	
	$ast = Get-ASTFromInput -Content $Content
	$commandAST = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst]}, $true)    
	$output = @()
    $DescribesTreated = @()

    $ModuleScopeASTs = $commandAST | ? { $PSItem.GetCommandName() -eq 'InModuleScope' }
    $describeASTs = $commandAST | Where-Object -FilterScript {$PSItem.GetCommandName() -eq 'Describe'}

    # InmoduleScope
    $i = 0
    if ($ModuleScopeASTS) {
        Foreach ($ModuleScope in $ModuleScopeASTs) {
            $InModuleScopeElement = $ModuleScope.CommandElements | Select-Object -First 2 | Where-Object -FilterScript {$PSitem.Value -ne 'InModuleScope'}

            # Check if Descibes stored in InModuleScope
            if ($ModuleScope.Extent.Text -match "Describe+.*") { 
                
                $TempAST = Get-ASTFromInput -Content $($ModuleScope.Extent.Text)
                $CommandTempAST = $TempAST.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst]}, $true)
                $TempdescribeASTs = $commandTempAST | Where-Object -FilterScript {$PSItem.GetCommandName() -eq 'Describe'}

                Switch -Exact ($TempdescribeASTs.CommandElements.StringConstantType) {
			
				    'DoubleQuoted' {  
					    $DescribesTreated += $($ExecutionContext.InvokeCommand.ExpandString($TempdescribeASTs.Value)) 
				    }
				    'SingleQuoted' {
					    # if the test name is a single quoted string
					    $DescribesTreated += $($TempdescribeASTs.CommandElements.value[1])
				    }
                }
            }

            # Change if InModuleScope double detected 
            [Array]$Doubles = $output | ? { $_.Name -eq $($InModuleScopeElement.Value) }

            if ($doubles)  {
                $Name = $($InModuleScopeElement.Value) + "$($i)"
            }
            else {
                $Name = $($InModuleScopeElement.Value)
            }

            Write-verbose "File Name: $Name"
            $output += New-Object -TypeName PSObject -Property @{
                         Name = $Name
                         Content = $($ModuleScope.Extent.Text) }
            $i++
            break
        }
    }

    # Describes
  	if ($describeASTs) {
		foreach ($describeAST in $describeASTs) {

			$TestNameElement = $describeAST.CommandElements | Select-Object -First 2 | Where-Object -FilterScript {$PSitem.Value -ne 'Describe'}
			Switch -Exact ($TestNameElement.StringConstantType ) {
			
				'DoubleQuoted' {
					# if the test name is a double quoted string
                    if ($DescribesTreated -notcontains $($ExecutionContext.InvokeCommand.ExpandString($TestNameElement.Value))) {
					    $output += New-Object -typename PSObject -property @{
						    #Add the test name as key and testBlock string as value 
                        
						    Name = $($ExecutionContext.InvokeCommand.ExpandString($TestNameElement.Value))
                            Content = $($describeAST.Extent.Text)
                        }
					}
					break
				}
				'SingleQuoted' {
					# if the test name is a single quoted string
                    if ($DescribesTreated -notcontains $($TestNameElement.Value)) {
					    $output += New-Object -typename PSObject -property @{
						    Name = $($TestNameElement.Value)
                            Content = $($describeAST.Extent.Text)
					    }
                    }
					break
				}
				default {
					throw 'TestName passed to Describe block should be a string'
				}

			}

		} # end foreach block
	}
	else {
		throw 'Describe block not found in the Test Body.'
	}

	Return $Output
}


Export-ModuleMember Get-TestNameAndTestBlock