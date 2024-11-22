### Register pnp application
## v. 1.0
## 
## You need to have the mgraph module installed in powershell'
##https://learn.microsoft.com/en-us/sharepoint/dev/transform/modernize-userinterface-site-pages-powershell



function New-ConvertSitesToModern {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Insert the url of the site")]
        [string]$SPsiteurl,
        [Parameter(Mandatory = $true, HelpMessage = "Insert the client id, of the application.")]
            [string]$appname
    )


    connect-PnPOnline -url $SPsiteurl -Interactive -ClientId $appname
    Start-Sleep -s 3

    Write-Host "Ensure the modern page feature is enabled..." -ForegroundColor Green
    Enable-PnPFeature -Identity "B6917CB1-93A0-4B97-A84D-7CF49975D4EC" -Scope Web -Force

Write-Host "Modernizing wiki and web part pages..." -ForegroundColor Green
    # Get all the pages in the site pages library. 
    # Use paging (-PageSize parameter) to ensure the query works when there are more than 5000 items in the list
    $pages = Get-PnPListItem -List sitepages -PageSize 500

Write-Host "Pages are fetched, let's start the modernization..." -ForegroundColor Green
    Foreach($page in $pages)
    { 
        $pageName = $page.FieldValues["FileLeafRef"]
        
        if ($page.FieldValues["ClientSideApplicationId"] -eq "b6917cb1-93a0-4b97-a84d-7cf49975d4ec" ) 
        { 
            Write-Host "Page " $page.FieldValues["FileLeafRef"] " is modern, no need to modernize it again" -ForegroundColor Yellow
        } 
        else 
        {
            Write-Host "Processing page $($pageName)" -ForegroundColor Cyan

         


            ConvertTo-PnPPage -Identity $page.FieldValues["ID"] -Overwrite -TakeSourcePageName:$true -LogType File -LogFolder $LogOutputFolder -LogSkipFlush -KeepPageCreationModificationInformation -CopyPageMetadata
        }
    }

# Write the logs to the folder
    Write-Host "Writing the conversion log file..." -ForegroundColor Green
    Save-PnPPageConversionLog

Write-Host "Wiki and web part page modernization complete! :)" -ForegroundColor Green
}
end
{
    Disconnect-PnPOnline
}
