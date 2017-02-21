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
function Get-MSOLUserServiceStatus
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$True,
                   Position=0)]
        [string[]] $UserPrincipalName,
        [string] $License,
        [string] $ServiceName
    )

    foreach ($Upn in $UserPrincipalName)
    {
        $MsolUser = Get-MsolUser -UserPrincipalName $Upn

        $MyLicense = $Null
        $HasMyLicense = $False
        foreach ($MsolUserLicense in $MsolUser.Licenses.getenumerator())
        {
            if ($MsolUserLicense.accountSku.SkuPartNumber -eq $License)
            {
                $HasMyLicense = $True
                $MyLicense = $MsolUserLicense
                Break
            }
        }

        if (-Not $HasMyLicense)
        {
            return $Null
        }
        else
        {
            $SS = $Null
            :FirstLoop foreach ($ServiceStatus in $MyLicense.ServiceStatus)
            {
                :SecondLoop foreach ($ServicePlan in $ServiceStatus.ServicePlan)
                {
                    if ($ServicePlan.ServiceName -eq $ServiceName)
                    {
                        $SS = $ServiceStatus
                        Break FirstLoop
                    }
                }
            }
            $SS.ProvisioningStatus
        }
    }
}