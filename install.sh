#!/bin/sh

echo "What OS are you installing on?"
echo "1 = TrueNAS CORE"
echo "2 = Proxmox"
echo "3 = pfSense"
read -p "My OS: " USER_OS
case $USER_OS in
    1) echo "You selected TrueNAS CORE" ;;
    2) echo "You selected Proxmox" ;;
    3) echo "You Selected pfSense" ;;
    *) echo "You didn't enter a proper selection, try again please." ;;
esac

if [ "$USER_OS" = "1" ]; then
    echo "copying files to /root/fan-control/"
    cp defaults_truenas/* /root/fan-control
    echo "making appropriate files executable"
    chmod 755 /root/fan-control/gen-config.py /root/fan-control/fan-control.py /root/fan-control/fan-control.sh
    echo "Starting nano to edit the config file generator that now. Ctrl+X when complete to save and exit."
    echo "(sleeping for 10 seconds to cancel if wanted)"
    sleep 10
    nano /root/fan-control/gen-config.py
    echo "Executing gen-config.py to generate the config file"
    /root/fan-control/gen-config.py
    echo "************************"
    echo "* USER ACTION REQUIRED *"
    echo "************************"
    echo "Go to the TrueNAS Core WebUI, log in, go to following menus:"
    echo "Tasks -> Init/Shutdown Scripts"
    echo "Add a task, type Command, command as:"
    echo "/root/fan-control/fan-control.sh start"
    echo "Set When to Post Init, and enable it then save." 
    echo "fan-control.py is setup. Starting the script now."
    nohup /root/fan-control/fan-control.sh start & # starting this way so it won't stop when exiting the shell
fi

if [ "$USER_OS" = "2" ]; then
    echo "copying files to /root/fan-control/"
    cp defaults_proxmox/* /root/fan-control
    echo "making appropriate files executable"
    chmod 755 /root/fan-control/gen-config.py /root/fan-control/fan-control.py
    echo "Starting nano to edit the config file generator that now. Ctrl+X when complete to save and exit."
    echo "(sleeping for 10 seconds to cancel if wanted)"
    sleep 10
    nano /root/fan-control/gen-config.py
    echo "Executing gen-config.py to generate the config file"
    /root/fan-control/gen-config.py
    echo "copying service file"
    cp /root/fan-control/fan-control.service /etc/systemd/system/fan-control.service
    echo "reloading daemons"
    systemctl daemon-reload
    echo "enabling fan-control.service"
    systemctl enable fan-control.service
    echo "starting fan-control"
    systemctl restart fan-control.service
    sleep 2
    systemctl status fan-control.service
fi

if [ "$USER_OS" = "3" ]; then
    echo "copying files to /root/fan-control/"
    cp defaults_pfsense/* /root/fan-control
    echo "making appropriate files executable"
    chmod 755 /root/fan-control/gen-config.py /root/fan-control/fan-control.py /root/fan-control/fan-control.sh
    echo "Starting nano to edit the config file generator that now. Ctrl+X when complete to save and exit."
    echo "(sleeping for 10 seconds to cancel if wanted)"
    sleep 10
    nano /root/fan-control/gen-config.py
    echo "Executing gen-config.py to generate the config file"
    /root/fan-control/gen-config.py
    echo "Copying fan-control.sh to /usr/local/etc/rc.d/ so it can auto start on reboots"
    cp fan-control.sh /usr/local/etc/rc.d/
    echo "fan-control.py is setup. Starting the script now."
    nohup /root/fan-control/fan-control.sh start & # starting this way so it won't stop when exiting the shell
fi


