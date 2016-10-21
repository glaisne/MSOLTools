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
function Get-MSOLSubscriptionTimeline
{
    [CmdletBinding()]
    $SubscriptionData = get-msolsubscription
    $Usage            = Get-LicenseUsage

    $SKUs  = $($SubscriptionData | select skupartnumber -Unique).SkuPartNumber
    $Dates = $($SubscriptionData | select NextLifecycleDate -Unique).NextLifecycleDate |? {-not [string]::IsNullOrEmpty($_ )}

    $Timeline = new-object System.Collections.ArrayList

    foreach ($Entry in $SKUs)
    {
        $Product = New-Object PSObject -Property @{
            SkuPartNumber = $Entry
            DisplayName   = Get-AccountSkuIdFriendlyName $Entry
            Owned         = 0
            Consumed      = $(($usage |? {$_.AccountSkuId -match ":$Entry$"}).ConsumedUnits)
        }

        foreach ($Date in $Dates | sort)
        {
            $Product | Add-Member -MemberType NoteProperty -Name $Date.ToShortDateString() -Value ([string]::Empty) -Force
        }

        $Product | Add-Member -MemberType NoteProperty -Name 'Never' -Value ([string]::Empty) -Force

        $Timeline.Add($Product) | Out-Null
    }

    foreach ($Entry in $Timeline)
    {
        foreach ($LineItem in $SubscriptionData)
        {
            if ($Entry.SkuPartNumber -eq $LineItem.SkuPartNumber)
            {
                $Entry.Owned = $Entry.Owned + $LineItem.TotalLicenses
                if ([string]::IsNullOrEmpty($LineItem.NextLifecycleDate))
                {
                    $Entry.Never = -1 * $LineItem.TotalLicenses
                }
                else
                {
                    $Entry.$($LineItem.NextLifecycleDate.ToShortDateString()) = -1 * $LineItem.TotalLicenses
                }
            }
        }
    }
    $Timeline | select *
}


