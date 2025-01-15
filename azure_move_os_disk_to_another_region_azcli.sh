#Move OS Disk to another region
--create snapshot for os disk

export osDiskId=$(az vm show  -g "sys-reserve" -n "mainwest"  --query "storageProfile.osDisk.managedDisk.id"  -o tsv)

az snapshot create -g sys-reserve --source "$osDiskId" --name osDisk-vm

--create container in destination

az storage account create \
--name "containerless" \
--resource-group "sys-reserve" \
--sku Standard_LRS

az storage account keys list \
--account-name "containerless" \
--resource-group "sys-reserve" \
--output table

export AZURE_STORAGE_ACCOUNT="containerless"
export AZURE_STORAGE_KEY="lQMHvuTSRreVH6Cio8/8tuEYI7m9fupUcFZ3B5WIO+cDQ2Rscg51Iw5RAAnAB64b6KSPwZyH9sEl9AlEmyV3gA=="

--create blob storage in container
az storage container create --name "containerlesscon"

export subscriptionId=$SUB_ID
export resourceGroupName="sys-reserve"
export snapshotName1="mainwest_mysql_disk_snap"
export storageAccountName="containerless"
export storageContainerName="containerlesscon"
export destinationVHDFileName1=mainwest_mysql_disk.vhd
export storageAccountKey="lQMHvuTSRreVH6Cio8/8tuEYI7m9fupUcFZ3B5WIO+cDQ2Rscg51Iw5RAAnAB64b6KSPwZyH9sEl9AlEmyV3gA=="

az account set --subscription $subscriptionId

--open sas for copy

export sas1=$(az disk grant-access -n "mainwest_mysql_disk" -g "sys-reserve" --duration-in-seconds 864000 --query [accessSas] -o tsv)

sas1=$(az snapshot grant-access --resource-group $resourceGroupName --name $snapshotName1 --duration-in-seconds 86400 --query [accessSas] -o tsv)

--copy os disk

az storage blob copy start --destination-blob $destinationVHDFileName1 --destination-container $storageContainerName --account-name $storageAccountName --account-key $storageAccountKey --source-uri $sas1

--create disk from blob on portal azure and after than create vm from this disk