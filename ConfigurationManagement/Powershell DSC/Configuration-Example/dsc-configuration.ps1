Configuration MyWebServerConfig 
{
    Import-DscResource -Module PsDesiredStateConfiguration

    Node "localhost"
    {
        WindowsFeature IIS
        {
            Ensure  = "Present"
            Name    = "Web-Server" 
        }
    }
}

Write-Output "Compiling mof file..."
MyWebServerConfig