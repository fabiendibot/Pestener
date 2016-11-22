Function Start-Container {
    [CmdletBinding()]
    param (
        [String]$TestMount,
        [String]$Workspace,
        [String]$DockerPesterPath = 'c:\Pester',
        [String]$DockerWorkspacePath = 'C:\Workspace',
        [switch]$wait

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
            #$Scriptblock = [ScriptBlock]::Create('start-process -filepath "docker" -argumentlist "run -ti -v $TestMount:$DockerPesterPath -v $workspace:$DockerWorkspacePath pestener" -NoNewWindow -wait')
            #Write-output $Scriptblock
            #$DockerJob = Invoke-Command -AsJob -ScriptBlock $Scriptblock | Wait-Job
            
            if ($wait) {
                # Last container to stop
                docker run --name lastone -d -v ${TestMount}:${DockerPesterPath} -v ${workspace}:${DockerWorkspacePath} pestener | out-null
                $a = 'Running'
                while ($a -eq 'exited') {
                    Start-Sleep -Seconds 1
                    $a = docker inspect -f '{{.State.Status}}' lastone
                }
                Write-Verbose -Message "The last one container has stopped"
            }
            else {
                docker run -d -v ${TestMount}:${DockerPesterPath} -v ${workspace}:${DockerWorkspacePath} pestener | out-null
            }

        }
        Catch {
            Write-Error -Message "$($_.Exception.Message)"
        }
    }
    END {
        # Nothing atm
    }
    
    

}

Export-ModuleMember Start-Container