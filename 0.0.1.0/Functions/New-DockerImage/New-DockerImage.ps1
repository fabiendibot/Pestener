Function New-DockerImage {
    [CmdletBinding()]
<#
.SYNOPSIS
 This function will trigger a docker build.

.EXAMPLE
New-DockerImage

#>
    param ()
    Try {
        Write-Verbose -Message "Starting the Docker image build process."
        docker build -t pestener .
    }
    Catch {
        Write-Error -Message "Impossible to build the image. Error: $($_.Exception.Message)"
    }

}
