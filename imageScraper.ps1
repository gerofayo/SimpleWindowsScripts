[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Alias("u")]
    [string]$url, # URL to extract images from (optional if -html is provided)

    [Alias("o")]
    [ValidateScript({ Test-Path $_ -IsValid })]
    [string]$outputPath = $PSScriptRoot, # Folder where images will be saved

    [Alias("m")]
    [int]$max = [int]::MaxValue, # Maximum number of images to extract

    [Alias("n")]
    [switch]$noCopy, # Prevents duplicate file creation

    [Alias("e")]
    [ValidateSet("png", "jpg", "jpeg", "gif")]
    [string]$extension = "png", # Image extension (default: png)

    [Alias("f")]
    [ValidateScript({ Test-Path $_ })]
    [string]$htmlFilePath, # Local HTML file to extract images from

    [Alias("h")]
    [switch]$help # Show help message
)

# Show help message
if ($help) {
    Write-Host @"
Usage: .\imageScraper.ps1 [-url <URL>] [-html <FilePath>] [-outputPath <Path>] [-max <Number>] [-extension <Extension>] [-noCopy] [-help]

Parameters:
    -url (u)        URL to extract images from (optional if -html is provided)
    -html (f)       Path to local HTML file to extract images from (optional if -url is provided)
    -outputPath (o) Folder where images will be saved (default: script directory)
    -max (m)        Maximum number of images to extract (default: all)
    -noCopy (n)     Prevents duplicate file names
    -extension (e)  Image extension (default: png)
    -help (h)       Show this message
"@ -ForegroundColor Cyan
    exit
}

# Ensure at least one required parameter is present
if (-not $url -and -not $htmlFilePath) {
    Write-Host "Error: You must specify either -url or -html. Use -help for more information." -ForegroundColor Red
    exit 1
}

# Create output folder if it does not exist
if (-not (Test-Path $outputPath)) {
    Write-Host "Creating output folder: $outputPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

# Get HTML content from a file or URL
try {
    if ($htmlFilePath) {
        Write-Host "Reading HTML from file: $htmlFilePath" -ForegroundColor Green
        $htmlContent = Get-Content -Path $htmlFilePath -Raw
    } else {
        Write-Host "Fetching webpage: $url" -ForegroundColor Green
        $response = Invoke-WebRequest -Uri $url
        $htmlContent = $response.Content
    }

    # Extract image URLs and alt attributes using regex
    $imageMatches = [regex]::Matches($htmlContent, '<img[^>]+src=["'']([^"'']+)["''][^>]*alt=["'']([^"'']*)["'']')
    $imageUrls = $imageMatches | ForEach-Object {
        @{
            Url = $_.Groups[1].Value
            Alt = $_.Groups[2].Value
        }
    }
    Write-Host "$($imageUrls.Count) images found." -ForegroundColor Cyan
} catch {
    Write-Host "Error: Unable to retrieve or process HTML. $_" -ForegroundColor Red
    exit 1
}

# Image download counter
$imageNumber = 1

foreach ($image in $imageUrls) {
    if ($imageNumber -gt $max) { break }

    $src = $image.Url
    $alt = $image.Alt

    # Convert relative URLs to absolute
    if ($src -match "^//") { $src = "https:$src" }
    if ($src -notmatch "^https?://") {
        if ($url) {
            $baseUri = [System.Uri]::new($url)
            $src = (New-Object System.Uri($baseUri, $src)).AbsoluteUri
        } else {
            Write-Host "Skipping image $imageNumber : Relative URL without base." -ForegroundColor Yellow
            continue
        }
    }

    # Generate file name using alt attribute or fallback to numeration
    if (-not [string]::IsNullOrWhiteSpace($alt)) {
        $fileName = ($alt -replace '[<>:"/\\|?*]', '') + ".$extension" # Sanitize alt text for filename
    } else {
        $fileName = "image$imageNumber.$extension"
    }
    $filePath = Join-Path -Path $outputPath -ChildPath $fileName

    # Handle duplicate files if -noCopy is not active
    if (-not $noCopy) {
        $counter = 1
        while (Test-Path $filePath) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
            $filePath = Join-Path -Path $outputPath -ChildPath "$baseName`_copy$counter.$extension"
            $counter++
        }
    }

    # Download the image
    try {
        Write-Host "Downloading image $imageNumber : $src" -ForegroundColor Blue
        Invoke-WebRequest -Uri $src -OutFile $filePath -ErrorAction Stop
        Write-Host "Saved to: $filePath" -ForegroundColor Green
    } catch {
        Write-Host "Error downloading image $imageNumber : $_" -ForegroundColor Red
    }

    $imageNumber++
}

Write-Host "Image download completed. Total downloaded: $($imageNumber - 1)." -ForegroundColor Cyan