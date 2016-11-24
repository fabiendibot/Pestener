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
