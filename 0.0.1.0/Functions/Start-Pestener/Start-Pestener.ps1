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
 
.PARAMETER PesterFile
This parameter indicate the PesterFile to parse.

.PARAMETER TestPath
This parameter indicates the location of every Pester tests you want to be run.
 
.PARAMETER NewImage
Use this switch if you want to generate a new docker image.
 
.PARAMETER DockerFile
This is the path where you want to generate your dockerfile
 
 .PARAMETER Workspace
This is the path where is stored your workspace, a common data path, if you want to share artifact with your contianers.
It'll be mounted aas C:\Workspace in the container.

.PARAMETER From
Which docker image should be used at first to build your own one.
 
.PARAMETER Maintener
The fullname of the maintener of the image

.PARAMETER MaintenerMail
The maintenet mail adress

.PARAMETER MinRunspaces

.PARAMETER MaxRunspaces


.EXAMPLE
Start-Pestener -PesterFile D:\git\Pestener\Tests\demo.tests.ps1 -Workspace D:\Git\Pestener -TestPath D:\temp -DockerFile D:\Git\Pestener -Maintener "Fabien Dibot" -MaintenerMail "fdibot@pwrshell.net"

#>

    param (
        [Parameter(Mandatory)]
        [String]$PesterFile,
        [Parameter(Mandatory)]
        [String]$Workspace,
        [Parameter(Mandatory)]
        [String]$TestPath,
        [String]$DockerFile,
        [String]$from = 'microsoft/nanoserver',
        [String]$Maintener,
        [String]$MaintenerMail,
        [Switch]$NewImage,
        [int]$MinRunspaces = 1,
        [int]$MaxRunspaces = 5

    )

    BEGIN {

    }
    PROCESS {
        $apartmentstate = "MTA"
        $pool                 = [RunspaceFactory]::CreateRunspacePool($MinRunspaces,$MaxRunspaces)
        $pool.ApartmentState  = $apartmentstate
        $pool.CleanupInterval =  (New-TimeSpan -Minutes 1)
        $pool.Open()

        $runspaces = [System.Collections.ArrayList]@()

        $scriptblock = {
            Param (
                [string]$testmount,
                [string]$workspace,
                [String]$PesterPath = 'c:\Pester',
                [String]$WorkspacePath = 'C:\Workspace'
            )

            try {
                #$cmdOutput = 
                cmd /c "docker run -ti -v ${testmount}:${PesterPath} -v ${workspace}:${WorkspacePath} pestener" '2>&1'
            }
            catch {  }
	    }   

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
            # Verify that all needed arguments are here.
            if (!(($DockerFile) -and ($Maintener) -and ($MaintenerMail))) {}
                
            # Create the new docker file
            New-DockerFile -Path $DockerFile -From $from -Maintener $Maintener -MaintenerMail $MaintenerMail

            # Build the new image
            New-DockerImage
        }
        

        # Start a container for each Pester tests file
        
        $Tests = Get-ChildItem -LiteralPath $TestPath -Recurse -File

        $Tests | ForEach-Object {

            $DirectoryName = $($PSItem.FullName).split('\')[-2]
            $testmount = Join-Path -Path $testpath -ChildPath $DirectoryName
            $runspace = [PowerShell]::Create()
            $null = $runspace.AddScript($scriptblock)
            $null = $runspace.AddArgument($testmount)
            $null = $runspace.AddArgument($workspace)
            $runspace.RunspacePool = $pool
            [void]$runspaces.Add([PSCustomObject]@{ Pipe = $runspace; Status = $runspace.BeginInvoke() })

        }

        # Wait for runspaces to complete
        while ($runspaces.Status.IsCompleted -notcontains $true) {}

        $pool.Close() 
        $pool.Dispose()
    }
    END {

    }


}

Export-ModuleMember Start-Pestener