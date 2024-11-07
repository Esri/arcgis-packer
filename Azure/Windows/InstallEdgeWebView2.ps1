<#

   Copyright 2024 Esri

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

    $url = "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/1b33f4e1-227e-4265-b9e9-3751aeeb2efe/MicrosoftEdgeWebview2Setup.exe"
    $path = "$psscriptroot\MicrosoftEdgeWebview2Setup.exe"
    if(!(test-path $path)) {
        "Downloading [$url]`nSaving at [$path]" 
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $path)
    }

    Invoke-Command -ScriptBlock { Start-Process -FilePath $path -ArgumentList "/silent /install" -Wait -PassThru }
}catch{
    write-host $_
    if(Test-Path $path){
        Remove-Item $path -Force -Verbose
    }
    exit 1
}