function Get-o365LicenseFriendlyName
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0)]
        [string[]] $AccountSkuId
    )

    Begin
    {}
    Process
    {
        foreach ($ASI in $AccountSkuId)
        {
            if ($MODULELicenseFriendlyName.containskey($ASI))
            {
                $MODULELicenseFriendlyName[$ASI]
            }
            elseif ($MODULELicenseFriendlyName.containskey($asi.substring($ASI.indexof(':') + 1)))
            {
                $MODULELicenseFriendlyName[$($asi.substring($ASI.indexof(':') + 1))]
            }
            else
            {
                $ASI
            }
        }
    }
    End
    {}
}
