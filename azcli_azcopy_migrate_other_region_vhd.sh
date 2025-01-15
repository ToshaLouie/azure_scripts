export sourceDiskName="mainmysql_data_disk1"
export sourceRG="main"
export targetDiskName="mainwest_mysql_data_disk1"
export targetRG="sys-reserve"
export targetLocation="westus"


export sourceDiskSizeBytes=$(az disk show -g $sourceRG -n $sourceDiskName --query '[diskSizeBytes]' -o tsv)

az disk create -g $targetRG -n $targetDiskName -l $targetLocation --for-upload --upload-size-bytes $(($sourceDiskSizeBytes+512)) --sku standard_lrs  #target disk will be HDD, after process azcopy you can convert disk in new region

export targetSASURI=$(az disk grant-access -n $targetDiskName -g $targetRG --access-level Write --duration-in-seconds 864000 -o tsv)

export sourceSASURI=$(az disk grant-access -n $sourceDiskName -g $sourceRG --duration-in-seconds 864000 --query [accessSas] -o tsv)

azcopy copy $sourceSASURI $targetSASURI --blob-type PageBlob

az disk revoke-access -n $sourceDiskName -g $sourceRG

az disk revoke-access -n $targetDiskName -g $targetRG





