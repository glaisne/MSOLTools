$ModuleName   = "MSOLTools"
$ModulePath   = "C:\Program Files\WindowsPowerShell\Modules"
$TargetPath = "$($ModulePath)\$($ModuleName)"

if(-Not(Test-Path $TargetPath))
{
    mkdir $TargetPath | out-null
}

$filelist = @"
MSOLTools.psd1
MSOLTools.psm1
Get-LicenseAssignmentReport.ps1
Get-LicenseUsage.ps1
Get-MsolUserLicenseAssignment.ps1
New-MSOnLineLicenseReport.ps1
"@

$filelist -split "`n" | % { Copy-Item -Verbose -Path "$pwd\$($_.trim())" -Destination "$($TargetPath)\$($_.trim())" }