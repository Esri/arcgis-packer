$ErrorActionPreference = 'Stop'
try{

    $url = "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/304fddef-b073-4e0a-b1ff-c2ea02584017/MicrosoftEdgeWebview2Setup.exe"
    $path = "$psscriptroot\MicrosoftEdgeWebview2Setup.exe"
    if(!(test-path $path)) {
        "Downloading [$url]`nSaving at [$path]" 
        (new-object net.webClient).DownloadFile($url, $path)
    }

    Invoke-Command -ScriptBlock { Start-Process -FilePath $path -ArgumentList "/silent /install" -Wait -PassThru }
}catch{
    write-host $_
    if(Test-Path $path){
        Remove-Item $path -Force -Verbose
    }
    exit 1
}