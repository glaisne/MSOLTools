$ModuleName   = "MSOLTools"
$ModulePath   = "C:\Program Files\WindowsPowerShell\Modules"
$TargetPath = "$($ModulePath)\$($ModuleName)"

if(-Not(Test-Path $TargetPath))
{
    mkdir $TargetPath | out-null
}

Copy-Item -Verbose -Path "$PSScriptRoot\$ModuleName" -Destination $ModulePath -Container -Recurse -Force