# escape=`

# https://github.com/microsoft/dotnet-framework-docker/blob/master/4.8/sdk/windowsservercore-ltsc2019/Dockerfile
FROM docker.io/mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Remove microsoft's preinstalled nuget.exe 4.4.3
RUN Remove-Item 'C:\Program Files\NuGet\nuget.exe' -force

# Install Git to C:/Program Files/Git
RUN [Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls' ; `
    Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.19.1.windows.1/MinGit-2.19.1-64-bit.zip -OutFile git.zip; `
    Expand-Archive git.zip -DestinationPath $Env:ProgramFiles\Git ; `
    Remove-Item -Force git.zip

USER ContainerAdministrator
# Install Cement
RUN [Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls' ; `
    Invoke-WebRequest https://github.com/skbkontur/cement/releases/download/v1.0.59/e23d31e2b5251cb298218e74570a3c06270eda8a.zip -OutFile cm.zip; `
    Expand-Archive cm.zip -DestinationPath C:\ -Force; `
    # Start-Process -FilePath 'C:\cm\dotnet\install.cmd' -Wait -PassThru; `
    C:\dotnet\install.cmd; `
    Remove-Item cm.zip -Force ; `
    Remove-Item "c:\dotnet" -Recurse -Force

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true;`
    # Disable first time experience;`
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true;`
    # Configure Kestrel web server to bind to port 80 when present;`
    DOTNET_RUNNING_IN_CONTAINER=true;`
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true;`
    # Skip extraction of XML docs - generally not useful within an image/container - helps perfomance;`
    NUGET_XMLDOC_MODE=skip; `
    # git path
    GIT_HOME="C:\Program Files\Git\cmd"; `
    # cement path
    CEMENT_HOME="C:\Users\ContainerAdministrator\bin\dotnet"

    
RUN setx /M PATH ('{0};{1};{2}' -f $env:PATH, $env:GIT_HOME, $env:CEMENT_HOME)

CMD powershell



# Unzip and run dotnet\install.cmd
# Restart terminal
# Command cm shows you available commands in any directory
# If you have installed Visual Studio 2017 in custom folder run set VS150COMNTOOLS=D:\Program Files\Microsoft Visual Studio\2017\Professional\Common7\Tools\ (with your custom foler path) in cmd.