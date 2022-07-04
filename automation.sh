echo ">>>>apt update:"
apt update -y
echo ">>>>> Installing aws cli"
apt install awscli -y
apt install cron


s3_bucket=upgrad-angelina
name=angelina
DateTime=$(date '+%d%m%Y-%H%M%S')

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
systemctl is-enabled apache2 | grep "enabled" > /dev/null 2>&1
if [ $? != 0 ]
then
	systemctl enable apache2
	service apache2 restart > /dev/null
fi



tar -cvf /tmp/${name}-httpd-logs-${DateTime}.tar /var/log/apache2/error.log /var/log/apache2/access.log

aws s3 cp /tmp/${name}-httpd-logs-${DateTime}.tar s3://${s3_bucket}/${name}-httpd-logs-${DateTime}.tar

if [ -f "/var/www/html/inventory.html" ];
then
	echo "Inventory exists"
	size=$(du -s -h /tmp/$name-httpd-logs-$DateTime.tar | awk '{print $1}')
	echo "<p>httpd-logs&emsp;$DateTime&emsp;&emsp;logs&emsp;$size</p>" >> /var/www/html/inventory.html
else
	echo "Inventory does not exists. Creating Inventory..."
        touch /var/www/html/inventory.html
	printf "<p>" >> /var/www/html/inventory.html
B	echo "<p>Log Type&emsp;Date Created&emsp; &emsp;&emsp; Type&emsp;Size</p>" >> /var/www/html/inventory.html
	size=$(du -s -h /tmp/$name-httpd-logs-$DateTime.tar | awk '{print $1}')
        echo "<p>httpd-logs&emsp;$DateTime&emsp;&emsp;logs&emsp;$size</p>" >> /var/www/html/inventory.html
	printf "</p>" >> /var/www/html/inventory.html
fi

service cron start
echo ">>>>Checking whether cron is running or not"
service cron status | grep "active (running)" > /dev/null 2>&1
if [ $? != 0 ]
then
        service cron start > /dev/null
fi

echo ">>>>>Checking whether cron is enabled or not"
systemctl is-enabled cron | grep "enabled" > /dev/null 2>&1
if [ $? != 0 ]
then
        systemctl enable cron
        service cron restart > /dev/null
fi

if [ -f "/etc/cron.d/automation" ];
then
	echo "cron job available"
else
	echo "Creating cron job to run every day..."
	touch /etc/cron.d/automation
	echo "0 0 * * * root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
fi
