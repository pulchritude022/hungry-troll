# PowerShell script to rename all directories and files in assets folder
# Converts to lowercase and replaces spaces with underscores

$assetsPath = "assets"

function Normalize-Name {
    param([string]$name)
    # Convert to lowercase and replace spaces with underscores
    $name = $name.ToLower()
    $name = $name -replace '\s+', '_'
    return $name
}

function Rename-Directories {
    param([string]$path)
    
    # Collect all directories first, then rename from deepest to shallowest
    $allDirs = @()
    $queue = New-Object System.Collections.Queue
    $queue.Enqueue($path)
    
    while ($queue.Count -gt 0) {
        $currentPath = $queue.Dequeue()
        try {
            $dirs = Get-ChildItem -Path $currentPath -Directory -ErrorAction SilentlyContinue
            foreach ($dir in $dirs) {
                $allDirs += $dir
                $queue.Enqueue($dir.FullName)
            }
        } catch {
            # Directory may have been renamed, skip
        }
    }
    
    # Sort by depth (deepest first) - count path separators
    $sortedDirs = $allDirs | Sort-Object { ($_.FullName -split '[\\/]').Count } -Descending
    
    foreach ($dir in $sortedDirs) {
        try {
            $newName = Normalize-Name $dir.Name
            if ($dir.Name -ne $newName -and (Test-Path $dir.FullName)) {
                Write-Host "Renaming directory: $($dir.Name) -> $newName"
                Rename-Item -Path $dir.FullName -NewName $newName -ErrorAction Stop
            }
        } catch {
            Write-Host "Skipping $($dir.FullName): $_"
        }
    }
}

function Rename-Files {
    param([string]$path)
    
    # Get all files recursively
    $files = Get-ChildItem -Path $path -File -Recurse -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        try {
            $newName = Normalize-Name $file.Name
            if ($file.Name -ne $newName -and (Test-Path $file.FullName)) {
                Write-Host "Renaming file: $($file.Name) -> $newName"
                Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
            }
        } catch {
            Write-Host "Skipping $($file.FullName): $_"
        }
    }
}

Write-Host "Starting asset renaming process..."
Write-Host "Step 1: Renaming directories..."
Rename-Directories -path $assetsPath

Write-Host "Step 2: Renaming files..."
Rename-Files -path $assetsPath

Write-Host "Asset renaming complete!"

