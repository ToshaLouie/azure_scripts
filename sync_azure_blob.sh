#!/bin/bash
# copy file from local consent_capture to azure blob container
ZABBIX_SERVER='10.1.0.9'
ZABBIX_PORT=10051
log=/tmp/sync_azureblob.log
touch $log
localdir='/var/www/vhosts/project/www/protected/runtime/collective/consent_capture'

array_product=("loan" "ploan" "car" "datafeed" "business" "canada")
preview=$(date -d "yesterday" '+%Y-%m-%d')
year=$(date -d $preview +%Y)

for i in ${!array_product[*]}
do
if [ -d "$localdir/${array_product[$i]}" ] 
then
   # echo "Directory ${array_product[$i]} exists." s
    rclone copy $localdir/${array_product[$i]}/$year/$preview azureblob:consentcapture/${array_product[$i]}/$year/ | tee $log
    zabbix_sender -z $ZABBIX_SERVER -p $ZABBIX_PORT -s $1 -k custom.nodes.sync_azureblob.check -o 1
else
   # echo "Error: Directory ${array_product[$i]} does not exists." | tee $log
    zabbix_sender -z $ZABBIX_SERVER -p $ZABBIX_PORT -s $1 -k custom.nodes.sync_azureblob.check -o 0
    exit
fi
done
exit