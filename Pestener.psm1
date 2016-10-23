# Add file with licalized available
Function Get-TestList {

    param (
        # Insert some test about this directory
        [String]$Path,
        [Switch]$Recurse
    )

    Try {
        # Insert some logical test for recurse or not :)
        $TestList = Get-ChildItem -LiteralPath $Path -ErrorAction SilentlyContinue
    }
    Catch {
        # Do some better catching on possible exceptions.
        Throw $($_.Exception.Message)
    }

    Return $TestList

}


Function Test-System {

    # Test if docker is running
    # if no return a $false

    if ((Get-Service Docker).status -eq 'running') {
        Return $true
    }
    else {
        return $false
    }



}

Function Start-Container {

    param (
        [String]$MountPoint

    )

    # Each container should start and execute Pester script
    # The container should be only a temporary one
    # And the containter must print out verbose stuff
    # The container must have local volume mounted to a local directory in order to stored XML NUnit file.

    docker run -ti -v $($MountPoint):$($MountPoint) -rm <imagename>

}

Function New-DockerFile {

    # if you need some container to connect a SQL Server
    # Be sure that this SQL Server can be reached.
    # If you want to have SQL Server available in the nano server, just build your own image :)

    param (
        [String]$Path,
        [String]$from = 'microsoft/NanoServer',
        [String]$Maintener,
        [String]$MaintenerMail,
        [Switch]$OutputXML
    )
    
    Try {
        # Creation of the Dockerfile
        # test Windows version
    
        $FullPath = Join-Path -Path $Path -ChildPath 'Dockerfile' -ErrorAction SilentlyContinue
        $TestFullPath = Join-Path -Path $TestPath -ChildPath Unit.tests.ps1 -ErrorAction SilentlyContinue
        
        #Adding the OS Source
        echo "FROM $($from)" | Out-File -FilePath $FullPath -ErrorAction SilentlyContinue

        #Building the Pester command line
        if ($OutputXML) {
            $PesterCMD = $PesterCMD + "-OutPutXML NUnit.XML"
        } 
        #if ()

        #Adding the Pester tests to be runned after the launch.
        echo "CMD powershell.exe -ExecutionPolicy Bypass -Command Invoke-Pester $($PesterCMD)" | Out-File -FilePath $FullPath -ErrorAction SilentlyContinue -Append


    }
    
}

Function New-DockerImage {

    param (
        #[Int]$Image = 'PesterImage',
        [String]$Name
    )

    Try {
        docker build . --name=$Name
    }
    Catch {
        #Throw something
    }

}


Function Invoke-CutPesterFile {

    param (
        [String]$Path,
        [String]$Workplace
    )

    # This function will create a new file for each describe
    Get-Content -LiteralPath $Path | ForEach-Object {

        # Find a way to handle the fact that it's a bloc.
        # Each find a bloc is finished, reg theses lines in a file.
        # Make a folder for each one of the new file in workspace

    }
}


Function Start-Pestener {

    param (

        [String]$TestPath,
        [String]$ImageName,
        [Switch]$OutputXML,
        [Switch]$ShouldExit,
        [String]$Workspace,
        [Switch]$CleanWorkspace,
        [String]$DockerFilePath,
        [String]$from = 'microsoft/NanoServer',
        [String]$Maintener,
        [String]$MaintenerMail

    )

    # Building a list of every single pester test file
    $FilesList = @()
    Get-ChildItem -LiteralPath $TestPath -Recurse -File | ForEach-Object {

        if ($PSItem.FullName -like "*.tests.ps1") {

            $FilesList.Add($PSItem.FullName)

        }

    }

    # Create file for each describe bloc :)
    $FilesList | ForEach-Object {

        Invoke-CutPesterFile -Path $PSItem -Workspace $Workspace

    }

    # Create the new docker file
    New-DockerFile -Path $DockerFilePath -OutPutXML -From 'microsoft/nanoserver' -Maintener 'Fabien Dibot' -MaintenerMail 'fdibot@pwrshell.net'

    # Build the new image
    New-DockerImage -Name 'Pestener'

    # Start a container for each Pester tests file
    Get-ChildItem -LiteralPath $Workspace -Recurse -File | ForEach-Object {

        $DirectoryName = $PSItem.split('\')[-2]
        Start-Container -Mountpoint (Join-Path -Path 'C:\temp' -ChildPath $DirectoryName) 

    }


}
