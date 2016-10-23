# Add file with licalized available
Function Get-TestList {

    param (
        # Insert some test about this directory
        [int]$Path,
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

Function New-Container {

}

Function New-DockerFile {

    param (
        [int]$Path,
        [int]$TestPath,
        [int]$Version = 'NanoServer',
        [int]$Maintener,
        [int]$MaintenerMail,
        [Switch]$OutputXML
    )
    
    Try {
        # Creation of the Dockerfile
        # test Windows version
    
        $FullPath = Join-Path -Path $Path -ChildPath 'Dockerfile' -ErrorAction SilentlyContinue
        $TestFullPath = Join-Path -Path $TestPath -ChildPath Unit.tests.ps1 -ErrorAction SilentlyContinue
        
        #Adding the OS Source
        echo "FROM microsoft/$version" | Out-File -FilePath $FullPath -ErrorAction SilentlyContinue

        #Building the Pester command line
        if ($OutputXML) {
            $PesterCMD = $PesterCMD + "-OutPutXML NUnit.XML"
        } 
        #if ()

        #Adding the Pester tests to be runned after the launch.
        echo "CMD powershell.exe -ExecutionPolicy Bypass -Command Invoke-Pester $($PesterCMD)"


    }
    
}

Function New-DockerImage {

    param (
        [Int]$Name = 'PesterImage'
    )

    docker build .

}