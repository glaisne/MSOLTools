#requires -version 4


#Get public and private function definition files.
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue |? {$_.name -notlike "*_BETA*"})
    $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

# Here I might...
    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only

Export-ModuleMember -Function $Public.Basename



$MODULEServiceFriendlyName = @{
    'VISIO_CLIENT_SUBSCRIPTION'   = 'Visio Pro for Office 365'
    'PROJECT_CLIENT_SUBSCRIPTION' = 'Project Pro for Office 365'
    'POWERVIDEOSFREE'             = 'Microsoft Power Videos Basic'
    'POWERFLOWSFREE'              = 'Logic flows'
    'POWERAPPSFREE'               = 'Microsoft PowerApps'
    'SQL_IS_SSIM'                 = 'Microsoft Power BI Information Services Plan 1'
    'BI_AZURE_P1'                 = 'Microsoft Power BI Reporting and Analytics Plan 1'
    'SWAY'                        = 'Sway'
    'INTUNE_O365'                 = 'Mobile Device Management for Office 365'
    'YAMMER_ENTERPRISE'           = 'Yammer Enterprise'
    'SHAREPOINTWAC'               = 'Office Online'
    'SHAREPOINTENTERPRISE'        = 'SharePoint Online (Plan 2)'
    'RMS_S_ENTERPRISE'            = 'Azure Rights Management'
    'MCOSTANDARD'                 = 'Skype for Business Online (Plan 2)'
    'EXCHANGE_S_ENTERPRISE'       = 'Exchange Online (Plan 2)'
    'PROJECTWORKMANAGEMENT'       = 'Microsoft Planner'
    'OFFICESUBSCRIPTION'          = 'Office 365 ProPlus'
    'EXCHANGE_S_DESKLESS'         = 'Exchange Online Kiosk'
    'EXCHANGE_S_STANDARD'         = 'Exchange Online (Plan 1)'
    'BI_AZURE_P0'                 = 'Power BI (free)'
    'ADALLOM_S_O365'              = 'Office 365 Advanced Security Management'
    'EQUIVIO_ANALYTICS'           = 'Office 365 Advanced eDiscovery'
    'LOCKBOX_ENTERPRISE'          = 'Customer Lockbox'
    'EXCHANGE_ANALYTICS'          = 'Delve Analytics'
    'ATP_ENTERPRISE'              = 'Exchange Online Advanced Threat Protection'
    'MCOEV'                       = 'Skype for Business Cloud PBX'
    'BI_AZURE_P2'                 = 'Power BI Pro'
    'FLOW_O365_P2'                = 'Flow for Office 365'
    'FLOW_O365_P3'                = 'Flow for Office 365'
    'POWERAPPS_O365_P2'           = 'PowerApps for Office 365'
    'POWERAPPS_O365_P3'           = 'PowerApps for Office 365'
    'Deskless'                    = 'Microsoft StaffHub'
    'TEAMS1'                      = 'Microsoft Teams'
    'RMS_S_PREMIUM'               = 'Azure Rights Management Premium'
    'INTUNE_A'                    = 'Intune A Direct'
    'AAD_PREMIUM'                 = 'Azure Active Directory Premium'
    'MFA_PREMIUM'                 = 'Azure Multi-Factor Authentication'
    'MCOMEETADV'                  = 'Skype for Business PSTN Conferencing'
    'SHAREPOINT_PROJECT'          = 'Project Online'
    'EXCHANGE_S_ARCHIVE_ADDON'    = 'Exchange Online Archiving for Exchange Online'
    'MCOPSTN2'                    = 'Skype for Business PSTN Domestic and International Calling'
}


$MODULELicenseFriendlyName = @{
    'VISIOCLIENT'                    = 'Visio Pro for Office 365'
    'PROJECTCLIENT'                  = 'Project Pro for Office 365'
    'POWERAPPS_INDIVIDUAL_USER'      = 'Microsoft PowerApps and Logic flows'
    'POWER_BI_INDIVIDUAL_USER'       = 'Microsoft Power BI for Office 365 Individual User Trial' 
    'POWER_BI_PRO'                   = 'Power BI Pro'
    'ENTERPRISEPACKWITHOUTPROPLUS'   = 'Office 365 Enterprise E3 without ProPlus'
    'ENTERPRISEPACK'                 = 'Office 365 Enterprise E3'
    'FLOW_FREE'                      = 'Microsoft Flow Free'
    'EXCHANGEDESKLESS'               = 'Exchange Online Kiosk'
    'EXCHANGESTANDARD'               = 'Exchange Online Plan 1'
    'DYN365_ENTERPRISE_PLAN1'        = 'Dynamics 365 Plan 1 Enterprise Edition'
    'POWER_BI_STANDARD'              = 'Power BI (free)'
    'ENTERPRISEPREMIUM_NOPSTNCONF'   = 'Office 365 Enterprise E5 without PSTN Conferencing'
    'EMS'                            = 'Enterprise Mobility Suite'
    'AX7_USER_TRIAL'                 = 'Microsoft Dynamics AX7 User Trial'
    'MCOMEETADV'                     = 'Skype for Business PSTN Conferencing'
    'PROJECTONLINE_PLAN_1'           = 'Project Online'
    'EXCHANGEARCHIVE_ADDON'          = 'Exchange Online Archiving for Exchange Online'
    'MCOPSTN2'                       = 'Skype for Business PSTN Domestic and International Calling'
    'MCOPSTN_5'                      = 'Skype for Business PSTN Calling Domestic Small'
    'EXCHANGEENTERPRISE'             = 'Exchange Online (Plan 2)'
    'PROJECT_MADEIRA_PREVIEW_IW_SKU' = 'Dynamics 365 for Financials for IWs'
    'RIGHTSMANAGEMENT_ADHOC'         = 'Rights Management Adhoc'
    'MCOPSTNC'                       = 'Skype for Business PSTN Consumption'
    'MCOPSTN1'                       = 'Skype for Business PSTN Domestic Calling'
}

# This Alias strictly for backward compatability until the 
# Get-AccountSkuIdFriendlyName function can be removed.
New-Alias -Name Get-AccountSkuIdFriendlyName -Value Get-o365LicenseFriendlyName

Export-ModuleMember -Function * -Alias *