#!/bin/bash

# Installation script for: disaggregation_logger-DSMR-P1-usb
# OS/HW: Raspbian / Raspberry Pi
# Path: /home/pi/disaggregation

# Get started:
# Download with: sudo wget https://raw.githubusercontent.com/disaggregation/installer/master/installer.sh
# Start with: sudo chmod +x disaggregtion_installer.sh && sudo ./disaggregtion_installer.sh

#***************************************************************************
printf "\e[33mInstallation of the Open source disaggregation DSMR P1 logger and webapp v0.1\n\n"
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
printf "\e[96m* GENERAL UPDATE(S)\n"
printf "\e[96m  - Update apt-get lists..."
sudo apt-get update >> disaggregation_installer.log
printf "\e[92mOK\e[0m\n"
printf "\e[96m  - install screen to run scripts in background..."
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
sudo locale-gen >> disaggregation_installer.log
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m* INSTALLING DISAGGREGATION FILES from github.com/disaggregation\n"
printf "\e[96m  - Creating folder structure(s)..."
sudo mkdir $log_dir >> disaggregation_installer.log
sudo mkdir $log_dir/data >> disaggregation_installer.log
sudo cd $log_dir >> disaggregation_installer.log
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m  - Downloading files..."
sudo wget -q https://github.com/disaggregation/logger-DSMR-P1-usb/archive/master.zip -O ${log_dir}/master-logger.zip --no-check-certificate >> disaggregation_installer.log
printf "\n\e[0mLogger\e[92m OK\e[0m\n"
sudo wget -q https://github.com/disaggregation/disaggregator-deltaPower/archive/master.zip -O ${log_dir}/master-disaggregator.zip --no-check-certificate >> disaggregation_installer.log
printf "\e[0mDisaggregator\e[92m OK\e[0m\n"
sudo wget -q https://github.com/disaggregation/viewer/archive/master.zip -O ${log_dir}/master-viewer.zip --no-check-certificate >> disaggregation_installer.log
printf "\e[0mViewer (WebApp)\e[92m OK\e[0m\n"
#***************************************************************************
printf "\e[96m  - Extracting files..."
sudo unzip -q -o ${log_dir}/master-logger.zip -d ${log_dir}/logger >> disaggregation_installer.log
sudo rm ${log_dir}/master-logger.zip >> disaggregation_installer.log
sudo mv ${log_dir}/logger/logger-DSMR-P1-usb-master/* ${log_dir}/logger
sudo rm -rf ${log_dir}/logger/logger-DSMR-P1-usb-master

sudo unzip -q -o ${log_dir}/master-disaggregator.zip -d ${log_dir}/disaggregator >> disaggregation_installer.log
sudo rm ${log_dir}/master-disaggregator.zip >> disaggregation_installer.log
sudo mv ${log_dir}/disaggregator/disaggregator-deltaPower-master/* ${log_dir}/disaggregator
sudo rm -rf ${log_dir}/disaggregator/disaggregator-deltaPower-master

sudo unzip -q -o ${log_dir}/master-viewer.zip -d ${log_dir}/viewer >> disaggregation_installer.log
sudo rm ${log_dir}/master-viewer.zip >> disaggregation_installer.log
sudo mv ${log_dir}/viewer/viewer-master/* ${log_dir}/viewer
sudo rm -rf ${log_dir}/viewer/viewer-master
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m  - Changing file permissions and rights to pi..."
sudo chmod -R 777 ${log_dir} >> disaggregation_installer.log
sudo chown -R pi ${log_dir} >> disaggregation_installer.log
printf "\e[92mOK\e[0m\n"
#***************************************************************************
# should be implemented
# printf "\e[96m  - creating venv..." 
# printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m* PYTHON AND PIP INSTALLATION\n"
sudo apt-get install python >/dev/null
sudo apt install python3-pip >/dev/null
printf "\e[96m* PYTHON DEPENDENCIES\n"
printf "\e[96m  - Downloading and installing pyserial..."
pip install pyserial >/dev/null
printf "\e[92mOK\e[0m\n"
printf "\e[96m  - Downloading and installing pandas..."
pip install pandas >/dev/null
printf "\e[92mOK\e[0m\n"
printf "\e[96m  - Downloading and installing IPython..."
pip install IPython >/dev/null
printf "\e[92mOK\e[0m\n"
printf "\e[96m  - Downloading and installing plotly..."
pip install plotly >/dev/null
printf "\e[92mOK\e[0m\n"
printf "\e[96m  - Downloading and installing cufflinks..."
pip install cufflinks >/dev/null
printf "\e[92mOK\e[0m\n"
printf "\e[96m  - Downloading and installing flask..."
pip install flask --upgrade >/dev/null
pip install flask-cli >/dev/null
printf "\e[92mOK\e[0m\n"
#***************************************************************************
printf "\e[96m* CONFIGURE\n"
printf "\e[96m  - Set CRON-jobs...\n"
sudo cd ${log_dir}
echo "@reboot screen -dmS atboot_disaggregation_P1_logger /usr/bin/python  ${log_dir}/logger/schedule_p1_reader.py >> ${log_dir}/cron.log 2>&1" >> tempcron
echo "@reboot screen -dmS atboot_disaggregation_disaggregator /usr/bin/python  ${log_dir}/disaggregator/schedule_disaggregator.py >> ${log_dir}/cron.log 2>&1" >> tempcron
echo "@reboot screen -dmS atboot_disaggregation_viewer /usr/bin/python  ${log_dir}/viewer/start_webserver.py >> ${log_dir}/cron.log 2>&1" >> tempcron
crontab tempcron
sudo rm tempcron
printf "\e[92mOK\e[0m\n"
#***************************************************************************
if ls /dev | grep 'ttyUSB' >/dev/null 2>&1; then 
  printf "\e[96m  - Start logger DSMR P1 script..."
  screen -dmS atboot_P1_logger /usr/bin/python ${log_dir}/schedule_p1_reader.py 2>&1 >> disaggregation_installer.log 
  printf "\e[92m - OK\e[0m\n"

#printf "\e[96m  - Init website DB..."
# should be implemented
  printf "\e[96m  - Start viewer (website at localhost:5000)..."
  screen -dmS atboot_disaggregation_viewer /usr/bin/python ${log_dir}/start_webserver.py 2>&1 >> disaggregation_installer.log 
  printf "\e[92m - OK\e[0m\n"

  printf "\e[96m  - Start disaggregator..."
  screen -dmS atboot_disaggregation_disaggregator /usr/bin/python ${log_dir}/disaggregator/schedule_disaggregator.py 2>&1 >> disaggregation_installer.log 
  printf "\e[92m - OK\e[0m\n"
  printf "\e[92mOK\e[0m\n"
else
  printf "\e[91mUSB NOT FOUND, could not start scripts! Connect USB cable and reboot! ;0)\e[0m\n"
fi

#***************************************************************************
printf "\n\e[91mEnd of installation\e[0m - \e[92mOpen Source disaggregation code installed. ;-)\n\e[0m"
#***************************************************************************
