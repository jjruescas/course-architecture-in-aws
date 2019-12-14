Configuration WebServerConfig 
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $NodeName
    )

    Import-DscResource -Module PsDesiredStateConfiguration

    Node $NodeName
    {
        WindowsFeature IIS
        {
            Ensure  = "Present" # Ensure = "Absent"
            Name    = "Web-Server" 
        }

        File WebsiteContent 
        {
            Ensure = 'Present'
            SourcePath = 'c:\test\index.html'
            DestinationPath = 'c:\inetpub\wwwroot'
        }
    }
}

Write-Output "Compiling mof file..."
WebServerConfig -NodeName "localhost" # ["webserve1", "webserver2"]

Write-Output "Executing DSC..."
Start-DscConfiguration -Path .\WebServerConfig -Wait -Verbose -Force