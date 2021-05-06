<#

   Copyright 2021 Esri

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
    $url = "https://go.microsoft.com/fwlink/?linkid=2088631" 
    $registryPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
    $installedVersion = [version]((Get-ItemProperty -Path $registryPath -Name Version).Version)
    $installedVersion

    if($installedVersion -ge [version]("4.8")) {
        write-host "dotnet 4.8 already installed"
        return
    }

    $path = "$psscriptroot\ndp48-x86-x64-allos-enu.exe" 
    $path

    if(!(test-path $path)) {
        "Downloading [$url]`nSaving at [$path]" 
        (new-object net.webClient).DownloadFile($url, $path) 
    }

    Invoke-Command -ScriptBlock { Start-Process -FilePath $path -ArgumentList "/q  /norestart" -Wait -PassThru } 
    Write-Host (Get-ItemProperty -Path $registryPath -Name Version).Version
}catch{
    write-host $_
    exit 1
}