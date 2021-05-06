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

}catch{
    write-host $_
    exit 1
}