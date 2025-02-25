#Clean Temporary Files Folder
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine

$tempFolder = $(Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Local\Temp")
$tempFiles = Get-ChildItem $tempFolder -Recurse -Force

foreach ($file in $tempFiles) {

    $filePath = $file.FullName

    if(Test-Path $filePath){
        try {
            Remove-Item -Recurse -Force $filePath
        } catch {
            Write-Error "Failed to delete ${filePath}: $_"
            continue
        }
    }

}
