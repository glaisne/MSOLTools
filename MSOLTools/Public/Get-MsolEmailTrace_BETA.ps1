$StartDate     = "11/01/2016 1:00 am"
$EndDate       = "11/08/2016 5:00 pm"
$SenderAddress = 'Gene@Contoso.com'
$subject       = 'Subject'



$msgCount = -1

$Results = new-object System.Collections.ArrayList

$Page = 1
while ($msgCount -ne 0 -and $page -le 1000)
{
    $Msgs = get-messagetrace -StartDate $StartDate -EndDate $EndDate -pagesize 1000 -SenderAddress $SenderAddress  -Page $Page |?{$_.subject -eq $subject  -and $_.Status -ne 'Resolved'}

    if ($Msgs -ne $null)
    {
        $msgCount = ($Msgs | measure).count
    }
    else
    {
        $msgCount = 0
    }

    $Results.AddRange($Msgs)

    $Page++
}

$Results | sort RecipientAddress | select Received,SenderAddress,RecipientAddress,Subject,Status | Export-Excel c:\temp\ActiveShooterTrainingEmail_11072016b.xlsx -AutoSize -FreezeTopRow -Show
$Results | sort RecipientAddress | select Received,SenderAddress,RecipientAddress,Subject,Status | Ft -AutoSize

