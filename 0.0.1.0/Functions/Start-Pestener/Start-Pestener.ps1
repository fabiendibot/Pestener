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
        
        $Tests = Get-ChildItem -LiteralPath $TestPath -Recurse -File

        # Add a $i variable to find the last started container and use a docker wait
        $i = $Tests.count
        $Tests | ForEach-Object {

            $DirectoryName = $($PSItem.FullName).split('\')[-2]
            Write-Verbose -Message "Starting a container for the tests $($DirectoryName)"

            if ($i -eq 1) {
                Write-Verbose -Message "Last Docker container"
                Start-Container -Workspace $workspace -TestMount (Join-Path -Path $TestPath -ChildPath $DirectoryName ) -wait
            }
            else {
                Start-Container -Workspace $workspace -TestMount (Join-Path -Path $TestPath -ChildPath $DirectoryName ) 
            }
            $i--

        }
    }
    END {

    }


}


Export-ModuleMember Start-Pestener