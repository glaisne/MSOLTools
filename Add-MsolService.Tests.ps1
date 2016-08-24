$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

function CreateTestUser ()
{
    $test = new-object Microsoft.Online.Administration.User
    $test.usageLocation = 'US'
    $test.WhenCreated = [datetime]::now.adddays(-30)
    $Test.BlockCredential = $False
    $test.City = 'Boston'
    $test.CloudExchangeRecipientDisplayType = 1073741824
    $Test.Country = 'United States'
    $Test.Department = 'Information Technology'
    $Test.DisplayName = 'Bob Smith'
    $Test.Fax = '+1-555-555-1212'
    $test.FirstName = 'Bob'
    $Test.ImmutableId = 'qvjnw23480-5S=='
    $Test.IsBlackberryUser = $false
    $test.IsLicensed = $False
    $test.LastDirSyncTime = [datetime]::now.addminutes(-30)
    $test.LastName = 'Smith'
    $test.LastPasswordChangeTimestamp = [datetime]::now.AddDays(-345)
    $test.LicenseReconciliationNeeded = $False
    $test.LiveId = 'MADEUPID1001'
    $test.MobilePhone = 'UNKNOWN'
    $test.ObjectID = $(New-Guid)
    $Test.Office = 'Beacon Hill'
    $Test.PasswordNeverExpires = $true
    $test.PasswordResetNotRequiredDuringActivate = $true
    $test.PasswordResetNotRequiredDuringActivate = $true
    $test.PhoneNumber = 'UNKNOWN'
    $test.PostalCode = 'MA 02000'
    $test.SignInName = 'Bob.Smith@Contoso.com'
    $test.State = 'MA'
    $test.StreetAddress = '1 Boston Pl'
    $test.PostalCode = 'MA 02108'
    $test.StrongPasswordRequired = $true
    $test.StsRefreshTokensValidFrom = [datetime]::now.AddDays(-347)
    $test.Title = 'CEO'
    $test.UsageLocation = 'US'
    $test.UserPrincipalName = 'bob.smith@contoso.com'
    $Test.ValidationStatus = [Microsoft.Online.Administration.ValidationStatus]::Healthy
    $Test.WhenCreated = [datetime]::now.adddays(-630)

    $Test
}

function AddLicense
{
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Microsoft.Online.Administration.User] $User,
        [string] $Tenant,
        [string] $SkuId,
        [string[]] $EnabledService,
        [string[]] $DisabledService
    )

    $License = new-object Microsoft.Online.Administration.UserLicense

    $AccountSku = new-object Microsoft.Online.Administration.AccountSkuIdentifier
    $AccountSku.AccountName   = $Tenant
    $AccountSku.SkuPartNumber = $SkuId

    $License.AccountSku = $AccountSku

    $License.AccountSkuId = "{0}:{1}" -f $Tenant, $SkuId


    $ServiceStatuses = new-object System.Collections.ArrayList
    Foreach ($Service in $EnabledService)
    {
        $ServiceStatus = new-object Microsoft.Online.Administration.ServiceStatus
        $ServicePlan   = new-object Microsoft.Online.Administration.ServicePlan
        $ServicePlan.ServiceName = $Service
        $ServiceStatus.ServicePlan = $ServicePlan
        $ServiceStatus.ProvisioningStatus = [Microsoft.Online.Administration.ProvisioningStatus]::Success
        $ServiceStatuses.Add($ServiceStatus) | Out-Null
    }
    Foreach ($Service in $DisabledService)
    {
        $ServiceStatus = new-object Microsoft.Online.Administration.ServiceStatus
        $ServicePlan   = new-object Microsoft.Online.Administration.ServicePlan
        $ServicePlan.ServiceName = $Service
        $ServiceStatus.ServicePlan = $ServicePlan
        $ServiceStatus.ProvisioningStatus = [Microsoft.Online.Administration.ProvisioningStatus]::Disabled
        $ServiceStatuses.Add($ServiceStatus) | Out-Null
    }
    $License.ServiceStatus = $ServiceStatuses.ToArray()

    if ($user.Licenses -eq $null)
    {
        $User.Licenses = $License
    }
    else
    {
        $User.Licenses.Add($License) | Out-Null
    }

}

 
Describe “Add-MsolService" {
    Context "Should not find user" {
        mock Get-msoluser { $null }
        It "Can not find user" {
            { Add-MsolService -UserPrincipalName 'Test@contoso.com' -AccountskuId 'VISIOCLIENT' -ServiceName 'VISIOCLIENT' } | Should Throw
        }
    }

    Context "User not licensed and no UsageLocation" {
        Mock Get-MsolUser { $t = CreateTestUser; $t.UsageLocation = $null; $t }
        It "User not licensed and no UsageLocation" {
            { Add-MsolService -UserPrincipalName 'Test@contoso.com' -AccountskuId 'VISIOCLIENT' -ServiceName 'VISIOCLIENT' } | Should Throw
        }
        
        It "User not licensed and invalid UsageLocation" {
            { Add-MsolService -UserPrincipalName 'test.laisne@cwservices.com' -AccountskuId 'VISIOCLIENT' -ServiceName 'VISIOCLIENT' -UsageLocation 'asdfasdf'} | Should Throw
        }
    }

    Context "Bad parameters" {
        
        It "Invalid ServiceName" {
            { Add-MsolService -UserPrincipalName 'test.laisne@cwservices.com' -AccountskuId 'ENTERPRISEPREMIUM_NOPSTNCONF' -ServiceName 'ThisIsNotARealServiceName' -UsageLocation 'AU'} | Should Throw
        }
        
        It "Invalid License options" {
            { Add-MsolService -UserPrincipalName 'test.laisne@cwservices.com' -AccountskuId 'ENTERPRISEPREMIUM_NOPSTNCONF' -ServiceName 'MCOEV' -UsageLocation 'AU'} | Should Throw
        }
    
        It "Unable to asign this license" {
            # This license alone is not sufficiant, it has additional requirements.
            { Add-MsolService -UserPrincipalName 'test.laisne@cwservices.com' -AccountskuId 'EMS' -ServiceName 'RMS_S_PREMIUM' -UsageLocation 'AU'} | Should Throw
        }

    }

    Context "Valid parameters for users with no licenses assigned" {
    
        It "Successful license assignment" {
            { Add-MsolService -UserPrincipalName 'test.laisne@cwservices.com' -AccountskuId 'ENTERPRISEPACK' -ServiceName 'SWAY' -UsageLocation 'AU'} | Should Not Throw
        }

    }

    Context "Valid parameters for users with some other license assigned" {
    
        It "Valid parameters" {
            { Add-MsolService -UserPrincipalName 'test.laisne@cwservices.com' -AccountskuId 'EMS' -ServiceName 'INTUNE_A' -UsageLocation 'AU'} | Should Not Throw
        }
    
        It "Valid parameters" {
            { Add-MsolService -UserPrincipalName 'test.laisne@cwservices.com' -AccountskuId 'ENTERPRISEPACKWITHOUTPROPLUS' -ServiceName 'YAMMER_ENTERPRISE' -UsageLocation 'AU'} | Should Not Throw
        }
    }
}
