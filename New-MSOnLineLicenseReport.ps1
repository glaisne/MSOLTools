. .\Get-MsolUserLicenseAssignment.ps1
. .\Get-LicenseUsage.ps1

$DateTimeStamp = get-date -f 'MMddyyyyHHmmssffff'

Get-MsolUserLicenseAssignment |select userprincipalname,islicensed,usagelocation, Region, * -ea 0 | Export-Excel "c:\temp\userlicenses_$DateTimeStamp`.xlsx" -WorkSheetname "Individuals" -AutoFilter -FreezeTopRow -ConditionalText $(
    New-ConditionalText -Text 'Enterprise Mobility Suite' -ConditionalTextColor White -BackgroundColor MediumBlue
    New-ConditionalText -Text 'Office 365 Enterprise E5 without PSTN Conferencing' -ConditionalTextColor White -BackgroundColor Firebrick
    New-ConditionalText -Text 'Office 365 Enterprise E3' -ConditionalTextColor black -BackgroundColor tan
    New-ConditionalText 'Disabled' -ConditionalTextColor Red -BackgroundColor White
    New-ConditionalText 'FALSE' -Range B:B -ConditionalTextColor Red

)


$LicenseUsage = Get-LicenseUsage
$LicenseUsage | select AccountSkuId, DisplayName, ActiveUnits, ConsumedUnits, AvailableUnits | export-excel "c:\temp\userlicenses_$DateTimeStamp`.xlsx" -WorkSheetname "Licenses" -Show -Numberformat '[black]#,###;[Red]-#,###' -AutoSize
# -ConditionalText $(
#    New-ConditionalText '-' -Range D:D
#)
