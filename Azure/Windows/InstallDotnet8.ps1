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
    $url = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.15/windowsdesktop-runtime-8.0.15-win-x64.exe"
    $path = "$psscriptroot\windowsdesktop-runtime-8.0.15-win-x64.exe"
    if(!(test-path $path)) {
        "Downloading [$url]`nSaving at [$path]" 
        (new-object net.webClient).DownloadFile($url, $path) 
    }

    Invoke-Command -ScriptBlock { Start-Process -FilePath $path -ArgumentList "/install /quiet /norestart" -Wait -PassThru }
}catch{
    write-host $_
    if(Test-Path $path){
        Remove-Item $path -Force -Verbose
    }
    exit 1
}