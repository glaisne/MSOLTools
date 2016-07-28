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
function Add-MsolService
{
    [OutputType([Boolean])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]] $UserPrincipalName,
        
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string] $AccountSkuID,
        
        [Parameter(Mandatory=$true,
                   Position=2)]
        [string] $ServiceName,

        [ValidatePattern("^\w\w$")]
        [string] $UsageLocation
    )

    Foreach ($upn in $UserPrincipalName)
    {
        $upn = $upn.Trim()
        $user = $null
        Try
        {
            $user = get-MsolUser -userPrincipalName $upn -ErrorAction Stop
        }
        Catch
        {
            Throw $_
        }
        
        if ($user -eq $null)
        {
        	Throw "User not found ($upn)."
        }

        if (-not $user.IsLicensed)
        {
            # The user is not licensened.

            if ([string]::IsNullOrEmpty($user.UsageLocation))
            {
                # if usageLocation is not available
                if (-not $PSBoundParameters.ContainsKey('UsageLocation'))
                {
                    $Exception = new-object System.ArgumentNullException("User is not licensed. UsageLocation is required to apply the first license.")
                    Throw $Exception
                }

                # Set UsageLocation
                Try
                {
                    Set-msoluser -UserPrincipalName $upn -UsageLocation $UsageLocation -ErrorAction Stop
                }
                catch
                {
                    Throw $_
                }
            }

            # Add License

            # get all the services in this license
            $SKU = Get-MsolAccountSku |? {$_.AccountSkuId -like "*:$AccountSkuID"}

            if ($sku -isNot [Microsoft.Online.Administration.AccountSkuDetails])
            {
                $Exception = new-object System.ArgumentNullException("Unable to find Account SKU ID $AccountSkuID")
                Throw $Exception
            }

            $DisabledServices = new-object System.Collections.ArrayList
            foreach ($MSOLServiceName in $SKu.servicestatus.ServicePlan.ServiceName)
            {
                if ($MSOLServiceName -ne $ServiceName)
                {
                    $DisabledServices.Add($MSOLServiceName) | Out-Null
                }
            }

            # Check to see if we would just be disabling all the services
            If ($DisabledServices.Count -eq $SKu.servicestatus.ServicePlan.ServiceName.count)
            {
                $Exception = new-object System.ArgumentException("ServiceName $ServiceName not found in License $AccountSkuID")
                Throw $Exception
            }

            # Check to see if we would be enabling more than one service
            If ($DisabledServices.Count -ne $($SKu.servicestatus.ServicePlan.ServiceName.count - 1))
            {
                $Exception = new-object System.ArgumentNullException("ServiceName $ServiceName found multiple times within SKU $AccountSkuID")
                Throw $Exception
            }

            try
            {
                $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $SKU.AccountSkuId -DisabledPlans $DisabledServices.ToArray() -ErrorAction stop
            }
            catch
            {
                throw $_
            }

            try
            {
                Set-MsolUserLicense -User $upn -AddLicenses $SKU.AccountSkuId -LicenseOptions $LicenseOptions -ErrorAction stop
            }
            catch
            {
                throw $_
            }

        }
        else  # User is licensed
        {
            # Determine if this user has this license
            $LicenseApplied = $False
            foreach ($AppliedLicense in $user.Licenses)
            {
                if ($AppliedLicense.AccountSkuId -like "*:$AccountSkuID")
                {
                    $LicenseApplied = $True
                    Break
                }
            }

            if ($LicenseApplied)
            {
                # Get all the current services applied in this license
                $DisabledServices = new-object System.Collections.ArrayList
                $License = $User.Licenses |? {$_.AccountSkuId -like "*:$AccountSkuId"}
                foreach ($Service in $License.ServiceStatus)
                {
                    if ($Service.ProvisioningStatus.tostring() -eq "Disabled")
                    {
                        $DisabledServices.Add($Service.serviceplan.serviceName) | Out-Null
                    }
                }

                if ($DisabledServices.Count -eq 0)
                {
                    Write-Verbose "This user has all services in $AccountSkuId applied."
                    Break
                }

                if ($DisabledServices -notcontains $ServiceName)
                {
                    Write-Verbose "This user already has $ServiceName applied."
                    Break
                }

                if ($DisabledServices -contains $ServiceName)
                {
                    $DisabledServices.Remove($ServiceName) | Out-Null
                }

                try
                {
                    $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $SKU.AccountSkuId -DisabledPlans $DisabledServices.ToArray() -ErrorAction stop
                }
                catch
                {
                    throw $_
                }

                try
                {
                    Set-MsolUserLicense -User $upn -LicenseOptions $LicenseOptions -ErrorAction stop
                }
                catch
                {
                    throw $_
                }
            }
            else  # User does not have this license
            {
                # Add License

                # get all the services in this license
                $SKU = Get-MsolAccountSku |? {$_.AccountSkuId -like "*:$AccountSkuID"}

                if ($sku -isNot [Microsoft.Online.Administration.AccountSkuDetails])
                {
                    $Exception = new-object System.ArgumentException("Unable to find Account SKU ID $AccountSkuID")
                    Throw $Exception
                }

                $DisabledServices = new-object System.Collections.ArrayList
                foreach ($MSOLServiceName in $SKu.servicestatus.ServicePlan.ServiceName)
                {
                    if ($MSOLServiceName -ne $ServiceName)
                    {
                        $DisabledServices.Add($MSOLServiceName) | Out-Null
                    }
                }

                # Check to see if we would just be disabling all the services
                If ($DisabledServices.Count -eq $SKu.servicestatus.ServicePlan.ServiceName.count)
                {
                    $Exception = new-object System.ArgumentNullException("ServiceName $ServiceName not found in License $AccountSkuID")
                    Throw $Exception
                }

                # Check to see if we would be enabling more than one service
                If ($DisabledServices.Count -ne $($SKu.servicestatus.ServicePlan.ServiceName.count - 1))
                {
                    $Exception = new-object System.ArgumentNullException("ServiceName $ServiceName found multiple times within SKU $AccountSkuID")
                    Throw $Exception
                }

                try
                {
                    $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $SKU.AccountSkuId -DisabledPlans $DisabledServices.ToArray() -ErrorAction stop
                }
                catch
                {
                    throw $_
                }

                try
                {
                    Set-MsolUserLicense -User $upn -AddLicenses $SKU.AccountSkuId -LicenseOptions $LicenseOptions -ErrorAction stop
                }
                catch
                {
                    throw $_
                }
            }
        }
    }
}