#[CmdletBinding()]


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

$AllUsers = get-msoluser -All
$UserIndex = 0

$msolAccountSku = get-msolAccountSku

foreach ($msoluser in get-msoluser -All)
{
    $UserIndex++
    Write-Progress -Activity "Processing Users" -status "Progress:" -PercentComplete $($UserIndex/$($AllUsers.count)*100)

    $Object = New-Object PSObject -Property @{
        userprincipalname = $msoluser.userprincipalname
        IsLicensed        = $msoluser.IsLicensed
        UsageLocation     = $msoluser.UsageLocation
    }

    foreach ($AccountSkuId in $msolAccountSku)
    {
        foreach ($Service in $AccountSkuId.ServiceStatus)
        {
            $Object | Add-Member -MemberType NoteProperty -Name $("{0}:{1}" -f $AccountSkuId.AccountSkuId, $service.ServicePlan.ServiceName) -Value ([string]::Empty) -Force
        }
    }


    if ($msoluser.IsLicensed)
    {
        foreach ($License in $msoluser.Licenses)
        {
            $AccountSkuId = $License.AccountSkuId

            foreach ($Service in $License.ServiceStatus)
            {
                $ServiceID = $("{0}:{1}" -f $AccountSkuId, $service.ServicePlan.ServiceName)
                $Status    = $Service.ProvisioningStatus

                $Object.$ServiceID = $Status # | Add-Member -MemberType NoteProperty -Name $ServiceID -Value $Status -Force
            }
        }
    }
    $Results.Add($Object) | Out-Null
}

$Results |select userprincipalname,islicensed,usagelocation,* -ea 0 | Export-Excel c:\temp\test_userlicenses.xlsx -FreezeTopRow -Show


