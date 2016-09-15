function Get-MsolUserLicenseAssignment
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true,
                    Position=0,
                    ParameterSetName="List")]
        [String[]] $UserPrincipalName,
        
        [Parameter(ParameterSetName="All")]
        [Switch] $All
    )

    #
    #    Ensure the needed modules and connections are set.
    #

    TRY
    {
	    IF (-not (Get-Module -Name MSOnline))
	    {
		    Write-Verbose -Message "Import module MSOL"
		    Import-Module -Name MSOnline -ErrorAction Stop
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

    
    write-verbose "Getting users..."
    switch($PsCmdlet.ParameterSetName)
    {
        "All" 
        {
            Write-Progress -Activity 'Gathering all users' 
            $AllUsers = get-msoluser -All
        }
        "List" 
        {
            $Allusers = new-object System.Collections.ArrayList
            $userIndex = 0
            $UserPrincipalNameCount = ($UserPrincipalName | measure).count
            foreach ($entry in $UserPrincipalName)
            {
                Write-Progress -Activity "Gathering Users (step 1 of 2)" -status "Progress: (working on $Entry)" -PercentComplete $($UserIndex/$($UserPrincipalNameCount)*100)
                $UserIndex++
                $user = $null
                Try
                {
                    $user = get-msoluser -userprincipalname $Entry
                }
                Catch
                {
                    $Err = $_
                    write-Warning "Error getting user ($Entry) : $($Err.Exception.Message)"
                    continue
                }
                
                if ($user -eq $null)
                {
                	Write-Warning "User not found ($Entry)."
                    continue
                }
                $Allusers.Add($User) | Out-Null
            }
        }
    }

    Write-Progress -Activity "Processing Users (step 2 of 2)" -status "Progress:" -PercentComplete 0
    Write-Verbose "Gathering License and Services 'Friendly Names.'"
    $UserIndex = 0

    $msolAccountSku = get-msolAccountSku

    $LicenseUsage = Get-LicenseUsage
    $LicenseMap = @{}
    foreach ($license in $LicenseUsage)
    {
        $LicenseMap.Add($($license.AccountSkuID),"$($license.DisplayName)")
    }

    $ServiceFriendlyNames = new-object System.Collections.ArrayList
    $ServiceFriendlyNameMap = @{}
    foreach ($AccountSkuId in $msolAccountSku)
    {
        foreach ($Service in $AccountSkuId.ServiceStatus)
        {
            $ServiceFriendlyName = Get-O365ServiceFriendlyName -ServiceID $("{0}:{1}" -f $AccountSkuId.AccountSkuId, $service.ServicePlan.ServiceName)
            $ServiceFriendlyNames.Add($ServiceFriendlyName) | Out-Null
            $ServiceFriendlyNameMap.Add($("{0}:{1}" -f $AccountSkuId.AccountSkuId, $service.ServicePlan.ServiceName), $ServiceFriendlyName)
        }
    }


    Write-verbose "Processing users..."
    foreach ($msoluser in $AllUsers)
    {
        $UserIndex++
        Write-Progress -Activity "Processing Users (step 2 of 2)" -status "Progress: ($($msoluser.userprincipalname))" -PercentComplete $($UserIndex/$($AllUsers.count)*100)

        $Object = New-Object PSObject -Property @{
            userprincipalname = $msoluser.userprincipalname
            IsLicensed        = $msoluser.IsLicensed
            UsageLocation     = $msoluser.UsageLocation
            Region            = [string]::Empty
            Licenses          = New-Object System.Collections.ArrayList
        }

        foreach ($License in $LicenseUsage)
        {
            $Object | Add-Member -MemberType NoteProperty -Name "Has $($License.DisplayName)" -Value ([string]::Empty) -Force
        }

        foreach ($ServiceFriendlyName in $ServiceFriendlyNameMap.GetEnumerator())
        {
            $Object | Add-Member -MemberType NoteProperty -Name $ServiceFriendlyName.Value -Value ([string]::Empty) -Force
        }


        if ($msoluser.IsLicensed)
        {
            foreach ($License in $msoluser.Licenses)
            {
                $AccountSkuId = $License.AccountSkuId

                #$LicenseFriendlyName = Get-O365LicenseFriendlyName $AccountSkuId.split(':')[1]
                $LicenseFriendlyName = $LicenseMap.Get_Item($AccountSkuId)

                $Object."Has $LicenseFriendlyName" = $True
                $Object.Licenses.Add($LicenseFriendlyName) | Out-Null

                foreach ($Service in $License.ServiceStatus)
                {
                    $ServiceID = $ServiceFriendlyNameMap.Get_Item($("{0}:{1}" -f $AccountSkuId, $service.ServicePlan.ServiceName))
                    $Status    = $Service.ProvisioningStatus

                    $Object."$ServiceID" = $Status # | Add-Member -MemberType NoteProperty -Name $ServiceID -Value $Status -Force
                }
            }
        }
        Write-output $Object
    }
}