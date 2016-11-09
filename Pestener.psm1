


Function Get-TestList {

    param (
        # Insert some test about this directory
        [String]$Path,
        [Switch]$Recurse
    )
    BEGIN {
        # Do some cleaning of maybe existing previous variables
        Write-Verbose -Message "Cleaning variables"
        Remove-Variable -Name $TestList
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

    param (
        [String]$TestMount,
        [String]$ThirdPartyTools,
        [String]$Workspace

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
            docker run -ti -v $($TestMount):c:\Pester -v $($workspace):C:\Workspace -v $($ThirdPartyTools):C:\ThirdPartyTools -rm Pestener
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

    # if you need some container to connect a SQL Server
    # Be sure that this SQL Server can be reached.
    # If you want to have SQL Server available in the nano server, just build your own image :)

    param (
        [String]$Path,
        [String]$from = 'microsoft/nanserver',
        [String]$Maintener,
        [String]$MaintenerMail,
        [Switch]$OutputXML,
        [Switch]$ShouldExit
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
                $PesterCMD = $PesterCMD + "-OutputFormat LegacyNUnitXml -OutputFile C:\Workspace\Nunit.XML"
            } 
            if ($ShouldExit) {
                $PesterCMD = $PesterCMD + "-ShouldExit"
            } 

            Write-Verbose -Message "Starting creation of the Docker file in $($FullPath)"

            #Adding informations in the Dockerfile
            Write-Verbose -Message "Adding the 'FROM' information in $($FullPath)"
            echo "FROM $($from)" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue

            #Building the folder structure.
            Write-Verbose -Message "Building the folder structure"
            echo "RUN mkdir C:\Pester" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append
            echo "RUN mkdir C:\ThirdPartyTool" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append
            echo "RUN mkdir C:\Workspace" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append

            # Installing the Pester module
            Write-Verbose -Message "Installing Pester module from PSGallery"
            echo "RUN powershell.exe -ExecutionPolicy Bypass -Command 'Install-Module Pester -Force'" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append

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

    # if you need some container to connect a SQL Server
    # Be sure that this SQL Server can be reached.
    # If you want to have SQL Server available in the nano server, just build your own image :)

    param (
        [String]$Path,
        [String]$from = 'microsoft/nanserver',
        [String]$Maintener,
        [String]$MaintenerMail,
        [Switch]$OutputXML,
        [Switch]$ShouldExit
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
                $PesterCMD = $PesterCMD + "-OutPutXML NUnit.XML"
            } 
            if ($ShouldExit) {
                $PesterCMD = $PesterCMD + "-ShouldExit"
            } 

            Write-Verbose -Message "Starting creation of the Docker file in $($FullPath)"

            #Adding informations in the Dockerfile
            Write-Verbose -Message "Adding the 'FROM' information in $($FullPath)"
            echo "FROM $($from)" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue

            #Building the folder structure.
            Write-Verbose -Message "Building the folder structure"
            echo "RUN mkdir C:\Pester" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append
            echo "RUN mkdir C:\ThirdPartyTool" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append
            echo "RUN mkdir C:\workspace" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append

            # Installing the Pester module
            Write-Verbose -Message "Installing Pester module from PSGallery"
            echo "RUN powershell.exe -ExecutionPolicy Bypass -Command 'Install-Module Pester -Force'" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append

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

    param (
        [String]$Name
    )

    Try {
        Write-Verbose -Message "Starting the Docker image build process."
        docker build -t Pestener .
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
	$describeASTs = $commandAST | Where-Object -FilterScript {$PSItem.GetCommandName() -eq 'Describe'}

	if ($describeASTs) {
		foreach ($describeAST in $describeASTs) {

			$TestNameElement = $describeAST.CommandElements | Select-Object -First 2 | Where-Object -FilterScript {$PSitem.Value -ne 'Describe'}
			Switch -Exact ($TestNameElement.StringConstantType ) {
			
				'DoubleQuoted' {
					# if the test name is a double quoted string
					$output += New-Object -typename PSObject -property @{
						#Add the test name as key and testBlock string as value 
						Name = $($ExecutionContext.InvokeCommand.ExpandString($TestNameElement.Value))
                        Content = $($describeAST.Extent.Text)
					}
					break
				}
				'SingleQuoted' {
					# if the test name is a single quoted string
					$output += New-Object -typename PSObject -property @{
						Name = $($TestNameElement.Value)
                        Content = $($describeAST.Extent.Text)
					}
					break
				}
				default {
					throw 'TestName passed to Describe block should be a string'
				}

			}

		} # end foreach block
        return $output
	}
	else {
		throw 'Describe block not found in the Test Body.'
	}
	
}

Function Start-Pestener {

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
 
.PARAMETER ShouldExit
This parameter will indicate to the script if it should generate an error code and use it
in you CI solution.
 
.PARAMETER CleanWorkspace
This parameter will indicate to the script to clean the workspace at the startup of each new
tests campaign.
 
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
Start-Pestener -TestPath C:\temp\Pestertests -OutPutXML -Workspace C:\Jenkins -CleanWorkspace -DockerFile C:\Jenkins\Dockerfile -Maintener 'Fabien Dibot' -MaintenerMail fdibot@pwrshell.net

#>

    param (

        [String]$TestPath,
        [String]$Image = "Pestener",
        [Switch]$OutputXML,
        [Switch]$ShouldExit,
        [String]$Workspace,
        [String]$PesterTests,
        [String]$ThirdPartyToolsFolder,
        [Switch]$CleanWorkspace,
        [String]$DockerFile,
        [String]$from = 'microsoft/NanoServer',
        [String]$Maintener,
        [String]$MaintenerMail,
        [Switch]$NoNewImage

    )

    BEGIN {

    }
    PROCESS {

        # Create file for each describe bloc :)
        Get-TestList -Path $TestPath | ForEach-Object {
        
            # Gather the list of Describe block for each file 
            Get-TestNameAndTestBlock -Path $PSItem | ForEach-Object {
                
                # Create new pester  specific directory
                New-Item -Path (Join-Path -path $Workspace -childpath $($PSItem.Name.replace(' ',''))) -ItemType Directory

                # Create new test file in the previous direcotry
                New-Item -Path (Join-Path -path (Join-Path -path $Workspace -childpath $($PSItem.Name.replace(' ',''))) -ChildPath "run.tests.ps1") -ItemType File -Value $($PSItem.content)

            }

        }

        if (!($NoNewImage)) {

            # Create the new docker file
            New-DockerFile -Path $DockerFile -OutPutXML -ShouldExit -From 'microsoft/nanoserver' -Maintener 'Fabien Dibot' -MaintenerMail 'fdibot@pwrshell.net'

            # Build the new image
            New-DockerImage -Name $image

        }
        

        # Start a container for each Pester tests file
        Get-ChildItem -LiteralPath $Workspace -Recurse -File | ForEach-Object {

            $DirectoryName = $PSItem.split('\')[-2]
            Write-Verbose -Message "Starting a container for the tests $($DirectoryName)"
            if ($ThirdPartyToolsFolder) {
                Start-Container -Workspace $workspace -TestMount $DirectoryName -ThirdPartyTools $ThirdPartyToolsFolder
            }
            else {
                Start-Container -Workspace $workspace -TestMount $DirectoryName 
            }
            

        }
    }
    END {

    }


}


Export-ModuleMember -Function Start-Pestener