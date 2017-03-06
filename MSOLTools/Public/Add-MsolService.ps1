<#
.Synopsis
   Adds services to Office 365 licenses.
.DESCRIPTION
   This function will enable services for a give license in Office 365. In 
   cases where the license is not assigned, this fucntion will assign the
   licenses then add the services.

   Additionally, if the user does not have any licenses, this function will
   assign the license and add the service including, but only if it is specified,
   will set the UsageLocation for the user.

   This function makes it easier to add licenses then using the default 
   MS Online tools where license need to be identified as disabled.
.EXAMPLE
   Example of how to use this cmdlet
#>
function Add-MsolService
{
    [OutputType([Boolean])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$True,
                   ValueFromPipelineByPropertyName=$True,
                   Position=0)]
        [string[]] $UserPrincipalName,
        
        [Parameter(Mandatory=$True,
                   Position=1)]
        [string] $AccountSkuID,
        
        [Parameter(Mandatory=$True,
                   Position=2)]
        [string[]] $ServiceName,

        [ValidatePattern("^\w\w$")]
        [string] $UsageLocation,

        [string] $RevertScript
    )

    Begin
    {
        $CreateRevertScript = $False
        if ($PSBoundParameters.ContainsKey('RevertScript'))
        {
            if ($(Test-Path $(split-path $RevertScript)))
            {
                "" | Out-File $RevertScript -Encoding ascii -Append -NoClobber -Force -ErrorAction Stop
                $CreateRevertScript = $True
            }
            else
            {
                throw "Unable to find path $(split-path $RevertScript)"
            }
        }
    }

    Process
    {
        Foreach ($UPN in $UserPrincipalName)
        {
            $UPN = $UPN.Trim()

            Write-Verbose "$UPN : Processing user"
            $User = $Null
            Try
            {
                $User = get-MsolUser -UserPrincipalName $UPN -ErrorAction Stop
            }
            Catch
            {
                Throw $_
            }
        
            if ($User -eq $Null)
            {
        	    Throw "User not found ($UPN)."
            }

            # Get all the services in this license
            $SKU = Get-MsolAccountSku |? {$_.SkuPartNumber -eq $AccountSkuID}

            # Make sure we have what we need.
            if ($SKU -isNot [Microsoft.Online.Administration.AccountSkuDetails])
            {
                $Exception = new-object System.ArgumentException("Unable to find Account SKU ID $AccountSkuID")
                Throw $Exception
            }

            if (-not $User.IsLicensed)
            {
                Write-Verbose "$UPN : User is not licensed."

                if ([string]::IsNullOrEmpty($User.UsageLocation))
                {
                    # If UsageLocation is not available throw an exception
                    if (-not $PSBoundParameters.ContainsKey('UsageLocation'))
                    {
                        $Exception = new-object System.ArgumentNullException("User is not licensed. UsageLocation is required to apply the first license.")
                        Throw $Exception
                    }

                    # Set UsageLocation
                    Write-Verbose "$UPN : Setting user's UsageLocation to $UsageLocation"
                    Try
                    {
                        Set-msoluser -UserPrincipalName $UPN -UsageLocation $UsageLocation -ErrorAction Stop
                    }
                    catch
                    {
                        Throw $_
                    }
                
                    Write-Verbose "$UPN : Services before any change:"
                    ((Get-MsolUser -UserPrincipalName $UPN).licenses |? {$_.accountsku.skupartnumber -eq $AccountSkuID}).servicestatus |ft -AutoSize | Out-String -Stream | ? {-not [string]::IsNullOrEmpty($_)} |% {write-verbose "$(" "*4)$_"}

                }

                # Add License

                $DisabledServices = new-object System.Collections.ArrayList
                foreach ($MSOLServiceName in $SKu.servicestatus.ServicePlan.ServiceName)
                {
                    if ($ServiceName -notcontains $MSOLServiceName)
                    {
                        Write-Verbose "$UPN : Disabling Service: $MSOLServiceName"
                        $DisabledServices.Add($MSOLServiceName) | Out-Null
                    }
                    else
                    {
                        Write-Verbose "$UPN : Enabling Service: $MSOLServiceName"
                    }
                }

                # Check to see if we would just be disabling all the services
                If ($DisabledServices.Count -eq $SKu.servicestatus.ServicePlan.ServiceName.count)
                {
                    Write-Warning "No services provided were found in License $AccountSkuID"
                    Continue
                }

                Write-Verbose "$UPN : Configuring License Options."
                try
                {
                    $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $SKU.AccountSkuId -DisabledPlans $DisabledServices.ToArray() -ErrorAction stop
                }
                catch
                {
                    throw $_
                }

                Write-Verbose "$UPN : Setting user licenses."
                try
                {
                    Set-MsolUserLicense -User $UPN -AddLicenses $SKU.AccountSkuId -LicenseOptions $LicenseOptions -ErrorAction stop
                }
                catch
                {
                    throw $_
                }
                Write-Verbose "$Upn : Services After change:"
                ((Get-MsolUser -UserPrincipalName $UPN).licenses |? {$_.accountsku.skupartnumber -eq $AccountSkuID}).servicestatus |ft -AutoSize | Out-String -Stream | ? {-not [string]::IsNullOrEmpty($_)} |% {write-verbose "$(" "*4)$_"}
            
                write-verbose "$UPN : RevertScript : Set-MsolUserLicense -User $UPN -RemoveLicenses $($SKU.AccountSkuId)"
                if ($CreateRevertScript)
                {
                    "<# $upn #> Set-MsolUserLicense -User $UPN -RemoveLicenses $($SKU.AccountSkuId)" | Out-File $RevertScript -Encoding ascii -Append -Force -NoClobber
                }

            }
            else  # User is licensed
            {
                Write-Verbose "$UPN : User is licensed."

                # Determine if this user has this license
                $LicenseApplied = $False
                foreach ($AppliedLicense in $User.Licenses)
                {
                    if ($AppliedLicense.accountsku.skupartnumber -eq $AccountSkuID)
                    {
                        $LicenseApplied = $True
                        Break
                    }
                }

                if ($LicenseApplied)
                {
                    Write-Verbose "$UPN : User has this license assigned : $AccountSkuID"

                    Write-Verbose "$UPN : Services before any changes:"
                    ((Get-MsolUser -UserPrincipalName $UPN).licenses |? {$_.accountsku.skupartnumber -eq $AccountSkuID}).servicestatus |ft -AutoSize | Out-String -Stream | ? {-not [string]::IsNullOrEmpty($_)} |% {write-verbose "$(" "*4)$_"}

                    # Get all the current services applied in this license
                    $DisabledServices = new-object System.Collections.ArrayList
                    $License = $User.Licenses |? {$_.accountsku.skupartnumber -eq $AccountSkuId}
                    foreach ($Service in $License.ServiceStatus)
                    {
                        if ($Service.ProvisioningStatus.tostring() -eq "Disabled")
                        {
                            Write-Verbose "$UPN : Current disabled service : $($Service.serviceplan.serviceName)"
                            $DisabledServices.Add($Service.serviceplan.serviceName) | Out-Null
                        }
                    }

                    $RevertServices = $DisabledServices.Clone()

                    if ($DisabledServices.Count -eq 0)
                    {
                        Write-Verbose "This user has all services in $AccountSkuId applied."
                        continue
                    }

                    $DisabledServicesAltered = $False
                    foreach ($SN in $ServiceName)
                    {
                        if ($DisabledServices -contains $SN)
                        {
                            Write-Verbose "$UPN : Enabling this service: $SN"
                            $DisabledServices.Remove($SN.ToUpper())
                            $DisabledServicesAltered = $True
                        }
                    }

                    if ($DisabledServicesAltered -eq $False)
                    {
                        Write-Verbose "$UPN : No changes made to user's services."
                        ((Get-MsolUser -UserPrincipalName $UPN).licenses |? {$_.accountsku.skupartnumber -eq $AccountSkuID}).servicestatus |ft -AutoSize | Out-String -Stream | ? {-not [string]::IsNullOrEmpty($_)} |% {write-verbose "$(" "*4)$_"}
                        Continue
                    }

                    Write-Verbose "$UPN : Configuring License Options."
                    try
                    {
                        $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $SKU.AccountSkuId -DisabledPlans $DisabledServices.ToArray() -ErrorAction stop
                    }
                    catch
                    {
                        throw $_
                    }

                    Write-Verbose "$UPN : Setting user licenses."
                    try
                    {
                        Set-MsolUserLicense -User $UPN -LicenseOptions $LicenseOptions -ErrorAction stop
                    }
                    catch
                    {
                        throw $_
                    }
                
                    Write-Verbose "$UPN : Services after changes:"
                    ((Get-MsolUser -UserPrincipalName $UPN).licenses |? {$_.accountsku.skupartnumber -eq $AccountSkuID}).servicestatus |ft -AutoSize | Out-String -Stream | ? {-not [string]::IsNullOrEmpty($_)} |% {write-verbose "$(" "*4)$_"}

                    Write-Verbose "$UPN : RevertScript : `$LicenseOptions = New-MsolLicenseOptions -AccountSkuId $($SKU.AccountSkuId) -DisabledPlans $($RevertServices.ToArray() -join ',')"
                    Write-Verbose "$UPN : RevertScript : Set-MsolUserLicense -User $UPN -LicenseOptions `$LicenseOptions"
                    if ($CreateRevertScript)
                    {
                        "<# $upn #> `$LicenseOptions = New-MsolLicenseOptions -AccountSkuId $($SKU.AccountSkuId) -DisabledPlans $($RevertServices.ToArray() -join ',')" | Out-File $RevertScript -Encoding ascii -Append -Force -NoClobber
                        "<# $upn #> Set-MsolUserLicense -User $UPN -LicenseOptions `$LicenseOptions" | Out-File $RevertScript -Encoding ascii -Append -Force -NoClobber
                    }
                }
                else  # User does not have this license
                {
                    Write-Verbose "$UPN : User does not have this license."
                    # Add License

                    $DisabledServices = new-object System.Collections.ArrayList
                    foreach ($MSOLServiceName in $SKu.servicestatus.ServicePlan.ServiceName)
                    {
                        if ($ServiceName -notcontains $MSOLServiceName)
                        {
                            Write-Verbose "$UPN : Disabling this service : $MSOLServiceName"
                            $DisabledServices.Add($MSOLServiceName) | Out-Null
                        }
                    }

                    # Check to see if we would just be disabling all the services
                    If ($DisabledServices.Count -eq $SKu.servicestatus.ServicePlan.ServiceName.count)
                    {
                        Write-Warning "Could not find service in Licnese $AccountSkuID. No Changes made."
                        Continue
                    }

                    Write-Verbose "$UPN : Configuring License Options."
                    try
                    {
                        $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $SKU.AccountSkuId -DisabledPlans $DisabledServices.ToArray() -ErrorAction stop
                    }
                    catch
                    {
                        throw $_
                    }

                    Write-Verbose "$UPN : Setting user licenses."
                    try
                    {
                        Set-MsolUserLicense -User $UPN -AddLicenses $SKU.AccountSkuId -LicenseOptions $LicenseOptions -ErrorAction stop
                    }
                    catch
                    {
                        throw $_
                    }

                    ((Get-MsolUser -UserPrincipalName $UPN).licenses |? {$_.accountsku.skupartnumber -eq $AccountSkuID}).servicestatus |ft -AutoSize | Out-String -Stream | ? {-not [string]::IsNullOrEmpty($_)} |% {write-verbose "$(" "*4)$_"}
            
                    write-verbose "$UPN : RevertScript : Set-MsolUserLicense -User $UPN -RemoveLicenses $($SKU.AccountSkuId)"
                    if ($CreateRevertScript)
                    {
                        "<# $upn #> Set-MsolUserLicense -User $UPN -RemoveLicenses $($SKU.AccountSkuId)" | Out-File $RevertScript -Encoding ascii -Append -Force -NoClobber
                    }
                }
            }
        }
    }

    End
    {
    }
}