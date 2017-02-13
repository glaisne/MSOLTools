<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-LicenseUsage
{
    TRY
    {
	    IF (-not (Get-Module -Name MSOnline))
	    {
		    Write-Verbose -Message "Import module MSOL"
		    Import-Module -Name MSOnline -ErrorAction Stop
	    }
    }
    CATCH
    {
        $err = $_
	    throw "exception while importing module MSOnline : $($err.exception.message)"
    }

    try
    {
        get-msoldomain -ErrorAction stop | Out-Null
    }
    catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException]
    {
        try
        {
            Connect-MsolService
        }
        catch
        {
            $err = $_
            throw "Error connecting to MSOnLine : $($err.exception.message)"
        }
    }
    catch
    {
        $err = $_
        throw $e.exception.message
    }
<#
        function Get-AccountSkuIdFriendlyName
        {
            [CmdletBinding()]
            Param
            (
                # Param1 help description
                [Parameter(Mandatory=$True,
                           ValueFromPipeline=$True,
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
#>



    $Results = new-object System.Collections.ArrayList

    foreach ($AccountSku in Get-MsolAccountSku)
    {
        $AccountSku | Add-Member -MemberType ScriptProperty -Name AvailableUnits -Value {$this.ActiveUnits - $this.ConsumedUnits - $this.LockedOutUnits - $this.SuspendedUnits - $this.WarningUnits} -Force
        Write-Output $AccountSku | select AccountSkuId, @{Expression={Get-AccountSkuIdFriendlyName -AccountSkuId $_.AccountSkuId.split(':')[1]};label='DisplayName'}, ActiveUnits, AvailableUnits, ConsumedUnits, LockedOutUnits, SuspendedUnits, WarningUnits
    }


}
