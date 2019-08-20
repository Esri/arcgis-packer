<#

   Copyright 2019 Esri

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

# Status of Winrm
Get-Service -Name WinRM | Select Status

# Increase WinRM timeouts

winrm set winrm/config '@{MaxTimeoutms="7200000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{EnumerationTimeoutms="7200000"}'

winrm quickconfig -quiet

$DSCModuleZipPath = $env:ArcGIS_Module_Zip_Path  
$InstallConfigFilePath = $env:Install_Config_File_Path
$UseAzureFiles = ($env:Use_Azure_Files -ieq "True")

# Install ArcGIS Module
$DSC_TARGET = "$($env:ProgramFiles)\\WindowsPowerShell\\Modules\\ArcGIS"
if(Test-Path $DSC_TARGET){ Remove-Item $DSC_TARGET -Force -ErrorAction Ignore -Recurse}
Write-Host "Unzipping and Copying ArcGIS Module to Local Machine"
Expand-Archive $DSCModuleZipPath -DestinationPath $DSC_TARGET -Verbose
Write-Host 'Unzipped and Successfully copied ArcGIS Module to Local Machine'

# Install ArcGIS Artifacts
Write-Host "Downloading and Installing Artifacts"
if($UseAzureFiles -ieq $True){
    # Env Variables
    $AzureStorageAcc = $env:Azure_Storage_Acc
    $AzureStorageAccKey = $env:Azure_Storage_Acc_Key
    $AFSEndpoint = $env:AFS_Endpoint

    # Mount AFS
    $AFSUserName =  "Azure\$AzureStorageAcc"
    $acctKey = ConvertTo-SecureString -String $AzureStorageAccKey -AsPlainText -Force
    $AFSCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $AFSUserName, $acctKey

    Invoke-BuildArcGISAzureImage -InstallConfigFilePath $InstallConfigFilePath -SkipFilesDownload $false -UseAzureFiles $true -AFSCredential $AFSCredential -AFSEndpoint $AFSEndpoint -DebugSwitch
}else{
    Invoke-BuildArcGISAzureImage -InstallConfigFilePath $InstallConfigFilePath -SkipFilesDownload $false -UseAzureFiles $false -DebugSwitch
}

Write-Host "Downloaded and Installed Artifacts"

 # Clean up Temp files, folders and ArcGIS module 
Write-Host 'Removing ArcGIS Module and Temp Folders from Local Machine'
Remove-Item $DSCModuleZipPath -Force -Recurse
Remove-Item $InstallConfigFilePath -Force
if(Test-Path $DSC_TARGET ){ Remove-Item $DSC_TARGET  -Force -ErrorAction Ignore -Recurse}
Write-Host 'Successfully removed ArcGIS Module from Local Machine'

Write-Host "Cleaning SxS..."
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

@(
    "$env:localappdata\Nuget",
    "$env:localappdata\temp\*",
    "$env:windir\logs",
    "$env:windir\panther",
    "$env:windir\temp\*",
    "$env:windir\winsxs\manifestcache"
) | % {
        if(Test-Path $_) {
            Write-Host "Removing $_"
            try {
              Takeown /d Y /R /f $_
              Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
              Remove-Item $_ -Recurse -Force | Out-Null
            } catch { $global:error.RemoveAt(0) }
        }
    }

Write-Host "defragging..."
if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) {
    Optimize-Volume -DriveLetter C
    } else {
    Defrag.exe c: /H
}

Write-Host "0ing out empty space..."
$FilePath="c:\zero.tmp"
$Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
$ArraySize= 64kb
$SpaceToLeave= $Volume.Size * 0.05
$FileSize= $Volume.FreeSpace - $SpacetoLeave
$ZeroArray= new-object byte[]($ArraySize)

$Stream= [io.File]::OpenWrite($FilePath)
try {
   $CurFileSize = 0
    while($CurFileSize -lt $FileSize) {
        $Stream.Write($ZeroArray,0, $ZeroArray.Length)
        $CurFileSize +=$ZeroArray.Length
    }
}
finally {
    if($Stream) {
        $Stream.Close()
    }
}

Del $FilePath

 # Generalizing the VM - Sysprep windows machine
Write-Host "Sysprep started"
if( Test-Path $env:SystemRoot\\windows\\system32\\Sysprep\\unattend.xml ){ rm $env:SystemRoot\\windows\\system32\\Sysprep\\unattend.xml -Force}
& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit
while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }
