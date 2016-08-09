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
		    #Import-Module -Name MSOnline -ErrorAction Stop
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



    function Get-O365ServiceFriendlyName
    {
            [CmdletBinding()]
            Param
            (
                # Param1 help description
                [Parameter(Mandatory=$true,
                           ValueFromPipeline=$true,
                           Position=0)]
                $ServiceID
            )

            foreach ($License in Get-LicenseUsage)
            {
                if ($License.AccountSkuID -match "[a-z0-9]+:$ServiceID$")
                {
                    $License.DisplayName
                }
            }
<#            switch ($ServiceID)
            {
		        {$_ -LIKE "*:VISIOCLIENT:VISIO_CLIENT_SUBSCRIPTION"}             { "Visio Pro for Office 365".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:PROJECTCLIENT:PROJECT_CLIENT_SUBSCRIPTION"}         { "Project Pro for Office 365".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:POWERAPPS_INDIVIDUAL_USER:POWERVIDEOSFREE"}         { "Microsoft PowerApps and Logic flows`n Microsoft Power Videos Basic".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:POWERAPPS_INDIVIDUAL_USER:POWERFLOWSFREE"}          { "Microsoft PowerApps and Logic flows`n Logic flows".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:POWERAPPS_INDIVIDUAL_USER:POWERAPPSFREE"}           { "Microsoft PowerApps and Logic flows`n Microsoft PowerApps".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:POWER_BI_INDIVIDUAL_USER:SQL_IS_SSIM"}              { "Microsoft Power BI for Office 365 Individual User Trial`n Microsoft Power BI Information Services Plan 1".replace("$([char]13)","$([char]10)$([char]13)"); break } 
		        {$_ -LIKE "*:POWER_BI_INDIVIDUAL_USER:BI_AZURE_P1"}              { "Microsoft Power BI for Office 365 Individual User Trial`n Microsoft Power BI Reporting and Analytics Plan 1".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACKWITHOUTPROPLUS:SWAY"}                 { "Office 365 Enterprise E3 without ProPlus`n Sway".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACKWITHOUTPROPLUS:INTUNE_O365"}          { "Office 365 Enterprise E3 without ProPlus`n Mobile Device Management for Office 365".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACKWITHOUTPROPLUS:YAMMER_ENTERPRISE"}    { "Office 365 Enterprise E3 without ProPlus`n Yammer Enterprise".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACKWITHOUTPROPLUS:SHAREPOINTWAC"}        { "Office 365 Enterprise E3 without ProPlus`n Office Online".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACKWITHOUTPROPLUS:SHAREPOINTENTERPRISE"} { "Office 365 Enterprise E3 without ProPlus`n SharePoint Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACKWITHOUTPROPLUS:RMS_S_ENTERPRISE"}     { "Office 365 Enterprise E3 without ProPlus`n Azure Rights Management".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACKWITHOUTPROPLUS:MCOSTANDARD"}          { "Office 365 Enterprise E3 without ProPlus`n Skype for Business Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACKWITHOUTPROPLUS:EXCHANGE_S_ENTERPRISE"}{ "Office 365 Enterprise E3 without ProPlus`n Exchange Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACK:PROJECTWORKMANAGEMENT"}              { "Office 365 Enterprise E3`n Microsoft Planner".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACK:SWAY"}                               { "Office 365 Enterprise E3`n Sway".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACK:INTUNE_O365"}                        { "Office 365 Enterprise E3`n Mobile Device Management for Office 365 ".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACK:YAMMER_ENTERPRISE"}                  { "Office 365 Enterprise E3`n Yammer Enterprise".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACK:RMS_S_ENTERPRISE"}                   { "Office 365 Enterprise E3`n Azure Rights Management".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACK:OFFICESUBSCRIPTION"}                 { "Office 365 Enterprise E3`n Office 365 ProPlus".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACK:MCOSTANDARD"}                        { "Office 365 Enterprise E3`n Skype for Business Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACK:SHAREPOINTWAC"}                      { "Office 365 Enterprise E3`n Office Online".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACK:SHAREPOINTENTERPRISE"}               { "Office 365 Enterprise E3`n SharePoint Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPACK:EXCHANGE_S_ENTERPRISE"}              { "Office 365 Enterprise E3`n Exchange Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EXCHANGEDESKLESS:INTUNE_O365"}                      { "Exchange Online Kiosk`n Mobile Device Management for Office 365 ".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EXCHANGEDESKLESS:EXCHANGE_S_DESKLESS"}              { "Exchange Online Kiosk`n Exchange Online Kiosk".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EXCHANGESTANDARD:INTUNE_O365"}                      { "Exchange Online Plan 1`n Mobile Device Management for Office 365 ".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EXCHANGESTANDARD:EXCHANGE_S_STANDARD"}              { "Exchange Online Plan 1`n Exchange Online (Plan 1)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:POWER_BI_STANDARD:BI_AZURE_P0"}                     { "Power BI (free)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:ADALLOM_S_O365"}       { "Office 365 Enterprise E5 without PSTN Conferencing`n Office 365 Advanced Security Management".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:EQUIVIO_ANALYTICS"}    { "Office 365 Enterprise E5 without PSTN Conferencing`n Office 365 Advanced eDiscovery".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:LOCKBOX_ENTERPRISE"}   { "Office 365 Enterprise E5 without PSTN Conferencing`n Customer Lockbox".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:EXCHANGE_ANALYTICS"}   { "Office 365 Enterprise E5 without PSTN Conferencing`n Delve Analytics".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:SWAY"}                 { "Office 365 Enterprise E5 without PSTN Conferencing`n Sway".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:ATP_ENTERPRISE"}       { "Office 365 Enterprise E5 without PSTN Conferencing`n Exchange Online Advanced Threat Protection ".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:MCOEV"}                { "Office 365 Enterprise E5 without PSTN Conferencing`n Skype for Business Cloud PBX".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:BI_AZURE_P2"}          { "Office 365 Enterprise E5 without PSTN Conferencing`n Power BI Pro".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:INTUNE_O365"}          { "Office 365 Enterprise E5 without PSTN Conferencing`n Mobile Device Management for Office 365 ".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:PROJECTWORKMANAGEMENT"}{ "Office 365 Enterprise E5 without PSTN Conferencing`n Microsoft Planner".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:RMS_S_ENTERPRISE"}     { "Office 365 Enterprise E5 without PSTN Conferencing`n Azure Rights Management".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:YAMMER_ENTERPRISE"}    { "Office 365 Enterprise E5 without PSTN Conferencing`n Yammer Enterprise".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:OFFICESUBSCRIPTION"}   { "Office 365 Enterprise E5 without PSTN Conferencing`n Office 365 ProPlus".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:MCOSTANDARD"}          { "Office 365 Enterprise E5 without PSTN Conferencing`n Skype for Business Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:EXCHANGE_S_ENTERPRISE"}{ "Office 365 Enterprise E5 without PSTN Conferencing`n Exchange Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:SHAREPOINTENTERPRISE"} { "Office 365 Enterprise E5 without PSTN Conferencing`n SharePoint Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:ENTERPRISEPREMIUM_NOPSTNCONF:SHAREPOINTWAC"}        { "Office 365 Enterprise E5 without PSTN Conferencing`n Office Online".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EMS:RMS_S_PREMIUM"}                                 { "Enterprise Mobility Suite`n Azure Rights Management Premium".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EMS:INTUNE_A"}                                      { "Enterprise Mobility Suite`n Intune A Direct".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EMS:RMS_S_ENTERPRISE"}                              { "Enterprise Mobility Suite`n Azure Rights Management".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EMS:AAD_PREMIUM"}                                   { "Enterprise Mobility Suite`n Azure Active Directory Premium".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EMS:MFA_PREMIUM"}                                   { "Enterprise Mobility Suite`n Azure Multi-Factor Authentication".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:MCOMEETADV:MCOMEETADV"}                             { "Skype for Business PSTN Conferencing".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:PROJECTONLINE_PLAN_1:SWAY"}                         { "Project Online`n Sway".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:PROJECTONLINE_PLAN_1:SHAREPOINT_PROJECT"}           { "Project Online`n Project Online".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:PROJECTONLINE_PLAN_1:SHAREPOINTWAC"}                { "Project Online`n Office Online".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:PROJECTONLINE_PLAN_1:SHAREPOINTENTERPRISE"}         { "Project Online`n SharePoint Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EXCHANGEARCHIVE_ADDON:EXCHANGE_S_ARCHIVE_ADDON"}    { "Exchange Online Archiving for Exchange Online".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:MCOPSTN2:MCOPSTN2"}                                 { "Skype for Business PSTN Domestic and International Calling".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EXCHANGEENTERPRISE:INTUNE_O365"}                    { "Exchange Online (Plan 2)`n Mobile Device Management for Office 365 ".replace("$([char]13)","$([char]10)$([char]13)"); break }
		        {$_ -LIKE "*:EXCHANGEENTERPRISE:EXCHANGE_S_ENTERPRISE"}          { "Exchange Online (Plan 2)`n Exchange Online (Plan 2)".replace("$([char]13)","$([char]10)$([char]13)"); break }
                Default {$ServiceID}
            }
            #>
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

                $Object."Has $(Get-O365ServiceFriendlyName $AccountSkuId)" = $True

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