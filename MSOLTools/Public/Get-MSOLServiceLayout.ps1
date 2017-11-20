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
function Get-MSOLServiceLayout
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([PSObject])]
    Param
    (
        # # Param1 help description
        # [Parameter(Mandatory=$true,
        #         ValueFromPipelineByPropertyName=$true,
        #         Position=0)]
        # [Param1Type]
        # $Param1,

        # # Param2 help description
        # [Param2Type]
        # $Param2
    )

    Foreach ($Sku in Get-MSOLAccountSku)
    {
        $SkuFriendlyName = Get-o365LicenseFriendlyName $Sku.SkuPartNumber
        foreach ($Service in $Sku.ServiceStatus)
        {
            [pscustomobject]@{
                AccountSku          = $Sku.SkuPartNumber
                SkuFriendlyName     = $SkuFriendlyName
                ServiceName         = $Service.serviceplan.servicename
                ServiceFriendlyName = Get-O365ServiceFriendlyName -ServiceID $Service.serviceplan.servicename
            }
        }
    }
}