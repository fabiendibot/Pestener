$manifestPath = "D:\Git\Pestener\Pestener.psd1"
$ReadmePath = "D:\Git\Pestener\README.md"

Describe "Verify system prerequites" {
    It "has a valid manifest" {
        {
            $script:manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a readme file" {
        test-Path -Path $ReadmePath | Should be $true
    }

    It "has Docker installed" {
        Test-Path -Path 'C:\program Files\Docker\docker.exe' | Should be $true
    }

    It "has Docker deamon installed" {
        Test-Path -Path 'C:\program Files\Docker\dockerd.exe' | Should be $true
    }

    It "has Docker deamon running" {
        Get-Process -name dockerd | Should be $true
    }

}

Describe "Test the script execution" {
    Import-Module D:\git\Pestener\Pestener.psm1
    Start-Pestener -PesterFile D:\git\Pestener\Tests\DSC.tests.ps1 -OutputXML -ShouldExit -Workspace D:\Git\Pestener -PesterTests D:\temp -DockerFile D:\Git\Pestener `
               -Maintener "Fabien Dibot" -MaintenerMail "fdibot@pwrshell.net"

    It 'Should be finished without any exception' {

        
    }         
}