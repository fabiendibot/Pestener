


Function Get-TestList {
    [CmdletBinding()]


    param (
        # Insert some test about this directory
        [String]$Path,
        [Switch]$Recurse
    )
    BEGIN {
        # Do some cleaning of maybe existing previous variables
        Write-Verbose -Message "Cleaning variables"
    }
    PROCESS {
        Try {
            # Get all pester tests in the directory.
            Write-Verbose -Message "Gathering a list of every Pester tests stored in $($Path)"
            If ($Recurse) {
                Write-Verbose -Message "Recursive mode requested. Go in $($path) depth "
                $TestList = Get-ChildItem -LiteralPath $Path -Recurse -File -ErrorAction SilentlyContinue
            }
            else {
                $TestList = Get-ChildItem -LiteralPath $Path -File -ErrorAction SilentlyContinue
            }
        }
        Catch {
            # To be done: Do some better catching on possible exceptions.
            $TestList = $null
            Write-Error -Message "$($_.Exception.Message)"
        }

    }
    END {
        Write-Verbose -Message "Returning the Pester tests list requested"
        Return $TestList
    }

}

Function Start-Container {
    [CmdletBinding()]
    param (
        [String]$TestMount,
        [String]$Workspace,
        [String]$DockerPesterPath = 'c:\Pester',
        [String]$DockerWorkspacePath = 'C:\Workspace'

    )

    BEGIN {
        # Nothing ATM
    }
    PROCESS {
        Try {
            # Each container should start and execute Pester script
            # The container should be only a temporary one
            # And the containter must print out verbose stuff
            # The container must have local volume mounted to a local directory in order to stored XML NUnit file.
            Write-Verbose -Message "Starting docker temporary container to launch tests stored in $($TestMount)"
            #$Scriptblock = [ScriptBlock]::Create('start-process -filepath "docker" -argumentlist "run -ti -v $TestMount:$DockerPesterPath -v $workspace:$DockerWorkspacePath pestener" -NoNewWindow -wait')
            #Write-output $Scriptblock
            #$DockerJob = Invoke-Command -AsJob -ScriptBlock $Scriptblock | Wait-Job
            docker run -d -v ${TestMount}:${DockerPesterPath} -v ${workspace}:${DockerWorkspacePath} pestener | out-null
            
            Write-Output $DockerJob
        }
        Catch {
            Write-Error -Message "$($_.Exception.Message)"
        }
    }
    END {
        # Nothing atm
    }
    
    

}


Function New-DockerFile {
    [CmdletBinding()]
    # if you need some container to connect a SQL Server
    # Be sure that this SQL Server can be reached.
    # If you want to have SQL Server available in the nano server, just build your own image :)

    param (
        [String]$Path,
        [String]$from = 'microsoft/nanoserver',
        [String]$Maintener,
        [String]$MaintenerMail,
        [Switch]$OutputXML

    )
    
    BEGIN {

        Write-Verbose "Create some path for the script needs"
        $FullPath = Join-Path -Path $Path -ChildPath 'Dockerfile' -ErrorAction SilentlyContinue


    }
    PROCESS {

        Try {

            Write-Verbose -Message "Building the Pester command line."

            #Building the Pester command line
            if ($OutputXML) {
                $PesterCMD = $PesterCMD + "-OutputFormat LegacyNUnitXml -OutputFile C:\Pester\NUnit.XML "
            } 
            
            $PesterCMD = $PesterCMD + "-EnableExit"


            Write-Verbose -Message "Starting creation of the Docker file in $($FullPath)"

            #Adding informations in the Dockerfile
            Write-Verbose -Message "Adding the 'FROM' information in $($FullPath)"
            echo "FROM $($from)" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue

            #Building the folder structure.
            Write-Verbose -Message "Building the folder structure"
            echo "RUN mkdir C:\Pester" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append
            echo "RUN mkdir C:\workspace" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append

            # Installing the Pester module
            #Write-Verbose -Message "Installing Pester module from PSGallery"
            #echo "RUN powershell.exe -ExecutionPolicy Bypass -Command 'Install-Module Pester -Force'" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append

            #Adding the Pester tests to be runned after the launch.
            Write-Verbose -Message "Adding the PowerShell command that will be launched at the container start"
            echo "CMD powershell.exe -ExecutionPolicy Bypass -Command cd C:\Pester; Invoke-Pester $($PesterCMD)" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append


        }
        Catch {

            Write-Warning -Message "$($_.Exception.Message)"
 
       }

    }
    END {

    }
    
    
}

Function New-DockerImage {
    [CmdletBinding()]
    param (
        [String]$Name
    )

    Try {
        Write-Verbose -Message "Starting the Docker image build process."
        docker build -t pestener .
    }
    Catch {
        Write-Error -Message "Impossible to build the image. Error: $($_.Exception.Message)"
    }

}

