Function Get-TestList {
    [CmdletBinding()]


    param (
        # Insert some test about this directory
        [String]$Path,
        [Switch]$Recurse
    )
    BEGIN {
        # Do some cleaning of maybe existing previous variables
        Write-Verbose -Message "Cleaning variables"
    }
    PROCESS {
        Try {
            # Get all pester tests in the directory.
            Write-Verbose -Message "Gathering a list of every Pester tests stored in $($Path)"
            If ($Recurse) {
                Write-Verbose -Message "Recursive mode requested. Go in $($path) depth "
                $TestList = Get-ChildItem -LiteralPath $Path -Recurse -File -ErrorAction SilentlyContinue
            }
            else {
                $TestList = Get-ChildItem -LiteralPath $Path -File -ErrorAction SilentlyContinue
            }
        }
        Catch {
            # To be done: Do some better catching on possible exceptions.
            $TestList = $null
            Write-Error -Message "$($_.Exception.Message)"
        }

    }
    END {
        Write-Verbose -Message "Returning the Pester tests list requested"
        Return $TestList
    }

}

Export-ModuleMember Get-TestList