
write-Warning "This cmdlet (Move-MsolLicense) is in a BETA state. It should only be used in testing."

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
function Move-MsolLicense
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [string[]]$UserPrincipalName,

        # Param2 help description
        [string] $SourceLicense,
        [string] $SourceService,

        # Param2 help description
        [string] $DestinationLicense,
        [string] $DestinationService
    )

    Foreach ($upn in $UserPrincipalName)
    {
        $user = $null
        Try
        {
            $user = get-msoluser -userprincipalname $upn
        }
        Catch
        {
            $Err = $_
            Write-Warning "Error getting user ($upn) : $($Err.Exception.Message)"
            continue
        }
        
        if ($user -eq $null)
        {
        	Write-Warning "User not found ($upn)."
            continue
        }

        # Get the current disabled services in the source
        # and the destination Licenses
        $OriginalSourceLicenseOptions = new-object System.Collections.ArrayList
        $OriginalDestinationLicenseOptions = new-object System.Collections.ArrayList
        foreach ($License in $User.Licenses)
        {
            if ($License.AccountSkuId -eq $SourceLicense)
            {
                
                foreach ($Service in $License.ServiceStatus)
                {
                    if ($Service.ProvisioningStatus.tostring() -eq "Disabled")
                    {
                        $OriginalSourceLicenseOptions.Add($Service.serviceplan.serviceName)
                    }
                }
            }
            
            if ($License.AccountSkuId -eq $DestinationLicense)
            {
                
                foreach ($Service in $License.ServiceStatus)
                {
                    if ($Service.ProvisioningStatus.tostring() -eq "Disabled")
                    {
                        $OriginalDestinationLicenseOptions.Add($Service.serviceplan.serviceName)
                    }
                }
            }
        }

        # determine if the user has the source service
        $HasSourceService = $True
        if ($OriginalSourceLicenseOptions.Count -eq 0 -or $OriginalSourceLicenseOptions.Contains($SourceService))
        {
            $HasSourceService = $False
        }
        
        # Determine if the user has the Destination Service
        $HasDestinationService = $True
        if ($OriginalDestinationLicenseOptions.Count -eq 0 -or $OriginalDestinationLicenseOptions.Contains($DestinationService))
        {
            $HasDestinationService = $False
        }



        if ($HasSourceService -eq $False -and $HasDestinationService -eq $true)
        {
            Write-verbose "This user has the required configuration already. no change made."
        }

        if ($HasSourceService -eq $True -and $HasDestinationService -eq $true)
        {
            #
            #    Disable Source License : Source Service
            #

            Write-verbose "disabling $SourceLicense : $SourceService"

            # check if the OriginalSourceLicenseOptions is empty. if so,
            # populate OriginalSourceLicenseOptions with all the services in that license.
            if ($OriginalSourceLicenseOptions.Count -eq 0)
            {
                $NewSourceLicenseOptions = new-object System.Collections.ArrayList
                foreach ($servicename in (get-msolAccountSku |? {$_.Accountskuid -like "*$SourceLicense"}).servicestatus.serviceplan.servicename)
                {
                    $NewSourceLicenseOptions.Add($ServiceName) | Out-Null
                }
            }
            else
            {
                $NewSourceLicenseOptions = $OriginalSourceLicenseOptions.Clone()
            }

            $NewSourceLicenseOptions.Add($SourceService) | Out-Null
            try
            {
                $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $SourceLicense -DisabledPlans $NewSourceLicenseOptions.ToArray() -ErrorAction stop
            }
            catch
            {
                $err = $_
                Write-Warning "Failed creating new License options for Soruce License ($SourceLicense) ($($NewSourceLicenseOptions)) : $($err.exception.message)"
            }

            try
            {
                Set-MsolUserLicense -User $upn -LicenseOptions $LicenseOptions -ErrorAction stop
            }
            catch
            {
                $err = $_
                Write-Warning "Failed setting License options for Soruce License ($SourceLicense) : $($err.exception.message)"
                $LicenseOptions | fl | out-string -stream |? {-not [string]::IsNullOrEmpty($_)} | % {Write-warning "  $_"}
            }
        }

        if ($HasSourceService -eq $True -and $HasDestinationService -eq $False)
        {
            #
            #    Disable Source License : Source Service
            #

            Write-verbose "disabling $SourceLicense : $SourceService"

            # check if the OriginalDestinationLicenseOptions is empty. if so,
            # populate OriginalDestinationLicenseOptions with all the services in that license.
            if ($OriginalSourceLicenseOptions.Count -eq 0)
            {
                $NewSourceLicenseOptions = new-object System.Collections.ArrayList
                foreach ($servicename in (get-msolAccountSku |? {$_.Accountskuid -like "*$SourceLicense"}).servicestatus.serviceplan.servicename)
                {
                    $NewSourceLicenseOptions.Add($ServiceName) | Out-Null
                }
            }
            else
            {
                $NewSourceLicenseOptions = $OriginalSourceLicenseOptions.Clone()
            }

            $NewSourceLicenseOptions.Add($SourceService) | Out-Null
            try
            {
                $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $SourceLicense -DisabledPlans $NewSourceLicenseOptions.ToArray() -ErrorAction stop
            }
            catch
            {
                $err = $_
                Write-Warning "Failed creating new License options for Source License ($SourceLicense) ($($NewSourceLicenseOptions)) : $($err.exception.message)"
            }

            try
            {
                Set-MsolUserLicense -User $upn -LicenseOptions $LicenseOptions -ErrorAction stop
            }
            catch
            {
                $err = $_
                Write-Warning "Failed setting License options for Soruce License ($SourceLicense) : $($err.exception.message)"
                $LicenseOptions | fl | out-string -stream |? {-not [string]::IsNullOrEmpty($_)} | % {Write-warning "  $_"}
            }

            
            
            #
            #    Enabling Destination License : Destination Service
            #

            Write-verbose "Enabling $DestinationLicense : $DestinationService"
            # check if the OriginalDestinationLicenseOptions is empty. if so,
            # populate OriginalDestinationLicenseOptions with all the services in that license.
            if ($OriginalDestinationLicenseOptions.Count -eq 0)
            {
                $NewDestinationLicenseOptions = new-object System.Collections.ArrayList
                foreach ($servicename in (get-msolAccountSku |? {$_.Accountskuid -like "*$DestinationLicense"}).servicestatus.serviceplan.servicename)
                {
                    $NewDestinationLicenseOptions.Add($ServiceName) | Out-Null
                }
            }
            else
            {
                $NewDestinationLicenseOptions = $OriginalDestinationLicenseOptions.Clone()
            }

            
            $NewDestinationLicenseOptions.Remove($DestinationService) | Out-Null
            try
            {
                $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $DestinationLicense -DisabledPlans $NewDestinationLicenseOptions.ToArray() -ErrorAction stop
            }
            catch
            {
                $err = $_
                Write-Warning "Failed creating new License options for Destination License ($DestinationLicense) ($($NewDestinationLicenseOptions)) : $($err.exception.message)"
            }

            try
            {
                Set-MsolUserLicense -User $upn -LicenseOptions $LicenseOptions -ErrorAction stop
            }
            catch
            {
                $err = $_
                Write-Warning "Failed setting License options for Destination License ($DestinationLicense) : $($err.exception.message)"
                $LicenseOptions | fl | out-string -stream |? {-not [string]::IsNullOrEmpty($_)} | % {Write-warning "  $_"}
            }

        }

        if ($HasSourceService -eq $False -and $HasDestinationService -eq $False)
        {
            
            #
            #    Enabling Destination License : Destination Service
            #

            Write-verbose "Enabling $DestinationLicense : $DestinationService"

            # check if the OriginalDestinationLicenseOptions is empty. if so,
            # populate OriginalDestinationLicenseOptions with all the services in that license.
            if ($OriginalDestinationLicenseOptions.Count -eq 0)
            {
                $NewDestinationLicenseOptions = new-object System.Collections.ArrayList
                foreach ($servicename in (get-msolAccountSku |? {$_.Accountskuid -like "*$DestinationLicense"}).servicestatus.serviceplan.servicename)
                {
                    $NewDestinationLicenseOptions.Add($ServiceName) | Out-Null
                }
            }
            else
            {
                $NewDestinationLicenseOptions = $OriginalDestinationLicenseOptions.Clone()
            }

            
            $NewDestinationLicenseOptions.Remove($DestinationService) | Out-Null
            try
            {
                $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $DestinationLicense -DisabledPlans $NewDestinationLicenseOptions.ToArray() -ErrorAction stop
            }
            catch
            {
                $err = $_
                Write-Warning "Failed creating new License options for Destination License ($DestinationLicense) ($($NewDestinationLicenseOptions)) : $($err.exception.message)"
            }

            try
            {
                Set-MsolUserLicense -User $upn -LicenseOptions $LicenseOptions -ErrorAction stop
            }
            catch
            {
                $err = $_
                Write-Warning "Failed setting License options for Destination License ($DestinationLicense) : $($err.exception.message)"
                $LicenseOptions | fl | out-string -stream |? {-not [string]::IsNullOrEmpty($_)} | % {Write-warning "  $_"}
            }
        }



    }

}