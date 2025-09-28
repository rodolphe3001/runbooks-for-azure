
##### FUNCTIONS #####
function Init {

    Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
    
    Connect-AzAccount -Identity
    
    <# these variables should be changed if reuse of this script in another context. #>
    $SubscriptionId     = ""
    $Location           = "eastus"
    $ResourceGroupName  = ""
    $StorageAccountName = ""
    $StorageContainer   = "images"
    $FileName           = $Location + "-microsoftwindowsserver-offers.txt"
    $Publisher          = "MicrosoftWindowsServer"

    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    Write-Output "[info] Azure Context has been set. "
    
    GetStorageContext

}

function GetStorageContext {

    $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

    if ($StorageAccount) {

        Write-Output "[info] Storage Account $StorageAccountName has been found. "

        $StorageAccountKey1 = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]

        if ($StorageAccountKey1) {       

            Write-Output "[info] Storage Account Key for $StorageAccountName has been found. "

            $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey1

            if ($StorageContext) {

                Write-Output "[info] Storage Context has been set. "

                GetOffers
                
            }
            else {

                Write-Output "[error] Storage Context has not been set. "

            }

        }
        else {

            Write-Output "[error] Storage Account Key for $StorageAccountName has not been found. "

        }

    }
    else {

        Write-Output "[error] Storage Account $StorageAccountName has not been found. "

    }

}


function GetOffers {

    $AllOffers = Get-AzVMImageOffer -Location $Location -PublisherName $Publisher | Select-Object -Property Offer | Sort-Object -Property Offer

    if ($AllOffers) {

        Write-Host "[info] Offers have been found for $Publisher "

        $AllOffers | Out-file $FileName -Append

        Set-AzStorageBlobContent -File $FileName -Container $StorageContainer -BlobType "Block" -Context $StorageContext -Verbose -Force | Out-Null

    }
    else {

        Write-Host "[error] Offers have not been found. "

        Return

    }

}


##### INIT #####
Init
