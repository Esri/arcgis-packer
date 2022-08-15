<#

   Copyright 2022 Esri

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
    $url = "https://download.visualstudio.microsoft.com/download/pr/5681bdf9-0a48-45ac-b7bf-21b7b61657aa/bbdc43bc7bf0d15b97c1a98ae2e82ec0/windowsdesktop-runtime-6.0.5-win-x64.exe" 
    $path = "$psscriptroot\windowsdesktop-runtime-6.0.5-win-x64.exe" 
    
    if(!(test-path $path)) {
        "Downloading [$url]`nSaving at [$path]" 
        (new-object net.webClient).DownloadFile($url, $path) 
    }

    Invoke-Command -ScriptBlock { Start-Process -FilePath $path -ArgumentList "/install /quiet /norestart" -Wait -PassThru }
}catch{
    write-host $_
    exit 1
}