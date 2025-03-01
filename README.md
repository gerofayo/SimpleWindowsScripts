# Simple Windows Scripts

A collection of simple and useful PowerShell scripts for Windows.

## How to Use
1. Download the script.
2. Ensure that you are allowed to run scripts by setting the execution policy. This might require administrative privileges. Open PowerShell as an administrator and run:
    ```powershell
    Set-ExecutionPolicy RemoteSigned
    ```
    **Note:** Changing the execution policy might expose your system to security risks. It is recommended to revert the policy to its default setting after running the script:
    ```powershell
    Set-ExecutionPolicy Restricted
    ```
3. Navigate to the directory where the script is located.
4. Run the script using:
    ```powershell
    .\scriptname.ps1
    ```
5. Alternatively, you can right-click the script file and select **"Run with PowerShell"**.

## Scripts
### 1. cleanTempFiles.ps1
Cleans temporary files from the system to free up space.

### 2. imageScraper.ps1
Extracts and downloads images from a specified website or a local HTML file.

#### Usage:
```powershell
- `-url` (`-u`): The URL of the website to scrape images from (required if `-htmlFilePath` is not provided).
  **Note:** This script only extracts images that are directly embedded in the HTML and does not handle images loaded dynamically via JavaScript.
```

#### Parameters:
- `-url` (`-u`): The URL of the website to scrape images from (required if `-htmlFilePath` is not provided). Note: This script only extracts images that are directly embedded in the HTML and does not handle images loaded dynamically via JavaScript.
- `-outputPath` (`-o`): Folder where images will be saved (default: script directory).
- `-noCopy` (`-n`): Prevents saving images that already exist in the output directory.
- `-noCopy` (`-n`): Prevents duplicate file creation.
- `-extension` (`-e`): Image extension(s) to save, separated by commas (default: png, options: png, jpg, jpeg, gif).
- `-htmlFilePath` (`-f`): Path to a local HTML file to extract images from (required if `-url` is not provided).
- `-help` (`-h`): Displays the help message.

#### Example Commands:
1. **Scrape images from a website**:
    ```powershell
    .\imageScraper.ps1 -url "https://example.com" -outputPath "C:\MyImages"
    ```
2. **Extract images from a local HTML file**:
    ```powershell
    .\imageScraper.ps1 -htmlFilePath "C:\Users\User\Desktop\page.html"
    ```
3. **Download only 5 JPEG images, preventing duplicates**:
    ```powershell
    .\imageScraper.ps1 -url "https://example.com" -max 5 -extension "jpg" -noCopy
    ```

### 3. removeImageDuplicates.ps1
Finds and removes duplicate images in a specified folder by comparing their SHA256 hashes.

#### Usage:
```powershell
.\removeImageDuplicates.ps1 -folder "C:\MyImages"
```

#### Parameters:
- `-folder` (`-f`): The folder containing the images to check for duplicates (required). The folder path must be an absolute path.

#### Example Command:
```powershell
.\removeImageDuplicates -folder "C:\MyImages"
```

#### Features:
- Validates image files before processing.
- Uses SHA256 hashing to detect exact duplicates.
- Removes duplicate files automatically.
- Provides a summary of removed duplicates and remaining unique images.

---