# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2016-amd64

ENV `
    # Configure web servers to bind to port 80 when present
    ASPNETCORE_URLS=http://+:80 `
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true `
    DOTNET_VERSION=5.0.3

COPY .\tar\* \tar\
#COPY .\archiveint.dll $Env:ProgramFiles\tar\

RUN powershell -Command `
        $ErrorActionPreference = 'Stop'; `
        $ProgressPreference = 'SilentlyContinue'; `
        `
        Write-Output $env:DOTNET_VERSION; `
        # Install .NET
        # ServicePointManager.Expect100Continue = true; `
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
        Invoke-WebRequest -OutFile dotnet.zip https://dotnetcli.azureedge.net/dotnet/Runtime/$Env:DOTNET_VERSION/dotnet-runtime-$Env:DOTNET_VERSION-win-x64.zip; `
        $dotnet_sha512 = '1b29d6f51c11c2eb3101eb1cfd259deade6a4575e555e5a93839c37a9a14d7f81e7bb57d3e78d8957d7537d95a5db6577320d8e5e44d3bc70f33769f4fdd0aa9'; `
        if ((Get-FileHash dotnet.zip -Algorithm sha512).Hash -ne $dotnet_sha512) { `
            Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
            exit 1; `
        }; `
        `
        mkdir $Env:ProgramFiles\dotnet; `
        \tar\tar.exe -C $Env:ProgramFiles\dotnet -oxzf dotnet.zip; `
        Remove-Item -Force dotnet.zip

RUN setx /M PATH "%PATH%;C:\Program Files\dotnet"