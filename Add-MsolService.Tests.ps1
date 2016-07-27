$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"
 
Describe “Add-MsolService" {
    Context "Bad parameters" {
        It "Can not find user" {
            { Add-MsolService -UserPrincipalName 'gene.asdf@cushwake.com' -AccountskuId 'VISIOCLIENT' -ServiceName 'VISIOCLIENT' } | Should Throw
        }
        
        It "User not licensed and no UsageLocation" {
            { Add-MsolService -UserPrincipalName 'test.laisne@cwservices.com' -AccountskuId 'VISIOCLIENT' -ServiceName 'VISIOCLIENT' } | Should Throw
        }
        
        It "User not licensed and invalid UsageLocation" {
            { Add-MsolService -UserPrincipalName 'test.laisne@cwservices.com' -AccountskuId 'VISIOCLIENT' -ServiceName 'VISIOCLIENT' -UsageLocation 'asdfasdf'} | Should Throw
        }
        
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
