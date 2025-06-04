<#

   Copyright 2025 Esri

   Licensed under the Apache License, Version 2.0 (the "License");

   you may not use this file except in compliance with the License.

   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software

   distributed under the License is distributed on an "AS IS" BASIS,

   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

   See the License for the specific language governing permissions and

   limitations under the License.​
#>

$ErrorActionPreference = 'Stop'
try{
    $url = "https://github.com/dotnet/cli-lab/releases/download/1.7.521001/dotnet-core-uninstall-1.7.521001.msi"
    $path = "$psscriptroot\dotnet-core-uninstall-1.7.521001.msi"
    Write-Host "Downloading [$url]`nSaving at [$path]"
    (new-object net.webClient).DownloadFile($url, $path) 
    Start-Process "msiexec.exe" -Wait -Verbose -ArgumentList "/I $psscriptroot\dotnet-core-uninstall-1.7.521001.msi /norestart /qn" -NoNewWindow -PassThru
    & "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall" remove --all --force --yes --sdk 
    & "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall" remove --all --force --yes --runtime
    & "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall" remove --all --force --yes --aspnet-runtime
    & "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall" remove --all --force --yes --hosting-bundle
    Get-Package -Name "*SDK Uninstall Tool*" |  Uninstall-Package -Force
}catch{
    write-host $_
    if(Test-Path $path){
        Remove-Item $path -Force -Verbose
    }
    exit 1
}