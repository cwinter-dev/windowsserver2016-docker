# escape=`

        # Add-Type -Assembly System.IO.Compression.FileSystem; `
        # $zip = [IO.Compression.ZipFile]::OpenRead('aspnetcore.zip'); `
        # $entries = $zip.Entries | where {$_.FullName -like 'aspnetcore/shared/Microsoft.AspNetCore.App/*' -and $_.FullName -ne 'aspnetcore/shared/Microsoft.AspNetCore.App/'}; `
        # New-Item -ItemType Directory -Path $Env:ProgramFiles\dotnet\shared\Microsoft.AspNetCore.App -Force; `
        # Write-Output 'test'; `
        # $entries | % { Write-Output $_.Name }; `
        # $zip.Dispose(); `
        #Expand-Archive -LiteralPath dotnet.zip -DestinationPath $Env:ProgramFiles\dotnet; `

ARG REPO=recology.azurecr.io/dotnet/runtime
FROM $REPO:5.0-windowsservercore-ltsc2016

ENV ASPNET_VERSION=5.0.3

RUN powershell -Command `
        $ErrorActionPreference = 'Stop'; `
        $ProgressPreference = 'SilentlyContinue'; `
        `
        # Install ASP.NET Core Runtime
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
        Invoke-WebRequest -OutFile aspnetcore.zip https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/$Env:ASPNET_VERSION/aspnetcore-runtime-$Env:ASPNET_VERSION-win-x64.zip; `
        $aspnetcore_sha512 = '1188f9af667338bd1785246d1682876c10eabd584f1f8dc52a7cae06d2ad03c0b4236c4a603bd436d5fcf8f4221026b6a64cb4aa5ee13bf1f8e32e3b774e25d0'; `
        if ((Get-FileHash aspnetcore.zip -Algorithm sha512).Hash -ne $aspnetcore_sha512) { `
            Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
            exit 1; `
        }; `
        `
        \tar\tar.exe -C $Env:ProgramFiles\dotnet -oxzf aspnetcore.zip ./shared/Microsoft.AspNetCore.App; `
        Remove-Item -Force aspnetcore.zip