--create snapshot for os disk

export osDiskId=$(az vm show  -g "main-rg" -n "main-mysqlupgrade"  --query "storageProfile.osDisk.managedDisk.id"  -o tsv)

az snapshot create -g main-rg --source "$osDiskId" --name main-mysql_ubuntu22

--create container in destination

az storage account create \
--name "toawsmigration" \
--resource-group "nodes-rg" \
--sku Standard_LRS

--get account key

az storage account keys list \
--account-name "toawsmigration" \
--resource-group "nodes-rg" \
--output table

export AZURE_STORAGE_ACCOUNT="toawsmigration"
export AZURE_STORAGE_KEY="TFPmwZqCUZensjGT+Vd+YzMej2jRAIlP4hrvU0+2JV/yq3sve1i0hbbgQjyesYOWW49ST/YQO0id+ASt10oOcw=="

--create blob storage in container

az storage container create --account-name "toawsmigration" --name "toawsmigrationcon"
export subscriptionId=$SUB_ID
export resourceGroupName="main-rg"
export snapshotName1="main-mysql_ubuntu22"
export storageAccountName="toawsmigration"
export storageContainerName="toawsmigrationcon"
export destinationVHDFileName1=oddiskmain-mysql_ubuntu22.vhd
export storageAccountKey="TFPmwZqCUZensjGT+Vd+YzMej2jRAIlP4hrvU0+2JV/yq3sve1i0hbbgQjyesYOWW49ST/YQO0id+ASt10oOcw=="

az account set --subscription $subscriptionId

--open sas for copy

sas1=$(az snapshot grant-access --resource-group $resourceGroupName --name $snapshotName1 --duration-in-seconds 86400 --query [accessSas] -o tsv)

sas1=$(az snapshot grant-access --resource-group $resourceGroupName --name $snapshotName1 --duration-in-seconds 86400 --query [accessSas] -o tsv)

--copy os disk

az storage blob copy start --destination-blob $destinationVHDFileName1 --destination-container $storageContainerName --account-name $storageAccountName --account-key $storageAccountKey --source-uri $sas1

--create disk from blob on portal azure and after than create vm from this disk

aws s3 cp main-rg-buyrubuntu2clone_osdisk1.vhd s3://migrationfromazure
                                                                                                                                                                                         
aws ec2 import-snapshot --disk-container "Format=VHD,UserBucket={S3Bucket=migrationfromazure,S3Key=osdiskmain-mysql_ubuntu22.vhd}" --output json
aws ec2 describe-import-snapshot-tasks --import-task-ids import-snap-02c678dc4a7697fff --output json

s3://migrationfromazure/main-mysql_ubuntu22.vhd
aws ec2 register-image --name main-rg-buyr_new_ubuntu22_os_disk_ami  --region=us-west-2 --description AMI_new_from_azure_main-rg-buyrubuntu22 --block-device-mappings DeviceName="/dev/xvda",Ebs={SnapshotId=snap-0f852df6cff9f10a3} --root-device-name "/dev/xvda" --architecture x86_64 --virtualization-type hvm
aws ec2 register-image --name main-mysql_ubuntu22_ami--region=us-west-2 --description AMI_from_azure_snapshot_fro_azure_main-mysql_ubuntu22 --block-device-mappings DeviceName="/dev/xvda",Ebs={SnapshotId=snap-0f852df6cff9f10a3} --root-device-name "/dev/xvda" --architecture x86_64 --virtualization-type hvm

aws s3 rm s3://migrationfromazure/osdisk_main-rg-buyrubuntu2.vhd