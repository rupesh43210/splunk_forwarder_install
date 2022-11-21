#!/bin/bash

REQUIRED_PKG="sudo"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: "$PKG_OK"
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

#setup functions

forarderdestconfig(){
         read -r -p "Enter the destination IP or FQDN of splunk monitor/server: " destination_IP
         read -r -p "Enter the destination PORT of splunk monitor/server: " destport
         echo you have set destination monitoring server as "$destination_IP:$destport"
            if [[  $destination_IP &&  $destport ]]; then
               finaldestination="$destination_IP:$destport"
               sudo /opt/splunkforwarder/bin/splunk add forward-server "$finaldestination"
               else echo "invalid entry"
                     forarderdestconfig
               fi
   }

forarderdmonconfig(){
         read -r -p "full path of the directory you want to monitor: " addmonitor

         if [[ -z $addmonitor ]]; then
         sudo /opt/splunkforwarder/bin/splunk add monitor "$addmonitor"
         else echo "invalid entry"
            forarderdestconfig
         fi
   }



#Proceed with script fetching and innstallation
wget -O splunkforwarder-9.0.2-17e00c557dc1-Linux-x86_64.tgz "https://download.splunk.com/products/universalforwarder/releases/9.0.2/linux/splunkforwarder-9.0.2-17e00c557dc1-Linux-x86_64.tgz"

tar -xvzf splunk*.tgz -C /opt

useradd -m splunk

export SPLUNK_HOME="/opt/splunkforwarder"

mkdir $SPLUNK_HOME

chown -R splunk:splunk $SPLUNK_HOME

chown -R splunk:splunk /opt/splunkforwarder

sudo /opt/splunkforwarder/bin/splunk start --accept-license


read -r -p "Do you want to configure destination server for monitoring?: (y/N): " userinput

               if [[ -z $userinput ]]; then
                        if [[ $userinput == Y || $userinput == y ]]; then
                           forarderdestconfig

                              read -r -p "Do you want add Monitor? (Y/n): " userinputmonitor
                              if [[ $userinputmonitor == Y || $userinputmonitor == y ]]; then
                                       if [[ $userinputmonitor == Y || $userinputmonitor == y ]]; then
                                          forarderdmonconfig
                                       elif [[ $userinputmonitor == N || $userinputmonitor == n ]]; then
                                          echo "you can add monitor later using command - splunk add monitor $addmonitor"
                                       fi      
                              else  forarderdmonconfig
                              fi  

                        elif [[ $userinput == N || $userinput == n ]]; then
                           echo "you can congigure destination later using the command - splunk add forward-server $destination_IP:$destport "
                        fi      
               else  forarderdestconfig
               fi  



/opt/splunkforwarder/bin/splunk stop

/opt/splunkforwarder/bin/splunk enable boot-start

sudo /opt/splunkforwarder/bin/splunk start
