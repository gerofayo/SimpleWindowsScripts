param (
    [Alias("f")]
    [string]$folder # Folder containing images
)

# Validate if the folder exists
if (-not (Test-Path $folder -PathType Container)) {
    Write-Host "The specified folder does not exist. Please provide a valid folder path." -ForegroundColor Red
    exit
}

# Load the System.Drawing assembly
Add-Type -AssemblyName System.Drawing

# Get all valid image files from the folder
$images = Get-ChildItem -Path $folder -File | Where-Object {
    # Filter for valid images by attempting to load them
    try {
        $bitmap = [System.Drawing.Bitmap]::FromFile($_.FullName)
        $bitmap.Dispose()
        $true
    } catch {
        $false
    }
}

# List to track duplicate files
$duplicates = @()

# Hashtable to track unique image hashes
$hashTable = @{}

# Iterate through each image to find duplicates
foreach ($image in $images) {
    # Calculate SHA256 hash using built-in cmdlet
    $hashResult = Get-FileHash -Path $image.FullName -Algorithm SHA256 -ErrorAction SilentlyContinue
    
    if (-not $hashResult) {
        Write-Host "Skipping file due to hash error: $($image.Name)" -ForegroundColor Red
        continue
    }
    
    $hash = $hashResult.Hash
    
    if ($hashTable.ContainsKey($hash)) {
        Write-Host "Duplicate found: $($image.Name) duplicates $($hashTable[$hash].Name)" -ForegroundColor Yellow
        Write-Host "Removing: $($image.FullName)" -ForegroundColor Red
        $duplicates += $image.FullName
        Remove-Item -Path $image.FullName -Force
    } else {
        $hashTable[$hash] = $image
    }
}

# Output results
if ($duplicates.Count -gt 0) {
    Write-Host "Removed $($duplicates.Count) duplicates:" -ForegroundColor Green
    $duplicates | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    Write-Host "`nRemaining unique images ($($hashTable.Count)):" -ForegroundColor Green
    $hashTable.Values | ForEach-Object { Write-Host "  $($_.Name)" }
} else {
    Write-Host "No duplicate images found." -ForegroundColor Green
}