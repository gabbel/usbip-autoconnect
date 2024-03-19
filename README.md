
# Description

These scripts help to automate usbip on the server and client side.

Please note that this project is WIP, the server side should be functional and  complete, the client side is functional but incomplete.

## What you need.

A server, in my case it is an old Router with openwrt and a firmware that includes usbip.
A client, in my case a pop! Linux (ubuntu based distribution).


## How it works on the Server side.

Within openwrt, during boot the file '/etc/rc.local' will be checked for custom commands.
There the custom script '/usr/sbin/usbip-startup-share' is referenced.
That custom script will wait till the network interface is up and has an ip, then the script will check for connected usb devices, verify if they are allowed to be shared '/etc/usbip_allowed_usb_devices.txt' then share these using usbip.

The second script '/etc/hotplug.d/usb/90-usb_usbip' checks for changes on the usb bus.
It detects, if devices are beeing plugged, then shares them if allowed or when unplugged, unshares them.

### Setup server side:

Use scp to copy the files to openwrt.
```shell
scp usbip-startup-share root@openwrt.lan:/usr/sbin/usbip-startup-share
scp 90-usb_usbip root@openwrt.lan:/etc/hotplug.d/usb/90-usb_usbip
scp usbip_allowed_usb_devices.txt root@openwrt.lan:/etc/usbip_allowed_usb_devices.txt
```

Connect to the server using ssh
```shell
ssh root@openwrt.lan
```

Setup the scripts
```shell
# Download and install usbip
opkg update && opkg install usbip-server
# Autoexecute 'usbip-startup-share' on system startup
echo "/usr/sbin/usbip-startup-share" >> rc.local
# make sure that all scripts are executable
chmod +x /usr/sbin/usbip-startup-share
chmod +x /etc/hotplug.d/usb/90-usb_usbip

# Run these commands, in order to keep your custom configurations when running sysupgrades of openwrt.
echo "/usr/sbin/usbip-startup-share" >> /etc/sysupgrade.conf
echo "/etc/hotplug.d/usb/90-usb_usbip" >> /etc/sysupgrade.conf
echo "/etc/usbip_allowed_usb_devices.txt" >> /etc/sysupgrade.conf
echo "/etc/rc.local" >> /etc/sysupgrade.conf
```
## How it works on the Client side.

The script '/usr/local/bin/remote_connect_usbip.sh' gets executed once a minute using cron.
I checks if the server side does share devices over usbip and attaches all of them.

### Setup client side:

Setup the script

```shell
# Copy it somwehere that makes sense.
sudo cp remote_connect_usbip.sh /usr/local/bin/remote_connect_usbip.sh
# Make Script executable
sudo chmod +x /usr/local/bin/remote_connect_usbip.sh
# Run the script once not using cron to check the dependencies.
sudo /usr/local/bin/remote_connect_usbip.sh
```

Edit crontab
```shell
sudo crontab -e
```

Add this to crontab (script will execute once per minute)
```
# connect usb devices using usbip from remote server.
* * * * * /usr/local/bin/your_script.sh
```

Wait a minute
```shell
# check if script gets executed
grep CRON /var/log/syslog
```
