### Register pnp application
## v. 1.1
## 
## You need to have the mgraph module installed in powershell'
##https://learn.microsoft.com/en-us/sharepoint/dev/transform/modernize-userinterface-site-pages-powershell



function New-ConvertSitesToModern {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Insert the URL of the site")]
        [string]$SPsiteurl,
        [Parameter(Mandatory = $true, HelpMessage = "Insert the client ID of the application.")]
        [string]$Clientid,
        [Parameter(Mandatory = $true, HelpMessage = "Write the file path, e.g., C:\logsharepointveeam.")]
        [string]$LogOutputFolder
    )

    try {
        # Ensure log folder exists
        if (!(Test-Path -Path $LogOutputFolder)) {
            New-Item -ItemType Directory -Path $LogOutputFolder | Out-Null
        }

        # Connect to SharePoint
        connect-PnPOnline -Url $SPsiteurl -Interactive -ClientId $Clientid
        Start-Sleep -s 3

        # Enable modern pages feature
        Write-Host "Ensuring the modern page feature is enabled..." -ForegroundColor Green
        Enable-PnPFeature -Identity "B6917CB1-93A0-4B97-A84D-7CF49975D4EC" -Scope Web -Force

        # Verify and fetch pages
        $list = Get-PnPList -Identity "sitepages" -ErrorAction SilentlyContinue
        if (-not $list) {
            Write-Host "Site Pages library not found. Exiting..." -ForegroundColor Red
            return
        }

        Write-Host "Fetching pages from the Site Pages library..." -ForegroundColor Green
        $pages = Get-PnPListItem -List sitepages -PageSize 500

        # Process pages
        foreach ($page in $pages) {
            $pageName = $page.FieldValues["FileLeafRef"]
            
            if ($page.FieldValues["ClientSideApplicationId"] -eq "b6917cb1-93a0-4b97-a84d-7cf49975d4ec") {
                Write-Host "Page '$pageName' is modern, no need to modernize it again" -ForegroundColor Yellow
            } else {
                Write-Host "Processing page '$pageName'" -ForegroundColor Cyan
                try {
                    ConvertTo-PnPPage -Identity $page.FieldValues["ID"] -Overwrite -TakeSourcePageName:$true `
                        -LogType File -LogFolder $LogOutputFolder -LogSkipFlush `
                        -KeepPageCreationModificationInformation -CopyPageMetadata
                } catch {
                    Write-Host "Error converting page '$pageName': $_" -ForegroundColor Red
                }
            }
        }

        # Save conversion logs
        Write-Host "Saving the conversion log file..." -ForegroundColor Green
        Save-PnPPageConversionLog
    } catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
    } finally {
        Write-Host "Disconnecting from SharePoint..." -ForegroundColor Green
        Disconnect-PnPOnline
    }
    
    Write-Host "Wiki and web part page modernization complete! :)" -ForegroundColor Green
}

New-ConvertSitesToModern
