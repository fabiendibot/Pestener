Function New-DockerFile {
    [CmdletBinding()]
<#
.SYNOPSIS
This function will help you create a new Dockerfile

.PARAMETER Path
This parameter indicates the location where yo want your dockerile to be generated
 
.PARAMETER From
Which docker image should be used at first to build your own one.
 
.PARAMETER Maintener
The fullname of the maintener of the image

.PARAMETER MaintenerMail
The maintenet mail adress

.EXAMPLE
New-DockerFile -Path $DockerFile -From $from -Maintener $Maintener -MaintenerMail $MaintenerMail

#>
    param (
        [Parameter(Mandatory)]
        [String]$Path,
        [String]$from = 'microsoft/nanoserver',
        [Parameter(Mandatory)]
        [String]$Maintener,
        [Parameter(Mandatory)]
        [String]$MaintenerMail

    )
    
    BEGIN {

        Write-Verbose "Create some path for the script needs"
        $FullPath = Join-Path -Path $Path -ChildPath 'Dockerfile' -ErrorAction SilentlyContinue


    }
    PROCESS {

        Try {

            Write-Verbose -Message "Building the Pester command line."        
            $PesterCMD = $PesterCMD + "-EnableExit -OutputFormat LegacyNUnitXml -OutputFile C:\Pester\NUnit.XML "

            Write-Verbose -Message "Starting creation of the Docker file in $($FullPath)"

            #Adding informations in the Dockerfile
            Write-Verbose -Message "Adding the 'FROM' information in $($FullPath)"
            Write-Output "FROM $($from)" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue

            #Building the folder structure.
            Write-Verbose -Message "Building the folder structure"
            Write-Output "RUN mkdir C:\Pester" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append
            Write-Output "RUN mkdir C:\workspace" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append
            
            #Adding the Pester tests to be runned after the launch.
            Write-Verbose -Message "Adding the PowerShell command that will be launched at the container start"
            Write-Output "CMD powershell.exe -ExecutionPolicy Bypass -Command cd C:\Pester; Invoke-Pester $($PesterCMD)" | Out-File -FilePath $FullPath -Encoding utf8 -ErrorAction SilentlyContinue -Append


        }
        Catch {

            Write-Warning -Message "$($_.Exception.Message)"
 
       }

    }
    END {

    }
    
    
}

Export-ModuleMember New-DockerFile