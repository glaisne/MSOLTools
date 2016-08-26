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
        [string[]] $ServiceName,

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

        # get all the services in this license
        $SKU = Get-MsolAccountSku |? {$_.AccountSkuId -like "*:$AccountSkuID"}

        if ($SKU -isNot [Microsoft.Online.Administration.AccountSkuDetails])
        {
            $Exception = new-object System.ArgumentException("Unable to find Account SKU ID $AccountSkuID")
            Throw $Exception
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

            $DisabledServices = new-object System.Collections.ArrayList
            foreach ($MSOLServiceName in $SKu.servicestatus.ServicePlan.ServiceName)
            {
                if ($ServiceName -notcontains $MSOLServiceName)
                {
                    $DisabledServices.Add($MSOLServiceName) | Out-Null
                }
            }

            # Check to see if we would just be disabling all the services
            If ($DisabledServices.Count -eq $SKu.servicestatus.ServicePlan.ServiceName.count)
            {
                Write-Warning "No services provided were found in License $AccountSkuID"
                Continue
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
                    continue
                }

                foreach ($SN in $ServiceName)
                {
                    if ($DisabledServices -contains $SN)
                    {
                        $DisabledServices.Remove($SN)
                    }
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

                $DisabledServices = new-object System.Collections.ArrayList
                foreach ($MSOLServiceName in $SKu.servicestatus.ServicePlan.ServiceName)
                {
                    if ($ServiceName -notcontains $MSOLServiceName)
                    {
                        $DisabledServices.Add($MSOLServiceName) | Out-Null
                    }
                }

                # Check to see if we would just be disabling all the services
                If ($DisabledServices.Count -eq $SKu.servicestatus.ServicePlan.ServiceName.count)
                {
                    Write-Warning "Could not find service in Licnese $AccountSkuID. No Changes made."
                    Continue
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