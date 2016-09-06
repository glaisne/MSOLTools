function Get-AccountSkuIdFriendlyName
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true,
                    Position=0)]
        $AccountSkuId
    )
    switch ($AccountSkuId)
    {
		'VISIOCLIENT'                   { "Visio Pro for Office 365"; break }
		'PROJECTCLIENT'                 { "Project Pro for Office 365"; break }
		'POWERAPPS_INDIVIDUAL_USER'     { "Microsoft PowerApps and Logic flows"; break }
		'POWER_BI_INDIVIDUAL_USER'      { "Microsoft Power BI for Office 365 Individual User Trial"; break } 
		'ENTERPRISEPACKWITHOUTPROPLUS'  { "Office 365 Enterprise E3 without ProPlus"; break }
		'ENTERPRISEPACK'                { "Office 365 Enterprise E3"; break }
		'EXCHANGEDESKLESS'              { "Exchange Online Kiosk"; break }
		'EXCHANGESTANDARD'              { "Exchange Online Plan 1"; break }
		'POWER_BI_STANDARD'             { "Power BI (free)"; break }
		'ENTERPRISEPREMIUM_NOPSTNCONF'  { "Office 365 Enterprise E5 without PSTN Conferencing"; break }
		'EMS'                           { "Enterprise Mobility Suite"; break }
		'MCOMEETADV'                    { "Skype for Business PSTN Conferencing"; break }
		'PROJECTONLINE_PLAN_1'          { "Project Online"; break }
		'EXCHANGEARCHIVE_ADDON'         { "Exchange Online Archiving for Exchange Online"; break }
		'MCOPSTN2'                      { "Skype for Business PSTN Domestic and International Calling"; break }
		'EXCHANGEENTERPRISE'            { "Exchange Online (Plan 2)"; break }
        Default {$AccountSkuId}
    }
}