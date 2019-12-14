Install-Module -Name xPSDesiredStateConfiguration -Force
Install-Module -Name xWebAdministration -Force

Configuration WebServerConfig 
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $NodeName
    )

    Import-DscResource -Module PsDesiredStateConfiguration
    Import-DscResource -Module xPSDesiredStateConfiguration
    Import-DscResource -Module xWebAdministration

    Node $NodeName
    {
        WindowsFeature IIS
        {
            Ensure  = "Present" # Ensure = "Absent"
            Name    = "Web-Server" 
        }

        xWindowsFeature Web-Mgmt-Console
        {
            Ensure  = "Present"
            Name    = "Web-Mgmt-Console"
        }

        xWebSite DefaultSite
        {
            Ensure  = "Present"
            Name    = "Default Web Site"
            State   = "Started"
            DependsOn = "[WindowsFeature]IIS"
        }
    }
}

Write-Output "Compiling mof file..."
WebServerConfig -NodeName "localhost" # ["webserve1", "webserver2"]

Write-Output "Executing DSC..."
Start-DscConfiguration -Path .\WebServerConfig -Wait -Verbose -Force