# Thanks to Dexter for the Next two functions :)

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
                Write-Verbose -Message "Describe block found! -> $($matches[0])"

                $TempAST = Get-ASTFromInput -Content $ModuleScope.Extent.Text
                $CommandTempAST = $TempAST.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst]}, $true)
                $TempdescribeASTs = $commandAST | Where-Object -FilterScript {$PSItem.GetCommandName() -eq 'Describe'}
                
                Switch -Exact ($TempdescribeASTs.StringConstantType ) {
			
				    'DoubleQuoted' {  
					    $DescribesTreated += $($ExecutionContext.InvokeCommand.ExpandString($TempdescribeASTs.Value)) 
				    }
				    'SingleQuoted' {
					    # if the test name is a single quoted string
					    $DescribesTreated += $($TempdescribeASTs.Value)
				    }
                }
            }

            if ($DescribesTreated) {
                Write-Output $DescribesTreated
            }

            # Change if InModuleScope double detected 
            [Array]$Doubles = $output | ? { $_.Name -eq $($InModuleScopeElement.Value) }

            
            if ($doubles)  {
                $Name = $($InModuleScopeElement.Value) + "$i"
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

Function Start-Pestener {
[CmdletBinding()]
<#
.SYNOPSIS
Provides an enhanced utilization of the Pester framework. Thanks to the Docker
 technology. It's easier to scale as much as you want in order to reduce the time
 of your tests. This module will split your Pester tests file describe blocs in separated 
 file. Each file will be run by Pester in his own container. Once it's done you choose
 if you want to have the NUnit Exported or Not and if it needs to stop the build.
Like that you can use this tools with things like TeamCity, Jenkins or TravisCI.
 
.PARAMETER TestPath
This parameter indicates the location of every Pester tests you want to be run.
 
.PARAMETER Image
This is the name you want to use for the container image that you will build on the 
Jenkins.
 
.PARAMETER OutputXML
This parameter will indicate to the script if you want it to export the XML file in the 
mDocker mounted volume

 
.PARAMETER DockerFile
This is the full path of the DockerFile used to build the Docker image
 
.PARAMETER From
Which docker image should be used at first to build your own one.
 
.PARAMETER Maintener
The fullname of the maintener of the image

.PARAMETER MaintenerMail
The maintenet mail adress

.EXAMPLE
Import-Module Pestener
Start-Pestener -PesterFile D:\git\Pestener\Tests\demo.tests.ps1 -OutputXML -Workspace D:\Git\Pestener -TestPath D:\temp -DockerFile D:\Git\Pestener -Maintener "Fabien Dibot" -MaintenerMail "fdibot@pwrshell.net"

#>

    param (

        [String]$PesterFile,
        [String]$Image = "pestener",
        [Switch]$OutputXML,
        [String]$Workspace,
        [String]$TestPath,
        [String]$DockerFile,
        [String]$from = 'microsoft/nanoserver',
        [String]$Maintener,
        [String]$MaintenerMail,
        [Switch]$NewImage

    )

    BEGIN {

    }
    PROCESS {

        # Create file for each describe bloc :)
        Get-TestList -Path $PesterFile | ForEach-Object {
            Write-Verbose -Message "File theaten $($PSItem.FullName)"
            # Gather the list of Describe block for each file 
            Get-TestNameAndTestBlock -Content (Get-Content $PSItem.FullName -raw) | ForEach-Object {
                
                # Get rid of specials characters
                if ($PSItem.Name -like '*$*') {
                    $FolderName = $($PSItem.Name).replace('$', '')
                 }
                 else {
                    $FolderName = $PSItem.Name
                 }

                # Create new pester  specific directory
                Write-Verbose -Message "Folder: $($FolderName.replace(' ',''))"
                New-Item -Path (Join-Path -path $TestPath -childpath $FolderName.replace(' ','')) -ItemType Directory -Force | Out-Null

                # Create new test file in the previous direcotry
                Write-Verbose -Message "File: $($PSItem.Name.replace(' ',''))"
                New-Item -Path (Join-Path -path (Join-Path -path $TestPath -childpath $($PSItem.Name.replace(' ',''))) -ChildPath "run.tests.ps1") -ItemType File -Value $($PSItem.content) -Force | Out-Null

            }

        }

        if ($NewImage) {
            
            # Create the new docker file
            New-DockerFile -Path $DockerFile -OutPutXML -From $from -Maintener $Maintener -MaintenerMail $MaintenerMail

            # Build the new image
            New-DockerImage -Name $image

        }
        

        # Start a container for each Pester tests file
        # Bosser sur les définitions de variables qui ne sont pas claires !!!
        Get-ChildItem -LiteralPath $TestPath -Recurse -File | ForEach-Object {

            $DirectoryName = $($PSItem.FullName).split('\')[-2]
            Write-Verbose -Message "Starting a container for the tests $($DirectoryName)"

            Start-Container -Workspace $workspace -TestMount (Join-Path -Path $TestPath -ChildPath $DirectoryName )

        }
    }
    END {

    }


}


Export-ModuleMember -Function *