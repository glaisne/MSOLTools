function Get-O365LicenseFriendlyName
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true,
                    Position=0)]
        $LicenseID
    )

    foreach ($License in Get-LicenseUsage)
    {
        if ($License.AccountSkuID -match "[a-z0-9]+:$LicenseID$")
        {
            $License.DisplayName
            Break
        }
    }
}
