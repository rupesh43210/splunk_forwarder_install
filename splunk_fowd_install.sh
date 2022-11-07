#!/bin/bash

REQUIRED_PKG="sudo"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
   apt-get --yes install $REQUIRED_PKG
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   echo " do a sudo su"
   exit 1
fi

sudo apt update 

sudo apt install -y curl

sudo apt install -y git

sudo apt install -y wget 

wget -O splunkforwarder-9.0.1-82c987350fde-Linux-x86_64.tgz "https://download.splunk.com/products/universalforwarder/releases/9.0.1/linux/splunkforwarder-9.0.1-82c987350fde-Linux-x86_64.tgz"

tar -xvzf splunk*.tgz -C /opt

useradd -m splunk

export SPLUNK_HOME="/opt/splunkforwarder"

mkdir $SPLUNK_HOME

chown -R splunk:splunk $SPLUNK_HOM

chown -R splunk:splunk /opt/splunkforwarder

sudo /opt/splunkforwarder/bin/splunk start --accept-license

/opt/splunkforwarder/bin/splunk stop

/opt/splunkforwarder/bin/splunk enable boot-start

sudo /opt/splunkforwarder/bin/splunk add forward-server 52.220.216.171:9997

sudo /opt/splunkforwarder/bin/splunk add monitor /var/log

sudo /opt/splunkforwarder/bin/splunk start
