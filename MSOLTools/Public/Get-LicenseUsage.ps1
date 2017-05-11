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
        $Err = $_
	    throw "exception while importing module MSOnline : $($Err.exception.message)"
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
            $Err = $_
            throw "Error connecting to MSOnLine : $($Err.exception.message)"
        }
    }
    catch
    {
        $Err = $_
        throw $Err.exception.message
    }


    $Results = new-object System.Collections.ArrayList

    foreach ($AccountSku in Get-MsolAccountSku)
    {
        $AccountSku | Add-Member -MemberType ScriptProperty -Name AvailableUnits -Value {$This.ActiveUnits - $This.ConsumedUnits} -Force
        Write-Output $AccountSku | select AccountSkuId, @{Expression={Get-AccountSkuIdFriendlyName -AccountSkuId $_.AccountSkuId.split(':')[1]};label='DisplayName'}, ActiveUnits, AvailableUnits, ConsumedUnits, LockedOutUnits, SuspendedUnits, WarningUnits
    }


}
