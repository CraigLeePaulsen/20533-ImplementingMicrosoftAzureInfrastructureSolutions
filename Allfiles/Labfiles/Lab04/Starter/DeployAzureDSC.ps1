Login-AzureRmAccount

Show-SubscriptionARM

$resourceGroupName = '20533C0401-LabRG'

$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName
$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccount.StorageAccountName)[0].Value

# we are using default container 
$containerName = 'windows-powershell-dsc'

$configurationName = 'IISInstall'
$configurationPath = "$PSScriptRoot\$configurationName.ps1"

$moduleURL = Publish-AzureRmVMDscConfiguration -ConfigurationPath $configurationPath -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccount.StorageAccountName -Force

$storageContext = New-AzureStorageContext -StorageAccountName $storageAccount.StorageAccountName -StorageAccountKey $storageAccountKey
$sasToken = New-AzureStorageContainerSASToken -Name $containerName -Context $storageContext -Permission r

$settingsHashTable = @{
"ModulesUrl" = "$moduleURL";
"ConfigurationFunction" = "$configurationName.ps1\$configurationName";
"SasToken" = "$sasToken"
}

$vmName1= 'ResDevWebVM1'
$vmName2= 'ResDevWebVM2'
$extensionName = 'DSC'
$extensionType = 'DSC'
$publisher = 'Microsoft.Powershell'
$typeHandlerVersion = '2.1'

Set-AzureRmVMExtension  -ResourceGroupName $resourceGroupName -VMName $vmName1 -Location $storageAccount.Location `
-Name $extensionName -Publisher $publisher -ExtensionType $extensionType -TypeHandlerVersion $typeHandlerVersion `
-Settings $settingsHashTable

Set-AzureRmVMExtension  -ResourceGroupName $resourceGroupName -VMName $vmName2 -Location $storageAccount.location `
-Name $extensionName -Publisher $publisher -ExtensionType $extensionType -TypeHandlerVersion $typeHandlerVersion `
-Settings $settingsHashTable
