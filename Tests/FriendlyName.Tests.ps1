#$here = Split-Path -Parent $MyInvocation.MyCommand.Path
#$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
#. "$here\$sut"


Describe “Friendly Name Tests" {
    Context "Licenses" {
        It "'VISIOCLIENT'                    = 'Visio Pro for Office 365'" {
            Get-o365LicenseFriendlyName -AccountSkuId 'VISIOCLIENT' | Should be 'Visio Pro for Office 365'
        }

        It "'DYN365_ENTERPRISE_PLAN1'        = 'Dynamics 365 Plan 1 Enterprise Edition'" {
            Get-o365LicenseFriendlyName -AccountSkuId 'DYN365_ENTERPRISE_PLAN1' | Should be 'Dynamics 365 Plan 1 Enterprise Edition'
        }
    }
    Context "Licenses via Alias" {
        It "'VISIOCLIENT'                    = 'Visio Pro for Office 365'" {
            Get-AccountSkuIdFriendlyName -AccountSkuId 'VISIOCLIENT' | Should be 'Visio Pro for Office 365'
        }

        It "'DYN365_ENTERPRISE_PLAN1'        = 'Dynamics 365 Plan 1 Enterprise Edition'" {
            Get-AccountSkuIdFriendlyName -AccountSkuId 'DYN365_ENTERPRISE_PLAN1' | Should be 'Dynamics 365 Plan 1 Enterprise Edition'
        }
    }

    Context 'Services' {
        It '"POWERVIDEOSFREE"             = "Microsoft Power Videos Basic"' {
            Get-O365ServiceFriendlyName -ServiceID POWERVIDEOSFREE | Should be 'Microsoft Power Videos Basic'
        }

        It '"OFFICESUBSCRIPTION"          = "Office 365 ProPlus"' {
            Get-O365ServiceFriendlyName -ServiceID OFFICESUBSCRIPTION | Should be 'Office 365 ProPlus'
        }
    }
}