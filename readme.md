# Convert Sharepoint Sites to modern sites pages
This is the Beta versions. Handle with care!

## Overview
This is made to transform sites to modern pages


## Prerequisites
Before using these scripts, make sure you have the following:

PowerShell environment configured with the required modules.
Appropriate permissions to create applications and service principals in Microsoft 365.

You need powershell 7.4
You'll need to have the Microsoft-graph module installed
https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0

You'll need the pnp module to installed.
https://pnp.github.io/powershell/articles/installation.html 

## Usage
You need to create an entra application first.

Run the pnp-application.ps1
You'll need a Global Administrator account to create it
It will give you an apllication id (Client id)

To convert sites open the the pnp-application.ps1
You need a Global adminstrator account and the Sharepoint url


## Author

Emil Mathiasen