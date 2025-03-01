# Define the temporary folder path
$tempFolder = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Local\Temp"

# Check if the folder exists
if (-not (Test-Path $tempFolder)) {
    Write-Host "Temporary folder not found: $tempFolder" -ForegroundColor Yellow
    exit
}

# Get all files and folders in the temp directory
$tempFiles = Get-ChildItem -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue

# Initialize counters
$deletedCount = 0
$failedCount = 0

# Loop through each file/folder and attempt to delete it
foreach ($file in $tempFiles) {
    $filePath = $file.FullName

    try {
        # Attempt to delete the file/folder
        Remove-Item -Path $filePath -Recurse -Force -ErrorAction Stop
        Write-Host "Deleted: $filePath" -ForegroundColor Green
        $deletedCount++
    } catch {
        Write-Host "Failed to delete: $filePath - $_" -ForegroundColor Red
        $failedCount++
    }
}

# Display summary
Write-Host "Cleanup completed." -ForegroundColor Cyan
Write-Host "Total files/folders deleted: $deletedCount" -ForegroundColor Cyan
Write-Host "Total files/folders failed to delete: $failedCount" -ForegroundColor Cyan