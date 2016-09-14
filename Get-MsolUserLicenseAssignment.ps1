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
	    IF (-not (Get-Module -Name MSOnline -ListAvailable))
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

    $UserIndex = 0

    $msolAccountSku = get-msolAccountSku

    foreach ($msoluser in $AllUsers)
    {
        $UserIndex++
        Write-Progress -Activity "Processing Users (step 2 of 2)" -status "Progress:" -PercentComplete $($UserIndex/$($AllUsers.count)*100)

        $Object = New-Object PSObject -Property @{
            userprincipalname = $msoluser.userprincipalname
            IsLicensed        = $msoluser.IsLicensed
            UsageLocation     = $msoluser.UsageLocation
            Region            = [string]::Empty
            Licenses          = New-Object System.Collections.ArrayList
        }

        foreach ($License in Get-LicenseUsage)
        {
            $Object | Add-Member -MemberType NoteProperty -Name "Has $($License.DisplayName)" -Value ([string]::Empty) -Force
        }

        foreach ($AccountSkuId in $msolAccountSku)
        {
            foreach ($Service in $AccountSkuId.ServiceStatus)
            {
                $Object | Add-Member -MemberType NoteProperty -Name $(Get-O365ServiceFriendlyName -ServiceID $("{0}:{1}" -f $AccountSkuId.AccountSkuId, $service.ServicePlan.ServiceName)) -Value ([string]::Empty) -Force
            }
        }


        if ($msoluser.IsLicensed)
        {
            foreach ($License in $msoluser.Licenses)
            {
                $AccountSkuId = $License.AccountSkuId

                $LicenseFriendlyName = Get-O365LicenseFriendlyName $AccountSkuId.split(':')[1]

                $Object."Has $LicenseFriendlyName" = $True
                $Object.Licenses.Add($LicenseFriendlyName) | Out-Null

                foreach ($Service in $License.ServiceStatus)
                {
                    $ServiceID = $(Get-O365ServiceFriendlyName -ServiceID $("{0}:{1}" -f $AccountSkuId, $service.ServicePlan.ServiceName))
                    $Status    = $Service.ProvisioningStatus

                    $Object."$ServiceID" = $Status # | Add-Member -MemberType NoteProperty -Name $ServiceID -Value $Status -Force
                }
            }
        }
        Write-output $Object
    }
}