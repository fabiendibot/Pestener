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

Export-ModuleMember New-DockerFile