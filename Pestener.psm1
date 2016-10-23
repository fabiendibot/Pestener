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

    param (
        []
    )

}

Function New-DockerFile {

    param (
        [int]$Path,
        [int]$Version = 'NanoServer',
        [int]$Maintener,
        [int]$MaintenerMail
    )
    
    Try {
        
        $FullPath = Join-Path -Path $Path -ChildPath 'Dockerfile'
        # test Windows version
    }
    


}