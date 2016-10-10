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
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string[]] $UserPrincipalName,
        [string] $License,
        [string] $ServiceName
    )

    foreach ($upn in $UserPrincipalName)
    {
        $MsolUser = Get-MsolUser -UserPrincipalName $upn

        $MyLicense = $null
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
            return $null
        }
        else
        {
            $SS = $null
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