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
        Write-Verbose "[$(Get-Date -f 'yyyyMMdd HHmmss')] $($userPrincipalName.padRight(30)) [Get-MSOLUserServiceStatus] Getting user."
        Try
        {
            $MsolUser = Get-MsolUser -UserPrincipalName $Upn -ErrorAction Stop
        }
        catch
        {
            $err = $_
            Write-Warning "[$(Get-Date -f 'yyyyMMdd HHmmss')] $($userPrincipalName.padRight(30)) [Get-MSOLUserServiceStatus] Failed getting user : $($err.Exception.Message)"
        }
        

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
            Write-Verbose "[$(Get-Date -f 'yyyyMMdd HHmmss')] $($userPrincipalName.padRight(30)) [Get-MSOLUserServiceStatus] User has the license ($License)"
            $SS = $Null
            :FirstLoop foreach ($ServiceStatus in $MyLicense.ServiceStatus)
            {
                :SecondLoop foreach ($ServicePlan in $ServiceStatus.ServicePlan)
                {
                    if ($ServicePlan.ServiceName -eq $ServiceName)
                    {
                        Write-Verbose "[$(Get-Date -f 'yyyyMMdd HHmmss')] $($userPrincipalName.padRight(30)) [Get-MSOLUserServiceStatus] Service Status: $ServiceStatus"
                        $SS = $ServiceStatus
                        Break FirstLoop
                    }
                }
            }
            $SS.ProvisioningStatus
        }
    }
}