#!/bin/bash

# Installation script for: disaggregation_logger-DSMR-P1-usb
# OS/HW: Raspbian / Raspberry Pi
# Path: /home/pi/disaggregation

# Get started:
# Download with: sudo wget https://raw.githubusercontent.com/disaggregation/installer/master/installer.sh
# Start with: sudo chmod +x install.sh && sudo ./installer.sh

#***************************************************************************
printf "\e[33mInstallation of the open source disaggregation logger and website started v0.1\n\n"
#***************************************************************************
log_dir="/home/pi/disaggregation"
read -e -i "$log_dir" -p "Please enter your prefered directory: " input
log_dir="${input:-$name}"

printf "\e[96m* CHECK\n"
printf "\e[96m  - Check if USB Serial port is found..."
#comment by Arne: I changed ttyUSB0 to ttyUSB, because serial does not have to be on usb port 0
if ls /dev | grep 'ttyUSB' >/dev/null 2>&1; then 
  printf "\e[92mOK\e[0m\n"
else
  printf "\e[91mUSB NOT FOUND! Connect USB or order one online! ;0)\e[0m\n"
fi
#***************************************************************************
printf "\e[96m* GENERAL UPDATE\n"
printf "\e[96m  - Update apt-get lists..."
sudo apt-get update &>/dev/null
sudo apt-get install screen
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m  - Set timezone..."
sudo sudo cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m  - Generate languages..."
sudo bash -c "echo 'nl_NL.UTF-8 UTF-8' >> /etc/locale.gen"
sudo bash -c "echo 'nl_NL ISO-8859-1' >> /etc/locale.gen"
sudo locale-gen &>/dev/null
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m* DSRM P1 LOGGER FILES\n"
printf "\e[96m  - Creating folder structure(s)..."
sudo mkdir $log_dir &>/dev/null
sudo mkdir $log_dir "/data" &>/dev/null
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m  - Downloading files..."
sudo rm ${log_dir}/master-logger.zip &>/dev/null
sudo wget -q https://github.com/disaggregation/logger-DSMR-P1-usb/archive/master.zip -O ${log_dir}/master-logger.zip &>/dev/null
printf "\e[92mLogger OK\e[0m\n"
sudo rm ${log_dir}/master-disaggregator.zip &>/dev/null
sudo wget -q https://github.com/disaggregation/disaggregtor-deltaP/archive/master.zip -O ${log_dir}/master-disaggregator.zip &>/dev/null
printf "\e[92mDisaggregation OK\e[0m\n"
sudo rm ${log_dir}/master-viewer.zip &>/dev/null
sudo wget -q https://github.com/disaggregation/viewer/archive/master.zip -O ${log_dir}/master-viewer.zip &>/dev/null
printf "\e[92mViewer (website) OK\e[0m\n"
#***************************************************************************
printf "\e[96m  - Extracting files..."
sudo unzip -q -o ${log_dir}/master-logger.zip -d ${log_dir} &>/dev/null
sudo unzip -q -o ${log_dir}/master-disaggregator.zip -d ${log_dir} &>/dev/null
sudo unzip -q -o ${log_dir}/master-viewer.zip -d ${log_dir} &>/dev/null
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m  - Cleanup files..."
sudo rm ${log_dir}/master-logger.zip &>/dev/null
sudo rm ${log_dir}/master-disaggregator.zip &>/dev/null
sudo rm ${log_dir}/master-viewer.zip &>/dev/null
sudo mv ${log_dir}/logger-DSMR-P1-usb-master/* .
sudo rm ${log_dir}/logger-DSMR-P1-usb-master
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m  - Changing file permissions and rights to pi..."
sudo chmod -R 777 ${log_dir} &>/dev/null
sudo chown -R pi ${log_dir} &>/dev/null
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m* PYTHON DEPENDENCIES\n"
printf "\e[96m  - Downloading and installing pyserial..."
pip install pyserial >/dev/null
printf "\e[96m  - Downloading and installing plotly..."
pip install plotly >/dev/null
printf "\e[96m  - Downloading and installing cufflings..."
pip install cufflings >/dev/null
printf "\e[96m  - Downloading and installing flask..."
pip install flask >/dev/null
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m* CONFIGURE\n"
printf "\e[96m  - Set CRON-jobs..."
sudo cd ${log_dir}
echo "@reboot screen -dmS atboot_disaggregation_P1_logger /usr/bin/python  ${log_dir}/schedule_p1_reader.py" >> tempcron
echo "@reboot screen -dmS atboot_disaggregation_disaggregator /usr/bin/python  ${log_dir}/schedule_disaggregator.py" >> tempcron
echo "@reboot screen -dmS atboot_disaggregation_viewer /usr/bin/python  ${log_dir}/schedule_viewer.py" >> tempcron
crontab tempcron
sudo rm tempcron
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m  - Start DSMR P1 script..."
screen -dmS atboot_P1_logger /usr/bin/python ${log_dir}/schedule_p1_reader.py 2>&1 &>/dev/null 
printf "\e[92m - OK\e[0m\n"
printf "\e[96m  - Start disaggregator..."
screen -dmS atboot_disaggregation_disaggregator /usr/bin/python ${log_dir}/schedule_disaggregator.py 2>&1 &>/dev/null 
printf "\e[92m - OK\e[0m\n"
printf "\e[96m  - Start viwer (website at localhost:5000)..."
screen -dmS atboot_disaggregation_viewer /usr/bin/python ${log_dir}/schedule_viewer.py 2>&1 &>/dev/null 
printf "\e[92m - OK\e[0m\n"
#***************************************************************************
printf "\n\e[33mEnd of installation - Open Source disaggregation project installed. ;-)\n"
#***************************************************************************