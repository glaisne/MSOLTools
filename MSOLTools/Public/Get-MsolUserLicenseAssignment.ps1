function Get-MsolUserLicenseAssignment
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,
                    ValueFromPipeline=$True,
                    Position=0,
                    ParameterSetName="List")]
        [String[]] $UserPrincipalName,
        
        [Parameter(ParameterSetName="All")]
        [Switch] $All
    )

    #
    #    Ensure the needed modules and connections are set.
    #

    try
    {
        get-msoldomain -ErrorAction stop | Out-Null
    }
    catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException]
    {
        try
        {
            Connect-MsolService -ErrorAction Stop
        }
        catch
        {
            $Err = $_
            throw "Error connecting to MSOnLine : $($err.exception.message)"
        }
    }
    catch
    {
        $Err = $_
        throw $Err.exception.message
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
            $UserIndex = 0
            $UserPrincipalNameCount = ($UserPrincipalName | measure).count
            foreach ($Entry in $UserPrincipalName)
            {
                Write-Progress -Activity "Gathering Users (step 1 of 2)" -Status "Progress: (working on $Entry)" -PercentComplete $($UserIndex/$($UserPrincipalNameCount)*100)
                $UserIndex++
                $User = $Null
                Try
                {
                    $User = get-msoluser -UserPrincipalName $Entry -ErrorAction Stop
                }
                Catch
                {
                    $Err = $_
                    write-Warning "Error getting user ($Entry) : $($Err.Exception.Message)"
                    continue
                }
                
                if ($User -eq $Null)
                {
                	Write-Warning "User not found ($Entry)."
                    continue
                }
                $Allusers.Add($User) | Out-Null
            }
        }
    }

    Write-Progress -Activity "Processing Users (step 2 of 2)" -Status "Progress:" -PercentComplete 0
    Write-Verbose "Gathering License and Services 'Friendly Names.'"
    $UserIndex = 0

    $msolAccountSkus = get-msolAccountSku

    $LicenseUsage = Get-LicenseUsage
    #$LicenseMap = @{}
    #foreach ($License in $LicenseUsage)
    #{
    #    $LicenseMap.Add($($License.AccountSkuID),"$($License.DisplayName)")
    #}

    $ServiceFriendlyNames = new-object System.Collections.ArrayList
    $ServiceFriendlyNameMap = @{}
    foreach ($AccountSkuId in $msolAccountSku)
    {
        foreach ($Service in $AccountSkuId.ServiceStatus)
        {
            $ServiceFriendlyName = Get-O365ServiceFriendlyName -ServiceID $Service.ServicePlan.ServiceName
            $ServiceFriendlyNames.Add($ServiceFriendlyName) | Out-Null
            $ServiceFriendlyNameMap.Add($("{0}:{1}" -f $(Get-o365LicenseFriendlyName $AccountSkuId.AccountSkuId.split(':')[1]), $Service.ServicePlan.ServiceName), $ServiceFriendlyName)
        }
    }


    Write-verbose "Processing users..."
    foreach ($MsolUser in $AllUsers)
    {
        $UserIndex++
        Write-Progress -Activity "Processing Users (step 2 of 2)" -Status "Progress: ($($MsolUser.userprincipalname))" -PercentComplete $($UserIndex/$($AllUsers.count)*100)

        $Object = New-Object PSObject -Property @{
            userprincipalname = $MsolUser.userprincipalname
            IsLicensed        = $MsolUser.IsLicensed
            UsageLocation     = $MsolUser.UsageLocation
            Region            = [string]::Empty
            #Licenses          = New-Object System.Collections.ArrayList
        }

        #foreach ($License in $LicenseUsage)
        #{
        #    $Object | Add-Member -MemberType NoteProperty -Name "Has $($License.DisplayName)" -Value ([string]::Empty) -Force
        #}

        #foreach ($ServiceFriendlyName in $ServiceFriendlyNameMap.GetEnumerator())
        #foreach ($Service in $AccountSkuId.ServiceStatus)
        #{
        #    $Object | Add-Member -MemberType NoteProperty -Name $ServiceFriendlyName.Value -Value ([string]::Empty) -Force
        #}

        foreach ($msolAccountSku in $msolAccountSkus)
        {
            $Object | Add-Member -MemberType NoteProperty -Name "Has $(Get-o365LicenseFriendlyName -AccountSkuId $($msolAccountSku.AccountSkuId.split(':')[1]))" -Value ([string]::Empty) -Force
        }

        foreach ($msolAccountSku in $msolAccountSkus)
        {
            $License = $(Get-o365LicenseFriendlyName -AccountSkuId $($msolAccountSku.AccountSkuId.split(':')[1]))
            foreach ($ServiceStatus in $msolAccountSku.ServiceStatus)
            {
                $Object | Add-Member -MemberType NoteProperty -Name "$License`n$(Get-O365ServiceFriendlyName $ServiceStatus.ServicePlan.ServiceName)" -Value ([string]::Empty) -Force
            }
        }




        if ($MsolUser.IsLicensed)
        {
            foreach ($License in $MsolUser.Licenses)
            {
                $AccountSkuId = $License.AccountSkuId

                #$LicenseFriendlyName = $LicenseMap.Get_Item($AccountSkuId)
                $LicenseFriendlyName = Get-o365LicenseFriendlyName -AccountSkuId $AccountSkuId.split(':')[1]

                $Object."Has $LicenseFriendlyName" = $True
                #$Object.Licenses.Add($LicenseFriendlyName) | Out-Null

                foreach ($ServiceStatus in $License.ServiceStatus)
                {
                    #$ServiceID = $ServiceFriendlyNameMap.Get_Item($("{0}:{1}" -f $AccountSkuId, $Service.ServicePlan.ServiceName))
                    #$ServiceID = $ServiceStatus.ServicePlan.ServiceName
                    $Status    = $ServiceStatus.ProvisioningStatus

                    $Object."$LicenseFriendlyName`n$(Get-O365ServiceFriendlyName $ServiceStatus.ServicePlan.ServiceName)" = $Status 
                }
            }
        }
        Write-output $Object
    }
}