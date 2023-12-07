<#

   Copyright 2023 Esri

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
    $url = "https://download.visualstudio.microsoft.com/download/pr/dde9eb7e-8ea8-494a-9b04-5db26c7740e2/43d5050cfa63b7323749c7e56fedd3ac/windowsdesktop-runtime-6.0.24-win-x64.exe"
    $path = "$psscriptroot\windowsdesktop-runtime-6.0.24-win-x64.exe" 
    
    if(!(test-path $path)) {
        "Downloading [$url]`nSaving at [$path]" 
        (new-object net.webClient).DownloadFile($url, $path) 
    }

    Invoke-Command -ScriptBlock { Start-Process -FilePath $path -ArgumentList "/install /quiet /norestart" -Wait -PassThru }
}catch{
    write-host $_
    exit 1
}