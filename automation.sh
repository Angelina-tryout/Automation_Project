
echo ">>>>apt update:"
apt update -y
echo ">>>>> Installing aws cli"
apt install awscli -y

#Variables
s3_bucket=upgrad-angelina
name=angelina
DateTime=$(date '+%d%m%Y-%H%M%S')

#Apache Check on Installation | Active | Enabled
echo ">>>>Checking whether apache installed or not"
dpkg --get-selections | grep apache2 > /dev/null 2>&1
if [ $? != 0 ]
then
		apt install apache2 -y
fi

service apache2 start
echo ">>>>Checking whether apache2 is running or not"
service apache2 status | grep "active (running)" > /dev/null 2>&1
if [ $? != 0 ]
then
		service apache2 start > /dev/null
fi

echo ">>>>>Checking whether apcehe2 is enabled or not"
systemctl is-active apache2 | grep "enabled" > /dev/null 2>&1
if [ $? != 0 ]
then
		systemctl enable apache2
		service apache2 restart > /dev/null
fi

tar -cvf /tmp/${name}-httpd-logs-${DateTime}.tar /var/log/apache2/error.log /var/log/apache2/access.log

aws s3 cp /tmp/${name}-httpd-logs-${DateTime}.tar s3://${s3_bucket}/${name}-httpd-logs-${DateTime}.tar

