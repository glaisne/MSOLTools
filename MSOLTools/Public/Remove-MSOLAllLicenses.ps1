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
function Remove-MSOLAllLicenses
{
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $userPrincipalName,

        [switch]
        $Block
    )

    $YesToAll = $False
    $NoToAll  = $false

    if ($ConfirmPreference -eq 'None')
    {
        $YesToAll = $True
    }

    Foreach ($upn in $userPrincipalName)
    {
        

        $UserAccountSkuIds = (Get-MsolUser -UserPrincipalName $upn).licenses.AccountSkuId

        if ($UserAccountSkuIds -ne $null)
        {
             #                           Target   Aciotn
            if ( $PSCmdlet.ShouldProcess($upn,   "Set-MsolUserLicense -RemoveLicense $($userAccountSkuIds -join ',')") )
            {
                #                             Query            Caption (Action)                                 YesToAll        NoToAll
                if ( $PSCmdlet.ShouldContinue("Are you sure?", "Remove all Office 365 licenses from user $upn", [ref]$YesToAll, [ref]$NoToAll ) )
                {
                    Try
                    {
                        Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $userAccountSkuIds -ErrorAction Stop
                    }
                    catch
                    {
                        $err = $_
                        Write-Warning "Error removing licenses ($($userAccountSkuIds -join ',')) from $upn : $($err.Exception.Message)"
                    }
                }
            }
        }
        else
        {
            Write-Verbose "User $upn currently has no licenses."
        }


        if ($Block)
        {
            #                           Target   Aciotn
            if ( $PSCmdlet.ShouldProcess($upn,   "Blocking O365 credentail from logging on.") )
            {
                #                             Query            Caption (Action)                                 YesToAll        NoToAll
                if ( $PSCmdlet.ShouldContinue("Are you sure?", "Remove all Office 365 licenses from user $upn", [ref]$YesToAll, [ref]$NoToAll ) )
                {
                    Try
                    {
                        Set-MsolUser -UserPrincipalName $upn -BlockCredential $true
                    }
                    catch
                    {
                        $err = $_
                        Write-Warning "Error Blocking account $upn : $($err.Exception.Message)"
                    }
                }
            }
        }
    }
}