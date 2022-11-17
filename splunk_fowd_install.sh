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

wget -O splunkforwarder-9.0.2-17e00c557dc1-Linux-x86_64.tgz "https://download.splunk.com/products/universalforwarder/releases/9.0.2/linux/splunkforwarder-9.0.2-17e00c557dc1-Linux-x86_64.tgz"
#wget -O splunkforwarder-9.0.1-82c987350fde-Linux-x86_64.tgz "https://download.splunk.com/products/universalforwarder/releases/9.0.1/linux/splunkforwarder-9.0.1-82c987350fde-Linux-x86_64.tgz"

tar -xvzf splunk*.tgz -C /opt

useradd -m splunk

export SPLUNK_HOME="/opt/splunkforwarder"

mkdir $SPLUNK_HOME

chown -R splunk:splunk $SPLUNK_HOM

chown -R splunk:splunk /opt/splunkforwarder

sudo /opt/splunkforwarder/bin/splunk start --accept-license

/opt/splunkforwarder/bin/splunk stop

/opt/splunkforwarder/bin/splunk enable boot-start

forarderdestconfig(){
         read -p "enter the destination IP or FQDN of splunk monitor/server" destination_IP
         read -p "enter the destination PORT of splunk monitor/server" destport
         sudo /opt/splunkforwarder/bin/splunk add forward-server $destination_IP:$destport
   }

forarderdestconfig(){
         read -p "full path of the directory you want yo monitor" addmonitor
         sudo /opt/splunkforwarder/bin/splunk add monitor $addmonitor
   }

read "Do you want to configure destination server for monitoring? (y/N)"userinput

   if [[ -z $userinput ]]; then
            if [[ $userinput == Y || $userinput == y ]]; then
               forarderdestconfig
            elif [[ $userinput == N || $userinput == n ]]; then
               echo "you can congigure destination later using the command - splunk add forward-server $destination_IP:$destport "
            fi      
   else  forarderdestconfig
   fi  

read "Do you want add nmonitor? (y/N)"userinputmonitor

   if [[ -z $userinput ]]; then
            if [[ $userinputmonitor == Y || $userinputmonitor == y ]]; then
               forarderdestconfig
            elif [[ $userinputmonitor == N || $userinputmonitor == n ]]; then
               echo "you can add monitor later using - splunk add monitor $addmonitor
   } "
            fi      
   else  forarderdestconfig
   fi  

   forarderdestconfig

sudo /opt/splunkforwarder/bin/splunk start
