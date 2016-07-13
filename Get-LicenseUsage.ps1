TRY
{
	IF (-not (Get-Module -Name MSOnline -ListAvailable))
	{
		Write-Verbose -Message "Import module MSOL"
		#Import-Module -Name MSOnline -ErrorAction Stop
	}
}
CATCH
{
    $err = $_
	throw "exception while importing module MSOnline : $($err.exception.message)"
}

try
{
    get-msoldomain -ea stop | Out-Null
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

$Results = new-object System.Collections.ArrayList

foreach ($AccountSku in Get-MsolAccountSku)
{
    $AccountSku | Add-Member -MemberType ScriptProperty -Name AvailableUnits -Value {$this.ActiveUnits - $this.ConsumedUnits - $this.LockedOutUnits - $this.SuspendedUnits - $this.WarningUnits} -Force

    $Results.Add($AccountSku) | Out-Null

    $Results | select ExtensionData, AccountName, AccountObjectId, AccountSkuId, ActiveUnits, AvailableUnits, ConsumedUnits, LockedOutUnits, ServiceStatus, SkuId, SkuPartNumber, SubscriptionIds, SuspendedUnits, TargetClass, WarningUnits
}

