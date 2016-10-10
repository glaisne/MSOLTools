﻿$ModuleName   = "MSOLTools"
$ModulePath   = "C:\Program Files\WindowsPowerShell\Modules"
$TargetPath = "$($ModulePath)\$($ModuleName)"

if(-Not(Test-Path $TargetPath))
{
    mkdir $TargetPath | out-null
}

$filelist = @"
MSOLTools.psd1
MSOLTools.psm1
Get-LicenseUsage.ps1
Get-MsolUserLicenseAssignment.ps1
Get-o365LicenseFriendlyName.ps1
Add-MsolService.ps1
Get-AccountSkuIdFriendlyName.ps1
Get-O365ServiceFriendlyName.ps1
Get-MSOLUserserviceStatus.ps1
"@

$filelist -split "`n" | % { Copy-Item -Verbose -Path "$pwd\$($_.trim())" -Destination "$($TargetPath)\$($_.trim())" }