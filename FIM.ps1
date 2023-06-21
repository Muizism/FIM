function Show-Menu {
    Write-Host "`n--- File Integrity Monitoring ---`n" -ForegroundColor Cyan
    Write-Host "1. Collect New Baseline"
    Write-Host "2. Check Files with Baseline"
    Write-Host "3. Exit`n"
}

function Collect-NewBaseline {
    Clear-Host
    Write-Host "`n--- Collect New Baseline ---`n" -ForegroundColor Cyan

    $targetFiles = Read-Host "Enter the file paths to include in the baseline (comma-separated):"
    $targetFiles = $targetFiles -split ',' | ForEach-Object { $_.Trim() }

    $baselineHashes = @{}
    foreach ($file in $targetFiles) {
        if (Test-Path -Path $file) {
            $hash = (Get-FileHash $file -Algorithm SHA256).Hash
            $baselineHashes[$file] = $hash
        } else {
            Write-Host "File '$file' not found. Skipping..." -ForegroundColor Yellow
        }
    }

    if ($baselineHashes.Count -gt 0) {
        $baselineHashes.Values | Out-File -Encoding UTF8 -FilePath "C:\Users\muizi\OneDrive\Documents\projects\baseline.txt" -Append
        Write-Host "Baseline created and saved in baseline.txt" -ForegroundColor Green
    } else {
        Write-Host "No valid files found. Baseline not created." -ForegroundColor Yellow
    }

    Start-Sleep -Seconds 2
}

function Check-FilesWithBaseline {
    Clear-Host
    Write-Host "`n--- Check Files with Baseline ---`n" -ForegroundColor Cyan

    $targetFiles = Read-Host "Enter the file paths to check against the baseline (comma-separated):"
    $targetFiles = $targetFiles -split ',' | ForEach-Object { $_.Trim() }

    if (Test-Path -Path "C:\Users\muizi\OneDrive\Documents\projects\baseline.txt") {
        $baselineHashes = Get-Content -Path "C:\Users\muizi\OneDrive\Documents\projects\baseline.txt"

        $success = $false
        foreach ($file in $targetFiles) {
            if (Test-Path -Path $file) {
                $currentHash = (Get-FileHash $file -Algorithm SHA256).Hash

                if ($baselineHashes -contains $currentHash) {
                    $success = $true
                    break
                }
            } else {
                Write-Host "File '$file' not found. Skipping..." -ForegroundColor Yellow
            }
        }

        if ($success) {
            Write-Host "`nFiles match the baseline." -ForegroundColor Green
        } else {
            Write-Host "`nFiles do not match the baseline." -ForegroundColor Red
        }

        Start-Sleep -Seconds 2
    } else {
        Write-Host "`nBaseline file not found. Please collect a new baseline first." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

do {
    Clear-Host
    Show-Menu
    $choice = Read-Host "Please enter your choice"

    switch ($choice) {
        '1' {
            Collect-NewBaseline
            break
        }
        '2' {
            Check-FilesWithBaseline
            break
        }
        '3' {
            break
        }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($choice -ne '3')
