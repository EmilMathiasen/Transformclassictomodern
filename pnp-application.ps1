### Register pnp application
## v. 1.1
## 
## You need to have the mgraph module installed in powershell'
##https://pnp.github.io/powershell/articles/registerapplication.html

function New-PnPApplication {
    param (
        [string]$AppName = "PnP Rocks",
        [string]$RedirectUri = "http://localhost",
        [string]$Scope = "AllSites.Read"
    )

    # Connect to Microsoft Graph with required scopes
    Connect-MgGraph -Scopes "Application.ReadWrite.All", "Directory.AccessAsUser.All", "Directory.ReadWrite.All", `
        "RoleManagement.ReadWrite.Directory", "AppRoleAssignment.ReadWrite.All", "Organization.ReadWrite.All"

    # Create the application
    $app = New-MgApplication -DisplayName $AppName -SignInAudience "AzureADMyOrg" `
        -PublicClient @{ RedirectUris = $RedirectUri } -IsFallbackPublicClient

    # Create a service principal for the application
    $clientsp = New-MgServicePrincipal -AppId $app.AppId

    # Get Microsoft Graph Service Principal
    $eoresource = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0ff1-ce00-000000000000'"

    # Grant delegated permissions
    New-MgOauth2PermissionGrant -BodyParameter @{
        clientId    = $clientsp.Id
        consentType = "AllPrincipals"
        resourceId  = $eoresource.Id
        scope       = $Scope
    }

    # Output application details
    Write-Host "remember to write the down this Application (client) ID:"
    return @{
        AppClientID = $app.AppId
  }
}

# Run the function
New-PnPApplication
